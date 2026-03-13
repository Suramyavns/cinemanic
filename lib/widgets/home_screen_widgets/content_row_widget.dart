import 'package:cinemanic/utils/constants.dart';
import 'package:cinemanic/utils/images.dart';
import 'package:cinemanic/widgets/reusable_widgets/content_card_widget.dart';
import 'package:flutter/material.dart';

// The "Parent" or Base Class
class ContentRowWidget extends StatefulWidget {
  const ContentRowWidget({
    super.key,
    required this.title,
    required this.data,
    required this.mediaType,
    this.onReturn,
  });

  final String title;
  final dynamic data;
  final String mediaType;
  final VoidCallback? onReturn;

  @override
  State<ContentRowWidget> createState() => _ContentRowWidgetState();
}

class _ContentRowWidgetState extends State<ContentRowWidget> {
  // 1. Define abstract methods that children MUST implement
  late List<dynamic> results;

  @override
  void initState() {
    setState(() {
      if (widget.data is List) {
        results = widget.data;
      } else {
        results = widget.data.results;
        try {
          results.sort((a, b) => (b.voteAverage - a.voteAverage).toInt());
        } catch (_) {}
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 3. This is the "Master Template"
    if (results.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
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
              children: List.generate(
                results.length > 10 ? 10 : results.length,
                (index) {
                  return ContentCardWidget(
                    imageSrc: imageUrlBuilder(results[index].posterPath ?? ''),
                    contentId: results[index].id,
                    mediaType: widget.mediaType == 'history'
                        ? results[index].type
                        : widget.mediaType,
                    onReturn: widget.onReturn,
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
