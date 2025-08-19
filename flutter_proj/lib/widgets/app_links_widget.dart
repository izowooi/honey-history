import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_proj/core/platform.dart';

class AppLinksWidget extends StatelessWidget {
  const AppLinksWidget({super.key});

  String _storeUrl() {
    switch (appPlatform) {
      case AppPlatform.android:
        // 번들 ID로 바로 연결 (필요 시 실제 패키지명으로 교체)
        return 'https://play.google.com/store/apps/details?id=com.izowooi.mystic_cocoa';
      case AppPlatform.ios:
        // 실제 App Store 링크로 교체 필요
        //return 'https://apps.apple.com/app/id0000000000';
        return 'https://play.google.com/store/apps/details?id=com.izowooi.mystic_cocoa';
      case AppPlatform.other:
        return 'https://play.google.com/store/apps/details?id=com.izowooi.mystic_cocoa';
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final links = <(String, String)>[
      const ('🧪 미학 점수', 'https://huggingface.co/spaces/izowooi/aesthetics_score'),
      const ('📊 이미지 갤러리', 'https://gen-image-gallery.streamlit.app/'),
      ('🔮 타로카드', _storeUrl()),
      const ('🚀 원본 코드', 'https://github.com/izowooi/honey-history/tree/main/flutter_proj'),
    ];

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
        ...links.map((item) => ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(item.$1),
              onTap: () => _openUrl(item.$2),
            )),
      ],
    );
  }
}


