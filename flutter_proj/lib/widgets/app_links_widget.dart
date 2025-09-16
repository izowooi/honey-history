import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_proj/core/platform.dart';
import 'package:flutter_proj/model/app_links_model.dart';

class AppLinksWidget extends StatefulWidget {
  const AppLinksWidget({super.key});

  @override
  State<AppLinksWidget> createState() => _AppLinksWidgetState();
}

class _AppLinksWidgetState extends State<AppLinksWidget> {
  AppLinksConfig? _config;
  String? _packageName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final jsonString = await rootBundle.loadString('assets/data/app_links_config.json');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      setState(() {
        _config = AppLinksConfig.fromJson(jsonMap);
        _packageName = packageInfo.packageName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Failed to load app links config: $e');
    }
  }

  AppPlatform _getCurrentAppPlatform() {
    return appPlatform;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '개발자가 만든 다른 앱보기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_config == null || _packageName == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '개발자가 만든 다른 앱보기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('링크 정보를 불러올 수 없습니다.'),
          ),
        ],
      );
    }

    final currentPlatform = _getCurrentAppPlatform();
    final validLinks = _config!.appLinks
        .where((link) {
          final url = link.getDisplayUrl(currentPlatform, _packageName!);
          return url != null && url.isNotEmpty;
        })
        .map((link) => (
              link.getDisplayTitle(_packageName!),
              link.getDisplayUrl(currentPlatform, _packageName!)!,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '개발자가 만든 다른 앱보기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...validLinks.map((item) => ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(item.$1),
              onTap: () => _openUrl(item.$2),
            )),
      ],
    );
  }
}


