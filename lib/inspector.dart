part of 'anadea_flutter_loggy.dart';

/// Overlay button to open the log screen
///
/// Is usually used in app builder
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return MaterialApp(
///     navigatorKey: _navigatorKey,
///     builder: (context, child) => Inspector(
///       navigatorKey: _navigatorKey,
///       child: child!,
///     ),
///   );
/// }
/// ```
class Inspector extends StatefulWidget {
  const Inspector({
    Key? key,
    required this.child,
    required this.navigatorKey,
    this.customRecordBuilders = const {},
    this.isShow = false,
  }) : super(key: key);

  final Widget child;

  /// Root navigator key. Used for logs screen navigation.
  final GlobalKey<NavigatorState> navigatorKey;

  final Map<Type, LogRecordCardBuilder> customRecordBuilders;

  final bool isShow;

  @override
  State<Inspector> createState() => _InspectorState();
}

class _InspectorState extends State<Inspector> {
  bool _isShowButton = true;

  @override
  Widget build(BuildContext context) {
    if (!widget.isShow) {
      return widget.child;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (_isShowButton)
          Directionality(
            textDirection: TextDirection.ltr,
            child: DraggableFloatingActionButton(
              initialOffset: const Offset(100, 100),
              onPressed: () {
                setState(() {
                  _isShowButton = false;
                });
                widget.navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'logs'),
                    builder: (context) => WillPopScope(
                      onWillPop: () async {
                        setState(() {
                          _isShowButton = true;
                        });
                        return true;
                      },
                      child: LogsScreen(
                        customRecordBuilders: widget.customRecordBuilders,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(
                  Icons.bug_report,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DraggableFloatingActionButton extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;
  final VoidCallback onPressed;

  const DraggableFloatingActionButton({
    Key? key,
    required this.child,
    required this.initialOffset,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  bool _isDragging = false;
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);
          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          if (_isDragging) {
            setState(() {
              _isDragging = false;
            });
          } else {
            widget.onPressed();
          }
        },
        child: widget.child,
      ),
    );
  }
}
