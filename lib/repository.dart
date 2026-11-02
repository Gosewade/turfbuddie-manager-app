import 'dart:math';
import 'models.dart';

/// ---------------------------------------------------------------
///  BACKEND SWITCH
///  Screens only talk to [ManagerRepository]. Abhi [repo] demo data
///  (MockRepository) deta hai. Backend ready hone par ek class likho
///  jo ye methods implement kare aur neeche ki last line badal do.
///
///  ventureId == null  ->  "Sabhi ventures" (combined view)
/// ---------------------------------------------------------------
abstract class ManagerRepository {
  Future<bool> sendOtp(String phone);
  Future<bool> verifyOtp(String phone, String otp);
  Future<List<Venture>> ventures();
  Future<OverviewStats> overview(String? ventureId);
  Future<List<Slot>> slots(String ventureId, DateTime date);
  Future<void> setSlotBlocked(String ventureId, DateTime date, String slotId, bool blocked);
  Future<void> addWalkIn(String ventureId, DateTime date, String slotId, String customerName);
  Future<int> closeDay(String ventureId, DateTime date);
  Future<List<Payout>> payouts(String? ventureId);
  Future<AnalyticsData> analytics(String? ventureId);
  Future<String> buddieReply(String? ventureId, String message);
}

class MockRepository implements ManagerRepository {
  final Map<String, SlotStatus> _overrides = {};
  final Map<String, String> _walkIns = {};

  static const _ventures = [
    Venture('v1', 'Welcome Venture', 'Dharampeth, Nagpur', SportType.turf),
    Venture('v2', 'Smash Pickleball Arena', 'Dharampeth, Nagpur', SportType.pickleball),
    Venture('v3', 'Cue Club Snooker', 'Sitabuldi, Nagpur', SportType.snooker),
  ];
  static const _names = ['Rohan Patil', 'Aditya Joshi', 'Sneha Kulkarni', 'Karan Mehta', 'Omkar Deshmukh', 'Priya Nair', 'Vivek Rathi'];

  double _factor(SportType s) => switch (s) {
        SportType.turf => 1.0,
        SportType.pickleball => 0.6,
        SportType.snooker => 0.45,
      };

  String _key(String v, DateTime d, String s) => '$v-${d.year}${d.month}${d.day}-$s';

  String _fmt(int h) {
    final hh = h % 24;
    final suffix = hh >= 12 ? 'PM' : 'AM';
    final h12 = hh % 12 == 0 ? 12 : hh % 12;
    return '$h12:00 $suffix';
  }

  Venture _byId(String id) => _ventures.firstWhere((v) => v.id == id);

  List<Slot> _buildSlots(String ventureId, DateTime date) {
    final v = _byId(ventureId);
    final seed = date.day * 31 + date.month + ventureId.codeUnits.fold<int>(0, (a, b) => a + b);
    final rnd = Random(seed);
    late int startH, endH, dayPrice, evePrice, dayRate, eveRate;
    switch (v.sport) {
      case SportType.turf:
        startH = 6; endH = 24; dayPrice = 800; evePrice = 1200; dayRate = 30; eveRate = 62;
      case SportType.pickleball:
        startH = 6; endH = 23; dayPrice = 400; evePrice = 600; dayRate = 35; eveRate = 70;
      case SportType.snooker:
        startH = 11; endH = 24; dayPrice = 300; evePrice = 400; dayRate = 25; eveRate = 60;
    }
    final out = <Slot>[];
    var n = 0;
    for (var h = startH; h < endH; h++) {
      if (v.sport == SportType.turf && h >= 11 && h < 16) continue;
      final evening = h >= 18;
      final id = 's$h';
      final key = _key(ventureId, date, id);
      final roll = rnd.nextInt(100);
      final phoneNum = '98${rnd.nextInt(90000000) + 10000000}';
      final originallyBooked = roll < (evening ? eveRate : dayRate);
      var st = originallyBooked ? SlotStatus.booked : SlotStatus.open;
      String? player;
      String? phone;
      if (originallyBooked) {
        player = _names[(n++ + date.day) % _names.length];
        phone = phoneNum;
      } else {
        final ov = _overrides[key];
        if (ov != null) st = ov;
        if (st == SlotStatus.booked) {
          player = _walkIns[key] ?? 'Walk-in customer';
          phone = null;
        }
      }
      out.add(Slot(
        id: id,
        time: '${_fmt(h)} - ${_fmt(h + 1)}',
        sport: v.sport.label,
        price: evening ? evePrice : dayPrice,
        isEvening: evening,
        status: st,
        player: player,
        phone: phone,
      ));
    }
    return out;
  }

