// models/top_rated_tv_response.dart

import 'package:cinemanic/models/movies.dart';

class TopRatedTvResponse {
  final int page;
  final List<TvShow> results;
  final int totalPages;
  final int totalResults;

  TopRatedTvResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TopRatedTvResponse.fromJson(Map<String, dynamic> json) {
    return TopRatedTvResponse(
      page: json['page'] as int,
      results: (json['results'] as List<dynamic>)
          .map((item) => TvShow.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'results': results.map((e) => e.toJson()).toList(),
    'total_pages': totalPages,
    'total_results': totalResults,
  };
}

// models/tv_show.dart

class TvShow {
  final String? backdropPath;
  final String firstAirDate;
  final List<int> genreIds;
  final int id;
  final String name;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath;
  final double voteAverage;
  final int voteCount;

  TvShow({
    this.backdropPath,
    required this.firstAirDate,
    required this.genreIds,
    required this.id,
    required this.name,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.voteAverage,
    required this.voteCount,
  });

  /// Helper: full poster URL
  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;

  /// Helper: full backdrop URL
  String? get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/original$backdropPath'
      : null;

  /// Helper: release year only
  String get year =>
      firstAirDate.isNotEmpty ? firstAirDate.substring(0, 4) : 'N/A';

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      backdropPath: json['backdrop_path'] as String?,
      firstAirDate: json['first_air_date'] as String? ?? '',
      genreIds: (json['genre_ids'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      id: json['id'] as int,
      name: json['name'] as String,
      originCountry: (json['origin_country'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      originalLanguage: json['original_language'] as String,
      originalName: json['original_name'] as String,
      overview: json['overview'] as String,
      popularity: (json['popularity'] as num).toDouble(),
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    if (backdropPath != null) 'backdrop_path': backdropPath,
    'first_air_date': firstAirDate,
    'genre_ids': genreIds,
    'id': id,
    'name': name,
    'origin_country': originCountry,
    'original_language': originalLanguage,
    'original_name': originalName,
    'overview': overview,
    'popularity': popularity,
    if (posterPath != null) 'poster_path': posterPath,
    'vote_average': voteAverage,
    'vote_count': voteCount,
  };
}

// models/tv_show_detail.dart

class TvShowDetail {
  final bool adult;
  final String? backdropPath;
  final List<CreatedBy> createdBy;
  final List<int> episodeRunTime;
  final String firstAirDate;
  final List<Genre> genres;
  final String? homepage;
  final int id;
  final bool inProduction;
  final List<String> languages;
  final String lastAirDate;
  final Episode? lastEpisodeToAir;
  final String name;
  final Episode? nextEpisodeToAir;
  final List<Network> networks;
  final int numberOfEpisodes;
  final int numberOfSeasons;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<Season> seasons;
  final List<SpokenLanguage> spokenLanguages;
  final String status;
  final String? tagline;
  final String type;
  final double voteAverage;
  final int voteCount;

  TvShowDetail({
    required this.adult,
    this.backdropPath,
    required this.createdBy,
    required this.episodeRunTime,
    required this.firstAirDate,
    required this.genres,
    this.homepage,
    required this.id,
    required this.inProduction,
    required this.languages,
    required this.lastAirDate,
    this.lastEpisodeToAir,
    required this.name,
    this.nextEpisodeToAir,
    required this.networks,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.seasons,
    required this.spokenLanguages,
    required this.status,
    this.tagline,
    required this.type,
    required this.voteAverage,
    required this.voteCount,
  });

  // Convenience getters
  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;

  String? get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/original$backdropPath'
      : null;

  String get startYear =>
      firstAirDate.isNotEmpty ? firstAirDate.substring(0, 4) : 'N/A';

  String get endYear =>
      lastAirDate.isNotEmpty ? lastAirDate.substring(0, 4) : 'N/A';

  String get yearRange => inProduction ? '$startYear–' : '$startYear–$endYear';

  List<String> get genreNames => genres.map((g) => g.name).toList();

  // Excludes "Specials" (season_number == 0)
  List<Season> get regularSeasons =>
      seasons.where((s) => s.seasonNumber > 0).toList();

  factory TvShowDetail.fromJson(Map<String, dynamic> json) {
    return TvShowDetail(
      adult: json['adult'] as bool,
      backdropPath: json['backdrop_path'] as String?,
      createdBy: (json['created_by'] as List<dynamic>)
          .map((e) => CreatedBy.fromJson(e as Map<String, dynamic>))
          .toList(),
      episodeRunTime: (json['episode_run_time'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      firstAirDate: json['first_air_date'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>)
          .map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
      homepage: json['homepage'] as String?,
      id: json['id'] as int,
      inProduction: json['in_production'] as bool,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastAirDate: json['last_air_date'] as String? ?? '',
      lastEpisodeToAir: json['last_episode_to_air'] != null
          ? Episode.fromJson(
              json['last_episode_to_air'] as Map<String, dynamic>,
            )
          : null,
      name: json['name'] as String,
      nextEpisodeToAir: json['next_episode_to_air'] != null
          ? Episode.fromJson(
              json['next_episode_to_air'] as Map<String, dynamic>,
            )
          : null,
      networks: (json['networks'] as List<dynamic>)
          .map((e) => Network.fromJson(e as Map<String, dynamic>))
          .toList(),
      numberOfEpisodes: json['number_of_episodes'] as int,
      numberOfSeasons: json['number_of_seasons'] as int,
      originCountry: (json['origin_country'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      originalLanguage: json['original_language'] as String,
      originalName: json['original_name'] as String,
      overview: json['overview'] as String,
      popularity: (json['popularity'] as num).toDouble(),
      posterPath: json['poster_path'] as String?,
      productionCompanies: (json['production_companies'] as List<dynamic>)
          .map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
          .toList(),
      productionCountries: (json['production_countries'] as List<dynamic>)
          .map((e) => ProductionCountry.fromJson(e as Map<String, dynamic>))
          .toList(),
      seasons: (json['seasons'] as List<dynamic>)
          .map((e) => Season.fromJson(e as Map<String, dynamic>))
          .toList(),
      spokenLanguages: (json['spoken_languages'] as List<dynamic>)
          .map((e) => SpokenLanguage.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      tagline: json['tagline'] as String?,
      type: json['type'] as String,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'adult': adult,
    if (backdropPath != null) 'backdrop_path': backdropPath,
    'created_by': createdBy.map((e) => e.toJson()).toList(),
    'episode_run_time': episodeRunTime,
    'first_air_date': firstAirDate,
    'genres': genres.map((e) => e.toJson()).toList(),
    if (homepage != null) 'homepage': homepage,
    'id': id,
    'in_production': inProduction,
    'languages': languages,
    'last_air_date': lastAirDate,
    'last_episode_to_air': lastEpisodeToAir?.toJson(),
    'name': name,
    'next_episode_to_air': nextEpisodeToAir?.toJson(),
    'networks': networks.map((e) => e.toJson()).toList(),
    'number_of_episodes': numberOfEpisodes,
    'number_of_seasons': numberOfSeasons,
    'origin_country': originCountry,
    'original_language': originalLanguage,
    'original_name': originalName,
    'overview': overview,
    'popularity': popularity,
    if (posterPath != null) 'poster_path': posterPath,
    'production_companies': productionCompanies.map((e) => e.toJson()).toList(),
    'production_countries': productionCountries.map((e) => e.toJson()).toList(),
    'seasons': seasons.map((e) => e.toJson()).toList(),
    'spoken_languages': spokenLanguages.map((e) => e.toJson()).toList(),
    'status': status,
    if (tagline != null) 'tagline': tagline,
    'type': type,
    'vote_average': voteAverage,
    'vote_count': voteCount,
  };
}

// models/created_by.dart

class CreatedBy {
  final int id;
  final String creditId;
  final String name;
  final int gender;
  final String? profilePath;

  CreatedBy({
    required this.id,
    required this.creditId,
    required this.name,
    required this.gender,
    this.profilePath,
  });

  String? get profileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w185$profilePath'
      : null;

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json['id'] as int,
    creditId: json['credit_id'] as String,
    name: json['name'] as String,
    gender: json['gender'] as int,
    profilePath: json['profile_path'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'credit_id': creditId,
    'name': name,
    'gender': gender,
    if (profilePath != null) 'profile_path': profilePath,
  };
}

// models/episode.dart

class Episode {
  final int id;
  final String name;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String airDate;
  final int episodeNumber;
  final String productionCode;
  final int? runtime;
  final int seasonNumber;
  final int showId;
  final String? stillPath;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.airDate,
    required this.episodeNumber,
    required this.productionCode,
    this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
  });

  String? get stillUrl =>
      stillPath != null ? 'https://image.tmdb.org/t/p/w300$stillPath' : null;

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    id: json['id'] as int,
    name: json['name'] as String,
    overview: json['overview'] as String,
    voteAverage: (json['vote_average'] as num).toDouble(),
    voteCount: json['vote_count'] as int,
    airDate: json['air_date'] as String? ?? '',
    episodeNumber: json['episode_number'] as int,
    productionCode: json['production_code'] as String? ?? '',
    runtime: json['runtime'] as int?,
    seasonNumber: json['season_number'] as int,
    showId: json['show_id'] as int,
    stillPath: json['still_path'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'overview': overview,
    'vote_average': voteAverage,
    'vote_count': voteCount,
    'air_date': airDate,
    'episode_number': episodeNumber,
    'production_code': productionCode,
    if (runtime != null) 'runtime': runtime,
    'season_number': seasonNumber,
    'show_id': showId,
    if (stillPath != null) 'still_path': stillPath,
  };
}

// models/network.dart

class Network {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  Network({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  String? get logoUrl =>
      logoPath != null ? 'https://image.tmdb.org/t/p/w200$logoPath' : null;

  factory Network.fromJson(Map<String, dynamic> json) => Network(
    id: json['id'] as int,
    logoPath: json['logo_path'] as String?,
    name: json['name'] as String,
    originCountry: json['origin_country'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (logoPath != null) 'logo_path': logoPath,
    'name': name,
    'origin_country': originCountry,
  };
}

// models/season.dart

class Season {
  final String? airDate;
  final int episodeCount;
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final int seasonNumber;
  final double voteAverage;

  Season({
    this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
  });

  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w300$posterPath' : null;

  bool get isSpecials => seasonNumber == 0;

  factory Season.fromJson(Map<String, dynamic> json) => Season(
    airDate: json['air_date'] as String?,
    episodeCount: json['episode_count'] as int,
    id: json['id'] as int,
    name: json['name'] as String,
    overview: json['overview'] as String? ?? '',
    posterPath: json['poster_path'] as String?,
    seasonNumber: json['season_number'] as int,
    voteAverage: (json['vote_average'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    if (airDate != null) 'air_date': airDate,
    'episode_count': episodeCount,
    'id': id,
    'name': name,
    'overview': overview,
    if (posterPath != null) 'poster_path': posterPath,
    'season_number': seasonNumber,
    'vote_average': voteAverage,
  };
}
