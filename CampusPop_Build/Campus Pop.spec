# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['C:/Users/nooklyweb/Documents/Python Projects/Storm/main.py'],
    pathex=['C:/Users/nooklyweb/Documents/Python Projects/Storm'],
    binaries=[],
    datas=[('C:/Users/nooklyweb/Documents/Python Projects/Storm/ui', 'ui'), ('C:/Users/nooklyweb/Documents/Python Projects/Storm/assets', 'assets')],
    hiddenimports=['PySide6.QtQml', 'PySide6.QtQuick', 'PySide6.QtQuickControls2', 'PySide6.QtSvg', 'PySide6.QtNetwork'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['PyQt5', 'PyQt6', 'PySide2'],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='Campus Pop',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['C:/Users/nooklyweb/Documents/Python Projects/Storm/assets/branding/campus_pop.ico'],
    contents_directory='.',
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='Campus Pop',
)
