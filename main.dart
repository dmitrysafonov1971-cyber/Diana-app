import 'package:flutter/material.dart';

void main() {
  runApp(const DianaApp());
}

class DianaApp extends StatelessWidget {
  const DianaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Диана',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Привет, Равви!\nЯ что-то тебе напоминаю?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 14),
                  child: Text('Начать', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_Reminder> _reminders = [];

  void _addManual() async {
    final result = await showDialog<_ManualResult>(
      context: context,
      builder: (_) => const _ManualDialog(),
    );
    if (result == null) return;
    setState(() => _reminders.add(_Reminder(text: result.text, time: result.time)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.pets),
        title: const Text('Диана — твои напоминания'),
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: Text(
                'Пока пусто. Нажми 🎙 чтобы добавить голосом\nили "+" чтобы добавить вручную.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final r = _reminders[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.alarm),
                    title: Text(r.text),
                    subtitle: Text(_fmt(r.time)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _reminders.removeAt(i)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manual',
            onPressed: _addManual,
            label: const Text('Добавить'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'mic',
            onPressed: () {
              // Заготовка: здесь позже подключим распознавание речи
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Голосовой ввод появится на следующем шаге.')),
              );
            },
            child: const Icon(Icons.mic_none),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.day}.${t.month}.${t.year} $hh:$mm';
  }
}

class _Reminder {
  final String text;
  final DateTime time;
  _Reminder({required this.text, required this.time});
}

class _ManualDialog extends StatefulWidget {
  const _ManualDialog();

  @override
  State<_ManualDialog> createState() => _ManualDialogState();
}

class _ManualDialogState extends State<_ManualDialog> {
  final _textCtrl = TextEditingController();
  DateTime _when = DateTime.now().add(const Duration(minutes: 5));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новое напоминание'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textCtrl,
            decoration: const InputDecoration(
              labelText: 'Текст',
              hintText: 'Например: Покормить Эби',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Когда'),
            subtitle: Text(_fmt(_when)),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                initialDate: _when,
              );
              if (d == null) return;
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_when),
              );
              if (t == null) return;
              setState(() {
                _when = DateTime(d.year, d.month, d.day, t.hour, t.minute);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: () {
            if (_textCtrl.text.trim().isEmpty) return;
            Navigator.pop(context, _ManualResult(text: _textCtrl.text.trim(), time: _when));
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  String _fmt(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.day}.${t.month}.${t.year} $hh:$mm';
  }
}

class _ManualResult {
  final String text;
  final DateTime time;
  _ManualResult({required this.text, required this.time});
}