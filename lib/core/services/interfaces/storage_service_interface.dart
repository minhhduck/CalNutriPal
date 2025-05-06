/// Interface for storage services like Firebase Storage
abstract class StorageServiceInterface {
  /// Uploads a file from a local path and returns the download URL
  Future<String> uploadFile(
      String userId, String localFilePath, String remotePath);

  /// Uploads a file from bytes and returns the download URL
  Future<String> uploadFileFromBytes(
      String userId, List<int> bytes, String remotePath, String mimeType);

  /// Deletes a file from storage
  Future<void> deleteFile(String remotePath);

  /// Gets the download URL for a file
  Future<String> getDownloadURL(String remotePath);

  /// Lists files in a directory
  Future<List<String>> listFiles(String directory);
}
