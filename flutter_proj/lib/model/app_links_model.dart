import 'package:flutter_proj/core/platform.dart';

enum AppLinkType { web, app, sourceCode }

class PlatformUrls {
  final String android;
  final String ios;
  final String defaultUrl;

  PlatformUrls({
    required this.android,
    required this.ios,
    required this.defaultUrl,
  });

  factory PlatformUrls.fromJson(Map<String, dynamic> json) {
    return PlatformUrls(
      android: json['android'] as String,
      ios: json['ios'] as String,
      defaultUrl: json['default'] as String,
    );
  }

  String getUrlForPlatform(AppPlatform platform) {
    switch (platform) {
      case AppPlatform.android:
        return android;
      case AppPlatform.ios:
        return ios;
      case AppPlatform.other:
        return defaultUrl;
    }
  }
}

class SourceCodePackage {
  final String title;
  final String url;

  SourceCodePackage({
    required this.title,
    required this.url,
  });

  factory SourceCodePackage.fromJson(Map<String, dynamic> json) {
    return SourceCodePackage(
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}

class AppLink {
  final AppLinkType type;
  final String title;
  final String? url;
  final PlatformUrls? platforms;
  final Map<String, SourceCodePackage>? packages;

  AppLink({
    required this.type,
    required this.title,
    this.url,
    this.platforms,
    this.packages,
  });

  factory AppLink.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = AppLinkType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => AppLinkType.web,
    );

    PlatformUrls? platforms;
    Map<String, SourceCodePackage>? packages;

    if (type == AppLinkType.app && json['platforms'] != null) {
      platforms = PlatformUrls.fromJson(json['platforms'] as Map<String, dynamic>);
    }

    if (type == AppLinkType.sourceCode && json['packages'] != null) {
      final packagesJson = json['packages'] as Map<String, dynamic>;
      packages = packagesJson.map(
        (key, value) => MapEntry(
          key,
          SourceCodePackage.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return AppLink(
      type: type,
      title: json['title'] as String,
      url: json['url'] as String?,
      platforms: platforms,
      packages: packages,
    );
  }

  String? getDisplayUrl(AppPlatform currentPlatform, String currentPackageName) {
    switch (type) {
      case AppLinkType.web:
        return url;
      case AppLinkType.app:
        return platforms?.getUrlForPlatform(currentPlatform);
      case AppLinkType.sourceCode:
        return packages?[currentPackageName]?.url;
    }
  }

  String getDisplayTitle(String currentPackageName) {
    if (type == AppLinkType.sourceCode && packages != null) {
      return packages![currentPackageName]?.title ?? title;
    }
    return title;
  }
}

class AppLinksConfig {
  final List<AppLink> appLinks;

  AppLinksConfig({
    required this.appLinks,
  });

  factory AppLinksConfig.fromJson(Map<String, dynamic> json) {
    final linksJson = json['app_links'] as List<dynamic>;
    final links = linksJson
        .map((linkJson) => AppLink.fromJson(linkJson as Map<String, dynamic>))
        .toList();

    return AppLinksConfig(appLinks: links);
  }
}