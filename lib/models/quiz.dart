enum QuizCategory { herbs, vitamins, supplements, adaptogens, general }

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final QuizCategory category;
  final String emoji;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
    required this.emoji,
  });
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final String emoji;
  final QuizCategory category;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.emoji,
    required this.category,
  });
}

// Sample Quiz Questions
const List<QuizQuestion> herbQuestions = [
  QuizQuestion(
    id: 'herb1',
    question: 'Which herb is known as "nature\'s Xanax" for its calming effects?',
    options: ['Oregano', 'Lemon Balm', 'Basil', 'Rosemary'],
    correctAnswerIndex: 1,
    explanation: 'Lemon Balm has been used for centuries to reduce anxiety and promote calmness. It works by increasing GABA in the brain.',
    category: QuizCategory.herbs,
    emoji: '🍋',
  ),
  QuizQuestion(
    id: 'herb2',
    question: 'What is Ashwagandha primarily used for?',
    options: ['Boosting energy', 'Reducing stress & cortisol', 'Weight loss', 'Improving vision'],
    correctAnswerIndex: 1,
    explanation: 'Ashwagandha is an adaptogen that helps the body manage stress by lowering cortisol levels. It\'s been used in Ayurvedic medicine for over 3,000 years.',
    category: QuizCategory.herbs,
    emoji: '🌿',
  ),
  QuizQuestion(
    id: 'herb3',
    question: 'Which herb is best known for soothing digestive issues?',
    options: ['Ginger', 'Lavender', 'Echinacea', 'St. John\'s Wort'],
    correctAnswerIndex: 0,
    explanation: 'Ginger is excellent for nausea, bloating, and digestive discomfort. It stimulates digestion and has anti-inflammatory properties.',
    category: QuizCategory.herbs,
    emoji: '🫚',
  ),
  QuizQuestion(
    id: 'herb4',
    question: 'Valerian root is most commonly used for:',
    options: ['Energy boost', 'Skin health', 'Sleep improvement', 'Heart health'],
    correctAnswerIndex: 2,
    explanation: 'Valerian root is a natural sedative that improves sleep quality without causing morning grogginess. It increases GABA levels in the brain.',
    category: QuizCategory.herbs,
    emoji: '🌙',
  ),
  QuizQuestion(
    id: 'herb5',
    question: 'What does "adaptogen" mean?',
    options: ['A type of vitamin', 'Herbs that help body adapt to stress', 'A digestive enzyme', 'An antioxidant'],
    correctAnswerIndex: 1,
    explanation: 'Adaptogens are herbs that help your body "adapt" to physical, chemical, and biological stress. Examples include Ashwagandha, Rhodiola, and Ginseng.',
    category: QuizCategory.herbs,
    emoji: '🌱',
  ),
];

const List<QuizQuestion> vitaminQuestions = [
  QuizQuestion(
    id: 'vit1',
    question: 'Which vitamin is known as the "sunshine vitamin"?',
    options: ['Vitamin A', 'Vitamin B12', 'Vitamin C', 'Vitamin D'],
    correctAnswerIndex: 3,
    explanation: 'Vitamin D is produced when your skin is exposed to sunlight. It\'s essential for bone health, immunity, and mood regulation.',
    category: QuizCategory.vitamins,
    emoji: '☀️',
  ),
  QuizQuestion(
    id: 'vit2',
    question: 'B12 deficiency is common in which group?',
    options: ['Athletes', 'Vegans & vegetarians', 'Children', 'People who exercise'],
    correctAnswerIndex: 1,
    explanation: 'B12 is mainly found in animal products, making vegans and vegetarians at higher risk for deficiency. Supplementation is often necessary.',
    category: QuizCategory.vitamins,
    emoji: '💊',
  ),
  QuizQuestion(
    id: 'vit3',
    question: 'What vitamin should be taken with Vitamin D3 for proper calcium absorption?',
    options: ['Vitamin A', 'Vitamin E', 'Vitamin K2', 'Vitamin B6'],
    correctAnswerIndex: 2,
    explanation: 'Vitamin K2 directs calcium to your bones and teeth instead of your arteries. Always pair D3 with K2 for optimal benefits.',
    category: QuizCategory.vitamins,
    emoji: '🦴',
  ),
  QuizQuestion(
    id: 'vit4',
    question: 'Which vitamin is a powerful antioxidant that boosts immune function?',
    options: ['Vitamin B1', 'Vitamin C', 'Vitamin K', 'Vitamin B6'],
    correctAnswerIndex: 1,
    explanation: 'Vitamin C is a potent antioxidant that supports immune function, collagen production, and helps the body absorb iron.',
    category: QuizCategory.vitamins,
    emoji: '🍊',
  ),
  QuizQuestion(
    id: 'vit5',
    question: 'What is the most common vitamin deficiency worldwide?',
    options: ['Vitamin A', 'Vitamin D', 'Vitamin C', 'Vitamin E'],
    correctAnswerIndex: 1,
    explanation: 'Vitamin D deficiency affects an estimated 1 billion people worldwide. Indoor lifestyles and sunscreen use contribute to this epidemic.',
    category: QuizCategory.vitamins,
    emoji: '🌍',
  ),
];

