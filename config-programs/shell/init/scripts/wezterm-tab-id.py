import json
import os
import sys


window = os.environ.get("KITTY_WINDOW_ID")
if window:
    try:
        os_windows = json.load(sys.stdin)
    except (json.JSONDecodeError, TypeError):
        raise SystemExit(1)

    for os_window in os_windows:
        for tab in os_window.get("tabs", []):
            if any(str(item.get("id")) == window for item in tab.get("windows", [])):
                tab_id = tab.get("id")
                if tab_id is not None:
                    print(tab_id)
                    raise SystemExit(0)
    raise SystemExit(1)

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
