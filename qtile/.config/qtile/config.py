# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import shutil
import subprocess
import os

from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod4"
terminal = "alacritty"
menu = "rofi -show run"
system_font = "IntoneMono Nerd Font Mono"
home_dir = os.path.expanduser("~")
logo = ""

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn(menu)),
]

group_labels = ["", "", "", "󰲦", "󰲨", "󰲪", "󰲬", "󰲮", "󰲰"]
group_class_matches = [
    ["Alacritty"],
    ["firefox", "Chrome", "Brave"],
    ["Thunar"],
    [],  # TODO: figure out catch all for other windows
    [],
    [],
    [],
    [],
    [],
]


def wm_class_matches(index):
    return [Match(wm_class=j) for j in group_class_matches[index]]


groups = [
    Group(i, label=group_labels[int(i) - 1], matches=wm_class_matches(int(i) - 1))
    for i in "123456789"
]


for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layout_theme = {
    "border_width": 2,
    "margin": 5,
    "font": system_font,
    "font_size": 14,
    "border_focus": "#f5e0dc",
    "border_normal": "#1e1e2e",
}

colors = [
    ["#11111b", "#11111b"],  # mantle dark
    ["#1e1e2e", "#1e1e2e"],  # base dark
    ["#f5e0dc", "#f5e0dc"],  # rosewater
    ["#f38ba8", "#f38ba8"],  # red
    ["#a6e3a1", "#a6e3a1"],  # green
    ["#f9e2af", "#f9e2af"],  # yellow
    ["#b4befe", "#b4befe"],  # lavender
    ["#f5c2e7", "#f5c2e7"],  # pink
    ["#74c7ec", "#74c7ec"],  # sapphire
    ["#cdd6f4", "#cdd6f4"],  # ghost
]

layouts = [
    layout.Columns(**layout_theme),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font=system_font,
    fontsize=14,
    padding=2,
)
extension_defaults = widget_defaults.copy()


def format_bytes(num_bytes):
    power = 2**10
    n = 0
    power_labels = {0: "", 1: "K", 2: "M", 3: "G", 4: "T"}
    while num_bytes > power:
        num_bytes /= power
        n += 1
    return f"{round(num_bytes, 2)}{power_labels[n]}"


def diskspace(mode):
    total, used, free = shutil.disk_usage("/")
    data_disk = {
        "DiskUsage": f"{format_bytes(used)} / {format_bytes(total)}",
        "FreeSpace": f"{format_bytes(free)}",
    }
    return data_disk[mode]


def init_widgets_list():
    widgets = [
        widget.TextBox(
            font=system_font,
            fontsize=24,
            padding=12,
            text=logo,
            foreground=colors[9],
            background=colors[1],
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(menu)},
        ),
        widget.GroupBox(
            font=system_font,
            fontsize=18,
            foreground=colors[2],
            background=colors[1],
            borderWidth=4,
            highlight_method="text",
            this_current_screen_border=colors[8],
            active=colors[5],
            inactive=colors[9],
        ),
        widget.Spacer(length=bar.STRETCH, background=colors[1]),
        widget.WindowTabs(foreground=colors[6], background=colors[1]),
        widget.Spacer(length=bar.STRETCH, background=colors[1]),
        widget.TextBox(
            font=system_font,
            fontsize=24,
            text="󰻠",
            foreground=colors[7],
            background=colors[1],
        ),
        widget.CPU(
            format="{load_percent}%",
            foreground=colors[9],
            background=colors[1],
            update_interval=2,
        ),
        widget.TextBox(
            font=system_font,
            fontsize=24,
            text=" ",
            foreground=colors[4],
            background=colors[1],
        ),
        widget.Memory(
            format="{MemUsed:.0f}{mm}",
            foreground=colors[9],
            background=colors[1],
            update_interval=2,
        ),
        widget.TextBox(
            font=system_font,
            fontsize=24,
            text=" 󰥔",
            foreground=colors[6],
            background=colors[1],
        ),
        widget.Clock(
            format="%d,%B %I:%M%p", foreground=colors[9], background=colors[1]
        ),
        widget.Systray(background=colors[1]),
        widget.Spacer(length=5, background=colors[1]),
    ]
    return widgets


screens = [
    Screen(
        top=bar.Bar(widgets=init_widgets_list(), size=30),
        wallpaper=f"{home_dir}/.config/qtile/wallpapers/primary",
    ),
    Screen(
        top=bar.Bar(widgets=init_widgets_list(), size=30),
        wallpaper=f"{home_dir}/.config/qtile/wallpapers/secondary",
    ),
    # Add more screens if needed
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]


@hook.subscribe.startup_once
def autostart():
    start = os.path.expanduser(f"{home_dir}/.config/qtile/scripts/autostart.sh")
    subprocess.call([start])


dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
