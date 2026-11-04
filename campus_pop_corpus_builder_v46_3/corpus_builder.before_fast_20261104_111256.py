"""Campus Pop corpus acquisition. Downloads openly licensed source materials on demand.

Not a neural model trainer. Each record retains attribution and license metadata.
Output budget measures UTF-8 text bytes, NOT download size or JSONL size.
"""
from __future__ import annotations
import argparse
import bz2
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
import sys
import time
from urllib.request import Request, urlopen

MIB = 1024 * 1024

COURSES = {
    "Applied Statistics": ["statistics", "statistical", "probability", "regression", "sampling", "hypothesis testing", "confidence interval", "bayesian", "variance", "distribution"],
    "Python Programming": ["python (programming language)", "python programming", "python language", "python syntax", "python library", "python function", "python module", "python interpreter", "python package"],
    "Computer Systems": ["computer architecture", "operating system", "microprocessor", "computer hardware", "computer memory", "cpu", "instruction set", "computer networking", "embedded system", "computer storage"],
    "Software Engineering": ["software engineering", "software testing", "software development", "software design", "software architecture", "software requirements", "version control", "agile software", "software maintenance", "unit testing"],
    "Discrete Mathematics": ["discrete mathematics", "graph theory", "combinatorics", "set theory", "propositional logic", "mathematical logic", "recurrence relation", "discrete probability", "boolean algebra", "number theory"],
    "Database Systems": ["database", "relational model", "sql", "database management", "database normalization", "transaction processing", "query optimization", "data modeling", "nosql", "relational algebra"],
}
LICENSES = {
    "wikipedia": "CC BY-SA 4.0 (verify individual article notices)",
    "wikitext": "CC BY-SA 3.0 / GFDL (per WikiText dataset card)",
    "tatoeba": "CC BY 2.0 FR (sentence-level exceptions may apply)",
    "openstax": "CC BY 4.0 (as stated in the specified book PDF; check edition)",
}
OPENSTAX = [
    ("Python Programming", "Introduction to Python Programming (2024)", "https://assets.openstax.org/oscms-prodcms/media/documents/Introduction_to_Python_Programming_-_WEB.pdf", "https://openstax.org/details/books/introduction-python-programming"),
    ("Applied Statistics", "Introductory Statistics 2e (2023)", "https://assets.openstax.org/oscms-prodcms/media/documents/Introductory_Statistics_2e_-_WEB.pdf", "https://openstax.org/details/books/introductory-statistics-2e"),
]


def normalized(text):
    text = re.sub(r"\x00|\u200b|\ufeff", "", str(text))
    text = re.sub(r"[ \t]{2,}", " ", text)
    text = re.sub(r"\n{4,}", "\n\n\n", text)
    return text.strip()


def classify(title, text):
    """Require topical title match or two distinct keyword matches in introduction."""
    name = title.lower().strip()
    intro = text[:3500].lower()
    scores = {}
    for course, phrases in COURSES.items():
        hits_title = sum(bool(re.search(r"(?<!\w)"+re.escape(term)+r"(?!\w)", name)) for term in phrases)
        hits_intro = sum(bool(re.search(r"(?<!\w)"+re.escape(term)+r"(?!\w)", intro)) for term in phrases)
        if hits_title or hits_intro >= 2:
            scores[course] = hits_title * 5 + min(hits_intro, 5)
    return max(scores, key=scores.get) if scores else "English Linguistics"


def split_for(stable_id):
    r = int(hashlib.sha256(stable_id.encode("utf-8")).hexdigest()[:8], 16) % 100
    return "train" if r < 90 else "validation" if r < 95 else "test"


