"""Campus Pop V46.1: bounded, offline NumPy-backed tutoring prototype.

Important: This is NOT a pretrained LLM. NumPy ranks human-reviewed lessons;
a small, explicitly documented dialogue policy handles follow-up requests.
No open-ended answers are graded and no student mastery is recorded.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import numpy as np

DATA = Path(__file__).with_name("knowledge.json")


def words(text: str) -> list[str]:
    return re.findall(r"[a-zA-Z_][a-zA-Z_0-9]*", text.lower())


REPAIRED_TERMS: dict[str, str] = {
    "def": (
        "def: a Python keyword meaning 'I'm defining a function'. "
        "It starts the function's definition; it doesn't run the instructions yet."
    ),
    "parentheses": (
        "Parentheses (): the round symbols after the function's name. "
        "They hold inputs when a function needs them. Empty () means no inputs are supplied."
    ),
    "colon": (
        "Colon (:): marks the start of the indented block of instructions "
        "belonging to the function."
    ),
    "indentation": (
        "Indentation: spaces at the start of a line. In Python, they show "
        "which instructions belong inside the function. Four spaces is a common convention."
    ),
    "function_name": (
        "Function name: the label you choose, such as greet, so you can run the steps later."
    ),
}


def mentioned_terms(message: str) -> list[str]:
    patterns = {
        "def": r"\bdef\b",
        "parentheses": r"\b(parentheses|parenthesis|round brackets|round bracket)\b",
        "colon": r"\bcolons?\b|(?<!:)\bcolon\b",
        "indentation": r"\b(indent|indentation|indented|spaces at the start)\b",
        "function_name": r"\bfunction name\b",
    }
    return [key for key, pattern in patterns.items() if re.search(pattern, message, re.I)]


BEGINNER_RE = re.compile(
    r"\b(beginner|new to (?:programming|python)|first time|simple|simpler|"
    r"easy|easier|confused|lost|don't understand|dont understand|do not understand|"
    r"i don't get|i dont get|explain (?:that|it) again|explain (?:that|it) like|"
    r"break (?:it|that) down|step by step)\b", re.I
)

FOLLOWUP_RE = re.compile(
    r"\b(it|that|this|those|them|again|still|same thing|another|"
    r"not clear|more detail|simpler|confused|example)\b", re.I
)

NON_FUNCTION_SUBJECT_RE = re.compile(
    r"\b(lists?|tuples?|dictionaries|sets|loops?|while|for loop|classes|files?|"
    r"dataframes?|arrays?)\b", re.I
)


class OfflineTutor:
    """Grounded teaching with stateful, limited linguistic repair.

    This layer can explain known definitions and distinguish obvious intents;
    it does not claim free-form semantic understanding or automatic grading.
    """

    def __init__(self, source=DATA):
        self.lessons = json.loads(Path(source).read_text(encoding="utf-8"))
        self.docs = [
            item["title"] + " " + " ".join(item["keywords"]) + " " + item["summary"]
            for item in self.lessons
        ]
        self.vocab = sorted(set(token for doc in self.docs for token in words(doc)))
        self.term_to_col = {word: i for i, word in enumerate(self.vocab)}
        tf = np.zeros((len(self.docs), len(self.vocab)), dtype=np.float32)
        for i, doc in enumerate(self.docs):
            for token in words(doc):
                tf[i, self.term_to_col[token]] += 1
        df = (tf > 0).sum(axis=0)
        self.idf = np.log((len(self.docs) + 1) / (df + 1)) + 1
        self.index = self._normalize(tf * self.idf)
        self.last_topic = None
        self.turn_count = 0
        self.previous_message = None
        self.last_offer = None

    @staticmethod
    def _normalize(values):
        return values / np.maximum(np.linalg.norm(values, axis=-1, keepdims=True), 1e-8)

    def retrieve(self, message):
        vec = np.zeros((1, len(self.vocab)), dtype=np.float32)
        for token in words(message):
            if token in self.term_to_col:
                vec[0, self.term_to_col[token]] += 1
        if not np.any(vec):
            return None, 0.0
        vec = self._normalize(vec * self.idf)
        scores = self.index @ vec[0]
        index = int(np.argmax(scores))
        return (self.lessons[index], float(scores[index])) if scores[index] > .10 else (None, 0.0)

    @staticmethod
    def _is_parameter_topic(message):
        return bool(re.search(r"\b(parameters?|arguments?)\b", message, re.I))

    @staticmethod
    def _is_return_topic(message):
        return bool(re.search(r"\b(return|returns|returning)\b", message, re.I))

    @staticmethod
    def _is_call_topic(message):
        return bool(re.search(r"\b(calling|call|invok(?:e|ing)|execut(?:e|ing))\b", message, re.I))

    def _lesson_by_title(self, prefix):
        return next((x for x in self.lessons if x["title"].lower().startswith(prefix)), None)

    def _select_lesson(self, message, followup):
        if self._is_parameter_topic(message):
            return self._lesson_by_title("parameters")
        if self._is_return_topic(message):
            return self._lesson_by_title("returning")
        if self._is_call_topic(message):
            return self._lesson_by_title("calling")
        if mentioned_terms(message):
            return self._lesson_by_title("defining")
        if followup and self.last_topic is not None:
            return self.last_topic
        if re.search(r"\bfunctions?\b", message, re.I):
            return self._lesson_by_title("defining")
        # Restrict fuzzy retrieval to messages with an explicit lesson vocabulary cue.
        # A generic question such as 'how do I make a list?' must not return functions.
        cue = re.search(r"\b(reusable|python def|greet\(\)|return value)\b", message, re.I)
        if cue:
            lesson, _ = self.retrieve(message)
            return lesson
        return None

    @staticmethod
    def _fundamentals(terms: list[str], beginner: bool) -> str:
        opening = (
            "A function is like giving a short recipe a name. You write the steps once "
            "and ask Python to follow them whenever you need them."
            if beginner else
            "Let's unpack the syntax rather than repeating the whole lesson."
        )
        intro = (
            "Here's a small example:\n\n"
            "def greet():\n"
            "    print('Hello')\n\n"
            "greet()\n\n"
            "The first two lines define the steps. The last line runs them."
        )
        details = "\n".join(f"- {REPAIRED_TERMS[term]}" for term in terms)
        return (
            f"{opening}\n\n{intro}\n\n"
            f"The parts you asked about:\n{details}\n\n"
            "Would you like me to walk through the example line by line?"
        )

    @staticmethod
    def _beginner_lesson(lesson) -> str:
        title = lesson["title"].lower()
        if "parameters" in title:
            return (
                "Think of a function as a recipe with a blank space for an ingredient. "
                "A parameter names that blank; an argument is the actual ingredient.\n\n"
                "def greet(name):\n"
                "    print('Hello', name)\n\n"
                "greet('Rudo')\n\n"
                "Here, name is the parameter in the definition, and 'Rudo' is "
                "the argument supplied when calling it.\n\n"
                "Should we try another name together?"
            )
        if "returning" in title:
            return (
                "A function can do something on screen, or give a value back to the code "
                "that called it. print shows something; return gives a value back.\n\n"
                "def add(a, b):\n"
                "    return a + b\n\n"
                "total = add(2, 3)\n\n"
                "Now total holds 5, so another calculation can use it."
            )
        if "calling" in title:
            return (
                "Defining a function is like writing a recipe. Calling it is like "
                "actually cooking from the recipe.\n\n"
                "def greet():\n"
                "    print('Hello')\n\n"
                "greet()\n\n"
                "The definition stores the steps; greet() tells Python to run them."
            )
        return OfflineTutor._fundamentals(["def", "parentheses", "indentation"], True)

    @staticmethod
    def _alt_example(lesson):
        if "defining" in lesson["title"].lower():
            return (
                "Here's a different example:\n\n"
                "def say_goodbye():\n"
                "    print('Goodbye')\n\n"
                "say_goodbye()\n\n"
                "The indented line is the instruction; the final line calls the function."
            )
        return "Here's another example:\n\n" + lesson["example"]

    @staticmethod
    def _line_by_line_walkthrough():
        return (
            "Let's read this one line at a time:\n\n"
            "1. def greet():  This creates a function named greet. The () means "
            "we aren't supplying inputs here; the colon begins its instructions.\n"
            "2.     print('Hello')  This line starts with four spaces, so it belongs "
            "inside greet. It will display Hello when greet runs.\n"
            "3. greet()  This line has no indentation. It calls the function, "
            "so Python now executes the print instruction.\n\n"
            "Notice: defining the function and calling the function are separate steps."
        )

    def respond(self, message):
        message = message.strip()
        if not message:
            return "What would you like to understand about Python functions?"
        if message.lower() in ("/reset", "reset"):
            self.last_topic = None
            self.previous_message = None
            self.last_offer = None
            self.turn_count = 0
            return "Conversation reset. Which Python function concept shall we discuss?"

        lower = message.lower()
        if self.last_offer == "walkthrough" and re.fullmatch(
            r"(yes[ ,]+please|yes|yep|yeah|sure|ok|okay|please|go ahead)[.! ]*", lower
        ):
            self.last_offer = None
            return self._line_by_line_walkthrough()
        if re.search(r"\b(line by line|walk (?:me )?through)\b", lower) and self.last_topic is not None:
            self.last_offer = None
            return self._line_by_line_walkthrough()
        self.last_offer = None
        is_beginner = bool(BEGINNER_RE.search(message))
        followup = bool(FOLLOWUP_RE.search(message) or re.search(
            r"\b(quiz|exercise|practice|test me|give me a question)\b", message, re.I
        )) and self.last_topic is not None
        terms = mentioned_terms(message)

        # Explicit topic switch overrides earlier discussion context.
        subject = bool(NON_FUNCTION_SUBJECT_RE.search(message))
        contains_function_cue = bool(re.search(
            r"\b(function|functions|def|parameter|argument|return|indentation)\b", message, re.I
        ))
        if subject and not contains_function_cue:
            return (
                "That question is about a different Python topic. This offline lesson "
                "pack currently covers functions, not lists, loops or other topics. "
                "I don't want to give you an unrelated explanation."
            )

        lesson = self._select_lesson(message, followup)
        if lesson is None:
            return (
                "I can't reliably interpret that question with this small offline lesson pack. "
                "I can help with defining functions, def, parentheses, indentation, "
                "parameters, arguments, calling functions, and return values."
            )

        self.last_topic = lesson
        self.previous_message = message
        self.turn_count += 1

        # Address each explicitly mentioned unfamiliar syntax term, not just the topic title.
        if terms and (is_beginner or len(terms) > 1 or re.search(r"\bmean|what (?:is|are)\b", lower)):
            self.last_offer = "walkthrough"
            return self._fundamentals(terms, is_beginner)

        if re.search(r"\b(quiz|exercise|practice|test me|give me a question)\b", lower):
            return (
                lesson["question"] + "\n\n"
                "I can discuss your reasoning, but this prototype cannot certify "
                "mastery from an open-ended answer."
            )
        if re.search(r"\b(another example|different example|more examples?)\b", lower):
            return self._alt_example(lesson)
        if is_beginner:
            return self._beginner_lesson(lesson)
        if re.search(r"\b(example|show me|code)\b", lower):
            return lesson["example"]
        if re.search(r"\b(cooking|recipe|analogy)\b", lower):
            return self._beginner_lesson(lesson)

        # For ordinary topic questions, teach without automatically setting an
        # exercise that will have no reliable grading path.
        return f"{lesson['summary']}\n\n{lesson['explanation']}\n\n{lesson['example']}"


def main():
    tutor = OfflineTutor()
    print("Campus Pop grounded offline tutor V46.1 | /reset clears context | /quit exits")
    while True:
        try:
            prompt = input("You: ")
        except (EOFError, KeyboardInterrupt):
            break
        if prompt.strip().lower() == "/quit":
            break
        print("Tutor:", tutor.respond(prompt), "\n")


if __name__ == "__main__":
    main()
