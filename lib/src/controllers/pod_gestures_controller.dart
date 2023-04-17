part of 'pod_getx_video_controller.dart';

class _PodGesturesController extends _PodVideoQualityController {
  //double tap
  Timer? leftDoubleTapTimer;
  Timer? rightDoubleTapTimer;
  bool? isPlayed;
  int leftDoubleTapduration = 0;
  int rightDubleTapduration = 0;
  bool isLeftDbTapIconVisible = false;
  bool isRightDbTapIconVisible = false;

  Timer? hoverOverlayTimer;

  ///*handle double tap

  void onLeftDoubleTap({int? seconds}) {
    isPlayed = _videoCtr!.value.isPlaying;
    notifyChildrens();
    leftDoubleTapTimer?.cancel();
    rightDoubleTapTimer?.cancel();

    isRightDbTapIconVisible = false;
    isLeftDbTapIconVisible = true;
    updateLeftTapDuration(
      leftDoubleTapduration += seconds ?? doubleTapForwardSeconds,
    );
    seekBackward(Duration(seconds: seconds ?? doubleTapForwardSeconds));
    _videoCtr!.value.isPlaying ? _videoCtr!.pause() : null;
    leftDoubleTapTimer = Timer(const Duration(milliseconds: 800), () {
      isLeftDbTapIconVisible = false;
      updateLeftTapDuration(0);
      leftDoubleTapTimer?.cancel();
      _videoCtr!.play();
    });
  }

  void onRightDoubleTap({int? seconds}) {
    isPlayed = _videoCtr!.value.isPlaying == true ? true : null;
    notifyChildrens();
    rightDoubleTapTimer?.cancel();
    leftDoubleTapTimer?.cancel();
    isLeftDbTapIconVisible = false;
    isRightDbTapIconVisible = true;
    updateRightTapDuration(
      rightDubleTapduration += seconds ?? doubleTapForwardSeconds,
    );

    seekForward(Duration(seconds: seconds ?? doubleTapForwardSeconds));

    _videoCtr!.value.isPlaying ? _videoCtr!.pause() : null;
    rightDoubleTapTimer = Timer(const Duration(milliseconds: 800), () {
      isRightDbTapIconVisible = false;
      updateRightTapDuration(0);
      rightDoubleTapTimer?.cancel();
      // _videoCtr!.play();
       isPlayed == true ? _videoCtr!.play() : null;
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
