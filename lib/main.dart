import 'dart:io';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/tools.dart';
import 'package:expressions/expressions.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

bool iOSWeb = false;

ExpressionEvaluator eval = ExpressionEvaluator();

TextStyle safariStyle({Color color, FontWeight fontWeight}) => TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.white.withOpacity(.01),
    fontFamily: 'Roboto',
    fontFamilyFallback: const ['Helvetica', 'Arial', 'sans-serif'],
    color: color,
    fontWeight: fontWeight
);

var header = TextStyle(
    fontSize: 20.0, color: Color(0xde000000), fontWeight: FontWeight.bold);
Map<String, num> nums = Map<String, num>();
var dates = Map();
var ddates = Map();
List<String> expr = [];
List<String> dexpr = [];
var todo;
var flnp;
var notiDetails;
var id = 0;
CurrencyFormatterSettings currency;
bool localCurrency = false;
String locale;
bool showAds = true;
CurrencyFormatter cf = CurrencyFormatter();

ValueNotifier theme = ValueNotifier('system');
List<String> themes = ['light', 'dark', 'system'];

BannerAd banner;
bool activeBanner = false;

bool calc = false;

class AboutTile {
  IconData leading;
  String title;
  String subtitle;
  String action;

  AboutTile(this.leading, this.title, this.subtitle, this.action);
}

List<AboutTile> aboutInfo = [
  AboutTile(Icons.share, 'Tell your friends about this app', 'Share this app',
      'share'),
  AboutTile(Icons.web, 'Visit my website', 'https://roman910.tk',
      'https://roman910.tk'),
  AboutTile(Icons.shop, 'Check out my other Android apps', 'Google Play Store',
      'https://play.google.com/store/apps/developer?id=Rom%C3%A1n+Via-Dufresne+Saus'),
  AboutTile(Icons.email, 'Reach me out', 'roman910dev@gmail.com',
      'mailto:roman910dev@gmail.com?subject=Debt Tracker Feedback'),
];

ThemeData lightTheme = ThemeData(
  // fontFamily: iOSWeb
  //     ? '--apple-system'
  //     : null,
  errorColor: Colors.red,
  cardColor: Colors.white,
  primaryTextTheme: TextTheme(
      headline1: safariStyle(),
      headline2: safariStyle(),
      headline3: safariStyle(),
      headline4: safariStyle(),
      headline5: safariStyle(),
      headline6: safariStyle(
          color: Colors.green,
          fontWeight: FontWeight.w500
      ),
      subtitle1: safariStyle(),
      subtitle2: safariStyle(),
      bodyText1: safariStyle(),
      bodyText2: safariStyle(),
      caption: safariStyle(),
      button: safariStyle(),
      overline: safariStyle()
  ),
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(
        color: Colors.green,
        fontSize: 20,
        letterSpacing: 0.15,
        fontWeight: FontWeight.w500),
  ),
  textTheme: TextTheme(
      headline1: safariStyle(),
      headline2: safariStyle(),
      headline3: safariStyle(),
      headline4: safariStyle(),
      headline5: safariStyle(),
      headline6: safariStyle(fontWeight: FontWeight.w500),
      subtitle1: safariStyle(),
      subtitle2: safariStyle(),
      bodyText1: safariStyle(fontWeight: FontWeight.w500),
      bodyText2: safariStyle(),
      caption: safariStyle(),
      button: safariStyle(fontWeight: FontWeight.w500),
      overline: safariStyle()
  ),
  primaryIconTheme: IconThemeData(color: Colors.green),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.green,
    selectionHandleColor: Colors.green,
    selectionColor: Colors.green,
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
      .copyWith(secondary: Colors.green),
);

ThemeData darkTheme = ThemeData(
  // fontFamily: iOSWeb
  //     ? '-apple-system'
  //     : null,
    errorColor: Colors.red[200],
    // primaryColor: Color(0xff404040),
    // cardColor:  Color(0xff404040),
    primaryTextTheme: TextTheme(
        headline1: safariStyle(),
        headline2: safariStyle(),
        headline3: safariStyle(),
        headline4: safariStyle(),
        headline5: safariStyle(),
        headline6: safariStyle(
            color: Colors.green[200],
            fontWeight: FontWeight.w500
        ),
        subtitle1: safariStyle(),
        subtitle2: safariStyle(),
        bodyText1: safariStyle(),
        bodyText2: safariStyle(),
        caption: safariStyle(),
        button: safariStyle(),
        overline: safariStyle()
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
          color: Colors.green[200],
          fontSize: 20,
          letterSpacing: 0.15,
          fontWeight: FontWeight.w500),
    ),
    textTheme: TextTheme(
        headline1: safariStyle(),
        headline2: safariStyle(),
        headline3: safariStyle(),
        headline4: safariStyle(),
        headline5: safariStyle(),
        headline6: safariStyle(fontWeight: FontWeight.w500),
        subtitle1: safariStyle(),
        subtitle2: safariStyle(),
        bodyText1: safariStyle(fontWeight: FontWeight.w500),
        bodyText2: safariStyle(),
        caption: safariStyle(),
        button: safariStyle(fontWeight: FontWeight.w500),
        overline: safariStyle()
    ),
    primaryIconTheme: IconThemeData(color: Colors.green[200]),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.green[200],
      selectionHandleColor: Colors.green[200],
      selectionColor: Colors.green[200],
    ),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: MaterialColor(Colors.green[200].value, {}),
      accentColor: Colors.green[200],
      brightness: Brightness.dark,
      errorColor: Colors.red[200],
      cardColor: Color(0xff404040),
    ));

