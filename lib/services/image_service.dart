import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //Pick profile picture, showing options: camera or gallery.
  //Returns cropped square image ready for upload.
  Future<File?> pickProfilePicture(BuildContext context) async {
    //Show bottom sheet with options
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImageSourceSheet(context),
    );

    if (source == null) return null;

    //pick image
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return null;

    //Crop to square
    return await _cropImageSquare(File(image.path));
  }

  //Pick post images that allows multiple images for posts.
  Future<List<File>> pickPostImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );

    //Limit to 4 images
    return images.take(4).map((xFile) => File(xFile.path)).toList();
  }

  //Crop image to square
  Future<File?> _cropImageSquare(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.blue,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  //Upload profile picture
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('profile_pictures/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );

      final uploadTask = ref.putFile(imageFile, metadata);

      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
      });

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      rethrow;
    }
  }

  //Upload post images
  Future<List<String>> uploadPostImages(List<File> imageFiles, String postId) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final fileName = 'post_${postId}_image_$i.jpg';
        final storageRef = _storage.ref();
        final imageRef = storageRef.child('post_images/$fileName');

        debugPrint('Uploading: $fileName');
        debugPrint('File size: ${await imageFiles[i].length()} bytes');

        final uploadTask = imageRef.putFile(imageFiles[i]);
        final snapshot = await uploadTask;
        debugPrint('Upload complete: ${snapshot.state}');

        final url = await imageRef.getDownloadURL();
        debugPrint('Got URL: $url');

        downloadUrls.add(url);
      } catch (e) {
        debugPrint('Error uploading image $i: $e');
      }
    }

    return downloadUrls;
  }

  //Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  //Build image source bottom sheet
  Widget _buildImageSourceSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Choose Photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.blue),
            ),
            title: const Text('Camera'),
            subtitle: const Text('Take a new photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_library, color: Colors.green),
            ),
            title: const Text('Gallery'),
            subtitle: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

//Cached image widget — displays images with loading and error states.
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
      placeholder ?? _buildLoadingPlaceholder(context),
      errorWidget: (context, url, error) => _buildPlaceholder(context),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: width != null ? width! * 0.5 : 40,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

class ImageCompressionService {


  // Compress single image
  Future<File?> compressImage(
      File file, {
        int quality = 70,
        int maxWidth = 1920,
        int maxHeight = 1920,
      }) async {
    try {
      debugPrint('Compressing image: ${file.path}');
      debugPrint('Original size: ${await file.length()} bytes');

      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(file.path);
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        debugPrint('Compression failed');
        return file;
      }

      final compressedSize = await File(compressedFile.path).length();
      final savedBytes = (await file.length()) - compressedSize;
      final savedPercentage =
      ((savedBytes / await file.length()) * 100).toStringAsFixed(1);

      debugPrint('Compressed size: $compressedSize bytes');
      debugPrint('Saved: $savedBytes bytes ($savedPercentage%)');

      return File(compressedFile.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file;
    }
  }

  //Compress multiple images — useful for posts with multiple images.
  Future<List<File>> compressImages(
      List<File> files, {
        int quality = 70,
        int maxWidth = 1920,
        int maxHeight = 1920,
      }) async {
    debugPrint('Compressing ${files.length} images...');

    final List<File> compressedFiles = [];

    for (final file in files) {
      final compressed = await compressImage(
        file,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }

    debugPrint('Compressed ${compressedFiles.length} images');
    return compressedFiles;
  }

  //Compress profile picture that uses smaller dimensions since profile pics display smaller.
  Future<File?> compressProfilePicture(File file) async {
    return compressImage(
      file,
      quality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
  }

  // Compress story image that stories are full-screen so higher quality is used.
  Future<File?> compressStoryImage(File file) async {
    return compressImage(
      file,
      quality: 85,
      maxWidth: 1080,
      maxHeight: 1920,
    );
  }

  // Get image info without loading the full image.
  Future<Map<String, dynamic>> getImageInfo(File file) async {
    try {
      final bytes = await file.length();

      return {
        'size': bytes,
        'sizeKB': (bytes / 1024).toStringAsFixed(2),
        'sizeMB': (bytes / (1024 * 1024)).toStringAsFixed(2),
        'path': file.path,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}