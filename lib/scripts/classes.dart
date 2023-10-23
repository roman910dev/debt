import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:debt/config.dart';
import 'package:debt/tools.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An immutable abstract class representing a debt item.
///
/// This is the parent class of [Entry] and [Person].
sealed class DebtItem {
  /// The text of the item.
  ///
  /// This is [Entry.description] for [Entry]s and [Person.name] for [Person]s.
  String get text;

  /// The amount of money of the item.
  num get money;

  /// The date of the item.
  DateTime get date;

  /// Whether the item is checked.
  bool get checked;

  /// Creates a copy of the item with the given text.
  DebtItem withText(String text);

  /// Creates a copy of the item with the given checked value.
  DebtItem withChecked(bool checked);

  /// Returns the item with the renamed [person].
  DebtItem rename(String personName);

  const DebtItem();

  List toList();

  /// Compares this item to an[other] one.
  ///
  /// The comparison is based on [checked] (unchecked first).
  /// If [checked] is equal, the comparison is based on [date] (latest date first).
  int compareTo(DebtItem other) => checked == other.checked
      ? -date.compareTo(other.date)
      : checked
          ? 1
          : -1;

  @override
  String toString() => jsonEncode(toList());

  @override
  operator ==(other) =>
      other is DebtItem &&
      other.text == text &&
      other.money == money &&
      other.date == date &&
      other.checked == checked;

  @override
  int get hashCode => Object.hash(text, money, date, checked);
}

class Entry extends DebtItem {
  /// The person who this entry refers to.
  final String person;

  /// The description of the entry.
  final String description;

  @override
  final num money;
  @override
  final DateTime date;
  @override
  final bool checked;

  /// The [description] of the entry.
  @override
  String get text => description;

  const Entry({
    required this.person,
    required this.description,
    required this.money,
    required this.date,
    this.checked = false,
  });

  Entry _copyWith({
    String? person,
    String? description,
    num? money,
    DateTime? date,
    bool? checked,
  }) =>
      Entry(
        person: person ?? this.person,
        description: description ?? this.description,
        money: money ?? this.money,
        date: date ?? this.date,
        checked: checked ?? this.checked,
      );

  @override
  Entry withText(String text) => withDescription(text);

  Entry withDescription(String description) =>
      _copyWith(description: description);

  Entry withDate(DateTime date) => _copyWith(date: date);

  @override
  Entry withChecked(bool checked) => _copyWith(checked: checked);

  @override
  Entry rename(String personName) => _copyWith(person: personName);

  Entry._legacyParse(String data, {bool checked = false})
      : this(
          money: num.parse(data.split('~|~')[0]),
          person: data.split('~|~')[1],
          description: data.split('~|~')[2],
          date: DebtDateTime.parse(data.split('~|~')[3]),
          checked: checked,
        );

  /// Parses a list of data into an [Entry].
  ///
  /// List must follow the format defined in [toList].
  Entry.fromList(List data)
      : this(
          person: data[0],
          description: data[1],
          money: data[2],
          date: DebtDateTime.fromSecondsSinceEpoch(data[3]),
          checked: data[4],
        );

  /// Returns a list of data representing the entry.
  ///
  /// The list follows the format:
  /// `[person, description, money, date, checked]`.
  @override
  List toList() => [
        person,
        description,
        money,
        date.secondsSinceEpoch,
        checked,
      ];
}

class Person extends DebtItem {
  /// The name of the person.
  final String name;

  /// The list of entries of the person.
  final List<Entry> entries;

  const Person({required this.name, required this.entries});

  /// The [name] of the person.
  @override
  String get text => name;

  @override
  bool get checked => entries.every((e) => e.checked);

  @override
  num get money => entries.balance;

  /// The latest date of the entries of the person.
  @override
  DateTime get date => entries.debtSorted.map((e) => e.date).first;

  @override
  Person withText(String text) => rename(text);

  @override
  Person withChecked(bool checked) => Person(
        name: name,
        entries: [for (final e in entries) e.withChecked(checked)],
      );

  @override
  Person rename(String personName) => Person(
        name: personName,
        entries: [for (final e in entries) e.rename(personName)],
      );

