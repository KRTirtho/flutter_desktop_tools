import 'dart:io';

import 'package:flutter/foundation.dart';

final SafePlatform _platform = SafePlatform._();

class SafePlatform {
  SafePlatform._();

  factory SafePlatform() => _platform;

  String? get linuxDesktop =>
      !isLinux ? null : Platform.environment["XDG_CURRENT_DESKTOP"];

  String? get linuxSession =>
      !isLinux ? null : Platform.environment["XDG_SESSION_TYPE"];

  bool get isWeb => kIsWeb;
  bool get isDesktop => isLinux || isWindows || isMacOS;
  bool get isMobile => isAndroid || isIOS;

  bool get isMacOS => kIsWeb ? false : Platform.isMacOS;
  bool get isLinux => kIsWeb ? false : Platform.isLinux;
  bool get isAndroid => kIsWeb ? false : Platform.isAndroid;
  bool get isIOS => kIsWeb ? false : Platform.isIOS;
  bool get isWindows => kIsWeb ? false : Platform.isWindows;

  bool get isGnome => kIsWeb ? false : linuxDesktop == "GNOME";
  bool get isKDE => kIsWeb ? false : linuxDesktop == "KDE";
  bool get isCinnamon => kIsWeb ? false : linuxDesktop == "Cinnamon";
  bool get isMATE => kIsWeb ? false : linuxDesktop == "MATE";

  bool get isFlatpak =>
      kIsWeb ? false : Platform.environment["FLATPAK_ID"] != null;
  bool get isSnap => kIsWeb ? false : Platform.environment["SNAP"] != null;
  bool get isAppImage =>
      kIsWeb ? false : Platform.environment["APPIMAGE"] != null;
  bool get isBrew =>
      kIsWeb ? false : Platform.environment["HOMEBREW_PREFIX"] != null;

  bool get isWayland => kIsWeb ? false : linuxSession == "wayland";
  bool get isX11 => kIsWeb ? false : linuxSession == "x11";
}
