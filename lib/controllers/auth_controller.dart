import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Current Firebase Auth user
  User get user => _user.value!; // Watch out for null safety

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _pickedImage = Rx<File?>(null);

    // Listen to auth state changes
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  // Navigate based on user being logged in or not
  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  // Optional: pick profile image from gallery
  void pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _pickedImage.value = File(pickedImage.path);
      Get.snackbar('Profile Picture', 'You have selected a profile picture.');
    }
  }

  // Register user and create user doc in Firestore
  Future<void> registerUser(
      String username,
      String email,
      String password,
      File? image,
      ) async {
    try {
      if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        // 1) Create user in Firebase Auth
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 2) (Optional) Upload image to storage (omitted here). For now:
        const placeholderPhotoUrl = '';

        // 3) Create user model
        model.User userModel = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: placeholderPhotoUrl,
        );

        // 4) Write to Firestore: users/{uid}
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(userModel.toJson());

        // Done. Once user is created, _user stream triggers navigation to HomeScreen.
      } else {
        Get.snackbar(
          'Error Creating Account',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar('Error Creating Account', e.toString());
    }
  }

  // Login with existing account
  Future<void> loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        Get.snackbar('Error Logging in', 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar('Error Logging in', e.toString());
    }
  }

  // Logout
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
