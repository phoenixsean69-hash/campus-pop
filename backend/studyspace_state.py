"""Local, persistent UI data for StudySpace. No accounts or network calls."""
from __future__ import annotations

import json
import os
import re
import collections
import zipfile
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta, timezone
from pathlib import Path
from uuid import uuid4
from shutil import copy2

from PySide6.QtCore import QObject, Property, Signal, Slot, QSettings, QStandardPaths, QUrl
from PySide6.QtGui import QDesktopServices, QGuiApplication
from PySide6.QtCore import Qt


class PreferencesBridge(QObject):
    themeChanged = Signal()
    focusMinutesChanged = Signal()
    weeklyGoalChanged = Signal()
    displayNameChanged = Signal()
    reducedMotionChanged = Signal()

    THEMES = ("campus", "ocean", "slate")
    appearanceChanged = Signal()
    fontScaleChanged = Signal()
    notificationsChanged = Signal()
    soundChanged = Signal()
    alarmToneChanged = Signal()
    alarmEnabledChanged = Signal()
    breakMinutesChanged = Signal()
    aiStyleChanged = Signal()
    programChanged = Signal()
    levelChanged = Signal()
    packChanged = Signal()
    paperIntensityChanged = Signal()
    densityChanged = Signal()
    illustrationsChanged = Signal()
    tutorDraftChanged = Signal()


    def __init__(self, parent=None):
        super().__init__(parent)
        self._settings = QSettings("Storm", "StudySpace")
        # Appearance packs are independent of accent and light/dark mode.
        self._pack = str(self._settings.value("appearance/pack", "pop"))
        # One-time key migration. Never remap the NEW Studio on later launches.
        migrated = str(self._settings.value("appearance/packIdsV34", "false")).lower() == "true"
        if not migrated:
            if self._pack == "studio":
                self._pack = "paper"
                self._settings.setValue("appearance/pack", "paper")
            elif self._pack == "graphite":
                self._pack = "studio"
                self._settings.setValue("appearance/pack", "studio")
            self._settings.setValue("appearance/packIdsV34", True)
            self._settings.sync()
        if self._pack not in ("pop", "paper", "studio"):
            self._pack = "pop"
        self._paper_intensity = str(self._settings.value("appearance/paperIntensity", "medium"))
        if self._paper_intensity not in ("soft", "medium", "strong"):
            self._paper_intensity = "medium"
        self._density = str(self._settings.value("appearance/density", "comfortable"))
        if self._density not in ("comfortable", "compact"):
            self._density = "comfortable"
        self._show_art = str(self._settings.value("appearance/illustrations", "true")).lower() == "true"
        self._theme = str(self._settings.value("appearance/theme", "campus"))
        if self._theme not in self.THEMES:
            self._theme = "campus"
        self._focus = self._bounded_int(self._settings.value("study/focusMinutes", 25), (15, 25, 45, 60), 25)
        self._goal = self._bounded_int(self._settings.value("study/weeklyGoal", 10), (5, 10, 15, 20), 10)
        self._name = str(self._settings.value("profile/name", "Student"))[:48] or "Student"
        self._motion = str(self._settings.value("appearance/reducedMotion", "false")).lower() == "true"
        self._appearance = str(self._settings.value("appearance/mode", "system"))
        if self._appearance not in ("system", "light", "dark"): self._appearance = "system"
        self._scale = self._bounded_int(self._settings.value("appearance/fontScale", 100), (90,100,110,120), 100)
        self._notifications = str(self._settings.value("study/notifications", "true")).lower() == "true"
        self._sound = str(self._settings.value("focus/sound", "false")).lower() == "true"
        self._alarm_tone = str(self._settings.value("alarms/tone", "Chime"))
        if self._alarm_tone not in ("Chime", "Bell", "Pulse", "Digital", "Soft"):
            self._alarm_tone = "Chime"
        self._alarm_enabled = str(self._settings.value("alarms/enabled", "true")).lower() in ("true", "1", "yes")
        self._break = self._bounded_int(self._settings.value("focus/breakMinutes", 5), (5,10,15), 5)
        self._program = str(self._settings.value("profile/program", ""))[:80]
        self._level = str(self._settings.value("profile/level", "Undergraduate"))
        self._ai_style = str(self._settings.value("ai/responseStyle", "Step by step"))
        if self._ai_style not in ("Concise", "Step by step", "Detailed"): self._ai_style = "Step by step"
        self._tutor_draft = ""
        self._tutor_mode = "Explain"
        self._tutor_auto = False
        app = QGuiApplication.instance()
        if app is not None:
            app.styleHints().colorSchemeChanged.connect(self._on_system_scheme_changed)

    def _on_system_scheme_changed(self, *_):
        if self._appearance == "system": self.appearanceChanged.emit()

    @Property(str, notify=appearanceChanged)
    def appearanceMode(self): return self._appearance

    @Property(bool, notify=appearanceChanged)
    def isDark(self):
        if self._appearance == "dark": return True
        if self._appearance == "light": return False
        app = QGuiApplication.instance()
        return bool(app and app.styleHints().colorScheme() == Qt.ColorScheme.Dark)

    @Slot(str)
    def setAppearanceMode(self, value):
        if value not in ("system", "light", "dark") or value == self._appearance: return
        self._appearance = value
        self._settings.setValue("appearance/mode", value)
        self._settings.sync()
        self.appearanceChanged.emit()

    @Property(int, notify=fontScaleChanged)
    def fontScale(self): return self._scale

    @Slot(int)
    def setFontScale(self, value):
        if value not in (90,100,110,120) or self._scale == value: return
        self._scale = value; self._settings.setValue("appearance/fontScale", value); self._settings.sync(); self.fontScaleChanged.emit()

    @Property(bool, notify=notificationsChanged)
    def notificationsEnabled(self): return self._notifications

    @Slot(bool)
    def setNotificationsEnabled(self, value):
        self._notifications = bool(value); self._settings.setValue("study/notifications", self._notifications); self._settings.sync(); self.notificationsChanged.emit()

    @Property(bool, notify=soundChanged)
    def focusSound(self): return self._sound

    @Slot(bool)
    def setFocusSound(self, value):
        self._sound = bool(value); self._settings.setValue("focus/sound", self._sound); self._settings.sync(); self.soundChanged.emit()

    @Property(int, notify=breakMinutesChanged)
    def breakMinutes(self): return self._break

    @Slot(int)
    def setBreakMinutes(self, value):
        if value not in (5,10,15): return
        self._break = value; self._settings.setValue("focus/breakMinutes", value); self._settings.sync(); self.breakMinutesChanged.emit()

    @Property(str, notify=programChanged)
    def program(self): return self._program

    @Slot(str)
    def setProgram(self, value):
        self._program = value.strip()[:80]
        self._settings.setValue("profile/program", self._program)
        self._settings.sync(); self.programChanged.emit()

    @Property(str, notify=levelChanged)
    def studyLevel(self): return self._level

    @Slot(str)
    def setStudyLevel(self, value):
        if value not in ("Undergraduate", "Postgraduate", "Diploma", "Other"): return
        self._level = value; self._settings.setValue("profile/level", value); self._settings.sync(); self.levelChanged.emit()

    @Property(str, notify=aiStyleChanged)
    def aiStyle(self): return self._ai_style

    @Slot(str)
    def setAiStyle(self, value):
        if value not in ("Concise", "Step by step", "Detailed"): return
        self._ai_style = value; self._settings.setValue("ai/responseStyle", value); self._settings.sync(); self.aiStyleChanged.emit()


    @staticmethod
    def _bounded_int(value, allowed, fallback):
        try:
            val = int(value)
            return val if val in allowed else fallback
        except (TypeError, ValueError):
            return fallback

    @Property(str, notify=themeChanged)
    def themeKey(self):
        return self._theme

    @Slot(str)
    def setThemeKey(self, value):
        if value not in self.THEMES or self._theme == value:
            return
        self._theme = value
        self._settings.setValue("appearance/theme", value)
        self._settings.sync()
        self.themeChanged.emit()

    @Property(int, notify=focusMinutesChanged)
    def focusMinutes(self):
        return self._focus

    @Slot(int)
    def setFocusMinutes(self, value):
        if value not in (15, 25, 45, 60) or self._focus == value:
            return
        self._focus = value
        self._settings.setValue("study/focusMinutes", value)
        self._settings.sync()
        self.focusMinutesChanged.emit()

    @Property(int, notify=weeklyGoalChanged)
    def weeklyGoal(self):
        return self._goal

    @Slot(int)
    def setWeeklyGoal(self, value):
        if value not in (5, 10, 15, 20) or self._goal == value:
            return
        self._goal = value
        self._settings.setValue("study/weeklyGoal", value)
        self._settings.sync()
        self.weeklyGoalChanged.emit()

    @Property(str, notify=displayNameChanged)
    def displayName(self):
        return self._name

    @Slot(str)
    def setDisplayName(self, value):
        value = value.strip()[:48]
        if not value or value == self._name:
            return
        self._name = value
        self._settings.setValue("profile/name", value)
        self._settings.sync()
        self.displayNameChanged.emit()

    @Property(bool, notify=reducedMotionChanged)
    def reducedMotion(self):
        return self._motion

    @Slot(bool)
    def setReducedMotion(self, value):
        value = bool(value)
        if value == self._motion:
            return
        self._motion = value
        self._settings.setValue("appearance/reducedMotion", value)
        self._settings.sync()
        self.reducedMotionChanged.emit()

    @Slot()
    def playFocusSound(self):
        try:
            if os.name == "nt":
                import winsound
                winsound.MessageBeep()
            else:
                app = QGuiApplication.instance()
                if app and hasattr(app, "beep"): app.beep()
        except Exception:
            pass

    @Slot()
    def resetPreferences(self):
        self.setPackKey("pop")
        self.setPaperIntensity("medium")
        self.setLayoutDensity("comfortable")
        self.setShowIllustrations(True)
        self.setThemeKey("campus")
        self.setFocusMinutes(25)
        self.setWeeklyGoal(10)
        self.setDisplayName("Student")
        self.setReducedMotion(False)
        self.setAppearanceMode("system")
        self.setFontScale(100)
        self.setNotificationsEnabled(True)
        self.setFocusSound(False)
        self.setAlarmTone("Chime")
        self.setAlarmEnabled(True)
        self.setBreakMinutes(5)
        self.setAiStyle("Step by step")
        self.setProgram("")
        self.setStudyLevel("Undergraduate")



    @Property(str, notify=tutorDraftChanged)
    def tutorDraft(self):
        return self._tutor_draft

    @Property(str, notify=tutorDraftChanged)
    def tutorMode(self):
        return self._tutor_mode

    @Property(bool, notify=tutorDraftChanged)
    def tutorAutoSend(self):
        return self._tutor_auto

    @Slot(str, str, bool)
    def queueTutorDraft(self, text, mode="Explain", autoSend=False):
        text = str(text).strip()
        self._tutor_draft = text
        self._tutor_mode = mode if mode in ("Explain", "Guided", "Practice", "Summarise") else "Explain"
        self._tutor_auto = bool(autoSend)
        self.tutorDraftChanged.emit()

    @Slot()
    def clearTutorDraft(self):
        if not self._tutor_draft and not self._tutor_auto and self._tutor_mode == "Explain":
            return
        self._tutor_draft = ""
        self._tutor_mode = "Explain"
        self._tutor_auto = False
        self.tutorDraftChanged.emit()

    # CAMPUS_POP_PACKS_V33: profile-independent appearance preferences.
    @Property(str, notify=packChanged)
    def packKey(self):
        return self._pack

    @Slot(str)
    def setPackKey(self, key):
        if key not in ("pop", "paper", "studio") or key == self._pack:
            return
        self._pack = key
        self._settings.setValue("appearance/pack", key)
        self._settings.sync()
        self.packChanged.emit()
        # Preset defaults can be changed independently right below the cards.
        self.setLayoutDensity("compact" if key == "studio" else "comfortable")
        self.setShowIllustrations(key != "studio")


    # CAMPUS_POP_PACKS_V34
    @Property(str, notify=paperIntensityChanged)
    def paperIntensity(self):
        return self._paper_intensity

    @Slot(str)
    def setPaperIntensity(self, level):
        if level not in ("soft", "medium", "strong") or level == self._paper_intensity:
            return
        self._paper_intensity = level
        self._settings.setValue("appearance/paperIntensity", level)
        self._settings.sync()
        self.paperIntensityChanged.emit()

    @Property(str, notify=densityChanged)
    def layoutDensity(self):
        return self._density

    @Slot(str)
    def setLayoutDensity(self, value):
        if value not in ("comfortable", "compact") or value == self._density:
            return
        self._density = value
        self._settings.setValue("appearance/density", value)
        self._settings.sync()
        self.densityChanged.emit()

    @Property(bool, notify=illustrationsChanged)
    def showIllustrations(self):
        return self._show_art

    @Slot(bool)
    def setShowIllustrations(self, visible):
        visible = bool(visible)
        if visible == self._show_art:
            return
        self._show_art = visible
        self._settings.setValue("appearance/illustrations", visible)
        self._settings.sync()
        self.illustrationsChanged.emit()



    # CAMPUS_POP_V35_TIMEUP — shared Windows alarm playback and tone preferences.
    @Property(str, notify=alarmToneChanged)
    def alarmTone(self):
        return self._alarm_tone

    @Slot(str)
    def setAlarmTone(self, tone):
        if tone not in ("Chime", "Bell", "Pulse", "Digital", "Soft") or tone == self._alarm_tone:
            return
        self._alarm_tone = tone
        self._settings.setValue("alarms/tone", tone)
        self._settings.sync()
        self.alarmToneChanged.emit()

    @Property(bool, notify=alarmEnabledChanged)
    def alarmEnabled(self):
        return self._alarm_enabled

    @Slot(bool)
    def setAlarmEnabled(self, enabled):
        enabled = bool(enabled)
        if enabled == self._alarm_enabled:
            return
        self._alarm_enabled = enabled
        self._settings.setValue("alarms/enabled", enabled)
        self._settings.sync()
        self.alarmEnabledChanged.emit()

    def _play_alarm_file(self):
        paths = {"Chime": "chime.wav", "Bell": "bell.wav", "Pulse": "pulse.wav",
                 "Digital": "digital.wav", "Soft": "soft.wav"}
        sound_file = Path(__file__).resolve().parent.parent / "assets" / "sounds" / "alarms" / paths[self._alarm_tone]
        if not sound_file.is_file():
            return False
        try:
            if os.name == "nt":
                import winsound
                winsound.PlaySound(str(sound_file), winsound.SND_FILENAME | winsound.SND_ASYNC | winsound.SND_NODEFAULT)
                return True
            # Campus Pop targets Windows. Other platforms use their desktop bell.
            app = QGuiApplication.instance()
            if app and hasattr(app, "beep"):
                app.beep()
                return True
        except Exception:
            return False
        return False

    @Slot(result=bool)
    def previewAlarm(self):
        """Preview plays even when automatic time-up alarms are muted."""
        return self._play_alarm_file()

    @Slot(result=bool)
    def playTimeUpAlarm(self):
        if not self._alarm_enabled:
            return False
        return self._play_alarm_file()