  Person.fromList(String person, List<List> data)
      : this(
          name: person,
          entries: [
            for (final e in data.where((d) => d[0] == person))
              Entry.fromList(e),
          ],
        );

  @override
  List<List> toList() => [for (final e in entries) e.toList()];
}

extension DebtItems on Iterable<DebtItem> {
  // using *where* may lead to an empty iterable, which would cause an error on *reduce*
  /// Returns the balance of the items. This is the sum of their [DebtItem.money] values.
  ///
  /// For [DebtItem.checked] items, the balance is 0.
  num get balance =>
      map((e) => e.checked ? 0 : e.money).reduce((a, b) => a + b);

  /// Returns the items sorted by [DebtItem.checked] and [DebtItem.date],
  /// using [DebtItem.compareTo].
  List<DebtItem> get debtSorted =>
      toList().reversed.sorted((a, b) => a.compareTo(b));
}

extension People on List<Person> {
  static List<Entry> _legacyParse(
    List<String> unchecked,
    List<String> checked,
  ) =>
      [
        for (final entries in [unchecked, checked]) ...[
          for (final entry in entries.reversed) ...[
            Entry._legacyParse(entry, checked: entries == checked),
          ],
        ],
      ];

  static List<Person> fromJson(List<List> data) => [
        for (final p in {for (final d in data) d[0]}) Person.fromList(p, data),
      ];

  List<List> toJson() => [for (final p in this) ...p.toList()]
      .sorted((a, b) => a[3].compareTo(b[3]));

  String toCSV() => toJson().map((e) {
        e[3] = DebtDateTime.fromSecondsSinceEpoch(e[3]).toFormattedString();
        return e.join(',');
      }).join('\n');

  static Future<List<Entry>> load([SharedPreferences? prefs]) async {
    prefs ??= await SharedPreferences.getInstance();
    if (DebtEnv.devMode) {
      return [
        ['Ross', '', -10, 1697493601, false],
        ['Joey', '', 750, 1697493602, false],
        ['Rachel', '', 70, 1697493603, false],
        ['Monica', '', -30, 1697493604, false],
        ['Phoebe', '', 10, 1697493606, true],
        ['Ross', '', 10, 1697493607, true],
        ['Chandler', "McDonald's", 9.75, 1697493608, false],
        ['Chandler', 'Duck', -24.99, 1697493609, false],
        ['Chandler', 'Chick', -19.99, 1697493610, false],
        ['Chandler', 'Armchair', -300, 1697493611, false],
        ['Chandler', 'Pizza night', 15.48, 1697493612, false],
        ['Chandler', 'Food', 8.7, 1697493613, false],
        ['Chandler', 'Cinema', 9.1, 1697493614, true],
      ].map(Entry.fromList).toList();
    } else if (['expr', 'dexpr'].any((k) => prefs!.containsKey(k))) {
      final List<String> expr = prefs.getStringList('expr') ?? [];
      final List<String> dexpr = prefs.getStringList('dexpr') ?? [];
      return _legacyParse(expr, dexpr);
    } else if (prefs.containsKey('data')) {
      final List<List> data =
          jsonDecode(prefs.getString('data')!).cast<List>() as List<List>;
      return [for (final d in data) Entry.fromList(d)];
    }
    return [];
  }
}

/// A controller that manages a list of [Person]s ([people]).
class PeopleController extends ChangeNotifier {
  bool _initialized = false;
  final List<Person> people = [];
  late final SharedPreferences _prefs;

  PeopleController();

  /// Whether the controller has been initialized.
  ///
  /// This is `true` after [initialize] is called.
  bool get initialized => _initialized;

  void _legacyCleanup() => _prefs
    ..remove('expr')
    ..remove('dexpr');

  /// Initializes the controller. This can only be done once.
  Future<void> initialize() async {
    _initialized = true;
    _prefs = await SharedPreferences.getInstance();
    addAll(await People.load(_prefs));
    _legacyCleanup();
    notifyListeners();
  }

  void _setData() {
    if (!DebtEnv.devMode) _prefs.setString('data', jsonEncode(people.toJson()));
    notifyListeners();
  }

