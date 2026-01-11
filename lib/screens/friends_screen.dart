import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../services/friend_service.dart';
import '../models/friendship.dart';
import '../models/user.dart';

class FriendsScreen extends StatefulWidget {
  final String currentUserId;

  const FriendsScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendService _friendService = FriendService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _friends = [];
  List<Friendship> _pendingRequests = [];
  List<Friendship> _sentRequests = [];
  List<User> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _friends = _friendService.getFriendUsers(widget.currentUserId);
      _pendingRequests = _friendService.getPendingRequests(widget.currentUserId);
      _sentRequests = _friendService.getSentRequests(widget.currentUserId);
    });
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _friendService.searchUsers(
        query,
        excludeUserId: widget.currentUserId,
      );
    });
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    try {
      await _friendService.sendFriendRequest(
        senderId: widget.currentUserId,
        receiverId: receiverId,
      );
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Friend request sent!'),
            backgroundColor: RemediaColors.mutedGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on FriendshipException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _acceptRequest(String friendshipId) async {
    try {
      await _friendService.acceptFriendRequest(friendshipId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Friend request accepted!'),
            backgroundColor: RemediaColors.mutedGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _rejectRequest(String friendshipId) async {
    try {
      await _friendService.rejectFriendRequest(friendshipId);
      _loadData();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _removeFriend(String friendshipId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: const Text('Are you sure you want to remove this friend?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _friendService.removeFriend(friendshipId);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      appBar: AppBar(
        backgroundColor: RemediaColors.creamBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: RemediaColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Friends',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: RemediaColors.textDark,
          unselectedLabelColor: RemediaColors.textMuted,
          indicatorColor: RemediaColors.mutedGreen,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Friends'),
                  if (_friends.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    _buildBadge(_friends.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Requests'),
                  if (_pendingRequests.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    _buildBadge(_pendingRequests.length),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Add'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(),
          _buildRequestsList(),
          _buildAddFriends(),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: RemediaColors.mutedGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No friends yet',
        subtitle: 'Add friends to see their posts and support each other!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        final friendship = _friendService.getFriends(widget.currentUserId)
            .firstWhere((f) =>
              f.senderId == friend.id || f.receiverId == friend.id);

        return _buildFriendCard(friend, friendship);
      },
    );
  }

  Widget _buildFriendCard(User friend, Friendship friendship) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildAvatar(friend),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.displayName,
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (friend.bio != null && friend.bio!.isNotEmpty)
                  Text(
                    friend.bio!,
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: RemediaColors.textMuted),
            onSelected: (value) {
              if (value == 'remove') {
                _removeFriend(friendship.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Remove friend'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_pendingRequests.isEmpty && _sentRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mail_outline,
        title: 'No requests',
        subtitle: 'Friend requests you receive will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_pendingRequests.isNotEmpty) ...[
          Text(
            'Received Requests',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ..._pendingRequests.map((request) => _buildRequestCard(request, true)),
        ],
        if (_sentRequests.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Sent Requests',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ..._sentRequests.map((request) => _buildRequestCard(request, false)),
        ],
      ],
    );
  }

  Widget _buildRequestCard(Friendship request, bool isReceived) {
    final otherUserId = isReceived ? request.senderId : request.receiverId;
    final user = _friendService.getUser(otherUserId);

    if (user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildAvatar(user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isReceived ? 'Wants to be your friend' : 'Request pending',
                  style: TextStyle(
                    color: RemediaColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isReceived) ...[
            IconButton(
              onPressed: () => _acceptRequest(request.id),
              icon: Icon(
                Icons.check_circle,
                color: RemediaColors.mutedGreen,
                size: 28,
              ),
            ),
            IconButton(
              onPressed: () => _rejectRequest(request.id),
              icon: Icon(
                Icons.cancel,
                color: RemediaColors.textMuted,
                size: 28,
              ),
            ),
          ] else
            Text(
              'Pending',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddFriends() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: TextStyle(color: RemediaColors.textLight),
              prefixIcon: Icon(Icons.search, color: RemediaColors.textMuted),
              filled: true,
              fillColor: RemediaColors.cardSand,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: RemediaColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: _isSearching
              ? _buildSearchResults()
              : _buildSearchPrompt(),
        ),
      ],
    );
  }

  Widget _buildSearchPrompt() {
    return _buildEmptyState(
      icon: Icons.person_add_outlined,
      title: 'Find Friends',
      subtitle: 'Search for friends by their name or email address.',
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No results',
        subtitle: 'Try searching with a different name or email.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildSearchResultCard(user);
      },
    );
  }

  Widget _buildSearchResultCard(User user) {
    final status = _friendService.getFriendshipStatus(
      widget.currentUserId,
      user.id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildAvatar(user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: RemediaColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(user, status),
        ],
      ),
    );
  }

  Widget _buildActionButton(User user, FriendshipStatus? status) {
    if (status == FriendshipStatus.accepted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 16,
              color: RemediaColors.mutedGreen,
            ),
            const SizedBox(width: 4),
            Text(
              'Friends',
              style: TextStyle(
                color: RemediaColors.mutedGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (status == FriendshipStatus.pending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: RemediaColors.warmBeige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Pending',
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _sendFriendRequest(user.id),
      style: ElevatedButton.styleFrom(
        backgroundColor: RemediaColors.mutedGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text('Add'),
    );
  }

  Widget _buildAvatar(User user) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: RemediaColors.warmBeige,
        borderRadius: BorderRadius.circular(14),
      ),
      child: user.avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(user),
              ),
            )
          : _buildInitials(user),
    );
  }

  Widget _buildInitials(User user) {
    return Center(
      child: Text(
        user.initials,
        style: TextStyle(
          color: RemediaColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: RemediaColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: RemediaColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
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
}
