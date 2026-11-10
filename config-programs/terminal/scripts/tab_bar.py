import os

from kitty.fast_data_types import get_boss


PREFIX_REPLACEMENTS = (
    ("/home/dev/workspace/affaires", "🚌"),
    ("/home/dev/.config", "⚙️"),
    ("/home/dev", "🏠"),
)


def draw_title(data):
    tab = get_boss().tab_for_id(data["tab_id"])
    if tab is None:
        return data["title"]

    directories = []
    for window in tab:
        cwd = window.get_cwd_of_root_child() or window.get_cwd_of_child()
        if cwd:
            directories.append(cwd)

    if not directories:
        return data["title"]

    try:
        common_directory = os.path.commonpath(directories)
    except ValueError:
        return data["title"]

    for (prefix, replacement) in PREFIX_REPLACEMENTS:
        prefix = os.path.normpath(prefix)
        if common_directory == prefix:
            return replacement 
        if common_directory.startswith(prefix + os.sep):
            return replacement + " " + common_directory[len(prefix) + 1:]
    return common_directory
