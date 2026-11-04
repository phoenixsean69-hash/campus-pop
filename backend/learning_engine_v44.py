"""Campus Pop V44: verifiable, offline, stateful course tutoring.

This is a finite teaching controller, not a generative language model. Every
explanation is grounded in the seeded lesson, approved local notes, or an
original small instructional extension. Unanswerable questions are disclosed.
No Python code submitted by a user is executed.
"""
from __future__ import annotations
import ast
from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path
import re

from .learning_store_v44 import LearningStore
from .functions_tutor_v45 import try_functions_v45  # CAMPUS_POP_PYTHON_FUNCTIONS_V45
from .offline_engine import Entry, answer, define_english, extract_summary, ranked, _text_from_file
from .tutor_router_v27 import resolve_course, stated_subject, _relevant_candidates

# Short, original extensions tied to known lesson titles. They don't fabricate
# citations to external documents; each extension names the underlying lesson.
GUIDES = {
  ('Python Programming','Functions and scope'): {
    'definition': 'A function is a named block of instructions that runs when you call it. It can accept inputs called parameters and send a result back with `return`.',
    'why': 'Functions let you reuse logic instead of copying the same instructions throughout a program.',
    'example': '```python\ndef greet(name):\n    return "Hello, " + name\n\nmessage = greet("Tariro")\nprint(message)  # Hello, Tariro\n```',
    'plain': 'Imagine a small machine: you give it a name, it performs an action, and it hands back a greeting. `def` creates the machine; calling `greet(...)` uses it.',
    'practice': [
       ('What does a Python function return if no `return` statement executes?', 'None'),
       ('What keyword declares a function in Python?', 'def'),
    ],
  },
  ('Python Programming','Values, variables and types'): {
    'definition': 'A variable is a name that refers to a Python object. You do not need to declare the type in advance.',
    'why': 'Variables store information you can reuse, while types determine which operations make sense.',
    'example': '```python\nage = 20\nname = "Tariro"\nprint(type(age))   # <class \'int\'>\nprint(type(name))  # <class \'str\'>\n```',
    'plain': 'Think of a variable as a label attached to a value. `age` is a name pointing to the number 20, not a storage box with a permanent type.',
    'practice': [('What is the type of `input("Age: ")` before conversion?', 'str')],
  },
  ('Python Programming','Conditions and loops'): {
    'definition': '`if`, `elif` and `else` choose between branches. `for` and `while` repeat work.',
    'why': 'Programs need to decide which actions to perform and repeat them without manually writing every step.',
    'example': '```python\nfor n in range(1, 6, 2):\n    print(n)\n# 1, 3, 5\n```',
    'plain': 'A condition is a decision. A loop is a repeated instruction. `range` tells a `for` loop which values to visit.',
    'practice': [('What numbers are produced by `range(1, 6, 2)`?', '1, 3 and 5')],
  },
  ('Python Programming','Lists, tuples, sets and dictionaries'): {
    'definition': 'Lists and tuples hold ordered values; sets keep unique items; dictionaries map keys to values.',
    'why': 'Choosing the right collection makes code easier to read and data easier to retrieve.',
    'example': '```python\ncourses = {"CSC203": "Python Programming"}\nprint(courses["CSC203"])\n```',
    'plain': 'A list is a sequence, a tuple is an unchangeable sequence, a set removes duplicates, and a dictionary pairs keys with values.',
    'practice': [('Which collection maps a course code to its title?', 'dictionary')],
  },
  ('Applied Statistics','Conditional probability and Bayes'): {
    'definition': 'Conditional probability describes the chance of one event given another. Bayes’ theorem reverses the condition using prior information.',
    'why': 'It helps interpret test results where the base rate matters, such as when a positive result is not the same as the probability of having a condition.',
    'example': 'If 1% of people have a condition, a test detects 90% of cases, and falsely tests positive in 10% of people without it, then among 10,000 people: 90 true positives and 990 false positives. Thus P(condition | positive) = 90 / (90 + 990) ≈ 8.3%.',
    'plain': 'Bayes’ theorem asks: after we see evidence, how much should we change our earlier estimate? A rare condition may still be unlikely after a positive test.',
    'practice': [('Does a test with 90% sensitivity mean a positive result gives a 90% chance of having the condition?', 'No; prevalence and false-positive rates matter.')],
  },
  ('Applied Statistics','Descriptive statistics'): {
    'definition': 'Descriptive statistics summarizes a dataset using measures such as mean, median, range and standard deviation.',
    'why': 'Summaries let you describe a large group of measurements without listing every value.',
    'example': 'For 2, 3, 4, 5, 100: the mean is 22.8, but the median is 4. The extreme value pulls the mean upward.',
    'plain': 'The mean is the arithmetic average. The median is the middle value when the observations are ordered.',
    'practice': [('Which measure of center is usually more robust to an extreme value?', 'median')],
  },
}

