import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';

class PayoutsScreen extends StatelessWidget {
  final Venture? venture;
  const PayoutsScreen({super.key, required this.venture});

  String _nextWednesday() {
    var d = DateTime.now();
    while (d.weekday != DateTime.wednesday) {
      d = d.add(const Duration(days: 1));
    }
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return 'Wed, ${d.day} ${m[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Load<List<Payout>>(
      fetch: () => repo.payouts(venture?.id),
      builder: (context, list) {
        final total = list.fold<int>(0, (a, p) => a + p.amount);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Panel(
              color: TB.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venture == null ? 'Agla payout · sabhi ventures' : 'Agla payout · ${venture!.name}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(_nextWednesday(), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Payout har Wednesday ko, booking ke 10 din ke andar.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Panel(
              child: Row(
                children: [
                  const Icon(Icons.savings, color: TB.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Pichle ${list.length} payouts mein mila', style: const TextStyle(color: TB.muted))),
                  Text(rupees(total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Payout history', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 10),
            for (final p in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Panel(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.dateLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text('${p.bookings} bookings', style: const TextStyle(color: TB.muted, fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(rupees(p.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(p.paid ? 'Paid' : 'Processing', style: TextStyle(color: p.paid ? TB.green : TB.amber, fontSize: 12, fontWeight: FontWeight.w600)),
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
