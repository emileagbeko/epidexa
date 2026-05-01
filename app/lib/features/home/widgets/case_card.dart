import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/clinical_case.dart';
import '../../../shared/widgets/placeholder_image.dart';

class CaseCard extends StatelessWidget {
  const CaseCard({super.key, required this.clinicalCase, required this.index});

  final ClinicalCase clinicalCase;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/case/${clinicalCase.id}/start'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: clinicalCase.imagePath == null || clinicalCase.imagePath == 'placeholder'
                  ? const PlaceholderImage(width: 100, height: 100)
                  : clinicalCase.imagePath!.startsWith('http')
                      ? Image.network(
                          clinicalCase.imagePath!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const PlaceholderImage(width: 100, height: 100),
                        )
                      : Image.asset(
                          clinicalCase.imagePath!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Case ${index + 1}'.toUpperCase(),
                          style: AppTextStyles.clinicalNoteLabel,
                        ),
                        const Spacer(),
                        _DifficultyPill(difficulty: clinicalCase.difficulty),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(clinicalCase.title, style: AppTextStyles.subheading),
                    const SizedBox(height: 3),
                    Text(
                      clinicalCase.category.name[0].toUpperCase() +
                          clinicalCase.category.name.substring(1),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.schedule_outlined,
                            size: 12, color: AppColors.mutedText),
                        const SizedBox(width: 3),
                        Text('~10 min', style: AppTextStyles.caption),
                        const SizedBox(width: 14),
                        Icon(Icons.layers_outlined,
                            size: 12, color: AppColors.mutedText),
                        const SizedBox(width: 3),
                        Text('6 steps', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.plumLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppColors.plum),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({required this.difficulty});

  final CaseDifficulty difficulty;

  Color get _color {
    return switch (difficulty) {
      CaseDifficulty.beginner => AppColors.correct,
      CaseDifficulty.intermediate => AppColors.gold,
      CaseDifficulty.advanced => AppColors.incorrect,
    };
  }

  Color get _bg {
    return switch (difficulty) {
      CaseDifficulty.beginner => AppColors.correctLight,
      CaseDifficulty.intermediate => AppColors.goldLight,
      CaseDifficulty.advanced => AppColors.incorrectLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = difficulty.name[0].toUpperCase() + difficulty.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
