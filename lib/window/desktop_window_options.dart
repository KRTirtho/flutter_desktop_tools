import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindowOptions extends WindowOptions {
  /// Sets whether the window should have a shadow. On Windows, doesn't do anything unless window is frameless.
  /// @platforms macos,windows
  final bool hasShadow;

  /// Move the window to a position aligned with the screen.
  final Alignment alignment;

  /// hides the surrounding frame of desktop window
  final bool hideWindowFrame;

  /// Sets the icon of the taskbar entry for the window.
  /// @platforms windows
  final String? taskbarIcon;

  /// Sets whether the window should be shown on the taskbar.
  final bool showOnTaskbar;

  /// Whether to remember the window size when the window is resized
  final bool rememberWindowSize;

  /// Brightness of the window
  final Brightness? windowBrightness;

  /// The window will maintain an aspect ratio when resized.
  final double? aspectRatio;

  final bool resizable;

  final double? opacity;
  final Offset? position;
  DesktopWindowOptions({
    bool hideTitleBar = false,
    this.hasShadow = true,
    this.alignment = Alignment.center,
    this.hideWindowFrame = false,
    this.showOnTaskbar = true,
    this.rememberWindowSize = true,
    this.resizable = true,
    this.aspectRatio,
    this.opacity,
    this.position,
    this.windowBrightness,
    this.taskbarIcon,
    super.alwaysOnTop,
    super.backgroundColor,
    super.fullScreen,
    super.maximumSize,
    super.minimumSize,
    super.size,
    super.title,
  }) : super(
          titleBarStyle:
              hideTitleBar ? TitleBarStyle.hidden : TitleBarStyle.normal,
          center: alignment == Alignment.center,
        );
}
