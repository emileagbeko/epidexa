import '../models/clinical_case.dart';

abstract class CaseRepository {
  List<ClinicalCase> getAllCases();
  ClinicalCase? getCaseById(String id);
  String? getNextCaseId(String currentCaseId);
}
