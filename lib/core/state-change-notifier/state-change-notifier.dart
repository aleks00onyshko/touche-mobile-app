// !important as Dart doesn't support Partial<T> I would cast them as T where T = Partial<T>
import 'package:flutter/widgets.dart';
import 'package:touche_app/core/state-change-notifier/state.dart';

abstract interface class ChangeNotifierWithState<T extends ChangeNotifierState> {
  late Map<String, dynamic> _initialState;
  late Map<String, dynamic> _state;

  Map<String, dynamic> get state;

  void initState(T state);
  void patchState(Map<String, dynamic> newState, bool? emitEvent);
  void resetState();
}

abstract class StateChangeNotifier<T extends ChangeNotifierState> extends ChangeNotifier implements ChangeNotifierWithState<T> {
  @override
  late Map<String, dynamic> _state;
  @override
  late Map<String, dynamic> _initialState;

  @override
  Map<String, dynamic> get state => _state;

  StateChangeNotifier(T initialState) {
    initState(initialState);
  }

  @override
  void initState(T state) {
    _initialState = state.toMap();
    _state = state.toMap();

    notifyListeners();
  }

  @override
  void patchState(Map<String, dynamic> newState, [bool? emitEvent]) {
    newState.forEach((key, value) {
      _state.update(key, (_) => value);
    });

    if (emitEvent ?? true) {
      notifyListeners();
    }
  }

  @override
  void resetState() {
    _state = _initialState;

    notifyListeners();
  }
}