SUBTOPICS = {
  ('Python Programming','Functions and scope'): {
    'parameter': ('A **parameter** is a name listed in a function definition; it receives the input sent when you call the function.',
                  '```python\ndef double(number):  # number is a parameter\n    return number * 2\nprint(double(5))    # 5 is the argument\n```'),
    'argument': ('An **argument** is the actual value passed into a function when you call it. A **parameter** is the name that receives it.',
                 '```python\ndef greet(name):  # parameter\n    return "Hello, " + name\nprint(greet("Rudo"))  # argument\n```'),
    'return': ('`return` ends a function call and sends a value back. A function that finishes without returning explicitly produces `None`.',
               '```python\ndef square(x):\n    return x * x\nprint(square(4))  # 16\n```'),
    'scope': ('Scope describes where a variable name can be accessed. A name assigned inside a function is normally local to that function.',
              '```python\ndef show():\n    message = "hello"  # local to show\n    print(message)\nshow()\n```'),
    'def': ('`def` starts a Python function definition. Put its parameters inside parentheses, then indent the function body.',
            '```python\ndef add(a, b):\n    return a + b\n```'),
  },
}


def _subtopic_explanation(q, entry):
    choices=SUBTOPICS.get((entry.course,entry.title),{})
    for term,(definition,example) in choices.items():
        if re.search(r'\b'+re.escape(term)+r'\b',q,re.I):
            return ('### '+term.capitalize()+' — '+entry.title+'\n\n'+definition+
                    '\n\nExample:\n'+example+'\n\nSource: '+_source(entry))
    return None

FILLER = {'what','which','explain','teach','tell','show','give','can','could','me',
          'lets','let','learn','learning','about','the','of','this','that','it',
          'please','course','topic','chapter','lesson','example','examples','my','how','why'}


def _roots(value):
    words = re.findall(r'[a-zA-Z][a-zA-Z0-9]*',str(value).casefold())
    result=[]
    for w in words:
        if w in FILLER:continue
        if len(w)>4 and w.endswith('ies'):w=w[:-3]+'y'
        elif len(w)>4 and w.endswith('s') and not w.endswith('ss'):w=w[:-1]
        result.append(w)
    return result


def _chosen_entry(question, course, corpus, state, allowed):
    # Conversation commands without a new explicit topic reuse the saved lesson.
    subject = stated_subject(question)
    chosen_course,_ = resolve_course(question, course, corpus)
    if subject:
        candidates = _relevant_candidates(corpus,question,subject)
    else:
        candidates=[e for e in corpus if e.course == chosen_course]
        if not candidates:
            candidates=[e for e in corpus if e.course in (allowed or [])]
    if subject and not candidates:
        return None
    query_terms=set(_roots(question))
    # References in a title are substantially more trustworthy than one match
    # somewhere in a long reference passage.
    scored=[]
    for e in candidates:
        title_terms=set(_roots(e.title))
        passage_terms=set(_roots(e.objective+' '+e.body[:2200]+' '+e.question))
        matched_title=query_terms & title_terms
        non_subject={t for t in query_terms if t not in {'python','java','javascript','statistics','statistic','math','cpp','visual','basic','software','engineering','computer','system','database','discrete','applied','programming'}}
        if not matched_title and not (non_subject & passage_terms):continue
        if not non_subject and subject:continue
        score=len(non_subject & title_terms)*10+len(non_subject & passage_terms)
        if e.course == chosen_course:score+=2
        if e.course.startswith('Open Library'):score-=1
        scored.append((score,e))
    if scored:
        scored.sort(key=lambda pair:-pair[0])
        return scored[0][1]
    # Use saved state only for deictic or explicit follow-up requests, not
    # because the query happens to be unrelated to the current dropdown.
    if state and re.search(r'\b(it|that|again|another|continue|next|hint|quiz|practice)\b',question,re.I):
        return next((e for e in corpus if e.course==state['course'] and e.title==state['title']),None)
    return None


