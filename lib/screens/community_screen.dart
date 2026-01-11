import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final List<CommunityPost> _posts = samplePosts;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Community Stats
              _buildCommunityStats(),
              const SizedBox(height: 24),

              // Share Your Creation
              _buildShareCreation(),
              const SizedBox(height: 20),

              // Made a Recipe Prompt
              _buildMadeRecipePrompt(),
              const SizedBox(height: 24),

              // Community Feed
              _buildCommunityFeed(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Sanctuary',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome, Friend',
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👥', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'Your Community',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'A safe space to share and support',
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: RemediaColors.warmBeige,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '12.5K',
                        style: TextStyle(
                          color: RemediaColors.textDark,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Members',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: RemediaColors.warmBeige,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '487',
                        style: TextStyle(
                          color: RemediaColors.textDark,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Posts Today',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareCreation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Share Your Creation',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Text('📸', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _postController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Share your sugar-free recipe or journey...\nYou're safe here.",
              hintStyle: TextStyle(
                color: RemediaColors.textLight,
                height: 1.5,
              ),
              filled: true,
              fillColor: RemediaColors.warmBeige,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: RemediaColors.textLight,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📷', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Add Photo',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: RemediaColors.warmBeige,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🔍', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_postController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Posted anonymously!'),
                      backgroundColor: RemediaColors.mutedGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  _postController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RemediaColors.warmBeige,
                foregroundColor: RemediaColors.textDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text(
                'Post Anonymously',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMadeRecipePrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Made a recipe?',
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Share your creation and inspire others!',
                  style: TextStyle(
                    color: RemediaColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: RemediaColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildCommunityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Feed',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ..._posts.map((post) => _buildPostCard(post)),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: RemediaColors.warmBeige,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(post.avatar, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.anonymousName,
                          style: TextStyle(
                            color: RemediaColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (post.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.badge!,
                              style: TextStyle(
                                color: RemediaColors.mutedGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: RemediaColors.textMuted),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            post.content,
            style: TextStyle(
              color: RemediaColors.textDark,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          // Image placeholder if has image
          if (post.hasImage) ...[
            const SizedBox(height: 16),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: RemediaColors.warmBeige,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.image_rounded,
                  size: 48,
                  color: RemediaColors.textMuted,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _buildActionButton(Icons.favorite_border, '${post.likes}'),
              const SizedBox(width: 20),
              _buildActionButton(Icons.chat_bubble_outline, '${post.comments}'),
              const Spacer(),
              Icon(Icons.bookmark_border, color: RemediaColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: RemediaColors.textMuted, size: 22),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class CommunityPost {
  final String anonymousName;
  final String avatar;
  final String? badge;
  final String timeAgo;
  final String content;
  final bool hasImage;
  final int likes;
  final int comments;

  const CommunityPost({
    required this.anonymousName,
    required this.avatar,
    this.badge,
    required this.timeAgo,
    required this.content,
    this.hasImage = false,
    required this.likes,
    required this.comments,
  });
}

final List<CommunityPost> samplePosts = [
  const CommunityPost(
    anonymousName: 'Anonymous Butterfly',
    avatar: '🦋',
    badge: '14-Day Champion',
    timeAgo: '2h ago',
    content: 'Day 14 of no sugar! I never thought I could do it. The cravings have finally stopped and I feel so much more energized. Thank you all for the support! 💚',
    hasImage: false,
    likes: 234,
    comments: 45,
  ),
  const CommunityPost(
    anonymousName: 'Gentle Sunrise',
    avatar: '🌅',
    badge: '7-Day Streak',
    timeAgo: '4h ago',
    content: 'Made my first sugar-free banana bread today! Used dates and mashed bananas for sweetness. My kids couldn\'t even tell the difference.',
    hasImage: true,
    likes: 189,
    comments: 32,
  ),
  const CommunityPost(
    anonymousName: 'Quiet Mountain',
    avatar: '🏔️',
    timeAgo: '6h ago',
    content: 'Struggling today. Day 3 and the cravings are intense. Any tips for getting through the afternoon slump?',
    hasImage: false,
    likes: 156,
    comments: 78,
  ),
  const CommunityPost(
    anonymousName: 'Dancing Leaf',
    avatar: '🍃',
    badge: '30-Day Master',
    timeAgo: '8h ago',
    content: 'One month sugar-free! Here\'s what changed:\n\n• Better sleep\n• Clearer skin\n• More stable energy\n• No more brain fog\n\nIt\'s worth it, trust the process! 🌿',
    hasImage: false,
    likes: 412,
    comments: 67,
  ),
];
