"""Open-license academic/reference search store for Campus Pop.

No LLM. No hidden crawling. Only explicitly curated licensed document endpoints
are synchronized, on user request; content is locally indexed and attributed.
"""
from __future__ import annotations
from dataclasses import dataclass
from datetime import datetime, timezone
from html import unescape
from html.parser import HTMLParser
from pathlib import Path
from sqlite3 import connect, OperationalError
from urllib.parse import urlparse
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
import json
import re
import time
import xml.etree.ElementTree as ET

USER_AGENT = 'CampusPopKnowledgeSync/1.0 (educational app; source and licenses retained)'
MAX_TEXT_BYTES = 1_600_000
MAX_PDF_BYTES = 9_500_000
MAX_PDF_PAGES = 115
MAX_CHUNK = 1900
MIN_CHUNK = 50

# These links are to independently verifiable, licensed document *sources*.
# We do not reuse W3Schools, GeeksforGeeks or OpenStax content.
@dataclass(frozen=True)
class Source:
    id: str
    title: str
    subject: str
    author: str
    license: str
    license_url: str
    public_url: str
    download_url: str
    format: str = 'markdown'
    enabled: bool = True


def _github(owner, repository, branch, path):
    return f'https://raw.githubusercontent.com/{owner}/{repository}/{branch}/{path}'

PSF_LICENSE='https://docs.python.org/3/license.html'
MDN_LICENSE='https://developer.mozilla.org/en-US/docs/MDN/Writing_guidelines/Attrib_copyright_license'
MICROSOFT_LICENSE='https://github.com/dotnet/docs/blob/main/LICENSE'
OPENINTRO_LICENSE='https://www.openintro.org/license/'
CPP_LICENSE='https://www.cppreference.com/Cppreference:About'
JAVA_LICENSE='https://creativecommons.org/licenses/by/4.0/'

