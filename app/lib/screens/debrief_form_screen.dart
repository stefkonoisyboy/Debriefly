import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class DebriefFormScreen extends StatefulWidget {
  final Debrief? debrief;

  const DebriefFormScreen({super.key, this.debrief});

  @override
  State<DebriefFormScreen> createState() => _DebriefFormScreenState();
}

class _DebriefFormScreenState extends State<DebriefFormScreen> {
  static const _navy = Color(0xFF1A1A2E);
  static const _amber = Color(0xFFF59E0B);
  static const _bg = Color(0xFFF2F3F7);
  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: Color(0xFF6B7280),
  );

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _clientNameCtrl = TextEditingController();
  final _participantsCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _decisionsCtrl = TextEditingController();
  final _risksCtrl = TextEditingController();

  DateTime? _meetingDate = DateTime.now();

  // Status
  String _status = 'draft';

  // Action items — each entry holds three controllers
  final List<_ActionItemEntry> _actionItems = [];

  // Validation errors
  bool _submitted = false;

  // AI Assist
  bool _showAiPanel = false;
  bool _isAiLoading = false;
  final _aiNotesCtrl = TextEditingController();

  bool get _isEditMode => widget.debrief != null;

  @override
  void initState() {
    super.initState();
    final d = widget.debrief;
    if (d != null) {
      _clientNameCtrl.text = d.clientName;
      _meetingDate = DateTime.tryParse(d.meetingDate);
      _status = d.status;
      _participantsCtrl.text = d.participants ?? '';
      _summaryCtrl.text = d.summary ?? '';
      _decisionsCtrl.text = d.decisionsMade ?? '';
      _risksCtrl.text = d.risksConcerns ?? '';
      for (final item in d.actionItems) {
        final entry = _ActionItemEntry();
        entry.descriptionCtrl.text = item.description;
        entry.ownerCtrl.text = item.owner;
        entry.dueDate = DateTime.tryParse(item.dueDate);
        _actionItems.add(entry);
      }
    }
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _participantsCtrl.dispose();
    _summaryCtrl.dispose();
    _decisionsCtrl.dispose();
    _risksCtrl.dispose();
    for (final e in _actionItems) {
      e.dispose();
    }
    _aiNotesCtrl.dispose();
    super.dispose();
  }

  void _addActionItem() {
    setState(() => _actionItems.add(_ActionItemEntry()));
  }

  void _removeActionItem(int index) {
    setState(() {
      _actionItems[index].dispose();
      _actionItems.removeAt(index);
    });
  }

  bool get _isFormValid {
    if (_clientNameCtrl.text.trim().isEmpty) return false;
    if (_meetingDate == null) return false;
    for (final item in _actionItems) {
      if (item.descriptionCtrl.text.trim().isEmpty) return false;
      if (item.ownerCtrl.text.trim().isEmpty) return false;
      if (item.dueDate == null) return false;
    }
    return true;
  }

  Future<void> _pickMeetingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _meetingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _navy,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _meetingDate = picked);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_isFormValid) return;

    final actionItems = _actionItems.map((e) {
      return ActionItem(
        description: e.descriptionCtrl.text.trim(),
        owner: e.ownerCtrl.text.trim(),
        dueDate: DateFormat('yyyy-MM-dd').format(e.dueDate!),
      );
    }).toList();

    final provider = context.read<DebriefProvider>();

    if (_isEditMode) {
      final request = UpdateDebriefRequest(
        clientName: _clientNameCtrl.text.trim(),
        meetingDate: DateFormat('yyyy-MM-dd').format(_meetingDate!),
        participants: _participantsCtrl.text.trim().isNotEmpty
            ? _participantsCtrl.text.trim()
            : null,
        summary: _summaryCtrl.text.trim().isNotEmpty
            ? _summaryCtrl.text.trim()
            : null,
        decisionsMade: _decisionsCtrl.text.trim().isNotEmpty
            ? _decisionsCtrl.text.trim()
            : null,
        risksConcerns: _risksCtrl.text.trim().isNotEmpty
            ? _risksCtrl.text.trim()
            : null,
        actionItems: actionItems,
        status: _status,
      );

      final updated = await provider.updateDebrief(widget.debrief!.id, request);

      if (!mounted) return;

      if (updated != null) {
        Navigator.of(context).pop(updated);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.actionError ?? 'Failed to update debrief'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final request = CreateDebriefRequest(
        clientName: _clientNameCtrl.text.trim(),
        meetingDate: DateFormat('yyyy-MM-dd').format(_meetingDate!),
        participants: _participantsCtrl.text.trim().isNotEmpty
            ? _participantsCtrl.text.trim()
            : null,
        summary: _summaryCtrl.text.trim().isNotEmpty
            ? _summaryCtrl.text.trim()
            : null,
        decisionsMade: _decisionsCtrl.text.trim().isNotEmpty
            ? _decisionsCtrl.text.trim()
            : null,
        risksConcerns: _risksCtrl.text.trim().isNotEmpty
            ? _risksCtrl.text.trim()
            : null,
        actionItems: actionItems.isNotEmpty ? actionItems : null,
        status: _status,
      );

      final created = await provider.createDebrief(request);

      if (!mounted) return;

      if (created != null) {
        Navigator.of(context).pop(created);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.actionError ?? 'Failed to save debrief'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              if (_showAiPanel) ...[
                const SizedBox(height: 16),
                _buildAiAssistPanel(),
              ],
              const SizedBox(height: 24),
              _buildCard(
                children: [
                  _buildClientNameField(),
                  const SizedBox(height: 20),
                  _buildMeetingDateField(),
                  const SizedBox(height: 20),
                  _buildStatusField(),
                  const SizedBox(height: 20),
                  _buildParticipantsField(),
                  const SizedBox(height: 20),
                  _buildSummaryField(),
                  const SizedBox(height: 20),
                  _buildDecisionsField(),
                  const SizedBox(height: 20),
                  _buildActionItemsSection(),
                  const SizedBox(height: 20),
                  _buildRisksField(),
                ],
              ),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runAiExtract() async {
    final notes = _aiNotesCtrl.text.trim();
    if (notes.isEmpty) return;

    setState(() => _isAiLoading = true);

    final provider = context.read<DebriefProvider>();
    final result = await provider.extractDebriefFields(notes);

    if (!mounted) return;

    setState(() {
      _isAiLoading = false;
      if (result != null) {
        if (result.clientName != null && result.clientName!.isNotEmpty) {
          _clientNameCtrl.text = result.clientName!;
        }
        if (result.meetingDate != null) {
          final parsed = DateTime.tryParse(result.meetingDate!);
          if (parsed != null) _meetingDate = parsed;
        }
        if (result.participants != null && result.participants!.isNotEmpty) {
          _participantsCtrl.text = result.participants!;
        }
        if (result.summary != null && result.summary!.isNotEmpty) {
          _summaryCtrl.text = result.summary!;
        }
        if (result.decisionsMade != null && result.decisionsMade!.isNotEmpty) {
          _decisionsCtrl.text = result.decisionsMade!;
        }
        if (result.risksConcerns != null && result.risksConcerns!.isNotEmpty) {
          _risksCtrl.text = result.risksConcerns!;
        }
        if (result.actionItems != null && result.actionItems!.isNotEmpty) {
          for (final e in _actionItems) {
            e.dispose();
          }
          _actionItems.clear();
          for (final item in result.actionItems!) {
            final entry = _ActionItemEntry();
            entry.descriptionCtrl.text = item.description;
            entry.ownerCtrl.text = item.owner;
            entry.dueDate = DateTime.tryParse(item.dueDate);
            _actionItems.add(entry);
          }
        }
        _showAiPanel = false;
      }
    });

    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.actionError ?? 'AI extraction failed'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAiAssistPanel() {
    return Container(
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, size: 18, color: _amber),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assist',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Paste notes & auto-extract debrief',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                onPressed: () => setState(() => _showAiPanel = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiNotesCtrl,
            minLines: 4,
            maxLines: 8,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  'Paste your raw meeting notes, transcript, or quick thoughts here...',
              hintStyle: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFF0F0F1A),
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF374151)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _amber, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAiLoading ? null : _runAiExtract,
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _amber.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              icon: _isAiLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                _isAiLoading ? 'Extracting...' : 'Extract Debrief Fields',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _navy, size: 22),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _navy,
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
              color: _navy,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: _navy),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back, size: 14, color: Color(0xFF6B7280)),
                    SizedBox(width: 4),
                    Text(
                      'Back to Debriefs',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isEditMode ? 'Edit Debrief' : 'New Debrief',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditMode
                    ? 'Update the debrief details below'
                    : 'Fill in the fields or use AI to extract from notes',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _showAiPanel = !_showAiPanel),
          style: OutlinedButton.styleFrom(
            foregroundColor: _amber,
            side: const BorderSide(color: _amber, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          icon: const Icon(Icons.auto_awesome, size: 16, color: _amber),
          label: const Text(
            'AI Assist',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: _amber,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: _labelStyle),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    bool hasError = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
          width: hasError ? 1.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFEF4444) : _navy,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildClientNameField() {
    final isEmpty = _submitted && _clientNameCtrl.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('CLIENT NAME', required: true),
        TextField(
          controller: _clientNameCtrl,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: 'e.g. ACME Corp',
            hasError: isEmpty,
          ),
          style: const TextStyle(fontSize: 14, color: _navy),
        ),
        if (isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Client name is required',
              style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            ),
          ),
      ],
    );
  }

  Widget _buildMeetingDateField() {
    final hasError = _submitted && _meetingDate == null;
    final displayText = _meetingDate != null
        ? DateFormat('dd.MM.yyyy').format(_meetingDate!)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('MEETING DATE'),
        GestureDetector(
          onTap: _pickMeetingDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE5E7EB),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText.isNotEmpty ? displayText : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: displayText.isNotEmpty
                          ? _navy
                          : const Color(0xFFADB5BD),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: hasError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Meeting date is required',
              style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('STATUS'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _status,
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: _navy),
              items: const [
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
                DropdownMenuItem(value: 'sent', child: Text('Sent')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('PARTICIPANTS'),
        TextField(
          controller: _participantsCtrl,
          decoration: _inputDecoration(
            hint: 'e.g. John (ACME), Sarah (Internal)',
          ),
          style: const TextStyle(fontSize: 14, color: _navy),
        ),
      ],
    );
  }

  Widget _buildSummaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('SUMMARY'),
        TextField(
          controller: _summaryCtrl,
          minLines: 4,
          maxLines: 8,
          decoration: _inputDecoration(
            hint:
                '• Discussed pricing changes\n• Agreed on pilot phase\n• Reviewed Q4 results',
          ),
          style: const TextStyle(fontSize: 14, color: _navy, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDecisionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('DECISIONS MADE'),
        TextField(
          controller: _decisionsCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: _inputDecoration(
            hint: '• Start pilot March 1\n• Budget approved for Q1',
          ),
          style: const TextStyle(fontSize: 14, color: _navy, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildActionItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('ACTION ITEMS', style: _labelStyle),
            const Spacer(),
            GestureDetector(
              onTap: _addActionItem,
              child: Row(
                children: const [
                  Icon(Icons.add, size: 16, color: _navy),
                  SizedBox(width: 2),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_actionItems.isNotEmpty) const SizedBox(height: 12),
        ...List.generate(_actionItems.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildActionItemRow(i),
          );
        }),
      ],
    );
  }

  Widget _buildActionItemRow(int index) {
    final entry = _actionItems[index];
    final descEmpty = _submitted && entry.descriptionCtrl.text.trim().isEmpty;
    final ownerEmpty = _submitted && entry.ownerCtrl.text.trim().isEmpty;
    final dateEmpty = _submitted && entry.dueDate == null;

    final dueDateText = entry.dueDate != null
        ? DateFormat('dd.MM.yyyy').format(entry.dueDate!)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: entry.descriptionCtrl,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(
                  hint: 'Task description',
                  hasError: descEmpty,
                ),
                style: const TextStyle(fontSize: 14, color: _navy),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeActionItem(index),
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        if (descEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Description is required',
              style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: entry.ownerCtrl,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(hint: 'Owner', hasError: ownerEmpty),
          style: const TextStyle(fontSize: 14, color: _navy),
        ),
        if (ownerEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Owner is required',
              style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            ),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: entry.dueDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _navy,
                    onPrimary: Colors.white,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() => entry.dueDate = picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dateEmpty
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE5E7EB),
                width: dateEmpty ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dueDateText.isNotEmpty ? dueDateText : 'Due date',
                    style: TextStyle(
                      fontSize: 14,
                      color: dueDateText.isNotEmpty
                          ? _navy
                          : const Color(0xFFADB5BD),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: dateEmpty
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (dateEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Due date is required',
              style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            ),
          ),
      ],
    );
  }

  Widget _buildRisksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('RISKS / CONCERNS', style: _labelStyle),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'OPTIONAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _risksCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: _inputDecoration(
            hint: 'Any risks or concerns to flag...',
          ),
          style: const TextStyle(fontSize: 14, color: _navy, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Consumer<DebriefProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isActionLoading;
        final isValid = _isFormValid;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (isLoading || (!isValid && _submitted)) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF9CA3AF),
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              isLoading
                  ? 'Saving...'
                  : (_isEditMode ? 'Save Changes' : 'Save Debrief'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        );
      },
    );
  }
}

class _ActionItemEntry {
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController ownerCtrl = TextEditingController();
  DateTime? dueDate;

  void dispose() {
    descriptionCtrl.dispose();
    ownerCtrl.dispose();
  }
}
