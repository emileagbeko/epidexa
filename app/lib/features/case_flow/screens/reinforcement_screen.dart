import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/epidexa_button.dart';
import '../../../shared/widgets/epidexa_scaffold.dart';
import '../providers/active_case_provider.dart';
import '../../case_flow/providers/case_flow_provider.dart';
import '../../case_flow/providers/case_repository_provider.dart';
import '../widgets/case_progress_header.dart';

class ReinforcementScreen extends ConsumerWidget {
  const ReinforcementScreen({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseFlowProvider(caseId));
    final clinicalCase = state.clinicalCase;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeCaseIdProvider.notifier).state = caseId;
      ref.read(currentPageContextProvider.notifier).state =
          'reviewing clinical learning insights for the \'${clinicalCase.title}\' case';
    });
    final attempt = state.attempt;
    final repo = ref.read(caseRepositoryProvider);

    final diagCorrect = attempt.diagnosisCorrect(clinicalCase.diagnosisOptions);
    final stepCorrect = attempt.nextStepCorrect(clinicalCase.nextStepOptions);

    final weakTags = <String>[];
    if (!diagCorrect || !stepCorrect) {
      weakTags.addAll(clinicalCase.conceptTags.take(2));
    }

    final nextCaseId = repo.getNextCaseId(caseId);

    return EpidexaScaffold(
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaseProgressHeader(step: CaseFlowStep.reinforcement, caseTitle: clinicalCase.title),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session insights', style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Text('Based on your answers for this case', style: AppTextStyles.caption),
                  const SizedBox(height: 24),

                  if (diagCorrect && stepCorrect) ...[
                    _InsightCard(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.correct,
                      title: 'Strong performance',
                      body: 'You correctly identified the diagnosis and appropriate management. '
                          'Keep building on this pattern recognition.',
                    ),
                  ] else ...[
                    if (!diagCorrect)
                      _InsightCard(
                        icon: Icons.visibility_outlined,
                        iconColor: AppColors.plum,
                        title: 'Revisit: differential diagnosis',
                        body: 'You chose an incorrect diagnosis for this case. '
                            'Focus on the distinguishing features — especially border definition '
                            'and distribution pattern.',
                      ),
                    if (!stepCorrect)
                      _InsightCard(
                        icon: Icons.medical_services_outlined,
                        iconColor: AppColors.plum,
                        title: 'Revisit: clinical management',
                        body: 'The management step was incorrect. '
                            'Review the first-line approach for '
                            '${clinicalCase.feedback.correctDiagnosis.toLowerCase()} '
                            'and when to escalate.',
                      ),
                  ],

                  if (weakTags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('AREAS TO REVIEW', style: AppTextStyles.clinicalNoteLabel),
                    const SizedBox(height: 10),
                    ...weakTags.map((tag) => _TagRow(tag: tag)),
                  ],

                  if (clinicalCase.specialtyNote != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.plumLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: AppColors.plum),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              clinicalCase.specialtyNote!,
                              style: AppTextStyles.caption.copyWith(color: AppColors.primaryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: nextCaseId != null
                ? EpidexaButton.primary(
                    label: 'Next case',
                    onPressed: () => context.go('/case/$nextCaseId/start'),
                  )
                : EpidexaButton.primary(
                    label: 'All cases complete',
                    enabled: false,
                    onPressed: null,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: EpidexaButton.secondary(
              label: 'Back to cases',
              onPressed: () => context.go('/'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subheading),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tag});

  final String tag;

  String get _displayLabel {
    return tag.replaceAll('-', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.plum,
            ),
          ),
          const SizedBox(width: 10),
          Text(_displayLabel, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