void updateData() async {
  var prefs = await SharedPreferences.getInstance();
  prefs.setStringList('expr', expr);
  prefs.setStringList('dexpr', dexpr);
  prefs.setString('theme', theme.value);
  prefs.setBool('showAds', showAds);
  if (cf.majors.values.contains(currency)) {
    prefs.setString('currencySymbol', localCurrency ? null : currency.symbol);
  } else {
    prefs.setString('currencySymbol',
        '${currency.symbolSide == SymbolSide.left ? 'l' : 'r'}${currency.symbol}');
  }
}

String date2String(DateTime date) => '${date.day}/${date.month}/${date.year}';

DateTime string2Date(String date) => DateTime(
  int.parse(date.split('/')[2]),
  int.parse(date.split('/')[1]),
  int.parse(date.split('/')[0]),
);

Color bgColor(BuildContext context) => Colors.black
    .withOpacity(Theme.of(context).brightness == Brightness.light ? .05 : .1);

Widget aboutSheet(context) {
  return Container(
    height: 500,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30), topRight: Radius.circular(30)),
    ),
    child: Column(
      children: [
        Container(
            transform: Matrix4.translationValues(0, -40, 0),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.all(Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.16),
                    offset: Offset(0, -10),
                    blurRadius: 24,
                  )
                ]),
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: 80,
              color: Theme.of(context).cardColor,
            )),
        Text(
          'Román Via-Dufresne Saus',
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontFamily: 'ProductSans',
              fontSize: 24),
        ),
        Padding(
            padding: EdgeInsets.only(top: 32, left: 16),
            child: Container(
              constraints: BoxConstraints(maxHeight: 300, maxWidth: 350),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, i) {
                        return ListTile(
                          leading: Icon(
                            aboutInfo[i].leading,
                            color: Theme.of(context).textTheme.bodyText2.color,
                          ),
                          title: Text(
                            aboutInfo[i].title,
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(aboutInfo[i].subtitle),
                          onTap: () async {
                            if (aboutInfo[i].action == 'share') {
                              FlutterShare.share(
                                  title: 'Debt Tracker',
                                  chooserTitle: 'Debt Tracker',
                                  linkUrl:
                                  'https://play.google.com/store/apps/details?id=tk.roman910.debt',
                                  text:
                                  'Hey! Check out this app. It helps me to keep track of my money.');
                            } else {
                              String url = aboutInfo[i].action;
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }
                          },
                        );
                      })),
            ))
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: theme,
        builder: (context, theme, _) => MaterialApp(
          title: 'Debt Tracker',
          home: MoneyList(),
          theme: theme == 'dark' ? darkTheme : lightTheme,
          darkTheme: theme == 'light' ? lightTheme : darkTheme,
        ));
  }
}

class MoneyListState extends State<MoneyList> {
  @override
  void initState() {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    // ));
    super.initState();
    _loadData().then((_) {
      if (!kIsWeb) {
        FirebaseAdMob.instance
            .initialize(appId: 'ca-app-pub-8832562785647597~3542311842');
        if (Platform.isAndroid && showAds) {
          banner = BannerAd(
            adUnitId: 'ca-app-pub-8832562785647597/8322552151',
            // adUnitId: BannerAd.testAdUnitId,
            size: AdSize.smartBanner,
            listener: (event) {
              if (event == MobileAdEvent.loaded) {
                setState(() {
                  activeBanner = true;
                });
              } else if (event == MobileAdEvent.failedToLoad) {
                setState(() {
                  activeBanner = false;
                });
              }
            },
          );
          banner
            ..load()
            ..show();
        }
      }
    });
  }

  Future<bool> _loadData() async {
    var prefs = await SharedPreferences.getInstance();
    String symbol = prefs.getString('currencySymbol');
    if (symbol == null) {
      if (kIsWeb) {
        currency = CurrencyFormatter.usd;
        localCurrency = false;
      } else {
        currency = cf.getLocal();
        localCurrency = true;
        locale = Platform.localeName;
      }
    } else {
      currency = cf.getFromSymbol(symbol) ??
          CurrencyFormatterSettings(
              symbol: symbol.substring(1),
              symbolSide:
              symbol.startsWith('l') ? SymbolSide.left : SymbolSide.right);
      localCurrency = false;
    }
    setState(() {
      expr = (prefs.getStringList('expr') ?? []);
      dexpr = (prefs.getStringList('dexpr') ?? []);
      theme.value = prefs.getString('theme') ?? 'system';
      showAds = prefs.getBool('showAds') ?? true;
      calc = prefs.getBool('calc') ?? false;
    });
    return true;
  }

  var appBarActions;
  var appBarTitle = Text('Debt Tracker');
  var appBarLeading;

