import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';

class OverviewScreen extends StatelessWidget {
  final Venture? venture;
  final void Function(Venture) onPick;
  final VoidCallback onOpenBuddie;
  const OverviewScreen({super.key, required this.venture, required this.onPick, required this.onOpenBuddie});

  @override
  Widget build(BuildContext context) {
    return Load<OverviewStats>(
      fetch: () => repo.overview(venture?.id),
      builder: (context, s) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Panel(
              color: TB.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venture == null ? 'Aaj ki kamai · sabhi ventures' : 'Aaj ki kamai · ${venture!.name}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(rupees(s.todayRevenue), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: s.utilisation, minHeight: 8, backgroundColor: Colors.white24, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text('${(s.utilisation * 100).round()}% slots booked aaj', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Stat(icon: Icons.event_available, label: 'Bookings aaj', value: '${s.todayBookings}')),
                const SizedBox(width: 12),
                Expanded(child: _Stat(icon: Icons.account_balance_wallet, label: 'Agla payout', value: rupees(s.pendingPayout))),
              ],
            ),
            if (venture == null) ...[
              const SizedBox(height: 22),
              const Text('Aapke ventures', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 10),
              for (final p in s.perVenture)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onPick(p.venture),
                    child: Panel(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _SportBadge(p.venture.sport),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.venture.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text('${p.venture.sport.label} · ${p.bookings} bookings · ${(p.utilisation * 100).round()}% full', style: const TextStyle(color: TB.muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(rupees(p.revenue), style: const TextStyle(fontWeight: FontWeight.w800)),
                          const Icon(Icons.chevron_right, color: TB.muted),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onOpenBuddie,
              child: Panel(
                color: TB.tint,
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: TB.green, child: Icon(Icons.support_agent, color: Colors.white)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kuch kharab hai?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('AI Buddie ko bolo, vendor connect kar degi.', style: TextStyle(color: TB.muted, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: TB.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Aaj ke bookings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 10),
            if (s.upcoming.isEmpty)
              const Panel(child: Text('Aaj koi booking nahi hai. Buddie se offer chalwa lo.', style: TextStyle(color: TB.muted)))
            else
              for (final b in s.upcoming)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Panel(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        _SportBadge(b.sport),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.player, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('${b.time} · ${b.venture}', style: const TextStyle(color: TB.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(rupees(b.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text(b.paid ? 'Paid' : 'Walk-in', style: TextStyle(color: b.paid ? TB.green : TB.amber, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _SportBadge extends StatelessWidget {
  final SportType sport;
  const _SportBadge(this.sport);
  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: sport.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(sport.icon, color: sport.color),
      );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: TB.green, size: 22),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: TB.muted, fontSize: 13)),
          ],
        ),
      );
}
