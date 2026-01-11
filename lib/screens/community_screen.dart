import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../theme/remedia_theme.dart';
import '../services/post_service.dart';
import '../services/friend_service.dart';
import '../models/community_post.dart';
import '../widgets/comments_sheet.dart';
import 'friends_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final PostService _postService = PostService();
  final FriendService _friendService = FriendService();
  final ImagePicker _imagePicker = ImagePicker();

  List<CommunityPost> _posts = [];
  bool _isLoading = true;
  File? _selectedImage;
  bool _isPosting = false;

  // TODO: Replace with actual authenticated user ID
  final String _currentUserId = 'current_user';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    // Seed sample posts if empty (for demo)
    await _postService.seedSamplePosts();

    setState(() {
      _posts = _postService.getFeed();
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RemediaColors.creamBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: RemediaColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add Photo',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: RemediaColors.mutedGreen),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: RemediaColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<String?> _saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/post_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedImage = await imageFile.copy('${imagesDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty && _selectedImage == null) return;

    setState(() => _isPosting = true);

    try {
      String? imagePath;
      if (_selectedImage != null) {
        imagePath = await _saveImageLocally(_selectedImage!);
      }

      await _postService.createPost(
        authorId: _currentUserId,
        content: _postController.text.trim(),
        imageUrl: imagePath,
        isAnonymous: true,
      );

      _postController.clear();
      setState(() {
        _selectedImage = null;
      });
      await _loadPosts();

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create post'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _toggleLike(CommunityPost post) async {
    try {
      await _postService.toggleLike(
        postId: post.id,
        userId: _currentUserId,
      );
      await _loadPosts();
    } catch (e) {
      // Handle error silently
    }
  }

  void _openComments(CommunityPost post) {
    CommentsSheet.show(
      context,
      post: post,
      currentUserId: _currentUserId,
      onCommentAdded: _loadPosts,
    );
  }

  void _openFriendsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendsScreen(currentUserId: _currentUserId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPosts,
          color: RemediaColors.mutedGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCommunityStats(),
                const SizedBox(height: 24),
                _buildShareCreation(),
                const SizedBox(height: 20),
                _buildMadeRecipePrompt(),
                const SizedBox(height: 24),
                _buildCommunityFeed(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
        ),
        Row(
          children: [
            // Friends button
            GestureDetector(
              onTap: _openFriendsScreen,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RemediaColors.cardSand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: RemediaColors.textDark,
                      size: 24,
                    ),
                    if (_friendService.getPendingRequestCount(_currentUserId) > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: RemediaColors.mutedGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityStats() {
    final totalMembers = '12.5K'; // Could be fetched from backend
    final postsToday = _postService.getPostsTodayCount();

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
                        totalMembers,
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
                        '$postsToday',
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
          // Selected image preview
          if (_selectedImage != null) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removeSelectedImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedImage != null
                            ? RemediaColors.mutedGreen
                            : RemediaColors.textLight,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: _selectedImage != null
                          ? RemediaColors.mutedGreen.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedImage != null
                              ? Icons.check_circle
                              : Icons.camera_alt_outlined,
                          size: 20,
                          color: _selectedImage != null
                              ? RemediaColors.mutedGreen
                              : RemediaColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedImage != null ? 'Photo Added' : 'Add Photo',
                          style: TextStyle(
                            color: _selectedImage != null
                                ? RemediaColors.mutedGreen
                                : RemediaColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
              onPressed: _isPosting ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: RemediaColors.warmBeige,
                foregroundColor: RemediaColors.textDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                disabledBackgroundColor: RemediaColors.warmBeige.withValues(alpha: 0.5),
              ),
              child: _isPosting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: RemediaColors.textDark,
                      ),
                    )
                  : const Text(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Community Feed',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: RemediaColors.mutedGreen,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_posts.isEmpty && !_isLoading)
          _buildEmptyFeed()
        else
          ..._posts.map((post) => _buildPostCard(post)),
      ],
    );
  }

  Widget _buildEmptyFeed() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: RemediaColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your journey!',
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final isLiked = post.isLikedBy(_currentUserId);

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
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: TextStyle(
                color: RemediaColors.textDark,
                fontSize: 15,
                height: 1.5,
              ),
            ),

          // Image
          if (post.hasImage) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildPostImage(post.imageUrl!),
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(post),
                child: _buildActionButton(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  '${post.likesCount}',
                  isActive: isLiked,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _openComments(post),
                child: _buildActionButton(
                  Icons.chat_bubble_outline,
                  '${post.commentsCount}',
                ),
              ),
              const Spacer(),
              Icon(Icons.bookmark_border, color: RemediaColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    // Check if it's a local file path
    if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      }
    }

    // Handle placeholder or network images
    if (imageUrl == 'placeholder') {
      return _buildImagePlaceholder();
    }

    return Image.network(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          color: RemediaColors.warmBeige,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: RemediaColors.mutedGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: RemediaColors.warmBeige,
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 48,
          color: RemediaColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count, {bool isActive = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.red.shade400 : RemediaColors.textMuted,
          size: 22,
        ),
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
