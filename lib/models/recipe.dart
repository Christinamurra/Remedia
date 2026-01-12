enum RecipeCategory {
  smoothie,
  juice,
  shot,
  bowl,
  salad,
  soup,
  mainDish,
  snack,
  dessert,
  dressing,
  dip,
}

enum DifficultyLevel {
  easy,
  medium,
  advanced,
}

class Ingredient {
  final String name;
  final String amount;
  final String? note; // e.g., "frozen", "roughly chopped"

  const Ingredient({
    required this.name,
    required this.amount,
    this.note,
  });
}

class NutritionInfo {
  final int calories;
  final int protein; // grams
  final int carbs; // grams
  final int fiber; // grams
  final int sugar; // grams
  final int fat; // grams

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fiber,
    required this.sugar,
    required this.fat,
  });
}

class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> tags;
  final String description;
  final RecipeCategory category;
  final int prepTime; // in minutes
  final int servings;
  final DifficultyLevel difficulty;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final NutritionInfo nutrition;
  final bool isFavorite;
  final bool isPremium;
  final String? expertId;
  final String? expertNote;
  final String? tip; // optional chef tip

  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.tags,
    required this.description,
    required this.category,
    required this.prepTime,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    this.isFavorite = false,
    this.isPremium = false,
    this.expertId,
    this.expertNote,
    this.tip,
  });

  // Legacy getter for backwards compatibility
  int get calories => nutrition.calories;

  Recipe copyWith({
    String? id,
    String? title,
    String? imageUrl,
    List<String>? tags,
    String? description,
    RecipeCategory? category,
    int? prepTime,
    int? servings,
    DifficultyLevel? difficulty,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    NutritionInfo? nutrition,
    bool? isFavorite,
    bool? isPremium,
    String? expertId,
    String? expertNote,
    String? tip,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutrition: nutrition ?? this.nutrition,
      isFavorite: isFavorite ?? this.isFavorite,
      isPremium: isPremium ?? this.isPremium,
      expertId: expertId ?? this.expertId,
      expertNote: expertNote ?? this.expertNote,
      tip: tip ?? this.tip,
    );
  }
}

