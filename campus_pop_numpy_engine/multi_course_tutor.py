"""Multi-course grounded teaching facade for Campus Pop V46.2.

Not a large language model; answers are anchored to local introductory
references or passages imported for the active student course.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

from course_library import CourseLibrary, Passage
from python_functions_tutor import OfflineTutor as PythonFunctionsTutor

BEGINNER = re.compile(r"\b(beginner|new to|confused|lost|simpler|simple|easier|dont understand|don't understand|do not understand|i don't get|break.*down|explain.*again|in simple terms)\b",re.I)
FOLLOWUP = re.compile(r"^(?:explain (?:it|that|this)(?: again)?|what does (?:it|that|this) mean|another example|give me an example|simplify|simpler|i(?:'m| am) (?:still )?confused|i (?:dont|don't) get it|yes|yes please|sure|ok|okay|please|go ahead|give me an exercise|quiz me|test me|line by line)[?.! ]*$",re.I)
CONTEXT_REQUEST = re.compile(r"^(?:explain (?:that|it|this)|(?:i(?:'m| am) )?(?:still )?confused|i (?:don't|dont) (?:get|understand) (?:that|it|this)|break (?:that|it|this) down|make (?:that|it|this) simpler|another example|give me an (?:example|exercise)|quiz me|test me|yes|sure|okay)\b",re.I)
EXERCISE = re.compile(r"\b(exercise|quiz|practice question|test me|question to practise|question to practice)\b",re.I)
EXAMPLE = re.compile(r"\b(example|show me how|demonstrate)\b",re.I)
FUNCTION_CUE = re.compile(r"\b(function|functions|def|parameter|argument|indentation|return|greet\(\)|calling a function)\b",re.I)
OTHER_PYTHON_CUE = re.compile(r"\b(lists?|tuples?|dictionaries|sets|loops?|classes|files|arrays|slices?)\b",re.I)


class MultiCourseTutor:
    def __init__(self, store=None, starters=None):
        opts = {}
        if store is not None: opts['store'] = store
        if starters is not None: opts['starters'] = starters
        self.library = CourseLibrary(**opts)
        self.course_id: str | None = None
        self.last_passage: Passage | None = None
        self.using_python_functions = False
        self.functions = PythonFunctionsTutor()

    def courses_text(self):
        lines = ['Available courses:']
        for c in self.library.all_courses():
            count = len(self.library.by_course.get(c['id'],[]))
            current = ' [selected]' if c['id']==self.course_id else ''
            lines.append(f"- {c['name']} ({count} indexed references){current}")
        lines.append("Select: /course \"Applied Statistics\"  |  Add: /addcourse \"My Course\"")
        return '\n'.join(lines)

    def help_text(self):
        return ("Commands:\n"
                "  /courses                 List courses and source counts\n"
                "  /course NAME             Select a course\n"
                "  /addcourse NAME          Create a new course\n"
                "  /import PATH             Add a file or directory to the selected course\n"
                "  /synccourses JSON_PATH  Register courses from a JSON list\n"
                "  /sources                 Show references for the selected course\n"
                "  /reset                   Clear conversation topic, keep course\n"
                "  /help                    Display commands\n"
                "  /quit                    Exit the terminal tutor\n\n"
                "Supported material: TXT, MD, CSV, PY, PDF and DOCX. "
                "PDF and DOCX require pypdf and python-docx. "
                "Scanned image-only pages are not read by this prototype.")

    def _reset_conversation(self):
        self.last_passage = None
        self.using_python_functions = False
        self.functions = PythonFunctionsTutor()

    def select_course(self, course_name):
        found = self.library.find_course(course_name)
        if found is None:
            return f"I couldn't find a unique course called '{course_name}'.\n"+self.courses_text()
        self.course_id = found['id']
        self._reset_conversation()
        return f"Now studying: {found['name']}. Ask a question about this course, or import your notes with /import PATH."

    def _command(self, msg):
        cmd, _, rest = msg.partition(' ')
        rest = rest.strip().strip('"').strip("'")
        cmd = cmd.casefold()
        if cmd == '/help': return self.help_text()
        if cmd == '/courses': return self.courses_text()
        if cmd == '/reset':
            self._reset_conversation(); return 'Conversation cleared. Your selected course is unchanged.'
        if cmd == '/course':
            return self.select_course(rest) if rest else 'Usage: /course "Applied Statistics"'
        if cmd == '/addcourse':
            if not rest: return 'Usage: /addcourse "Your Course Name"'
            try:
                c, created = self.library.add_course(rest)
            except ValueError as err:
                return f'Cannot add course: {err}'
            self.course_id = c['id']
            self._reset_conversation()
            return f"{'Created' if created else 'Selected existing'} course: {c['name']}. Add materials with /import PATH."
        if cmd == '/synccourses':
            if not rest: return 'Usage: /synccourses "C:\\path\\to\\courses.json"'
            try:
                data=json.loads(Path(rest).read_text(encoding='utf-8'))
                if isinstance(data,dict): data=data.get('courses',[])
                if not isinstance(data,list): return 'Catalog must be a JSON list (or {"courses": [...]}).'
                added=self.library.sync_course_names(data)
                return f'Synchronized course catalog. Added {len(added)} new course(s).\n'+self.courses_text()
            except (ValueError,OSError) as err:
                return f'Could not synchronize catalog: {err}'
        if cmd == '/import':
            if not self.course_id: return 'Select a course before importing: /course "Applied Statistics"'
            if not rest: return 'Usage: /import "C:\\Users\\...\\Documents\\notes.pdf"'
            try:
                added, skipped = self.library.import_path(self.course_id,rest)
            except (ValueError,FileNotFoundError,PermissionError,OSError) as err:
                return f'Import failed: {err}'
            self._reset_conversation()
            result = f'Imported {len(added)} file(s) into {self.library.find_course(self.course_id)["name"]}.'
            if added: result+='\nAdded: '+', '.join(added[:8])
            if skipped: result+='\nSkipped: '+'; '.join(skipped[:6])
            return result
        if cmd == '/sources':
            if not self.course_id: return 'Choose a course first: /courses'
            entries = self.library.by_course.get(self.course_id,[])
            if not entries: return 'No notes yet. Use /import PATH.'
            names = sorted(set(p.source for p in entries))
            return 'Indexed references:\n'+'\n'.join('- '+n for n in names[:30])
        return 'Unknown command. Type /help.'

    def _python_function_question(self, msg):
        return (self.course_id == 'python-programming'
                and (FUNCTION_CUE.search(msg) or (self.using_python_functions and FOLLOWUP.match(msg)))
                and not OTHER_PYTHON_CUE.search(msg))

    def _response_for(self, p: Passage, message: str) -> str:
        self.last_passage = p
        if p.kind=='starter' and p.lesson:
            lesson=p.lesson
            if EXERCISE.search(message):
                return (f"Practice — {lesson['title']}:\n{lesson['question']}\n\n"
                        "I won't count an unverified answer as mastery.")
            if EXAMPLE.search(message):
                return f"Example — {lesson['title']}:\n{lesson['example']}\n\nSource: {p.source}"
            if BEGINNER.search(message):
                return (f"{lesson.get('simple') or lesson['summary']}\n\n"
                        f"Example: {lesson['example']}\n\nSource: {p.source}")
            return (f"{lesson['summary']}\n\n{lesson['explanation']}\n\n"
                    f"Example: {lesson['example']}\n\nSource: {p.source}")
        # Imported material is displayed as evidence, never impersonated as a
        # generative explanation, so no unsupported claims or fake sources.
        excerpt=p.text.strip()[:800]
        if len(p.text.strip())>800: excerpt+='…'
        place=f' ({p.location})' if p.location else ''
        return (f"I found a relevant passage in your {self.library.find_course(p.course_id)['name']} material:\n\n"
                f"{excerpt}\n\nSource: {p.source}{place}\n\n"
                "This prototype retrieves course material; it cannot yet reliably rephrase "
                "arbitrary notes or independently grade open-ended answers.")

    def respond(self,message: str) -> str:
        message=message.strip()
        if not message: return 'Select a course with /courses, then ask what you would like to learn.'
        if message.startswith('/'):
            return self._command(message)
        if not self.course_id:
            # The first topic may be unambiguously from one of the seeded courses.
            results=self.library.search(message)
            if results and results[0][1]>=0.28 and (len(results)==1 or results[0][1]>results[1][1]*1.2):
                self.course_id=results[0][0].course_id
            else:
                return 'Select your course first so I use the right material.\n'+self.courses_text()
        if self._python_function_question(message):
            self.using_python_functions=True
            return self.functions.respond(message)
        self.using_python_functions=False
        if (FOLLOWUP.match(message) or CONTEXT_REQUEST.search(message)) and self.last_passage is not None:
            return self._response_for(self.last_passage,message)
        matches=self.library.search(message, self.course_id)
        if not matches or matches[0][1]<0.19:
            other=self.library.search(message)
            other=[pair for pair in other if pair[0].course_id!=self.course_id and pair[1]>=0.30]
            if other:
                name=self.library.find_course(other[0][0].course_id)['name']
                return (f"This looks more relevant to {name} than your selected course. "
                        f"Switch using /course \"{name}\" if that's what you're studying.")
            name=self.library.find_course(self.course_id)['name']
            return (f"I couldn't find enough reliable material for that question in {name}. "
                    "Import a relevant course outline, notes or textbook excerpt with /import PATH. "
                    "I won't invent an explanation or claim you've mastered it.")
        return self._response_for(matches[0][0],message)