  @override
  Future<bool> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return phone.length == 10;
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return otp.length == 6;
  }

  @override
  Future<List<Venture>> ventures() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _ventures;
  }

  @override
  Future<List<Slot>> slots(String ventureId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _buildSlots(ventureId, date);
  }

  @override
  Future<void> setSlotBlocked(String ventureId, DateTime date, String slotId, bool blocked) async {
    _overrides[_key(ventureId, date, slotId)] = blocked ? SlotStatus.blocked : SlotStatus.open;
  }

  @override
  Future<void> addWalkIn(String ventureId, DateTime date, String slotId, String customerName) async {
    final k = _key(ventureId, date, slotId);
    _overrides[k] = SlotStatus.booked;
    _walkIns[k] = customerName.isEmpty ? 'Walk-in customer' : customerName;
  }

  @override
  Future<int> closeDay(String ventureId, DateTime date) async {
    var count = 0;
    for (final s in _buildSlots(ventureId, date)) {
      if (s.status == SlotStatus.open) {
        _overrides[_key(ventureId, date, s.id)] = SlotStatus.blocked;
        count++;
      }
    }
    return count;
  }

  @override
  Future<OverviewStats> overview(String? ventureId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = ventureId == null ? _ventures : [_byId(ventureId)];
    var bookings = 0, revenue = 0, total = 0, pending = 0;
    final upcoming = <Booking>[];
    final per = <VentureSummary>[];
    for (final v in list) {
      final slots = _buildSlots(v.id, DateTime.now());
      final booked = slots.where((s) => s.status == SlotStatus.booked).toList();
      final rev = booked.fold<int>(0, (a, s) => a + s.price);
      per.add(VentureSummary(v, booked.length, rev, slots.isEmpty ? 0 : booked.length / slots.length));
      bookings += booked.length;
      revenue += rev;
      total += slots.length;
      pending += (18450 * _factor(v.sport)).round();
      for (final s in booked.take(ventureId == null ? 2 : 5)) {
        upcoming.add(Booking(v.name, v.sport, s.player ?? '-', s.time, s.price, !s.isWalkIn));
      }
    }
    return OverviewStats(bookings, revenue, total == 0 ? 0 : bookings / total, pending, upcoming, per);
  }

  @override
  Future<List<Payout>> payouts(String? ventureId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    const base = [
      ['Wed, 22 Oct', 14200, 17],
      ['Wed, 15 Oct', 11800, 14],
      ['Wed, 8 Oct', 16750, 21],
      ['Wed, 1 Oct', 9300, 11],
    ];
    final list = ventureId == null ? _ventures : [_byId(ventureId)];
    final f = list.fold<double>(0, (a, v) => a + _factor(v.sport));
    return [for (final b in base) Payout(b[0] as String, ((b[1] as int) * f).round(), ((b[2] as int) * f).round(), true)];
  }

  @override
  Future<AnalyticsData> analytics(String? ventureId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    const trend = [('Mon', 3200), ('Tue', 2400), ('Wed', 3600), ('Thu', 2800), ('Fri', 5200), ('Sat', 7400), ('Sun', 6800)];
    final list = ventureId == null ? _ventures : [_byId(ventureId)];
    final f = list.fold<double>(0, (a, v) => a + _factor(v.sport));
    final peak = ventureId == null
        ? '7:00 PM - 8:00 PM'
        : switch (_byId(ventureId).sport) {
            SportType.turf => '7:00 PM - 8:00 PM',
            SportType.pickleball => '6:00 PM - 7:00 PM',
            SportType.snooker => '9:00 PM - 10:00 PM',
          };
    return AnalyticsData(
      [for (final t in trend) DayRevenue(t.$1, (t.$2 * f).round())],
      0.34,
      0.71,
      (64 * f).round(),
      58,
      peak,
    );
  }

  @override
  Future<String> buddieReply(String? ventureId, String message) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final m = message.toLowerCase();
    final where = ventureId == null ? 'aapke ventures' : _byId(ventureId).name;
    if (m.contains('light') || m.contains('electric') || m.contains('bulb') || m.contains('flood')) {
      return 'Samajh gayi. $where ka light issue note kar liya. Main domain partner electrician ko connect kar rahi hu, woh TurfBuddie ID card ke saath aayenge. Aane wali slots pe asar na pade isliye pehle unka visit time confirm karti hu.';
    }
    if (m.contains('net') || m.contains('repair') || m.contains('torn') || m.contains('cloth') || m.contains('table')) {
      return 'Maintenance request bana di hai. Nearest vendor se quote mangwa rahi hu, 30 min mein update dungi.';
    }
    if (m.contains('report') || m.contains('summary')) {
      return 'Aaj ka report Home tab pe live hai. Is week ki kamai pichle week se behtar hai, weekend evening slots sabse zyada bik rahe hain. Payout har Wednesday aata hai.';
    }
    if (m.contains('block') || m.contains('band') || m.contains('close')) {
      return 'Slots tab mein date chuno aur "Aaj band karo" dabao ya kisi open slot pe tap karke block karo. Bolo toh main kar deti hu.';
    }
    if (m.contains('offer') || m.contains('market') || m.contains('discount')) {
      return 'Weekday morning slots ki utilisation kam hai. Un pe 15% off ka offer suggest karti hu. Chalu kar du?';
    }
    return 'Theek hai, note kar liya. Slot update, report, maintenance ya marketing, jo chahiye bol do.';
  }
}

// >>> Backend ready hone par ye line badlo <<<
final ManagerRepository repo = MockRepository();
