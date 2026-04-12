import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class DetailViewScreen extends StatelessWidget {
  final Debrief debrief;

  const DetailViewScreen({super.key, required this.debrief});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatShortDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  List<String> _parseBullets(String? text) {
    if (text == null || text.trim().isEmpty) return [];
    return text
        .split(RegExp(r'[\n•]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> _parseParticipants(String? text) {
    if (text == null || text.trim().isEmpty) return [];
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Debrief',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the debrief for "${debrief.clientName}"? This cannot be undone.',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<DebriefProvider>();
      final success = await provider.deleteDebrief(debrief.id);
      if (success && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debrief deleted'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.actionError ?? 'Failed to delete debrief'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSent = debrief.status == 'sent';
    final participants = _parseParticipants(debrief.participants);
    final summaryBullets = _parseBullets(debrief.summary);
    final decisionsBullets = _parseBullets(debrief.decisionsMade);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back navigation link
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back to Debriefs',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Header Card ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _DebriefHeader(
                      debrief: debrief,
                      isSent: isSent,
                      formattedDate: _formatDate(debrief.meetingDate),
                      participants: participants,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Summary ────────────────────────────────────────────────
                  if (summaryBullets.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(
                        icon: '📋',
                        label: 'SUMMARY',
                        labelColor: const Color(0xFF6B7280),
                        child: _BulletList(
                          bullets: summaryBullets,
                          bulletColor: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Decisions ──────────────────────────────────────────────
                  if (decisionsBullets.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(
                        icon: '✅',
                        label: 'DECISIONS',
                        labelColor: const Color(0xFF10B981),
                        child: _BulletList(
                          bullets: decisionsBullets,
                          bulletColor: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Action Items ───────────────────────────────────────────
                  if (debrief.actionItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(
                        icon: '🎯',
                        label: 'ACTION ITEMS',
                        labelColor: const Color(0xFFF59E0B),
                        child: Column(
                          children: debrief.actionItems
                              .map(
                                (item) => _ActionItemCard(
                                  item: item,
                                  formatDate: _formatShortDate,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Risks / Concerns ───────────────────────────────────────
                  if (debrief.risksConcerns != null &&
                      debrief.risksConcerns!.trim().isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(
                        icon: '⚠️',
                        label: 'RISKS / CONCERNS',
                        labelColor: const Color(0xFFF59E0B),
                        child: _RisksCard(text: debrief.risksConcerns!),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Shared With (only when sent) ───────────────────────────
                  if (isSent) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(
                        icon: '📧',
                        label: 'SHARED WITH',
                        labelColor: const Color(0xFF6B7280),
                        child: const _SharedWithSection(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom Action Bar ──────────────────────────────────────────────
          _BottomActionBar(
            onDelete: () => _confirmDelete(context),
            onShare: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Debriefly',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1A1A2E)),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ── Header Card ───────────────────────────────────────────────────────────────

class _DebriefHeader extends StatelessWidget {
  final Debrief debrief;
  final bool isSent;
  final String formattedDate;
  final List<String> participants;

  const _DebriefHeader({
    required this.debrief,
    required this.isSent,
    required this.formattedDate,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client name
          Text(
            debrief.clientName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          // Date + Participants row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Participants
              if (participants.isNotEmpty)
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          participants.join(', '),
                          style: const TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSent ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSent ? Icons.send_outlined : Icons.schedule_outlined,
                  size: 13,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  isSent ? 'sent' : 'draft',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String icon;
  final String label;
  final Color labelColor;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Bullet List ───────────────────────────────────────────────────────────────

class _BulletList extends StatelessWidget {
  final List<String> bullets;
  final Color bulletColor;

  const _BulletList({required this.bullets, required this.bulletColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets.map((bullet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              Expanded(
                child: Text(
                  bullet,
                  style: TextStyle(
                    fontSize: 14,
                    color: bulletColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Action Item Card ──────────────────────────────────────────────────────────

class _ActionItemCard extends StatelessWidget {
  final ActionItem item;
  final String Function(String) formatDate;

  const _ActionItemCard({required this.item, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle check icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.owner,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatDate(item.dueDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Risks Card ────────────────────────────────────────────────────────────────

class _RisksCard extends StatelessWidget {
  final String text;

  const _RisksCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFDC2626),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared With Section ───────────────────────────────────────────────────────

class _SharedWithSection extends StatelessWidget {
  const _SharedWithSection();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'This debrief has been shared via email.',
      style: TextStyle(
        fontSize: 13,
        color: Color(0xFF6B7280),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

// ── Bottom Action Bar ─────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _BottomActionBar({required this.onDelete, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Delete button
            TextButton.icon(
              onPressed: onDelete,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const Spacer(),
            // Share Debrief button
            ElevatedButton.icon(
              onPressed: onShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text(
                'Share Debrief',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
