part of 'pod_getx_video_controller.dart';

class _PodGesturesController extends _PodVideoQualityController {
  //double tap
  Timer? leftDoubleTapTimer;
  Timer? rightDoubleTapTimer;
  bool isPlayed = false;
  int leftDoubleTapduration = 0;
  int rightDubleTapduration = 0;
  bool isLeftDbTapIconVisible = false;
  bool isRightDbTapIconVisible = false;

  Timer? hoverOverlayTimer;

  ///*handle double tap

  void onLeftDoubleTap({int? seconds}) {
    isPlayed = _videoCtr!.value.isPlaying;
    notifyChildrens();
    _videoCtr!.value.isPlaying ? _videoCtr!.pause() : null;
    isShowOverlay(true);
    leftDoubleTapTimer?.cancel();
    rightDoubleTapTimer?.cancel();

    isRightDbTapIconVisible = false;
    isLeftDbTapIconVisible = true;
    updateLeftTapDuration(
      leftDoubleTapduration += seconds ?? doubleTapForwardSeconds,
    );
    seekBackward(Duration(seconds: seconds ?? doubleTapForwardSeconds));
    leftDoubleTapTimer = Timer(const Duration(milliseconds: 1500), () {
      isLeftDbTapIconVisible = false;
      updateLeftTapDuration(0);
      leftDoubleTapTimer?.cancel();
      isPlayed == true ? _videoCtr!.play() : null;
      isShowOverlay(false);
    });
  }

  void onRightDoubleTap({int? seconds}) {
    isPlayed = _videoCtr!.value.isPlaying;
    notifyChildrens();
    isShowOverlay(true);
    rightDoubleTapTimer?.cancel();
    leftDoubleTapTimer?.cancel();
    isLeftDbTapIconVisible = false;
    isRightDbTapIconVisible = true;
    updateRightTapDuration(
      rightDubleTapduration += seconds ?? doubleTapForwardSeconds,
    );

    seekForward(Duration(seconds: seconds ?? doubleTapForwardSeconds));
    rightDoubleTapTimer = Timer(const Duration(milliseconds: 1500), () {
      _videoCtr!.value.isPlaying ? _videoCtr!.pause() : null;
      isRightDbTapIconVisible = false;
      updateRightTapDuration(0);
      rightDoubleTapTimer?.cancel();
      isPlayed == true ? _videoCtr!.play() : null;
      isShowOverlay(false);
    });
  }

  void onOverlayHover() {
    if (kIsWeb) {
      hoverOverlayTimer?.cancel();
      isShowOverlay(true);
      hoverOverlayTimer = Timer(
        const Duration(seconds: 3),
        () => isShowOverlay(false),
      );
    }
  }

  void onOverlayHoverExit() {
    if (kIsWeb) {
      isShowOverlay(false);
    }
  }

  ///update doubletap durations
  void updateLeftTapDuration(int val) {
    leftDoubleTapduration = val;
    update(['double-tap']);
    update(['update-all']);
  }

  void updateRightTapDuration(int val) {
    rightDubleTapduration = val;
    update(['double-tap']);
    update(['update-all']);
  }
}
