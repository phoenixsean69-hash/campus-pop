# Campus Pop V46.3 speed patch

This ZIP contains a **drop-in replacement for V46.3** with the same command-line arguments, `courses.json`, and output layout. It does not make the remote Wikipedia shards smaller and is not a neural model trainer. It reduces local disk/SQLite overhead and prints network/processing progress every 10-20 seconds. The existing `campus_pop_corpus` data folder stays untouched by extraction.

Speed changes: buffered writes, 1000-record database batches, SQLite WAL journaling, simpler WikiText chunk accounting, progress counters, and 4 MiB HTTP read chunks. The exact speed improvement depends on the source and hardware.

**Before installing:** press Ctrl+C in the running builder once; allow its status printout and return to the PowerShell prompt. Close any other builder processes using the same corpus folder.

From your Campus Pop project directory:

```powershell
$P = 'C:\Users\nooklyweb\Documents\Python Projects\Storm'
$Z = Join-Path $env:USERPROFILE 'Downloads\campus_pop_corpus_builder_v46_3_fast.zip'
$Py = Join-Path $P '.venv\Scripts\python.exe'
$B = Join-Path $P 'campus_pop_corpus_builder_v46_3'
$D = Join-Path $P 'campus_pop_corpus'
Copy-Item (Join-Path $B 'corpus_builder.py') (Join-Path $B 'corpus_builder.before_fast.py') -Force
Expand-Archive -LiteralPath $Z -DestinationPath $P -Force
& $Py (Join-Path $B 'test_builder.py')
& $Py (Join-Path $B 'corpus_builder.py') --out $D --target-mib 2048 --per-course-mib 80 --max-wikipedia-articles 800000 --courses-json (Join-Path $B 'courses.json')
```

**Existing records** are recognized using `manifest.sqlite`; download caches in `downloads` are reused. Some streaming sources may need to be scanned again on rerun; this is not a true remote-offset resume. Leave the process running after confirming stage progress. Interrupt only if needed.

To check the status without downloading:

```powershell
& $Py (Join-Path $B 'corpus_builder.py') --out $D --only report --courses-json (Join-Path $B 'courses.json')
```

Avoid running the status query at the same time as the builder if you wish to minimize disk contention. This database is generated output, not a source of private credentials.
