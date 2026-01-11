class Protocol {
  final String id;
  final String title;
  final String expertId;
  final String description;
  final int durationDays; // 0 = ongoing lifestyle
  final List<String> steps;
  final List<String> foods;
  final List<String> benefits;
  final String? source;

  const Protocol({
    required this.id,
    required this.title,
    required this.expertId,
    required this.description,
    required this.durationDays,
    required this.steps,
    required this.foods,
    required this.benefits,
    this.source,
  });

  String get durationLabel {
    if (durationDays == 0) return 'Ongoing';
    if (durationDays == 1) return '1 day';
    return '$durationDays days';
  }
}

final List<Protocol> sampleProtocols = [
  // Medical Medium Protocols
  Protocol(
    id: 'celery-juice',
    title: 'Celery Juice Protocol',
    expertId: 'medical-medium',
    description:
        'Start each morning with 16oz of fresh celery juice on an empty stomach to restore hydrochloric acid, flush toxins, and heal the gut lining.',
    durationDays: 0,
    steps: [
      'Juice one large bunch of organic celery (yields ~16oz)',
      'Drink immediately on an empty stomach',
      'Wait 15-30 minutes before eating or drinking anything else',
      'For chronic conditions, work up to 32oz daily',
    ],
    foods: ['Organic celery'],
    benefits: [
      'Restores stomach acid production',
      'Flushes liver toxins',
      'Reduces bloating',
      'Clears skin conditions',
      'Improves digestion',
    ],
    source: 'Medical Medium: Celery Juice',
  ),
  Protocol(
    id: 'heavy-metal-detox',
    title: 'Heavy Metal Detox Smoothie',
    expertId: 'medical-medium',
    description:
        'A powerful daily smoothie combining five key ingredients that work synergistically to pull heavy metals from deep within tissues and safely escort them out of the body.',
    durationDays: 0,
    steps: [
      'Blend 2 cups wild blueberries (frozen is fine)',
      'Add 2 tsp barley grass juice powder',
      'Add 2 tsp spirulina',
      'Add 1 cup fresh cilantro',
      'Add 1 tsp Atlantic dulse',
      'Add 1 cup orange juice or water',
      'Blend until smooth and drink daily',
    ],
    foods: [
      'Wild blueberries',
      'Barley grass juice powder',
      'Spirulina',
      'Cilantro',
      'Atlantic dulse',
    ],
    benefits: [
      'Removes mercury, aluminum, lead, and other metals',
      'Clears brain fog',
      'Supports neurological health',
      'Reduces anxiety and depression',
      'Improves memory',
    ],
    source: 'Medical Medium: Life-Changing Foods',
  ),
  Protocol(
    id: 'mm-369-cleanse',
    title: '3:6:9 Cleanse',
    expertId: 'medical-medium',
    description:
        'A 9-day liver rescue cleanse divided into three phases that progressively deepens detoxification while flooding the body with healing foods.',
    durationDays: 9,
    steps: [
      'Days 1-3: Reduce fats, remove troublemaker foods, add lemon water and celery juice',
      'Days 4-6: Further reduce fats, add liver rescue smoothie, focus on raw foods',
      'Days 7-8: Liquid foods only - juices, smoothies, soups',
      'Day 9: Liver flush day with specific timed protocols',
    ],
    foods: [
      'Celery juice',
      'Lemon water',
      'Apples',
      'Cucumbers',
      'Spinach',
      'Dates',
      'Watermelon',
    ],
    benefits: [
      'Deep liver cleansing',
      'Eliminates stored toxins',
      'Weight loss',
      'Mental clarity',
      'Reduced inflammation',
    ],
    source: 'Medical Medium: Cleanse to Heal',
  ),

  // Brian Clement Protocols
  Protocol(
    id: 'living-foods',
    title: 'Living Foods Lifestyle',
    expertId: 'brian-clement',
    description:
        'Transform your health by transitioning to a diet of raw, enzyme-rich living foods including sprouts, greens, and fermented vegetables that provide maximum life force energy.',
    durationDays: 0,
    steps: [
      'Replace cooked foods with raw alternatives gradually',
      'Grow your own sprouts (sunflower, buckwheat, pea shoots)',
      'Include 2oz wheatgrass juice daily',
      'Eat large green salads with sprouts at each meal',
      'Add fermented vegetables for probiotics',
      'Eliminate all processed foods and sugar',
    ],
    foods: [
      'Sprouts',
      'Wheatgrass',
      'Raw vegetables',
      'Fermented foods',
      'Sea vegetables',
      'Green juices',
    ],
    benefits: [
      'Increased energy and vitality',
      'Cellular regeneration',
      'Stronger immune system',
      'Mental clarity',
      'Healthy weight',
    ],
    source: 'Food IS Medicine by Brian Clement',
  ),
  Protocol(
    id: 'wheatgrass-therapy',
    title: 'Wheatgrass Therapy',
    expertId: 'brian-clement',
    description:
        'Harness the concentrated nutrition of wheatgrass juice for deep cleansing, blood building, and cellular regeneration.',
    durationDays: 21,
    steps: [
      'Start with 1oz wheatgrass juice daily',
      'Gradually increase to 2-4oz over two weeks',
      'Drink on an empty stomach, 30 min before meals',
      'Use as implant for deeper detoxification (optional)',
      'Grow fresh wheatgrass at home for maximum potency',
    ],
    foods: ['Fresh wheatgrass juice'],
    benefits: [
      'Builds red blood cells',
      'Detoxifies the liver',
      'Alkalizes the body',
      'Provides concentrated chlorophyll',
      'Boosts oxygen levels',
    ],
    source: 'Hippocrates Health Institute',
  ),

  // Dr. Greger Protocols
  Protocol(
    id: 'daily-dozen',
    title: 'Daily Dozen Checklist',
    expertId: 'dr-greger',
    description:
        'A science-based checklist of foods to incorporate daily for optimal health, disease prevention, and longevity based on the latest nutrition research.',
    durationDays: 0,
    steps: [
      'Beans: 3 servings (legumes, lentils, hummus)',
      'Berries: 1 serving (any berries)',
      'Other fruits: 3 servings',
      'Cruciferous: 1 serving (broccoli, cabbage, kale)',
      'Greens: 2 servings',
      'Other vegetables: 2 servings',
      'Flaxseeds: 1 tablespoon ground',
      'Nuts: 1 serving',
      'Spices: 1/4 tsp turmeric + any others',
      'Whole grains: 3 servings',
      'Beverages: 5 glasses water or tea',
      'Exercise: 90 min moderate or 40 min vigorous',
    ],
    foods: [
      'Beans',
      'Berries',
      'Cruciferous vegetables',
      'Greens',
      'Flaxseeds',
      'Nuts',
      'Whole grains',
      'Turmeric',
    ],
    benefits: [
      'Reduces heart disease risk',
      'Lowers cancer risk',
      'Supports healthy weight',
      'Improves gut microbiome',
      'Increases longevity',
    ],
    source: 'How Not to Die by Dr. Michael Greger',
  ),
  Protocol(
    id: 'anti-inflammatory',
    title: 'Anti-Inflammatory Protocol',
    expertId: 'dr-greger',
    description:
        'Reduce chronic inflammation through strategic food choices backed by clinical research, focusing on the most potent anti-inflammatory plant foods.',
    durationDays: 0,
    steps: [
      'Include 1/4 tsp turmeric with black pepper daily',
      'Eat berries daily (especially wild blueberries)',
      'Add ground flaxseeds to meals',
      'Drink hibiscus or green tea',
      'Include ginger in cooking or tea',
      'Eliminate inflammatory foods (processed, fried, sugar)',
      'Emphasize leafy greens at every meal',
    ],
    foods: [
      'Turmeric',
      'Berries',
      'Flaxseeds',
      'Ginger',
      'Leafy greens',
      'Green tea',
    ],
    benefits: [
      'Reduced joint pain',
      'Lower CRP markers',
      'Better brain health',
      'Improved recovery',
      'Disease prevention',
    ],
    source: 'How Not to Die by Dr. Michael Greger',
  ),
];
