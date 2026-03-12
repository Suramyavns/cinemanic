import 'package:cinemanic/models/movies.dart';
import 'package:cinemanic/services/auth_service.dart';
import 'package:cinemanic/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Required for JSON encoding/decoding

Future<PopularMoviesResponse> fetchPopularMovies() async {
  final token = await AuthService().currentUser!.getIdToken();

  String apiUrl = serverUrl ?? 'http:localhost:3000';

  final response = await http.get(
    Uri.parse('$apiUrl/api/movie/top_rated'),
    headers: {"Authorization": "Bearer $token"},
  );

  return PopularMoviesResponse.fromJson(jsonDecode(response.body));
}

Future<MovieDetail> fetchMovieById(int id) async {
  final token = await AuthService().currentUser!.getIdToken();

  String apiUrl = serverUrl ?? 'http:localhost:3000';

  final response = await http.get(
    Uri.parse('$apiUrl/api/movie/$id'),
    headers: {"Authorization": "Bearer $token"},
  );

  return MovieDetail.fromJson(jsonDecode(response.body));
}
