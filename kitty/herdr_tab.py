"""Give the kitty window herdr runs in herdr's terminal colors.

Loaded for every window by `watcher herdr_tab.py` in kitty.conf. When the
shell starts a herdr client (`herdr`, `herdr --session NAME`, `herdr --remote
HOST`, `herdr session attach NAME`), that window alone takes
~/.config/kitty/herdr-colors.conf (written by herdr-theme). When the command
ends (quit or detach), the window gets kitty's theme back
(~/.config/kitty/current-theme.conf). Other windows are never touched.

Opacity: kitty applies background_opacity to every default-background cell of
an OS window, and herdr's panes use the default background. So while a herdr
window is the one in front, its OS window is made fully opaque (solid panes),
and switching to any other window restores the configured opacity. herdr's
chrome keeps its own translucency from the theme's transparent_background_colors.
This needs `dynamic_background_opacity yes`, which kitty reads only at startup.

Uses kitty's shell integration (on_cmd_startstop), so it works however `herdr`
resolves on PATH. herdr does not forward its panes' shell-integration marks to
kitty, so commands run inside herdr never reach this watcher.
"""

import os
import shlex
from typing import Any

from kitty.boss import Boss
from kitty.fast_data_types import get_options
from kitty.window import Window

HERE = os.path.dirname(os.path.abspath(__file__))
HERDR_COLORS = os.path.join(HERE, "herdr-colors.conf")
KITTY_THEME = os.path.join(HERE, "current-theme.conf")

# Windows currently wearing herdr's colors.
_tinted: set[int] = set()


def _is_herdr_client(cmdline: str) -> bool:
    try:
        argv = shlex.split(cmdline)
    except ValueError:
        return False
    # Leading VAR=value assignments, as in `HERDR_SESSION=x herdr`.
    while argv and "=" in argv[0] and not argv[0].startswith("-"):
        argv.pop(0)
    if not argv or os.path.basename(argv[0]) != "herdr":
        return False
    args = argv[1:]
    return not args or args[0] in ("--session", "--remote") or args[:2] == ["session", "attach"]


def _has_colors() -> bool:
    try:
        with open(HERDR_COLORS) as f:
            return any(line.split(None, 1)[:1] in (["background"], ["foreground"]) for line in f)
    except OSError:
        return False


def _set_colors(boss: Boss, window: Window, path: str) -> None:
    match = f"--match=id:{window.id}"
    # set-colors only changes keys the file names, so drop any translucent
    # colors first; a herdr theme that wants them sets them again.
    boss.call_remote_control(window, ("set-colors", match, "transparent_background_colors="))
    boss.call_remote_control(window, ("set-colors", match, path))


def _set_opacity(boss: Boss, window: Window, herdr_in_front: bool) -> None:
    """Solid while a herdr window is in front, the configured opacity otherwise."""
    opacity = 1.0 if herdr_in_front else get_options().background_opacity
    try:
        boss.call_remote_control(
            window, ("set-background-opacity", f"--match=id:{window.id}", str(opacity))
        )
    except Exception:
        # dynamic_background_opacity is off (kitty not restarted since it was
        # enabled): colors still apply, only the opacity switch is skipped.
        pass


def on_cmd_startstop(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if data.get("is_start"):
        if _is_herdr_client(data.get("cmdline", "")) and _has_colors():
            _set_colors(boss, window, HERDR_COLORS)
            _tinted.add(window.id)
            if boss.active_window is window:
                _set_opacity(boss, window, True)
    elif window.id in _tinted:
        _tinted.discard(window.id)
        _set_colors(boss, window, KITTY_THEME)
        if boss.active_window is window:
            _set_opacity(boss, window, False)


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    # Only herdr windows act: solid while focused, configured opacity once
    # focus moves anywhere else (including tabs created before this watcher).
    if window.id in _tinted:
        _set_opacity(boss, window, bool(data.get("focused")))


def on_close(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if window.id in _tinted:
        _tinted.discard(window.id)
        _set_opacity(boss, window, False)
