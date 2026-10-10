"""Jump to any pane in the current herdr tab.

Draws a scaled map of the tab with a letter in each pane, then focuses the
pane whose letter is pressed. Keys follow Colemak-DH: panes on the left half
of the tab get left-hand keys, panes on the right half get right-hand keys,
home row first. Run from a herdr popup command.

With --workspaces, also lists workspaces down the left side; pressing 1-9
focuses that workspace.
"""

import json
import os
import re
import shutil
import socket
import subprocess
import sys
import termios
import tty

LEFT_KEYS = "tsragdfpcwxzvb"
RIGHT_KEYS = "neiomhulky"
CANCEL = {"q", "\x1b", "\x03"}
STATUS_STYLE = {"blocked": "31", "working": "33", "done": "32"}
ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")

# Box-drawing glyph per set of edge directions meeting in a cell.
U, D, L, R = 1, 2, 4, 8
GLYPHS = {
    L: "─", R: "─", L | R: "─",
    U: "│", D: "│", U | D: "│",
    D | R: "┌", D | L: "┐", U | R: "└", U | L: "┘",
    U | D | R: "├", U | D | L: "┤", D | L | R: "┬", U | L | R: "┴",
    U | D | L | R: "┼",
}


def herdr(*args):
    out = json.loads(subprocess.check_output(["herdr", *args]))
    # CLI prints the API envelope: {"id": ..., "result": {...}}
    return out.get("result", out)


def call(sock_path, method, params):
    req = {"id": "pane-picker", "method": method, "params": params}
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.settimeout(1)
        s.connect(sock_path)
        s.sendall((json.dumps(req) + "\n").encode())
        try:
            s.recv(4096)
        except socket.timeout:
            pass


def snap(values, tol=2):
    """Map each edge coordinate to a canonical one, merging edges that are
    only separated by herdr's pane gaps."""
    canon = {}
    last = None
    for v in sorted(set(values)):
        if last is None or v - last > tol:
            last = v
        canon[v] = last
    return canon


def pane_name(info):
    for key in ("label", "display_agent", "agent", "terminal_title_stripped", "title"):
        if info.get(key):
            return info[key]
    return os.path.basename(info.get("foreground_cwd") or info.get("cwd") or "")


def assign_keys(panes, area):
    mid = area["x"] + area["width"] / 2
    reading = sorted(panes, key=lambda p: (p["rect"]["y"], p["rect"]["x"]))
    left = iter(LEFT_KEYS)
    right = iter(RIGHT_KEYS)
    keys = {}
    for p in reading:
        if p["focused"]:
            continue
        r = p["rect"]
        side = left if r["x"] + r["width"] / 2 < mid else right
        key = next(side, None) or next(left, None) or next(right, None)
        if key:
            keys[key] = p["pane_id"]
    return keys


def render(panes, area, keys, names, cols, rows):
    xs = snap([v for p in panes for v in (p["rect"]["x"], p["rect"]["x"] + p["rect"]["width"])])
    ys = snap([v for p in panes for v in (p["rect"]["y"], p["rect"]["y"] + p["rect"]["height"])])

    def col(x):
        return round((xs[x] - area["x"]) / area["width"] * (cols - 1))

    def row(y):
        return round((ys[y] - area["y"]) / area["height"] * (rows - 1))

    edges = [[0] * cols for _ in range(rows)]
    labels = []
    key_of = {v: k for k, v in keys.items()}
    for p in panes:
        r = p["rect"]
        c0, c1 = col(r["x"]), col(r["x"] + r["width"])
        r0, r1 = row(r["y"]), row(r["y"] + r["height"])
        for c in range(c0, c1 + 1):
            for rr in (r0, r1):
                edges[rr][c] |= (L if c > c0 else 0) | (R if c < c1 else 0)
        for rr in range(r0, r1 + 1):
            for c in (c0, c1):
                edges[rr][c] |= (U if rr > r0 else 0) | (D if rr < r1 else 0)
        labels.append((c0, c1, r0, r1, key_of.get(p["pane_id"]), names.get(p["pane_id"], "")))

    grid = [[GLYPHS.get(e, " ") for e in line] for line in edges]
    styled = {}
    for c0, c1, r0, r1, key, name in labels:
        width = c1 - c0 - 1
        cr = (r0 + r1) // 2
        cc = (c0 + c1) // 2
        if key:
            styled[(cr, cc)] = f"\x1b[1;33m{key}\x1b[0m"
        else:
            styled[(cr, cc)] = "\x1b[2m·\x1b[0m"
        if name and cr + 1 < r1 and width > 2:
            text = name[: width - 2]
            start = c0 + 1 + (width - len(text)) // 2
            for i, ch in enumerate(text):
                styled[(cr + 1, start + i)] = f"\x1b[2m{ch}\x1b[0m"

    lines = []
    for r, line in enumerate(grid):
        lines.append("".join(styled.get((r, c), ch) for c, ch in enumerate(line)))
    return "\n".join(lines)


