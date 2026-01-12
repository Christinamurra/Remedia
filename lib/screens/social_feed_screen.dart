import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../services/meal_post_service.dart';
import '../services/post_service.dart';
import '../models/meal_post.dart';
import '../models/community_post.dart';
import '../models/user.dart';
import '../models/recipe.dart';
import '../data/recipes_data.dart';
import '../widgets/meal_post_card.dart';
import '../widgets/comments_sheet.dart';
import 'create_meal_post_screen.dart';
import 'user_profile_screen.dart';
import 'recipe_detail_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MealPostService _mealPostService = MealPostService();
  final PostService _communityService = PostService();
  final ScrollController _scrollController = ScrollController();

  List<MealPost> _forYouPosts = [];
  List<MealPost> _followingPosts = [];
  List<CommunityPost> _communityPosts = [];
  bool _isLoading = true;

  // TODO: Replace with actual authenticated user ID
  final String _currentUserId = 'current_user';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    // Seed sample community posts if empty
    await _communityService.seedSamplePosts();

    final forYouPosts = await _mealPostService.getSocialFeed(_currentUserId);
    final followingPosts = await _mealPostService.getFriendsFeed(_currentUserId);
    final communityPosts = _communityService.getFeed();

    setState(() {
      _forYouPosts = forYouPosts;
      _followingPosts = followingPosts;
      _communityPosts = communityPosts;
      _isLoading = false;
    });
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

  User? _getUser(String userId) {
    return _mealPostService.getUser(userId);
  }

  Recipe? _getRecipe(String? recipeId) {
    if (recipeId == null) return null;
    try {
      return recipesData.firstWhere((r) => r.id == recipeId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _toggleLike(MealPost post) async {
    try {
      await _mealPostService.toggleLike(
        postId: post.id,
        userId: _currentUserId,
      );
      await _loadPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleCommunityLike(CommunityPost post) async {
    try {
      await _communityService.toggleLike(
        postId: post.id,
        userId: _currentUserId,
      );
      await _loadPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openCommunityComments(CommunityPost post) {
    CommentsSheet.show(
      context,
      post: post,
      currentUserId: _currentUserId,
      onCommentAdded: () => _loadPosts(),
    );
  }

  void _openComments(MealPost post) {
    // TODO: Implement comments for meal posts
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Comments coming soon!'),
        backgroundColor: RemediaColors.mutedGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: userId,
          currentUserId: _currentUserId,
        ),
      ),
    );
  }

  void _openRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }

  void _openCreatePost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMealPostScreen(
          currentUserId: _currentUserId,
        ),
      ),
    );

    if (result == true) {
      await _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedList(_forYouPosts),
                  _buildFeedList(_followingPosts),
                  _buildCommunityList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: RemediaColors.mutedGreen,
        child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            'Community',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (_isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: RemediaColors.mutedGreen,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: RemediaColors.warmBeige,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: RemediaColors.textDark,
        unselectedLabelColor: RemediaColors.textMuted,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'For You'),
          Tab(text: 'Following'),
          Tab(text: 'Discuss'),
        ],
      ),
    );
  }

  Widget _buildFeedList(List<MealPost> posts) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: RemediaColors.mutedGreen,
        ),
      );
    }

    if (posts.isEmpty) {
      return _buildEmptyFeed();
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      color: RemediaColors.mutedGreen,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final author = _getUser(post.authorId);
          final recipe = _getRecipe(post.linkedRecipeId);

          return MealPostCard(
            post: post,
            author: author,
            linkedRecipe: recipe,
            currentUserId: _currentUserId,
            onLike: () => _toggleLike(post),
            onComment: () => _openComments(post),
            onAuthorTap: () => _openUserProfile(post.authorId),
            onRecipeTap: recipe != null ? () => _openRecipeDetail(recipe) : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyFeed() {
    final isFollowingTab = _tabController.index == 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: RemediaColors.cardSand,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isFollowingTab
                    ? Icons.people_outline_rounded
                    : Icons.restaurant_menu_rounded,
                size: 40,
                color: RemediaColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFollowingTab ? 'No posts from friends yet' : 'No posts yet',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFollowingTab
                  ? 'Add friends to see their meal posts here'
                  : 'Share your first meal to get started!',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openCreatePost,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Share a Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RemediaColors.mutedGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: RemediaColors.mutedGreen,
        ),
      );
    }

    if (_communityPosts.isEmpty) {
      return _buildEmptyCommunity();
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      color: RemediaColors.mutedGreen,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: _communityPosts.length,
        itemBuilder: (context, index) {
          final post = _communityPosts[index];
          return _buildCommunityPostCard(post);
        },
      ),
    );
  }

  Widget _buildEmptyCommunity() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: RemediaColors.cardSand,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.forum_rounded,
                size: 40,
                color: RemediaColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No discussions yet',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with the community!',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityPostCard(CommunityPost post) {
    final isLiked = post.isLikedBy(_currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: RemediaColors.mutedGreen.withValues(alpha: 0.2),
                child: Text(
                  post.avatar,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.anonymousName,
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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
              if (post.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.badge!,
                    style: TextStyle(
                      color: RemediaColors.mutedGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Post content
          Text(
            post.content,
            style: TextStyle(
              color: RemediaColors.textDark,
              fontSize: 15,
              height: 1.4,
            ),
          ),

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: RemediaColors.warmBeige,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Actions row
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleCommunityLike(post),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isLiked ? RemediaColors.terraCotta : RemediaColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _openCommunityComments(post),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: RemediaColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentsCount}',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
