// 牛奶计算器 烟测：验证 App 能启动、首页文案与 FAB 可见。
// 覆盖「隐私政策已接受 → 空列表态」的主路径。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milk_protein_calculator/main.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // 每个测试前预设：隐私政策已同意，跳过首启弹窗直接进主界面
  setUp(() async {
    SharedPreferences.setMockInitialValues({'privacy_accepted_v1': true});
  });

  testWidgets('首次未同意隐私政策时弹出隐私弹窗', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MilkApp());
    // loading 指示器是无限动画，不能用 pumpAndSettle，固定推进即可
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('同意并继续'), findsOneWidget);
    expect(find.text('不同意并退出'), findsOneWidget);

    // 点击同意后进入主界面
    await tester.tap(find.text('同意并继续'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('还没有记录任何牛奶'), findsOneWidget);
  });

  testWidgets('App 启动后显示首页标题与空态提示', (tester) async {
    await tester.pumpWidget(const MilkApp());
    await tester.pump();

    // 首页标题
    expect(find.text('牛奶计算器'), findsOneWidget);

    // 空列表态文案
    expect(find.text('还没有记录任何牛奶'), findsOneWidget);
    expect(find.text('添加一瓶，算算它的性价比'), findsOneWidget);
    expect(find.text('添加第一瓶'), findsOneWidget);
  });

  testWidgets('右上角排序菜单可展开', (tester) async {
    await tester.pumpWidget(const MilkApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pump();

    expect(find.text('性价比 (克/元)'), findsOneWidget);
    expect(find.text('总蛋白质 (g)'), findsOneWidget);
    expect(find.text('每100ml单价 (¥)'), findsOneWidget);
  });

  testWidgets('FAB 可打开添加牛奶面板', (tester) async {
    await tester.pumpWidget(const MilkApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // 空态按钮里也有 add 图标，直接点 FAB 本身
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 400));

    // 「添加牛奶」出现两次：FAB 标签 + 面板标题
    expect(find.text('添加牛奶'), findsNWidgets(2));
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('添加一瓶牛奶后卡片正确显示计算结果', (tester) async {
    await tester.pumpWidget(const MilkApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // 打开添加面板（点 FAB；空态按钮里也有 add 图标）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 400));

    // 表单顺序：名称 / 容量 / 蛋白质 / 价格
    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), '测试牛奶');
    await tester.enterText(fields.at(1), '1000');
    await tester.enterText(fields.at(2), '3.3');
    await tester.enterText(fields.at(3), '10');
    await tester.pump();

    // 点击「加入对比」（空态页的「添加第一瓶」也是 FilledButton，需按文字精确定位）
    final submitBtn = find.widgetWithText(FilledButton, '加入对比');
    await tester.scrollUntilVisible(
      submitBtn,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(submitBtn);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 卡片显示：总蛋白质 33 g、每元蛋白质 3.3 g
    expect(find.text('33 g'), findsOneWidget);
    expect(find.text('3.3 g'), findsOneWidget);
    expect(find.text('性价比最高'), findsOneWidget);
  });

  testWidgets('设置中切换到英文后界面与选择都更新并持久化', (tester) async {
    await tester.pumpWidget(const MilkApp());
    await tester.pump();

    // 打开设置页
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // 默认中文：能看到「界面语言」
    expect(find.text('界面语言'), findsOneWidget);

    // 点击 English 段
    await tester.tap(find.text('English'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // 界面切换为英文
    expect(find.text('Language'), findsWidgets);
    expect(find.text('界面语言'), findsNothing);

    // 选择已持久化到本地存储
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale_v1'), 'en');
  });
}
