"""Per-local-profile SQLite source of truth for Campus Pop user records.

The app does NOT currently implement account login/authentication. A stable local
profile ID scopes records in this database. A profile name change keeps the same ID.
"""
from __future__ import annotations

import json
from contextlib import contextmanager
import re
import shutil
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

from PySide6.QtCore import QSettings, QStandardPaths


def local_user_id() -> str:
    settings = QSettings("Storm", "StudySpace")
    key = "profile/localUserIdV47"
    saved = str(settings.value(key, "") or "")
    if re.fullmatch(r"[a-f0-9]{32}", saved):
        return saved
    generated = uuid4().hex
    settings.setValue(key, generated)
    settings.sync()
    status = settings.status()
    if getattr(status, "value", status) != 0:
        raise RuntimeError("Could not persist the local student profile identifier")
    return generated


class StudentDatabase:
    def __init__(self, root: Path | None = None, user_id: str | None = None):
        if root is None:
            value = QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
            root = Path(value) if value else Path.home() / ".studyspace"
        self.root = Path(root)
        self.root.mkdir(parents=True, exist_ok=True)
        self.user_id = user_id or local_user_id()
        if not re.fullmatch(r"[a-f0-9]{32}", self.user_id):
            raise ValueError("Local user ID must be a 32-character UUID hex value")
        self.path = self.root / "campus_pop_students.sqlite3"
        with self.connect() as db:
            db.executescript("""
                CREATE TABLE IF NOT EXISTS profiles (
                    user_id TEXT PRIMARY KEY, created_at TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS workspace_documents (
                    user_id TEXT PRIMARY KEY REFERENCES profiles(user_id),
                    payload TEXT NOT NULL, updated_at TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS courses (
                    user_id TEXT NOT NULL REFERENCES profiles(user_id),
                    code TEXT NOT NULL, payload TEXT NOT NULL,
                    is_default INTEGER NOT NULL DEFAULT 0,
                    created_at TEXT NOT NULL,
                    PRIMARY KEY(user_id, code)
                );
                CREATE TABLE IF NOT EXISTS profile_settings (
                    user_id TEXT NOT NULL REFERENCES profiles(user_id),
                    setting_key TEXT NOT NULL, setting_value TEXT NOT NULL,
                    PRIMARY KEY(user_id, setting_key)
                );
                CREATE TABLE IF NOT EXISTS topic_completions (
                    user_id TEXT NOT NULL, code TEXT NOT NULL,
                    topic_index INTEGER NOT NULL, completed_at TEXT NOT NULL,
                    PRIMARY KEY(user_id, code, topic_index),
                    FOREIGN KEY(user_id,code) REFERENCES courses(user_id,code) ON DELETE CASCADE
                );
            """)
            db.execute("INSERT OR IGNORE INTO profiles(user_id,created_at) VALUES(?,?)",
                       (self.user_id, self.now()))

    @staticmethod
    def now() -> str:
        return datetime.now(timezone.utc).isoformat()

    @contextmanager
    def connect(self):
        db = sqlite3.connect(str(self.path), timeout=10)
        try:
            db.execute("PRAGMA foreign_keys=ON")
            db.execute("PRAGMA busy_timeout=10000")
            yield db
            db.commit()
        except Exception:
            db.rollback()
            raise
        finally:
            db.close()

    def load_workspace(self, legacy_json: Path, default: dict) -> dict:
        """Import existing workspace ONCE, backing up source before commit.

        A subsequent load comes only from the user-scoped database. Corrupt JSON
        produces an explicit exception instead of replacing the user's data with [].
        """
        with self.connect() as db:
            row = db.execute("SELECT payload FROM workspace_documents WHERE user_id=?",
                             (self.user_id,)).fetchone()
        if row is not None:
            source = json.loads(row[0])
            if not isinstance(source, dict):
                raise ValueError("Stored workspace is not a JSON object")
            return {key: source.get(key, []) if isinstance(source.get(key, []), list) else []
                    for key in default}
        data = {key: [] for key in default}
        if legacy_json.is_file():
            source = json.loads(legacy_json.read_text(encoding="utf-8"))
            if not isinstance(source, dict):
                raise ValueError("Existing workspace.json must contain an object")
            for key in default:
                if not isinstance(source.get(key, []), list):
                    raise ValueError(f"Existing workspace.json has invalid {key} collection")
                data[key] = source.get(key, [])
            backup = legacy_json.with_name("workspace.pre_v47_" + datetime.now().strftime("%Y%m%d_%H%M%S") + ".json")
            if not backup.exists():
                shutil.copy2(legacy_json, backup)
        self.save_workspace(data)
        return data

    def save_workspace(self, data: dict) -> None:
        content = json.dumps(data, ensure_ascii=False, separators=(",", ":"), allow_nan=False)
        with self.connect() as db:
            db.execute("""INSERT INTO workspace_documents(user_id,payload,updated_at)
                       VALUES(?,?,?) ON CONFLICT(user_id) DO UPDATE SET
                       payload=excluded.payload, updated_at=excluded.updated_at""",
                       (self.user_id, content, self.now()))

    def list_courses(self):
        with self.connect() as db:
            return [(json.loads(payload), bool(default_flag)) for payload, default_flag in
                    db.execute("SELECT payload,is_default FROM courses WHERE user_id=? ORDER BY created_at, code",
                               (self.user_id,)).fetchall()]

    def upsert_course(self, course: dict, is_default: bool = False, overwrite: bool = False):
        content = json.dumps(course, ensure_ascii=False)
        with self.connect() as db:
            if overwrite:
                db.execute("UPDATE courses SET payload=? WHERE user_id=? AND code=?",
                           (content, self.user_id, course["code"]))
            else:
                db.execute("""INSERT OR IGNORE INTO courses(user_id,code,payload,is_default,created_at)
                           VALUES(?,?,?,?,?)""", (self.user_id, course["code"], content,
                                                    int(is_default), self.now()))

    def completion_indices(self, code: str) -> set[int]:
        with self.connect() as db:
            return {int(row[0]) for row in db.execute(
                "SELECT topic_index FROM topic_completions WHERE user_id=? AND code=?",
                (self.user_id, code)).fetchall()}

    def mark_topic(self, code: str, index: int, completed: bool):
        with self.connect() as db:
            if completed:
                db.execute("""INSERT OR IGNORE INTO topic_completions(user_id,code,topic_index,completed_at)
                           VALUES(?,?,?,?)""", (self.user_id, code, index, self.now()))
            else:
                db.execute("DELETE FROM topic_completions WHERE user_id=? AND code=? AND topic_index=?",
                           (self.user_id, code, index))

    def get_setting(self, key: str, default):
        with self.connect() as db:
            value = db.execute("SELECT setting_value FROM profile_settings WHERE user_id=? AND setting_key=?",
                               (self.user_id, key)).fetchone()
        return value[0] if value is not None else default

    def set_setting(self, key: str, value) -> None:
        with self.connect() as db:
            db.execute("""INSERT INTO profile_settings(user_id,setting_key,setting_value)
                       VALUES(?,?,?) ON CONFLICT(user_id,setting_key) DO UPDATE
                       SET setting_value=excluded.setting_value""",
                       (self.user_id, key, str(value)))

    def course_activity(self) -> dict:
        """Timestamp of actual focus, quiz or completed-unit activity for each course."""
        totals = {}
        def record(name, stamp):
            if not name or not stamp: return
            try:
                date = datetime.fromisoformat(stamp.replace("Z", "+00:00"))
                if date.tzinfo is None: return
                value = date.astimezone(timezone.utc).isoformat()
                if value > totals.get(name, ""): totals[name] = value
            except (TypeError, ValueError, AttributeError):
                return
        with self.connect() as db:
            workspace = db.execute("SELECT payload FROM workspace_documents WHERE user_id=?",(self.user_id,)).fetchone()
            if workspace:
                try:
                    data=json.loads(workspace[0])
                    for section in ("focus","quizzes"):
                        for row in data.get(section, []):
                            record(row.get("course"),row.get("when"))
                except (KeyError, TypeError, ValueError):
                    pass
            course_names = {code:json.loads(payload).get("title", "") for code,payload in db.execute(
                "SELECT code,payload FROM courses WHERE user_id=?",(self.user_id,)).fetchall()}
            for code, stamp in db.execute(
                "SELECT code,MAX(completed_at) FROM topic_completions WHERE user_id=? GROUP BY code",(self.user_id,)):
                record(course_names.get(code),stamp)
        return totals

    def recent_topic_index(self, code: str):
        with self.connect() as db:
            row = db.execute("""SELECT topic_index FROM topic_completions
                WHERE user_id=? AND code=? ORDER BY completed_at DESC LIMIT 1""",
                (self.user_id, code)).fetchone()
        return row[0] if row else None

    def clear_course_progress(self):
        with self.connect() as db:
            db.execute("DELETE FROM topic_completions WHERE user_id=?", (self.user_id,))
