import 'package:cinemanic/screens/video_player.dart';
import 'package:flutter/material.dart';

class BannerWidget extends StatelessWidget {
  final int contentId;
  final String imagePath;
  final String mediaType;
  final int? startAt;
  final int? lastSeasonWatched;
  final int? lastEpisodeWatched;
  final VoidCallback? onReturn;

  const BannerWidget({
    super.key,
    required this.contentId,
    required this.imagePath,
    required this.mediaType,
    this.startAt,
    this.lastSeasonWatched,
    this.lastEpisodeWatched,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Huge Rectangular Poster
        SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath.isNotEmpty
                ? Image.network(
                    imagePath,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  )
                : Image.asset(
                    'assets/images/collage.jpg',
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            toPlay: mediaType == 'tv'
                                ? '$mediaType/$contentId/${lastSeasonWatched ?? 1}/${lastEpisodeWatched ?? 1}'
                                : '$mediaType/$contentId',
                            mediaType: mediaType,
                            startAt: startAt,
                          ),
                        ),
                      );
                      if (onReturn != null) onReturn!();
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 30),
                    label: Text(
                      mediaType == 'tv'
                          ? (lastSeasonWatched != null
                                ? 'Continue S$lastSeasonWatched E$lastEpisodeWatched'
                                : 'Play S01E01')
                          : (startAt != null ? 'Continue' : 'Play'),
                      style: TextStyle(
                        fontSize: mediaType == 'tv' && lastSeasonWatched != null
                            ? 14
                            : 18,
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
