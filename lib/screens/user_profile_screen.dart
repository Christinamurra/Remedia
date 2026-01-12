import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/remedia_theme.dart';
import '../services/meal_post_service.dart';
import '../services/friend_service.dart';
import '../models/meal_post.dart';
import '../models/user.dart';
import '../models/friendship.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String currentUserId;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.currentUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final MealPostService _postService = MealPostService();
  final FriendService _friendService = FriendService();

  User? _user;
  List<MealPost> _posts = [];
  bool _isLoading = true;
  FriendshipStatus? _friendshipStatus;

  bool get _isOwnProfile => widget.userId == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final user = _postService.getUser(widget.userId);
    final posts = await _postService.getUserPosts(
      widget.userId,
      viewerId: widget.currentUserId,
    );

    FriendshipStatus? status;
    if (!_isOwnProfile) {
      status = await _friendService.getFriendshipStatus(
        widget.currentUserId,
        widget.userId,
      );
    }

    setState(() {
      _user = user;
      _posts = posts;
      _friendshipStatus = status;
      _isLoading = false;
    });
  }

  Future<void> _handleFriendAction() async {
    if (_friendshipStatus == null) {
      // Send friend request
      try {
        await _friendService.sendFriendRequest(
          senderId: widget.currentUserId,
          receiverId: widget.userId,
        );
        setState(() => _friendshipStatus = FriendshipStatus.pending);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request sent!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _openPost(MealPost post) {
    // For now, show a bottom sheet with the post
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PostDetailSheet(
        post: post,
        author: _user,
        currentUserId: widget.currentUserId,
        onLike: () async {
          await _postService.toggleLike(
            postId: post.id,
            userId: widget.currentUserId,
          );
          await _loadProfile();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      appBar: AppBar(
        backgroundColor: RemediaColors.creamBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: RemediaColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _user?.displayName ?? 'Profile',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isOwnProfile)
            IconButton(
              icon: Icon(Icons.settings_outlined, color: RemediaColors.textDark),
              onPressed: () {
                // TODO: Open settings
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: RemediaColors.mutedGreen,
              ),
            )
          : _user == null
              ? _buildUserNotFound()
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: RemediaColors.mutedGreen,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildStats()),
                      if (!_isOwnProfile)
                        SliverToBoxAdapter(child: _buildActionButton()),
                      SliverPadding(
                        padding: const EdgeInsets.all(2),
                        sliver: _buildPostsGrid(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: RemediaColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'User not found',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(height: 16),

          // Name
          Text(
            _user!.displayName,
            style: TextStyle(
              color: RemediaColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),

          // Bio
          if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _user!.bio!,
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final size = 100.0;

    if (_user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 3),
        child: CachedNetworkImage(
          imageUrl: _user!.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitialsAvatar(size),
          errorWidget: (_, __, ___) => _buildInitialsAvatar(size),
        ),
      );
    }
    return _buildInitialsAvatar(size);
  }

  Widget _buildInitialsAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: RemediaColors.warmBeige,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Center(
        child: Text(
          _user?.initials ?? '?',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: size / 3,
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final postCount = _posts.length;
    final friendCount = _friendService.getFriendCount(widget.userId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(postCount.toString(), 'Posts'),
          Container(
            width: 1,
            height: 40,
            color: RemediaColors.warmBeige,
          ),
          _buildStatItem(friendCount.toString(), 'Friends'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    String label;
    VoidCallback? onTap;
    bool isPrimary = true;

    switch (_friendshipStatus) {
      case FriendshipStatus.accepted:
        label = 'Friends';
        isPrimary = false;
        onTap = null;
        break;
      case FriendshipStatus.pending:
        label = 'Pending';
        isPrimary = false;
        onTap = null;
        break;
      case FriendshipStatus.blocked:
        label = 'Blocked';
        isPrimary = false;
        onTap = null;
        break;
      default:
        label = 'Add Friend';
        onTap = _handleFriendAction;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary
                ? RemediaColors.mutedGreen
                : RemediaColors.warmBeige,
            foregroundColor: isPrimary ? Colors.white : RemediaColors.textMuted,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.grid_on_rounded,
                size: 48,
                color: RemediaColors.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                _isOwnProfile
                    ? 'Share your first meal!'
                    : 'No posts yet',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = _posts[index];
          return _buildGridItem(post);
        },
        childCount: _posts.length,
      ),
    );
  }

  Widget _buildGridItem(MealPost post) {
    return GestureDetector(
      onTap: () => _openPost(post),
      child: _buildPostThumbnail(post.imageUrl),
    );
  }

  Widget _buildPostThumbnail(String imageUrl) {
    // Check if it's a local file
    if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(),
        );
      }
    }

    // Network image
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: RemediaColors.warmBeige,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: RemediaColors.mutedGreen,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _buildThumbnailPlaceholder(),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: RemediaColors.warmBeige,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: RemediaColors.textMuted,
        ),
      ),
    );
  }
}

// Post detail sheet
class _PostDetailSheet extends StatelessWidget {
  final MealPost post;
  final User? author;
  final String currentUserId;
  final VoidCallback onLike;

  const _PostDetailSheet({
    required this.post,
    this.author,
    required this.currentUserId,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.isLikedBy(currentUserId);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: RemediaColors.creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RemediaColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildImage(post.imageUrl),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption
                if (post.hasCaption) ...[
                  Text(
                    post.caption!,
                    style: TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Actions
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked
                            ? Colors.red.shade400
                            : RemediaColors.textMuted,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(
        color: RemediaColors.warmBeige,
        child: Center(
          child: CircularProgressIndicator(
            color: RemediaColors.mutedGreen,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: RemediaColors.warmBeige,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: RemediaColors.textMuted,
          ),
        ),
      ),
    );
  }
}
