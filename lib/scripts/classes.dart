import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:debt/config.dart';
import 'package:debt/tools.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class DebtItem {
  String get text;
  num get money;
  DateTime get date;
  bool get checked;

  DebtItem withText(String text);
  DebtItem withChecked(bool checked);

  const DebtItem();

  List toList();

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
  final String person;
  final String description;
  @override
  final num money;
  @override
  final DateTime date;
  @override
  final bool checked;

  @override
  String get text => description;

  const Entry({
    required this.person,
    required this.description,
    required this.money,
    required this.date,
    this.checked = false,
  });

  Entry copyWith({
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

  Entry withDescription(String description) => copyWith(description: description);

  Entry withDate(DateTime date) => copyWith(date: date);

  @override
  Entry withChecked(bool checked) => copyWith(checked: checked);

  Entry rename(String person) => copyWith(person: person);

  Entry.legacyParse(String data, {bool checked = false})
      : this(
          money: num.parse(data.split('~|~')[0]),
          person: data.split('~|~')[1],
          description: data.split('~|~')[2],
          date: DebtDateTime.parse(data.split('~|~')[3]),
          checked: checked,
        );

  Entry.fromList(List data)
      : this(
          person: data[0],
          description: data[1],
          money: data[2],
          date: DebtDateTime.fromSecondsSinceEpoch(data[3]),
          checked: data[4],
        );

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
  final String name;
  final List<Entry> entries;

  const Person({required this.name, required this.entries});

  @override
  String get text => name;

  @override
  bool get checked => entries.every((e) => e.checked);

  @override
  num get money => entries.balance;

  @override
  DateTime get date => entries.debtSorted.map((e) => e.date).first;

  @override
  Person withText(String text) => rename(text);

  @override
  Person withChecked(bool checked) => Person(
        name: name,
        entries: [for (final e in entries) e.withChecked(checked)],
      );

  Person rename(String name) => Person(
        name: name,
        entries: [for (final e in entries) e.rename(name)],
      );

  Person.fromList(String person, List<List> data)
      : this(
          name: person,
          entries: [for (final e in data.where((d) => d[0] == person)) Entry.fromList(e)],
        );

  @override
  List<List> toList() => [for (final e in entries) e.toList()];
}

extension DebtItems on Iterable<DebtItem> {
  // using *where* may lead to an empty iterable, which would cause an error on *reduce*
  num get balance => map((e) => e.checked ? 0 : e.money).reduce((a, b) => a + b);

  List<DebtItem> get debtSorted => toList().reversed.sorted((a, b) => a.compareTo(b));
}

// TODO(roman910dev): move this somewhere else
extension People on List<Person> {
  static List<Entry> legacyParse(List<String> unchecked, List<String> checked) => [
        for (final entries in [unchecked, checked]) ...[
          for (final entry in entries.reversed) ...[
            Entry.legacyParse(entry, checked: entries == checked),
          ],
        ],
      ];

  static List<Person> fromJson(List<List> data) => [
        for (final p in {for (final d in data) d[0]}) Person.fromList(p, data),
      ];

  List<List> toJson() =>
      [for (final p in this) ...p.toList()].sorted((a, b) => a[3].compareTo(b[3]));

  String toCSV() => toJson().map((e) {
        e[3] = DebtDateTime.fromSecondsSinceEpoch(e[3]).toFormattedString();
        return e.join(',');
      }).join('\n');

  static Future<List<Entry>> load([SharedPreferences? prefs]) async {
    prefs ??= await SharedPreferences.getInstance();
    if (devMode) {
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
      return legacyParse(expr, dexpr);
    } else if (prefs.containsKey('data')) {
      final List<List> data = jsonDecode(prefs.getString('data')!).cast<List>() as List<List>;
      return [for (final d in data) Entry.fromList(d)];
    }
    return [];
  }
}

class PeopleController extends ChangeNotifier {
  bool _initialized = false;
  final List<Person> people = [];
  late final SharedPreferences _prefs;

  PeopleController();

  bool get initialized => _initialized;

  void _legacyCleanup() => _prefs
    ..remove('expr')
    ..remove('dexpr');

  Future<void> initialize() async {
    _initialized = true;
    _prefs = await SharedPreferences.getInstance();
    addAll(await People.load(_prefs));
    _legacyCleanup();
    notifyListeners();
  }

  void _setData() {
    if (!devMode) _prefs.setString('data', jsonEncode(people.toJson()));
    notifyListeners();
  }

  Person _parent(Entry entry) => people.firstWhere((p) => p.name == entry.person);

  bool _sameDate(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

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

  void setChecked(DebtItem item, bool checked) => replace(item, item.withChecked(checked));

  void replace(DebtItem oldItem, DebtItem newItem) {
    if (oldItem is Person && newItem is Person) {
      final int index = people.indexOf(oldItem);
      people[index] = newItem;
    } else if (oldItem is Entry && newItem is Entry) {
      final Person person = _parent(oldItem);
      final int entryIndex = person.entries.indexOf(oldItem);
      person.entries[entryIndex] = newItem.withDate(
        _sameDate(newItem.date, oldItem.date) ? oldItem.date : _sortableDate(newItem.date),
      );
    }
    _setData();
  }

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
    final Person? person = people.firstWhereOrNull((p) => p.name == entry.person);
    final Entry correctedEntry = entry.withDate(_sortableDate(entry.date));
    if (person == null) {
      people.add(Person(name: entry.person, entries: [correctedEntry]));
    } else {
      person.entries.add(correctedEntry);
    }
  }

  void addAll(List<Entry> entries) {
    for (final entry in entries) {
      _addEntry(entry);
    }
    _setData();
  }

  void addEntry(Entry entry) {
    _addEntry(entry);
    _setData();
  }

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
