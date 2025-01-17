import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String username;
  final String caption;
  final String songName;
  final String videoUrl;
  final String profilePhoto;
  final String thumbnail; // Required field
  final String uid;       // Required field
  final List<String> likes;
  final int commentCount;
  final int shareCount;

  Video({
    required this.id,
    required this.username,
    required this.caption,
    required this.songName,
    required this.videoUrl,
    required this.profilePhoto,
    required this.thumbnail, // Ensure it's provided
    required this.uid,       // Ensure it's provided
    required this.likes,
    required this.commentCount,
    required this.shareCount,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "profilePhoto": profilePhoto,
        "id": id,
        "likes": likes,
        "commentCount": commentCount,
        "shareCount": shareCount,
        "songName": songName,
        "caption": caption,
        "videoUrl": videoUrl,
        "thumbnail": thumbnail,
      };

  static Video fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Video(
      username: snapshot['username'],
      uid: snapshot['uid'],
      id: snapshot['id'],
      likes: snapshot['likes'],
      commentCount: snapshot['commentCount'],
      shareCount: snapshot['shareCount'],
      songName: snapshot['songName'],
      caption: snapshot['caption'],
      videoUrl: snapshot['videoUrl'],
      profilePhoto: snapshot['profilePhoto'],
      thumbnail: snapshot['thumbnail'],
    );
  }
}
