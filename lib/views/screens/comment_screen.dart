import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentScreen extends StatefulWidget {
  final String id;
  const CommentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CommentController commentController = Get.put(CommentController());

  @override
  void initState() {
    super.initState();
    commentController.updatePostId(widget.id); // Update post ID on initialization
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: Obx(() {
              if (commentController.comments.isEmpty) {
                return const Center(
                  child: Text(
                    'No comments yet',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                itemCount: commentController.comments.length,
                itemBuilder: (context, index) {
                  final comment = commentController.comments[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: comment.profilePhoto != null
                          ? NetworkImage(comment.profilePhoto!)
                          : null,
                      child: comment.profilePhoto == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          "${comment.username ?? 'Unknown User'}  ",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            comment.comment ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          comment.datePublished != null
                              ? tago.format(comment.datePublished!.toDate())
                              : 'Unknown time',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${comment.likes?.length ?? 0} likes',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () =>
                          commentController.likeComment(comment.id ?? ''),
                      child: Icon(
                        Icons.favorite,
                        size: 25,
                        color: comment.likes != null &&
                            comment.likes!.contains(
                                authController.user?.uid ?? '')
                            ? Colors.red
                            : Colors.white,
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Divider
          const Divider(color: Colors.white, height: 1),

          // Comment Input Field
          ListTile(
            title: TextFormField(
              controller: _commentController,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Comment',
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            trailing: TextButton(
              onPressed: () {
                if (_commentController.text.trim().isNotEmpty) {
                  commentController.postComment(_commentController.text.trim());
                  _commentController.clear(); // Clear input field after posting
                } else {
                  Get.snackbar(
                    'Error',
                    'Comment cannot be empty',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                'Send',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
