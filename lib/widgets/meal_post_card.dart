import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/remedia_theme.dart';
import '../models/meal_post.dart';
import '../models/user.dart';
import '../models/recipe.dart';

class MealPostCard extends StatelessWidget {
  final MealPost post;
  final User? author;
  final Recipe? linkedRecipe;
  final String currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onRecipeTap;

  const MealPostCard({
    super.key,
    required this.post,
    this.author,
    this.linkedRecipe,
    required this.currentUserId,
    this.onLike,
    this.onComment,
    this.onAuthorTap,
    this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.isLikedBy(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAuthorRow(context),
          ),

          // Full-width image
          _buildPostImage(),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
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

                // Linked recipe chip
                if (post.hasLinkedRecipe && linkedRecipe != null) ...[
                  _buildRecipeChip(),
                  const SizedBox(height: 12),
                ],

                // Actions row
                _buildActionsRow(isLiked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context) {
    return GestureDetector(
      onTap: onAuthorTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author?.displayName ?? 'User',
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (post.isFriendsOnly) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: RemediaColors.textMuted,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
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
    );
  }

  Widget _buildAvatar() {
    if (author?.avatarUrl != null && author!.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: author!.avatarUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitialsAvatar(),
          errorWidget: (_, __, ___) => _buildInitialsAvatar(),
        ),
      );
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: RemediaColors.warmBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          author?.initials ?? '?',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage() {
    final imageUrl = post.imageUrl;

    // Check if it's a local file path
    if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            file,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          ),
        );
      }
    }

    // Network image (Firebase Storage URL)
    return AspectRatio(
      aspectRatio: 1,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: RemediaColors.warmBeige,
          child: Center(
            child: CircularProgressIndicator(
              color: RemediaColors.mutedGreen,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: RemediaColors.warmBeige,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 48,
          color: RemediaColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildRecipeChip() {
    return GestureDetector(
      onTap: onRecipeTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: RemediaColors.mutedGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 16,
              color: RemediaColors.mutedGreen,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                linkedRecipe?.title ?? 'View Recipe',
                style: TextStyle(
                  color: RemediaColors.mutedGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: RemediaColors.mutedGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsRow(bool isLiked) {
    return Row(
      children: [
        GestureDetector(
          onTap: onLike,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red.shade400 : RemediaColors.textMuted,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                '${post.likesCount}',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: onComment,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: RemediaColors.textMuted,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '${post.commentsCount}',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Icon(
          Icons.bookmark_border_rounded,
          color: RemediaColors.textMuted,
          size: 24,
        ),
      ],
    );
  }
}
