import 'package:injectable/injectable.dart';
import 'package:smart_duel_disk/packages/core/core_config/core_config_interface/lib/core_config_interface.dart';
import 'package:smart_duel_disk/packages/core/core_data_manager/core_data_manager_interface/lib/core_data_manager_interface.dart';
import 'package:smart_duel_disk/packages/wrappers/wrapper_twitter/wrapper_twitter_interface/lib/wrapper_twitter_interface.dart';

@LazySingleton(as: NewsDataManager)
class NewsDataManagerImpl implements NewsDataManager {
  final AppConfig _appConfig;
  final TwitterProvider _twitterProvider;

  NewsDataManagerImpl(
    this._appConfig,
    this._twitterProvider,
  );

  @override
  Future<Iterable<NewsItem>> getNewsItems() async {
    final newsItems = await _twitterProvider.getUserTweets(_appConfig.twitterUserId);
    newsItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return newsItems.reversed;
  }
}
