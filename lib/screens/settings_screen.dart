import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

/// 设置页：目前提供「界面语言」切换（中文 / English）。
/// 选择后立即生效（监听 LocaleProvider，自身重建）并写入本地持久化。
///
/// 注意：设置页是通过 Navigator 推送的路由，MaterialApp 重建时不会自动
/// 重建已推送的路由，因此这里用 ListenableBuilder 直接订阅语言变化。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = LocaleScope.of(context);
    return ListenableBuilder(
      listenable: provider,
      builder: (ctx, _) {
        return Scaffold(
          appBar: AppBar(title: Text(L10n.tr(ctx, 'settings'))),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(L10n.tr(ctx, 'language')),
                subtitle: Text(L10n.tr(ctx, 'languageHint')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SegmentedButton<Locale>(
                  segments: [
                    ButtonSegment(
                      value: AppLocales.zh,
                      label: Text(L10n.tr(ctx, 'zhName')),
                    ),
                    ButtonSegment(
                      value: AppLocales.en,
                      label: Text(L10n.tr(ctx, 'enName')),
                    ),
                  ],
                  selected: {provider.locale},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      provider.setLocale(selection.first);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  provider.isZh
                      ? '切换后界面语言立即变化，并会在下次打开时保持。'
                      : 'The language changes immediately and persists on next launch.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