const List<QuizQuestion> supplementQuestions = [
  QuizQuestion(
    id: 'sup1',
    question: 'What is NAC (N-Acetyl Cysteine) a precursor to?',
    options: ['Serotonin', 'Glutathione', 'Melatonin', 'Dopamine'],
    correctAnswerIndex: 1,
    explanation: 'NAC is a precursor to glutathione, the body\'s master antioxidant. It supports liver health, mental clarity, and reduces anxiety.',
    category: QuizCategory.supplements,
    emoji: '✨',
  ),
  QuizQuestion(
    id: 'sup2',
    question: 'Which mineral is involved in over 300 enzymatic reactions in the body?',
    options: ['Zinc', 'Iron', 'Magnesium', 'Calcium'],
    correctAnswerIndex: 2,
    explanation: 'Magnesium is crucial for muscle function, nerve transmission, energy production, and sleep. Most people are deficient!',
    category: QuizCategory.supplements,
    emoji: '💜',
  ),
  QuizQuestion(
    id: 'sup3',
    question: 'What is glutathione often called?',
    options: ['The energy vitamin', 'The master antioxidant', 'The sleep hormone', 'The happy chemical'],
    correctAnswerIndex: 1,
    explanation: 'Glutathione is called the "master antioxidant" because it recycles other antioxidants and is essential for detoxification.',
    category: QuizCategory.supplements,
    emoji: '🛡️',
  ),
  QuizQuestion(
    id: 'sup4',
    question: 'Which form of magnesium is best for anxiety and sleep?',
    options: ['Magnesium Oxide', 'Magnesium Citrate', 'Magnesium Glycinate', 'Magnesium Sulfate'],
    correctAnswerIndex: 2,
    explanation: 'Magnesium Glycinate is the most absorbable and calming form. Glycine itself is calming, making this form ideal for anxiety and sleep.',
    category: QuizCategory.supplements,
    emoji: '😴',
  ),
  QuizQuestion(
    id: 'sup5',
    question: 'CoQ10 is especially important for which organ?',
    options: ['Liver', 'Heart', 'Kidneys', 'Lungs'],
    correctAnswerIndex: 1,
    explanation: 'CoQ10 is concentrated in the heart and provides energy for heart muscle cells. It\'s especially important if taking statin medications.',
    category: QuizCategory.supplements,
    emoji: '❤️',
  ),
  QuizQuestion(
    id: 'sup6',
    question: 'L-Theanine is naturally found in which beverage?',
    options: ['Coffee', 'Green tea', 'Orange juice', 'Milk'],
    correctAnswerIndex: 1,
    explanation: 'L-Theanine is an amino acid found in green tea that promotes relaxation without drowsiness. It\'s why tea feels calming despite having caffeine.',
    category: QuizCategory.supplements,
    emoji: '🍵',
  ),
  QuizQuestion(
    id: 'sup7',
    question: 'Which supplement helps repair the gut lining?',
    options: ['Vitamin C', 'L-Glutamine', 'Fish Oil', 'Zinc'],
    correctAnswerIndex: 1,
    explanation: 'L-Glutamine is the primary fuel source for intestinal cells and helps repair and maintain the gut lining.',
    category: QuizCategory.supplements,
    emoji: '🦠',
  ),
  QuizQuestion(
    id: 'sup8',
    question: 'Omega-3 fatty acids are best known for their:',
    options: ['Sugar-lowering effects', 'Anti-inflammatory properties', 'Protein content', 'Carbohydrate content'],
    correctAnswerIndex: 1,
    explanation: 'Omega-3s (EPA & DHA) are powerful anti-inflammatories that support brain, heart, and joint health.',
    category: QuizCategory.supplements,
    emoji: '🐟',
  ),
];

