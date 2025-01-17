import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/comment.dart';

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);

  List<Comment> get comments => _comments.value;

  String _postId = "";

  updatePostId(String id) {
    _postId = id;
    getComment();
  }

  getComment() async {
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


  postComment(String commentText) async {
    try {
      if (commentText.isNotEmpty) {
        if (authController.user != null) { // Null check
          DocumentSnapshot userDoc = await firestore
              .collection('users')
              .doc(authController.user!.uid) // Safe null handling
              .get();

          var allDocs = await firestore
              .collection('videos')
              .doc(_postId)
              .collection('comments')
              .get();
          int len = allDocs.docs.length;

          Comment comment = Comment(
            username: (userDoc.data()! as dynamic)['name'],
            comment: commentText.trim(),
            datePublished: DateTime.now(),
            likes: [],
            profilePhoto: (userDoc.data()! as dynamic)['profilePhoto'],
            uid: authController.user!.uid,
            id: 'Comment $len',
          );

          await firestore
              .collection('videos')
              .doc(_postId)
              .collection('comments')
              .doc('Comment $len')
              .set(
            comment.toJson(),
          );

          DocumentSnapshot doc =
          await firestore.collection('videos').doc(_postId).get();
          await firestore.collection('videos').doc(_postId).update({
            'commentCount': (doc.data()! as dynamic)['commentCount'] + 1,
          });
        } else {
          Get.snackbar('Error', 'User is not logged in');
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error While Commenting',
        e.toString(),
      );
    }
  }

  likeComment(String id) async {
    if (authController.user != null) { // Null check
      var uid = authController.user!.uid;

      DocumentSnapshot doc = await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id)
          .get();

      if ((doc.data()! as dynamic)['likes'].contains(uid)) {
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc(id)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc(id)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } else {
      Get.snackbar('Error', 'User is not logged in');
    }
  }
}