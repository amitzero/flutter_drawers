import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_drawers/src/drawer_holder.dart';

class BoxDrawer extends StatefulWidget {
  final Widget child;
  final Widget? drawer;
  final Widget? animatedHeader;
  final double? headerHeight;
  final DrawerAlignment alignment;
  final bool showDrawerOpener;
  final double drawerOpenerTopMargin;

  const BoxDrawer({
    Key? key,
    required this.child,
    this.drawer,
    this.animatedHeader,
    this.headerHeight,
    this.alignment = DrawerAlignment.end,
    this.showDrawerOpener = true,
    this.drawerOpenerTopMargin = 5,
  })  : assert(
            drawer == null || animatedHeader == null || headerHeight != null),
        super(key: key);

  static BoxDrawerState? of(BuildContext context) =>
      context.findAncestorStateOfType<BoxDrawerState>();

  @override
  BoxDrawerState createState() => BoxDrawerState();
}

class BoxDrawerState extends State<BoxDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  bool _canBeDragged = false;
  late Size size;
  late double drawerWidth;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    drawerWidth = size.width * 0.75;
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTapUp: (details) {
        bool valid = widget.alignment == DrawerAlignment.end
            ? details.globalPosition.dx < (size.width - drawerWidth)
            : details.globalPosition.dx > drawerWidth;
        if (animationController.isCompleted && valid) {
          toggle();
        }
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          return Material(
            color: Colors.blueGrey,
            child: Stack(
              children: <Widget>[
                Transform.translate(
                  offset: Offset(
                    widget.alignment == DrawerAlignment.end
                        ? (size.width - drawerWidth * animationController.value)
                        : (drawerWidth * (animationController.value - 1)),
                    0,
                  ),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0006)
                      ..rotateY((math.pi *
                              (1 - animationController.value) *
                              (widget.alignment == DrawerAlignment.end
                                  ? -1
                                  : 1)) /
                          2),
                    alignment: widget.alignment == DrawerAlignment.end
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: DrawerHolder(
                      width: drawerWidth,
                      child: widget.drawer,
                      hederHeight: widget.headerHeight,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    widget.alignment == DrawerAlignment.end
                        ? (-drawerWidth * animationController.value)
                        : (drawerWidth * animationController.value),
                    0,
                  ),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0006)
                      ..rotateY(
                        (math.pi * animationController.value / 2) *
                                (widget.alignment == DrawerAlignment.end
                                    ? 1
                                    : -1) +
                            (animationController.value * 0.05) *
                                (widget.alignment == DrawerAlignment.end
                                    ? -1
                                    : 1),
                      ),
                    alignment: widget.alignment == DrawerAlignment.end
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: widget.child,
                  ),
                ),
                if (widget.showDrawerOpener)
                  Positioned(
                    top: widget.drawerOpenerTopMargin,
                    left: widget.alignment == DrawerAlignment.end
                        ? null
                        : drawerWidth * animationController.value,
                    right: widget.alignment == DrawerAlignment.start
                        ? null
                        : drawerWidth * animationController.value,
                    child: IconButton(
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: animationController.view,
                      ),
                      onPressed: toggle,
                      color: Colors.white,
                    ),
                  ),
                if (widget.animatedHeader != null)
                  Positioned(
                    top: 16.0 + (1 - animationController.value) * size.height,
                    right: widget.alignment == DrawerAlignment.end
                        ? null
                        : size.width -
                            drawerWidth +
                            (1 - animationController.value) * size.width / 2,
                    left: widget.alignment == DrawerAlignment.start
                        ? null
                        : size.width -
                            drawerWidth +
                            (1 - animationController.value) * size.width / 2,
                    width: drawerWidth,
                    child: widget.animatedHeader!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed;
    bool isDragCloseFromRight = animationController.isCompleted;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta! / drawerWidth;
      animationController.value +=
          delta * (widget.alignment == DrawerAlignment.start ? 1 : -1);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    double _kMinFlingVelocity = 400;

    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx / size.width;
      animationController.fling(
          velocity: visualVelocity *
              (widget.alignment == DrawerAlignment.start ? 1 : -1));
    } else if (animationController.value < 0.5) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  void close() => animationController.reverse();
  void open() => animationController.forward();
}
