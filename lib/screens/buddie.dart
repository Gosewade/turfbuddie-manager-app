import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';

class BuddieScreen extends StatefulWidget {
  final Venture? venture;
  const BuddieScreen({super.key, required this.venture});
  @override
  State<BuddieScreen> createState() => _BuddieScreenState();
}

class _BuddieScreenState extends State<BuddieScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMsg> _msgs = [
    ChatMsg('Hi, main Riya, aapki AI Buddie. Slot update, report, maintenance ya marketing, jo chahiye bol do.', false),
  ];
  bool _typing = false;

  static const _quick = ['Aaj ka report do', 'Light kharab hai', 'Weekday offer chalao', 'Kal ke slots block karo'];

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(ChatMsg(t, true));
      _typing = true;
    });
    _toBottom();
    final reply = await repo.buddieReply(widget.venture?.id, t);
    if (!mounted) return;
    setState(() {
      _typing = false;
      _msgs.add(ChatMsg(reply, false));
    });
    _toBottom();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.venture;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(v == null ? 'Riya sabhi ventures ke liye kaam karegi' : 'Riya abhi ${v.name} ke liye kaam kar rahi hai', style: const TextStyle(color: TB.muted, fontSize: 12)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            itemCount: _msgs.length + (_typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _msgs.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(padding: EdgeInsets.all(8), child: Text('Riya likh rahi hai...', style: TextStyle(color: TB.muted, fontSize: 13))),
                );
              }
              final m = _msgs[i];
              return Align(
                alignment: m.fromOwner ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  decoration: BoxDecoration(
                    color: m.fromOwner ? TB.green : Colors.white,
                    border: m.fromOwner ? null : Border.all(color: TB.line),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(m.fromOwner ? 16 : 4),
                      bottomRight: Radius.circular(m.fromOwner ? 4 : 16),
                    ),
                  ),
                  child: Text(m.text, style: TextStyle(color: m.fromOwner ? Colors.white : TB.text, fontSize: 15, height: 1.35)),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _quick.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ActionChip(
              label: Text(_quick[i]),
              backgroundColor: Colors.white,
              side: const BorderSide(color: TB.line),
              onPressed: () => _send(_quick[i]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                  decoration: const InputDecoration(hintText: 'Riya ko message karo...'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: TB.green, foregroundColor: Colors.white, minimumSize: const Size(50, 50)),
                onPressed: () => _send(_ctrl.text),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
