part of 'pod_getx_video_controller.dart';

class PodVideoQualityController extends _PodVideoController {
  ///
  int? vimeoPlayingVideoQuality;

  String? highAudioUrl;

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

  void getUrl({String? url}) {
    highAudioUrl = url;
    update();
    update(['update-all']);
    podLog(highAudioUrl.toString());
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

  // Future<void> init() async {
  //   podLog("init audio");
  //   try {
  //     // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
  //     await _audioCtr?.setSourceUrl(
  //       'https://res.cloudinary.com/diqwddfh0/video/upload/v1686820373/ebfq5akmecslrig9abzz.mp3',
  //     );
  //   } catch (e) {
  //     podLog("Error loading audio source: $e");
  //   }
  // }

  void sortQualityVideoUrls(
    List<VideoQalityUrls>? urls,
  ) {
    final _urls = urls;

    ///has issues with 240p
    // _urls?.removeWhere((element) => element.quality == 240);

    ///has issues with 144p in web
    _urls?.removeWhere((element) => element.quality == 144);
    _urls?.removeWhere((element) => element.quality > 720);
    // _urls?.removeWhere(
    //   (element) =>
    //       element.url == '' && element.quality != 240 && element.quality != 480,
    // );

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

  Future<void> changeVideoQuality(int? quality, String? url, bool? isMuxed,
      PodGetXVideoController podCtr) async {
    print(vimeoOrVideoUrls.toString());
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }

    // if (isMuxed==false) {
    //   podVideoStateChanger(PodVideoState.paused);
    //   podVideoStateChanger(PodVideoState.loading);
    //   Timer(const Duration(milliseconds: 1000), () {
    //     podVideoStateChanger(PodVideoState.playing);
    //   });
    // }

    if (isMuxed == false) {
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
        await _audioCtr.play(
          UrlSource(
            'https://rr1---sn-gwpa-jv3z.googlevideo.com/videoplayback?expire=1689859531&ei=a-G4ZKCgOdqr9fwPlqyQoAI&ip=49.37.232.5&id=o-AL9Qt4CXCYyC1Tm2D5_xlPX-InVFOxPZzsEarhBGd0__&itag=251&source=youtube&requiressl=yes&mh=wp&mm=31%2C29&mn=sn-gwpa-jv3z%2Csn-gwpa-h55d&ms=au%2Crdu&mv=m&mvi=1&pl=20&initcwndbps=552500&spc=Ul2Sqys8PA0zd-lKFJ2eqlmhGTpRmKA&vprv=1&svpuc=1&mime=audio%2Fwebm&gir=yes&clen=119364144&dur=7650.201&lmt=1681276528246182&mt=1689837449&fvip=6&keepalive=yes&fexp=24007246%2C24363391%2C51000011&beids=24472443&c=ANDROID&txp=5432434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRAIgeTqD28lhE-Iclb0S1NgVTpnoxAFumDL6PzxEM3lW5l4CIF4zTSqaUMMNEiyerRrePNPjITnF4-JGi8Sr3CaW1-Yk&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRAIgfpFuBehO9S7s4MNZPnwYNROTvv0GJWcBb9L5FRzmjFoCICEH_eZ6G7GFxwyeI4S0B3usKZouWpCbgs2WB33kzFSP',
          ),
        );
        podVideoStateChanger(PodVideoState.playing);
        onVimeoVideoQualityChanged?.call();
        update();
        update(['update-all']);
      }
      // if (quality == 240 && url == '') {
      //   if (vimeoOrVideoUrls.any((element) => element.quality > 240)) {
      //     _videoQualityUrl = vimeoOrVideoUrls
      //         .where((element) => element.quality > 240)
      //         .first
      //         .url!;
      //   } else {
      //     vimeoPlayingVideoQuality = quality;
      //     podVideoStateChanger(PodVideoState.paused);
      //     podVideoStateChanger(PodVideoState.loading);
      //     Timer(const Duration(milliseconds: 1000), () {
      //       podVideoStateChanger(PodVideoState.playing);
      //     });
      //   }

      //   podLog(_videoQualityUrl);
      //   vimeoPlayingVideoQuality = quality;
      //   _videoCtr?.removeListener(videoListner);
      //   podVideoStateChanger(PodVideoState.paused);
      //   podVideoStateChanger(PodVideoState.loading);
      //   playingVideoUrl = _videoQualityUrl;
      //   _videoCtr = VideoPlayerController.network(_videoQualityUrl);
      //   await _videoCtr?.initialize();
      //   _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      //   _videoCtr?.addListener(videoListner);
      //   await _videoCtr?.seekTo(_videoPosition);
      //   setVideoPlayBack(_currentPaybackSpeed);
      //   podVideoStateChanger(PodVideoState.playing);
      //   onVimeoVideoQualityChanged?.call();
      //   update();
      //   update(['update-all']);
      // }
      // if (quality == 480 && url == '') {
      //   if (vimeoOrVideoUrls.any((element) => element.quality > 480)) {
      //     _videoQualityUrl = vimeoOrVideoUrls
      //         .where((element) => element.quality > 480)
      //         .first
      //         .url!;
      //   } else {
      //     vimeoPlayingVideoQuality = quality;
      //     podVideoStateChanger(PodVideoState.paused);
      //     podVideoStateChanger(PodVideoState.loading);
      //     Timer(const Duration(milliseconds: 1000), () {
      //       podVideoStateChanger(PodVideoState.playing);
      //     });
      //   }

      //   podLog(_videoQualityUrl);
      //   vimeoPlayingVideoQuality = quality;
      //   _videoCtr?.removeListener(videoListner);
      //   podVideoStateChanger(PodVideoState.paused);
      //   podVideoStateChanger(PodVideoState.loading);
      //   playingVideoUrl = _videoQualityUrl;
      //   _videoCtr = VideoPlayerController.network(_videoQualityUrl);
      //   await _videoCtr?.initialize();
      //   _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      //   _videoCtr?.addListener(videoListner);
      //   await _videoCtr?.seekTo(_videoPosition);
      //   setVideoPlayBack(_currentPaybackSpeed);
      //   podVideoStateChanger(PodVideoState.playing);
      //   onVimeoVideoQualityChanged?.call();
      //   update();
      //   update(['update-all']);
      // }
    } else {
      if (vimeoPlayingVideoQuality != quality) {
        await _videoCtr?.pause();
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
