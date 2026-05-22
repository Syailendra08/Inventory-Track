import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/loan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoanService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application'};
  }

  Future<Map<String, dynamic>?> fetchLoan({int page = 1, int limit = 5}) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/loans?page=$page&limit=$limit");

    try {
      final customHeaders = await _getHeaders();
      final response = await http.get(url, headers: customHeaders);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final paginationData = decoded['data'];
        List<dynamic> rawData = paginationData['data'];

        List<LoanModel> loans = rawData
            .map((e) => LoanModel.fromJson(e))
            .toList();

        return {
          'loans': loans,
          'totalPage': paginationData['totalPage'],
          'totalData': paginationData['total'],
        };
      } else {
        print("Gagal fetch data loan: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Failed to fetch $e");
      return null;
    }
  }
}
