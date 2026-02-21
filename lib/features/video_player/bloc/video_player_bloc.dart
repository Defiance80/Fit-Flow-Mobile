import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fitflow/common/enums.dart';
import 'package:fitflow/core/constants/app_constant.dart';
import 'package:fitflow/features/video_player/bloc/video_player_event.dart';
import 'package:fitflow/features/video_player/bloc/video_player_state.dart';
import 'package:fitflow/utils/convert_number.dart';
import 'package:fitflow/utils/extensions/duration_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerController? _videoPlayerController;
  VoidCallback? _onVideoCompletion;
  bool _hasTriggeredCompletion = false;

  VideoPlayerController? get videoPlayerController => _videoPlayerController;
  Duration get duration =>
      _videoPlayerController?.value.duration ?? Duration.zero;
  Duration get position =>
      _videoPlayerController?.value.position ?? Duration.zero;

  String get durationString => duration.toString();

  final ValueNotifier<double> minifiedPosition = ValueNotifier<double>(0);
  bool isSeeking = false;

  VideoPlayerBloc() : super(VideoPlayerInitial()) {
    on<LoadVideo>(_onLoadVideo);
    on<PlayVideo>(_onPlayVideo);
    on<TriggerControlsVisibility>(_onTriggerControlsVisibility);
    on<PauseVideo>(_onPauseVideo);
    on<SeekVideo>(_onSeekVideo);
    on<DoubleTapSeek>(_doubleTapSeekVideo);
    on<SetVolume>(_onSetVolume);
    on<SetSpeed>(_onSetSpeed);
    on<SetQuality>(_onSetQuality);
    on<TriggerFullScreen>(_onSetFullScreen);
    on<SetLoop>(_onSetLoop);
  }
  Timer? _uiControlsVisibilityTimer;
  Completer _triggerCompleter = Completer();

  ///This will trigger UI controls
  void _onTriggerControlsVisibility(
    TriggerControlsVisibility event,
    Emitter<VideoPlayerState> emit,
  ) async {
    ///If the completer is completed then assign new one because we are using the Timer,
    ///and if we use timer or any task which will be called on future then event will not wait if the
    /// task is not async. There after you will not be able to emit new state. So we are virtually
    ///  creating empty future which will do nothing but trick event handler
    if (_triggerCompleter.isCompleted) {
      _triggerCompleter = Completer();
    }
    _uiControlsVisibilityTimer?.cancel();

    if (state is! VideoPlayerLoaded) {
      return;
    }

    final currentState = state as VideoPlayerLoaded;

    ///Here is Timer is used because if the user leaves after seeking. this should trigger and ui will be hide after delay not instantly
    if (currentState.uiVisible && !event.isTimer) {
      ///If the UI is visible then we need to hide it
      emit(currentState.copyWith(uiVisible: false));
      return;
    }

    emit(currentState.copyWith(uiVisible: true));
    _uiControlsVisibilityTimer = Timer(const Duration(seconds: 3), () {
      if (state is VideoPlayerLoaded) {
        final VideoPlayerLoaded currentState = state as VideoPlayerLoaded;

        ///If the user is not seeking then complete the future
        if (!isSeeking) {
          if (currentState.isPlaying) {
            emit(currentState.copyWith(uiVisible: false));
            _triggerCompleter.complete();
          }
        }
      }
    });

    ///wait until the timer completes the future
    await _triggerCompleter.future;
  }

  void _listener() {
    if (isSeeking) {
      return;
    }

    if ((position.inSeconds / duration.inSeconds).isNaN) {
      return;
    }
    final double progress = position.inSeconds / duration.inSeconds;
    minifiedPosition.value = progress;

    // Check if video reached 90% completion
    if (progress >= 0.9 &&
        !_hasTriggeredCompletion &&
        _onVideoCompletion != null) {
      _hasTriggeredCompletion = true;
      _onVideoCompletion?.call();
    }
  }

  Future<void> _onLoadVideo(
    LoadVideo event,
    Emitter<VideoPlayerState> emit,
  ) async {
    emit(VideoPlayerLoading());
    try {
      // Store the completion callback
      _onVideoCompletion = event.onCompletion;
      _hasTriggeredCompletion = false;

      final String url = await event.source.getSource();
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController?.initialize();
      _videoPlayerController?.addListener(_listener);

      emit(
        VideoPlayerLoaded(
          source: event.source,
          position: Duration.zero,
          duration: _videoPlayerController!.value.duration,
          isPlaying: _videoPlayerController?.value.isPlaying ?? false,
          volume: 1.0,
          speed: PlaybackSpeed.normal,
          isMuted: false,
          isFullScreen: false,
          uiVisible: false,
          loop: false,
          quality: event.source.currentQuality,
        ),
      );
    } catch (e, st) {
      emit(VideoPlayerError('Failed to load video :$st'));
    }
  }

  void _onPlayVideo(PlayVideo event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      _videoPlayerController?.play();
      emit((state as VideoPlayerLoaded).copyWith(isPlaying: true));
    }
  }

  void _onPauseVideo(PauseVideo event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      _videoPlayerController?.pause();
      emit((state as VideoPlayerLoaded).copyWith(isPlaying: false));
    }
  }

  void _onSeekVideo(SeekVideo event, Emitter<VideoPlayerState> emit) async {
    isSeeking = true;
    minifiedPosition.value = event.position;
    if (!event.updateVisuallyOnly) {
      final double pos = ConvertNumber.inRange(
        currentValue: event.position,
        minValue: 0,
        maxValue: 1,
        newMaxValue: (state as VideoPlayerLoaded).duration.inSeconds.toDouble(),
        newMinValue: 0,
      );
      await _videoPlayerController?.seekTo(Duration(seconds: pos.toInt()));
      isSeeking = false;
      add(TriggerControlsVisibility(isTimer: true));
    }
  }

  FutureOr<void> _doubleTapSeekVideo(
    DoubleTapSeek event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (event.direction == DoubleTapDirection.left) {
      _videoPlayerController?.seekTo(
        position - const Duration(seconds: AppConstant.kDoubleTapSeekDuration),
      );
    } else {
      _videoPlayerController?.seekTo(
        position + const Duration(seconds: AppConstant.kDoubleTapSeekDuration),
      );
    }
  }

  void _onSetVolume(SetVolume event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      _videoPlayerController?.setVolume(event.volume);
      emit((state as VideoPlayerLoaded).copyWith(volume: event.volume));
    }
  }

  void _onSetSpeed(SetSpeed event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      _videoPlayerController?.setPlaybackSpeed(event.speed.value);
      emit((state as VideoPlayerLoaded).copyWith(speed: event.speed));
    }
  }

  void _onSetQuality(SetQuality event, Emitter<VideoPlayerState> emit) async {
    if (state is VideoPlayerLoaded) {
      final bool wasPlaying = _videoPlayerController?.value.isPlaying ?? false;

      ///We are storing current position here because the [position] variable will be changed after we initialize new video controller because it is getter so it will give us position of new player controller
      final Duration currentPosition = position;

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(event.quality.url),
      );

      await _videoPlayerController?.initialize();
      _videoPlayerController?.addListener(_listener);
      await _videoPlayerController?.seekTo(currentPosition);

      if (wasPlaying) {
        await _videoPlayerController!.play();
      }

      emit(
        (state as VideoPlayerLoaded).copyWith(
          quality: event.quality,

          ///Updating quality here as well this is optional but needed if want to check video quality from the [source]
          source: (state as VideoPlayerLoaded).source
            ..currentQuality = event.quality,
        ),
      );
    }
  }

  void _onSetFullScreen(
    TriggerFullScreen event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is VideoPlayerLoaded) {
      final bool isFullscreen = !(state as VideoPlayerLoaded).isFullScreen;
      SystemChrome.setPreferredOrientations(
        isFullscreen
            ? [.landscapeLeft]
            : [.portraitUp],
      );
      emit((state as VideoPlayerLoaded).copyWith(isFullScreen: isFullscreen));
    }
  }

  FutureOr<void> _onSetLoop(SetLoop event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      _videoPlayerController?.setLooping(event.loop);
      emit((state as VideoPlayerLoaded).copyWith(loop: event.loop));
    }
  }

  String progressDuration(double progress) {
    final bool seeking = isSeeking;
    if (seeking) {
      final double pos = ConvertNumber.inRange(
        currentValue: progress,
        minValue: 0,
        maxValue: 1,
        newMaxValue:
            _videoPlayerController?.value.duration.inSeconds.toDouble() ?? 0,
        newMinValue: 0,
      );
      return '${Duration(seconds: pos.toInt()).toFormattedDuration()} / ${duration.toFormattedDuration()}';
    }
    return '${position.toFormattedDuration()} / ${duration.toFormattedDuration()}';
  }

  VideoPlayerLoaded? getState() {
    if (state is VideoPlayerLoaded) {
      return (state as VideoPlayerLoaded);
    }
    return null;
  }

  @override
  Future<void> close() {
    // Cancel any active timers
    _uiControlsVisibilityTimer?.cancel();

    // Complete any pending futures
    if (!_triggerCompleter.isCompleted) {
      _triggerCompleter.complete();
    }

    // Properly stop and dispose video controller
    if (_videoPlayerController != null) {
      _videoPlayerController!.removeListener(_listener);
      _videoPlayerController!.pause();
      _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }

    // Dispose value notifier
    minifiedPosition.dispose();

    return super.close();
  }
}
