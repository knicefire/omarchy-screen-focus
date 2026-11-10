# Screen focus

An Omarchy bar widget that shows **which workspace this screen is on, and
whether this screen has keyboard focus**.

![one badge per monitor](docs/bar.png)

Omarchy draws one bar per monitor, and each bar knows which monitor it belongs
to — but nothing in the bar says so. This widget does, and fills a second gap
while it is there: `omarchy.workspaces` replaces the shown workspace's number
with a layout glyph, so the number you most want to read is the one it hides.

- The number is this monitor's active workspace, labelled 1–10 within that
  monitor's block (Hyprland numbers them 1–10, 11–20, and so on).
- The badge behind it is `accent` when this screen holds keyboard focus and
  `muted` when it does not. Nothing else changes between the two states.
- Click it to focus that screen.
- Hover for `<monitor> · workspace <n>`.
- With one monitor connected it hides itself and gives its slot back.

## Install

```bash
git clone https://github.com/knicefire/omarchy-screen-focus \
  ~/.config/omarchy/plugins/knicefire.screen-focus
omarchy bar put knicefire.screen-focus --section left
```

Omarchy reloads plugins on change. If the widget does not appear, run
`omarchy restart shell` — a plugin rescan refreshes only some bar surfaces, so
on a multi-monitor setup check every bar before concluding nothing happened.

## Settings

Set with `omarchy bar set knicefire.screen-focus <key> <value> --json`, or edit
the widget's entry in `~/.config/omarchy/shell.json`.

| Key | Default | What it does |
| --- | --- | --- |
| `hideWhenSingleScreen` | `true` | Hide while only one monitor is connected. |
| `inactiveOpacity` | `100` | Extra fade on unfocused screens, in percent. |
| `pillWidth` | `20` | Badge width, before the spacing scale. |
| `pillHeight` | `20` | Badge height. The horizontal bar is 26px tall. |
| `pillRadius` | `0` | Corner radius. Half the height gives a circle. |

Shapes worth trying: `20/20/0` a square, `20/20/10` a circle, `26/18/7` a wide
pill.

## Notes

Written against the public `qs.Ui` API rather than cloned from a built-in
widget, so an Omarchy update has no counterpart of this file to overwrite or
drift away from. Tested on Omarchy 4.5.0, Hyprland 0.56.2.

A bar surface finds its own monitor with
`Hyprland.monitorFor(QsWindow.window.screen)`. It is built on `WidgetButton`
rather than `BarIndicator`, because `BarIndicator` force-writes `opacity`
whenever its `active` changes, which fights a widget that must stay visible
while inactive.

## Licence

MIT
