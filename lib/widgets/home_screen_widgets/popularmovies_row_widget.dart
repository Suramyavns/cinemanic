import 'package:cinemanic/models/movies.dart';
import 'package:cinemanic/utils/constants.dart';
import 'package:cinemanic/utils/images.dart';
import 'package:cinemanic/widgets/reusable_widgets/content_card_widget.dart';
import 'package:flutter/material.dart';

// The "Parent" or Base Class
class PopularmoviesRowWidget extends StatefulWidget {
  const PopularmoviesRowWidget({
    super.key,
    required this.title,
    required this.data,
  });

  final String title;

  final PopularMoviesResponse data;

  @override
  State<PopularmoviesRowWidget> createState() => _TrendingRowWidgetState();
}

class _TrendingRowWidgetState extends State<PopularmoviesRowWidget> {
  // 1. Define abstract methods that children MUST implement
  late List<Movie> results;

  @override
  void initState() {
    setState(() {
      results = widget.data.results;
      results.sort((a, b) => (a.voteAverage - b.voteAverage).toInt());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 3. This is the "Master Template"
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.left,
            style: KTextStyle.headingTextStyle,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16,
              children: List.generate(10, (index) {
                return ContentCardWidget(
                  imageSrc: imageUrlBuilder(results[index].posterPath!),
                  contentId: results[index].id,
                  mediaType: 'movie',
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
