import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final user = FirebaseAuth.instance.currentUser;

  final List<Map<String, String>> teamMembers = [
    {"name": "Niraj", "email": "niraj@mototek.in"},
    {"name": "Dhruvish", "email": "dhruvish@mototek.in"},
    {"name": "Krushan", "email": "krushan@mototek.in"},
    {"name": "nishant", "email": "nishant@mototek.in"}
  ];

  Color getUserColor(String? email) {
    switch (email) {
      case "niraj@mototek.in":
        return Colors.blue;
      case "dhruvish@mototek.in":
        return Colors.green;
      case "krushan@mototek.in":
        return Colors.orange;
      case "nishant@mototek.in":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getNameFromEmail(String email) {
    final member = teamMembers.firstWhere((m) => m["email"] == email,
        orElse: () => {"name": email});
    return member["name"]!;
  }

  Future<void> addTask(
      String title, TimeOfDay time, List<String> assignedPeople) async {
    final docRef = await FirebaseFirestore.instance.collection("tasks").add({
      "title": title,
      "date": Timestamp.fromDate(_selectedDay),
      "hour": time.hour,
      "minute": time.minute,
      "completed": false,
      "ownerEmail": user?.email,
      "assignedTo": assignedPeople,
    });

    final scheduledDate = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, time.hour, time.minute);
    await NotificationService.scheduleNotification(
        id: docRef.id.hashCode, title: title, scheduledDate: scheduledDate);
  }

  Future<void> toggleComplete(String id, bool value) async {
    await FirebaseFirestore.instance
        .collection("tasks")
        .doc(id)
        .update({"completed": value});
  }

  Future<void> updateTask(
      String id, String newTitle, DateTime newDate, TimeOfDay newTime) async {
    await FirebaseFirestore.instance.collection("tasks").doc(id).update({
      "title": newTitle,
      "date": Timestamp.fromDate(newDate),
      "hour": newTime.hour,
      "minute": newTime.minute,
    });

    final scheduledDate = DateTime(
        newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);
    await NotificationService.scheduleNotification(
        id: id.hashCode, title: newTitle, scheduledDate: scheduledDate);
  }

  Future<void> deleteTask(String id) async {
    await FirebaseFirestore.instance.collection("tasks").doc(id).delete();
  }

  void showAddDialog() {
    TextEditingController titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<String> selectedPeople = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Task"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Task Name")),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text("Time: ${selectedTime.format(context)}"),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: selectedTime);
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                        child: const Text("Pick"),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Assign To:",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  ...teamMembers.map((member) {
                    bool isSelected = selectedPeople.contains(member["email"]);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(member["name"]!),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            selectedPeople.add(member["email"]!);
                          } else {
                            selectedPeople.remove(member["email"]);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    await addTask(
                        titleController.text, selectedTime, selectedPeople);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              )
            ],
          );
        },
      ),
    );
  }

  void showEditDialog(
      String id, String currentTitle, DateTime currentDate, TimeOfDay currentTime) {
    TextEditingController titleController =
        TextEditingController(text: currentTitle);
    DateTime selectedDate = currentDate;
    TimeOfDay selectedTime = currentTime;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Task"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Task Name")),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                          "Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}"),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: const Text("Pick"),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("Time: ${selectedTime.format(context)}"),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: selectedTime);
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                        child: const Text("Pick"),
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    await updateTask(id, titleController.text, selectedDate,
                        selectedTime);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              )
            ],
          );
        },
      ),
    );
  }

  void showCompletedTasks() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Completed Tasks",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("tasks")
                      .where("completed", isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text("No completed tasks yet"));
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var task = docs[index];
                        Map<String, dynamic> data =
                            task.data() as Map<String, dynamic>;
                        return ListTile(
                          leading:
                              const Icon(Icons.check_circle, color: Colors.green),
                          title: Text(data["title"] ?? "Untitled"),
                          subtitle: Text("By: ${data["ownerEmail"]}"),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            onPressed: showCompletedTasks,
            tooltip: "Completed Tasks",
          )
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("tasks").snapshots(),
            builder: (context, snapshot) {
              List<DateTime> taskDates = [];
              if (snapshot.hasData) {
                taskDates = snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return (data["date"] as Timestamp).toDate();
                }).toList();
              }
              return TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) => setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                }),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    bool hasTask =
                        taskDates.any((taskDate) => isSameDay(taskDate, day));
                    if (hasTask) {
                      return Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.35)),
                        alignment: Alignment.center,
                        child: Text('${day.day}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }
                    return null;
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("tasks").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  DateTime taskDate = (data["date"] as Timestamp).toDate();
                  return isSameDay(taskDate, _selectedDay);
                }).toList();
                if (docs.isEmpty) {
                  return const Center(child: Text("No tasks for this day"));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var task = docs[index];
                    Map<String, dynamic> data =
                        task.data() as Map<String, dynamic>;
                    bool isCompleted = data["completed"] ?? false;
                    bool isOwner = data["ownerEmail"] == user?.email;
                    Color ownerColor = getUserColor(data["ownerEmail"]);
                    int hour = data["hour"] ?? 0;
                    int minute = data["minute"] ?? 0;
                    List<dynamic> assignedTo = data["assignedTo"] ?? [];
                    String assignedNames = assignedTo
                        .map((email) => getNameFromEmail(email.toString()))
                        .join(", ");
                    TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
                    DateTime date = (data["date"] as Timestamp).toDate();

                    return Card(
                      color: ownerColor.withOpacity(0.15),
                      child: ListTile(
                        isThreeLine: true,
                        leading: IconButton(
                          icon: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isOwner ? ownerColor : Colors.grey),
                          onPressed: isOwner
                              ? () => toggleComplete(task.id, !isCompleted)
                              : null,
                        ),
                        title: Text(data["title"] ?? "Untitled",
                            style: TextStyle(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null)),
                        subtitle: Text(
                            "${time.format(context)} • By: ${data["ownerEmail"] ?? "Unknown"}\nAssigned: ${assignedNames.isEmpty ? "No one" : assignedNames}"),
                        trailing: isOwner
                            ? PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == "edit") {
                                    showEditDialog(
                                        task.id, data["title"], date, time);
                                  }
                                  if (value == "delete") {
                                    await deleteTask(task.id);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: "edit", child: Text("Edit")),
                                  PopupMenuItem(
                                      value: "delete", child: Text("Delete"))
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: showAddDialog, child: const Icon(Icons.add)),
    );
  }
}
