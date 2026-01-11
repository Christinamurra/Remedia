import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../services/comment_service.dart';
import '../models/comment.dart';
import '../models/community_post.dart';

class CommentsSheet extends StatefulWidget {
  final CommunityPost post;
  final String currentUserId;
  final VoidCallback onCommentAdded;

  const CommentsSheet({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onCommentAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required CommunityPost post,
    required String currentUserId,
    required VoidCallback onCommentAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        post: post,
        currentUserId: currentUserId,
        onCommentAdded: onCommentAdded,
      ),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Comment> _comments = [];
  String? _replyingToCommentId;
  String? _replyingToName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadComments() {
    setState(() {
      _comments = _commentService.getPostComments(widget.post.id);
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _commentService.createComment(
        postId: widget.post.id,
        authorId: widget.currentUserId,
        content: _commentController.text.trim(),
        parentCommentId: _replyingToCommentId,
      );

      _commentController.clear();
      _cancelReply();
      _loadComments();
      widget.onCommentAdded();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comment added!'),
            backgroundColor: RemediaColors.mutedGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to add comment'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startReply(Comment comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToName = comment.anonymousName;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToName = null;
    });
  }

  Future<void> _toggleLike(Comment comment) async {
    try {
      await _commentService.toggleLike(
        commentId: comment.id,
        userId: widget.currentUserId,
      );
      _loadComments();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RemediaColors.cardSand,
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: RemediaColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _commentService.deleteComment(comment.id);
      _loadComments();
      widget.onCommentAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: RemediaColors.creamBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _comments.isEmpty
                ? _buildEmptyState()
                : _buildCommentsList(),
          ),
          _buildInputArea(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: RemediaColors.warmBeige,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RemediaColors.textLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          Text(
            'Comments',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.post.commentsCount}',
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: RemediaColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts!',
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final replies = _commentService.getCommentReplies(comment.id);
        return _buildCommentItem(comment, replies);
      },
    );
  }

  Widget _buildCommentItem(Comment comment, List<Comment> replies) {
    final isOwn = comment.authorId == widget.currentUserId;
    final isLiked = comment.isLikedBy(widget.currentUserId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: RemediaColors.warmBeige,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(comment.avatar, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.anonymousName,
                          style: TextStyle(
                            color: RemediaColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment.timeAgo,
                          style: TextStyle(
                            color: RemediaColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Actions
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleLike(comment),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isLiked
                                    ? Colors.red.shade400
                                    : RemediaColors.textMuted,
                              ),
                              if (comment.likesCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '${comment.likesCount}',
                                  style: TextStyle(
                                    color: RemediaColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _startReply(comment),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: RemediaColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isOwn) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _deleteComment(comment),
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Replies
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              children: replies.map((reply) => _buildReplyItem(reply)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReplyItem(Comment reply) {
    final isOwn = reply.authorId == widget.currentUserId;
    final isLiked = reply.isLikedBy(widget.currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: RemediaColors.warmBeige,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(reply.avatar, style: const TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.anonymousName,
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reply.timeAgo,
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content,
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                // Actions
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(reply),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isLiked
                                ? Colors.red.shade400
                                : RemediaColors.textMuted,
                          ),
                          if (reply.likesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${reply.likesCount}',
                              style: TextStyle(
                                color: RemediaColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isOwn) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _deleteComment(reply),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        border: Border(
          top: BorderSide(
            color: RemediaColors.warmBeige,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply indicator
          if (_replyingToName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: RemediaColors.warmBeige,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: RemediaColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Replying to $_replyingToName',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: RemediaColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          // Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  decoration: InputDecoration(
                    hintText: _replyingToName != null
                        ? 'Write a reply...'
                        : 'Add a comment...',
                    hintStyle: TextStyle(color: RemediaColors.textLight),
                    filled: true,
                    fillColor: RemediaColors.warmBeige,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isLoading ? null : _submitComment,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: RemediaColors.mutedGreen,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
