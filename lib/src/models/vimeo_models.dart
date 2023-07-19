class VideoQalityUrls {
  int quality;
  String? url;
  bool? isMuxed;
  VideoQalityUrls({
    required this.quality,
    required this.url,
    this.isMuxed = true,
  });

  @override
  String toString() => 'VideoQalityUrls(quality: $quality, urls: $url)';
}
