
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:holo_streams/ui/screens/home/stream_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final BannerAd _banner;

  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _banner = BannerAd(
      adUnitId: 'ca-app-pub-4259638624676482/6397512801',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) {
          setState(() => _isAdLoaded = false);
          ad.dispose();
        },
      ),
    );
    _banner.load();
  }

  @override
  void dispose() {
    _banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const StreamListView(),
      bottomNavigationBar: _isAdLoaded
          ? SizedBox(
              width: _banner.size.width.toDouble(),
              height: _banner.size.height.toDouble(),
              child: Align(
                alignment: Alignment.center,
                child: AdWidget(ad: _banner),
              ),
            )
          : null,
    );
  }
}