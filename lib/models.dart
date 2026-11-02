import 'package:flutter/material.dart';

enum SportType { turf, pickleball, snooker }

extension SportInfo on SportType {
  String get label => switch (this) {
        SportType.turf => 'Turf',
        SportType.pickleball => 'Pickleball',
        SportType.snooker => 'Snooker',
      };
  IconData get icon => switch (this) {
        SportType.turf => Icons.sports_soccer,
        SportType.pickleball => Icons.sports_tennis,
        SportType.snooker => Icons.pool,
      };
  Color get color => switch (this) {
        SportType.turf => const Color(0xFF1FA64F),
        SportType.pickleball => const Color(0xFF2F7DE1),
        SportType.snooker => const Color(0xFF8B5CF6),
      };
}

class Venture {
  final String id;
  final String name;
  final String area;
  final SportType sport;
  const Venture(this.id, this.name, this.area, this.sport);
}

enum SlotStatus { open, booked, blocked }

class Slot {
  final String id;
  final String time;
  final String sport;
  final int price;
  final bool isEvening;
  SlotStatus status;
  final String? player;
  final String? phone;
  Slot({
    required this.id,
    required this.time,
    required this.sport,
    required this.price,
    required this.isEvening,
    required this.status,
    this.player,
    this.phone,
  });
  bool get isWalkIn => status == SlotStatus.booked && phone == null;
}

class Booking {
  final String venture;
  final SportType sport;
  final String player;
  final String time;
  final int amount;
  final bool paid;
  const Booking(this.venture, this.sport, this.player, this.time, this.amount, this.paid);
}

class VentureSummary {
  final Venture venture;
  final int bookings;
  final int revenue;
  final double utilisation;
  const VentureSummary(this.venture, this.bookings, this.revenue, this.utilisation);
}

class OverviewStats {
  final int todayBookings;
  final int todayRevenue;
  final double utilisation;
  final int pendingPayout;
  final List<Booking> upcoming;
  final List<VentureSummary> perVenture;
  const OverviewStats(this.todayBookings, this.todayRevenue, this.utilisation, this.pendingPayout, this.upcoming, this.perVenture);
}

class Payout {
  final String dateLabel;
  final int amount;
  final int bookings;
  final bool paid;
  const Payout(this.dateLabel, this.amount, this.bookings, this.paid);
}

class DayRevenue {
  final String label;
  final int amount;
  const DayRevenue(this.label, this.amount);
}

class AnalyticsData {
  final List<DayRevenue> trend;
  final double morningUtil;
  final double eveningUtil;
  final int totalBookings;
  final int repeatPercent;
  final String peakSlot;
  const AnalyticsData(this.trend, this.morningUtil, this.eveningUtil, this.totalBookings, this.repeatPercent, this.peakSlot);
}

class ChatMsg {
  final String text;
  final bool fromOwner;
  ChatMsg(this.text, this.fromOwner);
}