def _source(entry):
    # This label identifies the actual retrieved source and its title.
    return f'{entry.course} — {entry.title} ({entry.source})'


def _practice_items(entry):
    guide=GUIDES.get((entry.course,entry.title),{})
    items=list(guide.get('practice', []))
    if entry.question and not any(q.casefold()==entry.question.casefold() for q,_ in items):
        items.append((entry.question,entry.answer))
    return items


def _explain(entry, level='Step by step', simpler=False, example_only=False, include_question=True):
    guide=GUIDES.get((entry.course,entry.title),{})
    if example_only:
        ex=guide.get('example') or entry.example
        return ('### '+entry.title+' — Example\n\n'+(ex or 'There is no worked example in this lesson yet.')+
                '\n\nSource: '+_source(entry))
    if simpler:
        content=guide.get('plain') or (entry.body.split('. ')[0].strip()+'.')
        body='### '+entry.title+' — Simpler explanation\n\n'+content
        if guide.get('example'):body+='\n\nExample:\n'+guide['example']
        return body+'\n\nSource: '+_source(entry)
    definition=guide.get('definition') or (entry.body or entry.objective)
    if not definition:
        return 'I found this topic, but its lesson text is empty. Source: '+_source(entry)
    introduction='### '+entry.title+'\n\n**Main idea:** '+definition.strip()
    if guide.get('why'):
        introduction+='\n\n**Why it matters:** '+guide['why']
    elif entry.objective:
        introduction+='\n\nLearning objective: '+entry.objective
    if entry.body and (entry.course,entry.title) not in GUIDES and entry.body.strip()!=definition.strip():
        introduction+='\n\n'+entry.body[:1200].strip()
    example=guide.get('example') or entry.example
    if example:
        introduction+='\n\nExample:\n'+example.strip()
    if include_question:
        questions=_practice_items(entry)
        if questions:
            introduction+='\n\nTry this:\n'+questions[0][0]
            introduction+='\n\nReply with your answer, or type **hint**. We’ll check it before moving on.'
    introduction+='\n\nSource: '+_source(entry)
    return introduction


def _is_answer_request(q):
    return re.search(r'\b(show|reveal|give|tell)\s+(?:me\s+)?(?:the\s+)?(?:correct\s+)?answer\b',q,re.I)


def _check_known(entry, response, expected):
    """1 correct, 0 incorrect, or None when no defensible automatic checker exists."""
    text=re.sub(r'\s+',' ',response.casefold()).strip(' .!?')
    key=(entry.course,entry.title)
    if key==('Python Programming','Functions and scope'):
        if expected.lower()=='def':return int(bool(re.search(r'\bdef\b',text)))
        if re.search(r'\bnone\b',text):return 1
        if re.search(r'\b(0|empty string|false|null)\b',text):return 0
        return None
    tests={
     ('Python Programming','Values, variables and types'):(r'\b(str|string)\b',r'\b(int|integer|float|boolean|bool)\b'),
     ('Python Programming','Lists, tuples, sets and dictionaries'):(r'\bdictionar(?:y|ies)\b|\bdict\b',r'\b(list|tuple|set)\b'),
     ('Applied Statistics','Descriptive statistics'):(r'\bmedian\b',r'\bmean\b|\bmode\b'),
     ('Applied Statistics','Discrete distributions'):(r'\b3\.5\b',r'\b[1245689](?:\.0)?\b'),
     ('Discrete Mathematics','Sets and operations'):(r'\b32\b',r'\b(5|10|16|64)\b'),
     ('Discrete Mathematics','Counting and combinatorics'):(r'\b10\b',r'\b(5|20|25)\b'),
     ('Discrete Mathematics','Graphs and trees'):(r'\b11\b',r'\b(10|12|13)\b'),
     ('Database Systems','SQL SELECT and filtering'):(r'\bis\s+null\b',r'\b=\s*null\b'),
    }
    if key==('Python Programming','Conditions and loops'):
        digits=re.findall(r'(?<!\w)\d+(?!\w)',text)
        if digits:return int(digits==['1','3','5'])
        return None
    if key not in tests:return None
    yes,no=tests[key]
    has_yes=bool(re.search(yes,text))
    has_no=bool(re.search(no,text))
    if has_yes and not has_no:return 1
    if has_no and not has_yes:return 0
    return None


