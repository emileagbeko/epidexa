import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/clinical_case.dart';
import '../../../shared/widgets/epidexa_scaffold.dart';
import '../../ai_assistant/widgets/chat_sheet.dart';
import '../../case_flow/providers/active_case_provider.dart';
import '../../case_flow/providers/case_repository_provider.dart';
import '../widgets/case_card.dart';

class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.plum.withOpacity(0.08),
              AppColors.cyan.withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.plum.withOpacity(0.18)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.plum.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.plum,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.plum.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Assistant',
                      style: AppTextStyles.subheading
                          .copyWith(color: AppColors.primaryText)),
                  const SizedBox(height: 2),
                  Text(
                    'Ask clinical questions, explore diagnoses',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.plum,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Ask',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeCaseIdProvider.notifier).state = null;
      ref.read(currentPageContextProvider.notifier).state =
          'browsing the case library on the home screen';
    });
    final repo = ref.read(caseRepositoryProvider);
    final cases = repo.getAllCases();
    final featuredCase = cases.isNotEmpty ? cases.first : null;

    return EpidexaScaffold(
      showBack: false,
      title: 'Epidexa',
      useLogo: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.plumLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline_rounded,
                size: 18, color: AppColors.plum),
          ),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          // Greeting
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi there,',
                    style: AppTextStyles.heroTitle.copyWith(color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to sharpen your clinical eye?',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),

          // Hero card — Today's Case
          if (featuredCase != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _HeroCard(clinicalCase: featuredCase),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // AI Assistant card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AiAssistantCard(
                onTap: () {
                  final pageCtx = ref.read(currentPageContextProvider) ??
                      'browsing the case library';
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black26,
                    builder: (_) => ChatSheet(pageContext: pageCtx),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('ALL CASES', style: AppTextStyles.clinicalNoteLabel),
                  const Spacer(),
                  Text(
                    '${cases.length} available',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Case list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => CaseCard(
                  clinicalCase: cases[index],
                  index: index,
                ),
                childCount: cases.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.clinicalCase});

  final ClinicalCase clinicalCase;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/case/${clinicalCase.id}/start'),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colors.white.withOpacity(0.85)),
                    const SizedBox(width: 5),
                    Text(
                      "TODAY'S CASE",
                      style: AppTextStyles.heroMeta.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(clinicalCase.title, style: AppTextStyles.heroTitle),
              const SizedBox(height: 8),
              Text(
                clinicalCase.patientPresentation.length > 90
                    ? '${clinicalCase.patientPresentation.substring(0, 90)}...'
                    : clinicalCase.patientPresentation,
                style: AppTextStyles.heroBody,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _HeroMeta(
                    icon: Icons.schedule_outlined,
                    label: '~10 min',
                  ),
                  const SizedBox(width: 16),
                  _HeroMeta(
                    icon: Icons.star_border_rounded,
                    label: clinicalCase.difficulty.name[0].toUpperCase() +
                        clinicalCase.difficulty.name.substring(1),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Start Case',
                      style: AppTextStyles.buttonTextSecondary.copyWith(
                        color: AppColors.plum,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.heroMeta),
      ],
    );
  }
}
