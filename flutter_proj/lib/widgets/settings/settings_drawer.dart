import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/providers/settings_provider.dart';

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMovies = ref.watch(showMoviesProvider);
    final fontSizeScale = ref.watch(fontSizeScaleProvider);
    final useDetailedContent = ref.watch(useDetailedContentProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              '설정',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          CheckboxListTile(
            title: const Text('관련 영화 표시'),
            value: showMovies,
            onChanged: (bool? value) {
              if (value != null) {
                ref.read(showMoviesProvider.notifier).state = value;
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '글자 크기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RadioListTile<double>(
            title: const Text('보통'),
            value: 1.0,
            groupValue: fontSizeScale,
            onChanged: (value) {
              if (value != null) {
                ref.read(fontSizeScaleProvider.notifier).state = value;
              }
            },
          ),
          RadioListTile<double>(
            title: const Text('크게'),
            value: 1.2,
            groupValue: fontSizeScale,
            onChanged: (value) {
              if (value != null) {
                ref.read(fontSizeScaleProvider.notifier).state = value;
              }
            },
          ),
          RadioListTile<double>(
            title: const Text('더 크게'),
            value: 1.5,
            groupValue: fontSizeScale,
            onChanged: (value) {
              if (value != null) {
                ref.read(fontSizeScaleProvider.notifier).state = value;
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '내용 길이',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RadioListTile<bool>(
            title: const Text('초등학생용 (간단)'),
            subtitle: const Text('쉽고 간단한 설명'),
            value: false,
            groupValue: useDetailedContent,
            onChanged: (value) {
              if (value != null) {
                ref.read(useDetailedContentProvider.notifier).state = value;
              }
            },
          ),
          RadioListTile<bool>(
            title: const Text('고등학생용 (상세)'),
            subtitle: const Text('자세하고 전문적인 설명'),
            value: true,
            groupValue: useDetailedContent,
            onChanged: (value) {
              if (value != null) {
                ref.read(useDetailedContentProvider.notifier).state = value;
              }
            },
          ),
        ],
      ),
    );
  }
} 