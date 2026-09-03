# 牛奶计算器

> 🌐 **语言 / Language**：[English](README.en.md) · 中文

> ⚠️ **版权与授权声明**
> 本仓库代码及「牛奶计算器」App 的版权归作者所有。
> - ✅ 允许：个人学习、研究、非商业性使用。
> - ❌ **禁止**：任何商业用途与盈利行为（包括但不限于销售、转售、投放广告、集成进商业产品、以之获利）。
> - 如需商业使用，须事先获得作者书面授权。联系：hjd2002@yeah.net

一个帮你买牛奶时做决策的 App：输入**容量、蛋白质含量、价格**，自动算出
**总蛋白质**和**每元多少克蛋白质（性价比）**，把不同牛奶放在一起对比，并按性价比
综合排序，一眼看出哪瓶最划算。

> 例：一瓶 1000ml 鲜牛奶，蛋白质 3.3g/100ml，价格 ¥10
> - 总蛋白质 = 3.3 × (1000 / 100) = **33 g**
> - 每元蛋白质 = 33 / 10 = **3.3 g/元**  ← 性价比，越高越值

## 技术栈
- Flutter 3.x（一套代码出 iOS + Android）
- 纯本地存储（shared_preferences），无账号、不联网、数据不丢

## 功能
- ➕ 添加牛奶：名称（选填）、容量 ml、蛋白质 g/100ml、价格 ¥
- 🧮 自动计算：总蛋白质、每元蛋白质、每 100ml 单价
- 📊 对比列表：每张卡片带排名，性价比最高的标「性价比最高」
- ↕️ 三种排序：性价比（克/元）↓ / 总蛋白质（g）↓ / 每 100ml 单价（¥）↑
- 🗑️ 点击卡片上的删除图标即可移除某瓶（支持撤销）
- ✏️ 点击编辑图标可修改已录入的牛奶
- 🌐 中英文界面一键切换：在「设置」页选择语言，切换后立即生效，并自动记住你的选择
- ✅ 单元测试：`flutter test` 验证计算公式与界面烟测

## 运行步骤
> 需要本机已安装 Flutter SDK（≥ 3.0）。未安装请先到 https://docs.flutter.dev/get-started/install 安装。

```bash
# 1. 进入项目目录
cd milk_protein_calculator

# 2. 安装依赖
flutter pub get

# 3. 生成 android / ios 原生工程（仅首次需要，不会改动 lib/ 代码）
flutter create .

# 4. 连上手机或启动模拟器后运行
flutter run

# 想单独跑 iOS / Android：
flutter run -d ios
flutter run -d android
```

## 打包
```bash
flutter build apk --release      # Android APK
flutter build appbundle --release # Android AAB（上架 Play）
flutter build ios --release      # iOS（需 macOS + Xcode）
```

## 目录结构
```
lib/
  main.dart                 # 入口 + 主题 + 语言 Provider
  models/milk.dart          # 数据模型与计算公式
  services/storage.dart     # 本地持久化（含语言偏好）
  l10n/l10n.dart            # 国际化：中 / 英文案与语言状态管理
  widgets/milk_card.dart    # 单瓶牛奶信息卡
  screens/home_screen.dart  # 首页：列表 / 添加 / 排序 / 对比
  screens/settings_screen.dart # 设置页：语言切换
```

## 作者想说的话
这只是一个简单的小工具，做它的初衷就是买牛奶时能一眼看出哪瓶更划算。
如果你用着觉得还行，正好又有其他想要的功能或想法，欢迎邮件告诉我：hjd2002@yeah.net
能帮上你一点点，就很开心了。
