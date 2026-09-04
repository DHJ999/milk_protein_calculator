# Milk Calculator

> 🌐 **Language / 语言**：[中文](README.md) · English

> ⚠️ **Copyright & License**
> The code in this repository and the "Milk Calculator" app are licensed under the **PolyForm Noncommercial License 1.0.0** (see [LICENSE](LICENSE)).
> - ✅ Allowed: personal study, research, and any non-commercial use (including modification and redistribution, provided this notice and the author's attribution are retained).
> - ❌ **Prohibited**: any commercial use or monetization (including but not limited to reselling, advertising, bundling into commercial products, or profiting from it).
> - For commercial use, prior written authorization from the author is required. Contact: hjd2002@yeah.net

A small app to help you decide which milk to buy: enter **volume, protein content, and price**, and it automatically calculates **total protein** and **protein per yuan (value)**, so you can compare different milks side by side and rank them by value at a glance to see which one is the best deal.

> Example: a 1000 ml carton of fresh milk, 3.3 g protein per 100 ml, price ¥10
> - Total protein = 3.3 × (1000 / 100) = **33 g**
> - Protein per yuan = 33 / 10 = **3.3 g/¥**  ← value, higher is better

## Tech Stack
- Flutter 3.x (one codebase for iOS + Android)
- Fully local storage (shared_preferences), no account, no network, data never lost

## Features
- ➕ Add milk: name (optional), volume in ml, protein in g/100ml, price in ¥
- 🧮 Auto-calculate: total protein, protein per yuan, unit price per 100 ml
- 📊 Comparison list: each card shows a rank; the best value is tagged "Best Value"
- ↕️ Three sort modes: Value (g/¥) ↓ / Total Protein (g) ↓ / Unit Price (¥/100ml) ↑
- 🗑️ Tap the delete icon on a card to remove it (with undo support)
- ✏️ Tap the edit icon to modify an already-entered milk
- 🌐 One-tap Chinese / English switch: pick a language in **Settings**; it applies instantly and is remembered automatically
- 🏷️ App name follows the system language: shows "牛奶计算器" on Chinese devices and "Milk Calculator" on English ones
- ✅ Unit tests: `flutter test` covers the calculation formulas and UI smoke tests

## Running the App
> Requires the Flutter SDK (≥ 3.0) installed locally. If not, install it first at https://docs.flutter.dev/get-started/install.

```bash
# 1. Enter the project directory
cd milk_protein_calculator

# 2. Install dependencies
flutter pub get

# 3. Generate the android / ios native projects (first time only; does not change lib/ code)
flutter create .

# 4. Connect a phone or start an emulator, then run
flutter run

# To run iOS / Android specifically:
flutter run -d ios
flutter run -d android
```

## Building Release Packages
```bash
flutter build apk --release      # Android APK
flutter build appbundle --release # Android AAB (for Play Store)
flutter build ios --release      # iOS (requires macOS + Xcode)
```

## Language Switching
The app supports **中文 / English** out of the box. Open **Settings** (the gear icon in the top-right of the home screen), then choose your language under **Language**. The change takes effect immediately and is saved locally, so it persists the next time you open the app. No account or network is required.

## Project Structure
```
lib/
  main.dart                 # Entry point + theme + locale provider
  models/milk.dart          # Data model and calculation formulas
  services/storage.dart     # Local persistence (including language preference)
  l10n/l10n.dart            # Internationalization: zh / en strings and locale state
  widgets/milk_card.dart    # Single-milk info card
  screens/home_screen.dart  # Home: list / add / sort / compare
  screens/settings_screen.dart # Settings: language switch
```
