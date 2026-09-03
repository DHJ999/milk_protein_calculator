// Milk 模型单元测试：验证四个派生指标的计算公式是否正确。
// 这些是 App 的核心价值，用参数化测试锁住，改了公式断言会先挂。

import 'package:flutter_test/flutter_test.dart';
import 'package:milk_protein_calculator/models/milk.dart';

void main() {
  group('Milk 派生指标', () {
    // 基准案例：1000ml 鲜牛奶，蛋白质 3.3g/100ml，¥10
    late Milk milk;
    setUp(() {
      milk = Milk(
        id: 'test-id',
        name: '测试牛奶',
        volume: 1000,
        proteinPer100: 3.3,
        price: 10,
      );
    });

    test('总蛋白质 = 蛋白质含量 × (容量 / 100)', () {
      expect(milk.totalProtein, closeTo(33.0, 1e-9));
    });

    test('每元蛋白质 = 总蛋白质 / 价格', () {
      expect(milk.proteinPerYuan, closeTo(33.0 / 10, 1e-9));
    });

    test('每 100ml 单价 = 价格 / (容量 / 100)', () {
      expect(milk.pricePer100ml, closeTo(10.0 / 10, 1e-9));
    });

    test('每克蛋白质价 = 价格 / 总蛋白质', () {
      expect(milk.pricePerGramProtein, closeTo(10.0 / 33.0, 1e-9));
    });

    test('每元蛋白质 与 每克蛋白质价 互为倒数', () {
      expect(milk.proteinPerYuan * milk.pricePerGramProtein, closeTo(1.0, 1e-9));
    });

    test('不同规格牛奶的性价比对比正确', () {
      // 500ml / 3.0g/100ml / ¥5 → 总蛋白 15g，每元蛋白 3.0g
      final m2 = Milk(id: 'm2', name: '小盒', volume: 500, proteinPer100: 3.0, price: 5);
      // 2000ml / 2.8g/100ml / ¥15 → 总蛋白 56g，每元蛋白 3.73g
      final m3 = Milk(id: 'm3', name: '大桶', volume: 2000, proteinPer100: 2.8, price: 15);

      expect(m2.totalProtein, closeTo(15.0, 1e-9));
      expect(m2.proteinPerYuan, closeTo(3.0, 1e-9));

      expect(m3.totalProtein, closeTo(56.0, 1e-9));
      expect(m3.proteinPerYuan, closeTo(56.0 / 15, 1e-9));

      // 大桶性价比最高
      expect(m3.proteinPerYuan, greaterThan(m2.proteinPerYuan));
    });

    test('JSON 序列化往返正确', () {
      final json = milk.toJson();
      final restored = Milk.fromJson(json);

      expect(restored.id, milk.id);
      expect(restored.name, milk.name);
      expect(restored.volume, milk.volume);
      expect(restored.proteinPer100, milk.proteinPer100);
      expect(restored.price, milk.price);
      expect(restored.totalProtein, milk.totalProtein);
      expect(restored.proteinPerYuan, milk.proteinPerYuan);
    });
  });

  group('Milk 边界情况', () {
    test('价格为 0 时每元蛋白质应为 0', () {
      final m = Milk(id: 'm', name: '免费', volume: 1000, proteinPer100: 3.0, price: 0);
      expect(m.proteinPerYuan, 0.0);
    });

    test('容量为 0 时每 100ml 单价应为 0', () {
      final m = Milk(id: 'm', name: '空瓶', volume: 0, proteinPer100: 3.0, price: 10);
      expect(m.pricePer100ml, 0.0);
      expect(m.totalProtein, 0.0);
    });

    test('总蛋白质为 0 时每克蛋白价应为 0', () {
      final m = Milk(id: 'm', name: '无蛋白', volume: 1000, proteinPer100: 0, price: 10);
      expect(m.pricePerGramProtein, 0.0);
    });
  });
}
