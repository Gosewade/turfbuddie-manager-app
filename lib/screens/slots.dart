import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';

class SlotsScreen extends StatefulWidget {
  final Venture? venture;
  final List<Venture> ventures;
  final void Function(Venture) onPick;
  final VoidCallback onChanged;
  const SlotsScreen({super.key, required this.venture, required this.ventures, required this.onPick, required this.onChanged});
  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  late DateTime _date;
  Future<List<Slot>>? _future;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _date = DateTime(n.year, n.month, n.day);
    _load();
  }

  void _load() {
    final v = widget.venture;
    _future = v == null ? null : repo.slots(v.id, _date);
  }

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<void> _setBlocked(Slot s, bool block) async {
    await repo.setSlotBlocked(widget.venture!.id, _date, s.id, block);
    if (!mounted) return;
    _toast(block ? '${s.time} block ho gaya. Users ko nahi dikhega.' : '${s.time} wapas open ho gaya.');
    setState(_load);
    widget.onChanged();
  }

  Future<void> _walkIn(Slot s) async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Walk-in booking'),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Customer ka naam (optional)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Book karo')),
        ],
      ),
    );
    if (name == null) return;
    await repo.addWalkIn(widget.venture!.id, _date, s.id, name);
    if (!mounted) return;
    _toast('${s.time} walk-in ke liye book ho gaya.');
    setState(_load);
    widget.onChanged();
  }

  Future<void> _closeDay() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Aaj band karein?'),
        content: const Text('Is din ke sabhi open slots block ho jayenge. Booked slots pe asar nahi padega.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Nahi')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Haan, band karo')),
        ],
      ),
    );
    if (ok != true) return;
    final n = await repo.closeDay(widget.venture!.id, _date);
    if (!mounted) return;
    _toast('$n slots block ho gaye.');
    setState(_load);
    widget.onChanged();
  }

  void _sheet(Slot s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        final children = <Widget>[
          Text(s.time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('${s.sport} · ${rupees(s.price)}', style: const TextStyle(color: TB.muted)),
          const SizedBox(height: 12),
        ];
        if (s.status == SlotStatus.open) {
          children.addAll([
            ListTile(
              leading: const Icon(Icons.person_add_alt_1, color: TB.green),
              title: const Text('Walk-in booking add karo', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Customer venue pe aaya hai'),
              onTap: () {
                Navigator.pop(ctx);
                _walkIn(s);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: TB.red),
              title: const Text('Slot block karo', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Maintenance ya personal use'),
              onTap: () {
                Navigator.pop(ctx);
                _setBlocked(s, true);
              },
            ),
          ]);
        } else if (s.status == SlotStatus.blocked) {
          children.add(ListTile(
            leading: const Icon(Icons.lock_open, color: TB.green),
            title: const Text('Wapas open karo', style: TextStyle(fontWeight: FontWeight.w700)),
            onTap: () {
              Navigator.pop(ctx);
              _setBlocked(s, false);
            },
          ));
        } else {
          children.add(Panel(
            color: TB.tint,
            child: Row(
              children: [
                const Icon(Icons.person, color: TB.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.player ?? '-', style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(s.phone == null ? 'Walk-in booking' : '+91 ${s.phone}', style: const TextStyle(color: TB.muted)),
                    ],
                  ),
                ),
                if (s.phone != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: s.phone!));
                      Navigator.pop(ctx);
                      _toast('Number copy ho gaya');
                    },
                  ),
              ],
            ),
          ));
        }
        children.add(const SizedBox(height: 8));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.venture;
    if (v == null) return _picker();
    final today = DateTime.now();
    return Column(
      children: [
        SizedBox(
          height: 76,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = DateTime(today.year, today.month, today.day).add(Duration(days: i));
              final sel = d == _date;
              return GestureDetector(
                onTap: () => setState(() {
                  _date = d;
                  _load();
                }),
                child: Container(
                  width: 58,
                  decoration: BoxDecoration(
                    color: sel ? TB.green : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? TB.green : TB.line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(i == 0 ? 'Aaj' : _days[d.weekday - 1], style: TextStyle(fontSize: 12, color: sel ? Colors.white : TB.muted, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${d.day}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: sel ? Colors.white : TB.text)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 2),
          child: Row(
            children: [
              const _Legend(color: TB.green, label: 'Open'),
              const SizedBox(width: 12),
              const _Legend(color: TB.amber, label: 'Booked'),
              const SizedBox(width: 12),
              const _Legend(color: TB.red, label: 'Blocked'),
              const Spacer(),
              TextButton.icon(
                onPressed: _closeDay,
                icon: const Icon(Icons.do_not_disturb_on_outlined, size: 18, color: TB.red),
                label: const Text('Din band karo', style: TextStyle(color: TB.red, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Slot>>(
            future: _future,
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: TB.green));
              final slots = snap.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                itemCount: slots.length,
                itemBuilder: (_, i) {
                  final s = slots[i];
                  final color = switch (s.status) {
                    SlotStatus.open => TB.green,
                    SlotStatus.booked => TB.amber,
                    SlotStatus.blocked => TB.red,
                  };
                  final label = switch (s.status) {
                    SlotStatus.open => 'Open',
                    SlotStatus.booked => s.player ?? 'Booked',
                    SlotStatus.blocked => 'Blocked',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _sheet(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border(
                            left: BorderSide(color: color, width: 4),
                            top: const BorderSide(color: TB.line),
                            right: const BorderSide(color: TB.line),
                            bottom: const BorderSide(color: TB.line),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.time, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text('${rupees(s.price)}${s.isEvening ? ' · Evening' : ''}', style: const TextStyle(color: TB.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                              child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _picker() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text('Kis venture ke slots dekhne hain?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 12),
        for (final v in widget.ventures)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => widget.onPick(v),
              child: Panel(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: v.sport.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(v.sport.icon, color: v.sport.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          Text('${v.sport.label} · ${v.area}', style: const TextStyle(color: TB.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: TB.muted),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: TB.muted)),
        ],
      );
}
