"""Transparent, entirely local, non-generative course and vocabulary study engine.

Uses lexical ranking (BM25), source-grounded extraction, rules and local dictionary
lookup. Does not train or run a large language model; absent evidence is disclosed.
"""
from __future__ import annotations
from dataclasses import dataclass
from collections import Counter
from pathlib import Path
from math import log
from typing import Iterable
import json
import re
import zipfile
import xml.etree.ElementTree as ET

STOP = set('a an the and of for to in on with what is are was were this that do does did can could please explain tell show give me i my your you how when why who about from as using one some current study lesson topic'.split())
TOKEN = re.compile(r"[a-zA-Z][a-zA-Z0-9'-]*")
SENTENCE = re.compile(r'(?<=[.!?])\s+(?=[A-Z0-9])')
MAX_ATTACHMENT_BYTES = 12 * 1024 * 1024

@dataclass(frozen=True)
class Entry:
    course: str
    title: str
    source: str
    body: str
    objective: str = ''
    example: str = ''
    question: str = ''
    answer: str = ''


def tokens(text: str) -> list[str]:
    return [w.lower() for w in TOKEN.findall(text) if len(w)>1 and w.lower() not in STOP]


def read_seeded(path: Path) -> list[Entry]:
    if not path.is_file(): return []
    data = path.read_text('utf-8-sig')
    match = re.search(r'var\s+library\s*=\s*(\{.*?\})\s*;\s*function\s+findCourse', data, re.S)
    if not match:
        raise ValueError('The seeded course library format was not recognized.')
    library = json.loads(match.group(1))
    entries=[]
    for code, course in library.items():
        name = str(course.get('title',code))
        for number, topic in enumerate(course.get('topics',[]),1):
            entries.append(Entry(name,str(topic.get('title','Topic')),f'{code} · Lesson {number}',
                str(topic.get('lesson','')), str(topic.get('objective','')),
                str(topic.get('example','')),str(topic.get('question','')),str(topic.get('answer',''))))
        for number, material in enumerate(course.get('materials',[]),1):
            entries.append(Entry(name,str(material.get('title','Reading')),f'{code} · Reading {number}',str(material.get('body',''))))
    return entries


