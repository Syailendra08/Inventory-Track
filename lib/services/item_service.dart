import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemService {
  //mengambil token dari shared_preference dan membuat headers otomatis
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application'};
  }

  //GET ALL ITEMS
  Future<List<ItemModel>> getItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];
        return dataList.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        throw Exception("Gagal memuat data barang : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan $e");
    }
  }
  // Future<List<ItemModel>> postItem(String namaBarang, stockBarang, gambarBarang) async {
  //   final url = Uri.parse('${ApiConfig.baseUrl}/items');
  //   final headers = await _getHeaders();
  //   try {
  //     final response = await http.post( //jadi hanya berupa string, tidak menerima file
  //       url,
  //       headers: headers,
  //       body: {
  //         "name" : namaBarang,
  //         "stock" : stockBarang,
  //         "image" : gambarBarang
  //       });
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       final List<dynamic> dataList = responseData['data'] ?? [];
  //       return dataList.map((json) => ItemModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception("Gagal menyimpan data barng : ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     throw Exception("Terjadi kesalahan $e");
  //   }
  // }

  Future<void> postItem(
    String namaBarang,
    String stockBarang,
    File? gambarBarang,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
  
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = namaBarang;
      request.fields['stock'] = stockBarang;

      if (gambarBarang != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', gambarBarang.path),
        );
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception("Gagal menyimpan data barang : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan $e");
    }
  }

  Future<ItemModel> createItem({
    required String name,
    required String stock,
    required File imageFile,

  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/items");
    var request = http.MultipartRequest("POST", url);

    //ambil token dari shared preference
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

        request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = name;
        request.fields['stock'] = stock;
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        try {
          var streamedResponse = await request.send();
          var response = await http.Response.fromStream(streamedResponse);
          if (response.statusCode == 200 || response.statusCode == 201) {
            final Map<String, dynamic> 
            responseData = jsonDecode(response.body);
            return ItemModel.fromJson(responseData['data']);
          } else {
            throw Exception(
            "Gagal menyimpan data barang : ${response.statusCode}");
          }
        }catch (e) {
          throw Exception("terjadi kesalahan $e");
        }
  }

  //Update Item
  Future<ItemModel> updateItem({
    required int id,
    required String name,
    required String stock,
     File? newImageFile,

  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/items/$id");
    var request = http.MultipartRequest("PUT", url);

    //ambil token dari shared preference
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

        request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = name;
        request.fields['stock'] = stock;
        if (newImageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath('image', newImageFile.path));
          
        }

        try {
          var streamedResponse = await request.send();
          var response = await http.Response.fromStream(streamedResponse);
          if (response.statusCode == 200 || response.statusCode == 201) {
            final Map<String, dynamic> 
            responseData = jsonDecode(response.body);
            return ItemModel.fromJson(responseData['data']);
          } else {
            throw Exception(
            "Gagal mengubah data barang : ${response.statusCode}");
          }
        }catch (e) {
          throw Exception("terjadi kesalahan $e");
        }
  }
}