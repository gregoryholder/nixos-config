import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time


class RoutingError(Exception):
    pass


def run(args):
    return subprocess.run(
        args, check=True, capture_output=True, text=True, timeout=5
    ).stdout.strip()


def kitty_endpoint():
    endpoint = os.environ.get("KITTY_LISTEN_ON")
    pid = os.environ.get("KITTY_PID")
    if not endpoint:
        cache = os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))
        endpoint = f"unix:{cache}/kitty.sock"
    if endpoint.startswith("unix:") and pid:
        suffixed = f"{endpoint[5:]}-{pid}"
        if Path(suffixed).is_socket():
            return f"unix:{suffixed}"
    return endpoint


def tab_socket():
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if not runtime or not Path(runtime).is_dir():
        raise RoutingError("XDG_RUNTIME_DIR must point to an existing runtime directory")
    directory = Path(runtime) / "terminal-nvim"
    directory.mkdir(mode=0o700, exist_ok=True)

    window = os.environ.get("KITTY_WINDOW_ID")
    pane = os.environ.get("WEZTERM_PANE")
    if window:
        pid = os.environ.get("KITTY_PID")
        if not pid or not pid.isdecimal():
            raise RoutingError("KITTY_PID is missing or invalid")
        windows = json.loads(run(["kitten", "@", "--to", kitty_endpoint(), "ls"]))
        for os_window in windows:
            for tab in os_window["tabs"]:
                if any(str(item["id"]) == window for item in tab["windows"]):
                    return str(directory / f"kitty-{pid}-{int(tab['id'])}.sock")
        raise RoutingError("the current Kitty window was not found in any tab")
    if pane:
        panes = json.loads(run(["wezterm", "cli", "list", "--format", "json"]))
        for item in panes:
            if str(item["pane_id"]) == pane:
                return str(directory / f"wezterm-{int(item['tab_id'])}.sock")
        raise RoutingError("the current WezTerm pane was not found in any tab")
    raise RoutingError("no Kitty or WezTerm tab is available")


def nvr(address, *args):
    return run(["nvr", "--servername", address, "--nostart", *args])


def executable(name):
    path = shutil.which(name)
    if not path:
        raise RoutingError(f"{name} executable was not found in PATH")
    return path


def launch_split(*command):
    if os.environ.get("KITTY_WINDOW_ID"):
        return run([
            "kitten", "@", "--to", kitty_endpoint(), "launch",
            "--type=window", "--location=vsplit", "--cwd=current", *command,
        ])
    pane = os.environ.get("WEZTERM_PANE")
    if pane:
        return run([
            "wezterm", "cli", "split-pane", "--right", "--pane-id", pane,
            "--cwd", os.getcwd(), "--", *command,
        ])
    raise RoutingError("no Kitty or WezTerm pane is available")


def is_listening(address):
    if not Path(address).is_socket():
        return False
    try:
        return nvr(address, "--remote-expr", "1") == "1"
    except subprocess.CalledProcessError:
        return False


def wait_for_editor(address):
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if is_listening(address):
            return
        time.sleep(0.1)
    raise RoutingError(f"Neovim did not start listening at {address}")


def editor_address():
    address = os.environ.get("NVIM")
    if not address:
        if os.environ.get("KITTY_WINDOW_ID") or os.environ.get("WEZTERM_PANE"):
            address = tab_socket()
        else:
            address = os.environ.get("NVIM_LISTEN_ADDRESS")
    if not address or not is_listening(address):
        raise RoutingError(
            f"no listening Neovim server at {address or 'NVIM_LISTEN_ADDRESS'}; "
            "start Neovim from a new shell in this tab"
        )
    return address


def focus_editor(address):
    if os.environ.get("KITTY_WINDOW_ID"):
        window = nvr(address, "--remote-expr", "$KITTY_WINDOW_ID")
        if not window.isdecimal():
            raise RoutingError("the Neovim server has no valid Kitty window ID")
        run(["kitten", "@", "--to", kitty_endpoint(), "focus-window", "--match", f"id:{window}"])
    elif os.environ.get("WEZTERM_PANE"):
        pane = nvr(address, "--remote-expr", "$WEZTERM_PANE")
        if not pane.isdecimal():
            raise RoutingError("the Neovim server has no valid WezTerm pane ID")
        run(["wezterm", "cli", "activate-pane", "--pane-id", pane])


def main():
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("listen-address")
    open_parser = commands.add_parser("open")
    open_parser.add_argument("file")
    open_parser.add_argument("line", nargs="?", type=int)
    commands.add_parser("lazygit")
    args = parser.parse_args()
    try:
        if args.command == "listen-address":
            address = tab_socket()
            if not is_listening(address):
                print(address)
        elif args.command == "lazygit":
            tab_socket()
            launch_split(executable("lazygit"))
        else:
            if args.line is not None and args.line < 1:
                raise RoutingError("line number must be positive")
            if os.environ.get("NVIM"):
                address = editor_address()
            elif os.environ.get("KITTY_WINDOW_ID") or os.environ.get("WEZTERM_PANE"):
                address = tab_socket()
                if not is_listening(address):
                    launch_split(executable("nvim"), "--listen", address)
                    wait_for_editor(address)
            else:
                address = editor_address()
            file = Path(os.path.abspath(args.file))
            position = ["+Oil"] if file.is_dir() else (
                [f"+{args.line}"] if args.line is not None else []
            )
            nvr(address, "--remote", *position, str(file))
            focus_editor(address)
    except subprocess.CalledProcessError as error:
        print(f"terminal-nvim: {error.stderr.strip() or str(error)}", file=sys.stderr)
        return 1
    except (RoutingError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print(f"terminal-nvim: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