// Sample data - Updated with full recipe details
final List<Recipe> sampleRecipes = [
  const Recipe(
    id: '1',
    title: 'Green Goddess Smoothie Bowl',
    imageUrl: 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400',
    tags: ['Raw', 'Vegan', 'Gut Healing'],
    description: 'A vibrant blend of spinach, banana, and spirulina topped with fresh fruits and seeds.',
    category: RecipeCategory.bowl,
    prepTime: 10,
    servings: 1,
    difficulty: DifficultyLevel.easy,
    ingredients: [
      Ingredient(name: 'Spinach', amount: '2 cups', note: 'fresh'),
      Ingredient(name: 'Banana', amount: '1 large', note: 'frozen'),
      Ingredient(name: 'Spirulina powder', amount: '1 tsp'),
      Ingredient(name: 'Almond milk', amount: '1/2 cup', note: 'unsweetened'),
      Ingredient(name: 'Mixed berries', amount: '1/4 cup', note: 'for topping'),
      Ingredient(name: 'Hemp seeds', amount: '1 tbsp', note: 'for topping'),
      Ingredient(name: 'Chia seeds', amount: '1 tsp', note: 'for topping'),
    ],
    instructions: [
      'Add spinach, frozen banana, spirulina, and almond milk to a high-speed blender.',
      'Blend until thick and creamy, adding more milk if needed.',
      'Pour into a bowl and smooth the surface.',
      'Top with mixed berries, hemp seeds, and chia seeds.',
      'Serve immediately for best texture.',
    ],
    nutrition: NutritionInfo(calories: 320, protein: 12, carbs: 45, fiber: 9, sugar: 18, fat: 10),
    expertId: 'brian-clement',
    expertNote: 'Inspired by Hippocrates living foods principles',
    tip: 'Freeze your banana the night before for an extra thick, ice-cream-like texture.',
  ),
  const Recipe(
    id: '2',
    title: 'Lemon Ginger Immunity Shot',
    imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
    tags: ['Raw', 'Detox', 'Immunity'],
    description: 'A powerful immune-boosting shot with fresh lemon, ginger, and a touch of cayenne.',
    category: RecipeCategory.shot,
    prepTime: 5,
    servings: 2,
    difficulty: DifficultyLevel.easy,
    ingredients: [
      Ingredient(name: 'Lemon', amount: '1 large', note: 'juiced'),
      Ingredient(name: 'Fresh ginger', amount: '2 inches', note: 'peeled'),
      Ingredient(name: 'Cayenne pepper', amount: '1/8 tsp'),
      Ingredient(name: 'Raw honey or maple syrup', amount: '1 tsp', note: 'optional'),
    ],
    instructions: [
      'Juice the lemon into a small bowl.',
      'Grate or juice the fresh ginger and add to the lemon juice.',
      'Add cayenne pepper and sweetener if using.',
      'Stir well and divide into shot glasses.',
      'Drink immediately for maximum potency.',
    ],
    nutrition: NutritionInfo(calories: 25, protein: 0, carbs: 6, fiber: 0, sugar: 2, fat: 0),
    tip: 'Take this shot first thing in the morning before eating for best absorption.',
  ),
  const Recipe(
    id: '3',
    title: 'Raw Zucchini Noodles with Pesto',
    imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
    tags: ['Raw', 'Low Sugar', 'Vegan'],
    description: 'Fresh spiralized zucchini with homemade basil pesto and cherry tomatoes.',
    category: RecipeCategory.mainDish,
    prepTime: 15,
    servings: 2,
    difficulty: DifficultyLevel.easy,
    ingredients: [
      Ingredient(name: 'Zucchini', amount: '3 medium'),
      Ingredient(name: 'Fresh basil', amount: '2 cups', note: 'packed'),
      Ingredient(name: 'Pine nuts', amount: '1/4 cup'),
      Ingredient(name: 'Garlic', amount: '2 cloves'),
      Ingredient(name: 'Lemon juice', amount: '2 tbsp'),
      Ingredient(name: 'Olive oil', amount: '1/4 cup', note: 'extra virgin'),
      Ingredient(name: 'Nutritional yeast', amount: '2 tbsp'),
      Ingredient(name: 'Cherry tomatoes', amount: '1 cup', note: 'halved'),
      Ingredient(name: 'Sea salt', amount: 'to taste'),
    ],
    instructions: [
      'Spiralize the zucchini into noodles and set aside in a large bowl.',
      'In a food processor, combine basil, pine nuts, garlic, lemon juice, and nutritional yeast.',
      'Process while slowly drizzling in olive oil until smooth.',
      'Season pesto with sea salt to taste.',
      'Toss zucchini noodles with pesto until well coated.',
      'Top with halved cherry tomatoes and serve immediately.',
    ],
    nutrition: NutritionInfo(calories: 280, protein: 8, carbs: 18, fiber: 5, sugar: 8, fat: 22),
    tip: 'Salt zucchini noodles lightly and let sit for 5 minutes, then pat dry to prevent watery pesto.',
  ),
  const Recipe(
    id: '4',
    title: 'Turmeric Golden Milk',
    imageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400',
    tags: ['Gut Healing', 'Anti-Inflammatory', 'Warming'],
    description: 'Warming coconut milk infused with turmeric, ginger, and black pepper for absorption.',
    category: RecipeCategory.smoothie,
    prepTime: 10,
    servings: 1,
    difficulty: DifficultyLevel.easy,
    ingredients: [
      Ingredient(name: 'Coconut milk', amount: '1 cup', note: 'full-fat'),
      Ingredient(name: 'Turmeric powder', amount: '1 tsp'),
      Ingredient(name: 'Fresh ginger', amount: '1/2 inch', note: 'grated'),
      Ingredient(name: 'Cinnamon', amount: '1/4 tsp'),
      Ingredient(name: 'Black pepper', amount: '1/8 tsp'),
      Ingredient(name: 'Maple syrup', amount: '1 tsp', note: 'optional'),
    ],
    instructions: [
      'Add coconut milk to a small saucepan over medium-low heat.',
      'Whisk in turmeric, grated ginger, cinnamon, and black pepper.',
      'Heat gently for 5 minutes, stirring frequently. Do not boil.',
      'Remove from heat and strain if desired.',
      'Add maple syrup if using and stir.',
      'Pour into a mug and enjoy warm.',
    ],
    nutrition: NutritionInfo(calories: 150, protein: 2, carbs: 8, fiber: 1, sugar: 4, fat: 14),
    expertId: 'dr-greger',
    expertNote: 'Dr. Greger recommends 1/4 tsp turmeric with black pepper daily',
    tip: 'Black pepper increases turmeric absorption by 2000% - never skip it!',
  ),
  const Recipe(
    id: '5',
    title: 'Celery Juice Cleanse',
    imageUrl: 'https://images.unsplash.com/photo-1622597467836-f3285f2131b8?w=400',
    tags: ['Raw', 'Detox', 'Gut Healing'],
    description: 'Pure celery juice - the ultimate morning cleanse for gut health and hydration.',
    category: RecipeCategory.juice,
    prepTime: 5,
    servings: 1,
    difficulty: DifficultyLevel.easy,
    ingredients: [
      Ingredient(name: 'Celery', amount: '1 large bunch', note: 'organic preferred'),
    ],
    instructions: [
      'Wash celery thoroughly and trim the base.',
      'Run celery through a juicer.',
      'If using a blender, blend celery with 1/4 cup water, then strain through a nut milk bag.',
      'Pour into a glass and drink immediately on an empty stomach.',
      'Wait 15-30 minutes before eating breakfast.',
    ],
    nutrition: NutritionInfo(calories: 40, protein: 2, carbs: 8, fiber: 0, sugar: 4, fat: 0),
    expertId: 'medical-medium',
    expertNote: 'Medical Medium protocol: drink 16oz on empty stomach each morning',
    tip: 'Use organic celery when possible and drink within 15 minutes of juicing.',
  ),
  const Recipe(
    id: '6',
    title: 'Rainbow Buddha Bowl',
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
    tags: ['Vegan', 'Low Sugar', 'Gut Healing'],
    description: 'A colorful bowl of roasted vegetables, quinoa, and tahini dressing.',
    category: RecipeCategory.bowl,
    prepTime: 25,
    servings: 2,
    difficulty: DifficultyLevel.medium,
    ingredients: [
      Ingredient(name: 'Quinoa', amount: '1 cup', note: 'cooked'),
      Ingredient(name: 'Sweet potato', amount: '1 medium', note: 'cubed and roasted'),
      Ingredient(name: 'Red cabbage', amount: '1 cup', note: 'shredded'),
      Ingredient(name: 'Carrots', amount: '2 medium', note: 'shredded'),
      Ingredient(name: 'Cucumber', amount: '1/2', note: 'sliced'),
      Ingredient(name: 'Avocado', amount: '1', note: 'sliced'),
      Ingredient(name: 'Chickpeas', amount: '1/2 cup', note: 'drained and rinsed'),
      Ingredient(name: 'Tahini', amount: '3 tbsp'),
      Ingredient(name: 'Lemon juice', amount: '2 tbsp'),
      Ingredient(name: 'Garlic', amount: '1 clove', note: 'minced'),
      Ingredient(name: 'Water', amount: '2 tbsp'),
    ],
    instructions: [
      'Cook quinoa according to package directions and let cool slightly.',
      'Roast sweet potato cubes at 400°F for 20 minutes until tender.',
      'Make dressing by whisking tahini, lemon juice, garlic, and water.',
      'Divide quinoa between two bowls.',
      'Arrange vegetables, chickpeas, and avocado in sections over quinoa.',
      'Drizzle with tahini dressing and serve.',
    ],
    nutrition: NutritionInfo(calories: 420, protein: 14, carbs: 52, fiber: 12, sugar: 8, fat: 18),
    tip: 'Prep vegetables ahead of time for quick weekday assembly.',
  ),
];
