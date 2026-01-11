class Expert {
  final String id;
  final String name;
  final String credentials;
  final String philosophy;
  final String imageUrl;
  final List<String> keyFoods;

  const Expert({
    required this.id,
    required this.name,
    required this.credentials,
    required this.philosophy,
    required this.imageUrl,
    required this.keyFoods,
  });
}

final List<Expert> sampleExperts = [
  Expert(
    id: 'brian-clement',
    name: 'Brian Clement',
    credentials: 'Director of Hippocrates Health Institute',
    philosophy:
        'Living foods and wheatgrass therapy heal the body at a cellular level. Raw, enzyme-rich foods restore vitality and reverse disease by flooding the body with life force energy.',
    imageUrl: 'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=400',
    keyFoods: [
      'Wheatgrass',
      'Sprouts',
      'Raw vegetables',
      'Fermented foods',
      'Green juices',
      'Sea vegetables',
      'Sunflower greens',
      'Buckwheat greens',
    ],
  ),
  Expert(
    id: 'medical-medium',
    name: 'Anthony William',
    credentials: 'Medical Medium, New York Times Best-Selling Author',
    philosophy:
        'Chronic illness stems from hidden pathogens and heavy metals. Healing comes through specific fruits, vegetables, and herbs that detoxify and restore the body\'s natural balance.',
    imageUrl: 'https://images.unsplash.com/photo-1622597467836-f3285f2131b8?w=400',
    keyFoods: [
      'Celery juice',
      'Wild blueberries',
      'Spirulina',
      'Barley grass juice powder',
      'Atlantic dulse',
      'Cilantro',
      'Lemon water',
      'Papaya',
    ],
  ),
  Expert(
    id: 'dr-greger',
    name: 'Dr. Michael Greger',
    credentials: 'Physician, Founder of NutritionFacts.org',
    philosophy:
        'A whole food, plant-based diet backed by peer-reviewed science is the most powerful tool for preventing and reversing chronic disease. The Daily Dozen provides optimal nutrition.',
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
    keyFoods: [
      'Beans & legumes',
      'Berries',
      'Cruciferous vegetables',
      'Greens',
      'Flaxseeds',
      'Nuts',
      'Whole grains',
      'Turmeric',
    ],
  ),
];
