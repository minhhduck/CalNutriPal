import 'package:cal_nutri_pal/core/services/interfaces/storage_service_interface.dart';

/// Repository for storage operations that abstracts the storage service
class StorageRepository {
  /// The storage service implementation
  final StorageServiceInterface _storageService;

  /// Current user ID
  final String _currentUserId;

  /// Creates a new storage repository
  StorageRepository(this._storageService, this._currentUserId);

  /// Uploads a profile image and returns the download URL
  Future<String> uploadProfileImage(String localFilePath) {
    final remotePath = 'users/$_currentUserId/profile.jpg';
    return _storageService.uploadFile(
        _currentUserId, localFilePath, remotePath);
  }

  /// Uploads a food image and returns the download URL
  Future<String> uploadFoodImage(String localFilePath, String foodItemId) {
    final remotePath = 'users/$_currentUserId/foods/$foodItemId.jpg';
    return _storageService.uploadFile(
        _currentUserId, localFilePath, remotePath);
  }

  /// Uploads an image from memory and returns the download URL
  Future<String> uploadImageFromBytes(List<int> bytes, String fileName,
      {bool isProfileImage = false}) {
    final String mimeType = 'image/jpeg';
    String remotePath;

    if (isProfileImage) {
      remotePath = 'users/$_currentUserId/profile.jpg';
    } else {
      remotePath = 'users/$_currentUserId/images/$fileName';
    }

    return _storageService.uploadFileFromBytes(
        _currentUserId, bytes, remotePath, mimeType);
  }

  /// Deletes a file from storage
  Future<void> deleteFile(String remotePath) =>
      _storageService.deleteFile(remotePath);

  /// Gets a download URL for a file
  Future<String> getDownloadURL(String remotePath) =>
      _storageService.getDownloadURL(remotePath);

  /// Lists food images for the current user
  Future<List<String>> listUserFoodImages() {
    final directory = 'users/$_currentUserId/foods';
    return _storageService.listFiles(directory);
  }

  /// Builds a remote path for a food item image
  String getFoodImagePath(String foodItemId) =>
      'users/$_currentUserId/foods/$foodItemId.jpg';
}