CATALOGUE = [
    Source('python_intro','Python Tutorial · Introduction','Python','Python Software Foundation','PSF-2.0',PSF_LICENSE,'https://docs.python.org/3/tutorial/introduction.html',_github('python','cpython','main','Doc/tutorial/introduction.rst'),'rst'),
    Source('python_control','Python Tutorial · Control Flow','Python','Python Software Foundation','PSF-2.0',PSF_LICENSE,'https://docs.python.org/3/tutorial/controlflow.html',_github('python','cpython','main','Doc/tutorial/controlflow.rst'),'rst'),
    Source('python_structures','Python Tutorial · Data Structures','Python','Python Software Foundation','PSF-2.0',PSF_LICENSE,'https://docs.python.org/3/tutorial/datastructures.html',_github('python','cpython','main','Doc/tutorial/datastructures.rst'),'rst'),
    Source('python_classes','Python Tutorial · Classes','Python','Python Software Foundation','PSF-2.0',PSF_LICENSE,'https://docs.python.org/3/tutorial/classes.html',_github('python','cpython','main','Doc/tutorial/classes.rst'),'rst'),
    Source('js_intro','JavaScript Guide · Introduction','JavaScript','Mozilla Contributors','CC BY-SA 2.5+',MDN_LICENSE,'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Introduction',_github('mdn','content','main','files/en-us/web/javascript/guide/introduction/index.md')),
    Source('js_types','JavaScript Guide · Grammar and Types','JavaScript','Mozilla Contributors','CC BY-SA 2.5+',MDN_LICENSE,'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Grammar_and_types',_github('mdn','content','main','files/en-us/web/javascript/guide/grammar_and_types/index.md')),
    Source('js_flow','JavaScript Guide · Control Flow','JavaScript','Mozilla Contributors','CC BY-SA 2.5+',MDN_LICENSE,'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Control_flow_and_error_handling',_github('mdn','content','main','files/en-us/web/javascript/guide/control_flow_and_error_handling/index.md')),
    Source('js_functions','JavaScript Guide · Functions','JavaScript','Mozilla Contributors','CC BY-SA 2.5+',MDN_LICENSE,'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Functions',_github('mdn','content','main','files/en-us/web/javascript/guide/functions/index.md')),
    Source('vb_objects','Visual Basic · Objects and Classes','Visual Basic','Microsoft','CC BY 4.0',MICROSOFT_LICENSE,'https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/objects-and-classes/',_github('dotnet','docs','main','docs/visual-basic/programming-guide/language-features/objects-and-classes/index.md')),
    Source('vb_arrays','Visual Basic · Parameter Arrays','Visual Basic','Microsoft','CC BY 4.0',MICROSOFT_LICENSE,'https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/parameter-arrays',_github('dotnet','docs','main','docs/visual-basic/programming-guide/language-features/procedures/parameter-arrays.md')),
    Source('vb_keywords','Visual Basic · Keywords and Element Names','Visual Basic','Microsoft','CC BY 4.0',MICROSOFT_LICENSE,'https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/program-structure/keywords-as-element-names-in-code',_github('dotnet','docs','main','docs/visual-basic/programming-guide/program-structure/keywords-as-element-names-in-code.md')),
    Source('cpp_classes','C++ · Classes','C++','cppreference contributors','CC BY-SA 3.0',CPP_LICENSE,'https://en.cppreference.com/w/cpp/language/classes','https://en.cppreference.com/w/cpp/language/classes','html'),
    Source('cpp_vectors','C++ · std::vector','C++','cppreference contributors','CC BY-SA 3.0',CPP_LICENSE,'https://en.cppreference.com/w/cpp/container/vector','https://en.cppreference.com/w/cpp/container/vector','html'),
    Source('cpp_pointers','C++ · Pointers','C++','cppreference contributors','CC BY-SA 3.0',CPP_LICENSE,'https://en.cppreference.com/w/cpp/language/pointer','https://en.cppreference.com/w/cpp/language/pointer','html'),
    Source('math_data','Statistics · Introduction to Data','Math & Statistics','Mine Çetinkaya-Rundel, Johanna Hardin and OpenIntro contributors','CC BY-SA 3.0',OPENINTRO_LICENSE,'https://openintrostat.github.io/ims/introduction-to-data.html',_github('OpenIntroStat','ims','main','introduction-to-data.qmd'),'qmd'),
    Source('math_explore','Statistics · Numerical Data','Math & Statistics','Mine Çetinkaya-Rundel, Johanna Hardin and OpenIntro contributors','CC BY-SA 3.0',OPENINTRO_LICENSE,'https://openintrostat.github.io/ims/explore-numerical.html',_github('OpenIntroStat','ims','main','explore-numerical.qmd'),'qmd'),
    Source('math_infer','Statistics · Foundations of Inference','Math & Statistics','Mine Çetinkaya-Rundel, Johanna Hardin and OpenIntro contributors','CC BY-SA 3.0',OPENINTRO_LICENSE,'https://openintrostat.github.io/ims/foundations-of-inference.html',_github('OpenIntroStat','ims','main','foundations-of-inference.qmd'),'qmd'),
    Source('math_bootstrap','Statistics · Bootstrapping','Math & Statistics','Mine Çetinkaya-Rundel, Johanna Hardin and OpenIntro contributors','CC BY-SA 3.0',OPENINTRO_LICENSE,'https://openintrostat.github.io/ims/foundations-bootstrapping.html',_github('OpenIntroStat','ims','main','foundations-bootstrapping.qmd'),'qmd'),
    Source('math_regression','Statistics · Simple Linear Regression','Math & Statistics','Mine Çetinkaya-Rundel, Johanna Hardin and OpenIntro contributors','CC BY-SA 3.0',OPENINTRO_LICENSE,'https://openintrostat.github.io/ims/model-slr.html',_github('OpenIntroStat','ims','main','model-slr.qmd'),'qmd'),
    # Java is imported from a CC BY textbook. PDF parsing needs pypdf;
    # without it, sync records a precise per-source error instead of pretending.
    Source('java_text','Java, Java, Java · Object-Oriented Problem Solving','Java','Ralph Morelli and Ralph Walde','CC BY 4.0',JAVA_LICENSE,'https://www.cs.trincoll.edu/~ram/jjj/',_github('ram8647','javajavajava','master','JavaJavaJavaPDF2017edition.pdf'),'pdf'),
]

