"""Campus Pop V46.2 — local course catalog and imported-material retrieval.

This module uses NumPy for retrieval; it is not a pretrained LLM.
Student material remains on the user's device. Retrieved text is untrusted data,
not instructions to the application. No mastery is awarded.
"""
from __future__ import annotations

import hashlib
import json
import re
import shutil
from dataclasses import dataclass
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
STORE = ROOT / 'course_data'
STARTERS = ROOT / 'starter_lessons.json'
SEED_COURSES = (
    ('applied-statistics', 'Applied Statistics'),
    ('python-programming', 'Python Programming'),
    ('computer-systems', 'Computer Systems'),
    ('software-engineering', 'Software Engineering'),
    ('discrete-mathematics', 'Discrete Mathematics'),
    ('database-systems', 'Database Systems'),
)
SUPPORTED_EXT = {'.txt', '.md', '.csv', '.py', '.pdf', '.docx'}
SKIP_WORDS = set('a an the is are was were it of for to in on at and or that this these those with by from when how what why which who do does can could would should you your i my me explain tell about give show please very like not'.split())


def tokens(s: str) -> list[str]:
    return [t for t in re.findall(r"[a-z][a-z0-9_]*", s.casefold()) if t not in SKIP_WORDS and len(t)>1]


def keyify(s: str) -> str:
    result = re.sub(r'[^a-z0-9]+', '-', s.casefold()).strip('-')
    if not result:
        raise ValueError('A course needs a readable name.')
    return result[:80]


@dataclass
class Passage:
    course_id: str
    title: str
    text: str
    source: str
    location: str = ''
    kind: str = 'uploaded'
    lesson: dict | None = None