def _question_reply(q, entry, state, db, conversation_id):
    prompt=state['question']
    expected=state['answer']
    tries=int(state['tries'])
    if _is_answer_request(q) or re.fullmatch(r'(skip|i give up|give up)',q.casefold().strip(' .!?')):
        db.put(conversation_id,entry.course,entry.title,entry.source,sequence=state['sequence'])
        return ('### Model answer\n\n'+expected+'\n\nThis answer comes from the lesson, not from automatically grading your reply.'
                '\n\nType **next** to continue or **quiz me** to try another question.'
                '\n\nSource: '+_source(entry))
    if re.fullmatch(r'(hint|help|i don.t know|not sure)',q.casefold().strip()):
        hint=GUIDES.get((entry.course,entry.title),{}).get('plain') or entry.objective or entry.body[:170]
        return 'Hint: '+hint+'\n\nTry the question again:\n'+prompt
    grade=_check_known(entry,q,expected)
    if grade is None:
        db.put(conversation_id,entry.course,entry.title,entry.source,sequence=state['sequence'])
        return ('### Compare with the lesson answer\n\n**Your response:** '+q[:550]+
                '\n\n**Model answer:** '+expected+
                '\n\nI cannot reliably grade that response using the current rules, so I have not changed your mastery score.'+
                '\n\nSource: '+_source(entry)+'\n\nType **next** to continue.')
    if grade:
        db.record_checked(entry.course,entry.title,True)
        db.put(conversation_id,entry.course,entry.title,entry.source,sequence=state['sequence'])
        return ('### Correct\n\n'+expected+'\n\nThat answer has been recorded in your lesson progress.'+
                '\n\nType **next** to continue, or **quiz me** for another question.'+
                '\n\nSource: '+_source(entry))
    tries+=1
    if tries<2:
        db.put(conversation_id,entry.course,entry.title,entry.source,question=prompt,answer=expected,
               tries=tries,awaiting=True,sequence=state['sequence'])
        hint=GUIDES.get((entry.course,entry.title),{}).get('plain') or entry.objective or entry.body[:170]
        return 'Not quite. Here is a hint:\n\n'+hint+'\n\nTry once more:\n'+prompt
    db.record_checked(entry.course,entry.title,False)
    db.put(conversation_id,entry.course,entry.title,entry.source,sequence=state['sequence'])
    return ('### Review the answer\n\n**Expected:** '+expected+
            '\n\nReview the lesson, then try another question. The attempt was recorded as needing review.'+
            '\n\nSource: '+_source(entry))