def _text_from_file(path: Path, cap=45000) -> str:
    if not path.is_file() or path.stat().st_size>MAX_ATTACHMENT_BYTES:
        raise ValueError('Document is missing or larger than 12 MB.')
    ext=path.suffix.lower()
    if ext in ('.txt','.md','.csv'):
        return path.read_text('utf8',errors='replace')[:cap]
    if ext=='.docx':
        with zipfile.ZipFile(path) as z:
            if 'word/document.xml' not in z.namelist(): raise ValueError('DOCX text was not found.')
            root=ET.fromstring(z.read('word/document.xml'))
            pieces=[]
            for paragraph in root.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p'):
                s=''.join(t.text or '' for t in paragraph.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t'))
                if s:pieces.append(s)
            return '\n'.join(pieces)[:cap]
    if ext=='.pdf':
        try:
            from pypdf import PdfReader
        except ImportError as exc:
            raise ValueError('Text-based PDFs require the optional pypdf package.') from exc
        reader=PdfReader(str(path)); out=[]
        for page in reader.pages[:70]:
            out.append(page.extract_text() or '')
            if sum(map(len,out))>cap:break
        result='\n'.join(out)[:cap]
        if not result.strip():raise ValueError('No searchable text in this PDF. Scanned pages need OCR.')
        return result
    raise ValueError('Supported documents: TXT, MD, CSV, DOCX and text-based PDF.')


def load_workspace(workspace_json: Path) -> list[Entry]:
    if not workspace_json.is_file():return []
    data=json.loads(workspace_json.read_text('utf8'))
    entries=[]
    for note in data.get('notes',[])[:90]:
        if isinstance(note,dict) and note.get('body'):
            entries.append(Entry('My Notes',str(note.get('title','Saved note')),f'Note · {note.get("title","Saved note")}',str(note['body'])[:16000]))
    material_dir=(workspace_json.parent/'materials').resolve()
    for row in data.get('files',[])[:35]:
        if not isinstance(row,dict):continue
        try:
            file=Path(str(row.get('path',''))).resolve(strict=True)
            if not file.is_relative_to(material_dir): continue
            body=_text_from_file(file,26000)
        except (OSError,ValueError,RuntimeError,zipfile.BadZipFile):
            continue
        if body.strip(): entries.append(Entry('My Files',str(row.get('name','Imported material')),f'File · {file.name}',body))
    return entries


def ranked(entries: list[Entry], query: str, course='', allowed_courses: list[str]|None=None, limit=3) -> list[tuple[float,Entry]]:
    q=set(tokens(query)); course=course.strip().casefold()
    if not q:return []
    # CAMPUS_POP_OPEN_RANK_V26 - keep licensed reference passages eligible alongside course notes.
    filtered=[e for e in entries if not course or e.course.casefold()==course or (e.course in ('My Notes','My Files') or e.course.startswith('Open Library ·'))]
    if not course and allowed_courses:
        allowed={n.casefold() for n in allowed_courses}
        filtered=[e for e in filtered if e.course.casefold() in allowed or (e.course in ('My Notes','My Files') or e.course.startswith('Open Library ·'))]
    if not filtered:return []
    term_counts=[]
    for e in filtered:
        term_counts.append(Counter(tokens(e.title+' '+e.title+' '+e.objective+' '+e.body+' '+e.example)))
    lens=[sum(c.values()) for c in term_counts]; avg=sum(lens)/max(len(lens),1)
    df=Counter()
    for counts in term_counts:df.update(counts.keys())
    out=[]; n=len(filtered)
    for i,e in enumerate(filtered):
        score=0.0
        for word in q:
            freq=term_counts[i][word]
            if not freq:continue
            idf=log(1+(n-df[word]+0.5)/(df[word]+0.5))
            score+=idf*(freq*2.2)/(freq+1.2*(0.25+0.75*lens[i]/max(avg,1)))
        title_terms=set(tokens(e.title))
        title_hits=len(q.intersection(title_terms))
        score += 1.2*title_hits
        matched=len(q.intersection(term_counts[i]))
        if (len(q)==1 and matched>0 or matched>=2 or title_hits>0) and score>0.18:
            out.append((score,e))
    out.sort(key=lambda item:-item[0]);return out[:limit]


def extract_summary(text: str, limit=5) -> str:
    sentences=[s.strip() for s in SENTENCE.split(re.sub(r'\s+',' ',text)) if len(s.strip())>=28]
    if not sentences:
        return text.strip()[:900] or 'No readable text was found.'
    counts=Counter(tokens(text))
    ranked_sentences=[]
    for i,s in enumerate(sentences[:300]):
        words=tokens(s)
        if words:
            val=sum(counts.get(w,0)**0.5 for w in set(words))/max(1,len(words)**0.5)
            ranked_sentences.append((val,i,s))
    best=sorted(sorted(ranked_sentences,reverse=True)[:limit],key=lambda x:x[1])
    return '\n'.join('• '+s for _,_,s in best)


COMMON = {
 'algorithm':'A finite, ordered sequence of steps that solves a defined problem.',
 'variable':'A named value or characteristic that may change.',
 'probability':'A numerical measure of how likely an event is, ranging from zero to one.',
 'hypothesis':'A testable statement or tentative explanation examined using evidence.',
 'sample':'A subset selected from a larger population for observation.',
 'population':'The entire group about which a study draws conclusions.',
 'function':'A reusable procedure or mathematical mapping that relates inputs to outputs.',
 'iteration':'A repeated execution of steps until a condition is met.',
 'syntax':'The rules governing how symbols or words are arranged in a language.',
 'semantics':'The meaning assigned to words, expressions or program statements.',
 'inference':'A conclusion reached from observations, evidence or premises.',
 'distribution':'The pattern describing how observed or possible values occur.',
 'parameter':'A numerical characteristic of a population or a named input to a function, depending on context.',
 'correlation':'A measure of association between variables; it does not by itself prove causation.',
 'context':'The surrounding circumstances or text that determine interpretation.',
 'noun':'A word used to name a person, place, thing or idea.',
 'verb':'A word that expresses an action, occurrence or state.',
 'adjective':'A word that modifies or describes a noun.',
 'adverb':'A word that modifies a verb, adjective or other adverb.'
}


def define_english(query: str) -> str|None:
    m=re.search(r'\b(?:define|definition of|meaning of|what does|what is the meaning of|synonyms? (?:for|of)|antonyms? (?:for|of))\s+["\']?([a-z][a-z-]*(?:\s+[a-z-]+){0,2})',query,re.I)
    if not m:return None
    phrase=m.group(1).strip().lower()
    phrase=re.sub(r'\s+(in|for|mean|please|and|as|with)\b.*$','',phrase).strip()
    word=phrase.split(' ')[0]
    parts=[]
    try:
        from nltk.corpus import wordnet as wn
        senses=wn.synsets(phrase.replace(' ','_'))[:3]
        for sense in senses:
            alts=[l.name().replace('_',' ') for l in sense.lemmas() if l.name().replace('_',' ').lower()!=phrase][:4]
            parts.append('• '+sense.definition()+(' (Related: '+', '.join(alts)+')' if alts else ''))
        if parts:return 'English dictionary · '+phrase+'\n'+'\n'.join(parts)+'\nSource: locally installed WordNet.'
    except (ImportError,LookupError,OSError):pass
    if word in COMMON:
        return 'English glossary · '+word+'\n'+COMMON[word]+'\nSource: built-in StudySpace starter glossary. Install WordNet for wider coverage.'
    return 'I do not have a verified entry for “'+phrase+'” in the local dictionary. Install WordNet to add a much larger English lexicon.'


def answer(question: str, course: str, mode: str, entries: list[Entry], allowed_courses=None,
           attachment: str='', strategy: str='worked example',
           profile_name: str='', program: str='', study_year: str='') -> str:
    q=question.strip()
    if not q and not attachment:
        return 'Ask about a course topic or choose a document.'
    if re.search(r'\b(who am i|what is my name|my username)\b',q,re.I):
        return ('Your saved Campus Pop username is '+profile_name+'.' if profile_name
                else 'You have not chosen a username during onboarding yet.')
    if re.search(r'\b(what|which|list|show)\b.*\b(my courses|courses am i studying|enrolled courses|my modules)\b',q,re.I):
        return ('Your enrolled courses are: '+', '.join(allowed_courses)+'.' if allowed_courses
                else 'You have not selected any courses in onboarding yet.')
    if re.search(r'\b(my programme|my program|what am i studying)\b',q,re.I):
        return ('Saved programme: '+program+'.' if program else 'Your programme is not filled in under Settings → Profile.')
    if re.search(r'\b(my level|year of study)\b',q,re.I):
        return ('Saved study level: '+study_year+'.' if study_year else 'Your study level is not filled in yet.')
    if re.fullmatch(r'(hello|hi|hey|sup|good morning|good evening)[!. ]*',q.lower()):
        return 'Hello! I am the Campus Pop Offline Study Guide. Choose a course and ask about a topic, request a practice question, or ask me to define a word.'
    definition=define_english(q)
    if definition and not definition.startswith('I do not have a verified entry'):return definition
    if attachment:
        try:
            text=_text_from_file(Path(attachment))
            return 'Summary of '+Path(attachment).name+' (extractive; original sentences):\n'+extract_summary(text)
        except Exception as exc:
            return 'I could not read the attachment: '+str(exc)
    matches=ranked(entries,q,course,allowed_courses,limit=2)
    if not matches:
        return ('I cannot find a reliable answer in your available course lessons or notes. '
                'Try a more specific topic, select a different course, or import relevant material. '
                'I will not invent an explanation.')
    best=matches[0][1]
    source=best.source+' — '+best.title
    heading=f'{best.title} · {best.course}'
    if mode=='Practice' or strategy=='retrieval practice' or any(t in q.lower() for t in ('quiz me','practice question','test me')):
        if best.question:return f'{heading}\n\nTry this:\n{best.question}\n\nThink through your answer first, then ask “show the answer for {best.title}”.\n\nSource: {source}'
    if re.search(r'\b(show|reveal|give)\s+(the\s+)?answer\b',q,re.I) and best.answer:
        return f'{heading}\n\nAnswer: {best.answer}\n\nSource: {source}'
    if mode=='Summarise' or any(t in q.lower() for t in ('summarize','summarise','key points')):
        excerpt=best.body+' '+best.example
        return f'{heading}\n\nKey points (from your material):\n{extract_summary(excerpt,4)}\n\nSource: {source}'
    if mode=='Guided' or strategy=='guided questions':
        return f'{heading}\n\nLearning objective: {best.objective or best.title}\n\nGuiding question: {best.question or "What do you already know about this topic?"}\n\nHint: {best.body[:480]}\n\nSource: {source}'
    explanation=best.body.strip()
    if not explanation:return f'I found a reference title but no explanation for {best.title}. Source: {source}'
    out=f'{heading}\n\n{explanation[:1400]}'
    if best.example:out+='\n\nWorked example from your material:\n'+best.example[:650]
    if best.question:out+='\n\nCheck your understanding:\n'+best.question[:330]
    return out+'\n\nSource: '+source+'\nThis explanation uses your available material; it is not generated by an LLM.'
