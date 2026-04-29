import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/epidexa_button.dart';
import '../../../shared/widgets/epidexa_scaffold.dart';
import '../providers/active_case_provider.dart';
import '../providers/case_flow_provider.dart';
import '../widgets/case_image_fullscreen.dart';
import '../widgets/case_progress_header.dart';
import '../widgets/clinical_image_viewer.dart';
import '../widgets/multi_select_option_tile.dart';

class ObservationScreen extends ConsumerWidget {
  const ObservationScreen({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseFlowProvider(caseId));
    final clinicalCase = state.clinicalCase;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeCaseIdProvider.notifier).state = caseId;
      ref.read(currentPageContextProvider.notifier).state =
          'identifying clinical observations for the \'${clinicalCase.title}\' case';
    });
    final selected = state.attempt.selectedObservationIds;

    return EpidexaScaffold(
      onBack: () => context.go('/case/$caseId/start'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaseProgressHeader(step: CaseFlowStep.observation, caseTitle: clinicalCase.title),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CaseImageFullscreen(
                    imagePath: clinicalCase.imagePath,
                    heroTag: 'case_image_$caseId',
                  ),
                ),
              );
            },
            child: ClinicalImageViewer(
              caseId: caseId,
              imagePath: clinicalCase.imagePath,
              height: 220,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What do you notice?', style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Text('Select all that apply', style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  ...clinicalCase.observationOptions.map((option) {
                    return MultiSelectOptionTile(
                      label: option.label,
                      selected: selected.contains(option.id),
                      onTap: () => ref
                          .read(caseFlowProvider(caseId).notifier)
                          .toggleObservation(option.id),
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
              enabled: selected.isNotEmpty,
              onPressed: () {
                ref.read(caseFlowProvider(caseId).notifier).advanceTo(CaseFlowStep.diagnosis);
                context.go('/case/$caseId/diagnose');
              },
            ),
          ),
        ],
      ),
    );
  }
}