def _safe_ast_python(q):
    if not re.search(r'\b(check|debug|review|fix|syntax)\b.*\b(code|python|program|script)\b|\bcode\b.*\b(error|wrong|why)',q,re.I|re.S):
        return None
    match=re.search(r'```(?:python)?\s*\n(.*?)\n```',q,re.I|re.S)
    if match:code=match.group(1)
    elif '\n' in q:code=q.split('\n',1)[1]
    else:return 'Paste a Python code block in triple backticks so I can check its **syntax** without running it.'
    if not code.strip():return 'There is no code to inspect.'
    if len(code)>12000:return 'Please provide a shorter Python snippet (up to 12,000 characters).'
    try:tree=ast.parse(code)
    except SyntaxError as e:
        return f'### Python syntax check\n\n**Syntax error near line {e.lineno}:** {e.msg}.\n\nI only parsed the code; it was not executed.'
    counts={t:sum(isinstance(n,t) for n in ast.walk(tree)) for t in (ast.FunctionDef,ast.For,ast.While,ast.If,ast.ClassDef)}
    details=[]
    if counts[ast.FunctionDef]:details.append(f'{counts[ast.FunctionDef]} function definition(s)')
    if counts[ast.ClassDef]:details.append(f'{counts[ast.ClassDef]} class definition(s)')
    if counts[ast.For] or counts[ast.While]:details.append(f'{counts[ast.For]+counts[ast.While]} loop(s)')
    if counts[ast.If]:details.append(f'{counts[ast.If]} conditional(s)')
    return ('### Python syntax check\n\nThe snippet **parses successfully**.'+
            (' It contains '+', '.join(details)+'.' if details else '')+
            '\n\n**Limitation:** Syntax correctness does not prove the program behaves correctly. The code was not executed.')


@dataclass(frozen=True)
class Affine:
    x: Fraction
    b: Fraction


def _linear_ast(node):
    if isinstance(node,ast.Constant) and type(node.value) in (int,float):
        val=Fraction(str(node.value))
        if abs(val)>1000000:raise ValueError('Number too large for this exercise')
        return Affine(Fraction(0),val)
    if isinstance(node,ast.Name) and node.id=='x':return Affine(Fraction(1),Fraction(0))
    if isinstance(node,ast.UnaryOp) and isinstance(node.op,(ast.USub,ast.UAdd)):
        a=_linear_ast(node.operand)
        return Affine(-a.x,-a.b) if isinstance(node.op,ast.USub) else a
    if isinstance(node,ast.BinOp) and isinstance(node.op,(ast.Add,ast.Sub,ast.Mult,ast.Div)):
        a=_linear_ast(node.left);b=_linear_ast(node.right)
        if isinstance(node.op,ast.Add):return Affine(a.x+b.x,a.b+b.b)
        if isinstance(node.op,ast.Sub):return Affine(a.x-b.x,a.b-b.b)
        if isinstance(node.op,ast.Mult):
            if a.x and b.x:raise ValueError('Non-linear equation')
            return Affine(a.x*b.b+b.x*a.b,a.b*b.b)
        if b.x or b.b==0:raise ValueError('Variable or zero denominator')
        return Affine(a.x/b.b,a.b/b.b)
    raise ValueError('Unsupported expression')


def _solve_linear(q):
    if not re.search(r'\b(solve|find x|find the value of x)\b',q,re.I) or '=' not in q:return None
    match=re.search(r'([+\-\d\.\s*/()xX]+)=([+\-\d\.\s*/()xX]+)',q)
    if not match:return 'I can currently solve simple one-variable linear equations written like `2x + 3 = 11`.'
    try:
        left,right=[part.strip().replace('X','x') for part in match.groups()]
        if not left or not right:raise ValueError('Missing side')
        def parse(side):
            side=re.sub(r'(?<=\d)(?=x)', '*',side)
            side=re.sub(r'(?<=\d)(?=\()', '*',side)
            side=re.sub(r'(?<=\))(?=x)', '*',side)
            return _linear_ast(ast.parse(side, mode='eval').body)
        a=parse(left);b=parse(right)
        coefficient=a.x-b.x;constant=b.b-a.b
        if not coefficient:
            if constant==0:return '### Equation\n\nEvery value of `x` satisfies this identity.'
            return '### Equation\n\nThere is no solution: the constant terms are inconsistent.'
        result=constant/coefficient
        return ('### Solve for x\n\nGiven: `'+left+' = '+right+'`'+
                '\n\n1. Collect variable terms: `'+str(coefficient)+'x = '+str(constant)+'`.'+
                '\n2. Divide both sides by `'+str(coefficient)+'`.'+
                '\n3. **x = '+str(result)+'**'+
                '\n\nMethod: exact fraction arithmetic; no arbitrary code execution.')
    except (SyntaxError,ValueError,OverflowError,ZeroDivisionError):
        return 'I can solve basic **linear** equations in `x`, such as `2x + 3 = 11`. I cannot verify this equation with the current safe solver.'


