"""V46.2 tests: multi-course retrieval, local imports and context."""
import tempfile
import unittest
from pathlib import Path
from multi_course_tutor import MultiCourseTutor
from course_library import CourseLibrary


class MultiCourseTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.t=MultiCourseTutor(store=Path(self.temp.name)/'data')

    def tearDown(self):
        self.temp.cleanup()

    def test_six_seeded_courses(self):
        names=[c['name'] for c in self.t.library.all_courses()]
        self.assertEqual(len(names),6)
        self.assertIn('Applied Statistics',names)
        self.assertIn('Database Systems',names)

    def test_statistics(self):
        self.t.respond('/course Applied Statistics')
        response=self.t.respond('What is a population and sample?')
        self.assertIn('population',response.lower())
        self.assertIn('sample',response.lower())
        self.assertNotIn('def greet',response)

    def test_database(self):
        self.t.respond('/course Database Systems')
        self.assertIn('primary key',self.t.respond('Explain relational primary keys').lower())

    def test_software_engineering(self):
        self.t.respond('/course Software Engineering')
        self.assertIn('requirements',self.t.respond('What are functional requirements?').lower())

    def test_discrete_math(self):
        self.t.respond('/course Discrete Mathematics')
        self.assertIn('intersection',self.t.respond('Explain set union and intersection').lower())

    def test_computer_systems(self):
        self.t.respond('/course Computer Systems')
        self.assertIn('ram',self.t.respond('Explain CPU and RAM').lower())

    def test_python_function_fix_preserved(self):
        self.t.respond('/course Python Programming')
        self.t.respond('What is a Python function?')
        response=self.t.respond("I'm new and I don't understand def, parentheses or indentation")
        self.assertIn('parentheses',response.lower())
        self.assertIn('indentation',response.lower())
        self.assertIn('one line at a time',self.t.respond('yes').lower())

    def test_python_lists_not_wrongly_rejected(self):
        self.t.respond('/course Python Programming')
        self.assertIn('list',self.t.respond('How do I make a Python list?').lower())

    def test_new_course_and_import(self):
        self.assertIn('Created',self.t.respond('/addcourse Environmental Science'))
        p=Path(self.temp.name)/'soil.txt'
        p.write_text('Soil erosion is the removal of topsoil by wind and water.\n\nContour farming can help reduce soil erosion.',encoding='utf-8')
        self.assertIn('Imported 1 file',self.t.respond(f'/import "{p}"'))
        self.assertIn('topsoil',self.t.respond('What is soil erosion?').lower())
        self.assertIn('soil.txt',self.t.respond('/sources'))

    def test_unknown_does_not_guess(self):
        self.t.respond('/addcourse Organic Chemistry')
        self.assertIn("couldn't find enough",self.t.respond('Explain carboxylation enthalpy').lower())

    def test_exercise_does_not_certify_mastery(self):
        self.t.respond('/course Applied Statistics')
        self.t.respond('What is a sample?')
        response=self.t.respond('Give me an exercise')
        self.assertIn('Practice',response)
        self.assertIn('unverified',response)

    def test_context_course_switch(self):
        self.t.respond('/course Applied Statistics')
        self.t.respond('What is a population?')
        self.t.respond('/course Computer Systems')
        self.assertIn('operating system',self.t.respond('What is an operating system?').lower())

    def test_persistence_of_added_courses(self):
        self.t.respond('/addcourse Environmental Science')
        second=MultiCourseTutor(store=Path(self.temp.name)/'data')
        self.assertIsNotNone(second.library.find_course('Environmental Science'))

    def test_import_duplicate_is_skipped(self):
        self.t.respond('/addcourse Environmental Science')
        p=Path(self.temp.name)/'biology.txt'
        p.write_text('Photosynthesis converts light energy into chemical energy.',encoding='utf-8')
        self.t.respond(f'/import "{p}"')
        self.assertIn('Imported 0 file',self.t.respond(f'/import "{p}"'))

    def test_no_mastery_for_user_answer(self):
        self.t.respond('/course Applied Statistics')
        self.t.respond('What is a population?')
        answer=self.t.respond('Population is 8000 and sample is 400')
        self.assertNotIn('mastered',answer.lower())


    def test_beginner_followup_in_statistics(self):
        self.t.respond('/course Applied Statistics')
        self.t.respond('What is a population and sample?')
        result=self.t.respond("Explain that like I'm completely new to statistics. I'm confused.")
        self.assertIn('everyone you want to study',result.lower())

    def test_context_practice_in_discrete_maths(self):
        self.t.respond('/course Discrete Mathematics')
        self.t.respond('What is the union of two sets?')
        result=self.t.respond('Give me an exercise')
        self.assertIn('Practice',result)
        self.assertIn('union',result.lower())

    def test_import_folder(self):
        self.t.respond('/addcourse Botany')
        folder=Path(self.temp.name)/'materials'
        folder.mkdir()
        (folder/'leaf.txt').write_text('Stomata allow gas exchange in leaves.',encoding='utf-8')
        (folder/'root.md').write_text('Root hairs absorb water and minerals from soil.',encoding='utf-8')
        res=self.t.respond(f'/import "{folder}"')
        self.assertIn('Imported 2 file',res)
        self.assertIn('stomata',self.t.respond('What are stomata?').lower())

    def test_empty_course_reports_limit(self):
        self.t.respond('/addcourse Marine Biology')
        self.assertIn('import',self.t.respond('Explain osmotic regulation').lower())


    def test_json_course_catalog_sync(self):
        p=Path(self.temp.name)/'courses.json'
        p.write_text('{"courses": [{"name": "Business Administration"}, "Chemistry"]}',encoding='utf-8')
        self.assertIn('Added 2 new course',self.t.respond(f'/synccourses "{p}"'))
        self.assertIsNotNone(self.t.library.find_course('Business Administration'))
        self.assertIsNotNone(self.t.library.find_course('Chemistry'))

    def test_help_includes_import(self):
        self.assertIn('/import',self.t.respond('/help'))


if __name__=='__main__': unittest.main(verbosity=2)