  var selected = [];
  var selectMode = false;

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    iOSWeb = kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (localCurrency && Platform.localeName != locale) {
      currency = cf.getLocal();
      locale = Platform.localeName;
    }
    if (selected.length == 0) {
      appBarActions = [
        IconButton(
            icon:
            Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute<String>(
                  builder: (context) {
                    return AddDialog();
                  },
                  fullscreenDialog: true))
                  .then((_) {
                setState(() {});
              });
            }),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(value: 'theme', child: Text('Set Theme')),
            PopupMenuItem(value: 'currency', child: Text('Set Currency')),
            PopupMenuItem(value: 'calc', child: Text('Calculator Input')),
          ]
              + (kIsWeb ? [] : [
                PopupMenuItem(
                  value: 'ads',
                  child: Text(showAds ? 'Hide Ads (Free)' : 'Show Ads'),
                ),
                PopupMenuItem(
                  value: 'about',
                  child: Text('About'),
                )
              ]),
          onSelected: (value) {
            switch (value) {
              case 'theme':
                String option = theme.value;
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Choose Theme'),
                        content: StatefulBuilder(builder: (context, setState) {
                          return Container(
                              width: double.maxFinite,
                              constraints: BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                  itemCount: themes.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return RadioListTile(
                                      title: Text(
                                          '${themes[i].substring(0, 1).toUpperCase()}${themes[i].substring(1)}'),
                                      value: themes[i],
                                      groupValue: option,
                                      activeColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      onChanged: (val) {
                                        setState(() {
                                          option = val;
                                        });
                                      },
                                    );
                                  }));
                        }),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color:
                                  Theme.of(context).colorScheme.secondary),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text('SET',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                            onPressed: () {
                              theme.value = option;
                              updateData();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
                break;
              case 'currency':
                CurrencyFormatterSettings option =
                localCurrency ? null : currency;
                bool customCurrency = false;
                String symbol = currency.symbol;
                String side =
                currency.symbolSide == SymbolSide.left ? 'left' : 'right';
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Choose Currency'),
                        content: StatefulBuilder(builder: (context, setState) {
                          num bannerHeight =
                          banner == null ? 0 : banner.size.height;
                          print(MediaQuery.of(context).size.height -
                              bannerHeight -
                              256);
                          if (!customCurrency) {
                            return Container(
                                width: double.maxFinite,
                                constraints: BoxConstraints(
                                    maxHeight:
                                    MediaQuery.of(context).size.height -
                                        bannerHeight -
                                        320),
                                child: ListView.builder(
                                    itemCount: cf.majors.length + 2,
                                    itemBuilder: (context, i) {
                                      if (i == 0) {
                                        return InkWell(
                                            child: ListTile(
                                              leading: Icon(Icons.add),
                                              title: Text('Custom'),
                                              onTap: () => setState(
                                                      () => customCurrency = true),
                                            ));
                                      } else {
                                        if (kIsWeb && i == 1) {
                                          return Container();
                                        }
                                        return RadioListTile(
                                          title: i == 1
                                              ? Text('System')
                                              : Text(cf.majorSymbols.values
                                              .elementAt(i - 2)),
                                          value: i == 1
                                              ? null
                                              : cf.majors.values
                                              .elementAt(i - 2),
                                          groupValue: option,
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          onChanged: (val) {
                                            setState(() {
                                              option = val;
                                            });
                                          },
                                        );
                                      }
                                    }));
                          } else {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                    padding:
                                    EdgeInsets.only(top: 8, bottom: 16),
                                    child: Text(side == 'left'
                                        ? '$symbol 9,999.99'
                                        : '9.999,99 $symbol')),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                        flex: 1,
                                        child: TextFormField(
                                          // maxLength: 2,
                                          initialValue: symbol,
                                          decoration: InputDecoration(
                                              hintText: 'Symbol',
                                              counterText: '',
                                              border: InputBorder.none),
                                          onChanged: (value) =>
                                              setState(() => symbol = value),
                                        )),
                                    Flexible(
                                        flex: 1,
                                        child: DropdownButton(
                                          value: side,
                                          hint: Text('Side'),
                                          items: [
                                            DropdownMenuItem(
                                              child: Text('Left'),
                                              value: 'left',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Right'),
                                              value: 'right',
                                            )
                                          ],
                                          onChanged: (value) =>
                                              setState(() => side = value),
                                          underline: Container(),
                                        ))
                                  ],
                                )
                              ],
                            );
                          }
                        }),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color:
                                  Theme.of(context).colorScheme.secondary),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text('SET',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                            onPressed: () {
                              if (!customCurrency) {
                                if (option == null) {
                                  currency = cf.getLocal();
                                  localCurrency = true;
                                  locale = Platform.localeName;
                                } else {
                                  currency = option;
                                  localCurrency = false;
                                }
                              } else {
                                currency = CurrencyFormatterSettings(
                                    symbol: symbol,
                                    symbolSide: side == 'left'
                                        ? SymbolSide.left
                                        : SymbolSide.right);
                                localCurrency = false;
                              }
                              updateData();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }).then((_) => setState(() {}));
                break;
              case 'calc':
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      insetPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Text('Calculator input'),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(''
                                'If calculator input is disabled, a numerical keyboard will show when filling in money fields.\n\n'
                                'If it is enabled, a full keyboard will be show so you can enter expressions like +, -, * and /.\n'
                                'e.g. \'11.34/5\' will be saved as \'2.27\'.',
                              textAlign: iOSWeb
                                  ? TextAlign.left
                                  : TextAlign.justify,
                            ),
                            const SizedBox(height: 24),
                            InkWell(
                                onTap: () => setState(() => calc = !calc),
                                hoverColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.transparent
                                    : null,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                      color: bgColor(context),
                                    ),
                                    padding: EdgeInsets.only(left: 24, right: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Calculator input'),
                                        const SizedBox(width: 8,),
                                        Switch(
                                          value: calc,
                                          activeColor: Theme.of(context).colorScheme.secondary,
                                          onChanged: (val) => setState(() => calc = val),
                                        )
                                      ],
                                    )
                                )
                            )
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('CLOSE'),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    )
                ).then((_) async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('calc', calc);
                });
                break;
              case 'ads':
                if (showAds) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hide Ads (Free)'),
                        content: Text(
                            'You can hide all the ads of any of my apps with no cost at all. However, I would like you to consider keeping them as the very little money I get from showing them is my only profit for working on these apps.'),
                        actions: [
                          TextButton(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text('HIDE',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                            onPressed: () {
                              try {
                                showAds = false;
                                banner.dispose();
                                banner = null;
                              } catch (e) {
                                print('BANNER DISPOSE ERROR: $e');
                              }
                              updateData();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ));
                } else {
                  showAds = true;
                  banner = BannerAd(
                    adUnitId: 'ca-app-pub-8832562785647597/8322552151',
                    // adUnitId: BannerAd.testAdUnitId,
                    size: AdSize.smartBanner,
                    listener: (event) {
                      if (event == MobileAdEvent.loaded) {
                        setState(() {
                          activeBanner = true;
                        });
                      } else if (event == MobileAdEvent.failedToLoad) {
                        setState(() {
                          activeBanner = false;
                        });
                      }
                    },
                  );
                  banner
                    ..load()
                    ..show();
                  updateData();
                }
                break;
              case 'about':
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return aboutSheet(context);
                  },
                );
                break;
            }
          },
        )
      ];
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: appBarTitle,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Theme.of(context).brightness,
          statusBarIconBrightness:
          Theme.of(context).brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        backgroundColor: Theme.of(context).bottomAppBarColor,
        actions: appBarActions,
        iconTheme:
        IconThemeData(color: Theme.of(context).colorScheme.secondary),
        leading: appBarLeading,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return _showList();
        },
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget _showList() {
    _date(d) => int.parse(d.split('/').reversed.join());

    nums.clear();
    dates.clear();
    ddates.clear();

    expr.forEach((e) {
      var f = e.split('~|~');
      nums[f[1]] = (nums[f[1]] ?? 0) + double.parse(f[0]);
      if (nums[f[1]] % 1 == 0) {
        nums[f[1]] = nums[f[1]].round();
      }
      if (_date(f[3]) > (_date(dates[f[1]] ?? '0/0/0'))) dates[f[1]] = f[3];
    });

    dexpr.forEach((e) {
      var f = e.split('~|~');
      if (nums[f[1]] == null) if (_date(f[3]) >
          (_date(ddates[f[1]] ?? '0/0/0'))) ddates[f[1]] = f[3];
    });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      itemCount: nums.length + ddates.length,
      itemBuilder: (context, i) {
        return _buildRow(i, context);
      },
    );
  }

  _exitSelectMode() {
    setState(() {
      selectMode = false;
      selected = [];
      appBarActions = [
        IconButton(
            icon: Icon(Icons.add, color: Colors.green),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute<String>(
                  builder: (context) {
                    return AddDialog();
                  },
                  fullscreenDialog: true))
                  .then((_) {
                setState(() {});
              });
            })
      ];
      appBarLeading = null;
      appBarTitle = Text('Debt Tracker');
    });
  }

  _confirmDialog(context, action) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$action confirmation'),
            content: Text(
                'Are you sure you want to ${action.toLowerCase()} multiple items?'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'CANCEL',
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'ACCEPT',
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () {
                  switch (action) {
                    case 'Check':
                      var toMove = [];
                      expr.forEach((e) {
                        if (selected.contains(e.split('~|~')[1])) {
                          toMove.add(e);
                        }
                      });
                      toMove.forEach((e) {
                        dexpr.add(e);
                        expr.remove(e);
                      });
                      break;

                    case 'Uncheck':
                      var toMove = [];
                      dexpr.forEach((e) {
                        if (selected.contains(e.split('~|~')[1])) {
                          toMove.add(e);
                        }
                      });
                      toMove.forEach((e) {
                        expr.add(e);
                        dexpr.remove(e);
                      });
                      break;

                    case 'Delete':
                      var toDelete = [];
                      expr.forEach((e) {
                        if (selected.contains(e.split('~|~')[1]))
                          toDelete.add(e);
                      });
                      toDelete.forEach((e) => expr.remove(e));
                      toDelete = [];
                      dexpr.forEach((e) {
                        if (selected.contains(e.split('~|~')[1]))
                          toDelete.add(e);
                      });
                      toDelete.forEach((e) => dexpr.remove(e));
                      break;

                    default:
                      break;
                  }
                  updateData();
                  _exitSelectMode();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _editDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var controller = TextEditingController();
        controller.text = selected[0];
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: controller,
            autofocus: iOSWeb ? false : true,
            inputFormatters: [LengthLimitingTextInputFormatter(25)],
            decoration: filledInputDecoration(null, context),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCEL',
                style:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'CHANGE',
                style:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {
                if (controller.text != '') {
                  expr.forEach((e) {
                    List<String> splt = e.split('~|~');
                    if (splt[1] == selected[0]) {
                      splt[1] = controller.text;
                      expr[expr.indexOf(e)] = splt.join('~|~');
                    }
                  });
                  dexpr.forEach((e) {
                    List<String> splt = e.split('~|~');
                    if (splt[1] == selected[0]) {
                      splt[1] = controller.text;
                      dexpr[dexpr.indexOf(e)] = splt.join('~|~');
                    }
                  });
                  updateData();
                  _exitSelectMode();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(_scaffoldKey.currentContext)
                      .showSnackBar(
                      SnackBar(content: Text('Name cannot be null!')));
                }
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildRow(i, context) {
    var iconEdit = IconButton(
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () => _editDialog(context));
    // var iconNoti = IconButton(icon: Icon(Icons.notifications, color: Theme.of(context).colorScheme.secondary), onPressed: () => _notYetSnack(Scaffold.of(context)));
    var iconNoti = Container();
    var iconCheck = IconButton(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () => _confirmDialog(context, 'Check'));
    var iconUncheck = IconButton(
        icon: Icon(Icons.check_circle_outline),
        onPressed: () => _confirmDialog(context, 'Uncheck'));
    var iconDelete = IconButton(
        icon:
        Icon(Icons.delete, color: Theme.of(context).colorScheme.secondary),
        onPressed: () => _confirmDialog(context, 'Delete'));

    var x = 'ERROR';
    var y = 'ERROR';
    if (i < nums.length) {
      x = nums.keys.elementAt(i);
    } else {
      y = ddates.keys.elementAt(i - nums.length);
    }
    return Center(
      child: GestureDetector(
          onTap: () {
            if (selectMode) {
              if (selected.contains(i < nums.length ? x : y)) {
                selected.remove(i < nums.length ? x : y);
              } else {
                selected.add(i < nums.length ? x : y);
              }
              var checked = false;
              var unchecked = false;
              selected.forEach((e) {
                if (ddates.containsKey(e)) {
                  checked = true;
                } else if (nums.containsKey(e)) {
                  unchecked = true;
                }
              });
              setState(() {
                if (selected.length == 0) {
                  _exitSelectMode();
                } else if (selected.length == 1) {
                  appBarTitle = Text(selected[0]);
                  appBarActions = [
                    iconEdit,
                    iconNoti,
                    checked ? iconUncheck : iconCheck,
                    iconDelete
                  ];
                } else {
                  appBarTitle = Text('${selected.length} items');
                  if (checked && unchecked) {
                    appBarActions = [iconDelete];
                  } else {
                    appBarActions = [
                      checked ? iconUncheck : iconCheck,
                      iconDelete
                    ];
                  }
                }
              });
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) {
                    todo = i < nums.length ? x : y;
                    return FullScreen();
                  },
                  fullscreenDialog: true))
                  .then((_) {
                setState(() {});
              });
            }
          },
          onLongPress: () {
            setState(() {
              selectMode = true;
              selected = [i < nums.length ? x : y];
              appBarTitle = Text(i < nums.length ? x : y);
              appBarActions = [
                iconEdit,
                iconNoti,
                nums.keys.contains(i < nums.length ? x : y)
                    ? iconCheck
                    : iconUncheck,
                iconDelete
              ];
              appBarLeading = IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: _exitSelectMode);
            });
          },
          child: Card(
              color: i < nums.length
                  ? Theme.of(context).cardColor
                  : Color(0x10000000),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: selected.contains(i < nums.length ? x : y)
                      ? Color(0xe3000000)
                      : Color(0x33000000),
                  width: selected.contains(i < nums.length ? x : y) ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                              flex: 3,
                              child: Text(
                                i < nums.length ? x : y,
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
//                                    color: i < nums.length ? Color(0xDE000000) : Color(0x99000000),
                                  color: i < nums.length
                                      ? Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .color
                                      : Theme.of(context)
                                      .textTheme
                                      .caption
                                      .color,
                                ),
                              )),
                          Flexible(
                            flex: 2,
                            child: Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Text(
                                  i < nums.length
                                      ? cf.format(nums[x], currency,
                                      compact: nums[x] >= 10, decimal: 2)
                                      : '',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: '${nums[x]}'[0] == '-'
                                          ? Theme.of(context).errorColor
                                          : Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                )),
                          )
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            i < nums.length ? dates[x] : ddates[y],
                            style: TextStyle(
                                color:
                                Theme.of(context).textTheme.caption.color),
                          ))
                    ],
                  )))),
    );
  }
}


