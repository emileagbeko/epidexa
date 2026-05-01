import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../case_flow/providers/active_case_provider.dart';
import '../../case_flow/providers/case_repository_provider.dart';
import '../screens/ai_assistant_screen.dart';
import 'chat_sheet.dart';

// Wraps the entire app content. Manages the draggable Adora FAB as an overlay.
class GlobalChatFab extends ConsumerStatefulWidget {
  const GlobalChatFab({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<GlobalChatFab> createState() =>
      _GlobalChatFabState();
}

class _GlobalChatFabState
    extends ConsumerState<GlobalChatFab> {
  static const _kFabSize = 56.0;
  static const _kDismissRadius = 36.0;

  double _right = 20;
  double _bottom = 90;

  bool _isDragging = false;
  bool _isOverDismiss = false;
  bool _dismissed = false;

  void _openAdora(BuildContext context, String? caseId) {
    // Use GoRouter's navigator key so we always get the correct context,
    // even though this widget lives above the navigator in app.dart's builder.
    final navCtx = appRouter.routerDelegate.navigatorKey.currentContext;
    if (navCtx == null) return;

    final pageContext =
        ref.read(currentPageContextProvider) ?? 'browsing Epidexa';

    CaseContext? caseContext;
    if (caseId != null) {
      final clinicalCase =
          ref.read(caseRepositoryProvider).getCaseById(caseId);
      if (clinicalCase != null) {
        caseContext = CaseContext(
          caseId: caseId,
          title: clinicalCase.title,
          patientPresentation: clinicalCase.patientPresentation,
          additionalHistory: clinicalCase.additionalHistory,
          correctDiagnosis: clinicalCase.feedback.correctDiagnosis,
          userDiagnosis: null,
          diagnosisCorrect: null,
          nextStepCorrect: null,
          keyVisualCues: clinicalCase.feedback.keyVisualCues,
          imagePath: clinicalCase.imagePath,
          visualDescription: clinicalCase.visualDescription,
          differentialNote: clinicalCase.feedback.differentialNote,
          optionRationales: {
            for (var opt in clinicalCase.nextStepOptions)
              opt.label: opt.rationale ?? ''
          },
        );
      }
    }

    showModalBottomSheet(
      context: navCtx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (_) => ChatSheet(
        pageContext: pageContext,
        caseContext: caseContext,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnAssistant = ref.watch(isOnAssistantScreenProvider);
    final activeCaseId = ref.watch(activeCaseIdProvider);
    final mq = MediaQuery.of(context);
    final showFab = !_dismissed && !isOnAssistant;

    // Dismiss zone center in global screen coords
    final dzCx = mq.size.width / 2;
    final dzCy = mq.size.height - mq.padding.bottom - 40 - _kDismissRadius;

    return Stack(
      children: [
        widget.child,

        // ── Dismiss zone (only during drag) ──────────────────────────────────
        if (showFab && _isDragging)
          Positioned(
            bottom: mq.padding.bottom + 40,
            left: mq.size.width / 2 - _kDismissRadius,
            child: _DismissZone(active: _isOverDismiss),
          ),

        // ── The Adora FAB ─────────────────────────────────────────────────────
        if (showFab)
          Positioned(
            right: _right,
            bottom: _bottom,
            child: GestureDetector(
              onTap: () => _openAdora(context, activeCaseId),
              onLongPressStart: (_) => setState(() => _isDragging = true),
              onLongPressMoveUpdate: (d) {
                final pos = d.globalPosition;
                final newRight = (mq.size.width - pos.dx - _kFabSize / 2)
                    .clamp(4.0, mq.size.width - _kFabSize - 4);
                final newBottom = (mq.size.height - pos.dy - _kFabSize / 2)
                    .clamp(4.0, mq.size.height - _kFabSize - 4);

                final dx = pos.dx - dzCx;
                final dy = pos.dy - dzCy;

                setState(() {
                  _right = newRight;
                  _bottom = newBottom;
                  _isOverDismiss = (dx * dx + dy * dy) <
                      (_kDismissRadius + 20) * (_kDismissRadius + 20);
                });
              },
              onLongPressEnd: (_) {
                if (_isOverDismiss) {
                  setState(() => _dismissed = true);
                } else {
                  setState(() {
                    _isDragging = false;
                    _isOverDismiss = false;
                  });
                }
              },
              onLongPressCancel: () => setState(() {
                _isDragging = false;
                _isOverDismiss = false;
              }),
              child: AnimatedScale(
                scale: _isOverDismiss ? 0.7 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: AnimatedOpacity(
                  opacity: _isDragging ? 0.82 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: _kFabSize,
                    height: _kFabSize,
                    decoration: BoxDecoration(
                      color: AppColors.plum,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.plum.withOpacity(0.38),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DismissZone extends StatelessWidget {
  const _DismissZone({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 160),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: _GlobalChatFabState._kDismissRadius * 2,
        height: _GlobalChatFabState._kDismissRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFFD32F2F) : Colors.black54,
          boxShadow: [
            BoxShadow(
              color: (active ? const Color(0xFFD32F2F) : Colors.black)
                  .withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: active ? 26 : 22,
        ),
      ),
    );
  }
}