class CourseLibrary:
    def __init__(self, store: Path | str = STORE, starters: Path | str = STARTERS):
        self.store = Path(store)
        self.store.mkdir(parents=True, exist_ok=True)
        self.media = self.store / 'materials'
        self.media.mkdir(parents=True, exist_ok=True)
        self.catalog = self.store / 'courses.json'
        self.starters_path = Path(starters)
        if self.catalog.exists():
            self.courses = json.loads(self.catalog.read_text(encoding='utf-8'))
            if not isinstance(self.courses, list):
                raise ValueError('courses.json must contain a list')
        else:
            self.courses = [{'id': cid, 'name': name} for cid,name in SEED_COURSES]
            self.save()
        for course in self.courses:
            if not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', str(course.get('id', ''))):
                raise ValueError('Unsafe or invalid course ID in courses.json')
        self.passages: list[Passage] = []
        self.by_course: dict[str, list[Passage]] = {}
        self.index: dict[str, tuple[np.ndarray, dict[str,int], np.ndarray]] = {}
        self.reindex()

    def save(self):
        tmp = self.catalog.with_suffix('.json.tmp')
        tmp.write_text(json.dumps(self.courses, indent=2, ensure_ascii=False), encoding='utf-8')
        tmp.replace(self.catalog)

    def all_courses(self) -> list[dict]:
        return list(self.courses)

    def find_course(self, name_or_id: str):
        query = name_or_id.casefold().strip()
        exact = next((c for c in self.courses if c['id'] == query or c['name'].casefold() == query), None)
        if exact:
            return exact
        matches = [c for c in self.courses if c['name'].casefold().startswith(query)]
        return matches[0] if len(matches) == 1 else None

    def add_course(self, name: str):
        name = name.strip()
        if len(name) < 2 or len(name) > 120:
            raise ValueError('Course name must contain 2–120 characters.')
        existing = self.find_course(name)
        if existing:
            return existing, False
        ident = keyify(name)
        if any(c['id'] == ident for c in self.courses):
            raise ValueError('A course with this identifier already exists.')
        entry = {'id': ident, 'name': name}
        self.courses.append(entry)
        self.save()
        self.reindex()
        return entry, True

    def sync_course_names(self, names) -> list[str]:
        """Register user courses from the host application's current course catalog."""
        added = []
        for item in names:
            name = item.get('name') if isinstance(item, dict) else item
            if not isinstance(name, str) or not name.strip():
                continue
            course, created = self.add_course(name)
            if created: added.append(course['name'])
        return added

    def import_path(self, course_id: str, input_path: str) -> tuple[list[str], list[str]]:
        if not self.find_course(course_id):
            raise ValueError('Unknown course')
        incoming = Path(input_path).expanduser()
        if not incoming.exists():
            raise FileNotFoundError(f'No such path: {incoming}')
        files = [incoming] if incoming.is_file() else sorted(p for p in incoming.rglob('*') if p.is_file())
        added, skipped = [], []
        dest_dir = self.media / course_id
        dest_dir.mkdir(exist_ok=True, parents=True)
        for f in files:
            if f.suffix.casefold() not in SUPPORTED_EXT:
                skipped.append(f'{f.name}: unsupported type')
                continue
            if f.stat().st_size > 12_000_000:
                skipped.append(f'{f.name}: larger than 12 MB')
                continue
            raw = f.read_bytes()
            checksum = hashlib.sha256(raw).hexdigest()[:12]
            safe_stem = re.sub(r'[^\w. -]+', '_', f.stem)[:90] or 'notes'
            target = dest_dir / f'{safe_stem}-{checksum}{f.suffix.lower()}'
            if target.exists():
                skipped.append(f'{f.name}: already imported')
                continue
            try:
                # Verify the file is readable before storing it.
                parts = extract_text(f)
            except Exception as ex:
                skipped.append(f'{f.name}: {str(ex)[:150]}')
                continue
            if not any(text.strip() for _,text in parts):
                skipped.append(f'{f.name}: no selectable text (scanned PDFs need OCR)')
                continue
            shutil.copy2(f, target)
            added.append(f.name)
        if added:
            self.reindex()
        return added, skipped

    def reindex(self):
        self.passages = []
        known = {c['id'] for c in self.courses}
        if self.starters_path.exists():
            for lesson in json.loads(self.starters_path.read_text(encoding='utf-8')):
                cid = lesson['course_id']
                if cid not in known: continue
                body = '\n'.join(str(lesson.get(k,'')) for k in ('title','summary','explanation','example','keywords','simple'))
                self.passages.append(Passage(cid, lesson['title'], body,
                                             'Campus Pop introductory reference (built-in)', kind='starter', lesson=lesson))
        for course in self.courses:
            folder = self.media / course['id']
            if not folder.exists(): continue
            for p in sorted(folder.iterdir()):
                if not p.is_file() or p.suffix.lower() not in SUPPORTED_EXT: continue
                try:
                    pages = extract_text(p)
                except Exception:
                    continue
                for location, page in pages:
                    for piece in chunks(page):
                        self.passages.append(Passage(course['id'], p.stem.rsplit('-',1)[0], piece, p.stem.rsplit('-',1)[0] + p.suffix, location))
        self.by_course = {c['id']: [x for x in self.passages if x.course_id == c['id']] for c in self.courses}
        self.index = {}
        for cid, docs in self.by_course.items():
            if not docs: continue
            termlists = [tokens(d.title + ' ' + d.title + ' ' + d.text) for d in docs]
            vocab = sorted(set(t for ls in termlists for t in ls))
            if not vocab: continue
            positions = {v:i for i,v in enumerate(vocab)}
            counts = np.zeros((len(docs), len(vocab)), dtype=np.float32)
            for i, ls in enumerate(termlists):
                for term in ls:
                    counts[i,positions[term]] += 1
            df = (counts > 0).sum(axis=0)
            idf = np.log((1+len(docs))/(1+df))+1
            matrix = counts * idf
            matrix /= np.maximum(np.linalg.norm(matrix,axis=1,keepdims=True),1e-10)
            self.index[cid] = (matrix, positions, idf)

    def search(self, question: str, course_id: str | None = None, n: int = 3) -> list[tuple[Passage,float]]:
        candidates = [course_id] if course_id else list(self.by_course)
        found = []
        query_tokens = tokens(question)
        if not query_tokens: return []
        for cid in candidates:
            if cid not in self.index: continue
            matrix, termidx, idf = self.index[cid]
            q = np.zeros(len(termidx),dtype=np.float32)
            for tok in query_tokens:
                if tok in termidx: q[termidx[tok]] += 1
            if not np.any(q): continue
            q *= idf
            q /= max(np.linalg.norm(q), 1e-10)
            scores = matrix @ q
            for i, score in enumerate(scores):
                if score >= 0.12:
                    found.append((self.by_course[cid][i],float(score)))
        found.sort(key=lambda pair: pair[1],reverse=True)
        return found[:n]


def extract_text(path: Path) -> list[tuple[str,str]]:
    ext=path.suffix.lower()
    if ext in ('.txt','.md','.csv','.py'):
        return [('',path.read_text(encoding='utf-8-sig',errors='replace')[:500_000])]
    if ext=='.pdf':
        try:
            from pypdf import PdfReader
        except ImportError as ex:
            raise ImportError('PDF support requires: pip install pypdf') from ex
        reader=PdfReader(str(path))
        return [(f'page {i+1}', page.extract_text() or '') for i,page in enumerate(reader.pages[:150])]
    if ext=='.docx':
        try:
            from docx import Document
        except ImportError as ex:
            raise ImportError('DOCX support requires: pip install python-docx') from ex
        doc=Document(str(path))
        return [('', '\n'.join(p.text for p in doc.paragraphs)[:500_000])]
    raise ValueError('Unsupported file type')


def chunks(text: str, max_len=950) -> list[str]:
    # Prefer paragraph boundaries and overlap is deliberately small.
    paragraphs = [x.strip() for x in re.split(r'\n\s*\n',text) if x.strip()]
    pieces=[]
    for p in paragraphs:
        while len(p)>max_len:
            boundary=p.rfind(' ',0,max_len)
            cut=boundary if boundary>max_len//2 else max_len
            pieces.append(p[:cut]); p=p[cut:].strip()
        if p: pieces.append(p)
    result=[]; buf=''
    for p in pieces:
        if len(buf)+len(p)+2>max_len and buf:
            result.append(buf);buf=''
        buf=(buf+'\n\n'+p).strip()
    if buf:result.append(buf)
    return result[:1000]
