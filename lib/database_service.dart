// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:minio/io.dart';
// import 'package:minio/minio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:io';
//
// class DatabaseService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // Cloudflare R2 Configuration using minio
//   final minio = Minio(
//     endPoint: dotenv.env['R2_ENDPOINT'] ?? '',
//     accessKey: dotenv.env['R2_ACCESS_KEY'] ?? '',
//     secretKey: dotenv.env['R2_SECRET_KEY'] ?? '',
//     useSSL: true,
//   );
//
//   // Helper function to extract file name from a URL
//   String extractFileName(String url) {
//     String fileNameWithParams = url.split('/').last;
//     return fileNameWithParams.split('?').first;
//   }
//
//   // Save user profile to Firestore while preserving existing fields
//   Future<void> saveUserProfile({
//     required String username,
//     required String location,
//     required String bio,
//     String? profilePicture,
//   }) async {
//     String? userId = _auth.currentUser?.uid;
//     if (userId == null) return;
//
//     DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
//     Map<String, dynamic> currentData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};
//
//     Map<String, dynamic> updatedData = {
//       'username': username,
//       'location': location,
//       'bio': bio,
//       'profilePicture': profilePicture ?? currentData['profilePicture'] ?? '',
//       'postsCount': currentData['postsCount'] ?? 0,
//       'followersCount': currentData['followersCount'] ?? 0,
//       'followingCount': currentData['followingCount'] ?? 0,
//     };
//
//     await _db.collection('users').doc(userId).set(
//       updatedData,
//       SetOptions(merge: true),
//     );
//   }
//
//   // Fetch user profile from Firestore and refresh pre-signed URL for profile picture
//   Future<Map<String, dynamic>?> getUserProfile(String userId) async {
//     DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
//     if (!doc.exists) return null;
//
//     Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
//
//     if (userData['profilePicture'] != null && userData['profilePicture'].isNotEmpty) {
//       String fileName = extractFileName(userData['profilePicture']);
//       String freshUrl = await getPreSignedUrl(dotenv.env['R2_BUCKET_NAME'] ?? 'chetra', fileName);
//       userData['profilePicture'] = freshUrl;
//     }
//
//     return userData;
//   }
//
//   // Upload media to Cloudflare R2 and return a pre-signed URL
//   Future<String?> uploadMediaToR2(File file, String fileName) async {
//     try {
//       print("Uploading file to R2: $fileName, Path: ${file.path}");
//       await minio.fPutObject(
//         dotenv.env['R2_BUCKET_NAME'] ?? 'chetra',
//         fileName,
//         file.path,
//       );
//       print("File uploaded successfully: $fileName");
//
//       final preSignedUrl = await minio.presignedGetObject(
//         dotenv.env['R2_BUCKET_NAME'] ?? 'chetra',
//         fileName,
//         expires: 3600,
//       );
//       print("Pre-signed URL generated: $preSignedUrl");
//
//       return preSignedUrl;
//     } catch (e) {
//       print("Upload error: $e");
//       return null;
//     }
//   }
//
//   // Method to generate a pre-signed URL for an existing file
//   Future<String> getPreSignedUrl(String bucketName, String fileName) async {
//     try {
//       String preSignedUrl = await minio.presignedGetObject(
//         bucketName,
//         fileName,
//         expires: 3600,
//       );
//       print("Generated pre-signed URL for $fileName: $preSignedUrl");
//       return preSignedUrl;
//     } catch (e) {
//       print("Error generating pre-signed URL for $fileName: $e");
//       rethrow;
//     }
//   }
//
//   // Save a photo to Firestore
//   Future<void> savePhoto({
//     required String userId,
//     required String mediaUrl,
//   }) async {
//     await _db.collection('photos').add({
//       'userId': userId,
//       'mediaUrl': mediaUrl,
//       'type': 'photo',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//
//     await _db.collection('users').doc(userId).update({
//       'postsCount': FieldValue.increment(1),
//     });
//   }
//
//   // Save a video to Firestore
//   Future<void> saveVideo({
//     required String userId,
//     required String mediaUrl,
//   }) async {
//     await _db.collection('videos').add({
//       'userId': userId,
//       'mediaUrl': mediaUrl,
//       'type': 'video',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//
//     await _db.collection('users').doc(userId).update({
//       'postsCount': FieldValue.increment(1),
//     });
//   }
//
//   // Save a story to Firestore
//   Future<void> saveStory({
//     required String userId,
//     required String mediaUrl,
//   }) async {
//     await _db.collection('stories').add({
//       'userId': userId,
//       'mediaUrl': mediaUrl,
//       'type': 'story',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   // Save a post to Firestore with additional fields
//   Future<void> createPost({
//     required String userId,
//     required String mediaUrl,
//     String? content,
//     String? hashtags,
//     int likes = 0,
//     int comments = 0,
//   }) async {
//     await _db.collection('posts').add({
//       'userId': userId,
//       'mediaUrl': mediaUrl,
//       'content': content ?? '',
//       'hashtags': hashtags ?? '',
//       'likes': likes,
//       'comments': comments,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//
//     await _db.collection('users').doc(userId).update({
//       'postsCount': FieldValue.increment(1),
//     });
//   }
//
//   // Fetch user's photos from Firestore
//   Stream<QuerySnapshot> getUserPhotos(String userId) {
//     return _db
//         .collection('photos')
//         .where('userId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
//
//   // Fetch user's videos from Firestore
//   Stream<QuerySnapshot> getUserVideos(String userId) {
//     return _db
//         .collection('videos')
//         .where('userId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
//
//   // Fetch user's posts from Firestore
//   Stream<QuerySnapshot> getUserPosts(String userId) {
//     return _db
//         .collection('posts')
//         .where('userId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
//
//   // Fetch all posts from Firestore
//   Stream<QuerySnapshot> getAllPosts() {
//     return _db
//         .collection('posts')
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
//
//   // Save story highlight to Firestore
//   Future<void> saveStoryHighlight({
//     required String userId,
//     required String label,
//     required String imageUrl,
//   }) async {
//     try {
//       await _db.collection('story_highlights').add({
//         'userId': userId,
//         'label': label,
//         'imageUrl': imageUrl,
//       });
//       print("Story highlight saved: Label=$label, ImageUrl=$imageUrl");
//     } catch (e) {
//       print("Error saving story highlight: $e");
//       rethrow;
//     }
//   }
//
//   // Fetch story highlights for a user and refresh pre-signed URLs
//   Stream<List<Map<String, dynamic>>> getStoryHighlights(String userId) {
//     return _db
//         .collection('story_highlights')
//         .where('userId', isEqualTo: userId)
//         .snapshots()
//         .asyncMap((snapshot) async {
//       List<Map<String, dynamic>> highlights = [];
//       for (var doc in snapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
//           String fileName = extractFileName(data['imageUrl']);
//           String freshUrl = await getPreSignedUrl(dotenv.env['R2_BUCKET_NAME'] ?? 'chetra', fileName);
//           data['imageUrl'] = freshUrl;
//         }
//         highlights.add(data);
//       }
//       return highlights;
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloudflare R2 Configuration using minio (getter)
  Minio get minio {
    final endpoint = dotenv.env['R2_ENDPOINT'];
    final accessKey = dotenv.env['R2_ACCESS_KEY'];
    final secretKey = dotenv.env['R2_SECRET_KEY'];

    if (endpoint == null || accessKey == null || secretKey == null) {
      throw Exception('R2 credentials not found in .env file');
    }

    return Minio(
      endPoint: endpoint,
      accessKey: accessKey,
      secretKey: secretKey,
      useSSL: true,
    );
  }

  // Helper function to extract file name from a URL
  String extractFileName(String url) {
    String fileNameWithParams = url.split('/').last;
    return fileNameWithParams.split('?').first;
  }

  // Save user profile to Firestore while preserving existing fields
  Future<void> saveUserProfile({
    required String username,
    required String location,
    required String bio,
    String? profilePicture,
  }) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
    Map<String, dynamic> currentData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};

    Map<String, dynamic> updatedData = {
      'username': username,
      'location': location,
      'bio': bio,
      'profilePicture': profilePicture ?? currentData['profilePicture'] ?? '',
      'postsCount': currentData['postsCount'] ?? 0,
      'followersCount': currentData['followersCount'] ?? 0,
      'followingCount': currentData['followingCount'] ?? 0,
    };

    await _db.collection('users').doc(userId).set(
      updatedData,
      SetOptions(merge: true),
    );
  }

  // Fetch user profile from Firestore and refresh pre-signed URL for profile picture
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

    if (userData['profilePicture'] != null && userData['profilePicture'].isNotEmpty) {
      String fileName = extractFileName(userData['profilePicture']);
      String freshUrl = await getPreSignedUrl(dotenv.env['R2_BUCKET_NAME'] ?? 'chetra', fileName);
      userData['profilePicture'] = freshUrl;
    }

    return userData;
  }

  // Upload media to Cloudflare R2 and return a pre-signed URL
  Future<String?> uploadMediaToR2(File file, String fileName) async {
    try {
      print("Uploading file to R2: $fileName, Path: ${file.path}");
      await minio.fPutObject(
        dotenv.env['R2_BUCKET_NAME'] ?? 'chetra',
        fileName,
        file.path,
      );
      print("File uploaded successfully: $fileName");

      final preSignedUrl = await minio.presignedGetObject(
        dotenv.env['R2_BUCKET_NAME'] ?? 'chetra',
        fileName,
        expires: 3600,
      );
      print("Pre-signed URL generated: $preSignedUrl");

      return preSignedUrl;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  // Method to generate a pre-signed URL for an existing file
  Future<String> getPreSignedUrl(String bucketName, String fileName) async {
    try {
      String preSignedUrl = await minio.presignedGetObject(
        bucketName,
        fileName,
        expires: 3600,
      );
      print("Generated pre-signed URL for $fileName: $preSignedUrl");
      return preSignedUrl;
    } catch (e) {
      print("Error generating pre-signed URL for $fileName: $e");
      rethrow;
    }
  }

  // Save a photo to Firestore
  Future<void> savePhoto({
    required String userId,
    required String mediaUrl,
  }) async {
    await _db.collection('photos').add({
      'userId': userId,
      'mediaUrl': mediaUrl,
      'type': 'photo',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(1),
    });
  }

  // Save a video to Firestore
  Future<void> saveVideo({
    required String userId,
    required String mediaUrl,
  }) async {
    await _db.collection('videos').add({
      'userId': userId,
      'mediaUrl': mediaUrl,
      'type': 'video',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(1),
    });
  }

  // Save a story to Firestore
  Future<void> saveStory({
    required String userId,
    required String mediaUrl,
  }) async {
    await _db.collection('stories').add({
      'userId': userId,
      'mediaUrl': mediaUrl,
      'type': 'story',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Save a post to Firestore with additional fields
  Future<void> createPost({
    required String userId,
    required String mediaUrl,
    String? content,
    String? hashtags,
    int likes = 0,
    int comments = 0,
  }) async {
    await _db.collection('posts').add({
      'userId': userId,
      'mediaUrl': mediaUrl,
      'content': content ?? '',
      'hashtags': hashtags ?? '',
      'likes': likes,
      'comments': comments,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(1),
    });
  }

  // Fetch user's photos from Firestore
  Stream<QuerySnapshot> getUserPhotos(String userId) {
    return _db
        .collection('photos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Fetch user's videos from Firestore
  Stream<QuerySnapshot> getUserVideos(String userId) {
    return _db
        .collection('videos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Fetch user's posts from Firestore
  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Fetch all posts from Firestore
  Stream<QuerySnapshot> getAllPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Save story highlight to Firestore
  Future<void> saveStoryHighlight({
    required String userId,
    required String label,
    required String imageUrl,
  }) async {
    try {
      await _db.collection('story_highlights').add({
        'userId': userId,
        'label': label,
        'imageUrl': imageUrl,
      });
      print("Story highlight saved: Label=$label, ImageUrl=$imageUrl");
    } catch (e) {
      print("Error saving story highlight: $e");
      rethrow;
    }
  }

  // Fetch story highlights for a user and refresh pre-signed URLs
  Stream<List<Map<String, dynamic>>> getStoryHighlights(String userId) {
    return _db
        .collection('story_highlights')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> highlights = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
          String fileName = extractFileName(data['imageUrl']);
          String freshUrl = await getPreSignedUrl(dotenv.env['R2_BUCKET_NAME'] ?? 'chetra', fileName);
          data['imageUrl'] = freshUrl;
        }
        highlights.add(data);
      }
      return highlights;
    });
  }
}