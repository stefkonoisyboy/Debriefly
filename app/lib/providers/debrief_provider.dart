import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

enum DebriefListStatus { initial, loading, loaded, error }

enum DebriefActionStatus { idle, loading, success, error }

class DebriefProvider extends ChangeNotifier {
  final DebriefService _service;

  DebriefProvider({DebriefService? service})
    : _service = service ?? DebriefService();

  // ── List state ──────────────────────────────────────────────────────────────

  List<Debrief> _debriefs = [];
  DebriefListStatus _listStatus = DebriefListStatus.initial;
  String? _listError;

  List<Debrief> get debriefs => List.unmodifiable(_debriefs);
  DebriefListStatus get listStatus => _listStatus;
  String? get listError => _listError;
  bool get isListLoading => _listStatus == DebriefListStatus.loading;

  // ── Selected debrief state ───────────────────────────────────────────────────

  Debrief? _selectedDebrief;
  DebriefListStatus _detailStatus = DebriefListStatus.initial;
  String? _detailError;

  Debrief? get selectedDebrief => _selectedDebrief;
  DebriefListStatus get detailStatus => _detailStatus;
  String? get detailError => _detailError;
  bool get isDetailLoading => _detailStatus == DebriefListStatus.loading;

  // ── Action state (create / update / delete / email) ──────────────────────────

  DebriefActionStatus _actionStatus = DebriefActionStatus.idle;
  String? _actionError;

  DebriefActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  bool get isActionLoading => _actionStatus == DebriefActionStatus.loading;

  // ── Actions ──────────────────────────────────────────────────────────────────

  /// Loads all debriefs for the current [userId].
  Future<void> loadDebriefs({String? userId}) async {
    _listStatus = DebriefListStatus.loading;
    _listError = null;
    notifyListeners();

    try {
      _debriefs = await _service.getDebriefs(userId: userId);
      _listStatus = DebriefListStatus.loaded;
    } on ApiException catch (e) {
      _listStatus = DebriefListStatus.error;
      _listError = e.message;
    } catch (e) {
      _listStatus = DebriefListStatus.error;
      _listError = e.toString();
    }

    notifyListeners();
  }

  /// Loads a single debrief by [id] and sets it as [selectedDebrief].
  Future<void> loadDebrief(String id) async {
    _detailStatus = DebriefListStatus.loading;
    _detailError = null;
    notifyListeners();

    try {
      _selectedDebrief = await _service.getDebrief(id);
      _detailStatus = DebriefListStatus.loaded;
    } on ApiException catch (e) {
      _detailStatus = DebriefListStatus.error;
      _detailError = e.message;
    } catch (e) {
      _detailStatus = DebriefListStatus.error;
      _detailError = e.toString();
    }

    notifyListeners();
  }

  /// Creates a new debrief.
  /// Returns the created [Debrief] on success, or `null` on failure.
  Future<Debrief?> createDebrief(
    CreateDebriefRequest request, {
    String? userId,
  }) async {
    _setActionLoading();

    try {
      final created = await _service.createDebrief(request, userId: userId);
      _debriefs = [created, ..._debriefs];
      _setActionSuccess();
      return created;
    } on ApiException catch (e) {
      _setActionError(e.message);
      return null;
    } catch (e) {
      _setActionError(e.toString());
      return null;
    }
  }

  /// Updates the debrief identified by [id].
  /// Returns the updated [Debrief] on success, or `null` on failure.
  Future<Debrief?> updateDebrief(
    String id,
    UpdateDebriefRequest request,
  ) async {
    _setActionLoading();

    try {
      final updated = await _service.updateDebrief(id, request);
      _debriefs = [for (final d in _debriefs) d.id == id ? updated : d];
      if (_selectedDebrief?.id == id) {
        _selectedDebrief = updated;
      }
      _setActionSuccess();
      return updated;
    } on ApiException catch (e) {
      _setActionError(e.message);
      return null;
    } catch (e) {
      _setActionError(e.toString());
      return null;
    }
  }

  /// Deletes the debrief identified by [id].
  /// Returns `true` on success.
  Future<bool> deleteDebrief(String id) async {
    _setActionLoading();

    try {
      await _service.deleteDebrief(id);
      _debriefs = _debriefs.where((d) => d.id != id).toList();
      if (_selectedDebrief?.id == id) {
        _selectedDebrief = null;
      }
      _setActionSuccess();
      return true;
    } on ApiException catch (e) {
      _setActionError(e.message);
      return false;
    } catch (e) {
      _setActionError(e.toString());
      return false;
    }
  }

  /// Sends the debrief identified by [id] via email.
  /// Returns `true` on success.
  Future<bool> emailDebrief(String id, EmailDebriefRequest request) async {
    _setActionLoading();

    try {
      await _service.emailDebrief(id, request);
      _setActionSuccess();
      return true;
    } on ApiException catch (e) {
      _setActionError(e.message);
      return false;
    } catch (e) {
      _setActionError(e.toString());
      return false;
    }
  }

  /// Clears the currently selected debrief.
  void clearSelectedDebrief() {
    _selectedDebrief = null;
    _detailStatus = DebriefListStatus.initial;
    _detailError = null;
    notifyListeners();
  }

  /// Resets the action status back to [DebriefActionStatus.idle].
  void resetActionStatus() {
    _actionStatus = DebriefActionStatus.idle;
    _actionError = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setActionLoading() {
    _actionStatus = DebriefActionStatus.loading;
    _actionError = null;
    notifyListeners();
  }

  void _setActionSuccess() {
    _actionStatus = DebriefActionStatus.success;
    notifyListeners();
  }

  void _setActionError(String message) {
    _actionStatus = DebriefActionStatus.error;
    _actionError = message;
    notifyListeners();
  }
}
