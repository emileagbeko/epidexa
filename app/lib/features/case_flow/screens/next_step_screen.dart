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

class NextStepScreen extends ConsumerWidget {
  const NextStepScreen({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseFlowProvider(caseId));
    final clinicalCase = state.clinicalCase;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeCaseIdProvider.notifier).state = caseId;
      ref.read(currentPageContextProvider.notifier).state =
          'choosing the next clinical management step for the \'${clinicalCase.title}\' case';
    });
    final selected = state.attempt.selectedNextStepId;

    return EpidexaScaffold(
      onBack: () => context.go('/case/$caseId/diagnose'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaseProgressHeader(step: CaseFlowStep.nextStep, caseTitle: clinicalCase.title),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What would you do next?', style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Text('Select the most appropriate management step', style: AppTextStyles.caption),
                  const SizedBox(height: 20),
                  ...clinicalCase.nextStepOptions.map((option) {
                    return SingleSelectOptionTile(
                      label: option.label,
                      selected: selected == option.id,
                      onTap: () => ref
                          .read(caseFlowProvider(caseId).notifier)
                          .selectNextStep(option.id),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: EpidexaButton.primary(
              label: 'See feedback',
              enabled: selected != null,
              onPressed: () {
                ref.read(caseFlowProvider(caseId).notifier).completeCase();
                context.go('/case/$caseId/feedback');
              },
            ),
          ),
        ],
      ),
    );
  }
}
