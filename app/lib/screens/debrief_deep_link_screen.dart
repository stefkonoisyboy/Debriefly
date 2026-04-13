import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import 'detail_view_screen.dart';

/// Shown when navigating directly to /debrief/:id (e.g. from a shared URL).
/// Fetches the debrief by [debriefId] then hands off to [DetailViewScreen].
class DebriefDeepLinkScreen extends StatefulWidget {
  final String debriefId;

  const DebriefDeepLinkScreen({super.key, required this.debriefId});

  @override
  State<DebriefDeepLinkScreen> createState() => _DebriefDeepLinkScreenState();
}

class _DebriefDeepLinkScreenState extends State<DebriefDeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebriefProvider>().loadDebrief(widget.debriefId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DebriefProvider>(
      builder: (context, provider, _) {
        // Loading
        if (provider.isDetailLoading ||
            provider.detailStatus == DebriefListStatus.initial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF2F3F7),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
            ),
          );
        }

        // Error
        if (provider.detailStatus == DebriefListStatus.error) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F3F7),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Debrief not found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.detailError ??
                          'This debrief may have been deleted or the link is invalid.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Success — hand off to the full detail screen
        final debrief = provider.selectedDebrief;
        if (debrief == null) {
          return const SizedBox.shrink();
        }

        // If there's no previous route (e.g. opened via a shared URL directly),
        // show in read-only mode. In-app navigation retains full controls.
        final isDeepLink = !Navigator.of(context).canPop();
        return DetailViewScreen(debrief: debrief, readOnly: isDeepLink);
      },
    );
  }
}
