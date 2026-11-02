import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';

class AnalyticsScreen extends StatelessWidget {
  final Venture? venture;
  const AnalyticsScreen({super.key, required this.venture});

  @override
  Widget build(BuildContext context) {
    return Load<AnalyticsData>(
      fetch: () => repo.analytics(venture?.id),
      builder: (context, a) {
        final week = a.trend.fold<int>(0, (s, d) => s + d.amount);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venture == null ? 'Is hafte ki kamai · sabhi ventures' : 'Is hafte ki kamai · ${venture!.name}', style: const TextStyle(color: TB.muted)),
                  const SizedBox(height: 4),
                  Text(rupees(week), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  SizedBox(height: 160, child: CustomPaint(painter: _BarPainter(a.trend), size: Size.infinite)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Mini(label: 'Bookings (30 din)', value: '${a.totalBookings}')),
                const SizedBox(width: 12),
                Expanded(child: _Mini(label: 'Repeat players', value: '${a.repeatPercent}%')),
              ],
            ),
            const SizedBox(height: 12),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Slot utilisation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 14),
                  _Bar(label: 'Din · 6 AM - 5 PM', value: a.morningUtil, color: TB.amber),
                  const SizedBox(height: 12),
                  _Bar(label: 'Raat · 6 PM - 5 AM', value: a.eveningUtil, color: TB.green),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Panel(
              color: TB.tint,
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: TB.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sabse busy slot', style: TextStyle(color: TB.muted, fontSize: 13)),
                        Text(a.peakSlot, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  const _Mini({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: TB.muted, fontSize: 13)),
          ],
        ),
      );
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _Bar({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(color: TB.muted, fontSize: 13))),
              Text('${(value * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: value, minHeight: 9, backgroundColor: TB.tint, color: color),
          ),
        ],
      );
}

class _BarPainter extends CustomPainter {
  final List<DayRevenue> data;
  _BarPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxV = data.map((d) => d.amount).reduce((a, b) => a > b ? a : b).toDouble();
    const labelH = 20.0;
    final chartH = size.height - labelH;
    final slot = size.width / data.length;
    final barW = slot * 0.56;
    final top = data.indexWhere((d) => d.amount.toDouble() == maxV);
    for (var i = 0; i < data.length; i++) {
      final h = chartH * (data[i].amount / maxV);
      final x = slot * i + (slot - barW) / 2;
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, chartH - h, barW, h), const Radius.circular(8));
      canvas.drawRRect(rect, Paint()..color = i == top ? TB.greenDark : TB.green.withOpacity(0.45));
      final tp = TextPainter(
        text: TextSpan(text: data[i].label, style: const TextStyle(color: TB.muted, fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(slot * i + (slot - tp.width) / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) => old.data != data;
}
