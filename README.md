# 牛奶计算器

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
- 🗑️ 长按/点删除即可移除某瓶

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
  main.dart                 # 入口 + 主题
  models/milk.dart          # 数据模型与计算公式
  services/storage.dart     # 本地持久化
  widgets/milk_card.dart    # 单瓶牛奶信息卡
  screens/home_screen.dart  # 首页：列表 / 添加 / 排序 / 对比
```