def sidebar(workspaces, width):
    """One line per workspace: key, status dot, label. Returns lines and the
    key -> workspace_id map."""
    lines = []
    keys = {}
    for w in sorted(workspaces, key=lambda w: w["number"]):
        n = w["number"]
        key = str(n) if 1 <= n <= 9 else None
        if key:
            keys[key] = w["workspace_id"]
        style = STATUS_STYLE.get(w.get("agent_status"), "2")
        label = w["label"][: width - 5]
        if w["focused"]:
            label = f"\x1b[1m{label}\x1b[0m"
        else:
            label = f"\x1b[2m{label}\x1b[0m"
        mark = f"\x1b[1;33m{key}\x1b[0m" if key else " "
        lines.append(f" {mark} \x1b[{style}m●\x1b[0m {label}")
    return lines, keys


def join_columns(left, right, width):
    out = []
    rows = right.split("\n")
    for i, line in enumerate(rows):
        side = left[i] if i < len(left) else ""
        pad = width - len(ANSI.sub("", side))
        out.append(f"{side}{' ' * pad}\x1b[2m│\x1b[0m{line}")
    return "\n".join(out)


def read_key():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        return os.read(fd, 1).decode(errors="ignore")
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)


def main():
    sock_path = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser("~/.config/herdr/herdr.sock")
    with_workspaces = "--workspaces" in sys.argv[1:]
    layout = herdr("pane", "layout")["layout"]
    panes, area = layout["panes"], layout["area"]
    others = [p for p in panes if not p["focused"]]
    if not with_workspaces:
        if not others:
            return
        if len(others) == 1:
            call(sock_path, "pane.focus", {"pane_id": others[0]["pane_id"]})
            return

    infos = herdr("pane", "list", "--workspace", layout["workspace_id"])["panes"]
    names = {i["pane_id"]: pane_name(i) for i in infos}
    keys = assign_keys(panes, area)

    size = shutil.get_terminal_size()
    rows = size.lines - 1
    ws_keys = {}
    if with_workspaces:
        width = min(24, size.columns // 4)
        side, ws_keys = sidebar(herdr("workspace", "list")["workspaces"], width)
        screen = join_columns(side, render(panes, area, keys, names, size.columns - width - 1, rows), width)
        hint = "1-9 workspace, letter pane, q or esc to cancel"
    else:
        screen = render(panes, area, keys, names, size.columns, rows)
        hint = "press a letter, q or esc to cancel"
    sys.stdout.write("\x1b[?25l\x1b[2J\x1b[H")
    sys.stdout.write(screen)
    sys.stdout.write(f"\n\x1b[2m{hint}\x1b[0m")
    sys.stdout.flush()
    try:
        while True:
            key = read_key()
            if key in CANCEL:
                return
            if key in ws_keys:
                call(sock_path, "workspace.focus", {"workspace_id": ws_keys[key]})
                return
            if key in keys:
                call(sock_path, "pane.focus", {"pane_id": keys[key]})
                return
    finally:
        sys.stdout.write("\x1b[?25h")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
