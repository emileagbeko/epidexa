import '../mock/mock_cases.dart';
import '../models/clinical_case.dart';
import 'case_repository.dart';

class MockCaseRepository implements CaseRepository {
  @override
  List<ClinicalCase> getAllCases() => mockCases;

  @override
  ClinicalCase? getCaseById(String id) {
    try {
      return mockCases.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  String? getNextCaseId(String currentCaseId) {
    final index = mockCases.indexWhere((c) => c.id == currentCaseId);
    if (index == -1 || index == mockCases.length - 1) return null;
    return mockCases[index + 1].id;
  }
}
