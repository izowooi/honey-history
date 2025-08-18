import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:flutter_proj/providers/build_info_provider.dart';
import 'package:flutter_proj/services/push_notification_service.dart';
import 'package:flutter_proj/widgets/app_links_widget.dart';

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});
  static const isDeveloperMode = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMovies = ref.watch(showMoviesProvider);
    final fontSizeScale = ref.watch(fontSizeScaleProvider);
    final useDetailedContent = ref.watch(useDetailedContentProvider);
    final isDebug = ref.watch(isDebugProvider);
    final notificationEnabled = ref.watch(notificationEnabledProvider);

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
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) {
                  if (flag) return const SizedBox.shrink();
                  return CheckboxListTile(
                    title: const Text('알림'),
                    subtitle: const Text('매일 역사적 사건 알림 받기'),
                    value: notificationEnabled,
                    onChanged: (bool? value) async {
                      if (value == null) return;
                      if (value) {
                        final granted = await PushNotificationService.ensurePermission();
                        if (granted) {
                          await PushNotificationService.subscribeHistoryTopic();
                          ref.read(notificationEnabledProvider.notifier).setValue(true);
                        } else {
                          ref.read(notificationEnabledProvider.notifier).setValue(false);
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          messenger?.showSnackBar(
                            const SnackBar(content: Text('알림 권한이 필요합니다. 설정에서 허용해주세요.')),
                          );
                        }
                      } else {
                        await PushNotificationService.unsubscribeHistoryTopic();
                        ref.read(notificationEnabledProvider.notifier).setValue(false);
                      }
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) => flag ? const SizedBox.shrink() : const Divider(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) {
                  if (flag) return const SizedBox.shrink();
                  return CheckboxListTile(
                    title: const Text('관련 영화 표시'),
                    value: showMovies,
                    onChanged: (bool? value) {
                      if (value != null) {
                        ref.read(showMoviesProvider.notifier).setValue(value);
                      }
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) => flag ? const SizedBox.shrink() : const Divider(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
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
                ref.read(fontSizeScaleProvider.notifier).setValue(value);
              }
            },
          ),
          RadioListTile<double>(
            title: const Text('크게'),
            value: 1.2,
            groupValue: fontSizeScale,
            onChanged: (value) {
              if (value != null) {
                ref.read(fontSizeScaleProvider.notifier).setValue(value);
              }
            },
          ),
          RadioListTile<double>(
            title: const Text('더 크게'),
            value: 1.5,
            groupValue: fontSizeScale,
            onChanged: (value) {
              if (value != null) {
                ref.read(fontSizeScaleProvider.notifier).setValue(value);
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
                ref.read(useDetailedContentProvider.notifier).setValue(value);
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
                ref.read(useDetailedContentProvider.notifier).setValue(value);
              }
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) {
                  if (flag) return const SizedBox.shrink();
                  return const Divider();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) {
                  if (flag || isDeveloperMode == false) return const SizedBox.shrink();
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      '개발자 옵션',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) {
                  if (flag || isDeveloperMode == false) return const SizedBox.shrink();
                  return CheckboxListTile(
                    title: const Text('디버그 모드'),
                    subtitle: const Text('개발자용 디버그 정보 표시'),
                    value: isDebug,
                    onChanged: (bool? value) {
                      if (value != null) {
                        ref.read(isDebugProvider.notifier).setValue(value);
                      }
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) {
                  if (flag) return const SizedBox.shrink();
                  return const Divider();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isReviewBuild = ref.watch(isReviewBuildProvider);
              return isReviewBuild.when(
                data: (flag) {
                  if (flag) return const SizedBox.shrink();
                  return const AppLinksWidget();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
} 