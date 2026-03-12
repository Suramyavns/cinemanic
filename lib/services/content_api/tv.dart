import 'package:cinemanic/models/shows.dart';
import 'package:cinemanic/services/auth_service.dart';
import 'package:cinemanic/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Required for JSON encoding/decoding

Future<TopRatedTvResponse> fetchTopShows() async {
  final token = await AuthService().currentUser!.getIdToken();

  String apiUrl = serverUrl ?? 'http:localhost:3000';

  final response = await http.get(
    Uri.parse('$apiUrl/api/tv/top_rated'),
    headers: {"Authorization": "Bearer $token"},
  );

  return TopRatedTvResponse.fromJson(jsonDecode(response.body));
}

Future<TvShowDetail> fetchTvShowById(int id) async {
  final token = await AuthService().currentUser!.getIdToken();

  String apiUrl = serverUrl ?? 'http:localhost:3000';

  final response = await http.get(
    Uri.parse('$apiUrl/api/tv/$id'),
    headers: {"Authorization": "Bearer $token"},
  );

  return TvShowDetail.fromJson(jsonDecode(response.body));
}
