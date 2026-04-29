import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/case_flow/screens/case_start_screen.dart';
import '../../features/case_flow/screens/observation_screen.dart';
import '../../features/case_flow/screens/diagnosis_screen.dart';
import '../../features/case_flow/screens/next_step_screen.dart';
import '../../features/case_flow/screens/feedback_screen.dart';
import '../../features/case_flow/screens/reinforcement_screen.dart';
import '../../features/ai_assistant/screens/ai_assistant_screen.dart';

Page<void> _slidePage(LocalKey key, Widget child) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/case/:caseId/start',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        CaseStartScreen(caseId: state.pathParameters['caseId']!),
      ),
    ),
    GoRoute(
      path: '/case/:caseId/observe',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        ObservationScreen(caseId: state.pathParameters['caseId']!),
      ),
    ),
    GoRoute(
      path: '/case/:caseId/diagnose',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        DiagnosisScreen(caseId: state.pathParameters['caseId']!),
      ),
    ),
    GoRoute(
      path: '/case/:caseId/next-step',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        NextStepScreen(caseId: state.pathParameters['caseId']!),
      ),
    ),
    GoRoute(
      path: '/case/:caseId/feedback',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        FeedbackScreen(caseId: state.pathParameters['caseId']!),
      ),
    ),
    GoRoute(
      path: '/case/:caseId/reinforce',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        ReinforcementScreen(caseId: state.pathParameters['caseId']!),
      ),
    ),
    GoRoute(
      path: '/assistant',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        const AiAssistantScreen(),
      ),
    ),
    GoRoute(
      path: '/case/:caseId/assistant',
      pageBuilder: (context, state) {
        final extra = state.extra as CaseContext?;
        return _slidePage(
          state.pageKey,
          AiAssistantScreen(caseContext: extra),
        );
      },
    ),
  ],
);
