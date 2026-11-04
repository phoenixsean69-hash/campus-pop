"""Campus Pop V46.2 multi-course terminal tutor.

Compatibility: OfflineTutor remains importable for original V46.1 tests.
"""
from python_functions_tutor import OfflineTutor
from multi_course_tutor import MultiCourseTutor


def main():
    tutor=MultiCourseTutor()
    print('Campus Pop offline multi-course tutor V46.2')
    print('Choose any course, add new courses, and import your own materials.')
    print(tutor.courses_text())
    print('Type /help for all commands; /quit to exit.\n')
    while True:
        try:
            msg=input('You: ')
        except (EOFError,KeyboardInterrupt):
            print('\nSession ended.')
            break
        if msg.strip().lower()=='/quit':break
        print('\nTutor:',tutor.respond(msg),'\n')


if __name__=='__main__': main()
