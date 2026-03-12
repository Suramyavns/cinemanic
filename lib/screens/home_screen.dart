import 'package:cinemanic/models/media_item.dart';
import 'package:cinemanic/models/movies.dart';
import 'package:cinemanic/models/shows.dart';
import 'package:cinemanic/services/content_api/movies.dart';
import 'package:cinemanic/services/content_api/tv.dart';
import 'package:cinemanic/services/content_api/trending.dart';
import 'package:cinemanic/widgets/home_screen_widgets/popularmovies_row_widget.dart';
import 'package:cinemanic/widgets/home_screen_widgets/topshows_row_widget.dart';
import 'package:cinemanic/widgets/home_screen_widgets/trending_row_widget.dart';
import 'package:cinemanic/widgets/reusable_widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TrendingDataClass trendingData;
  late TopRatedTvResponse topShowsData;
  late PopularMoviesResponse popularMoviesData;

  bool isLoading = true;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> loadData() async {
    try {
      TrendingDataClass trending = await fetchTrending();
      TopRatedTvResponse topShows = await fetchTopShows();
      PopularMoviesResponse popularMovies = await fetchPopularMovies();
      if (mounted) {
        setState(() {
          trendingData = trending;
          topShowsData = topShows;
          popularMoviesData = popularMovies;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error so isLoading doesn't spin forever
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SearchBarWidget(),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 16),
              child: isLoading
                  ? LinearProgressIndicator()
                  : Column(
                      children: [
                        TrendingRowWidget(
                          title: 'Trending',
                          data: trendingData,
                        ),
                        PopularmoviesRowWidget(
                          title: 'Popular Movies',
                          data: popularMoviesData,
                        ),
                        TopshowsRowWidget(
                          title: 'Top Rated Shows',
                          data: topShowsData,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
