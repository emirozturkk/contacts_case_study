import 'dart:convert';
import 'package:contacts/repositories/database/abstract/database_interface_abstract.dart';
import 'package:contacts/app_common/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class NexoftDatabase implements DatabaseInterface {
  @override
  Future<String?> addUser({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String profileImageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(userUrl),
        headers: {
          'accept': 'text/json',
          'Content-Type': 'application/json',
          'ApiKey': apiKey,
        },
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'profileImageUrl': profileImageUrl,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Add user failed with status: ${response.statusCode}');
      }

      final responseBody = json.decode(response.body);
      return responseBody['data']['id'] as String;
    } catch (e) {
      throw Exception('Add user failed: $e');
    }
  }

  @override
  Future<void> updateUser({
    required String userID,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String profileImageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$userUrl/$userID'),
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
          'ApiKey': apiKey,
        },
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'profileImageUrl': profileImageUrl,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Update failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(allUsersUrl),
        headers: {'accept': 'text/json', 'ApiKey': apiKey},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Get all users failed with status: ${response.statusCode}',
        );
      }
      final responseBody = json.decode(response.body);
      final usersList = (responseBody['data']["users"] as List)
          .map((user) => user as Map<String, dynamic>)
          .toList();
      return usersList;
    } catch (e) {
      throw Exception('Get all users failed: $e');
    }
  }

  @override
  Future<void> deleteUser({required String userID}) async {
    try {
      final response = await http.delete(
        Uri.parse('$userUrl/$userID'),
        headers: {'accept': 'text/json', 'ApiKey': apiKey},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Delete failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }

  @override
  Future<String?> uploadImage({required XFile imageFile}) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final request = http.MultipartRequest('POST', Uri.parse(imageUrl));

      // Add headers
      request.headers['accept'] = 'text/plain';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['ApiKey'] = apiKey;

      // Add multipart file
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: _getContentType(imageFile.path),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Check if the response has the expected structure
        if (responseBody is Map<String, dynamic> &&
            responseBody['success'] == true &&
            responseBody['data'] is Map<String, dynamic> &&
            responseBody['data']['imageUrl'] != null) {
          return responseBody['data']['imageUrl'] as String;
        } else {
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Helper method to determine content type based on file extension
  MediaType _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Default fallback
    }
  }
}
