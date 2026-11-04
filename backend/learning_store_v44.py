"""Persistent local lesson position and verified exercise outcomes.

No network calls. Tracks no private note text, only the active lesson/source and
student performance on exercises with explicitly defined checkers.
"""
from __future__ import annotations
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
import json
import sqlite3


def _now():
    return datetime.now(timezone.utc).isoformat(timespec='seconds')


class LearningStore:
    def __init__(self, path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with self.connect() as db:
            db.executescript('''
                PRAGMA journal_mode=WAL;
                CREATE TABLE IF NOT EXISTS active_lessons (
                    conversation_id TEXT PRIMARY KEY,
                    course TEXT NOT NULL, title TEXT NOT NULL, source TEXT NOT NULL,
                    question TEXT NOT NULL, answer TEXT NOT NULL,
                    tries INTEGER NOT NULL DEFAULT 0,
                    awaiting INTEGER NOT NULL DEFAULT 0,
                    sequence INTEGER NOT NULL DEFAULT 0,
                    updated_at TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS checked_answers (
                    course TEXT NOT NULL, title TEXT NOT NULL,
                    attempts INTEGER NOT NULL DEFAULT 0,
                    correct INTEGER NOT NULL DEFAULT 0,
                    updated_at TEXT NOT NULL,
                    PRIMARY KEY (course, title)
                );
            ''')

    @contextmanager
    def connect(self):
        db = sqlite3.connect(str(self.path), timeout=10)
        db.row_factory = sqlite3.Row
        try:
            yield db
            db.commit()
        finally:
            db.close()

    def get(self, conversation_id):
        if not conversation_id:
            return None
        with self.connect() as db:
            row = db.execute('SELECT * FROM active_lessons WHERE conversation_id=?',
                             (conversation_id,)).fetchone()
            return dict(row) if row else None

    def put(self, conversation_id, course, title, source, question='', answer='',
            tries=0, awaiting=False, sequence=0):
        if not conversation_id:
            return
        with self.connect() as db:
            db.execute('''INSERT INTO active_lessons
              (conversation_id,course,title,source,question,answer,tries,awaiting,sequence,updated_at)
              VALUES(?,?,?,?,?,?,?,?,?,?)
              ON CONFLICT(conversation_id) DO UPDATE SET
                course=excluded.course,title=excluded.title,source=excluded.source,
                question=excluded.question,answer=excluded.answer,tries=excluded.tries,
                awaiting=excluded.awaiting,sequence=excluded.sequence,
                updated_at=excluded.updated_at''',
                (conversation_id, str(course)[:130],str(title)[:180],str(source)[:250],
                 str(question)[:1200],str(answer)[:1200],int(tries),int(bool(awaiting)),
                 int(sequence),_now()))

    def record_checked(self, course, title, correct):
        with self.connect() as db:
            db.execute('''INSERT INTO checked_answers(course,title,attempts,correct,updated_at)
              VALUES(?,?,1,?,?) ON CONFLICT(course,title) DO UPDATE SET
              attempts=attempts+1,correct=checked_answers.correct+excluded.correct,
              updated_at=excluded.updated_at''',(course,title,int(bool(correct)),_now()))

    def progress(self, course=None):
        with self.connect() as db:
            if course:
                rows=db.execute('SELECT * FROM checked_answers WHERE course=? ORDER BY title',
                                (course,)).fetchall()
            else:
                rows=db.execute('SELECT * FROM checked_answers ORDER BY course,title').fetchall()
            return [dict(row) for row in rows]