def _lesson_progress(db,course):
    data=db.progress(course)
    if not data:return ('There are no automatically checked answers recorded for this course yet. '
                       'Start a lesson and complete a practice question.')
    attempts=sum(r['attempts'] for r in data);correct=sum(r['correct'] for r in data)
    return (f'Checked practice in {course}: {correct}/{attempts} correct across {len(data)} topics. '+
            'This reflects checked exercises only, not a full measure of understanding.')


def teach_v44(payload:dict,entries:list[Entry]):
    q=str(payload.get('question','')).strip()
    course=str(payload.get('course','')).strip()
    mode=str(payload.get('mode','Explain'))
    conv=str(payload.get('conversation_id',''))
    directory=Path(payload.get('store_dir') or Path.home()/'.campus-pop')
    db=LearningStore(directory/'tutor_learning_v44.sqlite3')
    state=db.get(conv)
    allowed=payload.get('courses') or []
    if not q and not payload.get('attachment'):
        return 'Choose a lesson topic or ask a study question.'
    # These quick facts still use the original profile/dictionary path.
    if (re.search(r'\b(who am i|my username|what is my name|my courses|courses am i studying|my programme|my program|my level|year of study)\b',q,re.I)
        or re.fullmatch(r'(hello|hi|hey|good morning|good evening)[!. ]*',q.lower())
        or re.search(r'^\s*(define|definition of|meaning of|synonym|antonym)\b',q,re.I)):
        return answer(q,course,mode,entries,allowed,profile_name=payload.get('profile_name',''),
                      program=payload.get('program',''),study_year=payload.get('study_year',''))
    if payload.get('attachment'):
        return answer(q,course,mode,entries,allowed,attachment=payload.get('attachment',''))
    check=_safe_ast_python(q)
    if check is not None:return check
    solve=_solve_linear(q)
    if solve is not None:return solve
    # Dedicated, deliberately bounded Python Functions lesson.
    v45_reply = try_functions_v45(payload,entries)
    if v45_reply is not None:return v45_reply
    if re.search(r'\b(my progress|how am i doing|mastery|what have i learned)\b',q,re.I):
        return _lesson_progress(db,state['course'] if state else course)
    # Follow-up explanations retain the pending exercise and its stored topic.
    if state and re.search(r'\b(?:what (?:is|are|does)|why|how|could you explain|what do you mean)\b',q,re.I):
        active=next((e for e in entries if e.course==state['course'] and e.title==state['title']),None)
        if active:
            detail=_subtopic_explanation(q,active)
            if detail:
                if state['awaiting']:
                    detail+='\n\nYour pending question remains:\n'+state['question']
                return detail
            if re.fullmatch(r'(why|how|why is that|what do you mean|could you explain that)[?! .]*',q,re.I):
                return _explain(active,simpler=True,include_question=False)
    # If a question is waiting, do not mistake a short answer for a new lesson.
    new_request = bool(re.search(r'\b(?:let.s learn|start|teach me|new topic|switch to|next|continue|quiz me|test me|another question|what topic|where were we|resume lesson)\b',q,re.I)
                       or (stated_subject(q) and re.search(r'\b(?:explain|define|teach|learn|what is|show)\b',q,re.I)))
    if state and state['awaiting'] and not new_request:
        active=next((e for e in entries if e.course==state['course'] and e.title==state['title']),None)
        if active:
            if re.search(r'\b(again|explain|simpler|example)\b',q,re.I):
                return _explain(active,simpler=not bool(re.search(r'example',q,re.I)),example_only=bool(re.search(r'example',q,re.I)),include_question=False)+'\n\nYour pending question is still:\n'+state['question']
            return _question_reply(q,active,state,db,conv)
    if re.fullmatch(r'(next|next lesson|continue|move on|next topic)[.! ]*',q,re.I):
        if not state:return 'Choose a course topic first, then I can guide you through its lessons.'
        matching=[e for e in entries if e.course==state['course'] and re.search(r'Lesson \d+',e.source)]
        idx=next((i for i,e in enumerate(matching) if e.title==state['title']),-1)
        if idx<0 or idx+1>=len(matching):return 'That is the last available seeded lesson for '+state['course']+'. Pick another course or topic.'
        nxt=matching[idx+1]
        questions=_practice_items(nxt)
        pending=questions[0] if questions else ('','')
        db.put(conv,nxt.course,nxt.title,nxt.source,*pending,awaiting=bool(pending[0]))
        return _explain(nxt)
    if state and re.fullmatch(r'(another example|show another example|explain again|simpler|simplify|show example)[.! ]*',q,re.I):
        active=next((e for e in entries if e.course==state['course'] and e.title==state['title']),None)
        if active:return _explain(active,simpler=bool(re.search(r'simpl|again',q,re.I)),example_only=bool(re.search('example',q,re.I)),include_question=False)
    if state and _is_answer_request(q):
        active=next((e for e in entries if e.course==state['course'] and e.title==state['title']),None)
        if active:
            questions=_practice_items(active)
            if questions:
                i=min(int(state['sequence']),len(questions)-1)
                return '### Model answer\n\n'+questions[i][1]+'\n\nSource: '+_source(active)
    # Continued practice uses the current topic unless a new topic was named.
    if state and re.fullmatch(r'(quiz me|test me|practice|another question|question)[.! ]*',q,re.I):
        active=next((e for e in entries if e.course==state['course'] and e.title==state['title']),None)
        if active:
            questions=_practice_items(active)
            if not questions:return 'There is no verified practice question for this topic yet.'
            i=min(int(state['sequence'])+1,len(questions)-1)
            prompt,expected=questions[i]
            db.put(conv,active.course,active.title,active.source,prompt,expected,awaiting=True,sequence=i)
            return ('### Practice — '+active.title+'\n\nTry this:\n'+prompt+'\n\nReply with your answer or type **hint**.'+
                    '\n\nSource: '+_source(active))
    if state and re.fullmatch(r'(what are we learning|what topic|where were we|resume lesson)[.!? ]*',q,re.I):
        return ('We are studying **'+state['title']+'** in '+state['course']+'. '+
                ('Your practice question is still open:\n'+state['question'] if state['awaiting'] else 'Ask for an example, a quiz or the next lesson.'))
    active=_chosen_entry(q,course,entries,state,allowed)
    if not active:
        return ('I cannot locate a reliable lesson for that topic in your current course materials. '
                'Try naming the course and topic, selecting the correct course, or adding study notes. '
                'I will not invent an explanation.')
    if re.search(r'\b(?:summary|summari[sz]e|key points)\b',q,re.I) or mode=='Summarise':
        db.put(conv,active.course,active.title,active.source)
        return ('### '+active.title+' — Key points\n\n'+extract_summary(active.body+' '+active.example,4)+
                '\n\nSource: '+_source(active))
    if re.search(r'\b(?:example|show me code|demonstrate)\b',q,re.I) and not re.search(r'\b(?:teach|learn|lesson)\b',q,re.I):
        db.put(conv,active.course,active.title,active.source)
        return _explain(active,example_only=True)
    questions=_practice_items(active)
    pending=questions[0] if questions else ('','')
    db.put(conv,active.course,active.title,active.source,*pending,awaiting=bool(pending[0]))
    if mode=='Practice' or re.search(r'\b(quiz|test me|practice)\b',q,re.I):
        if not questions:return 'No verified practice question is available for '+active.title+'.'
        return ('### Practice — '+active.title+'\n\nTry this:\n'+pending[0]+
                '\n\nReply with your answer or type **hint**.\n\nSource: '+_source(active))
    return _explain(active,payload.get('study_level','Step by step'))
