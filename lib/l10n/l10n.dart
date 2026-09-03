import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本应用支持的语言。当前仅中文与英文。
class AppLocales {
  static const zh = Locale('zh', 'CN');
  static const en = Locale('en', 'US');
  static const supported = [zh, en];
  static const fallback = zh;

  static Locale fromCode(String? code) => code == 'en' ? en : zh;
  static String toCode(Locale locale) => locale.languageCode == 'en' ? 'en' : 'zh';
}

/// 管理当前界面语言：随用户切换立即生效，并持久化到本地。
class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  LocaleProvider([Locale? locale]) : _locale = locale ?? AppLocales.fallback;

  Locale get locale => _locale;
  bool get isZh => _locale.languageCode == 'zh';

  static const _prefKey = 'app_locale_v1';

  /// 从本地存储读取已保存的语言；未保存过则返回默认（中文）。
  static Future<LocaleProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    return LocaleProvider(AppLocales.fromCode(code));
  }

  /// 切换语言：更新内存状态并立即通知监听者（界面马上刷新），再写回本地。
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, AppLocales.toCode(locale));
    } catch (e, st) {
      debugPrint('LocaleProvider.setLocale failed: $e\n$st');
    }
  }

  /// 在中英文之间一键切换。
  void toggle() => setLocale(isZh ? AppLocales.en : AppLocales.zh);
}

/// 让任意后代组件拿到同一个 LocaleProvider 实例。
class LocaleScope extends InheritedWidget {
  final LocaleProvider provider;

  const LocaleScope({
    super.key,
    required this.provider,
    required super.child,
  });

  static LocaleProvider of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(w != null, 'No LocaleScope found above this context');
    return w!.provider;
  }

  @override
  bool updateShouldNotify(LocaleScope old) => old.provider != provider;
}

/// 集中管理所有界面文案，按 key 取当前语言对应的字符串。
class L10n {
  static const Map<String, Map<String, String>> _strings = {
    'appTitle': {'zh': '牛奶计算器', 'en': 'Milk Calculator'},
    'settings': {'zh': '设置', 'en': 'Settings'},
    'language': {'zh': '界面语言', 'en': 'Language'},
    'languageHint': {'zh': '切换中文 / English', 'en': 'Switch 中文 / English'},
    'zhName': {'zh': '中文', 'en': '中文'},
    'enName': {'zh': 'English', 'en': 'English'},
    'privacyPolicy': {'zh': '隐私政策', 'en': 'Privacy Policy'},
    'agree': {'zh': '同意并继续', 'en': 'Agree & Continue'},
    'disagree': {'zh': '不同意并退出', 'en': 'Decline & Exit'},
    'needPrivacy': {
      'zh': '需要同意隐私政策才能使用本应用',
      'en': 'You must accept the Privacy Policy to use this app',
    },
    'exitAndRetry': {
      'zh': '请手动退出后重新打开并同意',
      'en': 'Please close and reopen the app to accept',
    },
    'sort': {'zh': '排序方式', 'en': 'Sort by'},
    'sortValue': {'zh': '性价比 (克/元)', 'en': 'Value (g/¥)'},
    'sortProtein': {'zh': '总蛋白质 (g)', 'en': 'Total Protein (g)'},
    'sortUnitPrice': {'zh': '每100ml单价 (¥)', 'en': 'Unit Price (¥/100ml)'},
    'currentSort': {'zh': '当前排序：', 'en': 'Sorted by: '},
    'tapToSwitch': {'zh': '点击右上角 ↗ 切换', 'en': 'Tap ↗ at top-right to switch'},
    'emptyTitle': {'zh': '还没有记录任何牛奶', 'en': 'No milk recorded yet'},
    'emptyHint': {'zh': '添加一瓶，算算它的性价比', 'en': 'Add one to calculate its value'},
    'addFirst': {'zh': '添加第一瓶', 'en': 'Add the first one'},
    'addMilk': {'zh': '添加牛奶', 'en': 'Add Milk'},
    'editMilk': {'zh': '编辑牛奶', 'en': 'Edit Milk'},
    'nameField': {'zh': '名称 / 品牌（选填）', 'en': 'Name / Brand (optional)'},
    'nameHint': {'zh': '牛奶名称', 'en': 'Milk name'},
    'volume': {'zh': '容量', 'en': 'Volume'},
    'volumeField': {'zh': '容量 (ml)', 'en': 'Volume (ml)'},
    'volumeHint': {'zh': '如：1000', 'en': 'e.g. 1000'},
    'ml': {'zh': 'ml', 'en': 'ml'},
    'protein': {'zh': '蛋白质', 'en': 'Protein'},
    'proteinField': {'zh': '蛋白质含量 (g/100ml)', 'en': 'Protein (g/100ml)'},
    'proteinHint': {'zh': '如：3.3', 'en': 'e.g. 3.3'},
    'gPer100ml': {'zh': 'g/100ml', 'en': 'g/100ml'},
    'price': {'zh': '价格', 'en': 'Price'},
    'priceField': {'zh': '价格 (元)', 'en': 'Price (¥)'},
    'priceHint': {'zh': '如：10', 'en': 'e.g. 10'},
    'yuan': {'zh': '元', 'en': '¥'},
    'save': {'zh': '保存修改', 'en': 'Save Changes'},
    'submit': {'zh': '加入对比', 'en': 'Add to Compare'},
    'deleted': {'zh': '已删除', 'en': 'Deleted'},
    'undo': {'zh': '撤销', 'en': 'Undo'},
    'unnamed': {'zh': '未命名牛奶', 'en': 'Unnamed Milk'},
    'bestValue': {'zh': '性价比最高', 'en': 'Best Value'},
    'edit': {'zh': '编辑', 'en': 'Edit'},
    'delete': {'zh': '删除', 'en': 'Delete'},
    'totalProtein': {'zh': '总蛋白质', 'en': 'Total Protein'},
    'proteinPerYuan': {'zh': '每元蛋白质', 'en': 'Protein per ¥'},
    'per100ml': {'zh': '每100ml', 'en': 'per 100ml'},
    'pleaseEnter': {'zh': '请输入{field}', 'en': 'Please enter {field}'},
    'mustBeNumber': {'zh': '请输入数字', 'en': 'Please enter a number'},
    'mustBePositive': {'zh': '需大于 0', 'en': 'Must be greater than 0'},
  };

