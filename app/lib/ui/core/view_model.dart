import 'package:flutter/foundation.dart';

/// Base for screens that load data: loading/error state, reload when the
/// repository changes, safe to call after dispose.
abstract class LoadingViewModel extends ChangeNotifier {
  LoadingViewModel([this._source]) {
    _source?.addListener(_refresh);
  }

  final Listenable? _source;
  bool loading = true;
  Object? error;
  bool _disposed = false;

  @protected
  Future<void> fetch();

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    await _refresh();
  }

  Future<void> _refresh() async {
    try {
      await fetch();
      error = null;
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @protected
  void changed() => _notify();

  @override
  void dispose() {
    _disposed = true;
    _source?.removeListener(_refresh);
    super.dispose();
  }
}
