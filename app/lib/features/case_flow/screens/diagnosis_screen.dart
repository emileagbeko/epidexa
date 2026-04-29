import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/epidexa_button.dart';
import '../../../shared/widgets/epidexa_scaffold.dart';
import '../providers/active_case_provider.dart';
import '../providers/case_flow_provider.dart';
import '../widgets/case_progress_header.dart';
import '../widgets/single_select_option_tile.dart';

class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseFlowProvider(caseId));
    final clinicalCase = state.clinicalCase;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeCaseIdProvider.notifier).state = caseId;
      ref.read(currentPageContextProvider.notifier).state =
          'selecting a diagnosis for the \'${clinicalCase.title}\' case';
    });
    final selected = state.attempt.selectedDiagnosisId;

    return EpidexaScaffold(
      onBack: () => context.go('/case/$caseId/observe'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaseProgressHeader(step: CaseFlowStep.diagnosis, caseTitle: clinicalCase.title),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Most likely diagnosis?', style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Text('Based on the clinical image and history', style: AppTextStyles.caption),
                  const SizedBox(height: 20),
                  ...clinicalCase.diagnosisOptions.map((option) {
                    return SingleSelectOptionTile(
                      label: option.label,
                      selected: selected == option.id,
                      onTap: () => ref
                          .read(caseFlowProvider(caseId).notifier)
                          .selectDiagnosis(option.id),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: EpidexaButton.primary(
              label: 'Continue',
              enabled: selected != null,
              onPressed: () {
                ref.read(caseFlowProvider(caseId).notifier).advanceTo(CaseFlowStep.nextStep);
                context.go('/case/$caseId/next-step');
              },
            ),
          ),
        ],
      ),
    );
  }
}
