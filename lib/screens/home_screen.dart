import 'dart:async';

import 'package:cinemanic/models/media_item.dart';
import 'package:cinemanic/models/tmdb_models.dart' hide MediaType;
import 'package:cinemanic/models/watch_history.dart';
import 'package:cinemanic/services/content_api/movies.dart';
import 'package:cinemanic/services/content_api/search.dart';
import 'package:cinemanic/services/content_api/tv.dart';
import 'package:cinemanic/services/content_api/trending.dart';
import 'package:cinemanic/screens/content_screen.dart';
import 'package:cinemanic/widgets/home_screen_widgets/content_row_widget.dart';
import 'package:cinemanic/widgets/reusable_widgets/search_bar_widget.dart';
import 'package:cinemanic/widgets/reusable_widgets/search_result_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cinemanic/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TrendingDataClass trendingData;
  late TopRatedTvResponse topShowsData;
  late PopularMoviesResponse popularMoviesData;
  List<WatchHistoryItem> watchHistoryData = [];

  bool isLoading = true;

  // Search state
  Timer? _debounce;
  List<TmdbMedia> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      TrendingDataClass trending = await fetchTrending();
      TopRatedTvResponse topShows = await fetchTopShows();
      PopularMoviesResponse popularMovies = await fetchPopularMovies();

      List<WatchHistoryItem> history = [];
      try {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) {
          final apiUrl = serverUrl;
          final response = await http.get(
            Uri.parse('$apiUrl/api/watch/history'),
            headers: {'Authorization': 'Bearer $token'},
          );
          if (response.statusCode == 200) {
            final List data = jsonDecode(response.body);
            history = data.map((x) => WatchHistoryItem.fromJson(x)).toList();
          }
        }
      } catch (e) {
        debugPrint('Failed to load history: $e');
      }

      if (mounted) {
        setState(() {
          trendingData = trending;
          topShowsData = topShows;
          popularMoviesData = popularMovies;
          watchHistoryData = history;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error so isLoading doesn't spin forever
      print(e);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _currentQuery = '';
        });
        return;
      }

      setState(() {
        _isSearching = true;
        _currentQuery = query;
      });

      try {
        final results = await searchContent(query);
        if (mounted && _currentQuery == query) {
          setState(() {
            _searchResults = results.results
                .where((item) => item.mediaType.name != 'unknown')
                .toList();

            _searchResults.sort((a, b) => b.popularity.compareTo(a.popularity));
            _isSearching = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Search error: $e');
        }
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SearchBarWidget(onChanged: _onSearchChanged),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isLoading
                      ? const LinearProgressIndicator()
                      : Column(
                          children: [
                            if (watchHistoryData.isNotEmpty)
                              ContentRowWidget(
                                title: 'Continue Watching',
                                data: watchHistoryData,
                                mediaType: 'history',
                                onReturn: loadData,
                              ),
                            ContentRowWidget(
                              title: 'Trending',
                              data: trendingData,
                              mediaType: trendingData.results[0].mediaType.name,
                              onReturn: loadData,
                            ),
                            ContentRowWidget(
                              title: 'Popular Movies',
                              data: popularMoviesData,
                              mediaType: 'movie',
                              onReturn: loadData,
                            ),
                            ContentRowWidget(
                              title: 'Top Rated Shows',
                              data: topShowsData,
                              mediaType: 'tv',
                              onReturn: loadData,
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                ),
              ],
            ),
          ),
          if (_currentQuery.isNotEmpty)
            Positioned(
              top: 60, // Positioned below the search bar
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return SearchResultCard(
                            item: item,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContentScreen(
                                    contentId: item.id,
                                    mediaType: item.mediaType.name,
                                  ),
                                ),
                              );
                              loadData();
                            },
                          );
                        },
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
