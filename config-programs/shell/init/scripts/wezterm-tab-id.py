import json
import os
import sys


pane = os.environ.get("WEZTERM_PANE")
if not pane:
    raise SystemExit(1)

try:
    rows = json.load(sys.stdin)
except Exception:
    raise SystemExit(1)

for row in rows:
    if str(row.get("pane_id")) == str(pane):
        tab_id = row.get("tab_id")
        if tab_id is not None:
            print(tab_id)
            raise SystemExit(0)

raise SystemExit(1)