const List<QuizQuestion> adaptogenQuestions = [
  QuizQuestion(
    id: 'adapt1',
    question: 'Which mushroom is known for supporting brain health and nerve growth?',
    options: ['Reishi', 'Lion\'s Mane', 'Chaga', 'Shiitake'],
    correctAnswerIndex: 1,
    explanation: 'Lion\'s Mane stimulates Nerve Growth Factor (NGF) production, supporting brain health, memory, and focus.',
    category: QuizCategory.adaptogens,
    emoji: '🧠',
  ),
  QuizQuestion(
    id: 'adapt2',
    question: 'Rhodiola Rosea is best known for combating:',
    options: ['Insomnia', 'Fatigue', 'Inflammation', 'High blood pressure'],
    correctAnswerIndex: 1,
    explanation: 'Rhodiola is an adaptogen that fights fatigue, improves mental performance, and helps the body handle stress.',
    category: QuizCategory.adaptogens,
    emoji: '⚡',
  ),
  QuizQuestion(
    id: 'adapt3',
    question: 'Which mushroom is called the "mushroom of immortality"?',
    options: ['Lion\'s Mane', 'Cordyceps', 'Reishi', 'Turkey Tail'],
    correctAnswerIndex: 2,
    explanation: 'Reishi has been used in Traditional Chinese Medicine for over 2,000 years. It supports immunity, sleep, and longevity.',
    category: QuizCategory.adaptogens,
    emoji: '🍄',
  ),
  QuizQuestion(
    id: 'adapt4',
    question: 'Cordyceps mushrooms are traditionally used by athletes for:',
    options: ['Weight loss', 'Oxygen utilization & energy', 'Muscle building', 'Flexibility'],
    correctAnswerIndex: 1,
    explanation: 'Cordyceps improve how the body uses oxygen and boost ATP production, making them popular with athletes for endurance.',
    category: QuizCategory.adaptogens,
    emoji: '🏃',
  ),
  QuizQuestion(
    id: 'adapt5',
    question: 'Holy Basil (Tulsi) is revered in which traditional medicine system?',
    options: ['Chinese Medicine', 'Ayurveda', 'Greek Medicine', 'Native American'],
    correctAnswerIndex: 1,
    explanation: 'Holy Basil is sacred in Ayurvedic medicine, used for stress relief, blood sugar balance, and as an "elixir of life."',
    category: QuizCategory.adaptogens,
    emoji: '🌿',
  ),
];

// Pre-built quizzes
final List<Quiz> sampleQuizzes = [
  Quiz(
    id: 'quiz1',
    title: 'Herb Master',
    description: 'Test your knowledge of healing herbs and their traditional uses',
    questions: herbQuestions,
    emoji: '🌿',
    category: QuizCategory.herbs,
  ),
  Quiz(
    id: 'quiz2',
    title: 'Vitamin Expert',
    description: 'How well do you know your vitamins?',
    questions: vitaminQuestions,
    emoji: '💊',
    category: QuizCategory.vitamins,
  ),
  Quiz(
    id: 'quiz3',
    title: 'Supplement Scholar',
    description: 'Master the world of supplements - NAC, glutathione, and more!',
    questions: supplementQuestions,
    emoji: '✨',
    category: QuizCategory.supplements,
  ),
  Quiz(
    id: 'quiz4',
    title: 'Adaptogen Pro',
    description: 'Learn about powerful adaptogens and medicinal mushrooms',
    questions: adaptogenQuestions,
    emoji: '🍄',
    category: QuizCategory.adaptogens,
  ),
  Quiz(
    id: 'quiz5',
    title: 'Ultimate Wellness',
    description: 'The ultimate test - herbs, vitamins, supplements & adaptogens!',
    questions: [...herbQuestions, ...vitaminQuestions, ...supplementQuestions, ...adaptogenQuestions],
    emoji: '🏆',
    category: QuizCategory.general,
  ),
];
