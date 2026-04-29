class ConceptPerformance {
  ConceptPerformance({
    required this.tag,
    this.attempts = 0,
    this.correct = 0,
  });

  final String tag;
  int attempts;
  int correct;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  bool get isWeak => attempts >= 1 && accuracy < 0.7;
}
