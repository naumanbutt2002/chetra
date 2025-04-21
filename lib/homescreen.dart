import 'package:chetra/database_service.dart';
import 'package:chetra/profile_screen.dart';
import 'package:chetra/createpostscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final DatabaseService _databaseService = DatabaseService();
  Stream<QuerySnapshot>? _postsStream;

  final List<String> username = [
    "Your Story",
    "karenne",
    "zackjohn",
    "kieron_d",
    "craig_d",
  ];

  @override
  void initState() {
    super.initState();
    _refreshPosts();
    print("SocialFeedScreen initialized");
  }

  void _refreshPosts() {
    setState(() {
      _postsStream = _databaseService.getAllPosts();
    });
    print("Posts stream refreshed");
  }

  String _formatTimeSince(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";

    DateTime postTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(postTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hr";
    } else {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''}";
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building SocialFeedScreen");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Image.asset(
                      "assets/profileimage.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffF7F7F7),
                        border: Border.all(color: const Color(0xffCCCDCF), width: 0.5),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(bottom: 0, top: 2),
                          hintText: "Search",
                          hintStyle: const TextStyle(
                            color: Color(0xff808187),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: Image.asset(
                                "assets/searchicon.png",
                                height: 20,
                                width: 20,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xffF7F7F7),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: const Color(0xffCCCDCF),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.asset(
                            "assets/notifyicon.png",
                            height: 22,
                            width: 22,
                            fit: BoxFit.contain,
                          ),
                          Container(
                            height: 7,
                            width: 7,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xffF7F7F7),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: const Color(0xffCCCDCF),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topRight,
                        children: [
                          Image.asset(
                            "assets/messageicon.png",
                            height: 22,
                            width: 22,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            right: -5,
                            top: -3,
                            child: Container(
                              height: 14,
                              width: 14,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  "3",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Divider(height: 1, thickness: 0.2, color: Color(0xFFE0E0E0)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (_, index) {
                          var islive = index == 1;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: islive
                                      ? Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundImage: AssetImage(
                                                'assets/story${index + 1}.png',
                                              ),
                                            ),
                                            Positioned(
                                              bottom: -10,
                                              child: Container(
                                                height: 16,
                                                width: 28,
                                                decoration: BoxDecoration(
                                                  border:  Border.all(
                                                    color: Color(0xffFEFEFE),
                                                    width: 2,
                                                  ),
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "LIVE",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : CircleAvatar(
                                          radius: 28,
                                          backgroundImage: AssetImage(
                                            'assets/story${index + 1}.png',
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  username[index],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _postsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          print("StreamBuilder error: ${snapshot.error}");
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No posts available"));
                        }

                        var posts = snapshot.data!.docs;
                        print("Posts fetched: ${posts.map((doc) => doc.data()).toList()}");
                        return Column(
                          children: posts.map((doc) {
                            var post = doc.data() as Map<String, dynamic>;
                            String userId = post['userId'];
                            String mediaUrl = post['mediaUrl'];
                            String content = post['content'] ?? 'No content';
                            String hashtags = post['hashtags'] ?? '';
                            int likes = post['likes'] ?? 0;
                            int comments = post['comments'] ?? 0;
                            Timestamp? createdAt = post['createdAt'];

                            return FutureBuilder<Map<String, dynamic>?>(
                              future: _databaseService.getUserProfile(userId),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (userSnapshot.hasError || !userSnapshot.hasData) {
                                  print("User profile error: ${userSnapshot.error}");
                                  return const SizedBox.shrink();
                                }

                                var userData = userSnapshot.data!;
                                String username = userData['username'] ?? 'Unknown';
                                String profilePicture = userData['profilePicture'] ?? '';
                                String subtitle = userData['bio'] ?? '';

                                return FutureBuilder<String>(
                                  future: _databaseService.getPreSignedUrl('chetra', mediaUrl),
                                  builder: (context, urlSnapshot) {
                                    if (urlSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (urlSnapshot.hasError || !urlSnapshot.hasData) {
                                      print("Pre-signed URL error: ${urlSnapshot.error}");
                                      return const Center(child: Icon(Icons.error));
                                    }

                                    return PostWidget(
                                      profilePictureUrl: profilePicture,
                                      username: username,
                                      subtitle: subtitle,
                                      content: content,
                                      hashtags: hashtags.isNotEmpty ? hashtags : null,
                                      imagePaths: [urlSnapshot.data!],
                                      time: _formatTimeSince(createdAt),
                                      likes: likes.toString(),
                                      comments: comments.toString(),
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
     
    );
  }
}

class PostWidget extends StatefulWidget {
  final String profilePictureUrl;
  final String username;
  final String subtitle;
  final String content;
  final String? hashtags;
  final List<String>? imagePaths;
  final String time;
  final String likes;
  final String comments;

  const PostWidget({
    super.key,
    required this.profilePictureUrl,
    required this.username,
    required this.subtitle,
    required this.content,
    this.hashtags,
    this.imagePaths,
    required this.time,
    required this.likes,
    required this.comments,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: widget.profilePictureUrl.isNotEmpty
                  ? NetworkImage(widget.profilePictureUrl)
                  : const AssetImage('assets/profileimage.png') as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {
                print("Error loading profile picture: $exception");
              },
            ),
            title: Row(
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 3),
                Container(
                  height: 4,
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xff808187),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff808187),
                    ),
                  ),
                ),
                Image.asset(
                  "assets/moreoptions.png",
                  height: 2,
                  width: 16,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            subtitle: Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff808187),
                fontWeight: FontWeight.w400,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff00030F),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imagePaths!.length,
                  itemBuilder: (context, index) {
                    final isSingleImage = widget.imagePaths!.length == 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          widget.imagePaths![index],
                          width: isSingleImage ? 380 : 300,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Image load error: $error");
                            return const Icon(Icons.error, size: 50);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (widget.hashtags != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.hashtags!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff00030F),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Image.asset(
                  "assets/heart.png",
                  height: 16,
                  width: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Text(widget.likes, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Image.asset(
                  "assets/postcomment.png",
                  height: 16,
                  width: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Text(widget.comments, style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Image.asset(
                  "assets/share.png",
                  height: 16,
                  width: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSaved = !isSaved;
                    });
                  },
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                    color: isSaved ? Colors.green : const Color(0xff4D4F57),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 1,
            child: Divider(
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
          ),
        ],
      ),
    );
  }
}