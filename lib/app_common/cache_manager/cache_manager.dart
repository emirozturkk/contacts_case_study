import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// this class is used to manage the cache of the images ensuring all images have one cache manager
class CustomCacheManager {
  static const key = 'customImageCacheKey';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );
}
