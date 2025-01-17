import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/video.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  /// (Optional) Keep this method if you still want to compress the video locally.
  Future<File?> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo?.file;
  }

  /// (Optional) Keep this method if you still want to generate a thumbnail locally.
  Future<File?> _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  /// Updated method without Firebase Storage
  Future<void> uploadVideo(
      String songName,
      String caption,
      String videoPath,
      ) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

      // Generate an ID for the new video
      var allDocs = await firestore.collection('videos').get();
      int len = allDocs.docs.length;

      // (Optional) Compress video and generate thumbnail locally if you want
      // await _compressVideo(videoPath);
      // await _getThumbnail(videoPath);

      // For now, skip uploading to Firebase and use placeholders
      String videoUrl = '';    // was: await _uploadVideoToStorage(...)
      String thumbnail = '';   // was: await _uploadImageToStorage(...)

      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: "Video $len",
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl, // placeholder
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
        thumbnail: thumbnail,  // placeholder
      );

      // Only store the metadata in Firestore
      await firestore.collection('videos').doc('Video $len').set(video.toJson());

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error Uploading Video',
        e.toString(),
      );
    }
  }
}
