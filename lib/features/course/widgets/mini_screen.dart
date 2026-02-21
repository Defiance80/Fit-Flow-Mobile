// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

enum DragDirection { left, right }

mixin MiniScreenMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<Offset> _offset = ValueNotifier(Offset.zero);
  late Settings settings;
  double dragValue = 0;
  late double screenHeight = context.screenHeight;
  late double screenWidth = context.screenWidth;
  final double maxVisibleOffset = 0.02; //0-1
  final double miniPlayerPadding = 10;
  Duration animationDuration = Duration.zero;

  bool get isMiniPlayer => _offset.value.dy >= _maxAvailableOffset();

  double get weightedOpacity =>
      (1 - (dragValue * settings.opacityWeight)).clamp(0, 1);

  DragDirection previousDragDirection = DragDirection.right;
  bool visibilityCriteria() {
    return _offset.value.dy > (_maxAvailableOffset() * maxVisibleOffset);
  }

  double _maxAvailableOffset() {
    return screenHeight -
        settings.miniPlayerSize.height -
        kBottomNavigationBarHeight -
        (miniPlayerPadding * 3);
  }

  void _handleSnap() async {
    // Longer duration for smoother animation
    animationDuration = const Duration(milliseconds: 350);

    // Use half screen as the threshold for a more intuitive snap
    final double halfScreen = _maxAvailableOffset() / 2;

    if (_offset.value.dy > halfScreen) {
      _offset.value = Offset(_offset.value.dx, _maxAvailableOffset());
    } else {
      _offset.value = Offset(_offset.value.dx, 0);
    }

    await Future.delayed(animationDuration);
    animationDuration = Duration.zero;
  }

  double _getMaxHorizontalOffset() {
    return screenWidth - settings.miniPlayerSize.width - miniPlayerPadding;
  }

  // Helper method to handle horizontal drag logic
  void _handleHorizontalDrag(DraggableDetails details) {
    if (isMiniPlayer) {
      if (details.velocity.pixelsPerSecond.dx < -50) {
        previousDragDirection = DragDirection.left;
        _offset.value = Offset(_getMaxHorizontalOffset(), _offset.value.dy);
      } else if (details.velocity.pixelsPerSecond.dx > -50) {
        previousDragDirection = DragDirection.right;
        _offset.value = Offset(miniPlayerPadding, _offset.value.dy);
      }
      setState(() {});
    }
  }

  Widget MiniPlayer({
    required Widget Function(BuildContext context, bool isMiniPlayer) builder,
  }) {
    return GestureDetector(
      onTap: () async {
        animationDuration = const Duration(milliseconds: 250);
        _offset.value = const Offset(0, 0);
        await Future.delayed(animationDuration);
        animationDuration = Duration.zero;
      },
      child: Draggable(
        feedback: const SizedBox.shrink(),
        onDragUpdate: (DragUpdateDetails details) {
          if (isMiniPlayer) return;
          // Update both x and y coordinates
          _offset.value = Offset(
            _offset.value.dx,
            _offset.value.dy + details.delta.dy,
          );

          // Only clamp Y value for vertical dragging
          _offset.value = Offset(
            _offset.value.dx,
            _offset.value.dy.clamp(0, _maxAvailableOffset()),
          );
        },
        onDragEnd: (DraggableDetails details) {
          _handleHorizontalDrag(details);
          _handleSnap();
        },
        child: SizedBox(
          height: lerpDouble(
            settings.playerSize.height,
            settings.miniPlayerSize.height,
            _convertOffsetToValue(_offset.value.dy),
          ),
          width: settings.playerSize.width,
          child: builder(context, isMiniPlayer),
        ),
      ),
    );
  }

  double _convertOffsetToValue(double offset) {
    return offset / _maxAvailableOffset();
  }

  Widget Screen({
    required Settings settings,
    required Widget Function(BuildContext context, double value) builder,
  }) {
    this.settings = settings;

    return ValueListenableBuilder(
      valueListenable: _offset,
      builder: (context, offset, child) {
        final double t = _convertOffsetToValue(offset.dy);
        dragValue = t;
        if (!settings.enabled) {
          return builder(context, t);
        }
        return AnimatedPositioned(
          duration: animationDuration,
          top: offset.dy,
          right: previousDragDirection == DragDirection.right ? 0 : null,
          left: previousDragDirection == DragDirection.left ? 0 : null,
          child: SizedBox(
            height: lerpDouble(screenHeight, settings.miniPlayerSize.height, t),
            width: lerpDouble(
              settings.playerSize.width,
              settings.miniPlayerSize.width,
              t,
            ),
            child: builder(context, t),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }
}

class Settings {
  final Size playerSize;
  final Size miniPlayerSize;
  final double opacityWeight;
  final bool enabled;

  const Settings({
    required this.playerSize,
    required this.miniPlayerSize,
    this.opacityWeight = 1,
    this.enabled = true,
  });
}
