/// 一瓶牛奶的基础信息（用户输入）与所有派生指标（自动计算）。
///
/// 计算逻辑（与你描述的一致）：
///   总蛋白质(g)      = 蛋白质含量(g/100ml) × 容量(ml) / 100
///   每元蛋白质(g/元) = 总蛋白质 / 价格      —— 性价比核心指标，越高越值
///   每100ml单价(元)  = 价格 / (容量 / 100)  —— 横向比单价用
///   每克蛋白质价(元)  = 价格 / 总蛋白质      —— 与「每元蛋白质」互为倒数
class Milk {
  final String id;
  final String name;
  final double volume; // 容量，单位 ml
  final double proteinPer100; // 蛋白质含量，单位 g/100ml
  final double price; // 价格，单位 元

  Milk({
    required this.id,
    required this.name,
    required this.volume,
    required this.proteinPer100,
    required this.price,
  });

  /// 总蛋白质 = 蛋白质含量 × (容量 / 100)
  double get totalProtein => proteinPer100 * (volume / 100);

  /// 每元多少克蛋白质（性价比）—— 越高越划算
  double get proteinPerYuan => price > 0 ? totalProtein / price : 0;

  /// 每 100ml 单价
  double get pricePer100ml => volume > 0 ? price / (volume / 100) : 0;

  /// 每克蛋白质多少钱（与 proteinPerYuan 互为倒数）
  double get pricePerGramProtein => totalProtein > 0 ? price / totalProtein : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'volume': volume,
        'proteinPer100': proteinPer100,
        'price': price,
      };

  factory Milk.fromJson(Map<String, dynamic> json) => Milk(
        id: json['id'] as String,
        name: json['name'] as String,
        volume: (json['volume'] as num).toDouble(),
        proteinPer100: (json['proteinPer100'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
      );
}
