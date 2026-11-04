"""Student-scoped, explicitly recorded course-topic completion, never fake mastery."""
from __future__ import annotations
from copy import deepcopy
from PySide6.QtCore import QObject, Property, Signal, Slot


SEEDS = [
    {"title":"Applied Statistics", "code":"STA 201", "initials":"AS", "category":"Mathematics", "accent":"#F97316", "soft":"#FFF0E4", "topics":["Data types and study design", "Descriptive statistics", "Probability foundations", "Conditional probability and Bayes", "Discrete distributions", "Normal distribution and z-scores", "Confidence intervals", "Hypothesis testing and interpretation"]},
    {"title":"Python Programming", "code":"CSC 203", "initials":"PY", "category":"Programming", "accent":"#2563EB", "soft":"#E9F1FF", "topics":["Values, variables and types", "Conditions and loops", "Lists, tuples, sets and dictionaries", "Functions and scope", "Classes and objects", "Files, paths and exceptions", "Modules, packages and environments", "Testing and debugging"]},
    {"title":"Computer Systems", "code":"CSC 214", "initials":"CS", "category":"Computing", "accent":"#006E56", "soft":"#E4F6F1", "topics":["Computer architecture", "Binary representation and logic", "CPU performance and caches", "Memory hierarchy and virtual memory", "Processes, threads and scheduling", "Synchronization and deadlocks", "Storage systems and file systems", "Networks and system diagnostics"]},
    {"title":"Software Engineering", "code":"SWE 210", "initials":"SE", "category":"Engineering", "accent":"#2563EB", "soft":"#E9F1FF", "topics":["Software lifecycle and process models", "Requirements engineering", "UML and system modelling", "Modularity and design principles", "Version control and collaboration", "Software testing strategy", "Quality, security and maintainability", "Project estimation and delivery"]},
    {"title":"Discrete Mathematics", "code":"MTH 220", "initials":"DM", "category":"Mathematics", "accent":"#F97316", "soft":"#FFF0E4", "topics":["Propositional logic", "Predicate logic and quantifiers", "Sets and operations", "Relations and functions", "Counting and combinatorics", "Proof methods", "Graphs and trees", "Recurrence and algorithm analysis"]},
    {"title":"Database Systems", "code":"CSC 216", "initials":"DB", "category":"Computing", "accent":"#64748B", "soft":"#EFF2F6", "topics":["Database concepts and DBMS", "Entity-relationship modelling", "Relational keys and constraints", "SQL SELECT and filtering", "Joins and aggregation", "Normalization and anomalies", "Transactions and ACID", "Indexes, access control and backups"]},
]


class CourseProgressBridge(QObject):
    changed = Signal()
    warning = Signal(str)

    def __init__(self, database, profile, parent=None):
        super().__init__(parent)
        self.db = database
        self.profile = profile
        self._seed_defaults()
        if profile is not None:
            profile.changed.connect(self.changed.emit)

    def _seed_defaults(self):
        for course in SEEDS:
            self.db.upsert_course(deepcopy(course), is_default=True)

    def _active_courses(self):
        selected = set(self.profile.enrolledCourses) if self.profile is not None and self.profile.onboarded else None
        result = []
        activity = self.db.course_activity()
        for data, is_default in self.db.list_courses():
            if selected is not None and is_default and data.get("title") not in selected:
                continue
            code = data["code"]
            topics = data.get("topics", [])
            done = sorted(i for i in self.db.completion_indices(code) if 0 <= i < len(topics))
            progress = int((100 * len(done) / len(topics)) + 0.5) if topics else 0
            recent = self.db.recent_topic_index(code)
            last_topic = topics[recent] if recent is not None and recent in done else ("No topics completed yet" if topics else "Add your course topics")
            course = dict(data)
            course.update({
                "lecturer": course.get("lecturer", "Course lecturer"),
                "topic": last_topic,
                "topicCount": len(topics),
                "progress": progress,
                "completedTopics": len(done),
                "progressSource": "Marked topic completion",
                "lastActivityAt": activity.get(data["title"], ""),
            })
            result.append(course)
        return result

    @Property("QVariantList", notify=changed)
    def courses(self):
        return self._active_courses()

    @Property(int, notify=changed)
    def count(self):
        return len(self._active_courses())

    @Slot(str, int, result=bool)
    def topicCompleted(self, code, index):
        return int(index) in self.db.completion_indices(str(code))

    @Slot(str, int, bool, result=bool)
    def setTopicCompleted(self, code, index, completed):
        try:
            entry = next((c for c in self._active_courses() if c["code"] == code), None)
            if entry is None or not 0 <= index < len(entry.get("topics", [])):
                return False
            self.db.mark_topic(code, int(index), bool(completed))
            self.changed.emit()
            return True
        except Exception as exc:
            self.warning.emit(f"Could not save topic completion: {exc}")
            return False

    @Slot(str, str, str, result=bool)
    def addCourse(self, title, code, category):
        title = " ".join(str(title).strip().split())[:100]
        code = " ".join(str(code).strip().upper().split())[:40]
        category = " ".join(str(category).strip().split())[:64] or "General"
        if not title or not code or any(c["code"] == code for c,_ in self.db.list_courses()):
            return False
        try:
            self.db.upsert_course({"title": title, "code": code, "category": category,
                "initials": "".join(x[0] for x in title.split()[:2]).upper(),
                "accent": "#2563EB", "soft": "#E9F1FF", "topics": []})
            self.changed.emit()
            return True
        except Exception as exc:
            self.warning.emit(f"Could not save course: {exc}")
            return False

    @Slot(str, str, result=bool)
    def addTopic(self, code, topic):
        topic = " ".join(str(topic).strip().split())[:120]
        if not topic:
            return False
        try:
            for data, default in self.db.list_courses():
                if data["code"] != code: continue
                if default: return False  # canonical default units are not mutated
                current = list(data.get("topics", []))
                if len(current) >= 100 or topic.casefold() in (s.casefold() for s in current):
                    return False
                data["topics"] = current + [topic]
                self.db.upsert_course(data, overwrite=True)
                self.changed.emit()
                return True
        except Exception as exc:
            self.warning.emit(f"Could not save topic: {exc}")
        return False
