"""Qt integration for a private, algorithmic tutoring assistant (no LLM, no API)."""
from __future__ import annotations
from pathlib import Path
import json
from PySide6.QtCore import QObject, Signal, Slot, Property, QStandardPaths, QUrl, QThreadPool, QRunnable
from .conversation_store import ConversationStore
from .learning_engine_v44 import teach_v44  # CAMPUS_POP_TEACHER_V44
from .adaptive import choose_strategy
from .offline_engine import read_seeded,load_workspace,answer,_text_from_file,extract_summary
from .tutor_router_v27 import answer_v27  # CAMPUS_POP_SUBJECT_ROUTING_V27
from .offline_engine import Entry
from .open_library import OpenLibrary, subject_of

class ResultSignals(QObject):
    ready=Signal(str,str,str)
    failure=Signal(str,str)

class LocalJob(QRunnable):
    def __init__(self,kind,kwargs):
        super().__init__();self.kind=kind;self.args=kwargs;self.signals=ResultSignals()
    def run(self):
        try:
            if self.kind=='answer':
                p=self.args
                corpus=read_seeded(p['source'])+load_workspace(p['workspace'])
                # CAMPUS_POP_OPEN_SOURCE_V26 - searchable licensed references
                try:
                    lib = OpenLibrary(p['library_db'])
                    for hit in lib.search(p['question'], p['course'], limit=4):
                        source = ("Open source reference · " + hit['author'] +
                                  " · " + hit['license'] + " · " + hit['public_url'] +
                                  " · License: " + hit['license_url'])
                        corpus.append(Entry(
                            "Open Library · " + hit['subject'],
                            hit['title'],source,hit['content']))
                except Exception:
                    # The original course tutor still works if the index is absent.
                    pass
                response=teach_v44(p,corpus)
                self.signals.ready.emit('answer',response,'')
            else:
                text=_text_from_file(Path(self.args['file']))
                self.signals.ready.emit('summary','Local summary (original sentences):\n'+extract_summary(text),'')
        except Exception as e:
            self.signals.failure.emit(self.kind,str(e))