  /// 取当前语言下 key 对应的文案；缺失时回退为 key 本身，便于排查。
  static String tr(BuildContext context, String key) {
    final isZh = LocaleScope.of(context).isZh;
    final lang = isZh ? 'zh' : 'en';
    return _strings[key]?[lang] ?? key;
  }

  /// 隐私政策正文，随语言切换。
  static String privacyText(bool isZh) => isZh ? _privacyZh : _privacyEn;

  static const String _privacyZh = '''
欢迎使用《牛奶计算器》。我们非常重视您的隐私保护，请在继续使用前阅读以下要点：

一、我们收集的信息
本应用完全离线运行，不收集、不上传任何个人信息。所有功能在您设备本地完成，不连接网络、不向任何服务器发送数据。

二、数据存储
您输入的牛奶数据仅保存在设备本地私有存储中，不会离开您的设备，我们及任何第三方均无法访问。卸载应用即可彻底删除全部本地数据。

三、权限使用
本应用不申请任何敏感权限（如通讯录、定位、相机、麦克风等）。

四、第三方共享
我们不与任何第三方共享、出售或转让您的个人信息。

五、儿童隐私
本应用不面向儿童收集个人信息。

六、联系我们
如对本政策有疑问，可通过电子邮件 hjd2002@yeah.net 联系我们。

完整政策：https://dhj999.github.io/milk_protein_calculator/privacy.html
''';

  static const String _privacyEn = '''
Welcome to "Milk Calculator". We take your privacy very seriously. Please read the following points before continuing to use the app:

1. Information We Collect
This app runs entirely offline. It does not collect or upload any personal information. All features run locally on your device — it never connects to the network or sends any data to a server.

2. Data Storage
The milk data you enter is stored only in your device's private local storage and never leaves your device. Neither we nor any third party can access it. Uninstalling the app permanently deletes all local data.

3. Permission Usage
This app requests no sensitive permissions (such as contacts, location, camera, microphone, etc.).

4. Third-Party Sharing
We do not share, sell, or transfer your personal information to any third party.

5. Children's Privacy
This app does not collect personal information from children.

6. Contact Us
If you have any questions about this policy, please contact us at hjd2002@yeah.net.

Full policy: https://dhj999.github.io/milk_protein_calculator/privacy.html
''';
}
