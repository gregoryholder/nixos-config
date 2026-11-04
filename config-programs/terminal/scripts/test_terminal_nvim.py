import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SOURCE = Path(__file__).with_name("terminal-nvim.py")
ZSH = shutil.which("zsh")
spec = importlib.util.spec_from_file_location("terminal_nvim", SOURCE)
routing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(routing)


class RoutingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.runtime = Path(self.temporary.name)
        self.environment = patch.dict(os.environ, {
            "XDG_RUNTIME_DIR": str(self.runtime),
            "KITTY_PID": "123",
            "KITTY_WINDOW_ID": "7",
            "KITTY_LISTEN_ON": "unix:/unused.sock",
        }, clear=True)
        self.environment.start()
        self.addCleanup(self.environment.stop)

    def test_tab_socket_is_instance_scoped_and_rediscovered(self):
        def windows(tab):
            return json.dumps([{"tabs": [{"id": tab, "windows": [{"id": 7}]}]}])

        with patch.object(routing, "run", side_effect=[windows(2), windows(2), windows(3)]):
            first = routing.tab_socket()
            os.environ["KITTY_PID"] = "456"
            second = routing.tab_socket()
            moved = routing.tab_socket()
        self.assertEqual(first, str(self.runtime / "terminal-nvim/kitty-123-2.sock"))
        self.assertNotEqual(first, second)
        self.assertNotEqual(second, moved)
        self.assertEqual((self.runtime / "terminal-nvim").stat().st_mode & 0o777, 0o700)

    def test_kitty_endpoint_handles_base_and_already_suffixed_paths(self):
        base = self.runtime / "kitty.sock"
        with socket.socket(socket.AF_UNIX) as server:
            server.bind(str(base) + "-123")
            for endpoint in (f"unix:{base}", f"unix:{base}-123"):
                with patch.dict(os.environ, {"KITTY_LISTEN_ON": endpoint}):
                    self.assertEqual(routing.kitty_endpoint(), f"unix:{base}-123")

    def test_stale_environment_cannot_redirect_tab_and_embedded_nvim_wins(self):
        os.environ["NVIM_LISTEN_ADDRESS"] = "/wrong-tab.sock"
        with patch.object(routing, "tab_socket", return_value="/current-tab.sock"), \
                patch.object(routing, "is_listening", return_value=True):
            self.assertEqual(routing.editor_address(), "/current-tab.sock")
            os.environ["NVIM"] = "/embedded.sock"
            self.assertEqual(routing.editor_address(), "/embedded.sock")
        with patch.object(routing, "is_listening", return_value=False):
            with self.assertRaisesRegex(routing.RoutingError, "/embedded.sock"):
                routing.editor_address()

    def test_lookup_errors_are_reported_without_selecting_another_server(self):
        error = subprocess.CalledProcessError(1, ["kitten"], stderr="connection refused")
        with patch.object(routing, "run", side_effect=error), \
                patch("sys.argv", ["terminal-nvim", "listen-address"]), \
                contextlib.redirect_stderr(io.StringIO()) as stderr:
            self.assertEqual(routing.main(), 1)
        self.assertIn("connection refused", stderr.getvalue())

    def test_dead_socket_is_not_treated_as_an_active_editor(self):
        address = str(self.runtime / "dead.sock")
        with socket.socket(socket.AF_UNIX) as server:
            server.bind(address)
        error = subprocess.CalledProcessError(1, ["nvr"], stderr="connection refused")
        with patch.object(routing, "nvr", side_effect=error):
            self.assertFalse(routing.is_listening(address))

    def test_file_line_directory_and_editor_focus(self):
        for file, line, position in [
            ("file with spaces.txt", ["17"], "+17"),
            (str(self.runtime), [], "+Oil"),
        ]:
            with self.subTest(file=file), \
                    patch("sys.argv", ["terminal-nvim", "open", file, *line]), \
                    patch.object(routing, "editor_address", return_value="/editor.sock"), \
                    patch.object(routing, "nvr", return_value="9") as nvr, \
                    patch.object(routing, "run") as run:
                self.assertEqual(routing.main(), 0)
                self.assertEqual(nvr.call_args_list[0].args, (
                    "/editor.sock", "--remote", position, os.path.abspath(file),
                ))
                self.assertEqual(run.call_args.args[0][-2:], ["--match", "id:9"])

    def test_wezterm_discovery_and_focus(self):
        os.environ.pop("KITTY_WINDOW_ID")
        os.environ["WEZTERM_PANE"] = "8"
        with patch.object(routing, "run", return_value='[{"pane_id":8,"tab_id":4}]'):
            self.assertEqual(
                routing.tab_socket(), str(self.runtime / "terminal-nvim/wezterm-4.sock")
            )
        with patch.object(routing, "nvr", return_value="12"), patch.object(routing, "run") as run:
            routing.focus_editor("/editor.sock")
            run.assert_called_once_with(["wezterm", "cli", "activate-pane", "--pane-id", "12"])

    @unittest.skipUnless(ZSH, "zsh is required")
    def test_shell_startup_is_lazy_and_explicit_listen_is_preserved(self):
        shell_source = SOURCE.parents[2] / "shell/init/scripts/wezterm-nvim-socket.zsh"
        nvim = self.runtime / "nvim"
        nvim.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$TEST_LOG"\n')
        nvim.chmod(0o755)
        script = '''
function terminal-nvim() { print queried >> "$TEST_LOG"; return 1; }
source "$1"
[[ ! -e "$TEST_LOG" ]] || exit 1
nvim --listen /explicit.sock file.txt
if nvim file.txt; then exit 2; fi
'''
        env = {**os.environ, "PATH": str(self.runtime), "TEST_LOG": str(self.runtime / "calls")}
        subprocess.run([ZSH, "-f", "-c", script, "test",
                        str(shell_source)], env=env, check=True)
        self.assertEqual(
            (self.runtime / "calls").read_text(),
            "--listen /explicit.sock file.txt\nqueried\n",
        )


if __name__ == "__main__":
    unittest.main()
