import 'package:cal_nutri_pal/core/services/interfaces/storage_service_interface.dart';
import 'package:uuid/uuid.dart';

/// A mock implementation of StorageServiceInterface for development and testing
class MockStorageService implements StorageServiceInterface {
  // In-memory storage to simulate cloud storage
  final Map<String, List<int>> _storedFiles = {};
  final Map<String, String> _mimeTypes = {};

  @override
  Future<String> uploadFile(
      String userId, String localFilePath, String remotePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real implementation, we would read the file from disk
    // For mock, we'll just store the path and generate a fake download URL
    final fullPath = _getFullPath(userId, remotePath);

    // Simulate file content with random bytes
    final fakeContent = List<int>.generate(1024, (i) => i % 256);
    _storedFiles[fullPath] = fakeContent;

    // Return a mock download URL
    return _generateDownloadUrl(fullPath);
  }

  @override
  Future<String> uploadFileFromBytes(String userId, List<int> bytes,
      String remotePath, String mimeType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    final fullPath = _getFullPath(userId, remotePath);
    _storedFiles[fullPath] = bytes;
    _mimeTypes[fullPath] = mimeType;

    return _generateDownloadUrl(fullPath);
  }

  @override
  Future<void> deleteFile(String remotePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _storedFiles.remove(remotePath);
    _mimeTypes.remove(remotePath);
  }

  @override
  Future<String> getDownloadURL(String remotePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_storedFiles.containsKey(remotePath)) {
      throw Exception('File not found: $remotePath');
    }

    return _generateDownloadUrl(remotePath);
  }

  @override
  Future<List<String>> listFiles(String directory) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    return _storedFiles.keys
        .where((path) => path.startsWith(directory))
        .toList();
  }

  // Helper methods

  String _getFullPath(String userId, String remotePath) {
    if (remotePath.startsWith('/')) {
      remotePath = remotePath.substring(1);
    }
    return 'users/$userId/$remotePath';
  }

  String _generateDownloadUrl(String fullPath) {
    // Generate a mock download URL
    return 'https://mockfirestorage.example.com/v0/b/app-mock.appspot.com/o/$fullPath?alt=media&token=${const Uuid().v4()}';
  }
}
