import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import 'debrief_form_screen.dart';

enum _FilterTab { all, draft, sent }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _FilterTab _activeFilter = _FilterTab.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebriefProvider>().loadDebriefs();
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(
          () => _searchQuery = _searchController.text.toLowerCase().trim(),
        );
      }
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  Future<void> _openNewDebrief(BuildContext context) async {
    final created = await Navigator.of(context).push<Debrief>(
      MaterialPageRoute(builder: (_) => const DebriefFormScreen()),
    );
    if (created != null && mounted) {
      // Debrief already added to provider list inside createDebrief()
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debrief saved successfully'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Debrief> _filtered(DebriefProvider provider) {
    final all = provider.debriefs;
    final byStatus = switch (_activeFilter) {
      _FilterTab.all => all,
      _FilterTab.sent => all.where((d) => provider.isSent(d.id)).toList(),
      _FilterTab.draft => all.where((d) => !provider.isSent(d.id)).toList(),
    };
    if (_searchQuery.isEmpty) return byStatus;
    return byStatus.where((d) {
      final haystack = '${d.clientName} ${d.participants ?? ''}'.toLowerCase();
      return haystack.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: _buildAppBar(),
      body: Consumer<DebriefProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.loadDebriefs(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(provider),
                        const SizedBox(height: 24),
                        _buildStatsRow(provider),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildFilterTabs(provider),
                        const SizedBox(height: 12),
                        _buildResultCount(provider),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                _buildDebriefList(provider),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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

  Widget _buildHeader(DebriefProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Debriefs',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your client meeting debriefs',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 160,
          child: ElevatedButton.icon(
            onPressed: () => _openNewDebrief(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'New Debrief',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(DebriefProvider provider) {
    final total = provider.debriefs.length;
    final sent = provider.sentCount;
    final drafts = provider.draftCount;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF6B7280),
            iconBg: const Color(0xFFF3F4F6),
            count: total,
            label: 'Total',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.send_outlined,
            iconColor: const Color(0xFF10B981),
            iconBg: const Color(0xFFD1FAE5),
            count: sent,
            label: 'Sent',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule_outlined,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFEF3C7),
            count: drafts,
            label: 'Drafts',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by client or participants...',
          hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFADB5BD),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                  onPressed: _clearSearch,
                  tooltip: 'Clear search',
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCount(DebriefProvider provider) {
    if (provider.isListLoading ||
        provider.listStatus == DebriefListStatus.error) {
      return const SizedBox.shrink();
    }
    final count = _filtered(provider).length;
    final total = provider.debriefs.length;
    final isFiltered =
        _searchQuery.isNotEmpty || _activeFilter != _FilterTab.all;
    if (!isFiltered && count == total) return const SizedBox.shrink();
    return Text(
      isFiltered
          ? '$count ${count == 1 ? 'result' : 'results'} found'
          : '$count ${count == 1 ? 'debrief' : 'debriefs'}',
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFilterTabs(DebriefProvider provider) {
    final allCount = provider.debriefs.length;
    final draftCount = provider.draftCount;
    final sentCount = provider.sentCount;

    return Row(
      children: [
        _FilterChip(
          label: 'All',
          count: allCount,
          selected: _activeFilter == _FilterTab.all,
          onTap: () => setState(() => _activeFilter = _FilterTab.all),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Draft',
          count: draftCount,
          selected: _activeFilter == _FilterTab.draft,
          onTap: () => setState(() => _activeFilter = _FilterTab.draft),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Sent',
          count: sentCount,
          selected: _activeFilter == _FilterTab.sent,
          onTap: () => setState(() => _activeFilter = _FilterTab.sent),
        ),
      ],
    );
  }

  String _emptyMessage() {
    if (_searchQuery.isNotEmpty) {
      return 'No debriefs match "${_searchController.text.trim()}"';
    }
    return switch (_activeFilter) {
      _FilterTab.all => 'No debriefs yet. Create your first one!',
      _FilterTab.sent => 'No sent debriefs yet.',
      _FilterTab.draft => 'No drafts yet.',
    };
  }

  Widget _buildDebriefList(DebriefProvider provider) {
    if (provider.isListLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.listStatus == DebriefListStatus.error) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 12),
              Text(
                provider.listError ?? 'Failed to load debriefs',
                style: const TextStyle(color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadDebriefs(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final items = _filtered(provider);

    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _searchQuery.isNotEmpty
                      ? Icons.search_off_outlined
                      : Icons.description_outlined,
                  size: 48,
                  color: const Color(0xFFD1D5DB),
                ),
                const SizedBox(height: 12),
                Text(
                  _emptyMessage(),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Clear search'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final debrief = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DebriefCard(
              debrief: debrief,
              isSent: provider.isSent(debrief.id),
              onTap: () {},
            ),
          );
        }, childCount: items.length),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final int count;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: selected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.25)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Debrief Card ──────────────────────────────────────────────────────────────

class _DebriefCard extends StatelessWidget {
  final Debrief debrief;
  final bool isSent;
  final VoidCallback onTap;

  const _DebriefCard({
    required this.debrief,
    required this.isSent,
    required this.onTap,
  });

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  int _participantCount() {
    final p = debrief.participants;
    if (p == null || p.trim().isEmpty) return 0;
    return p.split(',').length;
  }

  String _summaryPreview() {
    final s = debrief.summary;
    if (s == null || s.trim().isEmpty) return '';
    final sentences = s
        .split(RegExp(r'[.•\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (sentences.isEmpty) return s;
    return sentences.take(2).map((e) => '• $e').join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = isSent
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final statusBg = isSent ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7);
    final statusLabel = isSent ? 'SENT' : 'DRAFT';
    final statusIcon = isSent ? Icons.send_outlined : Icons.schedule_outlined;

    final preview = _summaryPreview();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFD1D5DB),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              debrief.clientName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(debrief.meetingDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.people_outline,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 5),
                Text(
                  '${_participantCount()} participants',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
