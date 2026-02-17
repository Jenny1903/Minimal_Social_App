import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //pick profile picture , showing options: camera or gallery
  //returns cropped square image ready for upload
  Future<File?> pickProfilePicture(BuildContext context) async {
    //show bottom sheet with options
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

    //crop to square
    return await _cropImageSquare(File(image.path));
  }

  //pick post image
  //allows multiple images for posts
  Future<List<File>> pickPostImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );

    //limit to 4 images
    return images.take(4).map((xFile) => File(xFile.path)).toList();
  }

  //crop image to square
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

  //upload profile picture
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      //create unique file name
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('profile_pictures/$fileName');

      //upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );

      final uploadTask = ref.putFile(imageFile, metadata);

      //show progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
      });

      //wait for completion
      await uploadTask;

      //get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }

  //upload post images
  Future<List<String>> uploadPostImages(List<File> imageFiles, String postId) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final fileName = 'post_${postId}_image_$i.jpg';

        // Create storage reference
        final storageRef = _storage.ref();
        final imageRef = storageRef.child('post_images/$fileName');

        print('Uploading: $fileName');
        print('Path: post_images/$fileName');
        print('File size: ${await imageFiles[i].length()} bytes');

        // Upload file
        final uploadTask = imageRef.putFile(imageFiles[i]);

        // Wait for upload
        final snapshot = await uploadTask;
        print('Upload complete: ${snapshot.state}');

        // Get download URL
        final url = await imageRef.getDownloadURL();
        print('Got URL: $url');

        downloadUrls.add(url);
      } catch (e) {
        print('Error uploading image $i: $e');
        print('Stack trace: ${StackTrace.current}');
        // Continue with other images even if one fails
      }
    }

    return downloadUrls;
  }


  //delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  //build image source sheet
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

          //title
          Text(
            'Choose Photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          const SizedBox(height: 20),

          //camera option
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.blue),
            ),
            title: const Text('Camera'),
            subtitle: const Text('Take a new photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),

          //gallery option
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
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


//catched image widget
//displays images with loading and error states
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
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: width != null ? width! * 0.5 : 40,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}