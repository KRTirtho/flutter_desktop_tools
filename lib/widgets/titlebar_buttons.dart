import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_desktop_tools/flutter_desktop_tools.dart';

import 'package:titlebar_buttons/titlebar_buttons.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class WindowTitleBarButtons extends StatefulWidget {
  final Color? foregroundColor;

  /// If true, the window will be hidden when the minimize button is pressed.
  ///
  /// Best used in combination with system tray.
  final bool hideWindowOnMinimize;

  final FutureOr<void> Function()? onMinimize;
  final FutureOr<void> Function()? onMaximize;
  final FutureOr<void> Function()? onUnmaximize;
  final FutureOr<void> Function()? onClose;

  const WindowTitleBarButtons({
    Key? key,
    this.foregroundColor,
    this.hideWindowOnMinimize = true,
    this.onMinimize,
    this.onMaximize,
    this.onUnmaximize,
    this.onClose,
  }) : super(key: key);

  @override
  State<WindowTitleBarButtons> createState() => _WindowTitleBarButtonsState();
}

class _WindowTitleBarButtonsState extends State<WindowTitleBarButtons>
    with WindowListener {
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (DesktopTools.platform.isDesktop) {
      DesktopTools.window.isMaximized().then((value) {
        setState(() {
          isMaximized = value;
        });
      });
    }
  }

  void onMinimize() async {
    if (widget.hideWindowOnMinimize) {
      await DesktopTools.window.hide();
    } else {
      await DesktopTools.window.minimize();
    }

    await widget.onMinimize?.call();
  }

  Future<void> onMaximize() async {
    DesktopTools.window.maximize();
    setState(() {
      isMaximized = true;
    });

    await widget.onMaximize?.call();
  }

  Future<void> onUnmaximize() async {
    await DesktopTools.window.unmaximize();
    setState(() {
      isMaximized = false;
    });

    await widget.onUnmaximize?.call();
  }

  void onClose() async {
    await DesktopTools.window.close();
    await widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    const type = ThemeType.auto;
    if (!DesktopTools.platform.isDesktop || DesktopTools.platform.isMacOS) {
      return const SizedBox.shrink();
    }

    if (DesktopTools.platform.isWindows) {
      final theme = Theme.of(context);
      final foregroundColor =
          widget.foregroundColor ?? theme.colorScheme.onBackground;

      final colors = WindowButtonColors(
        normal: Colors.transparent,
        iconNormal: foregroundColor,
        mouseOver: foregroundColor.withOpacity(0.1),
        mouseDown: foregroundColor.withOpacity(0.2),
        iconMouseOver: foregroundColor,
        iconMouseDown: foregroundColor,
      );

      final closeColors = WindowButtonColors(
        normal: Colors.transparent,
        iconNormal: foregroundColor,
        mouseOver: Colors.red,
        mouseDown: Colors.red[800]!,
        iconMouseOver: Colors.white,
        iconMouseDown: Colors.black,
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MinimizeWindowButton(
              onPressed: onMinimize,
              colors: colors,
            ),
            if (!isMaximized)
              MaximizeWindowButton(
                colors: colors,
                onPressed: onMaximize,
              )
            else
              RestoreWindowButton(
                colors: colors,
                onPressed: onUnmaximize,
              ),
            CloseWindowButton(
              colors: closeColors,
              onPressed: onClose,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedMinimizeButton(
            type: type,
            onPressed: onMinimize,
          ),
          DecoratedMaximizeButton(
            type: type,
            onPressed: () async {
              if (await DesktopTools.window.isMaximized()) {
                await onUnmaximize();
              } else {
                await onMaximize();
              }
            },
          ),
          DecoratedCloseButton(
            type: type,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

typedef WindowButtonIconBuilder = Widget Function(
    WindowButtonContext buttonContext);
typedef WindowButtonBuilder = Widget Function(
    WindowButtonContext buttonContext, Widget icon);

class WindowButtonContext {
  BuildContext context;
  MouseState mouseState;
  Color? backgroundColor;
  Color iconColor;
  WindowButtonContext(
      {required this.context,
      required this.mouseState,
      this.backgroundColor,
      required this.iconColor});
}

class WindowButtonColors {
  late Color normal;
  late Color mouseOver;
  late Color mouseDown;
  late Color iconNormal;
  late Color iconMouseOver;
  late Color iconMouseDown;
  WindowButtonColors(
      {Color? normal,
      Color? mouseOver,
      Color? mouseDown,
      Color? iconNormal,
      Color? iconMouseOver,
      Color? iconMouseDown}) {
    this.normal = normal ?? _defaultButtonColors.normal;
    this.mouseOver = mouseOver ?? _defaultButtonColors.mouseOver;
    this.mouseDown = mouseDown ?? _defaultButtonColors.mouseDown;
    this.iconNormal = iconNormal ?? _defaultButtonColors.iconNormal;
    this.iconMouseOver = iconMouseOver ?? _defaultButtonColors.iconMouseOver;
    this.iconMouseDown = iconMouseDown ?? _defaultButtonColors.iconMouseDown;
  }
}

final _defaultButtonColors = WindowButtonColors(
  normal: Colors.transparent,
  iconNormal: const Color(0xFF805306),
  mouseOver: const Color(0xFF404040),
  mouseDown: const Color(0xFF202020),
  iconMouseOver: const Color(0xFFFFFFFF),
  iconMouseDown: const Color(0xFFF0F0F0),
);

class WindowButton extends StatelessWidget {
  final WindowButtonBuilder? builder;
  final WindowButtonIconBuilder? iconBuilder;
  late final WindowButtonColors colors;
  final bool animate;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;

  WindowButton(
      {Key? key,
      WindowButtonColors? colors,
      this.builder,
      @required this.iconBuilder,
      this.padding,
      this.onPressed,
      this.animate = false})
      : super(key: key) {
    this.colors = colors ?? _defaultButtonColors;
  }

  Color getBackgroundColor(MouseState mouseState) {
    if (mouseState.isMouseDown) return colors.mouseDown;
    if (mouseState.isMouseOver) return colors.mouseOver;
    return colors.normal;
  }

  Color getIconColor(MouseState mouseState) {
    if (mouseState.isMouseDown) return colors.iconMouseDown;
    if (mouseState.isMouseOver) return colors.iconMouseOver;
    return colors.iconNormal;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container();
    } else {
      // Don't show button on macOS
      if (Platform.isMacOS) {
        return Container();
      }
    }

    return MouseStateBuilder(
      builder: (context, mouseState) {
        WindowButtonContext buttonContext = WindowButtonContext(
            mouseState: mouseState,
            context: context,
            backgroundColor: getBackgroundColor(mouseState),
            iconColor: getIconColor(mouseState));

        var icon =
            (iconBuilder != null) ? iconBuilder!(buttonContext) : Container();

        var fadeOutColor =
            getBackgroundColor(MouseState()..isMouseOver = true).withOpacity(0);
        var padding = this.padding ?? const EdgeInsets.all(10);
        var animationMs =
            mouseState.isMouseOver ? (animate ? 100 : 0) : (animate ? 200 : 0);
        Widget iconWithPadding = Padding(padding: padding, child: icon);
        iconWithPadding = AnimatedContainer(
            curve: Curves.easeOut,
            duration: Duration(milliseconds: animationMs),
            color: buttonContext.backgroundColor ?? fadeOutColor,
            child: iconWithPadding);
        var button =
            (builder != null) ? builder!(buttonContext, icon) : iconWithPadding;
        return SizedBox(
          width: 45,
          height: 32,
          child: button,
        );
      },
      onPressed: () {
        if (onPressed != null) onPressed!();
      },
    );
  }
}

class MinimizeWindowButton extends WindowButton {
  MinimizeWindowButton(
      {Key? key,
      WindowButtonColors? colors,
      VoidCallback? onPressed,
      bool? animate})
      : super(
          key: key,
          colors: colors,
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              MinimizeIcon(color: buttonContext.iconColor),
          onPressed: onPressed,
        );
}

class MaximizeWindowButton extends WindowButton {
  MaximizeWindowButton(
      {Key? key,
      WindowButtonColors? colors,
      VoidCallback? onPressed,
      bool? animate})
      : super(
          key: key,
          colors: colors,
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              MaximizeIcon(color: buttonContext.iconColor),
          onPressed: onPressed,
        );
}

class RestoreWindowButton extends WindowButton {
  RestoreWindowButton(
      {Key? key,
      WindowButtonColors? colors,
      VoidCallback? onPressed,
      bool? animate})
      : super(
          key: key,
          colors: colors,
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              RestoreIcon(color: buttonContext.iconColor),
          onPressed: onPressed,
        );
}

final _defaultCloseButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: const Color(0xFFFFFFFF));

class CloseWindowButton extends WindowButton {
  CloseWindowButton(
      {Key? key,
      WindowButtonColors? colors,
      VoidCallback? onPressed,
      bool? animate})
      : super(
          key: key,
          colors: colors ?? _defaultCloseButtonColors,
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              CloseIcon(color: buttonContext.iconColor),
          onPressed: onPressed,
        );
}

// Switched to CustomPaint icons by https://github.com/esDotDev

/// Close
class CloseIcon extends StatelessWidget {
  final Color color;
  const CloseIcon({Key? key, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topLeft,
        child: Stack(children: [
          // Use rotated containers instead of a painter because it renders slightly crisper than a painter for some reason.
          Transform.rotate(
              angle: pi * .25,
              child:
                  Center(child: Container(width: 14, height: 1, color: color))),
          Transform.rotate(
              angle: pi * -.25,
              child:
                  Center(child: Container(width: 14, height: 1, color: color))),
        ]),
      );
}

/// Maximize
class MaximizeIcon extends StatelessWidget {
  final Color color;
  const MaximizeIcon({Key? key, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) => _AlignedPaint(_MaximizePainter(color));
}

class _MaximizePainter extends _IconPainter {
  _MaximizePainter(Color color) : super(color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width - 1, size.height - 1), p);
  }
}

/// Restore
class RestoreIcon extends StatelessWidget {
  final Color color;
  const RestoreIcon({
    Key? key,
    required this.color,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => _AlignedPaint(_RestorePainter(color));
}

class _RestorePainter extends _IconPainter {
  _RestorePainter(Color color) : super(color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 2, size.width - 2, size.height), p);
    canvas.drawLine(const Offset(2, 2), const Offset(2, 0), p);
    canvas.drawLine(const Offset(2, 0), Offset(size.width, 0), p);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height - 2), p);
    canvas.drawLine(Offset(size.width, size.height - 2),
        Offset(size.width - 2, size.height - 2), p);
  }
}

/// Minimize
class MinimizeIcon extends StatelessWidget {
  final Color color;
  const MinimizeIcon({Key? key, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) => _AlignedPaint(_MinimizePainter(color));
}

class _MinimizePainter extends _IconPainter {
  _MinimizePainter(Color color) : super(color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
  }
}

/// Helpers
abstract class _IconPainter extends CustomPainter {
  _IconPainter(this.color);
  final Color color;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlignedPaint extends StatelessWidget {
  const _AlignedPaint(this.painter, {Key? key}) : super(key: key);
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: CustomPaint(size: const Size(10, 10), painter: painter));
  }
}

Paint getPaint(Color color, [bool isAntiAlias = false]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..isAntiAlias = isAntiAlias
  ..strokeWidth = 1;

typedef MouseStateBuilderCB = Widget Function(
    BuildContext context, MouseState mouseState);

class MouseState {
  bool isMouseOver = false;
  bool isMouseDown = false;
  MouseState();
  @override
  String toString() {
    return "isMouseDown: $isMouseDown - isMouseOver: $isMouseOver";
  }
}

T? _ambiguate<T>(T? value) => value;

class MouseStateBuilder extends StatefulWidget {
  final MouseStateBuilderCB builder;
  final VoidCallback? onPressed;
  const MouseStateBuilder({Key? key, required this.builder, this.onPressed})
      : super(key: key);
  @override
  _MouseStateBuilderState createState() => _MouseStateBuilderState();
}

class _MouseStateBuilderState extends State<MouseStateBuilder> {
  late MouseState _mouseState;
  _MouseStateBuilderState() {
    _mouseState = MouseState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (event) {
          setState(() {
            _mouseState.isMouseOver = true;
          });
        },
        onExit: (event) {
          setState(() {
            _mouseState.isMouseOver = false;
          });
        },
        child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                _mouseState.isMouseDown = true;
              });
            },
            onTapCancel: () {
              setState(() {
                _mouseState.isMouseDown = false;
              });
            },
            onTap: () {
              setState(() {
                _mouseState.isMouseDown = false;
                _mouseState.isMouseOver = false;
              });
              _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
                if (widget.onPressed != null) {
                  widget.onPressed!();
                }
              });
            },
            onTapUp: (_) {},
            child: widget.builder(context, _mouseState)));
  }
}
