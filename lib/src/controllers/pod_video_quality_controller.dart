part of 'pod_getx_video_controller.dart';

class _PodVideoQualityController extends _PodVideoController {
  ///
  int? vimeoPlayingVideoQuality;

  ///vimeo all quality urls
  List<VideoQalityUrls> vimeoOrVideoUrls = [];
  late String _videoQualityUrl;

  ///invokes callback from external controller
  VoidCallback? onVimeoVideoQualityChanged;

  ///*vimeo player configs
  ///
  ///get all  `quality urls`
  Future<void> getQualityUrlsFromVimeoId(String videoId) async {
    try {
      podVideoStateChanger(PodVideoState.loading);
      final _vimeoVideoUrls = await VideoApis.getVimeoVideoQualityUrls(videoId);

      ///
      vimeoOrVideoUrls = _vimeoVideoUrls ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getQualityUrlsFromVimeoPrivateId(
    String videoId,
    Map<String, String> httpHeader,
  ) async {
    try {
      podVideoStateChanger(PodVideoState.loading);
      final _vimeoVideoUrls =
          await VideoApis.getVimeoPrivateVideoQualityUrls(videoId, httpHeader);

      ///
      vimeoOrVideoUrls = _vimeoVideoUrls ?? [];
    } catch (e) {
      rethrow;
    }
  }

  void sortQualityVideoUrls(
    List<VideoQalityUrls>? urls,
  ) {
    final _urls = urls;

    ///has issues with 240p
    // _urls?.removeWhere((element) => element.quality == 240);

    ///has issues with 144p in web
    _urls?.removeWhere((element) => element.quality == 144);
    _urls?.removeWhere((element) => element.quality > 720);
    _urls?.removeWhere(
      (element) =>
          element.url == '' && element.quality != 240 && element.quality != 480,
    );

    if (kIsWeb) {}

    ///sort
    _urls?.sort((a, b) => a.quality.compareTo(b.quality));

    ///
    vimeoOrVideoUrls = _urls ?? [];
  }

  ///get vimeo quality `ex: 1080p` url
  VideoQalityUrls getQualityUrl(int quality) {
    return vimeoOrVideoUrls.firstWhere(
      (element) => element.quality == quality,
      orElse: () => vimeoOrVideoUrls.first,
    );
  }

  Future<String> getUrlFromVideoQualityUrls({
    required List<int> qualityList,
    required List<VideoQalityUrls> videoUrls,
  }) async {
    sortQualityVideoUrls(videoUrls);
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }

    final fallback = vimeoOrVideoUrls[0];
    VideoQalityUrls? urlWithQuality;
    for (final quality in qualityList) {
      urlWithQuality = vimeoOrVideoUrls.firstWhere(
        (url) => url.quality == quality,
        orElse: () => fallback,
      );

      if (urlWithQuality != fallback) {
        break;
      }
    }

    urlWithQuality ??= fallback;
    _videoQualityUrl = urlWithQuality.url!;
    vimeoPlayingVideoQuality = urlWithQuality.quality;
    return _videoQualityUrl;
  }

  Future<List<VideoQalityUrls>> getVideoQualityUrlsFromYoutube(
    String youtubeIdOrUrl,
    bool live,
  ) async {
    return await VideoApis.getYoutubeVideoQualityUrls(youtubeIdOrUrl, live) ??
        [];
  }

  Future<void> changeVideoQuality(int? quality, String? url) async {
    print(vimeoOrVideoUrls.toString());
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }

    if (url == '' && quality != 240 && quality != 480) {
      podVideoStateChanger(PodVideoState.paused);
      podVideoStateChanger(PodVideoState.loading);
      Timer(const Duration(milliseconds: 1000), () {
        podVideoStateChanger(PodVideoState.playing);
      });
    }

    if (url == '' && vimeoPlayingVideoQuality != quality) {
      if (quality == 240 && url == '') {
        if (vimeoOrVideoUrls.any((element) => element.quality > 240)) {
          _videoQualityUrl = vimeoOrVideoUrls
              .where((element) => element.quality > 240)
              .first
              .url!;
          podLog(_videoQualityUrl);
          vimeoPlayingVideoQuality = quality;
          _videoCtr?.removeListener(videoListner);
          podVideoStateChanger(PodVideoState.paused);
          podVideoStateChanger(PodVideoState.loading);
          playingVideoUrl = _videoQualityUrl;
          _videoCtr = VideoPlayerController.network(_videoQualityUrl);
          await _videoCtr?.initialize();
          _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
          _videoCtr?.addListener(videoListner);
          await _videoCtr?.seekTo(_videoPosition);
          setVideoPlayBack(_currentPaybackSpeed);
          podVideoStateChanger(PodVideoState.playing);
          onVimeoVideoQualityChanged?.call();
          update();
          update(['update-all']);
        } else {
          vimeoPlayingVideoQuality = quality;
          podVideoStateChanger(PodVideoState.paused);
          podVideoStateChanger(PodVideoState.loading);
          Timer(const Duration(milliseconds: 1000), () {
            podVideoStateChanger(PodVideoState.playing);
          });
        }
      }
      if (quality == 480 && url == '') {
        if (vimeoOrVideoUrls.any((element) => element.quality > 480)) {
          _videoQualityUrl = vimeoOrVideoUrls
              .where((element) => element.quality > 480)
              .first
              .url!;
          podLog(_videoQualityUrl);
          vimeoPlayingVideoQuality = quality;
          _videoCtr?.removeListener(videoListner);
          podVideoStateChanger(PodVideoState.paused);
          podVideoStateChanger(PodVideoState.loading);
          playingVideoUrl = _videoQualityUrl;
          _videoCtr = VideoPlayerController.network(_videoQualityUrl);
          await _videoCtr?.initialize();
          _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
          _videoCtr?.addListener(videoListner);
          await _videoCtr?.seekTo(_videoPosition);
          setVideoPlayBack(_currentPaybackSpeed);
          podVideoStateChanger(PodVideoState.playing);
          onVimeoVideoQualityChanged?.call();
          update();
          update(['update-all']);
        } else {
          vimeoPlayingVideoQuality = quality;
          podVideoStateChanger(PodVideoState.paused);
          podVideoStateChanger(PodVideoState.loading);
          Timer(const Duration(milliseconds: 1000), () {
            podVideoStateChanger(PodVideoState.playing);
          });
        }
      }
    } else {
      if (vimeoPlayingVideoQuality != quality) {
        _videoQualityUrl = vimeoOrVideoUrls
            .where((element) => element.quality == quality)
            .first
            .url!;
        podLog(_videoQualityUrl);
        vimeoPlayingVideoQuality = quality;
        _videoCtr?.removeListener(videoListner);
        podVideoStateChanger(PodVideoState.paused);
        podVideoStateChanger(PodVideoState.loading);
        playingVideoUrl = _videoQualityUrl;
        _videoCtr = VideoPlayerController.network(_videoQualityUrl);
        await _videoCtr?.initialize();
        _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
        _videoCtr?.addListener(videoListner);
        await _videoCtr?.seekTo(_videoPosition);
        setVideoPlayBack(_currentPaybackSpeed);
        podVideoStateChanger(PodVideoState.playing);
        onVimeoVideoQualityChanged?.call();
        update();
        update(['update-all']);
      }
    }
  }
}
