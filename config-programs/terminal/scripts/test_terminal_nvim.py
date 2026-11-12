import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SOURCE = Path(__file__).with_name("terminal-nvim.py")
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

    def test_launch_split_uses_kitty_and_wezterm_current_tab(self):
        with patch.object(routing, "run") as run:
            routing.launch_split("lazygit")
        self.assertEqual(run.call_args.args[0], [
            "kitten", "@", "--to", "unix:/unused.sock", "launch",
            "--type=window", "--location=vsplit", "--cwd=current", "lazygit",
        ])

        os.environ.pop("KITTY_WINDOW_ID")
        os.environ["WEZTERM_PANE"] = "8"
        with patch.object(routing, "run") as run:
            routing.launch_split("nvim", "--listen", "/tab.sock")
        self.assertEqual(run.call_args.args[0], [
            "wezterm", "cli", "split-pane", "--right", "--pane-id", "8",
            "--cwd", os.getcwd(), "--", "nvim", "--listen", "/tab.sock",
        ])

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
                    patch.dict(os.environ, {"NVIM": "/editor.sock"}), \
                    patch.object(routing, "editor_address", return_value="/editor.sock"), \
                    patch.object(routing, "nvr", return_value="9") as nvr, \
                    patch.object(routing, "run") as run:
                self.assertEqual(routing.main(), 0)
                self.assertEqual(nvr.call_args_list[0].args, (
                    "/editor.sock", "--remote", position, os.path.abspath(file),
                ))
                self.assertEqual(run.call_args.args[0][-2:], ["--match", "id:9"])

    def test_open_starts_editor_split_when_tab_has_no_server(self):
        with patch("sys.argv", ["terminal-nvim", "open", "new file.txt"]), \
                patch.object(routing, "tab_socket", return_value="/tab.sock"), \
                patch.object(routing, "is_listening", side_effect=[False, True]), \
                patch.object(routing, "executable", return_value="/usr/bin/nvim"), \
                patch.object(routing, "launch_split") as launch, \
                patch.object(routing, "nvr", return_value="9") as nvr, \
                patch.object(routing, "run"):
            self.assertEqual(routing.main(), 0)
        launch.assert_called_once_with("/usr/bin/nvim", "--listen", "/tab.sock")
        self.assertEqual(nvr.call_args_list[0].args, (
            "/tab.sock", "--remote", os.path.abspath("new file.txt"),
        ))

    def test_open_reports_editor_start_timeout(self):
        with patch("sys.argv", ["terminal-nvim", "open", "file.txt"]), \
                patch.object(routing, "tab_socket", return_value="/tab.sock"), \
                patch.object(routing, "is_listening", return_value=False), \
                patch.object(routing, "executable", return_value="/usr/bin/nvim"), \
                patch.object(routing, "launch_split"), \
                patch.object(routing.time, "monotonic", side_effect=[0, 11]), \
                contextlib.redirect_stderr(io.StringIO()) as stderr:
            self.assertEqual(routing.main(), 1)
        self.assertIn("Neovim did not start listening at /tab.sock", stderr.getvalue())

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

if __name__ == "__main__":
    unittest.main()
