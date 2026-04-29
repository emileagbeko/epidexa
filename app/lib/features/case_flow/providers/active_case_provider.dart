import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeCaseIdProvider = StateProvider<String?>((ref) => null);

final isOnAssistantScreenProvider = StateProvider<bool>((ref) => false);

// Plain-English description of where the user is — passed to the AI as context
final currentPageContextProvider = StateProvider<String?>((ref) => null);
