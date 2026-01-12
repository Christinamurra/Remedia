import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/article.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expand your wellness knowledge',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Articles list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sampleArticles.length,
                itemBuilder: (context, index) {
                  return _buildArticleCard(context, sampleArticles[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.gutHealth:
        return '🦠';
      case ArticleCategory.bloodSugar:
        return '🍎';
      case ArticleCategory.herbs:
        return '🌿';
      case ArticleCategory.nervousSystem:
        return '🧘';
      case ArticleCategory.liverHealth:
        return '🫀';
    }
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    Color categoryColor;
    switch (article.category) {
      case ArticleCategory.gutHealth:
        categoryColor = RemediaColors.mutedGreen;
        break;
      case ArticleCategory.bloodSugar:
        categoryColor = RemediaColors.terraCotta;
        break;
      case ArticleCategory.herbs:
        categoryColor = RemediaColors.sageGreen;
        break;
      case ArticleCategory.nervousSystem:
        categoryColor = RemediaColors.waterBlue;
        break;
      case ArticleCategory.liverHealth:
        categoryColor = RemediaColors.terraCotta.withValues(alpha: 0.8);
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Category illustration
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withValues(alpha: 0.15),
                    categoryColor.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoryColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: -5,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoryColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  // Main emoji
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getCategoryEmoji(article.category),
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.categoryLabel,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Read time
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: RemediaColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readTime} min read',
                          style: TextStyle(
                            color: RemediaColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.chevron_right,
                color: RemediaColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  String _getCategoryEmoji(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.gutHealth:
        return '🦠';
      case ArticleCategory.bloodSugar:
        return '🍎';
      case ArticleCategory.herbs:
        return '🌿';
      case ArticleCategory.nervousSystem:
        return '🧘';
      case ArticleCategory.liverHealth:
        return '🫀';
    }
  }

  Color _getCategoryColor(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.gutHealth:
        return RemediaColors.mutedGreen;
      case ArticleCategory.bloodSugar:
        return RemediaColors.terraCotta;
      case ArticleCategory.herbs:
        return RemediaColors.sageGreen;
      case ArticleCategory.nervousSystem:
        return RemediaColors.waterBlue;
      case ArticleCategory.liverHealth:
        return RemediaColors.terraCotta.withValues(alpha: 0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(article.category);

    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      appBar: AppBar(
        backgroundColor: RemediaColors.creamBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: RemediaColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header illustration
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withValues(alpha: 0.15),
                    categoryColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoryColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoryColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 40,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoryColor.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  // Main emoji
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getCategoryEmoji(article.category),
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: RemediaColors.cardSand,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and read time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.categoryLabel,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: RemediaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readTime} min read',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary
                  Text(
                    article.summary,
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 16,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    color: RemediaColors.warmBeige,
                  ),
                  const SizedBox(height: 24),

                  // Content
                  Text(
                    article.content,
                    style: TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
