import 'package:cinemanic/screens/content_screen.dart';
import 'package:flutter/material.dart';

class ContentCardWidget extends StatefulWidget {
  const ContentCardWidget({
    super.key,
    required this.imageSrc,
    required this.contentId,
    required this.mediaType,
  });

  final String imageSrc;
  final int contentId;
  final String mediaType;

  @override
  State<ContentCardWidget> createState() => _ContentCardWidgetState();
}

class _ContentCardWidgetState extends State<ContentCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContentScreen(
                contentId: widget.contentId,
                mediaType: widget.mediaType,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(widget.imageSrc, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