class _VisibleHTML(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts=[];self.skip=0;self.article_only=False;self.article_level=0
    def handle_starttag(self,tag,attrs):
        if tag in ('script','style','noscript','svg','nav','footer','header'):
            self.skip+=1
        if tag in ('p','li','h1','h2','h3','h4','pre','dt','dd','tr') and self.skip==0:
            self.parts.append('\n')
    def handle_endtag(self,tag):
        if tag in ('script','style','noscript','svg','nav','footer','header') and self.skip:
            self.skip-=1
        if tag in ('p','li','h1','h2','h3','h4','pre'):
            self.parts.append('\n')
    def handle_data(self,data):
        if not self.skip and data.strip():self.parts.append(data+' ')
    def text(self):return ''.join(self.parts)


def _clean(text,format):
    if format=='html':
        parser=_VisibleHTML();parser.feed(text);text=parser.text()
    if format in ('markdown','qmd'):
        text=re.sub(r'\A---\n.*?\n---\n','',text,flags=re.S)
        text=re.sub(r'\{\{[^\n]*?\}\}','',text)
        text=re.sub(r'(?m)^\s*:::\s*\{[^\n]*\}.*$','',text)
        text=re.sub(r'\]\((?:https?://|/)[^)]+\)',']',text)
        text=re.sub(r'!\[[^\]]*\]\([^)]+\)','',text)
        text=re.sub(r'(?m)^\s*```\{r[^\n]*\}[\s\S]*?^```\s*$','',text)
        text=re.sub(r'(?m)^(?:#+\s*)','',text)
    if format=='rst':
        text=re.sub(r'(?m)^\s*\.\. (?:note|tip|warning|versionadded|versionchanged|seealso|code-block|image|literalinclude|only|toctree)::[^\n]*','',text)
        text=re.sub(r':\w+:`([^`]+)`',r'\1',text)
        text=re.sub(r'\.{2} _[^\n]+','',text)
    text=unescape(text)
    text=text.replace('\u00a0',' ')
    text=re.sub(r'(?m)^[-=~^]{3,}\s*$','',text)
    text=re.sub(r'[ \t]+',' ',text)
    text=re.sub(r'\n{3,}','\n\n',text)
    return text.strip()


def _paragraph_chunks(text, max_size=MAX_CHUNK):
    groups=re.split(r'\n\s*\n',text)
    chunks=[];current=''
    for group in groups:
        group=group.strip()
        if not group:continue
        if len(group)>max_size:
            # Split oversize paragraphs at sentence/line boundaries where possible.
            atoms=re.split(r'(?<=[.!?])\s+(?=[A-Z0-9])|\n+',group)
        else:atoms=[group]
        for atom in atoms:
            if len(atom)>max_size:
                if current.strip():chunks.append(current.strip());current=''
                chunks.extend(atom[j:j+max_size].strip() for j in range(0,len(atom),max_size))
                continue
            if len(current)+len(atom)+2>max_size:
                if current.strip():chunks.append(current.strip())
                current=atom
            else:current+=(('\n\n' if current else '')+atom)
    if current.strip():chunks.append(current.strip())
    return [x for x in chunks if len(x)>=MIN_CHUNK]


def _download(src:Source,transport=None):
    url=src.download_url
    parsed=urlparse(url)
    if parsed.scheme!='https' or parsed.hostname not in {'raw.githubusercontent.com','en.cppreference.com'}:
        raise ValueError('Source is not from an approved HTTPS host.')
    cap=MAX_PDF_BYTES if src.format=='pdf' else MAX_TEXT_BYTES
    if transport:
        raw=transport(url,cap)
    else:
        req=Request(url,headers={'User-Agent':USER_AGENT,'Accept':'text/plain, text/html, application/pdf'})
        with urlopen(req,timeout=20) as response:
            raw=response.read(cap+1)
    if len(raw)>cap:raise ValueError('Source exceeded the configured download size limit.')
    if src.format=='pdf':
        try:
            from pypdf import PdfReader
        except ImportError as e:raise RuntimeError('Java PDF requires the optional pypdf package. Run: python -m pip install pypdf') from e
        from io import BytesIO
        reader=PdfReader(BytesIO(raw))
        parts=[];length=0
        for page in reader.pages[:MAX_PDF_PAGES]:
            piece=page.extract_text() or ''
            parts.append(piece)
            length+=len(piece)
            if length>240000:break
        return _clean('\n\n'.join(parts),'text')
    content=raw.decode('utf-8-sig','replace')
    return _clean(content,src.format)


class OpenLibrary:
    def __init__(self,db_path):
        self.path=Path(db_path)
        self.path.parent.mkdir(parents=True,exist_ok=True)
        with connect(self.path) as con:
            con.execute('PRAGMA busy_timeout=5000')
            con.execute('CREATE TABLE IF NOT EXISTS sources (id TEXT PRIMARY KEY, title TEXT NOT NULL, subject TEXT NOT NULL, author TEXT NOT NULL, license TEXT NOT NULL, license_url TEXT NOT NULL, public_url TEXT NOT NULL, fetched_at TEXT NOT NULL)')
            con.execute('CREATE TABLE IF NOT EXISTS passages (id INTEGER PRIMARY KEY, source_id TEXT NOT NULL, content TEXT NOT NULL, FOREIGN KEY(source_id) REFERENCES sources(id))')
            try:
                con.execute('CREATE VIRTUAL TABLE IF NOT EXISTS passage_fts USING fts5(content, tokenize=\'unicode61\')')
                self.fts_enabled=True
            except OperationalError:
                self.fts_enabled=False

    def put(self,src:Source,text:str):
        chunks=_paragraph_chunks(text)
        if not chunks:raise ValueError('Retrieved source contained no usable text passages.')
        with connect(self.path,timeout=15) as con:
            con.execute('PRAGMA busy_timeout=5000')
            con.execute('DELETE FROM passage_fts WHERE rowid IN (SELECT id FROM passages WHERE source_id=?)',(src.id,)) if self.fts_enabled else None
            con.execute('DELETE FROM passages WHERE source_id=?',(src.id,))
            con.execute('INSERT INTO sources (id,title,subject,author,license,license_url,public_url,fetched_at) VALUES (?,?,?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET title=excluded.title,subject=excluded.subject,author=excluded.author,license=excluded.license,license_url=excluded.license_url,public_url=excluded.public_url,fetched_at=excluded.fetched_at',
                        (src.id,src.title,src.subject,src.author,src.license,src.license_url,src.public_url,datetime.now(timezone.utc).isoformat()))
            for chunk in chunks:
                cur=con.execute('INSERT INTO passages (source_id,content) VALUES (?,?)',(src.id,chunk))
                if self.fts_enabled:con.execute('INSERT INTO passage_fts (rowid,content) VALUES (?,?)',(cur.lastrowid,chunk))
        return len(chunks)

    def stats(self):
        with connect(self.path) as con:
            source_count=con.execute('SELECT COUNT(*) FROM sources').fetchone()[0]
            passage_count=con.execute('SELECT COUNT(*) FROM passages').fetchone()[0]
            newest=con.execute('SELECT MAX(fetched_at) FROM sources').fetchone()[0] or ''
        return {'sources':source_count,'passages':passage_count,'last_synced':newest,'fts':self.fts_enabled}

    def search(self,query:str,course:str='',limit:int=4):
        # No arbitrary SQL or FTS syntax from students.
        terms=re.findall(r'[A-Za-z][A-Za-z0-9_+#.-]{1,}',query.lower())
        stops={'tell','please','what','are','how','why','does','this','that','give','explain','show','about','from','using','with','could','would','should','the','and','its','can','you','does','when','where','have','some','examples','let','lets','learn','learning','want','need','about','please'}
        terms=[x for x in terms if x not in stops][:10]
        if not terms:return []
        mapped=subject_of(query) or subject_of(course)
        explicit_subject=subject_of(query)  # CAMPUS_POP_SUBJECT_FILTER_V27
        with connect(self.path,timeout=10) as con:
            con.row_factory=__import__('sqlite3').Row
            con.execute('PRAGMA busy_timeout=5000')
            if self.fts_enabled:
                # OR tolerates natural-language questions that include extra terms.
                safe=[re.sub(r'[^a-zA-Z0-9]','',t) for t in terms]
                safe=[t for t in safe if t]
                if not safe:return []
                fts_query=' OR '.join('"'+t+'"' for t in safe)
                sql='SELECT p.id,p.content,s.title,s.subject,s.author,s.license,s.license_url,s.public_url,bm25(passage_fts) AS score FROM passage_fts JOIN passages p ON p.id=passage_fts.rowid JOIN sources s ON s.id=p.source_id WHERE passage_fts MATCH ?'
                params=[fts_query]
                if explicit_subject:
                    sql+=' AND s.subject=?'
                    params.append(explicit_subject)
                sql+=' ORDER BY score ASC LIMIT 120'
                rows=con.execute(sql,params).fetchall()
            else:
                sql='SELECT p.id,p.content,s.title,s.subject,s.author,s.license,s.license_url,s.public_url,0.0 AS score FROM passages p JOIN sources s ON s.id=p.source_id'
                params=[]
                if explicit_subject:
                    sql+=' WHERE s.subject=?'
                    params.append(explicit_subject)
                sql+=' ORDER BY p.id LIMIT 2500'
                rows=con.execute(sql,params).fetchall()
        scored=[]
        query_terms=set(t.lower() for t in terms)
        for row in rows:
            # Never answer a Python question using unrelated JavaScript or math excerpts.
            if explicit_subject and row['subject'] != explicit_subject:
                continue
            body=row['content'].lower();title=row['title'].lower()
            matched=sum(1 for term in query_terms if term in body or term in title)
            if matched==0:continue
            subject_match=bool(mapped and row['subject']==mapped)
            exact_title_hits=sum(1 for term in query_terms if term in title)
            score=matched*2+exact_title_hits*2.4+(5 if subject_match else 0)
            if mapped and not subject_match:score-=2
            score+=min(1.0, len(query_terms.intersection(set(re.findall(r'[a-zA-Z0-9_+#.-]+',body))))*0.05)
            scored.append((score,row))
        scored.sort(key=lambda t:(-t[0],t[1]['id']))
        result=[]
        for score,row in scored[:max(1,min(int(limit),10))]:
            result.append({**dict(row),'relevance':round(score,2)})
        return result


SUBJECT_PATTERNS=(
 ('JavaScript',r'\b(?:javascript|ecmascript|js)\b'),
 ('Visual Basic',r'\b(?:visual basic|vb\.?net|vba|vb)\b'),
 ('C++',r'(?<!\w)c\+\+(?!\w)|\bcpp\b'),
 ('Python',r'\bpython\b'),
 ('Java',r'\bjava\b'),
 ('Math & Statistics',r'\b(?:statistics|statistical|probability|algebra|calculus|regression|hypothesis|normal distribution|confidence interval|mathematics|bayes)\b'),
)

def subject_of(text):
    text=str(text or '').lower()
    if text=='python programming':return 'Python'
    if text=='applied statistics' or text=='discrete mathematics':return 'Math & Statistics'
    for subject,pattern in SUBJECT_PATTERNS:
        if re.search(pattern,text,re.I):return subject
    return ''


def sync_library(db_path, sources=CATALOGUE, transport=None, pause=0.75, progress=None):
    """Fetch only listed licensed resources; report failures instead of hiding them.

    transport(url, cap)->bytes is injectable to test offline without network.
    """
    lib=OpenLibrary(db_path)
    errors=[];ok=[];new_count=0
    chosen=[s for s in sources if s.enabled]
    for i,src in enumerate(chosen,1):
        if progress:progress(f'Importing {i}/{len(chosen)} · {src.title}')
        try:
            txt=_download(src,transport=transport)
            count=lib.put(src,txt)
            new_count+=count
            ok.append(src.id)
        except Exception as exc:
            errors.append({'source':src.id,'title':src.title,'error':str(exc)[:350]})
        if pause and not transport and i<len(chosen):time.sleep(pause)
    report={'ok':ok,'errors':errors,'new_passages':new_count,'stats':lib.stats()}
    report_path=Path(db_path).with_name('open_library_last_sync.json')
    report_path.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    return report
