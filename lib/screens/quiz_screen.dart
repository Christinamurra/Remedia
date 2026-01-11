import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/quiz.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

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
          'Wellness Quizzes',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Test Your Knowledge',
            style: TextStyle(
              color: RemediaColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn about herbs, vitamins, and supplements through fun quizzes!',
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          ...sampleQuizzes.map((quiz) => _buildQuizCard(context, quiz)),
        ],
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPlayScreen(quiz: quiz),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: RemediaColors.mutedGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(quiz.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${quiz.questions.length} questions',
                    style: TextStyle(
                      color: RemediaColors.mutedGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: RemediaColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  bool _isQuizComplete = false;

  QuizQuestion get _currentQuestion => widget.quiz.questions[_currentQuestionIndex];

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      if (index == _currentQuestion.correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    } else {
      setState(() {
        _isQuizComplete = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
      _isQuizComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuizComplete) {
      return _buildResultScreen();
    }

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
          widget.quiz.title,
          style: TextStyle(
            color: RemediaColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: RemediaColors.mutedGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
              style: TextStyle(
                color: RemediaColors.mutedGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                backgroundColor: RemediaColors.warmBeige,
                valueColor: AlwaysStoppedAnimation<Color>(RemediaColors.mutedGreen),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      _currentQuestion.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuestion.question,
                    style: TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Answer options
                  ...List.generate(
                    _currentQuestion.options.length,
                    (index) => _buildAnswerOption(index),
                  ),

                  // Explanation (shown after answering)
                  if (_hasAnswered) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RemediaColors.mutedGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: RemediaColors.mutedGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Did you know?',
                                style: TextStyle(
                                  color: RemediaColors.mutedGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentQuestion.explanation,
                            style: TextStyle(
                              color: RemediaColors.textDark,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Next button
          if (_hasAnswered)
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: RemediaColors.cardSand,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RemediaColors.mutedGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex < widget.quiz.questions.length - 1
                        ? 'Next Question'
                        : 'See Results',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == _currentQuestion.correctAnswerIndex;

    Color backgroundColor = RemediaColors.cardSand;
    Color borderColor = Colors.transparent;
    Color textColor = RemediaColors.textDark;

    if (_hasAnswered) {
      if (isCorrect) {
        backgroundColor = RemediaColors.successGreen.withValues(alpha: 0.2);
        borderColor = RemediaColors.successGreen;
        textColor = RemediaColors.successGreen;
      } else if (isSelected && !isCorrect) {
        backgroundColor = RemediaColors.terraCotta.withValues(alpha: 0.2);
        borderColor = RemediaColors.terraCotta;
        textColor = RemediaColors.terraCotta;
      }
    } else if (isSelected) {
      borderColor = RemediaColors.mutedGreen;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _hasAnswered && isCorrect
                    ? RemediaColors.successGreen
                    : (_hasAnswered && isSelected && !isCorrect)
                        ? RemediaColors.terraCotta
                        : RemediaColors.warmBeige,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _hasAnswered
                    ? Icon(
                        isCorrect ? Icons.check : (isSelected ? Icons.close : null),
                        color: Colors.white,
                        size: 18,
                      )
                    : Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          color: RemediaColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentQuestion.options[index],
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / widget.quiz.questions.length * 100).round();
    String message;
    String emoji;

    if (percentage >= 80) {
      message = 'Amazing! You\'re a wellness expert!';
      emoji = '🏆';
    } else if (percentage >= 60) {
      message = 'Great job! You know your stuff!';
      emoji = '🌟';
    } else if (percentage >= 40) {
      message = 'Good effort! Keep learning!';
      emoji = '📚';
    } else {
      message = 'Keep exploring! You\'ll get there!';
      emoji = '🌱';
    }

    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              Text(
                'Quiz Complete!',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: RemediaColors.cardSand,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$_score',
                            style: TextStyle(
                              color: RemediaColors.mutedGreen,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '/${widget.quiz.questions.length}',
                            style: TextStyle(
                              color: RemediaColors.textMuted,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _score / widget.quiz.questions.length,
                        backgroundColor: RemediaColors.warmBeige,
                        valueColor: AlwaysStoppedAnimation<Color>(RemediaColors.mutedGreen),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percentage% correct',
                      style: TextStyle(
                        color: RemediaColors.mutedGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RemediaColors.mutedGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Quizzes',
                    style: TextStyle(
                      color: RemediaColors.mutedGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
