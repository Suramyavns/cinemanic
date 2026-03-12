import 'package:cinemanic/models/media_item.dart';
import 'package:cinemanic/utils/constants.dart';
import 'package:cinemanic/utils/images.dart';
import 'package:cinemanic/widgets/reusable_widgets/content_card_widget.dart';
import 'package:flutter/material.dart';

// The "Parent" or Base Class
class TrendingRowWidget extends StatefulWidget {
  const TrendingRowWidget({super.key, required this.title, required this.data});

  final String title;

  final TrendingDataClass data;

  @override
  State<TrendingRowWidget> createState() => _TrendingRowWidgetState();
}

class _TrendingRowWidgetState extends State<TrendingRowWidget> {
  // 1. Define abstract methods that children MUST implement
  late List<MediaItem> results;

  @override
  void initState() {
    setState(() {
      results = widget.data.results;
      results.sort((a, b) => (b.popularity - a.popularity).toInt());
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
                  mediaType: results[index].mediaType.name,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
