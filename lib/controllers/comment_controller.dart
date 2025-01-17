import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/comment.dart';

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);
  List<Comment> get comments => _comments.value;

  String _postId = '';

  void updatePostId(String postId) {
    _postId = postId;
    getComments();
  }

  void getComments() {
    if (_postId.isEmpty) {
      Get.snackbar('Error', 'Invalid Post ID');
      return;
    }
    _comments.bindStream(
      firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .snapshots()
          .map((QuerySnapshot query) {
        List<Comment> retValue = [];
        for (var element in query.docs) {
          retValue.add(Comment.fromSnap(element));
        }
        return retValue;
      }),
    );
  }

  Future<void> postComment(String commentText) async {
    try {
      if (commentText.isEmpty) {
        Get.snackbar('Error', 'Comment is empty');
        return;
      }
      if (authController.user == null) {
        Get.snackbar('Error', 'User is not logged in');
        return;
      }

      final uid = authController.user.uid;
      final userDoc = await firestore.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar('Error', 'User document not found');
        return;
      }
      final userData = userDoc.data() as Map<String, dynamic>;

      // Count existing comments
      final allComments = await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .get();
      final commentCount = allComments.docs.length;

      // Create comment model
      final comment = Comment(
        username: userData['name'] ?? 'Unknown',
        comment: commentText.trim(),
        datePublished: Timestamp.now(),
        likes: [],
        profilePhoto: userData['profilePhoto'] ?? '',
        uid: uid,
        id: 'Comment $commentCount',
      );

      // Write comment
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(comment.id)
          .set(comment.toJson());

      // Update commentCount in video doc
      final videoDoc = await firestore.collection('videos').doc(_postId).get();
      if (videoDoc.exists && videoDoc.data() != null) {
        final videoData = videoDoc.data() as Map<String, dynamic>;
        final currentCount = videoData['commentCount'] ?? 0;
        await firestore
            .collection('videos')
            .doc(_postId)
            .update({'commentCount': currentCount + 1});
      }
    } catch (e) {
      Get.snackbar('Error While Commenting', e.toString());
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      if (authController.user == null) {
        Get.snackbar('Error', 'User is not logged in');
        return;
      }
      final uid = authController.user.uid;

      final doc = await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(commentId)
          .get();
      if (!doc.exists || doc.data() == null) {
        Get.snackbar('Error', 'Comment not found');
        return;
      }

      final docData = doc.data() as Map<String, dynamic>;
      final likesList = List<String>.from(docData['likes'] ?? []);

      if (likesList.contains(uid)) {
        // Unlike
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        // Like
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
