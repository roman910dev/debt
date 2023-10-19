import 'package:collection/collection.dart';
import 'package:debt/config.dart';
import 'package:debt/pages/add_entry.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/widgets/balance.dart';
import 'package:debt/widgets/confirm_dialog.dart';
import 'package:debt/widgets/debt_item_box.dart';
import 'package:debt/widgets/edit_person_dialog.dart';
import 'package:debt/widgets/menu_button.dart';
import 'package:debt/widgets/scaffold.dart';
import 'package:debt/widgets/selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_symbols_icons/symbols.dart';

class _MoneyListAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? personName;
  final List<DebtItem> items;
  final SelectionController<DebtItem> selection;
  final void Function() onSelectionEnd;
  final void Function()? onSettingsChanged;

  const _MoneyListAppBar({
    required this.items,
    required this.selection,
    required this.onSelectionEnd,
    this.personName,
    this.onSettingsChanged,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  State<_MoneyListAppBar> createState() => __MoneyListAppBarState();
}

class __MoneyListAppBarState extends State<_MoneyListAppBar> {
  void _listener() => setState(() {});

  List<ConfirmAction> get _confirmActions => [
        if (widget.selection.every((p) => p.checked))
          ConfirmActions.uncheck
        else
          ConfirmActions.check,
        ConfirmActions.delete,
      ];

  void _onEdit() => showDialog<DebtItem?>(
        context: context,
        builder: (BuildContext context) => EditDialog(
          item: widget.selection.first!,
          validator: widget.selection.first is Person
              ? (newItem) => newItem.text.isEmpty
                  ? 'Name cannot be empty!'
                  : newItem.text != widget.selection.first!.text &&
                          widget.items.any((i) => i.text == newItem.text)
                      ? 'Name already exists!'
                      : null
              : null,
        ),
      ).then((newItem) {
        if (newItem != null) people.replace(widget.selection.first!, newItem);
        widget.onSelectionEnd();
      });

  @override
  void initState() {
    super.initState();
    widget.selection.addListener(_listener);
  }

  @override
  void dispose() {
    widget.selection.removeListener(_listener);
    super.dispose();
  }

  Widget _buildAddButton() => IconButton(
        tooltip: 'Add entry',
        icon: const Icon(Symbols.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddDialog(personName: widget.personName),
        ),
      );

  Widget _buildMenu() => MenuButton(onChanged: widget.onSettingsChanged);

  Widget _buildEditButton() => IconButton(
        tooltip: 'Edit',
        icon: const Icon(Symbols.edit),
        onPressed: _onEdit,
      );

  Widget _buildConfirmButton(ConfirmAction action) => ConfirmButton(
        action: action,
        items: widget.items,
        selection: widget.selection,
        onConfirm: (newPeople) {
          if (newPeople != null) {
            if (newPeople.isEmpty) {
              people.clearAll(widget.personName);
            } else {
              people.replaceAll(newPeople);
            }
            widget.onSelectionEnd();
          }
        },
      );

  Widget _buildExitSelectButton() => IconButton(
        icon: const Icon(Symbols.close),
        onPressed: widget.onSelectionEnd,
      );

  @override
  Widget build(BuildContext context) => AppBar(
        leading: widget.selection.any ? _buildExitSelectButton() : null,
        title: Text(
          widget.selection.any
              ? widget.selection.single
                  ? widget.selection.first is Person
                      ? widget.selection.first!.text
                      : '1 item'
                  : '${widget.selection.length} items'
              : widget.personName != null
                  ? widget.personName!
                  : 'Debt Tracker',
        ),
        actions: [
          if (widget.selection.any) ...[
            if (widget.selection.single) _buildEditButton(),
            for (final action in _confirmActions) _buildConfirmButton(action),
          ] else ...[
            _buildAddButton(),
            if (widget.personName == null) _buildMenu() else const SizedBox(width: 16),
          ],
        ],
      );
}

class MoneyList extends StatefulWidget {
  final String? personName;

  const MoneyList(this.personName, {super.key});

  @override
  MoneyListState createState() => MoneyListState();
}

class MoneyListState extends State<MoneyList> {
  List<DebtItem> _items = [];
  BannerAd? _bannerAd;

  void _listener() => setState(() {
        _items = widget.personName == null
            ? people.people.cast()
            : (people.people.firstWhereOrNull((p) => p.text == widget.personName)?.entries ?? [])
                .cast();
        if (widget.personName != null && _items.isEmpty) Navigator.pop(context);
        _items = _items.debtSorted;
      });

  void _loadAd() {
    if (!DebtData.isMobile) return;
    if (DebtSettings.showAds && _bannerAd == null) {
      _bannerAd = BannerAd(
        adUnitId: devMode
            ? //test
            'ca-app-pub-3940256099942544/6300978111'
            : //prod
            'ca-app-pub-8832562785647597/8322552151',
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        ),
      )..load();
    } else if (!DebtSettings.showAds && _bannerAd != null) {
      _bannerAd?.dispose();
      _bannerAd = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
    people.addListener(_listener..call());
  }

  @override
  void dispose() {
    people.removeListener(_listener);
    _bannerAd?.dispose();
    super.dispose();
  }

  final SelectionController<DebtItem> selection = SelectionController();

  void _onSelectionEnd() => setState(selection.clear);

  Widget _buildBalance() => Balance(selection: selection, items: _items);

  Widget _buildItem(int i) => DebtItemBox(item: _items[i - 1], selection: selection);

  @override
  Widget build(BuildContext context) => DebtScaffold(
        appBar: _MoneyListAppBar(
          items: _items,
          selection: selection,
          onSelectionEnd: _onSelectionEnd,
          personName: widget.personName,
          onSettingsChanged: () {
            DebtSettings.save();
            _loadAd();
            setState(() {});
          },
        ),
        body: Stack(
          children: [
            if (!people.initialized)
              const LinearProgressIndicator()
            else if (_items.isEmpty)
              const Center(
                child: Text(
                  'You have no entries yet :(\n'
                  'Press the + button to add the first one.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                // balance + items + ad?
                itemCount: _items.length + (_bannerAd == null ? 1 : 2),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: i == 0
                      ? _buildBalance()
                      : i == _items.length + 1
                          ? SizedBox(height: _bannerAd!.size.height.toDouble())
                          : _buildItem(i),
                ),
              ),
            if (_bannerAd != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
          ],
        ),
      );
}
