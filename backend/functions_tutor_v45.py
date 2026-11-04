"""Campus Pop V45 — bounded, offline Python Functions teaching controller.

Not an LLM. Deliberately grades only well-defined, machine-checkable answers.
Never executes submitted code. Other courses remain in the V44 engine.
"""
from __future__ import annotations

from dataclasses import dataclass
from contextlib import contextmanager
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sqlite3

LESSON_COURSE = "Python Programming"
LESSON_TITLE = "Functions and scope"

# Source labels keep original Campus Pop instructional additions separate from
# the seeded syllabus. We do not attribute our own examples to external texts.
ORIGINAL_SOURCE = "Campus Pop V45 teaching exercises (original)"


@dataclass(frozen=True)
class Question:
    id: str
    concept: str
    prompt: str
    answer: str
    kind: str
    example: str
    hint: str
    explanation: str


QUESTIONS = (
    Question(
        "implicit_none", "return-values",
        "What value does `announce()` return if it only prints a message?",
        "None", "none",
        '```python\ndef announce():\n    print("Hi")\n\nresult = announce()\nprint(result)  # None\n```',
        'Printing something is not the same as returning a value. Notice the value shown by `print(result)`. ',
        'When a Python function finishes without executing `return`, its result is **`None`**. '
        '`print()` displays text; `return` sends a value back to the caller.'
    ),
    Question(
        "return_keyword", "return-values", "Which Python keyword sends a value back from a function?",
        "return", "keyword_return",
        '```python\ndef double(n):\n    return n * 2\n```',
        'It appears immediately before `n * 2` in the example.',
        '`return` produces a result for the caller and ends the current function call.'
    ),
    Question(
        "parameter", "parameters", "In `def greet(name):`, what is the parameter called?",
        "name", "parameter",
        '```python\ndef greet(name):\n    return "Hello " + name\n\nprint(greet("Tariro"))\n```',
        'A parameter is a variable named in the parentheses of the function definition.',
        '`name` is the **parameter**. In `greet("Tariro")`, `"Tariro"` is the **argument**.'
    ),
    Question(
        "double_output", "calling", "What does `print(double(4))` print in this example?",
        "8", "number",
        '```python\ndef double(x):\n    return x * 2\n\nprint(double(4))\n```',
        'The argument `4` becomes `x`. Calculate `4 * 2`.',
        '`double(4)` returns **8**, and `print` displays 8.'
    ),
    Question(
        "define_keyword", "definitions", "Which keyword begins a function definition in Python?",
        "def", "keyword_def",
        '```python\ndef add(a, b):\n    return a + b\n```',
        'Look at the first word of a function definition.',
        'Python uses **`def`** to create a named function.'
    ),
    Question(
        "explicit_zero", "return-values", "What does `get_value()` return in this example?",
        "0", "number",
        '```python\ndef get_value():\n    return 0\n\nprint(get_value())\n```',
        'This example has an explicit `return` statement. Read the value after `return`.',
        'Here the function explicitly returns **0**. That is different from ending without a return, which gives `None`.'
    ),
    Question(
        "multiply", "parameters", "What is printed by `print(multiply(3, 4))`?",
        "12", "number",
        '```python\ndef multiply(a, b):\n    return a * b\n\nprint(multiply(3, 4))\n```',
        'Substitute `a = 3` and `b = 4`, then multiply.',
        'The function returns **12**; its caller prints that value.'
    ),
    Question(
        "scope_error", "scope", "After `show()` finishes, what error arises if we try `print(message)` outside it?",
        "NameError", "name_error",
        '```python\ndef show():\n    message = "Hi"\n    print(message)\n\nshow()\nprint(message)  # NameError\n```',
        '`message` is local to `show`. Outside the function it is not defined.',
        'Python raises **`NameError`** because `message` was created as a local variable inside `show`.'
    ),
    Question(
        "print_return", "return-values", "What two lines are printed, in order?",
        "Hi then None", "two_outputs",
        '```python\ndef say_hi():\n    print("Hi")\n\nvalue = say_hi()\nprint(value)\n```',
        '`say_hi()` prints `Hi`; assigning its return value stores `None`.',
        'The first line is **Hi** (inside the function). The second is **None** (its implicit returned value).'
    ),
)
BY_ID = {q.id: q for q in QUESTIONS}

