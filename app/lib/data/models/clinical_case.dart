enum CaseDifficulty { beginner, intermediate, advanced }

enum DermatologyCategory {
  inflammatory,
  fungal,
  bacterial,
  viral,
  neoplastic,
  autoimmune,
}

class ObservationOption {
  const ObservationOption({
    required this.id,
    required this.label,
    required this.isCorrect,
  });

  final String id;
  final String label;
  final bool isCorrect;
}

class DiagnosisOption {
  const DiagnosisOption({
    required this.id,
    required this.label,
    required this.isCorrect,
  });

  final String id;
  final String label;
  final bool isCorrect;
}

class NextStepOption {
  const NextStepOption({
    required this.id,
    required this.label,
    required this.isCorrect,
    this.rationale,
  });

  final String id;
  final String label;
  final bool isCorrect;
  final String? rationale;
}

class FeedbackData {
  const FeedbackData({
    required this.correctDiagnosis,
    required this.explanation,
    required this.keyVisualCues,
    this.differentialNote,
  });

  final String correctDiagnosis;
  final String explanation;
  final List<String> keyVisualCues;
  final String? differentialNote;
}

class ClinicalCase {
  const ClinicalCase({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.category,
    required this.patientPresentation,
    this.additionalHistory,
    this.imagePath,
    this.visualDescription,
    required this.observationOptions,
    required this.diagnosisOptions,
    required this.nextStepOptions,
    required this.feedback,
    required this.conceptTags,
    this.specialtyNote,
  });

  final String id;
  final String title;
  final CaseDifficulty difficulty;
  final DermatologyCategory category;
  final String patientPresentation;
  final String? additionalHistory;
  final String? imagePath;
  final String? visualDescription;
  final List<ObservationOption> observationOptions;
  final List<DiagnosisOption> diagnosisOptions;
  final List<NextStepOption> nextStepOptions;
  final FeedbackData feedback;
  final List<String> conceptTags;
  final String? specialtyNote;
}
