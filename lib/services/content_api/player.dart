import 'package:cinemanic/utils/constants.dart';

Future<String> fetchVideoPlayer(String id) async {
  String apiUrl = serverUrl ?? 'http:localhost:3000';

  return "$apiUrl/$id";
}
