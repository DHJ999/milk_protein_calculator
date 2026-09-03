import 'package:flutter/material.dart';
import 'l10n/l10n.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MilkApp());
}

class MilkApp extends StatefulWidget {
  const MilkApp({super.key});

  @override
  State<MilkApp> createState() => _MilkAppState();
}

class _MilkAppState extends State<MilkApp> {
  // 默认中文，initState 里再从本地存储读取用户上次的选择。
  final LocaleProvider _localeProvider = LocaleProvider();

  @override
  void initState() {
    super.initState();
    _initLocale();
  }

  Future<void> _initLocale() async {
    final loaded = await LocaleProvider.load();
    if (!mounted) return;
    if (loaded.locale != _localeProvider.locale) {
      _localeProvider.setLocale(loaded.locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 语言变化时立即重建整个 MaterialApp，使所有界面文案即时切换。
    // LocaleScope 放在 MaterialApp 之上，确保首页、设置页、底部弹窗等
    // 所有路由都在作用域内，都能拿到当前语言。
    return ListenableBuilder(
      listenable: _localeProvider,
      builder: (ctx, _) => LocaleScope(
        provider: _localeProvider,
        child: MaterialApp(
          title: 'Milk Calculator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A90D9), // 奶蓝
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F8FB),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
