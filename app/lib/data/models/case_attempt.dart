import 'clinical_case.dart';

class CaseAttempt {
  CaseAttempt({
    required this.caseId,
    required this.startedAt,
    this.completedAt,
    List<String>? selectedObservationIds,
    this.selectedDiagnosisId,
    this.selectedNextStepId,
  }) : selectedObservationIds = selectedObservationIds ?? [];

  final String caseId;
  final DateTime startedAt;
  DateTime? completedAt;
  final List<String> selectedObservationIds;
  String? selectedDiagnosisId;
  String? selectedNextStepId;

  bool observationCorrect(List<ObservationOption> options) {
    final correctIds = options.where((o) => o.isCorrect).map((o) => o.id).toSet();
    return selectedObservationIds.toSet().containsAll(correctIds) &&
        !selectedObservationIds.any((id) => !correctIds.contains(id));
  }

  bool diagnosisCorrect(List<DiagnosisOption> options) {
    final correctId = options.firstWhere((o) => o.isCorrect).id;
    return selectedDiagnosisId == correctId;
  }

  bool nextStepCorrect(List<NextStepOption> options) {
    final correctId = options.firstWhere((o) => o.isCorrect).id;
    return selectedNextStepId == correctId;
  }

  CaseAttempt copyWith({
    List<String>? selectedObservationIds,
    String? selectedDiagnosisId,
    String? selectedNextStepId,
    DateTime? completedAt,
  }) {
    return CaseAttempt(
      caseId: caseId,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      selectedObservationIds: selectedObservationIds ?? List.of(this.selectedObservationIds),
      selectedDiagnosisId: selectedDiagnosisId ?? this.selectedDiagnosisId,
      selectedNextStepId: selectedNextStepId ?? this.selectedNextStepId,
    );
  }
}
