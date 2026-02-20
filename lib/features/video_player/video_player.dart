import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_seek_bar.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/bloc/video_player_event.dart';
import 'package:elms/features/video_player/bloc/video_player_state.dart';
import 'package:elms/features/video_player/widgets/player_animation_panel.dart';
import 'package:elms/features/video_player/widgets/settings_bottomsheet.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String? url;
  final bool avoidVideoLoad;
  final bool forceFullScreen;
  final VoidCallback? onVideoCompletion;
  final bool hideLayout;
  final bool showNextButton;
  final bool showPreviousButton;
  final VoidCallback? onNextTap;
  final VoidCallback? onPreviousTap;

  CustomVideoPlayer({
    super.key,
    this.avoidVideoLoad = false,
    this.forceFullScreen = false,
    this.url,
    this.onVideoCompletion,
    this.hideLayout = false,
    this.showNextButton = false,
    this.showPreviousButton = false,
    this.onNextTap,
    this.onPreviousTap,
  }) : assert(
         avoidVideoLoad || (url != null && url.isNotEmpty),
         'URL must be set if avoidVideoLoad is false',
       );

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerBloc player = context.read<VideoPlayerBloc>();
  double _volume = 0.5;
  final ValueNotifier<bool> isSeekBarExpanded = ValueNotifier(false);
  double _brightness = 0.5;
  final ValueNotifier<VideoAnimations> animationPanelController = ValueNotifier(
    VideoAnimations(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initBrightnessSettings();
    if (!widget.avoidVideoLoad) {
      player.add(
        LoadVideo(widget.url!, onCompletion: widget.onVideoCompletion),
      );
    }
    if (widget.forceFullScreen) {
      SystemChrome.setPreferredOrientations([.landscapeLeft, .landscapeRight]);
    }
  }

  Future<void> _initBrightnessSettings() async {
    if (player.getState()?.isFullScreen == true) {
      _brightness = await ScreenBrightness().application;
    }
  }

  void _onTapPlayAction({required bool isPlaying}) {
    player.add(isPlaying ? PauseVideo() : PlayVideo());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pause video when app goes to background
    if (state == .paused || state == .inactive) {
      final videoController = player.videoPlayerController;
      if (videoController != null && videoController.value.isPlaying) {
        player.add(PauseVideo());
      }
    }
  }

  @override
  void deactivate() {
    // Don't pause when navigating to full screen
    final state = player.getState();
    final isGoingToFullScreen =
        state is VideoPlayerLoaded && state.isFullScreen;

    if (!isGoingToFullScreen && !widget.forceFullScreen) {
      // Only pause video when navigating away (not to full screen)
      final videoController = context
          .read<VideoPlayerBloc>()
          .videoPlayerController;
      if (videoController != null && videoController.value.isPlaying) {
        player.add(PauseVideo());
      }
    }
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([.portraitUp]);
    isSeekBarExpanded.dispose();
    animationPanelController.dispose();

    // Don't pause video when disposing full screen player (only pause when leaving course entirely)
    if (!widget.forceFullScreen) {
      final videoController = player.videoPlayerController;
      if (videoController != null && videoController.value.isPlaying) {
        player.add(PauseVideo());
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: .deferToChild,
      gestures: {
        if (widget.forceFullScreen)
          HorizontalDragGesturePrevention:
              GestureRecognizerFactoryWithHandlers<
                HorizontalDragGesturePrevention
              >(() => HorizontalDragGesturePrevention(), (instance) {
                instance.onDown = (_) {};
                instance.onCancel = () {};
                instance.onEnd = (_) {};
                instance.onDown = (_) {};
                instance.onUpdate = (_) {};
              }),
      },
      child: Padding(
        padding: const .only(bottom: 4),
        child: SafeArea(
          top: !widget.forceFullScreen,
          bottom: !widget.forceFullScreen,
          child: BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
            listenWhen: (previous, current) {
              // Only listen when isFullScreen actually changes, not on every state update
              if (previous is VideoPlayerLoaded &&
                  current is VideoPlayerLoaded) {
                return previous.isFullScreen != current.isFullScreen;
              }
              return false;
            },
            listener: (context, state) {
              if (state is VideoPlayerLoaded && !widget.forceFullScreen) {
                // Check if we should use nested navigator based on experimental feature flag
                final nestedNavigator = Get.nestedKey(1)?.currentState;
                final useNestedNavigator =
                    AppConstant.kEnableExperimentalMiniPlayer &&
                    nestedNavigator != null;

                if (useNestedNavigator) {
                  // Nested navigator (course content screen with experimental mini player)
                  if (state.isFullScreen) {
                    nestedNavigator.pushNamed(
                      CourseContentRoute.fullScreenVideoPlayer,
                      arguments: player,
                    );
                  } else {
                    nestedNavigator.pop();
                  }
                } else {
                  // Regular navigation (when experimental feature is disabled)
                  if (state.isFullScreen) {
                    Get.toNamed(
                      AppRoutes.fullScreenVideoPlayer,
                      arguments: player,
                    );
                  } else {
                    Get.back();
                  }
                }
              }
            },
            builder: (context, state) {
              final bool isPlaying =
                  state is VideoPlayerLoaded && state.isPlaying;

              return Container(
                width: context.screenWidth,
                height: widget.forceFullScreen ? 100 : 211,
                color: context.color.primary.withValues(alpha: 0.4),
                child: Stack(
                  children: [
                    // Video layer
                    if (player.videoPlayerController != null)
                      Positioned.fill(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio:
                                player.videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(player.videoPlayerController!),
                          ),
                        ),
                      ),

                    if (!widget.hideLayout)
                      PlayerAnimationPanel(
                        controller: animationPanelController,
                      ),

                    if (state is VideoPlayerLoaded && !widget.hideLayout) ...[
                      _buildGesturePanel(context, state),
                      _buildControls(state),
                    ],

                    if (state is VideoPlayerLoading) ...[
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _brightnessAndVolumeControls(
    DragUpdateDetails details,
    double screenWidth,
  ) {
    final double dx = details.localPosition.dx;
    final double dy = details.delta.dy;
    if (dx < screenWidth / 2) {
      if (player.getState()?.isFullScreen ?? false) {
        // Left half - adjust brightness
        _brightness -= dy * 0.005;
        _brightness = _brightness.clamp(0.0, 1.0);
        ScreenBrightness().setApplicationScreenBrightness(_brightness);
        animationPanelController.value = animationPanelController.value
            .copyWith(brightness: _brightness, showBrightness: true);
      }
    } else {
      // Right half - adjust volume
      _volume -= dy * 0.01;
      _volume = _volume.clamp(0.0, 1.0);
      animationPanelController.value = animationPanelController.value.copyWith(
        volume: _volume,
        showVolume: true,
      );
      player.add(SetVolume(_volume));
    }
  }

  Widget _buildGesturePanel(BuildContext context, VideoPlayerLoaded state) {
    // Only enable vertical drag gestures in fullscreen mode
    // In normal mode, we need to allow the mini player's drag functionality to work
    final bool enableVerticalDrag = state.isFullScreen;

    return GestureDetector(
      behavior: .translucent,
      onTap: () {
        player.add(TriggerControlsVisibility(userGesture: false));
      },
      onDoubleTapDown: (details) {
        final bool isLeft = details.localPosition.dx < context.screenWidth / 2;

        player.add(TriggerControlsVisibility(userGesture: false));
        player.add(
          DoubleTapSeek(
            isLeft ? DoubleTapDirection.left : DoubleTapDirection.right,
          ),
        );

        if (isLeft) {
          animationPanelController.value = animationPanelController.value
              .copyWith(showRewind: true);
        } else {
          animationPanelController.value = animationPanelController.value
              .copyWith(showForward: true);
        }
      },
      // Only allow vertical drag for brightness/volume control when in fullscreen
      // Otherwise, let the mini player handle vertical drags for scrolling
      onVerticalDragUpdate: enableVerticalDrag
          ? (details) {
              _brightnessAndVolumeControls(details, context.screenWidth);
            }
          : null,
      onVerticalDragEnd: enableVerticalDrag
          ? (details) {
              animationPanelController.value = animationPanelController.value
                  .copyWith(showVolume: false, showBrightness: false);
            }
          : null,
      child: const SizedBox(width: double.infinity, height: double.infinity),
    );
  }

  Widget _buildControls(VideoPlayerLoaded state) {
    return IgnorePointer(
      ignoring: !state.uiVisible,
      child: AnimatedOpacity(
        opacity: state.uiVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          fit: .expand,
          children: [
            Positioned.fill(
              child: IgnorePointer(child: Container(color: Colors.black26)),
            ),
            Align(
              alignment: .topCenter,
              child: Padding(
                padding: const .all(8.0),
                child: Row(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .end,
                  children: [_buildSettingsButton(context)],
                ),
              ),
            ),
            Align(child: _buildActionRow(context, isPlaying: state.isPlaying)),
            Positioned(
              bottom: 0,
              right: 10,
              left: 10,
              child: _buildProgressWithDuration(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.showCustomBottomSheet(
          context,
          child: BlocProvider.value(
            value: player,
            child: const VideoPlayerSettingsBottomSheet(),
          ),
        );
      },
      child: const Icon(Icons.settings, color: Colors.white),
    );
  }

  Widget _buildProgressWithDuration(BuildContext context) => Padding(
    padding: .only(bottom: widget.forceFullScreen ? 15 : 0),
    child: ValueListenableBuilder(
      valueListenable: player.minifiedPosition,
      builder: (context, value, child) {
        ///This will convert the 0-1 to the screen width respective value
        final double seekBarProgress = context.screenWidth * (1 - value);
        return GestureDetector(
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            player.add(
              SeekVideo.to(
                details.localPosition.dx / context.screenWidth,
                updateVisuallyOnly: true,
              ),
            );
            isSeekBarExpanded.value = true;
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            player.add(
              SeekVideo.to(details.localPosition.dx / context.screenWidth),
            );
            isSeekBarExpanded.value = false;
          },
          onTapUp: (TapUpDetails details) {
            player.add(
              SeekVideo.to(details.localPosition.dx / context.screenWidth),
            );
            isSeekBarExpanded.value = false;
          },
          onTapDown: (TapDownDetails details) {
            isSeekBarExpanded.value = true;
          },
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 2,
            children: [
              Padding(
                padding: const .symmetric(vertical: 7),
                child: Row(
                  children: [
                    CustomText(
                      player.progressDuration(value),
                      fontSize: 12,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        player.add(TriggerFullScreen());
                      },
                      child: Container(
                        padding: const .all(0),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: isSeekBarExpanded,
                builder: (context, isExpanded, child) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 900),
                    child: _buildSeekBar(
                      context,
                      height: isExpanded ? 8 : 5,
                      seekBarProgress: seekBarProgress,
                    ),
                  );
                },
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    ),
  );

  Widget _buildActionRow(BuildContext context, {required bool isPlaying}) {
    return Row(
      mainAxisAlignment: .center,
      spacing: 30,
      children: [
        if (widget.showPreviousButton) _buildPreviousAction(context),
        _buildPlayAction(context, isPlaying: isPlaying),
        if (widget.showNextButton) _buildNextAction(context),
      ],
    );
  }

  Widget _buildNextAction(BuildContext context) {
    return GestureDetector(
      onTap: widget.onNextTap,
      child: Container(
        decoration: BoxDecoration(
          shape: .circle,
          color: context.color.onSurface.withValues(alpha: 0.3),
        ),
        padding: const .all(4),
        child: Icon(Icons.skip_next, color: context.color.surface),
      ),
    );
  }

  Widget _buildPreviousAction(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPreviousTap,
      child: Container(
        decoration: BoxDecoration(
          shape: .circle,
          color: context.color.onSurface.withValues(alpha: 0.3),
        ),
        padding: const .all(4),
        child: Icon(Icons.skip_previous, color: context.color.surface),
      ),
    );
  }

  Widget _buildPlayAction(BuildContext context, {required bool isPlaying}) {
    return GestureDetector(
      onTap: () => _onTapPlayAction(isPlaying: isPlaying),
      child: Container(
        decoration: BoxDecoration(
          shape: .circle,
          color: context.color.onSurface.withValues(alpha: 0.5),
        ),
        padding: const .all(8),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow_rounded,
          size: 36,
          color: context.color.surface,
        ),
      ),
    );
  }

  Widget _buildSeekBar(
    BuildContext context, {
    required double height,
    required double seekBarProgress,
  }) {
    return CustomSeekBar(
      thickness: height,
      fullLength: context.screenWidth,
      seekBarProgress: seekBarProgress,
    );
  }
}

class HorizontalDragGesturePrevention extends HorizontalDragGestureRecognizer {
  bool _hasRejected = false;

  HorizontalDragGesturePrevention({super.debugOwner});

  @override
  void addPointer(PointerDownEvent event) {
    _hasRejected = false;
    super.addPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent && !_hasRejected) {
      final dx = event.delta.dx.abs();
      final dy = event.delta.dy.abs();

      if (dy > dx) {
        debugPrint('Vertical drag detected. Resolving to rejected.');
        _hasRejected = true;

        // This tells the gesture arena to reject this recognizer
        resolve(GestureDisposition.rejected);
        return;
      }
    }

    super.handleEvent(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _hasRejected = false;
    super.didStopTrackingLastPointer(pointer);
  }
}