class WorkspaceBridge(QObject):
    tasksChanged = Signal()
    notesChanged = Signal()
    filesChanged = Signal()
    statsChanged = Signal()
    errorOccurred = Signal(str)

    DEFAULT_DATA = {"tasks": [], "notes": [], "files": [], "focus": [], "quizzes": []}
    EXTENSIONS = {".pdf", ".docx", ".txt", ".md", ".pptx", ".xlsx"}

    def __init__(self, parent=None):
        super().__init__(parent)
        directory = QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
        self.root = Path(directory) if directory else Path.home() / ".studyspace"
        self.root.mkdir(parents=True, exist_ok=True)
        self.path = self.root / "workspace.json"
        self._data = self._load()

    def _load(self):
        if not self.path.exists():
            return {key: list(value) for key, value in self.DEFAULT_DATA.items()}
        try:
            data = json.loads(self.path.read_text(encoding="utf-8"))
            if not isinstance(data, dict):
                raise ValueError("Invalid workspace root")
            return {key: data.get(key, []) if isinstance(data.get(key, []), list) else []
                    for key in self.DEFAULT_DATA}
        except (OSError, ValueError) as exc:
            # Never overwrite an unreadable/corrupt original without preserving it.
            self.errorOccurred.emit(f"Could not read saved workspace: {exc}")
            return {key: [] for key in self.DEFAULT_DATA}

    def _save(self):
        tmp = self.path.with_suffix(".json.tmp")
        try:
            tmp.write_text(json.dumps(self._data, indent=2, ensure_ascii=False), encoding="utf-8")
            os.replace(tmp, self.path)
        except OSError as exc:
            self.errorOccurred.emit(f"Could not save changes: {exc}")
            try: tmp.unlink(missing_ok=True)
            except OSError: pass
            return False
        return True

    def _emit(self, *signals):
        for signal in signals: signal.emit()

    @Property("QVariantList", notify=tasksChanged)
    def tasks(self):
        return list(self._data["tasks"])

    @Property("QVariantList", notify=notesChanged)
    def notes(self):
        return list(self._data["notes"])

    @Property("QVariantList", notify=filesChanged)
    def files(self):
        return list(self._data["files"])

    @Property("QVariantList", notify=statsChanged)
    def recentFocus(self):
        return list(reversed(self._data["focus"][-15:]))

    @Property(int, notify=statsChanged)
    def totalFocusMinutes(self):
        return int(round(sum(max(0, float(row.get("minutes", 0))) for row in self._data["focus"])))

    @Property(int, notify=statsChanged)
    def weeklyFocusMinutes(self):
        today = datetime.now().astimezone()
        week = today.isocalendar()[:2]
        total = 0.0
        for row in self._data["focus"]:
            try:
                dt = datetime.fromisoformat(row["when"]).astimezone()
                if dt.isocalendar()[:2] == week: total += float(row["minutes"])
            except (KeyError, ValueError, TypeError):
                continue
        return int(round(total))

    @Property(int, notify=statsChanged)
    def streakDays(self):
        days = set()
        for item in self._data["focus"] + self._data["quizzes"]:
            try:
                days.add(datetime.fromisoformat(item["when"]).astimezone().date())
            except (KeyError, ValueError, TypeError):
                continue
        today = datetime.now().astimezone().date()
        current = today if today in days else today - timedelta(days=1)
        count = 0
        while current in days:
            count += 1
            current -= timedelta(days=1)
        return count

    @Property("QVariantList", notify=statsChanged)
    def dailyFocus(self):
        today = datetime.now().astimezone().date()
        output = []
        for offset in range(6, -1, -1):
            day = today - timedelta(days=offset)
            minutes = 0.0
            for row in self._data["focus"]:
                try:
                    logged = datetime.fromisoformat(row["when"]).astimezone().date()
                    if logged == day: minutes += float(row["minutes"])
                except (KeyError, ValueError, TypeError):
                    continue
            output.append({"day": day.strftime("%a"), "minutes": int(round(minutes))})
        return output

    @Property(int, notify=statsChanged)
    def quizCount(self):
        return len(self._data["quizzes"])

    @Property(int, notify=statsChanged)
    def quizAccuracy(self):
        total = sum(max(0, int(q.get("total", 0))) for q in self._data["quizzes"])
        correct = sum(max(0, int(q.get("correct", 0))) for q in self._data["quizzes"])
        return round(100 * correct / total) if total else 0

    @Property(int, notify=tasksChanged)
    def openTasks(self):
        return sum(not task.get("done", False) for task in self._data["tasks"])

    @Property("QVariantList", notify=statsChanged)
    def courseFocus(self):
        totals = {}
        for row in self._data["focus"]:
            name = row.get("course") or "Unassigned"
            totals[name] = totals.get(name, 0.0) + max(0, float(row.get("minutes", 0)))
        return [{"name": name, "value": round(total, 1)} for name, total in sorted(totals.items(), key=lambda x: -x[1]) if total > 0]

    @Property("QVariantList", notify=statsChanged)
    def courseAccuracy(self):
        acc = {}
        for row in self._data["quizzes"]:
            name = row.get("course") or "Unassigned"
            pair = acc.setdefault(name, [0,0])
            pair[0] += int(row.get("correct", 0)); pair[1] += int(row.get("total", 0))
        return [{"name": name, "value": round(100 * v[0] / v[1])} for name,v in acc.items() if v[1] > 0]

    @Property("QVariantList", notify=statsChanged)
    def topicAccuracy(self):
        acc = {}
        for row in self._data["quizzes"]:
            name = row.get("topic") or "Mixed topics"
            pair = acc.setdefault(name, [0,0]); pair[0] += int(row.get("correct", 0)); pair[1] += int(row.get("total", 0))
        return [{"name": name, "value": round(100 * v[0] / v[1])} for name,v in acc.items() if v[1] > 0]

    @Property("QVariantList", notify=tasksChanged)
    def taskUrgency(self):
        today = datetime.now().date()
        values = {"Overdue":0, "Next 7 days":0, "Later / unscheduled":0, "Completed":0}
        for row in self._data["tasks"]:
            if row.get("done"):
                values["Completed"] += 1; continue
            try: due = datetime.strptime(row.get("due", ""), "%Y-%m-%d").date()
            except (ValueError, TypeError): due = None
            if due is not None and due < today: values["Overdue"] += 1
            elif due is not None and (due - today).days <= 7: values["Next 7 days"] += 1
            else: values["Later / unscheduled"] += 1
        return [{"name": name, "value": value} for name,value in values.items()]

    @Property("QVariantList", notify=tasksChanged)
    def upcomingWeek(self):
        today = datetime.now().date()
        counts = { (today+timedelta(days=i)).isoformat():0 for i in range(7) }
        for row in self._data["tasks"]:
            if not row.get("done") and row.get("due", "") in counts: counts[row["due"]] += 1
        return [{"name": datetime.fromisoformat(k).strftime("%a"), "value": value} for k,value in counts.items()]

    @Slot(str, str, str, str, result=bool)
    def addTask(self, title, course, due, priority):
        title = title.strip()[:120]
        if not title: return False
        due = due.strip()
        if due:
            try: datetime.strptime(due, "%Y-%m-%d")
            except (TypeError, ValueError): return False
        row = {"id": uuid4().hex, "title": title,
               "course": (course.strip() or "General")[:70],
               "due": due.strip()[:32],
               "priority": priority if priority in ("Low", "Medium", "High") else "Medium",
               "done": False}
        self._data["tasks"].insert(0, row)
        if self._save(): self.tasksChanged.emit(); return True
        self._data["tasks"].pop(0)
        return False

    @Slot(str)
    def toggleTask(self, ident):
        for task in self._data["tasks"]:
            if task["id"] == ident:
                task["done"] = not task["done"]
                if self._save(): self.tasksChanged.emit()
                else: task["done"] = not task["done"]
                return

    @Slot(str)
    def deleteTask(self, ident):
        rows = self._data["tasks"]
        self._data["tasks"] = [t for t in rows if t["id"] != ident]
        if self._save(): self.tasksChanged.emit()
        else: self._data["tasks"] = rows

    @Slot(str, str, result=bool)
    def addNote(self, title, body):
        title = title.strip()[:90]
        body = body.strip()[:25000]
        if not title or not body: return False
        self._data["notes"].insert(0, {"id": uuid4().hex, "title": title,
                                        "body": body, "when": datetime.now().strftime("%d %b %Y")})
        if self._save(): self.notesChanged.emit(); return True
        self._data["notes"].pop(0)
        return False

    @Slot(str)
    def deleteNote(self, ident):
        previous = self._data["notes"]
        self._data["notes"] = [n for n in previous if n["id"] != ident]
        if self._save(): self.notesChanged.emit()
        else: self._data["notes"] = previous

    @Slot(str, result=str)
    def importFile(self, url):
        source = Path(QUrl(url).toLocalFile() if url.startswith("file:") else url)
        if not source.is_file(): return "File not found"
        if source.suffix.lower() not in self.EXTENSIONS: return "Unsupported file type"
        if source.stat().st_size > 20 * 1024 * 1024: return "Maximum file size is 20 MB"
        folder = self.root / "materials"
        folder.mkdir(parents=True, exist_ok=True)
        dest = folder / (uuid4().hex[:8] + "_" + source.name)
        try: copy2(source, dest)
        except OSError as exc: return str(exc)
        self._data["files"].insert(0, {"id": uuid4().hex, "name": source.name,
                                        "path": str(dest), "type": source.suffix.upper().lstrip(".")})
        if self._save(): self.filesChanged.emit(); return ""
        self._data["files"].pop(0)
        dest.unlink(missing_ok=True)
        return "Could not save imported file"

    @staticmethod
    def _read_study_text(path):
        # Text extraction remains entirely local. A scanned PDF needs OCR and is not supported.
        kind = path.suffix.lower()
        if kind in (".txt", ".md"):
            return path.read_text(encoding="utf-8", errors="replace")[:100000]
        if kind == ".pdf":
            try:
                from pypdf import PdfReader
            except ImportError:
                raise ValueError("PDF summaries require pypdf. Run: python -m pip install pypdf")
            reader = PdfReader(str(path))
            text = "\n".join((page.extract_text() or "") for page in list(reader.pages)[:80])
            return text[:100000]
        if kind in (".docx", ".pptx", ".xlsx"):
            if kind == ".docx":
                items = ["word/document.xml"]
            else:
                with zipfile.ZipFile(path) as archive:
                    members = archive.namelist()
                if kind == ".pptx":
                    items = sorted(x for x in members if re.fullmatch(r"ppt/slides/slide[0-9]+\.xml", x))[:60]
                else:
                    items = ["xl/sharedStrings.xml"] + sorted(x for x in members if re.fullmatch(r"xl/worksheets/sheet[0-9]+\.xml", x))[:40]
            paragraphs = []
            with zipfile.ZipFile(path) as archive:
                for item in items:
                    if item not in archive.namelist(): continue
                    raw = archive.read(item)
                    if len(raw) > 6*1024*1024: continue
                    doc = ET.fromstring(raw)
                    # OOXML text is stored in t, v and sometimes inline-string nodes.
                    for el in doc.iter():
                        if el.tag.rsplit("}", 1)[-1] in ("t", "v") and el.text:
                            paragraphs.append(el.text)
                        if sum(map(len, paragraphs)) > 100000: break
                    if sum(map(len, paragraphs)) > 100000: break
            return " ".join(paragraphs)[:100000]
        raise ValueError("Unsupported document format")

    @staticmethod
    def _extractive_summary(text, sentence_count=5):
        import math
        cleaned = re.sub(r"\s+", " ", text).strip()
        if not cleaned: return "No readable text found. Scanned PDFs may need OCR."
        # Take original sentences; never generate facts not found in the document.
        parts = [s.strip() for s in re.split(r"(?<=[.!?])\s+", cleaned) if len(s.strip()) > 28]
        if not parts: return cleaned[:1200]
        stop = set("the a an and or to for from in on of is are was were be been it this that with at as by we you they he she their your into our will can may not but than have has had more those these which who how what when where there such also only each some most very used use one two three about between through while using within all".split())
        words = [w for w in re.findall(r"[a-zA-Z]{3,}", cleaned.lower()) if w not in stop]
        freq = collections.Counter(words)
        scored = []
        for i, sent in enumerate(parts[:400]):
            terms = [w for w in re.findall(r"[a-zA-Z]{3,}", sent.lower()) if w not in stop]
            rank = sum(freq[w] for w in terms) / max(4, math.sqrt(len(terms)+1))
            scored.append((rank, i))
        selected = sorted(i for rank, i in sorted(scored, reverse=True)[:sentence_count])
        return "\n\n".join(parts[i] for i in selected)[:5000]

    @Slot(str, result=str)
    def extractFileText(self, ident):
        for row in self._data["files"]:
            if row["id"] == ident:
                try:
                    return self._read_study_text(Path(row["path"]))[:12000] or "No readable text found."
                except Exception as exc:
                    return "Could not read file: " + str(exc)
        return "Choose a file first."

    @Slot(str, result=str)
    def summarizeFile(self, ident):
        for row in self._data["files"]:
            if row["id"] == ident:
                try:
                    text = self._read_study_text(Path(row["path"]))
                    return self._extractive_summary(text)
                except Exception as exc:
                    return "Could not summarise file: " + str(exc)
        return "Choose a file first."

    @Slot(str, result=str)
    def summarizeNote(self, ident):
        for row in self._data["notes"]:
            if row["id"] == ident:
                return self._extractive_summary(row.get("body", ""))
        return "Choose a saved note first."

    @Slot(str)
    def openFile(self, ident):
        for row in self._data["files"]:
            if row["id"] == ident:
                QDesktopServices.openUrl(QUrl.fromLocalFile(row["path"]))
                return

    @Slot(str)
    def deleteFile(self, ident):
        previous = self._data["files"]
        removed = [f for f in previous if f["id"] == ident]
        self._data["files"] = [f for f in previous if f["id"] != ident]
        if self._save():
            self.filesChanged.emit()
            # Only delete files we copied into the app's material directory.
            for row in removed:
                p = Path(row["path"])
                if p.parent == self.root / "materials": p.unlink(missing_ok=True)
        else: self._data["files"] = previous

    @Slot(int)
    @Slot(int, str)
    def recordFocus(self, elapsedSeconds, course="Unassigned"):
        if elapsedSeconds < 30: return
        self._data["focus"].append({"when": datetime.now(timezone.utc).isoformat(),
                                     "minutes": round(elapsedSeconds / 60.0, 2), "course": (course or "Unassigned")[:70]})
        if self._save(): self.statsChanged.emit()
        else: self._data["focus"].pop()

    @Slot(str, int, int)
    @Slot(str, int, int, str)
    def recordQuiz(self, course, correct, total, topic="Mixed topics"):
        if total <= 0: return
        self._data["quizzes"].append({"when": datetime.now(timezone.utc).isoformat(),
                                      "course": course[:80], "topic": (topic or "Mixed topics")[:80], "correct": max(0, min(correct, total)),
                                      "total": total})
        if self._save(): self.statsChanged.emit()
        else: self._data["quizzes"].pop()

    @Slot(result=str)
    def exportData(self):
        docs = QStandardPaths.writableLocation(QStandardPaths.DocumentsLocation)
        destdir = Path(docs) if docs else Path.home()
        destdir.mkdir(parents=True, exist_ok=True)
        dest = destdir / f"StudySpace_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        try:
            dest.write_text(json.dumps(self._data, ensure_ascii=False, indent=2), encoding="utf-8")
            return str(dest)
        except OSError as exc:
            self.errorOccurred.emit(f"Export failed: {exc}")
            return ""

    @Slot()
    def clearStudyData(self):
        old = self._data
        self._data = {key: [] for key in self.DEFAULT_DATA}
        if self._save():
            for row in old["files"]:
                p = Path(row.get("path", ""))
                if p.parent == self.root / "materials":
                    try: p.unlink(missing_ok=True)
                    except OSError: pass
            self._emit(self.tasksChanged, self.notesChanged, self.filesChanged, self.statsChanged)
        else:
            self._data = old
