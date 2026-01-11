enum ArticleCategory { gutHealth, bloodSugar, herbs, nervousSystem }

class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final ArticleCategory category;
  final String imageUrl;
  final int readTime; // in minutes
  final DateTime publishedDate;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.readTime,
    required this.publishedDate,
  });

  String get categoryLabel {
    switch (category) {
      case ArticleCategory.gutHealth:
        return 'Gut Health';
      case ArticleCategory.bloodSugar:
        return 'Blood Sugar';
      case ArticleCategory.herbs:
        return 'Herbs & Botanicals';
      case ArticleCategory.nervousSystem:
        return 'Nervous System';
    }
  }
}

// Sample data
final List<Article> sampleArticles = [
  Article(
    id: '1',
    title: 'Understanding Your Gut Microbiome',
    summary: 'Learn how the trillions of bacteria in your gut affect everything from digestion to mood.',
    content: '''
Your gut microbiome is a complex ecosystem of trillions of microorganisms living in your digestive tract. These tiny inhabitants play a crucial role in your overall health.

**What is the Gut Microbiome?**

The gut microbiome refers to all the microorganisms living in your intestines. A person has about 300 to 500 different species of bacteria in their digestive tract.

**Why Does It Matter?**

Your gut microbiome affects:
- Digestion and nutrient absorption
- Immune system function
- Mental health and mood
- Weight management
- Inflammation levels

**How to Support Your Gut**

1. Eat fermented foods like sauerkraut and kimchi
2. Consume prebiotic fiber from vegetables
3. Avoid processed foods and artificial sweeteners
4. Manage stress through mindfulness
5. Get adequate sleep

Start nurturing your gut today, and feel the difference in your whole body.
    ''',
    category: ArticleCategory.gutHealth,
    imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400',
    readTime: 5,
    publishedDate: DateTime(2024, 1, 15),
  ),
  Article(
    id: '2',
    title: 'Natural Ways to Balance Blood Sugar',
    summary: 'Discover gentle, natural approaches to maintaining stable blood sugar throughout the day.',
    content: '''
Blood sugar balance is key to sustained energy, clear thinking, and long-term health. Here's how to support your body naturally.

**Why Blood Sugar Matters**

When blood sugar spikes and crashes, you experience:
- Energy crashes
- Brain fog
- Mood swings
- Increased cravings
- Long-term health risks

**Natural Balancing Strategies**

1. **Eat protein with every meal** - Protein slows glucose absorption
2. **Prioritize fiber** - Vegetables, legumes, and whole grains
3. **Apple cider vinegar** - 1 tbsp before meals can help
4. **Movement after meals** - A 10-minute walk works wonders
5. **Cinnamon** - Add to smoothies and oatmeal
6. **Stay hydrated** - Dehydration affects blood sugar

**Best Foods for Balance**

- Leafy greens
- Nuts and seeds
- Legumes
- Berries (low glycemic fruits)
- Fatty fish
    ''',
    category: ArticleCategory.bloodSugar,
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
    readTime: 4,
    publishedDate: DateTime(2024, 2, 1),
  ),
  Article(
    id: '3',
    title: 'Lemon Balm: Nature\'s Calming Herb',
    summary: 'Explore the gentle power of lemon balm for stress relief, better sleep, and digestive support.',
    content: '''
Lemon balm (Melissa officinalis) has been used for over 2,000 years to calm the mind and soothe the body.

**Benefits of Lemon Balm**

- **Reduces anxiety** - Calms the nervous system naturally
- **Improves sleep** - Promotes restful, deep sleep
- **Aids digestion** - Soothes stomach discomfort
- **Supports focus** - Calm alertness without drowsiness
- **Antiviral properties** - Supports immune function

**How to Use Lemon Balm**

1. **Tea** - Steep 1-2 tsp dried leaves for 10 minutes
2. **Tincture** - 30-60 drops as needed
3. **Fresh leaves** - Add to salads or water
4. **Essential oil** - Diffuse for aromatherapy

**When to Take It**

- Before bed for sleep support
- During stressful periods
- After meals for digestion
- During afternoon slumps

Lemon balm is gentle enough for daily use and safe for most people.
    ''',
    category: ArticleCategory.herbs,
    imageUrl: 'https://images.unsplash.com/photo-1515023115689-589c33041d3c?w=400',
    readTime: 4,
    publishedDate: DateTime(2024, 2, 20),
  ),
  Article(
    id: '4',
    title: 'Calming the Nervous System with Food',
    summary: 'How your diet directly impacts your stress response and what to eat for a calmer mind.',
    content: '''
Your nervous system responds directly to what you eat. Learn how to nourish yourself into a calmer state.

**The Gut-Brain Connection**

Your gut and brain communicate constantly through the vagus nerve. What you eat affects your mood, stress levels, and ability to relax.

**Calming Foods**

1. **Magnesium-rich foods** - Dark leafy greens, pumpkin seeds, dark chocolate
2. **Omega-3 fatty acids** - Wild salmon, sardines, walnuts
3. **Complex carbohydrates** - Sweet potatoes, oats, quinoa
4. **Fermented foods** - Kimchi, sauerkraut, kefir
5. **Herbal teas** - Chamomile, lavender, passionflower

**Foods to Limit**

- Caffeine (especially after noon)
- Refined sugar
- Alcohol
- Processed foods
- Artificial additives

**A Calming Day of Eating**

- Morning: Warm lemon water, then oatmeal with berries
- Lunch: Big salad with salmon and pumpkin seeds
- Afternoon: Chamomile tea and dark chocolate
- Dinner: Roasted vegetables with quinoa
    ''',
    category: ArticleCategory.nervousSystem,
    imageUrl: 'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=400',
    readTime: 5,
    publishedDate: DateTime(2024, 3, 5),
  ),
  Article(
    id: '5',
    title: 'The Healing Power of Ginger',
    summary: 'From nausea relief to inflammation reduction, discover why ginger is a wellness staple.',
    content: '''
Ginger (Zingiber officinale) is one of the most versatile healing roots in natural medicine.

**Proven Benefits**

- **Settles nausea** - Morning sickness, motion sickness, digestive upset
- **Reduces inflammation** - Joint pain, muscle soreness
- **Aids digestion** - Stimulates digestive enzymes
- **Supports immunity** - Antimicrobial properties
- **Warms circulation** - Improves blood flow

**Ways to Use Ginger**

1. **Fresh ginger tea** - Slice and simmer for 15 minutes
2. **Ginger shots** - Juice with lemon and cayenne
3. **In cooking** - Stir-fries, soups, dressings
4. **Ginger chews** - For travel and quick relief
5. **Powdered** - In smoothies and golden milk

**Daily Ginger Ritual**

Start each morning with warm water, fresh ginger, and lemon. This simple practice wakes up your digestion and sets a healthy tone for the day.
    ''',
    category: ArticleCategory.herbs,
    imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400',
    readTime: 4,
    publishedDate: DateTime(2024, 3, 15),
  ),
];
