"""Qt worker bridge for an on-demand open-license reference sync."""
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property, QRunnable, QThreadPool, QStandardPaths
from .open_library import OpenLibrary, sync_library


class _SyncSignals(QObject):
    done = Signal(object)
    error = Signal(str)
    progress = Signal(str)


class _SyncJob(QRunnable):
    def __init__(self, path):
        super().__init__()
        self.path = path
        self.signals = _SyncSignals()

    def run(self):
        try:
            result = sync_library(self.path, progress=self.signals.progress.emit)
            self.signals.done.emit(result)
        except Exception as exc:
            self.signals.error.emit(str(exc))


class LibraryBridge(QObject):
    statusChanged = Signal()
    busyChanged = Signal()
    countChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        data_dir = QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
        self._db = Path(data_dir or str(Path.home() / '.campus-pop')) / 'open_knowledge.sqlite3'
        self._library = OpenLibrary(self._db)
        self._busy = False
        self._status = 'Ready for first sync' if self._library.stats()['sources'] == 0 else 'Offline library ready'
        self._job = None
        self._pool = QThreadPool(self)
        self._pool.setMaxThreadCount(1)

    @Property(bool, notify=busyChanged)
    def busy(self): return self._busy

    @Property(str, notify=statusChanged)
    def status(self): return self._status

    @Property(int, notify=countChanged)
    def passages(self): return self._library.stats()['passages']

    @Property(int, notify=countChanged)
    def sources(self): return self._library.stats()['sources']

    @Slot()
    def sync(self):
        if self._busy: return
        self._busy = True
        self._status = 'Starting source sync...'
        self.busyChanged.emit();self.statusChanged.emit()
        job = _SyncJob(self._db)
        job.signals.progress.connect(self._progress)
        job.signals.done.connect(self._done)
        job.signals.error.connect(self._error)
        self._job = job
        self._pool.start(job)

    @Slot(str)
    def _progress(self, status):
        self._status = status
        self.statusChanged.emit()

    @Slot(object)
    def _done(self, report):
        successes=len(report['ok'])
        failures=len(report['errors'])
        self._status=f'{successes} sources updated; {failures} unavailable. Search is ready offline.'
        self._busy=False;self._job=None
        self.busyChanged.emit();self.statusChanged.emit();self.countChanged.emit()

    @Slot(str)
    def _error(self, error):
        self._status = 'Sync unsuccessful: ' + error[:160]
        self._busy=False;self._job=None
        self.busyChanged.emit();self.statusChanged.emit()