int dateInsertIndex(List<String> lst, String date) {
  DateTime _date = string2Date(date);

  for (int i = 0; i < lst.length; i++) {
    if (_date.compareTo(string2Date(lst[i].split('~|~')[3])) >= 0) {
      return i;
    }
  }

  return lst.length;
}

class MoneyList extends StatefulWidget {
  @override
  MoneyListState createState() => new MoneyListState();
}

class AddDialogState extends State<AddDialog> {
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var amountController = TextEditingController();
  TextEditingController dateController = TextEditingController(text: date2String(DateTime.now()));
  bool validName = true;
  bool validAmount = true;
  bool positive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Entry'),
          backgroundColor: Theme.of(context).bottomAppBarColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Theme.of(context).brightness,
            statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
          ),
          iconTheme:
          IconThemeData(color: Theme.of(context).colorScheme.secondary),
          actions: <Widget>[
            Builder(builder: (context) {
              return TextButton(
                  child: Text('SAVE',
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Theme.of(context).colorScheme.secondary)),
                  onPressed: () {
                    if (amountController.text.isNotEmpty &&
                        nameController.text.isNotEmpty) {
                      try {
                        num amount = eval.eval(
                            Expression.parse(amountController.text
                                .replaceAll(currency.decimalSeparator, '.')),
                            {})*(positive ? 1 : -1);
                        expr.insert(
                            dateInsertIndex(expr, dateController.text),
                            double.parse(amount.toStringAsFixed(2)).toString() +
                                '~|~' +
                                nameController.text +
                                '~|~' +
                                descriptionController.text +
                                '~|~' +
                                dateController.text);
                        updateData();
                        Navigator.of(context).pop();
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Invalid money input'),
                        ));
                      }
                    } else {
                      var snackbar = SnackBar(
                          content:
                          Text('Name and ${currency.symbol} are required'));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    }
                  });
            })
          ],
        ),
        body: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: 740),
                padding: EdgeInsets.all(8.0),
                child: Card(
                    color: Theme.of(context).cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: nameController,
                              autofocus: iOSWeb ? false : true,
                              onChanged: (val) {
                                setState(() {
                                  if (val.isEmpty) {
                                    validName = false;
                                  } else {
                                    validName = true;
                                  }
                                });
                              },
                              cursorColor: validName
                                  ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  : Theme.of(context).errorColor,
                              // decoration: InputDecoration(
                              //   labelText: 'Name',
                              //   border: OutlineInputBorder(),
                              //   errorText: validName ? null : '',
                              // ),
                              decoration: filledInputDecoration('Name', context,
                                  valid: validName
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .singleLineFormatter,
                                LengthLimitingTextInputFormatter(25)
                              ],
                            ),
                            const SizedBox(height: 8,),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  flex: 2,
                                  child:
                                  TextField(
                                      controller: descriptionController,
                                      maxLines: null,
                                      decoration: filledInputDecoration('Description', context)
                                  ),
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Container(
                                        margin: EdgeInsets.only(left: 8),
                                        padding: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                            color: validAmount
                                                ? bgColor(context)
                                                : Theme.of(context).errorColor.withOpacity(.1),
                                            borderRadius: BorderRadius.all(Radius.circular(6))),
                                        child: Row(children: [
                                          Container(
                                            child: IconButton(
                                              icon: Icon(positive ? Icons.add : Icons.remove),
                                              iconSize: 16,
                                              color: amountController.text.isNotEmpty
                                                  ? validAmount
                                                  ? Theme.of(context).colorScheme.secondary
                                                  : Theme.of(context).errorColor
                                                  : Theme.of(context).textTheme.caption.color,
                                              padding: EdgeInsets.zero,
                                              onPressed: () => setState(() => positive = !positive),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                                controller: amountController,
                                                onChanged: (val) {
                                                  try {
                                                    if (val.trim() == '-') {
                                                      positive = !positive;
                                                      amountController.text = '';
                                                      validAmount = true;
                                                    } else {
                                                      val = val.replaceAll(
                                                          currency.decimalSeparator, '.');
                                                      num amount = eval.eval(Expression.parse(val), {});
                                                      validAmount =
                                                          amount != double.infinity && amount != null;
                                                      if (validAmount && amount < 0) {
                                                        positive = !positive;
                                                        amountController.text =
                                                            amountController.text.replaceAll('-', '');
                                                      }
                                                    }
                                                  } on Exception {
                                                    validAmount = false;
                                                  }
                                                  setState(() {});
                                                },
                                                textAlign: TextAlign.left,
                                                // keyboardType: iOSWeb ? TextInputType.text : TextInputType.numberWithOptions(signed: true, decimal: true),
                                                keyboardType: calc
                                                    ? null
                                                    : TextInputType.numberWithOptions(
                                                    signed: true, decimal: true),
                                                cursorColor: validAmount
                                                    ? Theme.of(context).colorScheme.secondary
                                                    : Theme.of(context).errorColor,
                                                decoration: filledInputDecoration(currency.symbol, context,
                                                    valid: validAmount,
                                                    // hintText:
                                                    // currency.symbol + '                        ',
                                                    filled: false)),
                                          )
                                        ])))
                              ],
                            ),
                            const SizedBox(height: 8,),
                            TextField(
                              controller: dateController,
                              onTap: () => showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.utc(1900),
                                  lastDate: DateTime.now()
                              ).then((value) => setState(() {
                                dateController.text = date2String(value);
                              })),
                              readOnly: true,
                              mouseCursor: SystemMouseCursors.click,
                              decoration: filledInputDecoration('Date', context),
                            )
                          ],
                        ))))));
  }
}

