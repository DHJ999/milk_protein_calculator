import 'dart:math';

import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/milk.dart';
import '../screens/settings_screen.dart';
import '../services/storage.dart';
import '../widgets/milk_card.dart';

enum SortMode {
  value, // 性价比：每元蛋白质，降序
  protein, // 总蛋白质，降序
  unitPrice, // 每 100ml 单价，升序（越便宜越好）
}

extension SortModeX on SortMode {
  String label(BuildContext context) {
    switch (this) {
      case SortMode.value:
        return L10n.tr(context, 'sortValue');
      case SortMode.protein:
        return L10n.tr(context, 'sortProtein');
      case SortMode.unitPrice:
        return L10n.tr(context, 'sortUnitPrice');
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
  bool _privacyDenied = false;

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

  Future<void> _showPrivacyDialog() async {
    final isZh = LocaleScope.of(context).isZh;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(L10n.tr(context, 'privacyPolicy')),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Text(
              L10n.privacyText(isZh),
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(L10n.tr(context, 'disagree')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(L10n.tr(context, 'agree')),
          ),
        ],
      ),
    );
    if (result == true) {
      await PrivacyStorage.setAccepted();
      _load();
    } else {
      if (mounted) setState(() => _privacyDenied = true);
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
        content: Text(L10n.tr(context, 'deleted')),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: L10n.tr(context, 'undo'),
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
    if (_privacyDenied) {
      return Scaffold(
        appBar: AppBar(title: Text(L10n.tr(context, 'appTitle'))),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.amber[700],
              ),
              const SizedBox(height: 16),
              Text(
                L10n.tr(context, 'needPrivacy'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                L10n.tr(context, 'exitAndRetry'),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final sorted = _sorted;
    final bestId = sorted.isNotEmpty ? sorted.first.id : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.tr(context, 'appTitle')),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: L10n.tr(context, 'settings'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          PopupMenuButton<SortMode>(
            icon: const Icon(Icons.sort),
            tooltip: L10n.tr(context, 'sort'),
            onSelected: (m) => setState(() => _sort = m),
            itemBuilder: (ctx) => SortMode.values
                .map((m) => PopupMenuItem(value: m, child: Text(m.label(ctx))))
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
        label: Text(L10n.tr(context, 'addMilk')),
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
          Text(L10n.tr(context, 'currentSort'),
              style: const TextStyle(fontSize: 13)),
          Text(sort.label(context),
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(L10n.tr(context, 'tapToSwitch'),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
          Text(L10n.tr(context, 'emptyTitle'),
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(L10n.tr(context, 'emptyHint'),
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(L10n.tr(context, 'addFirst')),
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

  String? _require(String? v, String fieldKey) {
    if (v == null || v.trim().isEmpty) {
      return L10n.tr(context, 'pleaseEnter')
          .replaceFirst('{field}', L10n.tr(context, fieldKey));
    }
    final n = double.tryParse(v.trim());
    if (n == null) return L10n.tr(context, 'mustBeNumber');
    if (n <= 0) return L10n.tr(context, 'mustBePositive');
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
                  Text(_isEdit ? L10n.tr(context, 'editMilk') : L10n.tr(context, 'addMilk'),
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
                decoration: InputDecoration(
                  labelText: L10n.tr(context, 'nameField'),
                  hintText: L10n.tr(context, 'nameHint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _volumeCtl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: L10n.tr(context, 'volumeField'),
                  hintText: L10n.tr(context, 'volumeHint'),
                  border: const OutlineInputBorder(),
                  suffixText: L10n.tr(context, 'ml'),
                ),
                validator: (v) => _require(v, 'volume'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proteinCtl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: L10n.tr(context, 'proteinField'),
                  hintText: L10n.tr(context, 'proteinHint'),
                  border: const OutlineInputBorder(),
                  suffixText: L10n.tr(context, 'gPer100ml'),
                ),
                validator: (v) => _require(v, 'protein'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: L10n.tr(context, 'priceField'),
                  hintText: L10n.tr(context, 'priceHint'),
                  border: const OutlineInputBorder(),
                  suffixText: L10n.tr(context, 'yuan'),
                ),
                validator: (v) => _require(v, 'price'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(_isEdit
                      ? L10n.tr(context, 'save')
                      : L10n.tr(context, 'submit')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