class Corpus:
    def __init__(self, root: Path, target_mib: int, course_mib: int):
        self.root = root
        self.root.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(str(root / "manifest.sqlite"))
        self.db.execute("CREATE TABLE IF NOT EXISTS records (hash TEXT PRIMARY KEY, category TEXT, source TEXT, text_bytes INTEGER)")
        self.db.commit()
        self.quotas = {name: course_mib * MIB for name in COURSES}
        # The remainder is English. We never pad, truncate articles solely to fill, or duplicate data.
        self.quotas["English Linguistics"] = max(0, target_mib - course_mib * len(COURSES)) * MIB
        self.counts = {name: 0 for name in self.quotas}
        for category, count in self.db.execute("SELECT category, SUM(text_bytes) FROM records GROUP BY category"):
            if category in self.counts: self.counts[category] = count
        self.handles = {}
        self.pending = 0
        self.accepted = 0

    def add(self, title, body, category, source, url, license_code, source_id=None, extra=None):
        if category not in self.quotas or self.counts[category] >= self.quotas[category]:
            return False
        text = normalized(body)
        if len(text) < 60:
            return False
        if len(text) > 40000:
            text = text[:40000].rsplit(" ", 1)[0]
        text_bytes = len(text.encode("utf-8"))
        if self.counts[category] + text_bytes > self.quotas[category]:
            return False
        digest = hashlib.sha256((source+":"+str(source_id or url)+":"+text).encode("utf-8")).hexdigest()
        if self.db.execute("SELECT 1 FROM records WHERE hash=?", (digest,)).fetchone():
            return False
        record = {"id": digest, "course": category, "title": title, "text": text,
                  "source": source, "url": url, "license": license_code,
                  "split": split_for(digest)}
        if extra: record.update(extra)
        folder = self.root / "data" / category.replace(" ", "_").lower()
        folder.mkdir(parents=True, exist_ok=True)
        path = folder / (record["split"]+".jsonl")
        if path not in self.handles:
            self.handles[path] = path.open("a", encoding="utf-8", newline="\n")
        self.handles[path].write(json.dumps(record, ensure_ascii=False) + "\n")
        self.handles[path].flush()
        self.db.execute("INSERT INTO records VALUES (?,?,?,?)", (digest, category, source, text_bytes))
        self.pending += 1
        if self.pending >= 100:
            self.db.commit(); self.pending = 0
        self.counts[category] += text_bytes
        self.accepted += 1
        return True

    def full(self):
        return all(self.counts[k] >= self.quotas[k] - 40000 for k in self.quotas)

    def close(self):
        self.db.commit()
        for h in self.handles.values(): h.close()
        self.db.close()

    def report(self):
        result = {
            "target_text_MiB": round(sum(self.quotas.values()) / MIB, 1),
            "actual_text_MiB": round(sum(self.counts.values()) / MIB, 2),
            "notes": "Counts measure stored UTF-8 document text, not JSONL size or downloaded bytes; unfilled quotas stay unfilled.",
            "courses": {k:{"actual_MiB":round(v/MIB,2),"target_MiB":round(self.quotas[k]/MIB,1)} for k,v in self.counts.items()},
        }
        (self.root / "report.json").write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding="utf-8")
        print("\n--- CORPUS STATUS ---")
        for k,v in self.counts.items():
            print(f"{k:23} {v/MIB:8.1f} / {self.quotas[k]/MIB:8.1f} MiB")
        print(f"TOTAL: {sum(self.counts.values())/MIB:.1f} / {sum(self.quotas.values())/MIB:.1f} MiB text")
        return result


def http_download(url, destination):
    if destination.exists() and destination.stat().st_size > 1024:
        return destination
    destination.parent.mkdir(parents=True, exist_ok=True)
    req = Request(url, headers={"User-Agent":"CampusPopEducationalResearchCorpus/0.1 (local user download)"})
    temp = destination.with_suffix(destination.suffix + ".part")
    with urlopen(req, timeout=120) as r, temp.open("wb") as f:
        while True:
            data = r.read(1024*1024)
            if not data: break
            f.write(data)
    os.replace(temp, destination)
    return destination


def import_tatoeba(corpus, cache):
    print("\n[1/4] Tatoeba English sentences")
    url = "https://downloads.tatoeba.org/exports/per_language/eng/eng_sentences.tsv.bz2"
    file = http_download(url, cache / "eng_sentences.tsv.bz2")
    count = 0
    with bz2.open(file, "rt", encoding="utf-8", errors="replace") as f:
        for line in f:
            parts = line.strip().split("\t")
            if len(parts) < 2: continue
            id_, sentence = parts[0], parts[1]
            # Batch short lines for efficient language-model training and preserve each sentence ID in metadata.
            # Each record contains one sentence with source id, and the normal minimum length does not apply,
            # so we collect paragraphs of sentences instead.
            if not hasattr(import_tatoeba, "_batch"):
                import_tatoeba._batch = []
            import_tatoeba._batch.append((id_, sentence))
            if len(import_tatoeba._batch) >= 45:
                batch = import_tatoeba._batch
                txt = "\n".join(x[1] for x in batch)
                added = corpus.add("English sentence examples", txt, "English Linguistics", "tatoeba",
                           "https://tatoeba.org/", LICENSES["tatoeba"],
                           source_id=batch[0][0], extra={"sentence_ids": [x[0] for x in batch]})
                import_tatoeba._batch = []
                count += int(added)
                if corpus.counts["English Linguistics"] >= corpus.quotas["English Linguistics"]: break
        if getattr(import_tatoeba, "_batch", []):
            batch = import_tatoeba._batch
            corpus.add("English sentence examples", "\n".join(x[1] for x in batch), "English Linguistics",
                       "tatoeba", "https://tatoeba.org/", LICENSES["tatoeba"], source_id=batch[0][0],
                       extra={"sentence_ids": [x[0] for x in batch]})
            import_tatoeba._batch=[]
    print(f"Accepted {count} sentence batches")


