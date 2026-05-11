import 'package:flutter/material.dart';

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

final List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    icon: Icons.credit_card_rounded,
    title: 'Track All Your Cards',
    description:
        'Keep all your payment cards organized in one secure place. Add nicknames and see them at a glance.',
  ),
  OnboardingItem(
    icon: Icons.notifications_none_rounded,
    title: 'Never Miss a Payment',
    description:
        'Get timely reminders for upcoming subscription renewals. Stay on top of your recurring payments.',
  ),
  OnboardingItem(
    icon: Icons.insert_chart_outlined_rounded,
    title: 'Understand Your Spending',
    description:
        'Visualize your subscription expenses with clear charts and insights. Make informed decisions.',
  ),
  OnboardingItem(
    icon: Icons.shield_outlined,
    title: 'Your Data, Your Control',
    description:
        'We help you track and organize. Your financial information stays safe and private.',
  ),
];
