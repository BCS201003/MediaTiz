import 'package:get/get.dart';
import 'package:tiktok_tutorial/models/video.dart';

class VideoController extends GetxController {
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);

  List<Video> get videoList => _videoList.value;

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  /// Load videos from local assets
  void loadVideos() {
    _videoList.value = [
      Video(
        id: '1',
        username: 'User1',
        caption: 'This is the first video.',
        songName: 'Song1',
        videoUrl: 'assets/videos/video1.mp4',
        profilePhoto: 'https://via.placeholder.com/150',
        thumbnail: 'https://via.placeholder.com/150', // Replace with actual thumbnail
        uid: 'user1Uid', // Replace with actual UID logic
        likes: [],
        commentCount: 10,
        shareCount: 5,
      ),
      Video(
        id: '2',
        username: 'User2',
        caption: 'Check out this amazing clip!',
        songName: 'Song2',
        videoUrl: 'assets/videos/video2.mp4',
        profilePhoto: 'https://via.placeholder.com/150',
        thumbnail: 'https://via.placeholder.com/150', // Replace with actual thumbnail
        uid: 'user2Uid', // Replace with actual UID logic
        likes: [],
        commentCount: 20,
        shareCount: 15,
      ),
      Video(
        id: '3',
        username: 'User2',
        caption: 'Check out this amazing clip!',
        songName: 'Song2',
        videoUrl: 'assets/videos/video3.mp4',
        profilePhoto: 'https://via.placeholder.com/150',
        thumbnail: 'https://via.placeholder.com/150', // Replace with actual thumbnail
        uid: 'user2Uid', // Replace with actual UID logic
        likes: [],
        commentCount: 20,
        shareCount: 15,
      ),
      Video(
        id: '4',
        username: 'User2',
        caption: 'Check out this amazing clip!',
        songName: 'Song2',
        videoUrl: 'assets/videos/video4.mp4',
        profilePhoto: 'https://via.placeholder.com/150',
        thumbnail: 'https://via.placeholder.com/150', // Replace with actual thumbnail
        uid: 'user2Uid', // Replace with actual UID logic
        likes: [],
        commentCount: 20,
        shareCount: 15,
      ),
      Video(
        id: '5',
        username: 'User2',
        caption: 'Check out this amazing clip!',
        songName: 'Song2',
        videoUrl: 'assets/videos/video5.mp4',
        profilePhoto: 'https://via.placeholder.com/150',
        thumbnail: 'https://via.placeholder.com/150', // Replace with actual thumbnail
        uid: 'user2Uid', // Replace with actual UID logic
        likes: [],
        commentCount: 20,
        shareCount: 15,
      ),
      // Add more videos as needed
    ];
  }

  /// Like or unlike a video
  void likeVideo(String id) {
    // Find the video in the list by its ID
    int index = _videoList.value.indexWhere((video) => video.id == id);

    if (index != -1) {
      Video video = _videoList.value[index];
      var uid = 'currentUserUid'; // Replace with actual user ID logic

      if (video.likes.contains(uid)) {
        // If the user has already liked the video, remove their like
        video.likes.remove(uid);
      } else {
        // If the user hasn't liked the video, add their like
        video.likes.add(uid);
      }

      // Update the list to reflect the changes
      _videoList.value[index] = video;
      _videoList.refresh(); // Trigger UI update
    }
  }
}
