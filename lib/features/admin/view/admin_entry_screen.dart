import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../widgets/secondary_button.dart';
import '../../_placeholder/placeholder_body.dart';

/// In-app entry point shown to admin users (SRS FR-3.7, FR-11.1). The real
/// admin console is the separate React app on Vercel (M8); this just explains
/// that and offers a way back into the student app.
class AdminEntryScreen extends StatelessWidget {
  const AdminEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: PlaceholderBody(
            title: 'Admin portal',
            milestone: 'M8 · FR-11 · React on Vercel',
            actions: [
              SecondaryButton(label: 'Back to student app', onPressed: () => context.go('/home')),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
