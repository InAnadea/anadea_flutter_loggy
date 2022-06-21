part of 'anadea_flutter_loggy.dart';

class LogsButton extends StatefulWidget {
  const LogsButton({
    Key? key,
    required this.child,
    required this.navigatorKey,
  }) : super(key: key);

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<LogsButton> createState() => _LogsButtonState();
}

class _LogsButtonState extends State<LogsButton> {
  bool _isShowButton = true;

  @override
  Widget build(BuildContext context) {
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
                    builder: (context) => WillPopScope(
                      onWillPop: () async {
                        setState(() {
                          _isShowButton = true;
                        });
                        return true;
                      },
                      child: const LogsScreen(),
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
