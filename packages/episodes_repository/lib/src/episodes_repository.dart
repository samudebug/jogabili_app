import 'package:api_repository/api_repository.dart';
import 'package:episodes_repository/src/models/episode.dart';
import 'package:meta/meta.dart';

class EpisodesActionFailed implements Exception {}

class EpisodesRepository {
  EpisodesRepository({@required this.apiRepository})
      : assert(apiRepository != null);
  final APIRepository apiRepository;
  Future<List<Episode>> getGamesEpisodes({int page = 1}) async {
    try {
      List<Episode> result = [];
      List<dynamic> apiResponse = await apiRepository
          .performGet('http://localhost:3000/episodes/games?page=$page');
      result = apiResponse.map((e) => Episode.fromJson(e)).toList();
      return result;
    } on Exception {
      throw EpisodesActionFailed();
    }
  }

  Future<List<Episode>> getNonGamesEpisodes({int page = 1}) async {
    try {
      List<Episode> result = [];
      List<dynamic> apiResponse = await apiRepository
          .performGet('http://localhost:3000/episodes/non-games?page=$page');
      result = apiResponse.map((e) => Episode.fromJson(e)).toList();
      return result;
    } on Exception {
      throw EpisodesActionFailed();
    }
  }
}
