import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/milk.dart';
import '../services/storage.dart';
import '../widgets/milk_card.dart';

enum SortMode {
  value, // 性价比：每元蛋白质，降序
  protein, // 总蛋白质，降序
  unitPrice, // 每 100ml 单价，升序（越便宜越好）
}

extension SortModeX on SortMode {
  String get label {
    switch (this) {
      case SortMode.value:
        return '性价比 (克/元)';
      case SortMode.protein:
        return '总蛋白质 (g)';
      case SortMode.unitPrice:
        return '每100ml单价 (¥)';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Milk> _milks = [];
  SortMode _sort = SortMode.value;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPrivacy();
  }

  Future<void> _checkPrivacy() async {
    final accepted = await PrivacyStorage.isAccepted();
    if (!mounted) return;
    if (accepted) {
      _load();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showPrivacyDialog();
      });
    }
  }

  static const String _privacyText = '''
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

完整政策：https://dhj999.github.io/milk-protein-calculator/privacy.html
''';

  Future<void> _showPrivacyDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: const Text('隐私政策'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Text(
              _privacyText,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('不同意并退出'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('同意并继续'),
          ),
        ],
      ),
    );
    if (result == true) {
      await PrivacyStorage.setAccepted();
      _load();
    } else {
      SystemNavigator.pop();
    }
  }

  Future<void> _load() async {
    try {
      final list = await MilkStorage.load();
      if (!mounted) return;
      setState(() {
        _milks = list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('load milk list failed: $e');
      if (!mounted) return;
      setState(() {
        _milks = [];
        _loading = false;
      });
    }
  }

  Future<void> _persist() async {
    await MilkStorage.save(_milks);
  }

  List<Milk> get _sorted {
    final list = List<Milk>.from(_milks);
    switch (_sort) {
      case SortMode.value:
        list.sort((a, b) => b.proteinPerYuan.compareTo(a.proteinPerYuan));
        break;
      case SortMode.protein:
        list.sort((a, b) => b.totalProtein.compareTo(a.totalProtein));
        break;
      case SortMode.unitPrice:
        list.sort((a, b) => a.pricePer100ml.compareTo(b.pricePer100ml));
        break;
    }
    return list;
  }

  void _addMilk(Milk milk) {
    setState(() => _milks.add(milk));
    _persist();
  }

  void _deleteMilk(String id) {
    final idx = _milks.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final removed = _milks[idx];
    setState(() => _milks.removeAt(idx));
    _persist();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已删除'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            setState(() {
              final insertAt = idx.clamp(0, _milks.length);
              _milks.insert(insertAt, removed);
            });
            _persist();
          },
        ),
      ),
    );
  }

  void _updateMilk(Milk milk) {
    setState(() {
      final idx = _milks.indexWhere((m) => m.id == milk.id);
      if (idx != -1) _milks[idx] = milk;
    });
    _persist();
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddSheet(onSubmit: _addMilk),
    );
  }

  void _showEditSheet(Milk milk) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddSheet(initial: milk, onSubmit: _updateMilk),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    final bestId = sorted.isNotEmpty ? sorted.first.id : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('牛奶计算器'),
        centerTitle: false,
        actions: [
          PopupMenuButton<SortMode>(
            icon: const Icon(Icons.sort),
            tooltip: '排序方式',
            onSelected: (m) => setState(() => _sort = m),
            itemBuilder: (ctx) => SortMode.values
                .map((m) => PopupMenuItem(value: m, child: Text(m.label)))
                .toList(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : sorted.isEmpty
              ? _EmptyState(onAdd: _showAddSheet)
              : Column(
                  children: [
                    _SortBar(sort: _sort),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sorted.length,
                        itemBuilder: (ctx, i) => MilkCard(
                          milk: sorted[i],
                          rank: i + 1,
                          isBest: sorted[i].id == bestId,
                          onDelete: () => _deleteMilk(sorted[i].id),
                          onEdit: () => _showEditSheet(sorted[i]),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('添加牛奶'),
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  final SortMode sort;
  const _SortBar({required this.sort});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 16),
          const SizedBox(width: 6),
          const Text('当前排序：', style: TextStyle(fontSize: 13)),
          Text(sort.label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Text('点击右上角 ↗ 切换',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_drink_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('还没有记录任何牛奶',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 6),
          const Text('添加一瓶，算算它的性价比',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('添加第一瓶'),
          ),
        ],
      ),
    );
  }
}

class _AddSheet extends StatefulWidget {
  final void Function(Milk) onSubmit;
  final Milk? initial;

  const _AddSheet({required this.onSubmit, this.initial});

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _nameCtl = TextEditingController();
  final _volumeCtl = TextEditingController();
  final _proteinCtl = TextEditingController();
  final _priceCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    if (m != null) {
      _nameCtl.text = m.name;
      _volumeCtl.text = m.volume.toString();
      _proteinCtl.text = m.proteinPer100.toString();
      _priceCtl.text = m.price.toString();
    } else {
      // 添加模式下，弹窗打开后自动聚焦到名称字段
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _nameFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _volumeCtl.dispose();
    _proteinCtl.dispose();
    _priceCtl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final initial = widget.initial;
    final milk = Milk(
      id: initial?.id ??
          Random().nextInt(1 << 32).toString() +
              DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtl.text.trim(),
      volume: double.parse(_volumeCtl.text.trim()),
      proteinPer100: double.parse(_proteinCtl.text.trim()),
      price: double.parse(_priceCtl.text.trim()),
    );
    widget.onSubmit(milk);
    Navigator.pop(context);
  }

  String? _require(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '请输入$field';
    final n = double.tryParse(v.trim());
    if (n == null) return '请输入数字';
    if (n <= 0) return '需大于 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                             Row(
                children: [
                  Text(_isEdit ? '编辑牛奶' : '添加牛奶',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtl,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: '名称 / 品牌（选填）',
                  hintText: '牛奶名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _volumeCtl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '容量 (ml)',
                  hintText: '如：1000',
                  border: OutlineInputBorder(),
                  suffixText: 'ml',
                ),
                validator: (v) => _require(v, '容量'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proteinCtl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '蛋白质含量 (g/100ml)',
                  hintText: '如：3.3',
                  border: OutlineInputBorder(),
                  suffixText: 'g/100ml',
                ),
                validator: (v) => _require(v, '蛋白质含量'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '价格 (元)',
                  hintText: '如：10',
                  border: OutlineInputBorder(),
                  suffixText: '元',
                ),
                validator: (v) => _require(v, '价格'),
              ),
              const SizedBox(height: 20),
                SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(_isEdit ? '保存修改' : '加入对比'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