  /// Returns the [Person] that contains [entry].
  Person _parent(Entry entry) =>
      people.firstWhere((p) => p.name == entry.person);

  /// Wether dates [a] and [b] are the same day of the same month of the same year.
  bool _sameDate(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  /// If [date] is the same date as one of the dates of the entries of the people,
  /// it returns the latest date plus 1 second.
  ///
  /// Otherwise, it returns the [date] itself.
  ///
  /// Note that dates are always returned without time,
  /// so at 0:00 (plus the added seconds to avoid date collisions).
  DateTime _sortableDate(DateTime date) => DateTime.fromMillisecondsSinceEpoch(
        ([for (final p in people) ...p.entries]
                        .map((e) => e.date)
                        .where(
                          (d) => _sameDate(date, d),
                        )
                        .maxOrNull ??
                    DateTime(date.year, date.month, date.day))
                .millisecondsSinceEpoch +
            1000,
      );

  /// Replaces [oldItem] with [newItem], if they are of the same type.
  void replace(DebtItem oldItem, DebtItem newItem) {
    if (oldItem is Person && newItem is Person) {
      final int index = people.indexOf(oldItem);
      people[index] = newItem;
    } else if (oldItem is Entry && newItem is Entry) {
      final Person person = _parent(oldItem);
      final int entryIndex = person.entries.indexOf(oldItem);
      person.entries[entryIndex] = newItem.withDate(
        _sameDate(newItem.date, oldItem.date)
            ? oldItem.date
            : _sortableDate(newItem.date),
      );
    }
    _setData();
  }

  /// Sets the [checked] value of [item] to [checked].
  void setChecked(DebtItem item, bool checked) =>
      replace(item, item.withChecked(checked));

  /// Replaces all the existing items with [newItems].
  ///
  /// [newItems] must not be empty, use [clearAll] to clear all entries.
  void replaceAll(List<DebtItem> newItems) {
    if (newItems.isEmpty) {
      throw ArgumentError.value(
        newItems,
        'newPeople',
        ''
            '\'replaceAll\' cannot be called with an empty list. '
            'If you want to clear all entries, use \'clearAll\' instead.',
      );
    }
    if (newItems.first is Person) {
      people
        ..clear()
        ..addAll(newItems.cast());
    } else if (newItems.first is Entry) {
      final Person person = _parent(newItems.first as Entry);
      person.entries
        ..clear()
        ..addAll(newItems.cast());
    }
    _setData();
  }

  /// If [personName] is `null`, clears all [Person]s.
  ///
  /// Otherwise, reomoves the [Person] with the given name.
  void clearAll(String? personName) {
    if (personName == null) {
      people.clear();
    } else {
      final Person person = people.firstWhere((p) => p.name == personName);
      people.remove(person);
    }
    _setData();
  }

  void _addEntry(Entry entry) {
    final Person? person =
        people.firstWhereOrNull((p) => p.name == entry.person);
    final Entry correctedEntry = entry.withDate(_sortableDate(entry.date));
    if (person == null) {
      people.add(Person(name: entry.person, entries: [correctedEntry]));
    } else {
      person.entries.add(correctedEntry);
    }
  }

  /// Adds [entry] to the list of entries of the person with the same name,
  /// or creates a new person if it doesn't exist.
  void addEntry(Entry entry) {
    _addEntry(entry);
    _setData();
  }

  /// Adds all [entries].
  ///
  /// It calls [addEntry] for each entry.
  void addAll(List<Entry> entries) {
    for (final entry in entries) {
      _addEntry(entry);
    }
    _setData();
  }

  /// Deletes [entry] from the list of entries of the person with the same name.
  /// 
  /// If the entry is the only one of the person, the person is deleted.
  void deleteEntry(Entry entry) {
    final Person person = people.firstWhere((p) => p.name == entry.person);
    if (person.entries.length == 1 && person.entries.first == entry) {
      people.remove(person);
    } else {
      person.entries.remove(entry);
    }
    if (person.entries.isEmpty) people.remove(person);
    _setData();
  }
}
