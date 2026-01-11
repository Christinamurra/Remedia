import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String label;
  final IconData icon;

  const Goal({
    required this.id,
    required this.label,
    required this.icon,
  });
}

const List<Goal> predefinedGoals = [
  Goal(id: 'clear_skin', label: 'Get clear skin', icon: Icons.face),
  Goal(id: 'lose_weight', label: 'Lose weight', icon: Icons.fitness_center),
  Goal(id: 'gain_energy', label: 'Gain energy', icon: Icons.bolt),
  Goal(id: 'build_muscle', label: 'Build muscle', icon: Icons.sports_gymnastics),
  Goal(id: 'sleep_better', label: 'Sleep better', icon: Icons.bedtime),
  Goal(id: 'reduce_inflammation', label: 'Reduce inflammation', icon: Icons.healing),
  Goal(id: 'improve_digestion', label: 'Improve digestion', icon: Icons.restaurant),
  Goal(id: 'balance_hormones', label: 'Balance hormones', icon: Icons.balance),
  Goal(id: 'strengthen_immunity', label: 'Strengthen immunity', icon: Icons.shield),
  Goal(id: 'mental_clarity', label: 'Mental clarity', icon: Icons.psychology),
];
