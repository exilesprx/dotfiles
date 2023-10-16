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

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod4"
terminal = "alacritty"
system_font = "IntoneMono Nerd Font Mono"
home_dir = os.path.expanduser("~")

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
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
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
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

groups = [Group(i) for i in "123456789"]

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
    "border_width": 3,
    "margin": 15,
    "font": system_font,
    "font_size": 12,
    "border_focus": "#bd93f9",
    "border_normal": "#555555"
    }

colors = [
        ["#232a36", "#282a36"],
        ["#282a36", "#282a36"],
        ["#f8f8f2", "#f8f8f1"],
        ["#ff5555", "#ff5555"],
        ["#50fa7b", "#50fa7b"],
        ["#f1fa8c", "#f1fa8c"],
        ["#bd93f9", "#bd93f9"],
        ["#ff79c6", "#ff79c6"],
        ["#8be9fd", "#8be9fd"],
        ["#bbbbbb", "#bbbbbb"]
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
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

def format_bytes(num_bytes):
    power = 2**10
    n = 0
    power_labels = {0: '', 1: 'K', 2: 'M', 3: 'G', 4: 'T'}
    while num_bytes > power:
        num_bytes /= power
        n += 1
    return f"{round(num_bytes, 2)}{power_labels[n]}"

def diskspace(mode):
    total, used, free = shutil.disk_usage('/')
    data_disk = {
            'DiskUsage': f'{format_bytes(used)} / {format_bytes(total)}',
            'FreeSpace': f'{format_bytes(free)}'
        }
    return data_disk[mode]

def init_widgets_list(): 
    widgets = [
       widget.Spacer(
           length = 5,
           background = colors[1]
       ),
       widget.Image(
           filename = "/usr/share/pixmaps/archlinux-logo.png",
           background = colors[1],
           margin = 3,
           mouse_callbacks = {
               'Button1': lambda: qtile.cmd_spawn(
                   'j4-dmenu'
                ),
               'Button3': lambda: qtile.cmd_spawn(
                   f'alacritty -e vim {home_dir}/.config/qtile/config.py'
                )
             }
        ),
       widget.GroupBox(
           font = system_font,
           fontsize = 14,
           foreground = colors[2],
           background = colors[1],
           borderWidth = 4,
           hightlight_method = "text",
           this_current_screen_border = colors[6],
           active = colors[4],
           inactive = colors[2]
        ),
       widget.Sep(
           size_percent = 60,
           margin = 5,
           linewidth = 2,
           background = colors[1],
           foreground = "#555555"
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = "",
           foreground = colors[6],
           background = colors[1]
        ),
       widget.Volume(
           foreground = colors[2],
           background = colors[1]
       ),
       widget.Spacer(
           length = bar.STRETCH,
           background = colors[1]
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = " 󰍹",
           foreground = colors[3],
           background = colors[1]
        ),
       widget.CurrentLayout(
           foreground = colors[2],
           background = colors[1]
        ),
       widget.Sep(
           size_percent = 60,
           margin = 5,
           linewidth = 2,
           background = colors[1],
           foreground = "#555555"
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = "󰻠",
           foreground = colors[3],
           background = colors[1]
        ),
       widget.CPU(
           format = "{load_percent}%",
           foreground = colors[2],
           background = colors[1],
           update_interval = 2,
           mouse_callbacks = {
               'Button1': lambda: qtile.cmd_spawn(f"{terminal} -e gtop")
            }
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = " ",
           foreground = colors[4],
           background = colors[1]
        ),
       widget.Memory(
           format = "{MemUsed:.0f}{mm}",
           foreground = colors[2],
           background = colors[1],
           update_interval = 2,
           mouse_callbacks = {
               'Button1': lambda: qtile.cmd_spawn(f"{terminal} -e gtop")
            }
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = " 󰋊",
           foreground = colors[6],
           background = colors[1]
        ),
       widget.GenPollText(
           foreground = colors[2],
           background = colors[1],
           update_interval = 500,
           func = lambda: diskspace('FreeSpace'),
           mouse_callbacks = {
               'Button1': lambda: qtile.cmd_spawn(f"{terminal} -e gtop")
            }
        ),
       widget.Sep(
           size_percent = 60,
           margin = 5,
           linewidth = 2,
           background = colors[1],
           foreground = "#555555"
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = " ",
           foreground = colors[4],
           background = colors[1]
        ),
       widget.GenPollText(
           foreground = colors[2],
           background = colors[1],
           update_interval = 5,
           func = lambda: subprocess.check_output(f"{home_dir}/.config/qtile/scripts/num-installed-pkgs").decode("utf-8")
        ),
       widget.Spacer(
           length = bar.STRETCH,
           background = colors[1]
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = " 󰈀",
           foreground = colors[4],
           background = colors[1]
        ),
       widget.Net(
           format = "{down} ↓↑ {up}",
           foreground = colors[2],
           background = colors[1],
           update_interval = 2,
           mouse_callbacks = {
               'Button1': lambda: qtile.cmd_spawn("def-nmdmenu")
            }
        ),
       widget.Sep(
           size_percent = 60,
           margin = 5,
           linewidth = 2,
           background = colors[1],
           foreground = "#555555"
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = " ",
           foreground = colors[7],
           background = colors[1],
        ),
       widget.Clock(
           format = '%b %d-%Y',
           foreground = colors[2],
           background = colors[1]
        ),
       widget.TextBox(
           font = system_font,
           fontsize = 15,
           text = " 󰥔",
           foreground = colors[7],
           background = colors[1],
        ),
       widget.Clock(
           format = '%I:%M %p',
           foreground = colors[2],
           background = colors[1]
        ),
       widget.Systray(
           background = colors[1]
        ),
       widget.Spacer(
           length = 5,
           background = colors[1]
        )
    ]
    return widgets

screens = [
    Screen(
        top=bar.Bar(
            widgets = init_widgets_list(),
            size = 35,
            opacity = 0.9,
            margin = [5, 10, 0, 10]
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

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
