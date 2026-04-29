import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_image.dart';

class ClinicalImageViewer extends StatelessWidget {
  const ClinicalImageViewer({
    super.key,
    required this.caseId,
    required this.imagePath,
    this.height = 260,
  });

  final String caseId;
  final String imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'case_image_$caseId',
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: imagePath == 'placeholder'
            ? PlaceholderImage(height: height)
            : imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        PlaceholderImage(height: height),
                  )
                : Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}
