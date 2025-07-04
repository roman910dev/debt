import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Interface for the data of the buttons displayed in the [AboutSheet].
class _AboutData {
  final IconData leading;
  final String title;
  final String subtitle;
  final String? uri;

  const _AboutData(this.leading, this.title, this.subtitle, this.uri);
}

/// A bottom sheet that displays information about the app and the developer.
class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  static const List<_AboutData> _aboutData = [
    _AboutData(
      Symbols.share,
      'Tell your friends about this app',
      'Share this app',
      null,
    ),
    _AboutData(
      Symbols.web,
      'Visit my website',
      'https://roman910.tk',
      'https://roman910.tk',
    ),
    _AboutData(
      Symbols.shop,
      'Check out my other Android apps',
      'Google Play Store',
      'https://play.google.com/store/apps/developer?id=Rom%C3%A1n+Via-Dufresne+Saus',
    ),
    _AboutData(
      Symbols.email,
      'Reach me out',
      'roman910dev@gmail.com',
      'mailto:roman910dev@gmail.com?subject=Debt Tracker Feedback',
    ),
  ];

  Future<void> _onAction(String? uri) async {
    if (uri == null) {
      Share.share(
        'Hey! Check out this app. It helps me to keep track of my money.\n'
        'https://play.google.com/store/apps/details?id=tk.roman910.debt',
        subject: 'Debt Tracker',
      );
    } else {
      Uri? url = Uri.tryParse(uri);
      if (url != null && await canLaunchUrl(url)) {
        await launchUrl(url, webOnlyWindowName: '_blank');
      }
    }
  }

  Widget _buildLogo(BuildContext context) => Transform(
        transform: Matrix4.translationValues(0, -40, 0),
        child: Stack(
          children: [
            Positioned(
              left: 1,
              top: 1,
              right: 1,
              bottom: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.16),
                      offset: const Offset(0, -10),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/logo.svg',
              width: 80,
              colorFilter: ColorFilter.mode(
                Theme.of(context).cardColor,
                BlendMode.srcATop,
              ),
            ),
          ],
        ),
      );

  Widget _buildName(BuildContext context) => Text(
        'Román Via-Dufresne Saus',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontFamily: 'ProductSans',
          fontSize: 24,
        ),
      );

  Widget _actionItem(BuildContext context, _AboutData data) => ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        leading: Icon(
          data.leading,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        title: Text(
          data.title,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Text(data.subtitle),
        onTap: () => _onAction(data.uri),
      );

  Widget _buildActionsList(BuildContext context) => Column(
        children: [
          for (final data in _aboutData) _actionItem(context, data),
        ],
      );

  @override
  Widget build(BuildContext context) => Container(
        height: 500,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            _buildLogo(context),
            _buildName(context),
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 16),
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 300, maxWidth: 350),
                  child: _buildActionsList(context),
                ),
              ),
            ),
          ],
        ),
      );
}
