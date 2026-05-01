import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/epidexa_button.dart';
import '../../../shared/widgets/epidexa_scaffold.dart';
import '../../../data/models/clinical_case.dart';
import '../providers/active_case_provider.dart';
import '../providers/case_flow_provider.dart';
import '../widgets/case_image_fullscreen.dart';
import '../widgets/case_progress_header.dart';
import '../widgets/clinical_image_viewer.dart';

class CaseStartScreen extends ConsumerWidget {
  const CaseStartScreen({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseFlowProvider(caseId));
    final clinicalCase = state.clinicalCase;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeCaseIdProvider.notifier).state = caseId;
      ref.read(currentPageContextProvider.notifier).state =
          'reading the patient presentation for the \'${clinicalCase.title}\' case';
    });

    return EpidexaScaffold(
      onBack: () => context.go('/'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaseProgressHeader(step: CaseFlowStep.start, caseTitle: clinicalCase.title),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PATIENT PRESENTATION', style: AppTextStyles.clinicalNoteLabel),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        left: BorderSide(color: AppColors.plum, width: 3),
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      clinicalCase.patientPresentation,
                      style: AppTextStyles.clinicalNote,
                    ),
                  ),
                  if (clinicalCase.additionalHistory != null) ...[
                    const SizedBox(height: 16),
                    Text('ADDITIONAL HISTORY', style: AppTextStyles.clinicalNoteLabel),
                    const SizedBox(height: 8),
                    Text(
                      clinicalCase.additionalHistory!,
                      style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
                    ),
                  ],
                  if (clinicalCase.imagePath != null) ...[
                    const SizedBox(height: 32),
                    Text('CLINICAL IMAGE', style: AppTextStyles.clinicalNoteLabel),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CaseImageFullscreen(
                              imagePath: clinicalCase.imagePath!,
                              heroTag: 'case_start_image_${clinicalCase.id}',
                            ),
                          ),
                        );
                      },
                      child: ClinicalImageViewer(
                        caseId: '${clinicalCase.id}_start',
                        imagePath: clinicalCase.imagePath!,
                        height: 180,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _DifficultyBadge(difficulty: clinicalCase.difficulty),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: EpidexaButton.primary(
              label: 'View clinical image',
              onPressed: () {
                ref.read(caseFlowProvider(caseId).notifier).advanceTo(CaseFlowStep.observation);
                context.go('/case/$caseId/observe');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final CaseDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final label = difficulty.name[0].toUpperCase() + difficulty.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.plumLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: AppTextStyles.label.copyWith(color: AppColors.plum)),
    );
  }
}
