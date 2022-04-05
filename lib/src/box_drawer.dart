import 'dart:math' as math;

import 'package:flutter/material.dart';

class BoxDrawer extends StatefulWidget {
  final Widget child;
  final Widget? drawer;
  final Widget? animatedHeader;
  final double? headerHeight;

  const BoxDrawer({
    Key? key,
    required this.child,
    this.drawer,
    this.animatedHeader,
    this.headerHeight,
  })  : assert(drawer == null || animatedHeader == null || headerHeight != null),
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
      onTapUp: (delails) {
        if (animationController.isCompleted &&
            delails.globalPosition.dx < (size.width - drawerWidth)) {
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
                    size.width - drawerWidth * animationController.value,
                    0,
                  ),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0006)
                      ..rotateY(-math.pi * (1 - animationController.value) / 2),
                    alignment: Alignment.centerLeft,
                    child: DrawerHolder(
                      width: drawerWidth,
                      child: widget.drawer,
                      hederHeight: widget.headerHeight,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-drawerWidth * animationController.value, 0),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0006)
                      ..rotateY(math.pi * animationController.value / 2 -
                          (animationController.value * 0.05)),
                    alignment: Alignment.centerRight,
                    child: widget.child,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: drawerWidth * animationController.value,
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
                    left: size.width -
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
      animationController.value -= delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    double _kMinFlingVelocity = 400;

    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx / size.width;
      animationController.fling(velocity: -visualVelocity);
    } else if (animationController.value < 0.5) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  void close() => animationController.reverse();
}

class DrawerHolder extends StatelessWidget {
  final double width;
  final Widget? child;
  final double? hederHeight;
  const DrawerHolder(
      {Key? key, required this.width, this.child, this.hederHeight})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: double.infinity,
      child: Material(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.only(top: hederHeight ?? 0),
          child: Theme(
            data: ThemeData(brightness: Brightness.dark),
            child: child ?? Container(),
          ),
        ),
      ),
    );
  }
}
