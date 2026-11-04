"""Non-destructive inspection of Campus Pop QML for targeted stats integration."""
import argparse
from pathlib import Path
import re

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--project', required=True)
    p.add_argument('--out', required=True)
    args = p.parse_args()
    root = Path(args.project).resolve()
    candidates = []
    for path in root.rglob('*.qml'):
        if any(part in {'.venv', 'node_modules', 'build', 'dist', 'campus_pop_numpy_engine'} for part in path.parts):
            continue
        try:
            src = path.read_text('utf-8-sig')
        except (OSError, UnicodeDecodeError):
            continue
        needles = ['courses', 'study hours', 'weekly goal', 'day streak']
        matches = sum(bool(re.search(re.escape(s), src, re.I)) for s in needles)
        if matches >= 3 or ('dashboard' in path.name.lower() and matches >= 1):
            candidates.append((matches, path, src))
    candidates.sort(key=lambda item: (-item[0], len(item[2])))
    out = ['CAMPUS POP DASHBOARD INSPECTION — NO FILES MODIFIED', '', f'Project: {root}', '']
    if not candidates:
        out.append('No QML file matched enough stat labels. Please inspect UI source manually.')
    for matches, path, src in candidates[:8]:
        out.extend([f'FILE: {path.relative_to(root)} — {matches}/4 matching labels', '-'*72])
        lines = src.splitlines()
        hit_lines = [i for i, line in enumerate(lines) if re.search(r'Courses|Study hours|Weekly goal|Day streak', line, re.I)]
        ranges = []
        for i in hit_lines[:30]:
            a, b = max(0, i - 15), min(len(lines), i + 20)
            if ranges and a <= ranges[-1][1]: ranges[-1] = (ranges[-1][0], max(b, ranges[-1][1]))
            else: ranges.append((a,b))
        # Cap extract to avoid emitting giant source files or project data.
        for a,b in ranges[:8]:
            out.append(f'--- Lines {a+1}-{b} ---')
            out.extend(f'{i+1:5}: {lines[i]}' for i in range(a,b))
        out.append('')
    target = Path(args.out).resolve()
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text('\n'.join(out) + '\n', encoding='utf-8')
    print('Inspect report:', target)
    print('Candidate dashboard files:', len(candidates))
    for score, path, _ in candidates[:8]:
        print('  ', score, path.relative_to(root))

if __name__ == '__main__': main()
