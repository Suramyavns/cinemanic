// models/country.dart
// Response: /configuration/countries

class Country {
  final String iso31661;
  final String englishName;
  final String nativeName;

  Country({
    required this.iso31661,
    required this.englishName,
    required this.nativeName,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    iso31661: json['iso_3166_1'] as String,
    englishName: json['english_name'] as String,
    nativeName: json['native_name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'iso_3166_1': iso31661,
    'english_name': englishName,
    'native_name': nativeName,
  };
}

// models/language.dart
// Response: /configuration/languages

class Language {
  final String iso6391;
  final String englishName;
  final String name; // native name, may be empty string

  Language({
    required this.iso6391,
    required this.englishName,
    required this.name,
  });

  /// Returns native name if available, otherwise falls back to english name
  String get displayName => name.isNotEmpty ? name : englishName;

  bool get hasNativeName => name.isNotEmpty;

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    iso6391: json['iso_639_1'] as String,
    englishName: json['english_name'] as String,
    name: json['name'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'iso_639_1': iso6391,
    'english_name': englishName,
    'name': name,
  };
}

// models/genre.dart
// Response: /genre/movie/list or /genre/tv/list

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: json['id'] as int, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// Wrapper for the genres list endpoint
class GenreListResponse {
  final List<Genre> genres;

  GenreListResponse({required this.genres});

  factory GenreListResponse.fromJson(Map<String, dynamic> json) =>
      GenreListResponse(
        genres: (json['genres'] as List<dynamic>)
            .map((e) => Genre.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'genres': genres.map((e) => e.toJson()).toList(),
  };
}

// models/production_company_detail.dart
// Response: /company/{id}  (full detail endpoint — richer than the embedded version)

class ProductionCompanyDetail {
  final String description;
  final String headquarters;
  final String? homepage;
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;
  final ParentCompany? parentCompany;

  ProductionCompanyDetail({
    required this.description,
    required this.headquarters,
    this.homepage,
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
    this.parentCompany,
  });

  String? get logoUrl =>
      logoPath != null ? 'https://image.tmdb.org/t/p/w200$logoPath' : null;

  factory ProductionCompanyDetail.fromJson(Map<String, dynamic> json) =>
      ProductionCompanyDetail(
        description: json['description'] as String? ?? '',
        headquarters: json['headquarters'] as String? ?? '',
        homepage: json['homepage'] as String?,
        id: json['id'] as int,
        logoPath: json['logo_path'] as String?,
        name: json['name'] as String,
        originCountry: json['origin_country'] as String? ?? '',
        parentCompany: json['parent_company'] != null
            ? ParentCompany.fromJson(
                json['parent_company'] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
    'description': description,
    'headquarters': headquarters,
    if (homepage != null) 'homepage': homepage,
    'id': id,
    if (logoPath != null) 'logo_path': logoPath,
    'name': name,
    'origin_country': originCountry,
    'parent_company': parentCompany?.toJson(),
  };
}

class ParentCompany {
  final int id;
  final String name;
  final String? logoPath;

  ParentCompany({required this.id, required this.name, this.logoPath});

  String? get logoUrl =>
      logoPath != null ? 'https://image.tmdb.org/t/p/w200$logoPath' : null;

  factory ParentCompany.fromJson(Map<String, dynamic> json) => ParentCompany(
    id: json['id'] as int,
    name: json['name'] as String,
    logoPath: json['logo_path'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (logoPath != null) 'logo_path': logoPath,
  };
}

// models/production_company.dart
// Embedded version used inside MovieDetail / TvShowDetail

class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  String? get logoUrl =>
      logoPath != null ? 'https://image.tmdb.org/t/p/w200$logoPath' : null;

  factory ProductionCompany.fromJson(Map<String, dynamic> json) =>
      ProductionCompany(
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

// models/production_country.dart
// Embedded version used inside MovieDetail / TvShowDetail

class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({required this.iso31661, required this.name});

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      ProductionCountry(
        iso31661: json['iso_3166_1'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {'iso_3166_1': iso31661, 'name': name};
}

// models/spoken_language.dart
// Embedded version used inside MovieDetail / TvShowDetail

class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  String get displayName => name.isNotEmpty ? name : englishName;

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) => SpokenLanguage(
    englishName: json['english_name'] as String,
    iso6391: json['iso_639_1'] as String,
    name: json['name'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'english_name': englishName,
    'iso_639_1': iso6391,
    'name': name,
  };
}
