import sys
from pathlib import Path
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.load(QUrl.fromLocalFile(str(Path(__file__).with_name('preview.qml'))))
if not engine.rootObjects():
    raise SystemExit('Failed to load the Study Overview QML preview')
raise SystemExit(app.exec())
