import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';

class RemediesScreen extends StatefulWidget {
  const RemediesScreen({super.key});

  @override
  State<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends State<RemediesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm Remedia, your natural wellness guide. Tell me what's going on - whether it's digestive discomfort, low energy, stress, or cravings - and I'll suggest gentle, natural remedies to help you feel better.",
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Generate stub response
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _generateResponse(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  final Random _random = Random();

  // Expert citations to occasionally append to responses
  String? _maybeAddExpertCitation(String topic) {
    // ~30% chance to add a citation
    if (_random.nextDouble() > 0.3) return null;

    final citations = {
      'gut': [
        '\n\n📚 **Medical Medium tip:** Anthony William recommends 16oz of pure celery juice on an empty stomach each morning to restore hydrochloric acid and heal the gut lining.',
        '\n\n📚 **Dr. Greger note:** Research shows that a diverse plant-based diet with beans and fermented foods creates the healthiest gut microbiome.',
      ],
      'stress': [
        '\n\n📚 **Brian Clement insight:** At Hippocrates Health Institute, they emphasize that living foods and wheatgrass juice help calm the nervous system by providing bioavailable nutrients.',
      ],
      'energy': [
        '\n\n📚 **Dr. Greger recommendation:** The Daily Dozen checklist ensures you get energizing nutrients from whole plant foods daily.',
        '\n\n📚 **Brian Clement tip:** Fresh green juices and sprouts provide living enzymes that boost cellular energy naturally.',
      ],
      'detox': [
        '\n\n📚 **Medical Medium protocol:** The Heavy Metal Detox Smoothie with wild blueberries, spirulina, barley grass juice powder, cilantro, and Atlantic dulse works synergistically to remove toxins.',
      ],
      'immune': [
        '\n\n📚 **Dr. Greger research:** Cruciferous vegetables and berries are among the most powerful immune-supporting foods according to peer-reviewed studies.',
      ],
      'brain': [
        '\n\n📚 **Medical Medium insight:** Wild blueberries are called "brain food" for their ability to support cognitive function and remove heavy metals from brain tissue.',
        '\n\n📚 **Dr. Greger note:** Flaxseeds and leafy greens provide omega-3s and folate essential for brain health.',
      ],
    };

    final topicCitations = citations[topic];
    if (topicCitations == null) return null;
    return topicCitations[_random.nextInt(topicCitations.length)];
  }

  String _generateResponse(String input) {
    final lowercaseInput = input.toLowerCase();

    if (lowercaseInput.contains('stomach') ||
        lowercaseInput.contains('digest') ||
        lowercaseInput.contains('bloat') ||
        lowercaseInput.contains('gut')) {
      final citation = _maybeAddExpertCitation('gut');
      return '''For digestive support, I'd recommend:

💊 **L-Glutamine** - 5g daily. Repairs gut lining and supports intestinal health.

🦠 **Probiotics** - Multi-strain formula with 10+ billion CFU. Take on empty stomach or with meals.

🍎 **Digestive Enzymes** - Take with meals to help break down food and reduce bloating.

✨ **Zinc Carnosine** - 75mg twice daily. Soothes and heals stomach lining.

🫚 **Ginger Tea** - Steep fresh ginger in hot water for 10 minutes. Soothes the stomach and aids digestion.

🌿 **Peppermint Oil Capsules** - Enteric-coated for IBS and bloating relief.

🥒 **Celery Juice** - On an empty stomach in the morning, it helps restore stomach acid levels.

🍯 **Slippery Elm** - Coats and soothes the digestive tract. Mix powder in water before meals.

Start with L-glutamine and probiotics - they're foundational for gut health.${citation ?? ''}''';
    }

    if (lowercaseInput.contains('stress') ||
        lowercaseInput.contains('anxious') ||
        lowercaseInput.contains('anxiety') ||
        lowercaseInput.contains('calm')) {
      final citation = _maybeAddExpertCitation('stress');
      return '''For calming your nervous system:

💊 **NAC (N-Acetyl Cysteine)** - 600-1200mg daily. Supports glutathione production, reduces anxious thoughts and obsessive thinking. Take on an empty stomach.

✨ **Glutathione** - The master antioxidant. Supports detox and reduces oxidative stress linked to anxiety. Take 250-500mg sublingual or liposomal for best absorption.

🧠 **L-Theanine** - 100-200mg. Found in green tea, promotes calm focus without drowsiness.

🍋 **Lemon Balm Tea** - Nature's calming herb. Steep 1-2 tsp dried leaves for 10 minutes.

🌼 **Chamomile** - Gentle and soothing. Perfect before bed or during stressful moments.

💜 **Magnesium Glycinate** - 200-400mg before bed. The most calming form of magnesium for anxiety and sleep.

🌿 **Ashwagandha** - 300-600mg daily. Adaptogen that lowers cortisol and stress response.

Start with magnesium glycinate tonight and consider adding NAC in the morning.${citation ?? ''}''';
    }

    if (lowercaseInput.contains('energy') ||
        lowercaseInput.contains('tired') ||
        lowercaseInput.contains('fatigue') ||
        lowercaseInput.contains('exhausted')) {
      final citation = _maybeAddExpertCitation('energy');
      return '''For natural energy support:

💊 **B-Complex Vitamins** - Essential for energy production. Take in the morning with food.

🔋 **CoQ10** - 100-200mg. Powers your mitochondria, especially important if over 30 or on statins.

🍄 **Cordyceps** - Adaptogenic mushroom that boosts ATP production and oxygen utilization.

🌿 **Rhodiola Rosea** - 200-400mg. Fights fatigue and improves mental performance.

🥬 **Green Smoothie** - Spinach, banana, and a splash of coconut water. Nutrient-dense fuel.

🥒 **Celery Juice** - Morning celery juice provides clean, sustained energy.

🍵 **Matcha** - Gentle caffeine with L-theanine for calm alertness without the crash.

⚡ **Iron + Vitamin C** - If fatigued, get iron levels checked. Take with vitamin C for absorption.

Start with B-complex in the morning and consider adding CoQ10 for sustained energy.${citation ?? ''}''';
    }

    if (lowercaseInput.contains('sugar') ||
        lowercaseInput.contains('craving') ||
        lowercaseInput.contains('sweet')) {
      return '''For sugar cravings:

🍎 **Sweet fruits** - Dates, berries, or a banana can satisfy the craving naturally.

🥄 **Cinnamon** - Add to smoothies or oatmeal. Helps balance blood sugar.

💧 **Stay hydrated** - Sometimes cravings are actually thirst. Drink a full glass of water first.

🍫 **Dark chocolate** - A small piece (85%+) can satisfy without the sugar spike.

Try a date with almond butter when cravings hit. The healthy fats help stabilize blood sugar.''';
    }

    if (lowercaseInput.contains('sleep') ||
        lowercaseInput.contains('insomnia') ||
        lowercaseInput.contains('rest')) {
      return '''For better sleep:

💜 **Magnesium Glycinate** - 300-400mg before bed. The most absorbable form for sleep and relaxation.

🌙 **L-Tryptophan or 5-HTP** - Precursors to serotonin and melatonin. Take 30 min before bed.

🌿 **Valerian Root** - 300-600mg. Natural sedative that improves sleep quality.

🍄 **Reishi Mushroom** - Calming adaptogen that supports deep, restorative sleep.

✨ **Glycine** - 3g before bed. Amino acid that lowers body temperature and improves sleep quality.

🌼 **Chamomile & Lavender Tea** - Calming blend 1 hour before bed.

🍌 **Banana with Almond Butter** - Contains tryptophan and magnesium for relaxation.

🌿 **Lemon Balm** - Promotes restful, deep sleep without grogginess.

📵 **Evening routine** - Dim lights and avoid screens 1 hour before bed.

Start with magnesium glycinate tonight - it's gentle and effective for most people.''';
    }

    if (lowercaseInput.contains('vitamin') ||
        lowercaseInput.contains('supplement') ||
        lowercaseInput.contains('nac') ||
        lowercaseInput.contains('glutathione') ||
        lowercaseInput.contains('magnesium')) {
      return '''Here are foundational supplements for overall wellness:

✨ **Glutathione** - Master antioxidant. Supports detox, immune function, and skin health. 250-500mg liposomal.

💊 **NAC (N-Acetyl Cysteine)** - 600-1200mg. Boosts glutathione, supports liver, lungs, and mental clarity.

💜 **Magnesium Glycinate** - 300-400mg. Most people are deficient. Supports 300+ enzyme reactions.

☀️ **Vitamin D3 + K2** - 2000-5000 IU D3 with K2. Essential for immunity, mood, and bone health.

🐟 **Omega-3 Fish Oil** - 2-3g EPA/DHA. Anti-inflammatory, brain and heart support.

🧠 **B-Complex** - Essential for energy, mood, and nervous system function.

🦠 **Probiotics** - 10+ billion CFU multi-strain. Gut health is foundational.

🔋 **CoQ10** - 100-200mg. Cellular energy production, especially important with age.

Start with vitamin D, magnesium, and omega-3s - these are the most commonly deficient.''';
    }

    if (lowercaseInput.contains('immune') ||
        lowercaseInput.contains('sick') ||
        lowercaseInput.contains('cold') ||
        lowercaseInput.contains('flu')) {
      final citation = _maybeAddExpertCitation('immune');
      return '''For immune support:

🍊 **Vitamin C** - 1000-3000mg daily in divided doses. Increase when fighting illness.

🧄 **Elderberry** - Powerful antiviral. Take at first sign of illness.

🦪 **Zinc** - 15-30mg daily. Critical for immune function. Lozenges for sore throat.

☀️ **Vitamin D3** - 5000-10000 IU when sick. Most people are deficient.

✨ **Glutathione** - Supports immune cell function and detoxification.

🍄 **Mushroom Complex** - Lion's Mane, Reishi, Chaga, Turkey Tail boost immunity.

🧅 **Raw Garlic** - Natural antimicrobial. Crush and let sit 10 min before consuming.

🌿 **Oregano Oil** - Potent antimicrobial. Take in capsules or diluted drops.

At first sign of illness: high-dose vitamin C, zinc lozenges, and elderberry.${citation ?? ''}''';
    }

    if (lowercaseInput.contains('brain') ||
        lowercaseInput.contains('focus') ||
        lowercaseInput.contains('memory') ||
        lowercaseInput.contains('concentration')) {
      final citation = _maybeAddExpertCitation('brain');
      return '''For brain health and focus:

🧠 **Lion's Mane Mushroom** - 500-1000mg. Supports nerve growth factor and cognitive function.

💊 **NAC** - 600-1200mg. Supports glutathione in the brain, helps with focus and clarity.

🐟 **Omega-3 DHA** - Brain is 60% fat. DHA is essential for cognitive function.

🧠 **L-Theanine** - 100-200mg. Promotes alpha brain waves for calm focus.

☕ **Caffeine + L-Theanine** - Synergistic stack for focus without jitters.

🌿 **Bacopa Monnieri** - 300mg. Ayurvedic herb for memory and learning.

🔵 **Phosphatidylserine** - 100-300mg. Supports brain cell membranes and memory.

🍄 **Cordyceps** - Improves oxygen utilization and mental clarity.

Start with Lion's Mane and omega-3s for foundational brain support.${citation ?? ''}''';
    }

    // Default response
    return '''Thank you for sharing. Here are some general wellness suggestions:

🌿 **Start your morning** with warm lemon water to gently wake up your digestion.

🥗 **Eat the rainbow** - Include a variety of colorful vegetables in your meals.

💧 **Hydrate well** - Aim for half your body weight in ounces of water daily.

🧘 **Take a moment** - Even 5 minutes of deep breathing can reset your nervous system.

Tell me more specifically what you're experiencing - digestive issues, low energy, stress, cravings, or sleep troubles - and I can give you more targeted suggestions.''';
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: RemediaColors.mutedGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Remedia',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser ? RemediaColors.mutedGreen : RemediaColors.cardSand,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : RemediaColors.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: RemediaColors.textDark),
              decoration: InputDecoration(
                hintText: 'Tell Remedia what\'s going on...',
                hintStyle: TextStyle(color: RemediaColors.textLight),
                filled: true,
                fillColor: RemediaColors.warmBeige,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RemediaColors.mutedGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
