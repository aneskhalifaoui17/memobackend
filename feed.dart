import 'package:flutter/material.dart';

// 1. THE DATA MODEL (DUMMY POSTS)
class FeedPost {
  final String user;
  final String? profileImage; // URL or Asset path
  final String title;
  final String community; // e.g., "SoftwareEng"
  final String body;
  final int upvotes;
  final int comments;
  final Duration timeAgo;

  FeedPost({
    required this.user,
    this.profileImage,
    required this.title,
    required this.community,
    required this.body,
    required this.upvotes,
    required this.comments,
    required this.timeAgo,
  });
}

class AcademicFeedScreen extends StatelessWidget {
  AcademicFeedScreen({super.key});

  // 2. DUMMY DATA LIST (The content of your feed)
  final List<FeedPost> _dummyPosts = [
    FeedPost(
      user: "AlgoWizard",
      community: "DataStructures",
      title: "Anyone else struggling with Dijkstra's algorithm?",
      body: "I understand the basic concept, but my implementation keeps failing on edge cases. Any tips or reliable pseudocode resources?",
      upvotes: 88,
      comments: 24,
      timeAgo: const Duration(minutes: 15),
    ),
    FeedPost(
      user: "VaultKeeper",
      community: "AcademicVault",
      title: "Showcase: My 50-hour study streak badge!",
      body: "Finally hit the milestone! This app really helps me stay focused. What streaks are you all on?",
      upvotes: 142,
      comments: 6,
      timeAgo: const Duration(hours: 1),
    ),
    FeedPost(
      user: "CryptoNerd",
      community: "CompSecurity",
      title: "The importance of salting passwords (simple explanation)",
      body: "Salting ensures that two users with the same password will have different hash values. This prevents rainbow table attacks...",
      upvotes: 55,
      comments: 19,
      timeAgo: const Duration(hours: 3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
  backgroundColor: const Color(0xFF121212), // Deep black background
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.menu, color: Colors.white70),
    onPressed: () {},
  ),
  title: Container(
    height: 42,
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E), // Subtle dark gray fill
      borderRadius: BorderRadius.circular(25), // The "Super Pill" shape
      border: Border.all(
        color: Colors.orange.withOpacity(0.7), // The thin orange border from your pic
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        const SizedBox(width: 12),
        // The Reddit Icon (Using a CircleAvatar as a placeholder)
        const CircleAvatar(
          radius: 12,
          backgroundColor: Colors.orange,
          child: Icon(Icons.face, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Find anything",
            style: TextStyle(
              color: Colors.white38, 
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  ),
  centerTitle: true,
),
      body: ListView.separated(
        itemCount: _dummyPosts.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
        separatorBuilder: (context, index) => const SizedBox(height: 8), // Gap between posts
        itemBuilder: (context, index) {
          final post = _dummyPosts[index];
          return _buildPostCard(context, post);
        },
      ),
      // Reddit-style floating action button for new posts
    );
  }

  // 3. THE POST CARD UI WIDGET (The building block)
  Widget _buildPostCard(BuildContext context, FeedPost post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Match your vault card color
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Community, User, Time
          Row(
            children: [
              // Dummy Community Icon/Avatar
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white10,
                child: Text(
                  post.community.substring(0, 1),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "s/${post.community}", // Subreddit style
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                "• u/${post.user}",
                style: const TextStyle(color: Colors.white38),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(post.timeAgo),
                style: const TextStyle(color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TITLE
          Text(
            post.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // BODY (Preview)
          Text(
            post.body,
            maxLines: 3, // Limit preview length
            overflow: TextOverflow.ellipsis, // Add "..."
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),

          // ACTION BAR: Upvotes, Comments, Share
          Row(
            children: [
              // Upvotes (Reddit Style)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white38, size: 20),
                      onPressed: () {},
                    ),
                    Text("${post.upvotes}", style: const TextStyle(color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white38, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Comments
              _buildActionButton(Icons.chat_bubble_outline_rounded, "${post.comments}"),
              const SizedBox(width: 16),

              // Share
              _buildActionButton(Icons.share_outlined, ""),
              const Spacer(),
              _buildActionButton(Icons.bookmark_border_rounded, ""), // Save
            ],
          ),
        ],
      ),
    );
  }

  // Helper for action buttons (Comments, Share)
  Widget _buildActionButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          if (text.isNotEmpty) const SizedBox(width: 6),
          if (text.isNotEmpty)
            Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // Helper for formatting time
  String _formatTimeAgo(Duration duration) {
    if (duration.inMinutes < 60) {
      return "${duration.inMinutes}m ago";
    } else if (duration.inHours < 24) {
      return "${duration.inHours}h ago";
    } else {
      return "${duration.inDays}d ago";
    }
  }
}