INTRO = (
    '### Python Functions — Lesson 1\n\n'
    'A **function** is a reusable group of instructions. You **define** it with `def`, '
    '**call** it using parentheses, and can give it inputs called **arguments**. '
    'The names receiving those inputs in the definition are **parameters**.\n\n'
    '```python\ndef greet(name):  # name is a parameter\n'
    '    return "Hello, " + name\n\n'
    'message = greet("Rudo")  # "Rudo" is an argument\n'
    'print(message)  # Hello, Rudo\n```\n\n'
    '**Important: `print` vs `return`**\n\n'
    '- `print(value)` **displays** a value.\n'
    '- `return value` **sends** a value back to the calling code.\n'
    '- A function that finishes without an explicit `return` produces **`None`**, not `0`.\n\n'
    '```python\ndef announce():\n'
    '    print("Hi")\n\n'
    'result = announce()  # displays Hi\n'
    'print(result)       # displays None\n```\n\n'
    'We will practise one concept at a time. '
    'The source lesson is **Python Programming — Functions and scope**; '
    'these explanations and exercises are original Campus Pop material.'
)

FOLLOWUPS = {
    'parameter': (
        '### Parameters and arguments\n\n'
        'A **parameter** is a variable name inside the function definition. '
        'An **argument** is the actual value supplied when calling it.\n\n'
        '```python\ndef greet(name):  # parameter = name\n'
        '    return "Hi " + name\n\n'
        'greet("Rudo")      # argument = "Rudo"\n```'
    ),
    'argument': (
        '### Argument\n\nAn **argument** is the value given to a function when it is called. '
        'A **parameter** is the name in its definition that receives the value.\n\n'
        '```python\ndef double(number):\n    return number * 2\n\n'
        'double(5)  # 5 is the argument; number is the parameter\n```'
    ),
    'return': (
        '### Returning a value\n\n`return` ends a function call and passes a value back. '
        'A function without a completed `return` gives `None`; that is not 0.\n\n'
        '```python\ndef zero():\n    return 0\n\ndef empty():\n    print("Hi")\n\n'
        'print(zero())   # 0\nprint(empty())  # Hi, then None\n```'
    ),
    'scope': (
        '### Local scope\n\nA name created inside a function is usually **local** to that function. '
        'Using that name outside the function usually raises `NameError`.\n\n'
        '```python\ndef demo():\n    score = 10\n    print(score)\n\n'
        'demo()\n# print(score)  # NameError outside demo\n```'
    ),
    'def': '### Defining functions\n\n`def` begins a function definition. Example:\n\n```python\ndef add(a, b):\n    return a + b\n```',
    'none': (
        '### What is None?\n\n`None` is Python’s special value representing the absence of '
        'a return value. It is not `0`, `False`, or the string `"None"`. '
        'Other languages sometimes use `null` for a similar concept, but '
        'the Python keyword is **`None`**.'
    ),
    'function': INTRO,
}

