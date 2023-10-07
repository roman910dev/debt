import 'package:flutter/foundation.dart';

class SelectionController<DebtItem> extends ChangeNotifier {
  final Set<DebtItem> _set;

  SelectionController([Set<DebtItem>? initialSelected]) : _set = initialSelected ?? {};

  bool get any => _set.isNotEmpty;

  bool get single => _set.length == 1;

  bool isSelected(DebtItem value) => _set.contains(value);

  bool every(bool Function(DebtItem) test) => _set.every(test);

  int get length => _set.length;

  DebtItem? get first => _set.isEmpty ? null : _set.first;

  Set<DebtItem> get selectedItems => _set;

  void select(DebtItem value) {
    _set.add(value);
    notifyListeners();
  }

  void unSelect(DebtItem value) {
    _set.remove(value);
    notifyListeners();
  }

  void toggle(DebtItem value) {
    if (isSelected(value)) {
      unSelect(value);
    } else {
      select(value);
    }
  }

  clear() {
    _set.clear();
    notifyListeners();
  }
}

class BoolController extends ChangeNotifier {
  bool _value;

  BoolController([this._value = false]);

  bool get value => _value;

  set value(bool newValue) {
    _value = newValue;
    notifyListeners();
  }

  void toggle() {
    value = !value;
  }
}
