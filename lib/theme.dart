import 'package:flutter/material.dart';

/// Simple light theme taken from the TurfBuddie logo (green + black).
class TB {
  static const bg = Color(0xFFF5FAF6);
  static const surface = Colors.white;
  static const tint = Color(0xFFE8F6EC); // light green fill
  static const line = Color(0xFFE1EAE3);
  static const green = Color(0xFF1FA64F);
  static const greenDark = Color(0xFF137A39);
  static const text = Color(0xFF14201A);
  static const muted = Color(0xFF66786D);
  static const amber = Color(0xFFD98A00);
  static const red = Color(0xFFD93636);

  static ThemeData theme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: green,
        onPrimary: Colors.white,
        secondary: greenDark,
        surface: surface,
        onSurface: text,
        error: red,
      ),
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: tint,
        height: 68,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: green, width: 1.6)),
        hintStyle: const TextStyle(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}

String rupees(num v) {
  final s = v.round().toString();
  if (s.length <= 3) return '₹$s';
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '₹${parts.join(',')},$last3';
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? TB.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TB.line),
        ),
        child: child,
      );
}

class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  const BigButton({super.key, required this.label, required this.onPressed, this.busy = false});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          onPressed: busy ? null : onPressed,
          child: busy
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(label),
        ),
      );
}

/// Loads data once and shows a spinner meanwhile.
class Load<T> extends StatefulWidget {
  final Future<T> Function() fetch;
  final Widget Function(BuildContext, T) builder;
  const Load({super.key, required this.fetch, required this.builder});
  @override
  State<Load<T>> createState() => _LoadState<T>();
}

class _LoadState<T> extends State<Load<T>> {
  late Future<T> _f;
  @override
  void initState() {
    super.initState();
    _f = widget.fetch();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
        future: _f,
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Data load nahi ho paya. Dobara try karo.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: TB.green));
          return widget.builder(context, snap.data as T);
        },
      );
}
