import 'package:collection/collection.dart';
import 'package:debt/config.dart';
import 'package:debt/pages/entry_list/widgets/appbar.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/widgets/balance.dart';
import 'package:debt/widgets/debt_item_tile.dart';
import 'package:debt/scripts/selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// The page that displays the list of entries.
/// It is the main page of the app, the only one that contains a [Scaffold].
///
/// It can be used to display the list of entries of a specific person
/// by passing the person's name to the [personName] parameter.
///
/// If [personName] is `null`, the page will display the list of persons.
class EntryList extends StatefulWidget {
  /// The name of the person whose page is being displayed. Use `null` for the main page.
  final String? personName;

  const EntryList(this.personName, {super.key});

  @override
  EntryListState createState() => EntryListState();
}

class EntryListState extends State<EntryList> {
  /// The list of items in the page.
  List<DebtItem> _items = [];

  /// The banner ad displayed at the bottom of the page.
  /// If ads are disabled or not yet loaded, this will be `null`.
  BannerAd? _bannerAd;

  final SelectionController<DebtItem> _selection = SelectionController();

  void _onSelectionEnd() => setState(_selection.clear);

  /// Gets and sorts [_items].
  void _listener() => setState(() {
        _items = widget.personName == null
            ? people.people.cast()
            : (people.people
                        .firstWhereOrNull((p) => p.text == widget.personName)
                        ?.entries ??
                    [])
                .cast();
        if (widget.personName != null && _items.isEmpty) Navigator.pop(context);
        _items = _items.debtSorted;
      });

  void _loadAd() {
    if (!DebtEnv.isMobile) return;
    if (DebtSettings.showAds && _bannerAd == null) {
      _bannerAd = BannerAd(
        adUnitId: DebtEnv.devMode
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

  Widget _buildBalance() => Balance(selection: _selection, items: _items);

  Widget _buildItem(int i) =>
      DebtItemTile(item: _items[i - 1], selection: _selection);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DebtSettings.theme == ThemeMode.light
            ? Colors.white
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: EntryListAppBar(
          items: _items,
          selection: _selection,
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
