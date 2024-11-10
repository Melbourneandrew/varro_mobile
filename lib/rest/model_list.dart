import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scream_mobile/storage/token_storage.dart';
import 'package:scream_mobile/storage/platform_storage.dart';

Future<List<String>> listOpenAiModels() async {
  final url = Uri.parse(PlatformStorage.modelListUrl);
  final token = await TokenStorage.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final List<dynamic> models = jsonDecode(response.body)['data'];
    return models.map((model) => model['id'] as String).toList();
  } else {
    throw Exception('Failed to list models: ${response.body}');
  }

}