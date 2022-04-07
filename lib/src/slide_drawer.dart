import 'package:flutter/material.dart';
import 'package:flutter_drawers/src/drawer_holder.dart';

class SlideDrawer extends StatefulWidget {
  final Widget child;
  final Widget? drawer;
  final Widget? animatedHeader;
  final double? headerHeight;
  final DrawerAlignment alignment;
  final bool showDrawerOpener;
  final double drawerOpenerTopMargin;

  const SlideDrawer({
    Key? key,
    required this.child,
    this.drawer,
    this.animatedHeader,
    this.headerHeight,
    this.alignment = DrawerAlignment.end,
    this.showDrawerOpener = false,
    this.drawerOpenerTopMargin = 5,
  })  : assert(
            drawer == null || animatedHeader == null || headerHeight != null),
        super(key: key);

  static SlideDrawerState? of(BuildContext context) =>
      context.findAncestorStateOfType<SlideDrawerState>();

  @override
  SlideDrawerState createState() => SlideDrawerState();
}

class SlideDrawerState extends State<SlideDrawer>
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
    drawerWidth = size.width * 0.65;
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
                    widget.alignment == DrawerAlignment.end
                        ? (size.width - drawerWidth * animationController.value)
                        : (drawerWidth * (animationController.value - 1)),
                    0,
                  ),
                  child: DrawerHolder(
                    width: drawerWidth,
                    child: widget.drawer,
                    hederHeight: widget.headerHeight,
                  ),
                ),
                Transform(
                  transform: widget.alignment == DrawerAlignment.end
                      ? (Matrix4.identity()
                        ..translate(-drawerWidth * animationController.value, 0)
                        ..scale(1 - animationController.value * 0.4))
                      : (Matrix4.identity()
                        ..translate(drawerWidth * animationController.value, 0)
                        ..scale(1 - animationController.value * 0.4)),
                  alignment: widget.alignment == DrawerAlignment.end
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: widget.child,
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
