import 'package:cinemanic/models/tmdb_models.dart';
import 'package:cinemanic/services/content_api/movies.dart';
import 'package:cinemanic/services/content_api/tv.dart';
import 'package:cinemanic/widgets/content_screen_widgets/banner_widget.dart';
import 'package:cinemanic/widgets/content_screen_widgets/content_details_widget.dart';
import 'package:cinemanic/widgets/content_screen_widgets/content_tabs_widget.dart';
import 'package:cinemanic/widgets/content_screen_widgets/season_selector_widget.dart';
import 'package:cinemanic/widgets/theme_switcher_widget.dart';
import 'package:cinemanic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ContentScreen extends StatefulWidget {
  const ContentScreen({
    super.key,
    required this.contentId,
    required this.mediaType,
  });

  final int contentId;
  final String mediaType;

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  TvShowDetail? tvData;
  MovieDetail? movieData;
  CreditResponse? credits;
  List<AlternativeTitle>? altTitles;
  List<ReleaseInfo>? releases;
  int? startAtProgress;
  int? lastSeasonWatched;
  int? lastEpisodeWatched;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (widget.mediaType == 'tv') {
        final futures = await Future.wait([
          fetchTvShowById(widget.contentId),
          fetchTvCredits(widget.contentId),
          fetchTvAlternativeTitles(widget.contentId),
          // For TV, releases info is a bit different
          Future.value(<ReleaseInfo>[]),
        ]);
        tvData = futures[0] as TvShowDetail;
        credits = futures[1] as CreditResponse;
        altTitles = futures[2] as List<AlternativeTitle>;
        releases = futures[3] as List<ReleaseInfo>;
      } else {
        final futures = await Future.wait([
          fetchMovieById(widget.contentId),
          fetchMovieCredits(widget.contentId),
          fetchMovieAlternativeTitles(widget.contentId),
          fetchMovieReleaseInfo(widget.contentId),
        ]);
        movieData = futures[0] as MovieDetail;
        credits = futures[1] as CreditResponse;
        altTitles = futures[2] as List<AlternativeTitle>;
        releases = futures[3] as List<ReleaseInfo>;
      }
    } catch (e) {
      debugPrint('Error loading content data: $e');
      errorMessage =
          'Failed to load content details. Please check your connection and try again.';
    }

    // Try to fetch progress independently so it doesn't fail the whole screen
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null) {
        final apiUrl = serverUrl;
        final response = await http.get(
          Uri.parse('$apiUrl/api/watch/progress?mediaId=${widget.contentId}'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200 &&
            response.body.isNotEmpty &&
            response.body != 'null') {
          final data = jsonDecode(response.body);
          if (data != null) {
            if (data['progress'] != null &&
                data['progress']['watched'] != null) {
              startAtProgress = (data['progress']['watched'] as num).toInt();
            }
            if (data['lastSeasonWatched'] != null) {
              lastSeasonWatched = int.tryParse(
                data['lastSeasonWatched'].toString(),
              );
            }
            if (data['lastEpisodeWatched'] != null) {
              lastEpisodeWatched = int.tryParse(
                data['lastEpisodeWatched'].toString(),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch watch progress: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get _isAnime {
    if (widget.mediaType != 'tv' || tvData == null) return false;
    final hasAnimeGenre = tvData!.genres.any(
      (g) => g.name.toLowerCase() == 'animation',
    );
    final isFromJapan = tvData!.originCountry.contains('JP');
    return hasAnimeGenre && isFromJapan;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(actions: [ThemeSwitcherWidget()]),
        body: LinearProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(actions: [ThemeSwitcherWidget()]),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: loadData, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    // Safety check - should not happen if isLoading is false and errorMessage is null
    if (widget.mediaType == 'tv' ? tvData == null : movieData == null) {
      return const Scaffold(body: Center(child: Text('Data error')));
    }

    return Scaffold(
      appBar: AppBar(actions: [ThemeSwitcherWidget()]),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BannerWidget(
                  contentId: widget.contentId,
                  imagePath: widget.mediaType == 'tv'
                      ? tvData!.backdropPath!
                      : movieData!.backdropPath!,
                  mediaType: widget.mediaType,
                  startAt: startAtProgress,
                  lastSeasonWatched: lastSeasonWatched,
                  lastEpisodeWatched: lastEpisodeWatched,
                  onReturn: loadData,
                ),
                ContentDetailsWidget(
                  title: widget.mediaType == 'tv'
                      ? tvData!.name
                      : movieData!.title,
                  description: widget.mediaType == 'tv'
                      ? tvData!.overview
                      : movieData!.overview,
                  genres: widget.mediaType == 'tv'
                      ? tvData!.genreNames
                      : movieData!.genreNames,
                ),
                _buildReviewButton(),
                Column(
                  spacing: 0,
                  children: [
                    if (widget.mediaType == 'tv')
                      SeasonSelectorWidget(
                        tvId: widget.contentId,
                        seasons: tvData!.seasons
                            .map(
                              (s) => Season(
                                id: s.id,
                                name: s.name,
                                overview: s.overview,
                                seasonNumber: s.seasonNumber,
                                voteAverage: s.voteAverage,
                                episodeCount: s.episodeCount,
                                airDate: s.airDate,
                                posterPath: s.posterPath,
                              ),
                            )
                            .toList(),
                        isAnime: _isAnime,
                        onReturn: loadData,
                      ),
                    ContentTabsWidget(
                      credits: credits!,
                      genres: widget.mediaType == 'tv'
                          ? tvData!.genreNames
                          : movieData!.genreNames,
                      altTitles: altTitles!,
                      releases: releases!,
                      studios: widget.mediaType == 'tv'
                          ? tvData!.productionCompanies
                                .map(
                                  (c) => ProductionCompany(
                                    id: c.id,
                                    name: c.name,
                                    logoPath: c.logoPath,
                                    originCountry: c.originCountry,
                                  ),
                                )
                                .toList()
                          : movieData!.productionCompanies
                                .map(
                                  (c) => ProductionCompany(
                                    id: c.id,
                                    name: c.name,
                                    logoPath: c.logoPath,
                                    originCountry: c.originCountry,
                                  ),
                                )
                                .toList(),
                      countries: widget.mediaType == 'tv'
                          ? tvData!.productionCountries
                                .map(
                                  (c) => ProductionCountry(
                                    iso31661: c.iso31661,
                                    name: c.name,
                                  ),
                                )
                                .toList()
                          : movieData!.productionCountries
                                .map(
                                  (c) => ProductionCountry(
                                    iso31661: c.iso31661,
                                    name: c.name,
                                  ),
                                )
                                .toList(),
                      originalLanguage: widget.mediaType == 'tv'
                          ? tvData!.originalLanguage
                          : movieData!.originalLanguage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Placeholder for review functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review functionality coming soon!')),
          );
        },
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Log, rate or review'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
