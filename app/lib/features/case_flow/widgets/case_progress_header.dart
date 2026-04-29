import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/case_flow_provider.dart';

class CaseProgressHeader extends StatelessWidget {
  const CaseProgressHeader(
      {super.key, required this.step, required this.caseTitle});

  final CaseFlowStep step;
  final String caseTitle;

  static const _labels = [
    'Presentation',
    'Observation',
    'Diagnosis',
    'Next step',
    'Feedback',
    'Insights'
  ];

  int get _stepIndex => CaseFlowStep.values.indexOf(step);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caseTitle,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.mutedText,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_stepIndex + 1} / ${CaseFlowStep.values.length}',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.plum,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(CaseFlowStep.values.length, (i) {
              final isPast = i < _stepIndex;
              final isCurrent = i == _stepIndex;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < CaseFlowStep.values.length - 1 ? 4 : 0),
                  height: isCurrent ? 6 : 4,
                  decoration: BoxDecoration(
                    color: isPast
                        ? AppColors.plum.withOpacity(0.4)
                        : isCurrent
                            ? AppColors.plum
                            : AppColors.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 7),
          Text(
            _labels[_stepIndex].toUpperCase(),
            style: AppTextStyles.clinicalNoteLabel.copyWith(
              color: AppColors.plum,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
