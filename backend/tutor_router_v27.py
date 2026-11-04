"""Campus Pop v27: subject-aware, grounded query routing for the offline tutor.

This module does not generate information. It chooses the correct existing
course/reference corpus and delegates all answers to the tested local engine.
"""
from __future__ import annotations
import re
from .offline_engine import answer

# Keep 'javascript' before 'java' to avoid mistakenly matching JS questions.
SUBJECTS = (
    (re.compile(r'\b(?:javascript|ecmascript|node\.?js|js)\b', re.I), 'JavaScript'),
    (re.compile(r'\b(?:visual\s+basic|vb\.?net|vba|vb)\b', re.I), 'Visual Basic'),
    (re.compile(r'(?<!\w)c\+\+(?!\w)|\bcpp\b', re.I), 'C++'),
    (re.compile(r'\bpython\b', re.I), 'Python'),
    (re.compile(r'\bjava\b', re.I), 'Java'),
    (re.compile(r'\b(?:statistics|statistical|probability|regression|hypothesis|confidence\s+interval|bayes|binomial|normal\s+distribution|calculus)\b', re.I), 'Math & Statistics'),
)

PREFERRED = {
    'Python': 'Python Programming',
    'Math & Statistics': 'Applied Statistics',
}


def stated_subject(question: str) -> str:
    """Return a subject only if explicitly present in the user's question."""
    text = str(question or '')
    for pattern, subject in SUBJECTS:
        if pattern.search(text):
            return subject
    return ''


def resolve_course(question: str, selected_course: str, entries: list) -> tuple[str, bool]:
    """Explicit subject wins over the dropdown; otherwise respect the dropdown."""
    subject = stated_subject(question)
    if not subject:
        return selected_course, False
    preferred = PREFERRED.get(subject, '')
    if preferred and any(getattr(row, 'course', '').casefold() == preferred.casefold() for row in entries):
        return preferred, preferred.casefold() != (selected_course or '').casefold()
    # Non-seeded programming subjects are in the separately indexed open library.
    # Empty course removes the old dropdown's narrow course filter.
    return '', bool(selected_course)


def _word_root(word: str) -> str:
    word = word.casefold()
    if word.endswith('sses') and len(word) > 5:
        return word[:-2]
    if word.endswith('ies') and len(word) > 4:
        return word[:-3] + 'y'
    if word.endswith('s') and not word.endswith('ss') and len(word) > 4:
        return word[:-1]
    return word


# Conversation words are not evidence that an academic passage answers the question.
FILLER = set('a an and are as at be by can could do does example examples explain for from give how i in is it its just learn learning let lets me my of on one or please program programming question questions show solve step steps tell teach the this to understand using want what when where which why with would you your'.split())
SUBJECT_WORDS = set('python javascript ecmascript java js cpp visual basic vb net vba'.split())


def _relevant_candidates(entries: list, question: str, subject: str) -> list:
    """Avoid cross-language and generic-name matches masquerading as explanations."""
    expected_courses = {
        'Python': {'Python Programming', 'Open Library · Python'},
        'Java': {'Open Library · Java'},
        'JavaScript': {'Open Library · JavaScript'},
        'Visual Basic': {'Open Library · Visual Basic'},
        'C++': {'Open Library · C++'},
        'Math & Statistics': {'Applied Statistics', 'Discrete Mathematics', 'Open Library · Math & Statistics'},
    }.get(subject,set())
    domain = next((p for p, s in SUBJECTS if s == subject),None)
    candidates=[]
    for e in entries:
        e_course = str(getattr(e,'course',''))
        if e_course in expected_courses:
            candidates.append(e)
        elif e_course in ('My Notes','My Files') and domain is not None and domain.search(e.title+' '+e.body[:8000]):
            # Private notes may be used if they actually identify the named subject.
            candidates.append(e)
    words = re.findall(r'[a-zA-Z][a-zA-Z0-9]*', question.casefold())
    terms = {_word_root(w) for w in words if w not in FILLER and w not in SUBJECT_WORDS}
    if not terms:
        return candidates
    matches = []
    for entry in candidates:
        body = ' '.join(str(getattr(entry, name, '') or '') for name in ('title','objective','body','example','question'))
        body_words = {_word_root(w) for w in re.findall(r'[a-zA-Z][a-zA-Z0-9]*',body.casefold())}
        if not (terms & body_words):
            continue
        title_words = {_word_root(w) for w in re.findall(r'[a-zA-Z][a-zA-Z0-9]*',entry.title.casefold())}
        matches.append((bool(terms & title_words),entry))
    # Prefer a directly matching lesson title over a passing mention in a big
    # quick reference or a different course's generic notes.
    if any(t for t,entry in matches):
        return [entry for t,entry in matches if t]
    return [entry for _,entry in matches]


def answer_v27(question: str, course: str, mode: str, entries: list,
               allowed_courses=None, attachment: str='', strategy: str='worked example',
               profile_name: str='', program: str='', study_year: str='') -> str:
    effective, rerouted = resolve_course(question, course, entries)
    subject = stated_subject(question)

    # An explicitly requested subject must not be blocked by the user's enrolled
    # subjects or by an unrelated currently selected dropdown course.
    if subject:
        allowed_courses = None
        # Do not filter profile questions, greetings, or attached-file summaries.
        if not attachment and not re.search(r'\b(my courses|courses am i studying|my programme|my program|who am i|my username)\b',question,re.I):
            entries = _relevant_candidates(entries, question, subject)
    result = answer(question, effective, mode, entries, allowed_courses, attachment,
                    strategy, profile_name, program, study_year)
    # Small morphology mismatch in the legacy BM25 tokenizer: students may say
    # "function" while the lesson is called "Functions and scope". If a title
    # was already matched semantically by our strict gate, rerun retrieval with
    # that exact, verified title. This is retrieval, not answer generation.
    if (subject and entries and not attachment and
            result.startswith('I cannot find a reliable answer')):
        title = entries[0].title
        augmented = answer(question + ' ' + title, effective, mode, entries,
                           allowed_courses, attachment, strategy,
                           profile_name, program, study_year)
        if not augmented.startswith('I cannot find a reliable answer'):
            result = augmented

    # Do not add any routing banner to profile queries, greetings or file summaries.
    if not subject or not rerouted:
        return result
    if result.startswith('I cannot find a reliable answer'):
        label = PREFERRED.get(subject, subject)
        return (f'I recognised this as a {label} question, even though the selected '
                f'course was {course or "unspecified"}. I could not find a relevant '
                'passage in the currently indexed material. Open Resources → Open '
                'Knowledge Library → Sync Library, or import course notes. ' 
                'If Sync Library already ran, check the number of searchable passages. '
                'I will not invent an explanation.')
    if result.startswith(('Your saved Campus Pop username', 'Your enrolled courses',
                          'Saved programme:', 'Saved study level:','Hello!',
                          'English dictionary','English glossary')):
        return result
    return f'Course: {PREFERRED.get(subject, subject)} (detected from your question)\n\n{result}'
