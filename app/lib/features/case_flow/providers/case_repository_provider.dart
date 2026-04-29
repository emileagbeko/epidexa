import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../data/repositories/mock_case_repository.dart';

final caseRepositoryProvider = Provider<CaseRepository>((ref) {
  return MockCaseRepository();
});
