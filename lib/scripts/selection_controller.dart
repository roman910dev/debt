import 'package:flutter/foundation.dart';

/// A controller that manages the selection of [DebtItem]s.
class SelectionController<DebtItem> extends ChangeNotifier {
  final Set<DebtItem> _set;

  SelectionController([Set<DebtItem>? initialSelected])
      : _set = initialSelected ?? {};

  /// Whether any item is selected, i.e. the selection is not empty.
  bool get any => _set.isNotEmpty;

  /// Whether only one item is selected, i.e. the selection contains exactly one item.
  bool get single => _set.length == 1;

  /// Whether the given [item] is selected.
  bool isSelected(DebtItem item) => _set.contains(item);

  /// Whether every item in the selection satisfies the given [test].
  bool every(bool Function(DebtItem) test) => _set.every(test);

  /// The number of items in the selection.
  int get size => _set.length;

  /// The first item in the selection, if any.
  DebtItem? get first => _set.isEmpty ? null : _set.first;

  /// The selected items.
  Set<DebtItem> get selectedItems => _set;

  void select(DebtItem value) {
    _set.add(value);
    notifyListeners();
  }

  void unSelect(DebtItem value) {
    _set.remove(value);
    notifyListeners();
  }

  /// Selects [item] if not selected and unselects it if selected.
  void toggle(DebtItem item) =>
      isSelected(item) ? unSelect(item) : select(item);

  /// Clears the selection.
  clear() {
    _set.clear();
    notifyListeners();
  }
}
