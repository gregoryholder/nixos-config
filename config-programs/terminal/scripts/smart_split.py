from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    g = window.geometry
    width, height = g.right - g.left, g.bottom - g.top
    location = "vsplit" if width > height * 1.5 else "hsplit"
    boss.launch(
        f"--location={location}",
        "--cwd=current",
        f"--source-window=id:{window.id}",
        f"--next-to=id:{window.id}",
    )
