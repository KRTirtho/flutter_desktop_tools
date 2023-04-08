import 'package:flutter/material.dart';
import 'package:flutter_desktop_tools/flutter_desktop_tools.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconThemeData? actionsIconTheme;
  final bool? centerTitle;
  final double? titleSpacing;
  final double toolbarOpacity;
  final double? leadingWidth;
  final TextStyle? toolbarTextStyle;
  final TextStyle? titleTextStyle;
  final double? titleWidth;
  final Widget? title;

  const TitleBar({
    Key? key,
    this.actions,
    this.title,
    this.toolbarOpacity = 1,
    this.backgroundColor,
    this.actionsIconTheme,
    this.automaticallyImplyLeading = false,
    this.centerTitle,
    this.foregroundColor,
    this.leading,
    this.leadingWidth,
    this.titleSpacing,
    this.titleTextStyle,
    this.titleWidth,
    this.toolbarTextStyle,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = theme.scaffoldBackgroundColor;
    final defaultForegroundColor = theme.textTheme.bodyLarge!.color;

    return Theme(
      data: theme.copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: defaultBackgroundColor,
          foregroundColor: defaultForegroundColor,
        ),
      ),
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          if (DesktopTools.platform.isDesktop) {
            windowManager.startDragging();
          }
        },
        onVerticalDragStart: (details) {
          if (DesktopTools.platform.isDesktop) {
            windowManager.startDragging();
          }
        },
        child: AppBar(
          leading: widget.leading,
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          actions: [
            ...?widget.actions,
            WindowTitleBarButtons(
              foregroundColor: widget.foregroundColor ?? defaultForegroundColor,
            ),
          ],
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          actionsIconTheme: widget.actionsIconTheme,
          centerTitle: widget.centerTitle,
          titleSpacing: widget.titleSpacing,
          toolbarOpacity: widget.toolbarOpacity,
          leadingWidth: widget.leadingWidth,
          toolbarTextStyle: widget.toolbarTextStyle,
          titleTextStyle: widget.titleTextStyle,
          title: widget.title,
        ),
      ),
    );
  }
}
