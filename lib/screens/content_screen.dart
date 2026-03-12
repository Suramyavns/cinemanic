import 'package:cinemanic/models/movies.dart';
import 'package:cinemanic/models/shows.dart';
import 'package:cinemanic/services/content_api/movies.dart';
import 'package:cinemanic/services/content_api/tv.dart';
import 'package:cinemanic/widgets/content_screen_widgets/banner_widget.dart';
import 'package:cinemanic/widgets/content_screen_widgets/content_details_widget.dart';
import 'package:cinemanic/widgets/theme_switcher_widget.dart';
import 'package:flutter/material.dart';

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
  late TvShowDetail tvData;
  late MovieDetail movieData;

  bool isLoading = true;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    if (widget.mediaType == 'tv') {
      tvData = await fetchTvShowById(widget.contentId);
    } else {
      movieData = await fetchMovieById(widget.contentId);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [ThemeSwitcherWidget()]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BannerWidget(
                        contentId: widget.contentId,
                        imagePath: widget.mediaType == 'tv'
                            ? tvData.backdropPath!
                            : movieData.backdropPath!,
                        mediaType: widget.mediaType,
                      ),
                      ContentDetailsWidget(
                        title: widget.mediaType == 'tv'
                            ? tvData.name
                            : movieData.title,
                        description: widget.mediaType == 'tv'
                            ? tvData.overview
                            : movieData.overview,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
