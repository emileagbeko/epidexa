import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/epidexa_button.dart';
import '../../../shared/widgets/epidexa_scaffold.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../ai_assistant/widgets/chat_sheet.dart';
import '../providers/active_case_provider.dart';
import '../providers/case_flow_provider.dart';
import '../widgets/case_progress_header.dart';
import '../widgets/clinical_image_viewer.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseFlowProvider(caseId));
    final clinicalCase = state.clinicalCase;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeCaseIdProvider.notifier).state = caseId;
      ref.read(currentPageContextProvider.notifier).state =
          'reviewing their performance and feedback for the \'${clinicalCase.title}\' case';
    });
    final attempt = state.attempt;
    final feedback = clinicalCase.feedback;

    final obsCorrect = attempt.observationCorrect(clinicalCase.observationOptions);
    final diagCorrect = attempt.diagnosisCorrect(clinicalCase.diagnosisOptions);
    final stepCorrect = attempt.nextStepCorrect(clinicalCase.nextStepOptions);

    final selectedDiagnosis = clinicalCase.diagnosisOptions
        .where((o) => o.id == attempt.selectedDiagnosisId)
        .map((o) => o.label)
        .firstOrNull;

    final selectedNextStep = clinicalCase.nextStepOptions
        .where((o) => o.id == attempt.selectedNextStepId)
        .map((o) => o.label)
        .firstOrNull;

    final correctDiagnosis = clinicalCase.diagnosisOptions
        .firstWhere((o) => o.isCorrect)
        .label;

    final correctNextStep = clinicalCase.nextStepOptions
        .firstWhere((o) => o.isCorrect)
        .label;

    return EpidexaScaffold(
      showBack: false,
      body: Column(
        children: [
          CaseProgressHeader(step: CaseFlowStep.feedback, caseTitle: clinicalCase.title),
          const Divider(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (clinicalCase.imagePath != null)
                  SliverToBoxAdapter(
                    child: ClinicalImageViewer(
                      caseId: caseId,
                      imagePath: clinicalCase.imagePath!,
                      height: 200,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Score row
                        Row(
                          children: [
                            _ResultBadge(label: 'Observation', correct: obsCorrect),
                            const SizedBox(width: 8),
                            _ResultBadge(label: 'Diagnosis', correct: diagCorrect),
                            const SizedBox(width: 8),
                            _ResultBadge(label: 'Next step', correct: stepCorrect),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Correct diagnosis
                        Text('DIAGNOSIS', style: AppTextStyles.clinicalNoteLabel),
                        const SizedBox(height: 6),
                        Text(feedback.correctDiagnosis, style: AppTextStyles.heading),
                        const SizedBox(height: 16),

                        // Explanation
                        Text(feedback.explanation, style: AppTextStyles.body),
                        const SizedBox(height: 24),

                        // Key visual cues
                        Text('KEY VISUAL CUES', style: AppTextStyles.clinicalNoteLabel),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: feedback.keyVisualCues.map((cue) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.plumLight,
                                border: Border.all(color: AppColors.plum.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(cue, style: AppTextStyles.cueChip),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Answer comparison
                        Text('YOUR ANSWERS', style: AppTextStyles.clinicalNoteLabel),
                        const SizedBox(height: 12),
                        _AnswerRow(
                          step: 'Diagnosis',
                          yourAnswer: selectedDiagnosis ?? '—',
                          correctAnswer: correctDiagnosis,
                          isCorrect: diagCorrect,
                        ),
                        const SizedBox(height: 10),
                        _AnswerRow(
                          step: 'Next step',
                          yourAnswer: selectedNextStep ?? '—',
                          correctAnswer: correctNextStep,
                          isCorrect: stepCorrect,
                        ),

                        // Differential note
                        if (feedback.differentialNote != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.border.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: AppColors.mutedText),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feedback.differentialNote!,
                                    style: AppTextStyles.caption,
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: EpidexaButton.primary(
              label: 'View insights',
              onPressed: () {
                ref.read(caseFlowProvider(caseId).notifier).advanceTo(CaseFlowStep.reinforcement);
                context.go('/case/$caseId/reinforce');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: EpidexaButton.secondary(
              label: 'Ask AI about this case',
              icon: const Icon(Icons.smart_toy_rounded, size: 16),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black26,
                  builder: (_) => ChatSheet(
                    pageContext:
                        'reviewing feedback for the \'${clinicalCase.title}\' case',
                    caseContext: CaseContext(
                      caseId: caseId,
                      title: clinicalCase.title,
                      patientPresentation: clinicalCase.patientPresentation,
                      additionalHistory: clinicalCase.additionalHistory,
                      correctDiagnosis: feedback.correctDiagnosis,
                      userDiagnosis: selectedDiagnosis,
                      diagnosisCorrect: diagCorrect,
                      nextStepCorrect: stepCorrect,
                      keyVisualCues: feedback.keyVisualCues,
                      imagePath: clinicalCase.imagePath,
                      visualDescription: clinicalCase.visualDescription,
                      differentialNote: feedback.differentialNote,
                      optionRationales: {
                        for (var opt in clinicalCase.nextStepOptions)
                          opt.label: opt.rationale
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.label, required this.correct});

  final String label;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: correct ? AppColors.correctLight : AppColors.incorrectLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Icon(
              correct ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 18,
              color: correct ? AppColors.correct : AppColors.incorrect,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: correct ? AppColors.correct : AppColors.incorrect,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.step,
    required this.yourAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  final String step;
  final String yourAnswer;
  final String correctAnswer;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCorrect ? Icons.check : Icons.close,
                size: 16,
                color: isCorrect ? AppColors.correct : AppColors.incorrect,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  yourAnswer,
                  style: AppTextStyles.body.copyWith(
                    color: isCorrect ? AppColors.correct : AppColors.incorrect,
                    decoration: isCorrect ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    correctAnswer,
                    style: AppTextStyles.body.copyWith(color: AppColors.correct),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
