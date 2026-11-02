import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import 'overview.dart';
import 'slots.dart';
import 'buddie.dart';
import 'payouts.dart';
import 'analytics.dart';

class Shell extends StatefulWidget {
  final VoidCallback onLogout;
  const Shell({super.key, required this.onLogout});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;
  int _rev = 0; // bumps when slots change, so Home/Payouts/Insights refresh
  List<Venture> _ventures = [];
  String? _selId; // null = Sabhi ventures
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    repo.ventures().then((v) {
      if (!mounted) return;
      setState(() {
        _ventures = v;
        _loaded = true;
      });
    });
  }

  Venture? get _sel => _selId == null ? null : _ventures.firstWhere((v) => v.id == _selId);

  void _pick(Venture? v) => setState(() => _selId = v?.id);

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: TB.green)));
    }
    final sel = _sel;
    final k = '${_selId ?? 'all'}-$_rev';
    const titles = ['Home', 'Slots', 'AI Buddie', 'Payouts', 'Insights'];
    final pages = <Widget>[
      OverviewScreen(
        key: ValueKey('o$k'),
        venture: sel,
        onPick: (v) => _pick(v),
        onOpenBuddie: () => setState(() => _index = 2),
      ),
      SlotsScreen(
        key: ValueKey('s${_selId ?? 'all'}'),
        venture: sel,
        ventures: _ventures,
        onPick: (v) => _pick(v),
        onChanged: () => setState(() => _rev++),
      ),
      BuddieScreen(key: const ValueKey('buddie'), venture: sel),
      PayoutsScreen(key: ValueKey('p$k'), venture: sel),
      AnalyticsScreen(key: ValueKey('a$k'), venture: sel),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 34),
            const SizedBox(width: 10),
            Text(titles[_index]),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout, color: TB.muted),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _VChip(label: 'Sabhi ventures', icon: Icons.apps, color: TB.greenDark, selected: sel == null, onTap: () => _pick(null)),
                for (final v in _ventures)
                  _VChip(label: v.name, icon: v.sport.icon, color: v.sport.color, selected: sel?.id == v.id, onTap: () => _pick(v)),
              ],
            ),
          ),
          Expanded(child: IndexedStack(index: _index, children: pages)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: TB.greenDark), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month, color: TB.greenDark), label: 'Slots'),
          NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent, color: TB.greenDark), label: 'Buddie'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: TB.greenDark), label: 'Payouts'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: TB.greenDark), label: 'Insights'),
        ],
      ),
    );
  }
}

class _VChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _VChip({required this.label, required this.icon, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? color : TB.line),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? Colors.white : TB.text)),
            ],
          ),
        ),
      ),
    );
  }
}
