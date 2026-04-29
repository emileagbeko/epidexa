import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/case_attempt.dart';
import '../../../data/models/clinical_case.dart';
import 'case_repository_provider.dart';

enum CaseFlowStep { start, observation, diagnosis, nextStep, feedback, reinforcement }

class CaseFlowState {
  const CaseFlowState({
    required this.clinicalCase,
    required this.step,
    required this.attempt,
  });

  final ClinicalCase clinicalCase;
  final CaseFlowStep step;
  final CaseAttempt attempt;

  CaseFlowState copyWith({CaseFlowStep? step, CaseAttempt? attempt}) {
    return CaseFlowState(
      clinicalCase: clinicalCase,
      step: step ?? this.step,
      attempt: attempt ?? this.attempt,
    );
  }
}

class CaseFlowNotifier extends StateNotifier<CaseFlowState> {
  CaseFlowNotifier(ClinicalCase clinicalCase)
      : super(CaseFlowState(
          clinicalCase: clinicalCase,
          step: CaseFlowStep.start,
          attempt: CaseAttempt(caseId: clinicalCase.id, startedAt: DateTime.now()),
        ));

  void advanceTo(CaseFlowStep step) {
    state = state.copyWith(step: step);
  }

  void toggleObservation(String optionId) {
    final current = List<String>.from(state.attempt.selectedObservationIds);
    if (current.contains(optionId)) {
      current.remove(optionId);
    } else {
      current.add(optionId);
    }
    state = state.copyWith(
      attempt: state.attempt.copyWith(selectedObservationIds: current),
    );
  }

  void selectDiagnosis(String optionId) {
    state = state.copyWith(
      attempt: state.attempt.copyWith(selectedDiagnosisId: optionId),
    );
  }

  void selectNextStep(String optionId) {
    state = state.copyWith(
      attempt: state.attempt.copyWith(selectedNextStepId: optionId),
    );
  }

  void completeCase() {
    state = state.copyWith(
      step: CaseFlowStep.feedback,
      attempt: state.attempt.copyWith(completedAt: DateTime.now()),
    );
  }
}

final caseFlowProvider = StateNotifierProvider.autoDispose
    .family<CaseFlowNotifier, CaseFlowState, String>((ref, caseId) {
  final repo = ref.read(caseRepositoryProvider);
  final clinicalCase = repo.getCaseById(caseId);
  if (clinicalCase == null) throw Exception('Case $caseId not found');
  return CaseFlowNotifier(clinicalCase);
});