def import_openstax(corpus, cache):
    from pypdf import PdfReader
    print("\n[2/4] Two explicitly identified OpenStax book PDFs")
    for category, book, url, credit in OPENSTAX:
        print("  Download/parse", book)
        try:
            file = http_download(url, cache / ("openstax_"+category.replace(" ","_").lower()+".pdf"))
            reader = PdfReader(str(file))
            accepted = 0
            for i,page in enumerate(reader.pages):
                text = page.extract_text(extraction_mode="plain") or ""
                if corpus.add(book + f" — page {i+1}", text, category, "openstax", credit,
                              LICENSES["openstax"], source_id=f"{book}/{i+1}",
                              extra={"page":i+1,"book_pdf":url}):
                    accepted += 1
            print(f"  Accepted {accepted} pages")
        except Exception as e:
            print(f"  WARNING {book}: {e}; continuing")


def import_wikitext(corpus):
    print("\n[3/4] WikiText-103 English prose")
    from datasets import load_dataset
    ds = load_dataset("Salesforce/wikitext", "wikitext-103-raw-v1", split="train", streaming=True)
    added = 0
    lines = []
    for i,row in enumerate(ds):
        value = str(row.get("text") or "").strip()
        if not value: continue
        lines.append(value)
        if sum(map(len,lines)) < 4000: continue
        body = "\n".join(lines)
        lines=[]
        if corpus.add("WikiText-103 (Wikipedia featured articles)", body, "English Linguistics", "wikitext",
                      "https://huggingface.co/datasets/Salesforce/wikitext", LICENSES["wikitext"], source_id=f"block/{i}"):
            added += 1
        if i % 150000 == 0: print(f"  scanned {i:,} WikiText rows")
        if corpus.counts["English Linguistics"] >= corpus.quotas["English Linguistics"]: break
    if lines:
        corpus.add("WikiText-103 (Wikipedia featured articles)", "\n".join(lines), "English Linguistics", "wikitext",
                   "https://huggingface.co/datasets/Salesforce/wikitext", LICENSES["wikitext"], source_id="last")
    print("  Accepted", added, "WikiText chunks")


def import_wikipedia(corpus, max_articles):
    print("\n[4/4] Wikimedia Wikipedia (2023 English text snapshot)")
    from datasets import load_dataset
    ds = load_dataset("wikimedia/wikipedia", "20231101.en", split="train", streaming=True)
    accepted = 0
    scanned = 0
    for row in ds:
        scanned += 1
        if scanned > max_articles or corpus.full(): break
        title = str(row.get("title") or "")
        content = str(row.get("text") or "")
        if len(content) < 500: continue
        if re.match(r"^(list of|timeline of|category:|index of|bibliography)", title, re.I): continue
        category = classify(title, content)
        if corpus.counts[category] >= corpus.quotas[category]:
            # Do not relabel subject content as general English merely to hit a byte target.
            continue
        url = str(row.get("url") or "https://en.wikipedia.org/wiki/"+title.replace(" ", "_"))
        if corpus.add(title, content, category, "wikipedia", url, LICENSES["wikipedia"], source_id=str(row.get("id") or url)):
            accepted += 1
        if scanned % 25000 == 0:
            print(f"  scanned {scanned:,} articles; accepted {accepted:,}; corpus {sum(corpus.counts.values())/MIB:,.1f} MiB")
    print(f"  Scanned {scanned:,}; accepted {accepted:,} Wikipedia articles")



def import_lexicon(corpus, cache):
    """Dictionary meanings are reference data, not filler for the 2 GB prose budget."""
    print("\n[L] Simple English Wiktionary lexicon with parts of speech and definitions")
    url = "https://kaikki.org/simplewiktionary/raw-wiktextract-data.jsonl.gz"
    sourcefile = http_download(url, cache / "simplewiktionary.jsonl.gz")
    out = corpus.root / "linguistics" / "dictionary_english.jsonl"
    out.parent.mkdir(parents=True, exist_ok=True)
    count=0
    if out.exists() and out.stat().st_size > 100: 
        print("  Dictionary exists already; use it without redownloading")
        return
    with gzip.open(sourcefile, "rt", encoding="utf-8", errors="replace") as inp, out.open("w",encoding="utf-8") as dest:
        for line in inp:
            try: item=json.loads(line)
            except json.JSONDecodeError: continue
            if item.get("lang_code") not in ("en", "eng"): continue
            word = item.get("word", "")
            glosses=[]
            for sense in item.get("senses",[]):
                glosses.extend(sense.get("glosses",[]) or [])
            if not word or not glosses: continue
            dest.write(json.dumps({"word":word, "part_of_speech":item.get("pos"),
                 "definitions":glosses[:8], "source":"Simple English Wiktionary / Wiktextract",
                 "source_url":"https://simple.wiktionary.org/wiki/"+str(word).replace(" ","_"),
                 "license":"CC BY-SA 4.0 / GFDL; verify entries"},ensure_ascii=False)+"\n")
            count += 1
    print("  Saved",count,"English word entries to",out)


