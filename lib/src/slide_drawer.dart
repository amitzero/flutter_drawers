import 'package:flutter/material.dart';
import 'package:flutter_drawers/src/drawer_holder.dart';

class SlideDrawer extends StatefulWidget {
  /// Non-nullable child widget for home screen.
  final Widget child;

  /// Non-nullable drawer widget.
  final Widget? drawer;

  /// Non-nullable drawer header.
  final Widget? animatedHeader;

  /// Non-nullable drawer header height. Must not be null if
  /// [drawer] and [animatedHeader] is not null.
  final double? headerHeight;

  /// DrawerAlignment for drawer position.
  final DrawerAlignment alignment;

  /// Flag drawer opener's visibility.
  final bool showDrawerOpener;

  /// Drawer opener's top margin.
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

  /// Finds the nearest [BoxDrawerState] ancestor of the given context.
  static SlideDrawerState? of(BuildContext context) =>
      context.findAncestorStateOfType<SlideDrawerState>();

  @override
  SlideDrawerState createState() => SlideDrawerState();
}

class SlideDrawerState extends State<SlideDrawer>
    with SingleTickerProviderStateMixin {
  /// Open and close drawer with animation.
  late AnimationController animationController;

  /// Check if dragging is valid.
  bool canBeDragged = false;

  /// Store device size.
  late Size size;

  /// Store drawer width. It usages 75% of device width.
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

  /// Toggle the drawer. If the drawer is open, close it. If the drawer is closed, open it.
  /// Using [animationController] value to animate and toggle the drawer.
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

  /// Called when the user starts dragging the drawer.
  /// If valid drag is started, it will set the [canBeDragged] to true for later
  /// use in [_onDragUpdate] and [_onDragEnd].
  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed;
    bool isDragCloseFromRight = animationController.isCompleted;
    canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  /// On dragging update, if [canBeDragged] then calculate and update
  /// [animationController] value. Otherwise, do nothing.
  void _onDragUpdate(DragUpdateDetails details) {
    if (canBeDragged) {
      double delta = details.primaryDelta! / drawerWidth;
      animationController.value +=
          delta * (widget.alignment == DrawerAlignment.start ? 1 : -1);
    }
  }

  /// On dragging end, with a velocity greater than [kMinFlingVelocity] complete
  /// the open or close animation. Otherwise, do nothing.
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

  /// Close the drawer
  void close() => animationController.reverse();

  /// Open the drawer
  void open() => animationController.forward();
}
