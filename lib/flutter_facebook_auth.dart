// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// Future<UserCredential?> signInWithFacebook() async {
//   try {
//     // Trigger the Facebook Sign-In flow
//     final LoginResult loginResult = await FacebookAuth.instance.login();

//     // Check if the login was successful
//     if (loginResult.status == LoginStatus.success) {
//       // Access the access token
//       final AccessToken? accessToken = loginResult.accessToken;

//       // Ensure the access token is not null
//       if (accessToken != null) {
//         // Create a credential from the access token
//         final OAuthCredential credential =
//             FacebookAuthProvider.credential(accessToken.token);

//         // Sign in to Firebase with the credential
//         return await FirebaseAuth.instance.signInWithCredential(credential);
//       } else {
//         print("Facebook access token is null");
//         return null;
//       }
//     } else {
//       print("Facebook login failed: ${loginResult.status}");
//       return null;
//     }
//   } catch (e) {
//     print("Error signing in with Facebook: $e");
//     return null;
//   }
// }