class TutorBridge(QObject):
    replyReady=Signal(str)
    requestFailed=Signal(str)
    summaryReady=Signal(str)
    summaryFailed=Signal(str)
    workingChanged=Signal(bool)
    conversationChanged=Signal()
    feedbackSaved=Signal(str)

    def __init__(self,project_root,workspace=None,parent=None,profile=None):
        super().__init__(parent)
        self._root=Path(project_root);self._workspace=workspace;self._profile=profile
        store_dir=QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
        self._data=Path(store_dir or str(Path.home()/'.campus-pop'))
        self._store=ConversationStore(self._data/'tutor_chats.sqlite3')
        convos=self._store.list_conversations()
        self._current=convos[0]['id'] if convos else self._store.new()
        self._busy=False;self._task='';self._job=None;self._pending=None
        self._last_id=None;self._last_course='';self._last_mode='';self._last_strategy='worked example'
        self._pool=QThreadPool(self);self._pool.setMaxThreadCount(1)

    @Property(bool,constant=True)
    def configured(self):return True
    @Property(str,constant=True)
    def modelName(self):return 'Offline course + English study engine'
    @Property(str,constant=True)
    def dictionaryStatus(self):
        try:
            from nltk.corpus import wordnet as w
            w.synsets('student')
            return 'WordNet installed'
        except (ImportError,LookupError,OSError):return 'Starter glossary (WordNet optional)'
    @Property(bool,notify=workingChanged)
    def busy(self):return self._busy
    @Property(str,notify=conversationChanged)
    def conversationsJson(self):return json.dumps(self._store.list_conversations())
    @Property(str,notify=conversationChanged)
    def messagesJson(self):return json.dumps(self._store.messages(self._current))
    @Property(str,notify=conversationChanged)
    def currentConversationId(self):return self._current

    @Slot()
    def newConversation(self):
        if self._busy:return
        self._current=self._store.new();self.conversationChanged.emit()
    @Slot(str)
    def openConversation(self,ident):
        if not self._busy and self._store.contains(ident):
            self._current=ident;self.conversationChanged.emit()

    @Slot(str,str,str,str,str)
    def ask(self,question,course,mode,level,attachment):
        if self._busy:self.requestFailed.emit('Finish the previous response first.');return
        if not str(question).strip() and not attachment:
            self.requestFailed.emit('Type a question or attach a document.');return
        local_path=''
        if attachment:
            url=QUrl(attachment)
            local_path=url.toLocalFile() if url.isLocalFile() else attachment
        prompt=str(question).strip() or 'Summarise this document.'
        stats=self._store.policy_stats(course,mode)
        strategy=choose_strategy(course,mode,stats)
        courses=self._profile.enrolledCourses if self._profile is not None else []
        name=self._profile.username if self._profile is not None else ''
        prefs=getattr(self._profile,'_prefs',None)
        program=getattr(prefs,'program','') if prefs else ''
        year=getattr(prefs,'level','') if prefs else '' 
        args=dict(question=prompt,course=course,mode=mode,strategy=strategy,
                  attachment=local_path,courses=courses,profile_name=name,program=program,study_year=year,source=self._root/'ui/data/CourseContent.js',
                  workspace=self._data/'workspace.json',library_db=self._data/'open_knowledge.sqlite3')
        args.update(conversation_id=self._current, store_dir=str(self._data), study_level=level, history=self._store.history(self._current, 14))
        previous=self._store.messages(self._current)
        self._store.append(self._current,'user',prompt,Path(local_path).name if local_path else '')
        if not previous:self._store.rename(self._current,prompt[:55])
        self.conversationChanged.emit()
        self._pending=(self._current,course,mode,strategy)
        self._start('answer',args)

    @Slot(str,str)
    def summariseImportedFile(self,ident,style):
        if self._busy:self.summaryFailed.emit('Finish the previous request first.');return
        if self._workspace is None:self.summaryFailed.emit('Imported file library is unavailable.');return
        row=next((r for r in self._workspace.files if r.get('id')==ident),None)
        if not row:self.summaryFailed.emit('Choose a saved file first.');return
        try:
            file=Path(row['path']).resolve(strict=True)
            allowed=(self._data/'materials').resolve()
            if not file.is_relative_to(allowed):raise ValueError('File must be in your imported library.')
        except (OSError,ValueError) as exc:
            self.summaryFailed.emit(str(exc));return
        self._start('summary',dict(file=str(file)))

    def _start(self,kind,kwargs):
        self._task=kind;self._busy=True;self.workingChanged.emit(True)
        job=LocalJob(kind,kwargs)
        job.signals.ready.connect(self._ready)
        job.signals.failure.connect(self._failed)
        self._job=job;self._pool.start(job)

    @Slot(str,str,str)
    def _ready(self,kind,text,unused):
        if kind=='answer' and self._pending:
            convo,course,mode,strategy=self._pending
            self._last_id=self._store.append(convo,'assistant',text)
            self._last_course=course;self._last_mode=mode;self._last_strategy=strategy
            self._pending=None;self.conversationChanged.emit()
        self._busy=False;self._job=None;self.workingChanged.emit(False)
        if kind=='answer':self.replyReady.emit(text)
        else:self.summaryReady.emit(text)

    @Slot(str,str)
    def _failed(self,kind,message):
        self._busy=False;self._pending=None;self._job=None;self.workingChanged.emit(False)
        if kind=='summary':self.summaryFailed.emit(message)
        else:self.requestFailed.emit(message)

    @Slot(bool)
    def rateLastAnswer(self,helpful):
        if self._last_id is None:self.feedbackSaved.emit('No response is available to rate.');return
        self._store.rate(self._last_id,self._last_course,self._last_mode,self._last_strategy,helpful)
        self.feedbackSaved.emit('Feedback saved. Future study approaches can use it.')