class AddDialog extends StatefulWidget {
  @override
  createState() => AddDialogState();
}

class _AddItemDialog extends StatefulWidget {
  final String name;

  _AddItemDialog(this.name);

  @override
  State<StatefulWidget> createState() => _AddItemDialogState(name);
}

class _AddItemDialogState extends State {
  final String name;

  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController(text: date2String(DateTime.now()));
  bool validAmount = true;
  bool positive = true;

  _AddItemDialogState(this.name);
  @override
  Widget build(BuildContext context) {
    print(CurrencyFormatter().parse('-195K \$', CurrencyFormatter.usd));
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Add Entry',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                      flex: 2,
                      child: TextField(
                          controller: descriptionController,
                          autofocus: iOSWeb ? false : true,
                          maxLines: null,
                          decoration: filledInputDecoration('Description', context))),
                  Flexible(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                              color: validAmount
                                  ? bgColor(context)
                                  : Theme.of(context).errorColor.withOpacity(.1),
                              borderRadius: BorderRadius.all(Radius.circular(6))),
                          child: Row(children: [
                            Container(
                              child: IconButton(
                                icon: Icon(positive ? Icons.add : Icons.remove),
                                iconSize: 16,
                                color: amountController.text.isNotEmpty
                                    ? validAmount
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).errorColor
                                    : Theme.of(context).textTheme.caption.color,
                                padding: EdgeInsets.zero,
                                onPressed: () => setState(() => positive = !positive),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                  controller: amountController,
                                  onChanged: (val) {
                                    try {
                                      if (val.trim() == '-') {
                                        positive = !positive;
                                        amountController.text = '';
                                        validAmount = true;
                                      } else {
                                        val = val.replaceAll(
                                            currency.decimalSeparator, '.');
                                        num amount = eval.eval(Expression.parse(val), {});
                                        validAmount =
                                            amount != double.infinity && amount != null;
                                        if (validAmount && amount < 0) {
                                          positive = !positive;
                                          amountController.text =
                                              amountController.text.replaceAll('-', '');
                                        }
                                      }
                                    } on Exception {
                                      validAmount = false;
                                    }
                                    setState(() {});
                                  },
                                  textAlign: TextAlign.left,
                                  // keyboardType: iOSWeb ? TextInputType.text : TextInputType.numberWithOptions(signed: true, decimal: true),
                                  keyboardType: calc
                                      ? null
                                      : TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  cursorColor: validAmount
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).errorColor,
                                  decoration: filledInputDecoration(currency.symbol, context,
                                      valid: validAmount,
                                      hintText: ' '*30,
                                      filled: false)),
                            )
                          ])
                      )
                  )
                ]
            ),
            const SizedBox(height: 8,),
            TextField(
              controller: dateController,
              onTap: () => showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.utc(1900),
                  lastDate: DateTime.now()
              ).then((value) => setState(() {
                dateController.text = date2String(value);
              })),
              readOnly: true,
              mouseCursor: SystemMouseCursors.click,
              decoration: filledInputDecoration('Date', context),
            )
          ]
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'CANCEL',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('ADD'),
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
            onSurface: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: validAmount && amountController.text.isNotEmpty
              ? () {
            num amount = eval.eval(
                Expression.parse(amountController.text
                    .replaceAll(currency.decimalSeparator, '.')),
                {}) *
                (positive ? 1 : -1);
            expr.insert(
                dateInsertIndex(expr, dateController.text),
                double.parse(amount.toStringAsFixed(2)).toString() +
                    '~|~' +
                    name +
                    '~|~' +
                    descriptionController.text +
                    '~|~' +
                    dateController.text);
            updateData();
            Navigator.of(context).pop();
          }
              : null,
        )
      ],
    );
  }
}