# We persist state in a *separate* SQLite table to preserve V44's existing
# lesson/progress database and never invent earlier mastery results.
class FunctionSessionStore:
    def __init__(self, folder):
        self.path = Path(folder) / 'tutor_functions_v45.sqlite3'
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with self._connect() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS sessions (
                conversation_id TEXT PRIMARY KEY, data TEXT NOT NULL,
                updated_at TEXT NOT NULL)''')
            db.execute('''CREATE TABLE IF NOT EXISTS verified_answers (
                conversation_id TEXT NOT NULL, question_id TEXT NOT NULL,
                is_correct INTEGER NOT NULL, detail TEXT NOT NULL,
                updated_at TEXT NOT NULL)''')

    @contextmanager
    def _connect(self):
        db = sqlite3.connect(str(self.path), timeout=10)
        try:
            db.execute('PRAGMA busy_timeout=10000')
            yield db
            db.commit()
        except BaseException:
            db.rollback()
            raise
        finally:
            db.close()

    def get(self, conv):
        if not conv: return None
        with self._connect() as db:
            row = db.execute('SELECT data FROM sessions WHERE conversation_id=?', (conv,)).fetchone()
        return json.loads(row[0]) if row else None

    def put(self, conv, state):
        if not conv:return
        now = datetime.now(timezone.utc).isoformat(timespec='seconds')
        with self._connect() as db:
            db.execute('''INSERT INTO sessions(conversation_id,data,updated_at)
                VALUES(?,?,?) ON CONFLICT(conversation_id)
                DO UPDATE SET data=excluded.data,updated_at=excluded.updated_at''',
                (conv, json.dumps(state, ensure_ascii=False, separators=(',',':')), now))
            db.commit()

    def add_result(self, conv, qid, correct, detail):
        now = datetime.now(timezone.utc).isoformat(timespec='seconds')
        with self._connect() as db:
            db.execute('INSERT INTO verified_answers VALUES(?,?,?,?,?)',
                       (conv, qid, int(bool(correct)), detail[:75], now))
            db.commit()

    def progress(self, conv):
        with self._connect() as db:
            rows = db.execute('''SELECT question_id,is_correct,detail FROM verified_answers
                                  WHERE conversation_id=? ORDER BY rowid''',(conv,)).fetchall()
        return [(str(r[0]),bool(r[1]),str(r[2])) for r in rows]


def _state():
    return {'topic':'Python Functions', 'stage':'ready','current':'', 'tries':0,
            'seen':[], 'misconceptions':{}, 'reviewed':[]}


def _compact(text):
    return re.sub(r'\s+', ' ',str(text or '').casefold()).strip()


def _wants_functions(text, selected_course):
    q=_compact(text)
    if re.search(r'\b(?:functions?|funcs?)\b',q):
        if re.search(r'(?<!\w)c\+\+(?!\w)|\b(?:javascript|java|cpp|visual basic|vba|vbnet)\b',q):
            return False
        return bool(re.search(r'\bpython\b',q) or selected_course == LESSON_COURSE
                    or re.search(r'\b(?:teach|learn|practice|practise|exercise|quiz|test|explain|start|show|need|about)\b',q))
    return False


def _other_topic(text):
    q=_compact(text)
    if re.search(r'(?<!\w)c\+\+(?!\w)|\b(bayes|probability|statistics|java|javascript|cpp|calculus|sql|database|requirements engineering|discrete mathematics)\b',q):
        return bool(re.search(r'\b(teach|explain|learn|study|show|switch|start|solve|what is)\b',q))
    # Another Python topic explicitly requested.
    if re.search(r'\b(?:teach|learn|switch to|start a lesson on)\b',q) and re.search(
            r'\b(?:variables?|lists?|tuples?|dictionaries|sets?|loops?|conditions?|classes|objects|recursion|algorithms|arrays)\b',q):
        return True
    return False


def _followup_term(text):
    q=_compact(text)
    if not re.search(r'\b(what|define|meaning|explain|tell|how|why|difference|between)\b',q):return None
    for term in ('parameter','argument','return','scope','def','none','function'):
        if re.search(r'\b'+term+r's?\b',q):return term
    return None


def _is_practice(text, mode):
    q=_compact(text)
    if re.search(r'\b(exercis\w*|practice|practise|quiz|test\s+me|new\s+question|another\s+question|give\s+me\s+(?:a|another)\s+question)\b',q):return True
    return mode=='Practice' and re.search(r'\b(?:functions?|funcs?)\b',q) is not None


def _is_resume(text):
    return re.fullmatch(r'(?:where were we|resume(?: lesson)?|what are we learning|what topic)(?:[?! .]*)',_compact(text)) is not None


def _is_next(text):
    return re.fullmatch(r'(?:next|next question|another|another one|continue|move on)(?:[.! ]*)',_compact(text)) is not None


def _is_hint(text):
    return re.fullmatch(r'(?:hint|help|i don.t know|not sure|give me a hint)(?:[.! ]*)',_compact(text)) is not None


def _is_reveal(text):
    return re.fullmatch(r'(?:skip|i give up|give up|show (?:me )?(?:the )?answer|reveal (?:the )?answer)(?:[.! ]*)',_compact(text)) is not None


def _is_retry(text):
    return re.fullmatch(r'(?:retry|retry question|try again|let me try again|repeat question)[.! ]*',_compact(text)) is not None


def _is_example(text):
    return re.fullmatch(r'(?:example|another example|show (?:me )?(?:another|an) example|give me an example)[.! ]*',_compact(text)) is not None


def _is_why(text):
    return re.fullmatch(r'(?:why|why is that|how so|explain why)[?! .]*',_compact(text)) is not None


def _is_restart(text):
    return re.fullmatch(r'(?:restart (?:the )?lesson|start over|start (?:the )?lesson again)(?:[.! ]*)',_compact(text)) is not None


def _negated(text, token):
    """Detect direct denial; avoid falsely grading 'not None' as None."""
    q = _compact(text).replace('’',"'")
    target = re.escape(token.casefold())
    return bool(re.search(r"\b(?:not|never|isn't|isnt|doesn't|doesnt|don't|dont|cannot|can't|cant|won't|wont)\b(?:\s+\w+){0,3}\s+"+target+r"\b",q))


def _answer_value(text, question):
    """Return correct, incorrect, or unknown with a misconception label.

    Unknown is never recorded as wrong or correct; tests privilege precision.
    """
    q = _compact(text).replace('`','').strip(' .!?;:')
    expected = question.answer.casefold()
    # Be conservative with mixed or contradictory statements.
    # Treat denials of the expected response as *wrong*, never right.
    if question.kind == 'none':
        if re.search(r'\bnone\b',q) and _negated(q,'none'):
            return ('incorrect','denies_none')
        if re.search(r'\b(?:null|nil)\b',q) and not re.search(r'\bnone\b',q):
            return ('incorrect','uses_null')
        if re.search(r'\b(?:0|zero)\b',q) and not re.search(r'\bnone\b',q):
            return ('incorrect','uses_zero')
        if re.fullmatch(r'(?:it |the function |the function call |the value )?(?:returns? |is |produces? |gives? )?(?:the value )?none',q):
            return ('correct','verified')
        if re.search(r'\b(?:returns?|produces?|gives?)\s+none\b',q) and not _negated(q,'none'):
            # Don't reward contradictory assertions or explicitly uncertain prose.
            if re.search(r'\b(?:maybe|perhaps|possibly|not sure|guess|might)\b',q):
                return ('unknown','uncertain_explanation')
            if re.search(r"\b(?:doesn't|doesnt|does not|never)\s+return\s+(?:anything|a value)\b",q):
                return ('unknown','contradictory_explanation')
            if re.search(r'\b(?:0|zero|null|false)\b',q) and not re.search(r'\bnot\s+(?:0|zero|null|false)\b',q):
                return ('unknown','ambiguous_explanation')
            return ('correct','verified')
        if re.fullmatch(r'(?:(?:it|the function)\s+)?(?:returns?\s+)?(?:0|zero)',q):
            return ('incorrect','uses_zero')
        if re.fullmatch(r'(?:(?:it|the function)\s+)?(?:returns?\s+)?(?:null|nil)',q):
            return ('incorrect','uses_null')
        if re.fullmatch(r'(?:false|empty string|nothing)',q):return ('incorrect','confuses_return')
        return ('unknown','ambiguous_explanation')

    if question.kind.startswith('keyword_'):
        if _negated(q,expected):return ('incorrect','denies_keyword')
        if re.fullmatch(r'(?:it |the keyword |the answer |you use |use |it is |keyword is )?'+re.escape(expected),q):
            return ('correct','verified')
        if re.fullmatch(r'(?:def|return|print|function|class|lambda)',q):return ('incorrect','other_keyword')
        return ('unknown','ambiguous_explanation')

    if question.kind == 'parameter':
        if _negated(q,'name'):return ('incorrect','denies_parameter')
        if re.fullmatch(r'(?:the parameter (?:is|called) |parameter is |it is |its |it.s )?name',q):return ('correct','verified')
        if re.fullmatch(r'(?:greet|tariro|argument)',q):return ('incorrect','argument_vs_parameter')
        return ('unknown','ambiguous_explanation')

    if question.kind == 'number':
        if _negated(q,expected):return ('incorrect','denies_value')
        if re.fullmatch(r'(?:the (?:answer|result|output|value) is |it (?:prints|returns|outputs) |prints |returns? )?'+re.escape(expected),q):
            return ('correct','verified')
        if re.fullmatch(r'(?:the (?:answer|result|output|value) is |it (?:prints|returns|outputs) |prints |returns? )?\d+(?:\.\d+)?',q):
            return ('incorrect','wrong_number')
        return ('unknown','ambiguous_explanation')

    if question.kind == 'name_error':
        if _negated(q,'nameerror'):return ('incorrect','denies_value')
        if re.fullmatch(r'(?:it (?:raises|causes) |the error is |error is |a |an )?name\s*error',q):return ('correct','verified')
        if re.fullmatch(r'(?:typeerror|syntaxerror|valueerror|attributeerror)',q):return ('incorrect','wrong_error')
        return ('unknown','ambiguous_explanation')

    if question.kind == 'two_outputs':
        # Only accept unambiguous order. Never assume the meaning of free prose.
        squashed=re.sub(r'[\s,;:\->]+',' ',q).strip()
        if re.fullmatch(r'hi (?:then )?none',squashed):return ('correct','verified')
        if re.fullmatch(r'none (?:then )?hi',squashed):return ('incorrect','reversed_print')
        return ('unknown','ambiguous_explanation')

    return ('unknown','unsupported_checker')


def _feedback(question, misconception, attempt):
    if misconception=='uses_zero':
        return ('Not quite. **0 is a number returned only when a function explicitly returns 0.** '
                'If no `return` executes, Python uses `None`.\n\n'
                '```python\ndef a():\n    print("Hi")\n\ndef b():\n    return 0\n\nprint(a())  # Hi, then None\nprint(b())  # 0\n```')
    if misconception=='uses_null':
        return ('Good connection to other programming languages. **`null` is not the Python keyword.** '
                'Python uses **`None`** for an absent return value. `None` is not the number 0.')
    if misconception=='denies_none':
        return ('The phrase **“does not return None”** is the opposite of what happens. '
                'A Python function that finishes without a `return` produces the value **`None`**.')
    if misconception in ('argument_vs_parameter','denies_parameter'):
        return ('Look at the function *definition*, not the call. The parameter is the name '
                'in `def greet(name):`; the argument is the value passed when calling `greet(...)`.')
    if misconception in ('wrong_number','denies_value'):
        return question.explanation + '\n\nUse the example to calculate the final value.'
    if misconception=='reversed_print':
        return 'Remember the order: a function prints from its body first; the calling code then prints the returned `None`.'
    return question.explanation


def _next_question(state):
    # Use unique IDs rather than repeating the first lesson question on every request.
    seen=list(state.get('seen') or [])
    for q in QUESTIONS:
        if q.id not in seen:
            state['seen']=seen+[q.id]
            state['current']=q.id
            state['tries']=0
            state['stage']='awaiting'
            return q
    # All available questions used; prevent accidental endless repetition.
    state['current']=''
    state['stage']='ready'
    return None


def _question_text(q, title='Practice'):
    return ('### '+title+' — '+q.concept.replace('-',' ').title()+'\n\n'
            +q.example+'\n\n**Question:** '+q.prompt+'\n\nReply with a short answer, type **hint**, '
            '**show answer**, or **another exercise**.\n\n'
            'Source: '+ORIGINAL_SOURCE)


def _session_progress(store, conv, state):
    items=store.progress(conv)
    correct=sum(ok for _,ok,_ in items)
    reviews=[qid for qid,ok,_ in items if not ok]
    return (f'### Python Functions — checked practice\n\n'
            f'**{correct}/{len(items)}** completed assessments correct. '
            f'**{len(state.get("seen",[]))}/{len(QUESTIONS)}** different exercises shown.'
            + ('\n\nTo revisit: '+', '.join(BY_ID[qid].concept.replace('-',' ') for qid in reviews if qid in BY_ID)+'.' if reviews else '')
            + '\n\nThese figures include only automatically checked answers, not a complete estimate of mastery.'
            + ('\n\nCurrent exercise: '+BY_ID[state['current']].prompt if state.get('stage')=='awaiting' and state.get('current') in BY_ID else ''))


def _sync_v44(folder, conv, source):
    """Remove stale V44 question so a switch to another course is safe."""
    if not conv:return
    try:
        from .learning_store_v44 import LearningStore
        db = LearningStore(Path(folder)/'tutor_learning_v44.sqlite3')
        db.put(conv, LESSON_COURSE, LESSON_TITLE, source, awaiting=False)
    except (sqlite3.Error, OSError):
        # V45 learning remains usable if the older store is temporarily locked.
        pass


def try_functions_v45(payload, entries):
    """Return a Python Functions reply, or None to delegate to the V44 tutor.

    No user text is executed, and unknown answers are not given mastery scores.
    """
    text=str(payload.get('question','')).strip()
    if not text:return None
    conv=str(payload.get('conversation_id',''))
    folder=Path(payload.get('store_dir') or Path.home()/'.campus-pop')
    selected_course=str(payload.get('course') or '')
    mode=str(payload.get('mode') or 'Explain')
    named_topic=_wants_functions(text,selected_course)
    # Don't create the V45 SQLite database just because an unrelated lesson
    # is being used. Existing V44 conversations remain completely unaffected.
    if not named_topic and not (folder/'tutor_functions_v45.sqlite3').exists():
        return None
    store=FunctionSessionStore(folder)
    state=store.get(conv)
    # Any clearly stated subject change pauses this specialized lesson. The
    # next question then reaches the ordinary V44 course router safely.
    subject_change = _other_topic(text) and not named_topic
    if not subject_change and state and not named_topic and selected_course not in ('', LESSON_COURSE):
        # A changed dropdown alone should not discard a pending answer. Only
        # pause when the message *also* requests a different lesson.
        lesson_command = re.search(r'\b(?:teach|learn|explain|study|switch to|start (?:a |the )?lesson)\b',_compact(text))
        local_followup = (_followup_term(text) is not None or
                          re.fullmatch(r'(?:explain again|explain it again|simpler|simplify|teach me again)[.! ]*',_compact(text)))
        if lesson_command and not local_followup:
            subject_change = True
    if subject_change:
        if state and state.get('stage') != 'inactive':
            state['stage'] = 'inactive'
            store.put(conv,state)
        return None
    if not state and not named_topic:
        return None
    if state and state.get('stage')=='inactive' and not named_topic:
        return None

    source_entry=next((e for e in entries if getattr(e,'course',None)==LESSON_COURSE
                       and getattr(e,'title',None)==LESSON_TITLE),None)
    if source_entry is None:
        return ('I cannot find the seeded **Python Programming — Functions and scope** lesson. '
                'Please restore the course library before starting this teaching module.') if named_topic else None
    source=f'{LESSON_COURSE} — {LESSON_TITLE} ({getattr(source_entry,"source","seeded course")})'

    if state is None:
        state=_state()
        _sync_v44(folder,conv,source)
        # Explicit exercises start with a question, not a lecture.
        if _is_practice(text,mode):
            question=_next_question(state)
            store.put(conv,state)
            return _question_text(question,'Python Functions practice')
        question=_next_question(state)
        store.put(conv,state)
        return INTRO+'\n\n---\n\n'+_question_text(question,'Check your understanding')

    if _is_restart(text):
        # Keep seen-question history and verified outcomes; reset the *lesson*.
        question=_next_question(state)
        store.put(conv,state)
        return INTRO + ('\n\n---\n\n'+_question_text(question,'Try a new question') if question else '\n\nAll available exercises were already shown. Use **my progress** for results.')

    if re.fullmatch(r'(?:my progress|how am i doing|my mastery|what have i learned)[?! .]*',_compact(text)):
        return _session_progress(store,conv,state)

    if _is_resume(text):
        if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
            return ('We’re studying **Python Functions** in Python Programming. '\
                    'You have an unfinished practice question:\n\n'+_question_text(BY_ID[state['current']],'Continue'))
        return 'We’re studying **Python Functions**. Ask for **another exercise**, **explain again**, or **next lesson**.'

    if re.fullmatch(r'(?:next lesson|move to next lesson)[.! ]*',_compact(text)):
        # Hand off to V44 by clearing the old question and temporarily making
        # the V44 stored lesson available; V44 handles the next seeded lesson.
        from .learning_store_v44 import LearningStore
        db=LearningStore(folder/'tutor_learning_v44.sqlite3')
        db.put(conv,LESSON_COURSE,LESSON_TITLE,source,awaiting=False)
        # Disable V45 routing for this same conversation on the next message by
        # setting topic to inactive. This call itself delegates to V44.
        state['stage']='inactive'
        store.put(conv,state)
        return None

    if state.get('stage')=='inactive':
        if not named_topic:
            return None
        state['stage']='ready'
        store.put(conv,state)

    # Follow-up questions do not interrupt an unfinished exercise.
    term=_followup_term(text)
    if term and not _is_practice(text,mode):
        reply=FOLLOWUPS[term]
        if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
            reply+='\n\n**Your pending question remains:** '+BY_ID[state['current']].prompt
        return reply+'\n\nSource: '+source+'; Campus Pop V45 original explanations.'

    if re.fullmatch(r'(?:explain again|explain it again|simpler|simplify|repeat the lesson|teach me again)[.! ]*',_compact(text)):
        if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
            return INTRO+'\n\n**Your pending question remains:** '+BY_ID[state['current']].prompt
        return INTRO

    # Explicitly asking for an exercise is a *command*, never the answer to the
    # preceding question. A new question must be different from all seen IDs.
    if _is_practice(text,mode) or _is_next(text):
        q=_next_question(state)
        store.put(conv,state)
        if q:return _question_text(q,'New Python Functions exercise')
        return ('You have worked through all '+str(len(QUESTIONS))+' available Python Functions exercises. '
                'I won’t repeat one as though it were new. Review **my progress** or start another topic.')

    if _is_retry(text):
        target = (state.get('current') if state.get('stage')=='awaiting' else
                  (state.get('reviewed') or [None])[-1])
        if target in BY_ID:
            state['current']=target
            state['stage']='awaiting'
            state['tries']=0
            store.put(conv,state)
            return _question_text(BY_ID[target],'Retry a question')
        return 'You have no earlier question marked for review. Type **practice** for a fresh exercise.'

    if _is_example(text):
        example=(
            '### Another example — display versus return\n\n'
            '```python\ndef wave():\n    print("Welcome")\n\n'
            'value = wave()\nprint(value)  # None\n```\n\n'
            '`wave()` prints **Welcome**, but because it does not return a value, '
            '`value` is **None**.'
        )
        if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
            example+='\n\n**Your pending question remains:** '+BY_ID[state['current']].prompt
        return example

    if _is_why(text):
        if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
            current=BY_ID[state['current']]
            return current.explanation+'\n\n**Your pending question remains:** '+current.prompt
        return ('A function result depends on the code executed: `return` sends a '
                'value back; without it the function returns `None`. Ask for an example or exercise.')

    if _is_hint(text):
        if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
            q=BY_ID[state['current']]
            return '### Hint\n\n'+q.hint+'\n\n**Try the question again:** '+q.prompt
        return 'There is no unanswered question. Type **practice** to start one.'

    if _is_reveal(text):
        if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
            q=BY_ID[state['current']]
            state['stage']='ready';state['current']='';state['tries']=0
            store.put(conv,state)
            return ('### Model answer — '+q.answer+'\n\n'+q.explanation+
                    '\n\nNo mastery score was awarded because you requested the answer.'+
                    '\n\nType **another exercise** to continue.')
        return 'There is no unanswered question. Type **practice** to start one.'

    if named_topic and re.search(r'\b(?:teach|learn|explain|lesson)\b',_compact(text)):
        return INTRO+ ('\n\n**Your pending question remains:** '+BY_ID[state['current']].prompt
                     if state.get('stage')=='awaiting' and state.get('current') in BY_ID else '\n\nType **practice** for a new question.')

    if state.get('stage')=='awaiting' and state.get('current') in BY_ID:
        q=BY_ID[state['current']]
        result,misconception=_answer_value(text,q)
        if result=='unknown':
            return ('I can’t grade that wording reliably, and **no score was recorded**. '
                    'Give a short, direct answer, or ask me to explain the concept.\n\n'
                    '**Question:** '+q.prompt)
        if result=='correct':
            store.add_result(conv,q.id,True,'verified')
            state['stage']='ready';state['current']='';state['tries']=0
            store.put(conv,state)
            return ('### Correct — '+q.answer+'\n\n'+q.explanation+
                    '\n\nThat verified answer has been recorded. Type **another exercise** for '
                    'a different question, or **my progress** for checked results.'+
                    '\n\nSource: '+ORIGINAL_SOURCE)
        state['tries']=int(state.get('tries',0))+1
        counts=state.setdefault('misconceptions',{})
        counts[misconception]=int(counts.get(misconception,0))+1
        detail=_feedback(q,misconception,state['tries'])
        if state['tries']<2:
            store.put(conv,state)
            return ('### Let’s correct that\n\n'+detail+
                    '\n\n**Try the same question again:** '+q.prompt)
        store.add_result(conv,q.id,False,misconception)
        state['stage']='ready';state['current']='';state['tries']=0
        state.setdefault('reviewed',[]).append(q.id)
        store.put(conv,state)
        return ('### Review needed\n\n'+detail+'\n\n**Model answer:** '+q.answer+
                '\n\nThis checked exercise was marked as needing review after two attempts. '
                'Now type **another exercise** to practise a different example; '
                'you can return to this concept later.')

    if state.get('stage')=='ready':
        if re.fullmatch(r'(?:hello|hi|hey)[!. ]*',_compact(text)):
            return 'Welcome back to Python Functions. Type **another exercise** when ready.'
        if re.search(r'\b(?:functions?|funcs?)\b',_compact(text)):
            return INTRO+'\n\nType **practice** for a new question.'
        # Unrecognized message shouldn't be falsely graded as an answer.
        return ('We’re currently studying Python Functions. '
                'Type **practice**, **explain again**, **my progress**, or **next lesson**. '
                'For an unrelated subject, name its course and topic explicitly.')
    return None
