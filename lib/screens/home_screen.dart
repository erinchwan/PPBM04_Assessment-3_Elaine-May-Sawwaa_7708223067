import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextStyle alarmTextStyle = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFFB68D33),
  );

  List<AlarmData> alarms = [];

  // Fungsi untuk mengubah status alarm
  void _toggleAlarmStatus(int index) {
    setState(() {
      alarms[index].isActive = !alarms[index].isActive;
    });
  }

  // Fungsi untuk mengedit alarm
  void _editAlarm(int index) async {
    final editedAlarm = await showDialog<AlarmData>(
      context: context,
      builder: (BuildContext context) {
        return AlarmEditDialog(
          alarm: alarms[index],
          onDelete: () {
            _deleteAlarm(index);
            Navigator.pop(context); // Tutup dialog setelah menghapus
          },
        );
      },
    );

    if (editedAlarm != null) {
      setState(() {
        alarms[index] = editedAlarm;
      });
    }
  }

  // Fungsi untuk menambahkan alarm baru
  void _addNewAlarm() async {
    final newAlarm = await showDialog<AlarmData>(
      context: context,
      builder: (BuildContext context) {
        return AlarmEditDialog();
      },
    );

    if (newAlarm != null) {
      setState(() {
        alarms.add(newAlarm);
      });
    }
  }

  // Fungsi untuk menghapus alarm
  void _deleteAlarm(int index) {
    setState(() {
      alarms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm', style: alarmTextStyle),
        centerTitle: true,
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return AlarmCard(
                    time: alarm.time,
                    description: alarm.description,
                    selectedDays: alarm.selectedDays,
                    isActive: alarm.isActive,
                    onTap: () => _editAlarm(index),
                    onToggle: () => _toggleAlarmStatus(index),
                    onDelete: () => _deleteAlarm(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewAlarm,
        backgroundColor: const Color(0xFFB68D33),
        child: Icon(Icons.add),
      ),
    );
  }
}

class AlarmData {
  String time;
  String description;
  List<bool> selectedDays;
  bool isActive;

  AlarmData({
    required this.time,
    required this.description,
    required this.selectedDays,
    required this.isActive,
  });
}

class AlarmCard extends StatelessWidget {
  final String time;
  final String description;
  final bool isActive;
  final List<bool> selectedDays;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const AlarmCard({
    super.key,
    required this.time,
    required this.description,
    required this.isActive,
    required this.selectedDays,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    String selectedDaysText = days
        .asMap()
        .entries
        .where((entry) => selectedDays[entry.key])
        .map((entry) => entry.value)
        .join(", ");

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Color(0xFFB68D33), width: 2),
        ),
        color: const Color(0xFFF5F2D3),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            time,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB68D33),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Color(0xFFB68D33)),
              ),
              const SizedBox(height: 4),
              Text(
                "Days: $selectedDaysText",
                style: const TextStyle(fontSize: 12, color: Color(0xFFB68D33)),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: isActive,
                activeColor: const Color(0xFFB68D33),
                onChanged: (value) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlarmEditDialog extends StatefulWidget {
  final AlarmData? alarm;
  final VoidCallback? onDelete;

  const AlarmEditDialog({super.key, this.alarm, this.onDelete});

  @override
  _AlarmEditDialogState createState() => _AlarmEditDialogState();
}

class _AlarmEditDialogState extends State<AlarmEditDialog> {
  late TextEditingController _textController;
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.alarm?.description ?? '');
    _selectedTime = widget.alarm != null
        ? TimeOfDay(
            hour: int.parse(widget.alarm!.time.split(':')[0]),
            minute: int.parse(widget.alarm!.time.split(':')[1].split(' ')[0]),
          )
        : const TimeOfDay(hour: 6, minute: 0);
    _selectedDays = widget.alarm?.selectedDays ?? List.filled(7, false);
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return AlertDialog(
      title: Text(widget.alarm != null ? "Edit Alarm" : "Add New Alarm"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration:
                  const InputDecoration(labelText: "Alarm Name/Description"),
            ),
            const SizedBox(height: 20),
            const Text("Select Time:"),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Text(
                _selectedTime.format(context),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB68D33),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Days:"),
            Wrap(
              spacing: 8.0,
              children: List.generate(days.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _selectedDays[index],
                      onChanged: (value) {
                        setState(() {
                          _selectedDays[index] = value ?? false;
                        });
                      },
                    ),
                    Text(days[index]),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.alarm != null)
          TextButton(
            onPressed: widget.onDelete,
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              AlarmData(
                time: _selectedTime.format(context),
                description: _textController.text,
                selectedDays: List.from(_selectedDays),
                isActive: widget.alarm?.isActive ?? true,
              ),
            );
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
