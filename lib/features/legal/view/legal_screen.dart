import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';

/// One section of a legal document.
class LegalSection {
  const LegalSection(this.heading, this.body);
  final String heading;
  final String body;
}

/// A legal document (Terms / Privacy) rendered by [LegalScreen].
class LegalDoc {
  const LegalDoc({
    required this.title,
    required this.updated,
    required this.intro,
    required this.sections,
  });
  final String title;
  final String updated;
  final String intro;
  final List<LegalSection> sections;
}

/// Renders a [LegalDoc] (Terms of Service / Privacy Policy).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                  ),
                  Expanded(child: Text(doc.title, style: AppTypography.ui(18, weight: FontWeight.w800))),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Last updated: ${doc.updated}',
                  style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              Text(doc.intro, style: AppTypography.ui(14, color: AppColors.ink2, weight: FontWeight.w500, height: 1.5)),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < doc.sections.length; i++) ...[
                Text('${i + 1}. ${doc.sections[i].heading}',
                    style: AppTypography.ui(15, weight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(doc.sections[i].body,
                    style: AppTypography.ui(14, color: AppColors.ink2, weight: FontWeight.w500, height: 1.5)),
                const SizedBox(height: AppSpacing.lg),
              ],
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadii.cardRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact', style: AppTypography.ui(13, color: AppColors.primaryDeep, weight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    SelectableText('Email: umarahadusmani@gmail.com\nWhatsApp: +92 333 4739757',
                        style: AppTypography.ui(13, color: AppColors.ink2, weight: FontWeight.w600, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

const String _kContact =
    'Questions? Email umarahadusmani@gmail.com or message us on WhatsApp at +92 333 4739757.';

const LegalDoc kTermsDoc = LegalDoc(
  title: 'Terms of Service',
  updated: '17 June 2026',
  intro:
      'Welcome to Taskko ("we", "us", "our"). These Terms of Service ("Terms") govern your use '
      'of the Taskko mobile app and related services. By creating an account or using Taskko, you '
      'agree to these Terms. If you do not agree, please do not use the app.',
  sections: [
    LegalSection('Who can use Taskko',
        'Taskko is built for students and lifelong learners. You must be at least 16 years old (or '
        'have permission from a parent or guardian) to create an account, and you agree to provide '
        'accurate information when you sign up.'),
    LegalSection('Your account',
        'You are responsible for keeping your login details secure and for all activity under your '
        'account. Use a strong password, do not share your credentials, and tell us right away if you '
        'think your account has been compromised. One person, one account.'),
    LegalSection('What Taskko does',
        'Taskko helps you turn big goals into small, doable tasks using AI, plus quizzes, focus '
        'sessions, streaks, points and badges to keep you motivated. Taskko is a study aid — it is '
        'not a substitute for your own judgement, your instructors, or professional advice.'),
    LegalSection('AI-generated content',
        'Plans, quizzes, schedules and chat replies are generated by AI (Google Gemini) and may '
        'sometimes be inaccurate, incomplete or out of date. Always review AI output before relying '
        'on it, and verify important facts yourself. You are responsible for how you use what Taskko '
        'produces.'),
    LegalSection('Academic integrity',
        'Use Taskko to learn and organise your work — not to break your school or university rules. '
        'Do not use AI output to cheat, plagiarise, or present work as your own where that is not '
        'allowed. Always follow your institution\'s academic-integrity policies.'),
    LegalSection('Acceptable use',
        'You agree NOT to: break the law or others\' rights; upload harmful, hateful or illegal '
        'content; attempt to hack, overload, reverse-engineer or scrape the service; or misuse the AI '
        'features to generate abusive or unsafe content.'),
    LegalSection('Your content',
        'You keep ownership of the goals, tasks and messages you create. You grant us a limited '
        'licence to store and process that content (including sending it to our AI provider) only to '
        'operate and improve Taskko for you.'),
    LegalSection('Service availability',
        'Taskko is provided "as is" and "as available". This is an evolving student project; features '
        'may change, pause or be removed, and occasional downtime can happen. We do not guarantee the '
        'service will always be available or error-free.'),
    LegalSection('Ending your use',
        'You can stop using Taskko and delete your account at any time from Profile → Edit profile → '
        'Delete account. We may suspend or close accounts that break these Terms or put the service or '
        'other users at risk.'),
    LegalSection('Limitation of liability',
        'To the maximum extent allowed by law, Taskko and its maker are not liable for any indirect, '
        'incidental or consequential losses — including missed deadlines, exam results, lost data or '
        'academic outcomes — arising from your use of the app. Taskko is a productivity aid, and your '
        'results depend on you.'),
    LegalSection('Changes to these Terms',
        'We may update these Terms as Taskko grows. If we make material changes we will update the '
        'date above and, where appropriate, notify you in-app. Continuing to use Taskko after changes '
        'means you accept the updated Terms.'),
    LegalSection('Contact', _kContact),
  ],
);

const LegalDoc kPrivacyDoc = LegalDoc(
  title: 'Privacy Policy',
  updated: '17 June 2026',
  intro:
      'This Privacy Policy explains what information Taskko collects, how we use it, and the choices '
      'and rights you have. By using Taskko, you agree to this policy.',
  sections: [
    LegalSection('Who we are',
        'Taskko is a student productivity app. For any privacy questions, contact us at '
        'umarahadusmani@gmail.com or WhatsApp +92 333 4739757.'),
    LegalSection('Information we collect',
        'Account details: your name and email address. Your activity: goals, tasks, moods, points, '
        'streaks, focus sessions, quizzes, and your chat conversations with Tako (our AI buddy). '
        'Technical data: basic app/usage analytics and crash reports that help us fix problems.'),
    LegalSection('How we use your information',
        'To provide and personalise the app (build your plans, track your streaks and points), to '
        'power the AI features, to keep the app secure, and to diagnose crashes and improve Taskko. '
        'We do not sell your personal data, ever.'),
    LegalSection('AI processing',
        'When you use AI features, the text you enter (such as a goal or a message) is sent securely '
        'to our backend, which calls Google\'s Gemini API to generate a response. We do not use your '
        'content to train our own models. Google processes the request under its own terms.'),
    LegalSection('Where your data is stored',
        'Your data is stored using Google Firebase (Authentication and Cloud Firestore) and processed '
        'by our backend hosted on Vercel. Data is encrypted in transit, and security rules restrict '
        'access so you can only read and write your own data.'),
    LegalSection('Who we share data with',
        'Only the service providers needed to run Taskko — Google (Firebase, Gemini) and Vercel. We '
        'do not sell or rent your data, and we do not share it for advertising.'),
    LegalSection('Your rights and choices',
        'You can view and edit your profile, change your email and password, and export a copy of '
        'your data (Profile → Download my data). You can permanently delete your account and data at '
        'any time (Profile → Edit profile → Delete account). If you are covered by data-protection '
        'laws such as the GDPR, these include your rights to access, correct, export and erase your '
        'data.'),
    LegalSection('Data retention',
        'We keep your data while your account is active. When you delete your account, your '
        'authentication record and profile are removed, and associated content is deleted on a '
        'best-effort basis shortly after.'),
    LegalSection('Children\'s privacy',
        'Taskko is not directed at children under 16. We do not knowingly collect data from anyone '
        'under 16; if you believe a child has provided us data, contact us and we will remove it.'),
    LegalSection('Analytics & crash reporting',
        'We use Firebase Analytics and Crashlytics to understand usage trends and detect crashes, '
        'which helps us improve stability and features.'),
    LegalSection('Changes to this policy',
        'We may update this policy as the app changes. We will update the date above and notify you '
        'in-app for material changes.'),
    LegalSection('Contact', _kContact),
  ],
);
