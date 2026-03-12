import 'package:cinemanic/services/content_api/player.dart';
import 'package:cinemanic/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({
    super.key,
    required this.contentId,
    required this.imagePath,
    required this.mediaType,
  });

  final int contentId;
  final String imagePath;
  final String mediaType;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Huge Rectangular Poster
        SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrlBuilder(imagePath), fit: BoxFit.fill),
          ),
        ),
        // Gradient Overlay for Buttons
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
            ),
          ),
        ),
        // Overlaid Buttons
        Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final url = await fetchVideoPlayer(
                        mediaType == 'tv'
                            ? '$mediaType/$contentId/1/1'
                            : '$mediaType/$contentId',
                      );
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 30),
                    label: Text(
                      mediaType == 'tv' ? 'Play S01E01' : 'Play',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, size: 30),
                    label: const Text(
                      'Watchlist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey[800]?.withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
