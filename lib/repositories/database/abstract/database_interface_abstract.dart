import 'package:image_picker/image_picker.dart';

abstract class DatabaseInterface {
  Future<String?> addUser({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String profileImageUrl,
  });
  Future<void> updateUser({
    required String userID,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String profileImageUrl,
  });
  Future<List<Map<String, dynamic>>> getAllUsers();

  Future<String?> uploadImage({required XFile imageFile});

  Future<void> deleteUser({required String userID});
}
