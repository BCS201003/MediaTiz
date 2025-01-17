import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';  // Make sure this has your 'firestore' and 'authController'
import 'package:tiktok_tutorial/models/comment.dart';

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);

  List<Comment> get comments => _comments.value;

  String _postId = "";

  void updatePostId(String id) {
    _postId = id;
    getComment();
  }

  void getComment() async {
    if (_postId.isNotEmpty) {
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
    } else {
      Get.snackbar('Error', 'Invalid Post ID');
    }
  }

  Future<void> postComment(String commentText) async {
    try {
      // 1) Check if comment is empty
      if (commentText.isEmpty) {
        Get.snackbar('Error', 'Comment is empty');
        return;
      }
      // 2) Check if user is logged in
      if (authController.user == null) {
        Get.snackbar('Error', 'User is not logged in');
        return;
      }

      // 3) Fetch user document
      final userDoc = await firestore
          .collection('users')
          .doc(authController.user!.uid)
          .get();

      // If userDoc does not exist or has no data, show error
      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar('Error', 'User document not found');
        return;
      }

      // Safely get user data
      final userData = userDoc.data() as Map<String, dynamic>;

      // 4) Get comment count (length of docs)
      final allCommentsSnapshot = await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .get();
      final int len = allCommentsSnapshot.docs.length;

      // 5) Create the new Comment object
      final comment = Comment(
        username: userData['name'] ?? 'Unknown',
        comment: commentText.trim(),
        // Store as a Timestamp so .toDate() works in the UI
        datePublished: Timestamp.now(),
        likes: [],
        profilePhoto: userData['profilePhoto'] ?? '',
        uid: authController.user!.uid,
        id: 'Comment $len',
      );

      // 6) Write to Firestore
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc('Comment $len')
          .set(comment.toJson());

      // 7) Update commentCount in the main video document
      final videoDoc = await firestore.collection('videos').doc(_postId).get();

      if (videoDoc.exists && videoDoc.data() != null) {
        final videoData = videoDoc.data() as Map<String, dynamic>;
        final currentCount = videoData['commentCount'] ?? 0;
        await firestore.collection('videos').doc(_postId).update({
          'commentCount': currentCount + 1,
        });
      }

    } catch (e) {
      Get.snackbar(
        'Error While Commenting',
        e.toString(),
      );
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      // 1) Check if user is logged in
      if (authController.user == null) {
        Get.snackbar('Error', 'User is not logged in');
        return;
      }

      final uid = authController.user!.uid;

      // 2) Get the comment document
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

      // 3) If user already liked, remove; otherwise add
      if (likesList.contains(uid)) {
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
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