def parse_conllu_sentences(lines):
    block=[]
    for line in list(lines)+["\n"]:
        if line.strip(): block.append(line.rstrip("\n")); continue
        if not block: continue
        sentence = ""
        tokens=[]
        for row in block:
            if row.startswith("# text = "): sentence=row[len("# text = "):]
            if row.startswith("#"): continue
            cols=row.split("\t")
            if len(cols) < 8 or not cols[0].isdigit(): continue
            tokens.append({"token":cols[1], "lemma":cols[2], "pos":cols[3],
                           "features":cols[5],"head":cols[6],"dep":cols[7]})
        if sentence and tokens: yield sentence,tokens
        block=[]


def import_grammar(corpus, cache):
    print("\n[G] English grammar: Universal Dependencies English EWT")
    target = corpus.root / "linguistics" / "english_grammar_dependencies.jsonl"
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists() and target.stat().st_size > 100:
        print("  Grammar exists already")
        return
    base = "https://raw.githubusercontent.com/UniversalDependencies/UD_English-EWT/master/"
    count=0
    with target.open("w", encoding="utf-8") as output:
        for variant in ("train", "dev", "test"):
            file = "en_ewt-ud-"+variant+".conllu"
            source = http_download(base+file, cache/file)
            with source.open("r",encoding="utf-8") as f:
                for sentence,tokens in parse_conllu_sentences(f):
                    output.write(json.dumps({"sentence":sentence, "tokens":tokens, "split":variant,
                       "source_url":"https://github.com/UniversalDependencies/UD_English-EWT",
                       "license":"CC BY-SA 4.0 annotations; underlying text has separate rights notices"},ensure_ascii=False)+"\n")
                    count += 1
    print("  Saved",count,"annotated English sentences to",target)


def main():
    p = argparse.ArgumentParser(description="Build a provenance-preserving local text corpus (NO training executed).")
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--target-mib", type=int, default=2048, help="Target total of stored UTF-8 text in MiB")
    p.add_argument("--per-course-mib", type=int, default=80, help="Target per starter course")
    p.add_argument("--max-wikipedia-articles", type=int, default=800000)
    p.add_argument("--only", choices=["all", "sentences", "books", "wikitext", "wikipedia", "grammar", "lexicon", "report"], default="all")
    p.add_argument("--skip-books", action="store_true")
    p.add_argument("--courses-json", type=Path, help="JSON mapping of course names to relevant keywords; use for additional student courses")
    args = p.parse_args()
    if args.courses_json:
        global COURSES
        loaded = json.loads(args.courses_json.read_text(encoding="utf-8"))
        if not isinstance(loaded, dict) or not loaded or any(not isinstance(v, list) or not v or not all(isinstance(w,str) and w.strip() for w in v) for v in loaded.values()):
            p.error("--courses-json must be a JSON object mapping each course to a nonempty list of search keywords")
        COURSES = loaded
    if args.target_mib <= len(COURSES) * args.per_course_mib:
        p.error(f"target MiB must exceed per-course MiB x {len(COURSES)} courses")
    c = Corpus(args.out, args.target_mib, args.per_course_mib)
    print("Corpus stores source citations, split and licenses per record. No fabricated text.")
    print("NOTICE: CC BY-SA has redistribution requirements. Review the individual source terms.")
    cache = args.out / "downloads"
    operations = {
        "sentences": lambda: import_tatoeba(c, cache),
        "grammar": lambda: import_grammar(c, cache),
        "lexicon": lambda: import_lexicon(c, cache),
        "books": lambda: import_openstax(c, cache),
        "wikitext": lambda: import_wikitext(c),
        "wikipedia": lambda: import_wikipedia(c, args.max_wikipedia_articles),
    }
    try:
        if args.only != "report":
            modes = [args.only] if args.only != "all" else list(operations)
            for mode in modes:
                if mode == "books" and args.skip_books: continue
                try: operations[mode]()
                except KeyboardInterrupt: raise
                except Exception as e:
                    print(f"ERROR in {mode}: {e}")
                    print("Completed sources remain saved. Run again to retry.")
        c.report()
    except KeyboardInterrupt:
        print("\nInterrupted; completed records remain in the corpus.")
        c.report()
    finally:
        c.close()

if __name__ == "__main__": main()
