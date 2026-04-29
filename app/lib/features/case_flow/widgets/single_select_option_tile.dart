import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SingleSelectOptionTile extends StatelessWidget {
  const SingleSelectOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.resultCorrect,
    this.resultIncorrect,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool? resultCorrect;
  final bool? resultIncorrect;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.border;
    Color bgColor = AppColors.surface;
    bool hasResult = resultCorrect != null || resultIncorrect != null;

    if (resultCorrect == true) {
      borderColor = AppColors.correct;
      bgColor = AppColors.correctLight;
    } else if (resultIncorrect == true) {
      borderColor = AppColors.incorrect;
      bgColor = AppColors.incorrectLight;
    } else if (selected) {
      borderColor = AppColors.plum;
      bgColor = AppColors.plumLight;
    }

    return GestureDetector(
      onTap: hasResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: selected || hasResult ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: resultCorrect == true
                    ? AppColors.correct
                    : resultIncorrect == true
                        ? AppColors.incorrect
                        : selected
                            ? AppColors.plum
                            : Colors.transparent,
                border: Border.all(
                  color: resultCorrect == true
                      ? AppColors.correct
                      : resultIncorrect == true
                          ? AppColors.incorrect
                          : selected
                              ? AppColors.plum
                              : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: hasResult
                  ? Icon(
                      resultCorrect == true ? Icons.check_rounded : Icons.close_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : selected
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        )
                      : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.optionText.copyWith(
                  color: resultCorrect == true
                      ? AppColors.correct
                      : resultIncorrect == true
                          ? AppColors.incorrect
                          : AppColors.primaryText,
                  fontWeight: selected || hasResult ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