enum Action { restore, delete, reminder, repeat }

class FullScreenState extends State<FullScreen> {
  updateData() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('expr', expr);
      prefs.setStringList('dexpr', dexpr);
    });
  }

  // Future<void> dialog(context, data) async{
  //   switch(await showDialog(
  //       context: context,
  //       builder: (context) {
  //         return SimpleDialog(
  //           children: <Widget>[
  //             SimpleDialogOption(
  //               onPressed: () {Navigator.pop(context, Action.delete);},
  //               child: ListTile(
  //                 leading: Icon(Icons.close),
  //                 title: Text('Delete entry'),
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {Navigator.pop(context, Action.restore);},
  //               child: ListTile(
  //                 leading: Icon(Icons.restore),
  //                 title: Text('Restore entry'),
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {Navigator.pop(context, Action.reminder);},
  //               child: ListTile(
  //                 leading: Icon(Icons.notifications_active),
  //                 title: Text('Add reminder'),
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {Navigator.pop(context, Action.repeat);},
  //               child: ListTile(
  //                 leading: Icon(Icons.repeat),
  //                 title: Text('Add automation'),
  //               ),
  //             )
  //           ],
  //         );
  //       }
  //   )) {
  //     case Action.delete:
  //       setState(() {
  //         dexpr.remove(data.join('~|~'));
  //       });
  //       updateData();
  //       break;
  //     case Action.restore:
  //       setState(() {
  //         expr.insert(0, data.join('~|~'));
  //         dexpr.remove(data.join('~|~'));
  //       });
  //       updateData();
  //       break;
  //     case Action.reminder:
  //       print('DATE: ${notificationDialog(context, data)}');
  //       break;
  //     default:
  //       Scaffold.of(context).showSnackBar(SnackBar(content: Text('Not available yet!')));
  //       break;
  //   }
  // }

  _exitSelectMode() {
    setState(() {
      selectMode = false;
      selected = [];
      appBarActions = null;
      appBarLeading = null;
      appBarTitle = Text(todo);
    });
  }

  _confirmDialog(context, action) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$action confirmation'),
            content: Text(
                'Are you sure you want to ${action.toLowerCase()} the selected entries?'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'CANCEL',
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'ACCEPT',
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () {
                  var tot = expr + dexpr;
                  selected.forEach((f) {
                    var prexpr =
                    tot.where((e) => e.split('~|~')[1] == todo).toList()[f];
                    switch (action) {
                      case 'Check':
                        dexpr.add(prexpr);
                        expr.remove(prexpr);
                        break;

                      case 'Uncheck':
                        expr.add(prexpr);
                        dexpr.remove(prexpr);
                        break;

                      case 'Delete':
                        if (expr.contains(prexpr)) {
                          expr.remove(prexpr);
                        } else {
                          dexpr.remove(prexpr);
                        }
                        break;

                      default:
                        break;
                    }
                  });
                  updateData();
                  _exitSelectMode();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _editDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var controller = TextEditingController();
        var tothere = here + dhere;
        controller.text = tothere[selected[0]][2];
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text('Edit Description'),
          content: TextField(
            controller: controller,
            autofocus: iOSWeb ? false : true,
            maxLines: null,
            decoration: filledInputDecoration(null, context),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCEL',
                style:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'CHANGE',
                style:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {
                var tot = expr + dexpr;
                var prexpr = tot
                    .where((e) => e.split('~|~')[1] == todo)
                    .toList()[selected[0]];
                var split = prexpr.split("~|~");
                split[2] = controller.text;
                if (selected[0] < here.length) {
                  expr[expr.indexOf(prexpr)] = split.join('~|~');
                } else {
                  dexpr[dexpr.indexOf(prexpr)] = split.join('~|~');
                }
                updateData();
                _exitSelectMode();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  var appBarActions;
  var appBarTitle = Text(todo);
  var appBarLeading;

  var selected = [];
  var selectMode = false;

  var here;
  var dhere;
  num total;

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var iconEdit = IconButton(
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () => _editDialog(context));
    //var iconNoti = IconButton(icon: Icon(Icons.notifications, color: Theme.of(context).colorScheme.secondary), onPressed: () => _notYetSnack(Scaffold.of(context)));
    var iconNoti = Container();
    var iconCheck = IconButton(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () => _confirmDialog(context, 'Check'));
    var iconUncheck = IconButton(
        icon: Icon(Icons.check_circle_outline),
        onPressed: () => _confirmDialog(context, 'Uncheck'));
    var iconDelete = IconButton(
        icon:
        Icon(Icons.delete, color: Theme.of(context).colorScheme.secondary),
        onPressed: () => _confirmDialog(context, 'Delete'));
    here = [];
    dhere = [];
    total = 0;
    expr.forEach((f) {
      var e = f.split('~|~');
      if (e[1] == todo) {
        here.add(e);
        total += double.parse(e[0]);
      }
    });

    if (total % 1 == 0) {
      total = total.round();
    }

    dexpr.forEach((f) {
      var e = f.split('~|~');
      if (e[1] == todo) {
        dhere.add(e);
      }
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: appBarTitle,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Theme.of(context).brightness,
          statusBarIconBrightness:
          Theme.of(context).brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        actions: appBarActions,
        iconTheme:
        IconThemeData(color: Theme.of(context).colorScheme.secondary),
        leading: appBarLeading,
      ),
      body: Stack(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            itemCount: here.length + dhere.length + 1,
            itemBuilder: (context, j) {
              if (j == 0) {
                return Padding(
                    padding: EdgeInsets.fromLTRB(10, 24, 10, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Total:',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans'),
                        ),
                        Text(
                          cf.format(total, currency),
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: '$total'[0] == '-'
                                  ? Theme.of(context).errorColor
                                  : Theme.of(context).colorScheme.secondary),
                        )
                      ],
                    ));
              } else if (j <= here.length) {
                var i = j - 1;
                var key = here[i].join('~|~');
                return Dismissible(
                    key: Key(key),
                    onDismissed: (direction) {
                      setState(() {
                        expr.remove(key);
                        dexpr.insert(0, key);
                        updateData();
                      });
                    },
                    child: GestureDetector(
                        onTap: () {
                          if (selectMode) {
                            if (selected.contains(i)) {
                              selected.remove(i);
                            } else {
                              selected.add(i);
                            }
                            var checked = false;
                            var unchecked = false;
                            selected.forEach((e) {
                              if (e < here.length) {
                                unchecked = true;
                              } else {
                                checked = true;
                              }
                            });
                            setState(() {
                              if (selected.length == 0) {
                                _exitSelectMode();
                              } else if (selected.length == 1) {
                                appBarTitle = Text('1 item');
                                appBarActions = [
                                  iconEdit,
                                  iconNoti,
                                  checked ? iconUncheck : iconCheck,
                                  iconDelete
                                ];
                              } else {
                                appBarTitle = Text('${selected.length} items');
                                if (checked && unchecked) {
                                  appBarActions = [iconDelete];
                                } else {
                                  appBarActions = [
                                    checked ? iconUncheck : iconCheck,
                                    iconDelete
                                  ];
                                }
                              }
                            });
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            selectMode = true;
                            selected = [i];
                            appBarTitle = Text('1 item');
                            appBarActions = [
                              iconEdit,
                              iconNoti,
                              iconCheck,
                              iconDelete
                            ];
                            appBarLeading = IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color:
                                  Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: _exitSelectMode);
                          });
                        },
                        child: Card(
                            color: Theme.of(context).cardColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: selected.contains(i)
                                    ? Color(0xe3000000)
                                    : Color(0x33000000),
                                width: selected.contains(i) ? 2.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                            flex: 3,
                                            child: Text(
                                              here[i][2],
                                              style: TextStyle(
                                                fontSize: 16.0,
                                              ),
                                            )),
                                        Flexible(
                                          flex: 2,
                                          child: Padding(
                                              padding:
                                              EdgeInsets.only(left: 16.0),
                                              child: Text(
                                                cf.format(here[i][0], currency),
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color: here[i][0][0] == '-'
                                                        ? Theme.of(context)
                                                        .errorColor
                                                        : Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0),
                                              )),
                                        )
                                      ],
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          here[i][3],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color),
                                        ))
                                  ],
                                )))));
              } else {
                try {
                  var i = j - here.length - 1;
                  var k = j - 1;
                  return GestureDetector(
                      onTap: () {
                        if (selectMode) {
                          if (selected.contains(k)) {
                            selected.remove(k);
                          } else {
                            selected.add(k);
                          }
                          var checked = false;
                          var unchecked = false;
                          selected.forEach((e) {
                            if (e < here.length) {
                              unchecked = true;
                            } else {
                              checked = true;
                            }
                          });
                          setState(() {
                            if (selected.length == 0) {
                              _exitSelectMode();
                            } else if (selected.length == 1) {
                              appBarTitle = Text('1 item');
                              appBarActions = [
                                iconEdit,
                                iconNoti,
                                checked ? iconUncheck : iconCheck,
                                iconDelete
                              ];
                            } else {
                              appBarTitle = Text('${selected.length} items');
                              if (checked && unchecked) {
                                appBarActions = [iconDelete];
                              } else {
                                appBarActions = [
                                  checked ? iconUncheck : iconCheck,
                                  iconDelete
                                ];
                              }
                            }
                          });
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          selectMode = true;
                          selected = [k];
                          appBarTitle = Text('1 item');
                          appBarActions = [
                            iconEdit,
                            iconNoti,
                            iconUncheck,
                            iconDelete
                          ];
                          appBarLeading = IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: _exitSelectMode);
                        });
                      },
                      child: Card(
                          color: Color(0x05000000),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: selected.contains(k)
                                  ? Color(0xe3000000)
                                  : Color(0x33000000),
                              width: selected.contains(k) ? 2.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Flexible(
                                          flex: 3,
                                          child: Text(
                                            dhere[i][2],
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color),
                                          )),
                                      Flexible(
                                        flex: 2,
                                        child: Padding(
                                            padding:
                                            EdgeInsets.only(left: 16.0),
                                            child: Text(
                                              cf.format(dhere[i][0], currency),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .caption
                                                      .color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0),
                                            )),
                                      )
                                    ],
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        dhere[i][3],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ))
                                ],
                              ))));
                } on Exception catch (e) {
                  print('Exception: $e');
                }
              }
              return Container(); //TODO: aixo sobra
            },
          ),
        ),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
                padding: activeBanner
                    ? EdgeInsets.fromLTRB(0, 0, 16, 76)
                    : EdgeInsets.all(16),
                child: FloatingActionButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => _AddItemDialog(todo)).then((_) {
                    setState(() {});
                  }),
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  child: Icon(Icons.add),
                )))
      ]),
    );
  }
}

class FullScreen extends StatefulWidget {
  @override
  createState() => FullScreenState();
}

notificationDialog(context, d) async {
  TimeOfDay time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: 0, minute: 10),
  );

  if (time != null) {
    var now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    await flnp.schedule(
        0,
        int.parse(d[0]) > 0
            ? 'Get you money back!'
            : 'You have to give some money back!',
        int.parse(d[0]) > 0
            ? '${d[1]} owes you ${d[0]}${currency.symbol}'
            : 'You owe ${d[1]} ${d[0].slice(1)}${currency.symbol}',
        dt,
        notiDetails);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Reminder set!')));
  }
}
