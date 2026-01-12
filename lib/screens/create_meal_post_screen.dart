import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/remedia_theme.dart';
import '../services/meal_post_service.dart';
import '../services/image_upload_service.dart';
import '../models/meal_post.dart';
import '../models/recipe.dart';
import '../data/recipes_data.dart';

class CreateMealPostScreen extends StatefulWidget {
  final String currentUserId;

  const CreateMealPostScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<CreateMealPostScreen> createState() => _CreateMealPostScreenState();
}

class _CreateMealPostScreenState extends State<CreateMealPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final MealPostService _postService = MealPostService();
  final ImageUploadService _imageService = ImageUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  Recipe? _selectedRecipe;
  MealPostVisibility _visibility = MealPostVisibility.friendsOnly;
  bool _isPosting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
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
        decoration: const BoxDecoration(
          color: RemediaColors.creamBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

  void _showRecipeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RecipeSelectorSheet(
        selectedRecipe: _selectedRecipe,
        onRecipeSelected: (recipe) {
          setState(() {
            _selectedRecipe = recipe;
          });
          Navigator.pop(context);
        },
        onClear: () {
          setState(() {
            _selectedRecipe = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _createPost() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a photo of your meal'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // Upload image to Firebase Storage
      final imageUrl = await _imageService.uploadMealPostImage(
        _selectedImage!,
        widget.currentUserId,
      );

      // Create the post
      await _postService.createPost(
        authorId: widget.currentUserId,
        imageUrl: imageUrl,
        caption: _captionController.text.trim().isNotEmpty
            ? _captionController.text.trim()
            : null,
        linkedRecipeId: _selectedRecipe?.id,
        visibility: _visibility,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meal posted!'),
            backgroundColor: RemediaColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
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
          icon: Icon(Icons.close, color: RemediaColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Share Meal',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isPosting ? null : _createPost,
              child: _isPosting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: RemediaColors.mutedGreen,
                      ),
                    )
                  : Text(
                      'Post',
                      style: TextStyle(
                        color: _selectedImage != null
                            ? RemediaColors.mutedGreen
                            : RemediaColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            _buildImagePicker(),
            const SizedBox(height: 24),

            // Caption input
            _buildCaptionInput(),
            const SizedBox(height: 24),

            // Recipe link
            _buildRecipeLink(),
            const SizedBox(height: 24),

            // Privacy selector
            _buildPrivacySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: RemediaColors.warmBeige,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RemediaColors.warmBeige,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.add_a_photo_rounded,
                size: 40,
                color: RemediaColors.mutedGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add a photo of your meal',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to take a photo or choose from gallery',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caption',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _captionController,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Share something about your meal...',
            hintStyle: TextStyle(color: RemediaColors.textLight),
            filled: true,
            fillColor: RemediaColors.cardSand,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(color: RemediaColors.textMuted),
          ),
          style: TextStyle(color: RemediaColors.textDark),
        ),
      ],
    );
  }

  Widget _buildRecipeLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link a Recipe',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional - let others know what you made',
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showRecipeSelector,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RemediaColors.cardSand,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedRecipe != null
                        ? RemediaColors.mutedGreen.withValues(alpha: 0.12)
                        : RemediaColors.warmBeige,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    color: _selectedRecipe != null
                        ? RemediaColors.mutedGreen
                        : RemediaColors.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedRecipe?.title ?? 'Select a recipe',
                    style: TextStyle(
                      color: _selectedRecipe != null
                          ? RemediaColors.textDark
                          : RemediaColors.textMuted,
                      fontWeight: _selectedRecipe != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: RemediaColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who can see this?',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPrivacyOption(
                icon: Icons.people_rounded,
                label: 'Friends Only',
                isSelected: _visibility == MealPostVisibility.friendsOnly,
                onTap: () =>
                    setState(() => _visibility = MealPostVisibility.friendsOnly),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPrivacyOption(
                icon: Icons.public_rounded,
                label: 'Public',
                isSelected: _visibility == MealPostVisibility.public,
                onTap: () =>
                    setState(() => _visibility = MealPostVisibility.public),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacyOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? RemediaColors.mutedGreen.withValues(alpha: 0.12)
              : RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: RemediaColors.mutedGreen, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? RemediaColors.mutedGreen
                  : RemediaColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? RemediaColors.mutedGreen
                    : RemediaColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recipe selector sheet
class _RecipeSelectorSheet extends StatefulWidget {
  final Recipe? selectedRecipe;
  final Function(Recipe) onRecipeSelected;
  final VoidCallback onClear;

  const _RecipeSelectorSheet({
    this.selectedRecipe,
    required this.onRecipeSelected,
    required this.onClear,
  });

  @override
  State<_RecipeSelectorSheet> createState() => _RecipeSelectorSheetState();
}

class _RecipeSelectorSheetState extends State<_RecipeSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Recipe> get _filteredRecipes {
    if (_searchQuery.isEmpty) return recipesData;
    return recipesData.where((r) {
      return r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Text(
                  'Link a Recipe',
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (widget.selectedRecipe != null)
                  TextButton(
                    onPressed: widget.onClear,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: RemediaColors.terraCotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: RemediaColors.textMuted),
                filled: true,
                fillColor: RemediaColors.cardSand,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recipe list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                final isSelected = widget.selectedRecipe?.id == recipe.id;

                return GestureDetector(
                  onTap: () => widget.onRecipeSelected(recipe),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? RemediaColors.mutedGreen.withValues(alpha: 0.12)
                          : RemediaColors.cardSand,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: RemediaColors.mutedGreen, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            recipe.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: RemediaColors.warmBeige,
                              child: Icon(
                                Icons.restaurant_rounded,
                                color: RemediaColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                style: TextStyle(
                                  color: RemediaColors.textDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recipe.tags.take(2).join(' • '),
                                style: TextStyle(
                                  color: RemediaColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: RemediaColors.mutedGreen,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
