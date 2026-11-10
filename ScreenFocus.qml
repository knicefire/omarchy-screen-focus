import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// The workspace number of the screen this bar belongs to, in the accent colour
// when that screen has keyboard focus and faded when it does not.
//
// Two things the stock widgets leave out: omarchy.workspaces replaces the
// shown workspace's number with a layout glyph, so the number you most want to
// read is the one it hides; and nothing in the bar says which screen the
// keyboard is typing into, though every bar knows.
//
// New code built on the public qs.Ui API, not a copy of a built-in widget, so
// an Omarchy update has no counterpart of this file to drift away from.
BarWidget {
  id: root
  moduleName: "knicefire.screen-focus"

  // One bar surface exists per monitor, so this surface's own screen is the
  // monitor this copy speaks for. focusedMonitor is only a stand-in for a
  // surface that has not been mapped to a screen yet.
  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property string monitorName: root.monitor ? root.monitor.name : ""

  // Compared by id rather than reading monitor.focused, so the binding
  // re-evaluates when Quickshell retracks the focused monitor.
  readonly property bool focused: root.monitor !== null
    && Hyprland.focusedMonitor !== null
    && Hyprland.focusedMonitor.id === root.monitor.id

  readonly property int workspaceId: root.monitor && root.monitor.activeWorkspace
    ? root.monitor.activeWorkspace.id : -1

  // Hyprland gives each monitor a block of ten workspaces (1-10, 11-20, ...),
  // and every bar labels its own block 1-10. 10 is keyed as 0, as on the
  // keyboard row.
  readonly property string slotText: {
    if (root.workspaceId <= 0) return "-"
    var slot = (root.workspaceId - 1) % 10 + 1
    return slot === 10 ? "0" : String(slot)
  }

  readonly property real inactiveOpacity:
    Math.max(0, Math.min(100, root.setting("inactiveOpacity", 100))) / 100

  // With one screen there is nothing to tell apart, so the widget steps out of
  // the way rather than marking the only screen there is. Counted off
  // Hyprland's monitor list, which tracks hotplugs, so it comes back by itself
  // when a second screen is connected.
  readonly property int monitorCount:
    Hyprland.monitors && Hyprland.monitors.values ? Hyprland.monitors.values.length : 1
  readonly property bool hideWhenSingleScreen: root.setting("hideWhenSingleScreen", true) === true
  readonly property bool shown: root.monitorCount > 1 || !root.hideWhenSingleScreen

  // The badge's own size, rather than the text's. Wider than it is tall, so it
  // reads as a pill and not as another rounded square like the layout glyph
  // omarchy.workspaces draws for the workspace it shows. All three go through
  // Style.space(), so they follow the spacing scale like everything else.
  readonly property real pillWidth: Style.space(root.setting("pillWidth", 26))
  readonly property real pillHeight: Style.space(root.setting("pillHeight", 18))
  readonly property real pillRadius: Style.space(root.setting("pillRadius", 7))

  // Zero width when hidden, so it gives its slot back instead of leaving a gap.
  visible: root.shown
  implicitWidth: root.shown ? button.implicitWidth : 0
  implicitHeight: root.shown ? button.implicitHeight : 0

  // A filled badge in both states, so the number always reads as "this screen"
  // rather than as one more entry in the workspace row beside it. Only the
  // fill changes: the accent when this screen has focus, the theme's muted
  // grey when it does not.
  Rectangle {
    anchors.centerIn: button
    width: root.pillWidth
    height: root.pillHeight
    radius: root.pillRadius
    color: root.focused ? Color.accent : Color.muted
    opacity: button.opacity
  }

  function focusThisScreen() {
    if (!root.bar || root.focused || !root.monitorName) return
    root.bar.run("hyprctl dispatch "
      + Util.shellQuote('hl.dsp.focus({ monitor = "' + root.monitorName + '" })'))
  }

  WidgetButton {
    id: button
    bar: root.bar
    text: root.slotText

    // Dark text, because it sits on a filled badge in both states.
    foreground: Color.bar.background
    opacity: root.focused ? 1 : root.inactiveOpacity

    tooltipText: root.monitorName
      + (root.workspaceId > 0 ? " · workspace " + root.slotText : "")
      + (root.focused ? "" : " · not focused")

    // The bar's own active colour is the theme's urgent red; focus is not an
    // alert, so the accent carries it instead.
    useActiveColor: false
    horizontalMargin: 5
    verticalPadding: 5
    fixedWidth: root.vertical
      ? -1
      : Math.max(Style.bar.statusSlot, root.pillWidth + Style.space(4))
    fixedHeight: root.vertical ? Style.bar.statusSlot : -1
    onPressed: function(mouseButton) { root.focusThisScreen() }
  }
}
