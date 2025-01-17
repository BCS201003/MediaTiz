import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
// REMOVED: import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/user.dart' as model;
import 'package:tiktok_tutorial/views/screens/auth/login_screen.dart';
import 'package:tiktok_tutorial/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  late Rx<File?> _pickedImage;

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  void pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar(
        'Profile Picture',
        'You have successfully selected your profile picture!',
      );
      _pickedImage = Rx<File?>(File(pickedImage.path));
    }
  }

  // REMOVED: _uploadToStorage(File image) method

  // Registering the user without uploading to Firebase Storage
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // Create user in Firebase Auth
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // If you still want to store a local file path or
        // simply skip storing the image URL, you can do so here.
        // For example, store an empty string for now:
        const downloadUrl = ''; // or your custom logic

        // Create our local user model object
        model.User userModel = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl, // or any placeholder
        );

        // Save user data to Firestore
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(userModel.toJson());
      } else {
        Get.snackbar(
          'Error Creating Account',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Creating Account',
        e.toString(),
      );
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        Get.snackbar(
          'Error Logging in',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Logging in',
        e.toString(),
      );
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }
}
