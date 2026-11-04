"""StudySpace chat and tutoring-feedback storage. No network calls."""
from __future__ import annotations
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4


def utc_now():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


class ConversationStore:
    def __init__(self, db_path: str | Path):
        self.path = Path(db_path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with self._connect() as db:
            db.executescript('''
                PRAGMA foreign_keys=ON;
                CREATE TABLE IF NOT EXISTS conversations (
                    id TEXT PRIMARY KEY, title TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    conversation_id TEXT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
                    role TEXT NOT NULL CHECK(role IN ('user','assistant')),
                    content TEXT NOT NULL, attached_name TEXT NOT NULL DEFAULT '',
                    created_at TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS feedback (
                    message_id INTEGER PRIMARY KEY REFERENCES messages(id) ON DELETE CASCADE,
                    course TEXT NOT NULL, mode TEXT NOT NULL, strategy TEXT NOT NULL,
                    reward REAL NOT NULL CHECK(reward BETWEEN 0 AND 1), created_at TEXT NOT NULL
                );
            ''')

    def _connect(self):
        db = sqlite3.connect(str(self.path), timeout=15)
        db.execute('PRAGMA foreign_keys=ON')
        return db

    def new(self, title: str = "New conversation") -> str:
        ident = uuid4().hex
        stamp = utc_now()
        with self._connect() as db:
            db.execute('INSERT INTO conversations VALUES (?,?,?,?)', (ident, title[:80], stamp, stamp))
        return ident

    def rename(self, ident: str, title: str):
        with self._connect() as db:
            db.execute('UPDATE conversations SET title=?,updated_at=? WHERE id=?', (title.strip()[:80],utc_now(),ident))

    def append(self, ident: str, role: str, content: str, attached_name: str="") -> int:
        if role not in ('user','assistant'): raise ValueError('Invalid role')
        if len(content)>40000: content=content[:40000]
        with self._connect() as db:
            result=db.execute('INSERT INTO messages(conversation_id,role,content,attached_name,created_at) VALUES (?,?,?,?,?)',
                        (ident,role,content,attached_name[:160],utc_now()))
            db.execute('UPDATE conversations SET updated_at=? WHERE id=?',(utc_now(),ident))
            return int(result.lastrowid)

    def messages(self, ident: str, limit: int=150) -> list[dict]:
        with self._connect() as db:
            rows=db.execute('''SELECT role,content,attached_name,id FROM (
              SELECT role,content,attached_name,id FROM messages WHERE conversation_id=? ORDER BY id DESC LIMIT ?
            ) ORDER BY id ASC''',(ident,limit)).fetchall()
        return [dict(role=r[0], content=r[1], attachedName=r[2], id=r[3]) for r in rows]

    def history(self, ident: str, limit: int=12) -> list[dict]:
        return [dict(role=m['role'],content=m['content']) for m in self.messages(ident, limit)]

    def list_conversations(self, limit: int=100) -> list[dict]:
        with self._connect() as db:
            rows=db.execute('SELECT id,title FROM conversations ORDER BY updated_at DESC LIMIT ?', (limit,)).fetchall()
        return [{'id':i,'title':t} for i,t in rows]

    def contains(self, ident:str)->bool:
        with self._connect() as db:
            return db.execute('SELECT 1 FROM conversations WHERE id=?',(ident,)).fetchone() is not None

    def rate(self, message_id:int, course:str, mode:str, strategy:str, helpful:bool) -> None:
        reward=1.0 if helpful else 0.0
        with self._connect() as db:
            exists=db.execute("SELECT 1 FROM messages WHERE id=? AND role='assistant'",(message_id,)).fetchone()
            if not exists: raise ValueError('No assistant response available to rate')
            db.execute('''INSERT INTO feedback(message_id,course,mode,strategy,reward,created_at)
              VALUES(?,?,?,?,?,?) ON CONFLICT(message_id) DO UPDATE SET reward=excluded.reward,
              strategy=excluded.strategy,mode=excluded.mode,course=excluded.course,created_at=excluded.created_at''',
              (message_id,course[:90],mode[:30],strategy[:30],reward,utc_now()))

    def policy_stats(self, course:str,mode:str) -> dict[str,tuple[int,float]]:
        with self._connect() as db:
            rows=db.execute('''SELECT strategy,COUNT(*),AVG(reward) FROM feedback
              WHERE course=? AND mode=? GROUP BY strategy''',(course,mode)).fetchall()
        return {strategy:(n, avg) for strategy,n,avg in rows}

    def delete_conversation(self, ident:str):
        with self._connect() as db:
            db.execute('DELETE FROM conversations WHERE id=?',(ident,))
