library flutter_desktop_tools;

export 'package:window_manager/window_manager.dart'
    hide windowManager, WindowOptions;
export 'package:system_tray/system_tray.dart';

export 'package:flutter_desktop_tools/window/desktop_window_options.dart';
export 'package:flutter_desktop_tools/widgets/titlebar_buttons.dart';
export 'package:flutter_desktop_tools/widgets/titlebar.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_desktop_tools/utils/platform.dart';
import 'package:flutter_desktop_tools/window/desktop_window_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

late SharedPreferences _preferences;

final _instance = DesktopTools._();

enum SystemTrayEvent {
  click,
  doubleClick,
  rightClick;

  static SystemTrayEvent fromString(String event) {
    switch (event) {
      case kSystemTrayEventClick:
        return SystemTrayEvent.click;
      case kSystemTrayEventDoubleClick:
        return SystemTrayEvent.doubleClick;
      case kSystemTrayEventRightClick:
        return SystemTrayEvent.rightClick;
      default:
        throw Exception("Unknown event: $event");
    }
  }
}

class DesktopTools with WidgetsBindingObserver {
  DesktopTools._();
  factory DesktopTools() => _instance;

  static WindowManager get window => windowManager;
  static SafePlatform get platform => SafePlatform();

  static Future<void> ensureInitialized([DesktopWindowOptions? options]) async {
    options ??= DesktopWindowOptions();
    _preferences = await SharedPreferences.getInstance();

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(DesktopTools());

    await window.ensureInitialized();
    await window.waitUntilReadyToShow(options, () async {
      await window.setHasShadow(options!.hasShadow);
      await window.setAlignment(options.alignment);
      await window.setSkipTaskbar(!options.showOnTaskbar);
      if (options.aspectRatio != null) {
        await window.setAspectRatio(options.aspectRatio!);
      }
      if (options.windowBrightness != null) {
        await window.setBrightness(options.windowBrightness!);
      }
      if (options.opacity != null) {
        await window.setOpacity(options.opacity!);
      }
      if (options.position != null) {
        await window.setPosition(options.position!);
      }
      if (options.taskbarIcon != null) {
        await window.setIcon(options.taskbarIcon!);
      }
      if (options.hideWindowFrame) await window.setAsFrameless();
      if (options.rememberWindowSize == true) {
        final savedSize =
            json.decode(_preferences.getString(_windowSizeKey) ?? "{}");
        final double? height = savedSize?["height"];
        final double? width = savedSize?["width"];

        if (savedSize?["maximized"] == true) {
          await windowManager.maximize();
        } else if (height != null && width != null) {
          await windowManager.setSize(Size(width, height));
        }
      }

      await window.show();
    });
  }

  /// Windows requires using .ico so a different path is required
  static Future<SystemTray> createSystemTrayMenu({
    required String title,
    required String iconPath,
    required String windowsIconPath,
    required List<MenuItem> items,
    String? tooltip,
    FutureOr<void> Function(SystemTrayEvent event, SystemTray tray)? onEvent,
  }) async {
    final SystemTray systemTray = SystemTray();
    await systemTray.initSystemTray(
      title: title,
      iconPath: platform.isWindows ? windowsIconPath : iconPath,
      toolTip: tooltip,
    );
    final Menu menu = Menu();
    await menu.buildFrom(items);
    await systemTray.setContextMenu(menu);
    if (onEvent != null) {
      systemTray.registerSystemTrayEventHandler(
        (event) async {
          return onEvent(SystemTrayEvent.fromString(event), systemTray);
        },
      );
    }
    return systemTray;
  }

  static const _windowSizeKey = "window_size";

  Size? _prevSize;

  @override
  void didChangeMetrics() async {
    super.didChangeMetrics();
    if (platform.isMobile) return;
    final size = await window.getSize();
    final windowSameDimension =
        _prevSize?.width == size.width && _prevSize?.height == size.height;

    if (windowSameDimension) return;
    final isMaximized = await window.isMaximized();
    await _preferences.setString(
      _windowSizeKey,
      jsonEncode({
        'maximized': isMaximized,
        'width': size.width,
        'height': size.height,
      }),
    );
    _prevSize = size;
  }
}
