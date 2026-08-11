import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/milk.dart';

/// 用 shared_preferences 把牛奶列表以 JSON 形式存到本地，
/// 无需联网、无账号，重启 App 数据不丢。
class MilkStorage {
  static const _key = 'milk_list_v1';

  static Future<List<Milk>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => Milk.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      debugPrint('MilkStorage.load failed: $e\n$st');
      return [];
    }
  }

  static Future<void> save(List<Milk> milks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(milks.map((m) => m.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
