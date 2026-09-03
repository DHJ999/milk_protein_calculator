import 'package:flutter/material.dart';
import '../models/milk.dart';

class MilkCard extends StatelessWidget {
  final Milk milk;
  final int rank; // 综合排序后的名次（从 1 开始）
  final bool isBest; // 是否为当前排序维度下的最优项
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MilkCard({
    super.key,
    required this.milk,
    required this.rank,
    required this.isBest,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isBest ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isBest
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    milk.name.isEmpty ? '未命名牛奶' : milk.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isBest)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('性价比最高',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600)),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.grey[500],
                  onPressed: onEdit,
                  tooltip: '编辑',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.grey[500],
                  onPressed: onDelete,
                  tooltip: '删除',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _SpecChip(label: '容量', value: '${_fmt(milk.volume)} ml'),
                _SpecChip(
                    label: '蛋白质', value: '${_fmt(milk.proteinPer100)} g/100ml'),
                _SpecChip(label: '价格', value: '¥${_fmt(milk.price)}'),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Metric(
                    label: '总蛋白质',
                    value: '${_fmt(milk.totalProtein)} g',
                    highlight: false,
                  ),
                  _divider(),
                  _Metric(
                    label: '每元蛋白质',
                    value: '${_fmt(milk.proteinPerYuan)} g',
                    highlight: true,
                  ),
                  _divider(),
                  _Metric(
                    label: '每100ml',
                    value: '¥${_fmt(milk.pricePer100ml)}',
                    highlight: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: Colors.grey.withValues(alpha: 0.25),
      );

  String _fmt(double v) {
    // 整数不显示小数；非整数保留最多 2 位，去除末尾 0
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  final String value;
  const _SpecChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _Metric(
      {required this.label,
      required this.value,
      required this.highlight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: highlight
                    ? theme.colorScheme.primary
                    : Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight ? theme.colorScheme.primary : Colors.black87,
          ),
        ),
      ],
    );
  }
}
