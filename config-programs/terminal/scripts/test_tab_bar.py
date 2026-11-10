import importlib.util
from pathlib import Path
import sys
from types import ModuleType
import unittest
from unittest.mock import Mock, patch


SOURCE = Path(__file__).with_name("tab_bar.py")
spec = importlib.util.spec_from_file_location("tab_bar", SOURCE)
tab_bar = importlib.util.module_from_spec(spec)
kitty = ModuleType("kitty")
fast_data_types = ModuleType("kitty.fast_data_types")
fast_data_types.get_boss = Mock()
with patch.dict(sys.modules, {"kitty": kitty, "kitty.fast_data_types": fast_data_types}):
    spec.loader.exec_module(tab_bar)


def window(shell_cwd, foreground_cwd):
    result = Mock(spec=["get_cwd_of_root_child", "get_cwd_of_child"])
    result.get_cwd_of_root_child.return_value = shell_cwd
    result.get_cwd_of_child.return_value = foreground_cwd
    return result


class TitleTests(unittest.TestCase):
    def title(self, windows):
        boss = Mock()
        boss.tab_for_id.return_value = windows
        with patch.object(tab_bar, "get_boss", return_value=boss):
            return tab_bar.draw_title({"tab_id": 1, "title": "original"})

    def test_foreground_root_does_not_replace_shell_directory(self):
        pane = window("/projects/repo", "/")
        self.assertEqual(self.title([pane]), "/projects/repo")
        pane.get_cwd_of_child.assert_not_called()

    def test_multiple_panes_use_common_shell_directory(self):
        panes = [
            window("/projects/repo/src", "/"),
            window("/projects/repo/tests", "/projects/repo/tests"),
        ]
        self.assertEqual(self.title(panes), "/projects/repo")

    def test_missing_shell_directory_uses_foreground_directory(self):
        self.assertEqual(
            self.title([window(None, "/projects/repo")]), "/projects/repo"
        )

    def test_genuine_root_shell_directory_is_preserved(self):
        self.assertEqual(self.title([window("/", "/projects/repo")]), "/")

    def test_prefix_replacements_are_preserved(self):
        for prefix, replacement in tab_bar.PREFIX_REPLACEMENTS:
            for suffix in ("", "/project"):
                with self.subTest(prefix=prefix, suffix=suffix):
                    expected = replacement + (" project" if suffix else "")
                    self.assertEqual(
                        self.title([window(prefix + suffix, "/")]), expected
                    )

    def test_unavailable_tab_or_directories_preserve_original_title(self):
        for panes in (None, [], [window(None, None)]):
            with self.subTest(panes=panes):
                self.assertEqual(self.title(panes), "original")


if __name__ == "__main__":
    unittest.main()
