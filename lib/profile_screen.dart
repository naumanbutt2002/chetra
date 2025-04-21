import 'dart:io';
import 'package:chetra/createpostscreen.dart';
import 'package:chetra/database_service.dart';
import 'package:chetra/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
  }

  String extractFileName(String url) {
    String fileNameWithParams = url.split('/').last;
    return fileNameWithParams.split('?').first;
  }

  Stream<Map<String, dynamic>?> _getUserProfileStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return null;

      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

      if (userData['profilePicture'] != null &&
          userData['profilePicture'].isNotEmpty) {
        String fileName = _databaseService.extractFileName(userData['profilePicture']);
        String freshUrl = await _databaseService.getPreSignedUrl('chetra', fileName);
        userData['profilePicture'] = freshUrl;
      }

      return userData;
    });
  }

  Future<File?> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
      return null;
    }
  }

  Future<File?> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return null;
      return File(video.path);
    } catch (e) {
      print("Error picking video: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick video: $e")),
      );
      return null;
    }
  }

  Future<void> _uploadAndSaveMedia({
    required File mediaFile,
    required String type,
  }) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    print("Authenticated User ID: $userId");
    print("Firebase Auth Current User: ${FirebaseAuth.instance.currentUser?.uid}");

    String extension = mediaFile.path.split('.').last;
    String fileName = "${userId}_${type}_${DateTime.now().millisecondsSinceEpoch}.$extension";

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploading...")),
    );

    String? uploadResult = await _databaseService.uploadMediaToR2(mediaFile, fileName);
    if (uploadResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload media to Cloudflare R2")),
      );
      return;
    }

    String? mediaUrl;
    try {
      mediaUrl = await _databaseService.getPreSignedUrl('chetra', fileName);
      if (mediaUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate pre-signed URL")),
        );
        return;
      }
    } catch (e) {
      print("Error generating pre-signed URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate pre-signed URL: $e")),
      );
      return;
    }

    try {
      if (type == "photo") {
        await _databaseService.savePhoto(userId: userId!, mediaUrl: mediaUrl);
      } else if (type == "video") {
        await _databaseService.saveVideo(userId: userId!, mediaUrl: mediaUrl);
      } else if (type == "story") {
        await _databaseService.saveStory(userId: userId!, mediaUrl: mediaUrl);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Media uploaded successfully")),
      );
    } catch (e) {
      print("Error saving to Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save media to Firestore: $e")),
      );
    }
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Share",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildShareOption(
                icon: Icons.landscape,
                label: "Photography",
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await _pickImage();
                  if (image != null) {
                    await _uploadAndSaveMedia(mediaFile: image, type: "photo");
                  }
                },
              ),
              _buildShareOption(
                icon: Icons.videocam,
                label: "Video",
                onTap: () async {
                  Navigator.pop(context);
                  File? video = await _pickVideo();
                  if (video != null) {
                    await _uploadAndSaveMedia(mediaFile: video, type: "video");
                  }
                },
              ),
              _buildShareOption(
                icon: Icons.chat_bubble_outline,
                label: "Post",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                  );
                },
              ),
              _buildShareOption(
                icon: Icons.add_circle_outline,
                label: "Story",
                onTap: () async {
                  Navigator.pop(context);
                  File? media = await _pickImage();
                  if (media != null) {
                    await _uploadAndSaveMedia(mediaFile: media, type: "story");
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          ),
          title: StreamBuilder<Map<String, dynamic>?>(
            stream: _getUserProfileStream(userId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text("Loading..."));
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text("Error"));
              }
              final userData = snapshot.data!;
              return Center(
                child: Text(
                  "@${userData['username']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                _showShareBottomSheet(context);
              },
              icon: const Icon(
                Icons.add_box_outlined,
                size: 28,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              icon: const Icon(
                Icons.settings,
                size: 28,
                color: Colors.black,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _userInfo(userId!, _databaseService),
              const SizedBox(height: 16),
              _storyHighlights(userId!, _databaseService),
              const SizedBox(height: 16),
              const TabBar(
                labelColor: Color(0xff8E8E93),
                unselectedLabelColor: Color(0xff8E8E93),
                tabs: [
                  Tab(icon: Icon(Icons.grid_on_rounded, size: 24)),
                  Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 24)),
                  Tab(icon: Icon(Icons.label_outline_rounded, size: 24)),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                  children: [
                    _combinedMediaContent(userId!, _databaseService),
                    _allPostsContent(_databaseService),
                    const Center(child: Text("Tagged")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfo(String userId, DatabaseService databaseService) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _getUserProfileStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Error loading profile"));
        }

        final userData = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xffC7C7CC), width: 1),
                  image: userData['profilePicture'] != null &&
                      userData['profilePicture'].isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(userData['profilePicture']),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print("Error loading profile picture: $exception");
                    },
                  )
                      : null,
                ),
                child: userData['profilePicture'] == null ||
                    userData['profilePicture'].isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['username'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff262626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData['location'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8E8E93),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${userData['postsCount'] ?? 0}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff262626),
                              ),
                            ),
                            const Text(
                              "gonderi",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff262626),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${userData['followersCount'] ?? 0}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff262626),
                              ),
                            ),
                            const Text(
                              "takipci",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff262626),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${userData['followingCount'] ?? 0}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff262626),
                              ),
                            ),
                            const Text(
                              "takip",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff262626),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userData['bio'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff010101),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "MORE INFO",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _storyHighlights(String userId, DatabaseService databaseService) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: databaseService.getStoryHighlights(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Waiting for story highlights...");
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          print("Error fetching story highlights: ${snapshot.error}");
          return const SizedBox.shrink();
        }

        List<Map<String, dynamic>> stories = [
          {'label': 'New', 'imageUrl': ''},
        ];
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          stories.addAll(snapshot.data!);
        } else {
          print("No story highlights found for user $userId");
        }

        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 16, top: 8),
          child: SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemBuilder: (context, index) {
                final story = stories[index];

                if (index == 0) {
                  return Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xffC7C7CC), width: 1),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.black, size: 28),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story['label']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff262626),
                        ),
                      ),
                    ],
                  );
                } else {
                  print(
                      "Rendering highlight: ${story['label']}, URL: ${story['imageUrl']}");
                  return Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xffC7C7CC), width: 1),
                          image: story['imageUrl'] != null &&
                              story['imageUrl'].isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(story['imageUrl']),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              print(
                                  "Error loading image for ${story['label']}: $exception");
                            },
                          )
                              : null,
                        ),
                        child: story['imageUrl'] == null ||
                            story['imageUrl'].isEmpty
                            ? const Icon(Icons.error, size: 30)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story['label']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff262626),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _combinedMediaContent(String userId, DatabaseService databaseService) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseService.getUserPhotos(userId),
      builder: (context, photoSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: databaseService.getUserVideos(userId),
          builder: (context, videoSnapshot) {
            if (photoSnapshot.connectionState == ConnectionState.waiting ||
                videoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (photoSnapshot.hasError) {
              print("Photo snapshot error: ${photoSnapshot.error}");
              return Center(child: Text("Error loading photos: ${photoSnapshot.error}"));
            }
            if (videoSnapshot.hasError) {
              print("Video snapshot error: ${videoSnapshot.error}");
              return Center(child: Text("Error loading videos: ${videoSnapshot.error}"));
            }

            List<Map<String, dynamic>> mediaItems = [];

            if (photoSnapshot.hasData && photoSnapshot.data!.docs.isNotEmpty) {
              print("Photos found: ${photoSnapshot.data!.docs.length}");
              for (var doc in photoSnapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                data['type'] = 'photo';
                print("Photo document: $data");
                mediaItems.add(data);
              }
            } else {
              print("No photos found for user $userId");
            }

            if (videoSnapshot.hasData && videoSnapshot.data!.docs.isNotEmpty) {
              print("Videos found: ${videoSnapshot.data!.docs.length}");
              for (var doc in videoSnapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                data['type'] = 'video';
                print("Video document: $data");
                mediaItems.add(data);
              }
            } else {
              print("No videos found for user $userId");
            }

            if (mediaItems.isEmpty) {
              print("Media items list is empty");
              return const Center(child: Text("No photos or videos yet"));
            }

            mediaItems.sort((a, b) {
              Timestamp? aTime = a['createdAt'];
              Timestamp? bTime = b['createdAt'];
              return bTime?.compareTo(aTime ?? Timestamp.now()) ?? 0;
            });

            print("Total media items to render: ${mediaItems.length}");

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: mediaItems.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  var media = mediaItems[index];
                  String mediaType = media['type'] ?? 'photo';
                  print("Rendering media item $index: Type=$mediaType, URL=${media['mediaUrl']}");
                  return FutureBuilder<String>(
                    future: databaseService.getPreSignedUrl('chetra', extractFileName(media['mediaUrl'])),
                    builder: (context, urlSnapshot) {
                      if (urlSnapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (urlSnapshot.hasError || !urlSnapshot.hasData) {
                        print("Error fetching pre-signed URL for ${media['mediaUrl']}: ${urlSnapshot.error}");
                        return const SizedBox(
                          height: 150,
                          child: Center(child: Icon(Icons.error)),
                        );
                      }

                      String url = urlSnapshot.data!;
                      if (mediaType == 'video') {
                        print("Rendering video with URL: $url");
                        return VideoPlayerWidget(videoUrl: url);
                      } else {
                        print("Rendering image with URL: $url");
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                height: 150,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print("Image load error for $url: $error");
                              return const SizedBox(
                                height: 150,
                                child: Center(child: Icon(Icons.error)),
                              );
                            },
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _allPostsContent(DatabaseService databaseService) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseService.getAllPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading posts: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No posts available"));
        }

        var posts = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index].data() as Map<String, dynamic>;
            String? mediaUrl = post['mediaUrl'];

            if (mediaUrl == null || mediaUrl.isEmpty) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              );
            }

            return FutureBuilder<String>(
              future: databaseService.getPreSignedUrl('chetra', extractFileName(mediaUrl)),
              builder: (context, urlSnapshot) {
                if (urlSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (urlSnapshot.hasError || !urlSnapshot.hasData) {
                  print("Error fetching pre-signed URL: ${urlSnapshot.error}");
                  return const Icon(Icons.error);
                }

                String freshUrl = urlSnapshot.data!;
                return Image.network(
                  freshUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Image load error: $error");
                    return const Icon(Icons.error);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    print("Initializing VideoPlayer with URL: ${widget.videoUrl}");
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        print("VideoPlayer initialized successfully");
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isError = false;
            _controller.setLooping(true);
          });
        }
      }).catchError((error) {
        print("Error initializing VideoPlayer: $error");
        if (mounted) {
          setState(() {
            _isInitialized = false;
            _isError = true;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _isError = false;
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    print("Disposing VideoPlayerController");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              const Text(
                "Failed to load video",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    print("Rendering VideoPlayer");
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            print("Pausing video");
            _controller.pause();
          } else {
            print("Playing video");
            _controller.play();
          }
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            if (!_controller.value.isPlaying)
              Icon(
                Icons.play_arrow,
                color: Colors.white.withOpacity(0.8),
                size: 50,
              ),
          ],
        ),
      ),
    );
  }
}