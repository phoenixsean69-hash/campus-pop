"""Persist first-run onboarding and local student profile; photo never uploaded."""
from __future__ import annotations
import json
from pathlib import Path
from uuid import uuid4
from PySide6.QtCore import QObject, Signal, Slot, Property, QSettings, QStandardPaths, QUrl, Qt
from PySide6.QtGui import QImageReader, QImage, QColor

COURSES = ('Applied Statistics','Python Programming','Computer Systems',
           'Software Engineering','Discrete Mathematics','Database Systems')

class ProfileBridge(QObject):
    changed=Signal()
    warning=Signal(str)

    def __init__(self, settings_bridge=None, parent=None):
        super().__init__(parent)
        self._prefs=settings_bridge
        self._store=QSettings('Storm','StudySpace')
        self._done=str(self._store.value('onboarding/complete','false')).lower()=='true'
        self._editing=False
        raw=str(self._store.value('profile/name','Student'))
        self._name=raw.strip()[:48] or 'Student'
        saved=self._store.value('profile/courses','[]')
        try:
            items=json.loads(saved) if isinstance(saved,str) else []
            self._courses=[name for name in COURSES if name in items]
        except (TypeError,ValueError):self._courses=[]
        self._avatar_path=str(self._store.value('profile/avatar',''))
        if self._prefs is not None and hasattr(self._prefs,'displayNameChanged'):
            self._prefs.displayNameChanged.connect(self._on_name_from_settings)
        if self._avatar_path and not Path(self._avatar_path).is_file(): self._avatar_path=''

    def _on_name_from_settings(self):
        self._name=self._prefs.displayName or self._name
        self.changed.emit()

    @Property(bool, notify=changed)
    def onboarded(self):return self._done
    @Property(bool, notify=changed)
    def editing(self):return self._editing
    @Property(str, notify=changed)
    def username(self):return self._name
    @Property(str, notify=changed)
    def initials(self):
        words=[x for x in self._name.split() if x]
        return (''.join(w[0] for w in words[:2]) or 'ST').upper()
    @Property(str, notify=changed)
    def avatarUrl(self):
        return QUrl.fromLocalFile(self._avatar_path).toString() if self._avatar_path else ''
    @Property('QVariantList', notify=changed)
    def enrolledCourses(self):return self._courses
    @Property(str, notify=changed)
    def lastError(self):return getattr(self,'_error','')

    @Slot()
    def openEditor(self):
        self._editing=True;self.changed.emit()
    @Slot()
    def closeEditor(self):
        if self._done:self._editing=False;self.changed.emit()

    @Slot(str, result=bool)
    def pickAvatar(self,url:str):
        try:
            qurl=QUrl(url)
            source=Path(qurl.toLocalFile() if qurl.isLocalFile() else url)
            if source.suffix.lower() not in ('.png','.jpg','.jpeg','.webp','.bmp'):
                raise ValueError('Choose a PNG, JPG, WebP or BMP image.')
            if not source.is_file() or source.stat().st_size>10*1024*1024:
                raise ValueError('The photo must exist and be 10 MB or smaller.')
            reader=QImageReader(str(source))
            reader.setAutoTransform(True)
            pic=reader.read()
            if pic.isNull():raise ValueError('Could not read this image file.')
            data=QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
            folder=Path(data or str(Path.home()/'.campus-pop'))/'profile'
            folder.mkdir(parents=True,exist_ok=True)
            pic=pic.scaled(280,280,Qt.KeepAspectRatio,Qt.SmoothTransformation)
            dest=folder/'avatar.png'
            if not pic.save(str(dest),'PNG'):raise ValueError('Could not save the profile image.')
            self._avatar_path=str(dest)
            self._store.setValue('profile/avatar',self._avatar_path)
            self._store.sync();self.changed.emit()
            return True
        except Exception as e:
            self._error=str(e);self.warning.emit(self._error);self.changed.emit();return False

    @Slot(str, str, result=bool)
    def finish(self,name:str,courses_json:str):
        name=' '.join(str(name).strip().split())
        if not 2<=len(name)<=48:
            self._error='Enter a username between 2 and 48 characters.'
            self.warning.emit(self._error);self.changed.emit();return False
        try: courses=json.loads(courses_json)
        except ValueError:courses=[]
        if not isinstance(courses,list):courses=[]
        valid=[c for c in COURSES if c in courses]
        if not valid:
            self._error='Choose at least one of your courses.'
            self.warning.emit(self._error);self.changed.emit();return False
        self._name=name
        self._courses=valid
        self._done=True
        self._editing=False
        self._error=''
        self._store.setValue('profile/name',name)
        self._store.setValue('profile/courses',json.dumps(valid))
        self._store.setValue('onboarding/complete',True)
        self._store.sync()
        if self._prefs is not None and hasattr(self._prefs,'setDisplayName'):
            self._prefs.setDisplayName(name)
        self.changed.emit();return True

    @Slot(str, str, str, result=bool)
    def saveInlineProfile(self, name: str, courses_json: str, photo_uri: str):
        """Commit in-place profile editing; photo is staged until this method."""
        try:
            clean = ' '.join(str(name).strip().split())
            if not 2 <= len(clean) <= 48:
                raise ValueError('Enter a username between 2 and 48 characters.')
            try:
                selected = json.loads(courses_json)
            except (TypeError, ValueError):
                selected = []
            if not isinstance(selected, list):
                selected = []
            valid = [course for course in COURSES if course in selected]
            if not valid:
                raise ValueError('Select at least one course before saving.')
            new_photo = ''
            photo_uri = str(photo_uri or '').strip()
            if photo_uri:
                parsed = QUrl(photo_uri)
                source = Path(parsed.toLocalFile() if parsed.isLocalFile() else photo_uri)
                if source.suffix.lower() not in ('.png', '.jpg', '.jpeg', '.webp', '.bmp'):
                    raise ValueError('Choose a PNG, JPG, WebP or BMP photo.')
                if not source.is_file() or source.stat().st_size > 10 * 1024 * 1024:
                    raise ValueError('Choose an image file smaller than 10 MB.')
                reader = QImageReader(str(source))
                reader.setAutoTransform(True)
                picture = reader.read()
                if picture.isNull():
                    raise ValueError('Unable to read the selected photo.')
                folder = Path(QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
                              or str(Path.home() / '.campus-pop')) / 'profile'
                folder.mkdir(parents=True, exist_ok=True)
                output = folder / ('avatar_' + uuid4().hex[:12] + '.png')
                picture = picture.scaled(600, 600, Qt.KeepAspectRatio, Qt.SmoothTransformation)
                if not picture.save(str(output), 'PNG'):
                    raise ValueError('Cannot save the selected photo.')
                new_photo = str(output)
            self._name = clean
            self._courses = valid
            self._done = True
            self._editing = False
            self._error = ''
            if new_photo:
                self._avatar_path = new_photo
                self._store.setValue('profile/avatar', new_photo)
            self._store.setValue('profile/name', clean)
            self._store.setValue('profile/courses', json.dumps(valid))
            self._store.setValue('onboarding/complete', True)
            self._store.sync()
            if self._prefs is not None and hasattr(self._prefs, 'setDisplayName'):
                self._prefs.setDisplayName(clean)
            self.changed.emit()
            return True
        except Exception as exc:
            self._error = str(exc)
            self.warning.emit(self._error)
            self.changed.emit()
            return False
