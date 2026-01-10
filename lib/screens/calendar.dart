// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; 
import 'package:fblaaspire/components/event.dart';
import 'package:fblaaspire/services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay _selectedTime = TimeOfDay.now();

  final TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<Event>> _selectedEvents;
  Map<DateTime, List<Event>> _eventsCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _checkAndImportDefault();
  }

  @override
  void dispose() {
    _eventController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  // --- Helper Methods ---

  String _dateKey(DateTime date) => 
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  List<Event> _getEventsForDay(DateTime day) => _eventsCache[_normalizeDate(day)] ?? [];

  void _updateSelectedEventsList(DateTime day) {
    _selectedEvents.value = _eventsCache[_normalizeDate(day)] ?? [];
  }

  // --- Logic Methods ---

  Future<void> _checkAndImportDefault() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data()?['hasImportedDefault'] != true) {
        await _importDefaultICS();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'hasImportedDefault': true}, 
          SetOptions(merge: true)
        );
      } else {
        await _loadAllEvents();
      }
    } catch (e) {
      debugPrint("Setup Error: $e");
      _loadAllEvents();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importDefaultICS() async {
    try {
      final content = await rootBundle.loadString('assets/calendar/default_calendar.ics');
      final iCal = ICalendar.fromString(content);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final batch = FirebaseFirestore.instance.batch();

      for (final event in iCal.data) {
        if (event['type'] != 'VEVENT') continue;
        final summary = event['summary']?.toString() ?? "FBLA Event";
        final dtStartValue = event['dtstart'];
        DateTime? startDate;
        
        if (dtStartValue is IcsDateTime) {
          startDate = dtStartValue.toDateTime();
        } else if (dtStartValue != null) {
          String dtStr = dtStartValue.toString();
          if (dtStr.length == 8) {
            startDate = DateTime(
              int.parse(dtStr.substring(0, 4)),
              int.parse(dtStr.substring(4, 6)),
              int.parse(dtStr.substring(6, 8)),
            );
          } else {
            startDate = IcsDateTime(dt: dtStr).toDateTime();
          }
        }

        if (startDate != null) {
          final timeString = DateFormat.jm().format(startDate);
          
          if (startDate.isAfter(DateTime.now())) {
            await NotificationService.scheduleNotification(
              id: summary.hashCode + startDate.millisecond,
              title: "FBLA Event Reminder",
              body: "$summary starts soon",
              scheduledDate: startDate,
            );
          }

          final docRef = FirebaseFirestore.instance
              .collection('users').doc(user.uid)
              .collection('events').doc(_dateKey(startDate));

          batch.set(docRef, {
            'items': FieldValue.arrayUnion([
              {'title': summary, 'time': timeString}
            ]),
          }, SetOptions(merge: true));
        }
      }
      await batch.commit();
      await _loadAllEvents();
    } catch (e) {
      debugPrint("Default Import Error: $e");
    }
  }

  Future<void> _loadAllEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('events').get();

    Map<DateTime, List<Event>> newCache = {};
    for (var doc in snapshot.docs) {
      DateTime? date = DateTime.tryParse(doc.id);
      if (date != null) {
        final List<dynamic> items = doc.data()['items'] ?? [];
        newCache[_normalizeDate(date)] = items.map((data) {
          if (data is Map) {
            return Event(data['title']?.toString() ?? "No Title", time: data['time']?.toString());
          }
          return Event(data.toString());
        }).toList();
      }
    }

    if (mounted) {
      setState(() => _eventsCache = newCache);
      _updateSelectedEventsList(_selectedDay!);
    }
  }

  Future<void> _addEvent() async {
    if (_eventController.text.isEmpty || _selectedDay == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final timeString = _selectedTime.format(context);
    final scheduledDateTime = DateTime(
      _selectedDay!.year, _selectedDay!.month, _selectedDay!.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    await NotificationService.scheduleNotification(
      id: _eventController.text.hashCode + scheduledDateTime.millisecond,
      title: "Event Reminder",
      body: "${_eventController.text} starts now",
      scheduledDate: scheduledDateTime,
    );

    await FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('events').doc(_dateKey(_selectedDay!))
        .set({
      'items': FieldValue.arrayUnion([
        {'title': _eventController.text, 'time': timeString}
      ]),
    }, SetOptions(merge: true));

    _eventController.clear();
    if (mounted) Navigator.pop(context);
    _loadAllEvents();
  }

  Future<void> _updateEvent(Event oldEvent) async {
    if (_eventController.text.isEmpty || _selectedDay == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Cancel old notification
    await NotificationService.cancelNotification(oldEvent.title.hashCode);

    // 2. Remove old event from Firestore
    final oldEventMap = {'title': oldEvent.title, 'time': oldEvent.time};
    final docRef = FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('events').doc(_dateKey(_selectedDay!));

    await docRef.update({
      'items': FieldValue.arrayRemove([oldEventMap]),
    });

    // 3. Add new event data
    final timeString = _selectedTime.format(context);
    await docRef.set({
      'items': FieldValue.arrayUnion([
        {'title': _eventController.text, 'time': timeString}
      ]),
    }, SetOptions(merge: true));

    // 4. Schedule new notification
    final scheduledDateTime = DateTime(
      _selectedDay!.year, _selectedDay!.month, _selectedDay!.day,
      _selectedTime.hour, _selectedTime.minute,
    );
    await NotificationService.scheduleNotification(
      id: _eventController.text.hashCode + scheduledDateTime.millisecond,
      title: "Updated Event Reminder",
      body: "${_eventController.text} starts now",
      scheduledDate: scheduledDateTime,
    );

    _eventController.clear();
    if (mounted) Navigator.pop(context);
    _loadAllEvents();
  }

  Future<void> _deleteEvent(Event event) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedDay == null) return;

    await NotificationService.cancelNotification(event.title.hashCode);

    final eventMap = {'title': event.title, 'time': event.time};
    await FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('events').doc(_dateKey(_selectedDay!))
        .update({
      'items': FieldValue.arrayRemove([eventMap]),
    });

    _loadAllEvents();
  }

  Future<void> _importICS() async {
    final XFile? file = await openFile(
        acceptedTypeGroups: [XTypeGroup(label: 'ICS', extensions: ['ics'])]);
    if (file == null) return;

    try {
      final content = await File(file.path).readAsString();
      final iCal = ICalendar.fromString(content);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final batch = FirebaseFirestore.instance.batch();

      for (final event in iCal.data) {
        if (event['type'] != 'VEVENT') continue;
        final summary = event['summary']?.toString() ?? "No Title";
        final dtStartValue = event['dtstart'];
        DateTime? startDate;
        
        if (dtStartValue is IcsDateTime) {
          startDate = dtStartValue.toDateTime();
        } else if (dtStartValue != null) {
          startDate = IcsDateTime(dt: dtStartValue.toString()).toDateTime();
        }

        if (startDate != null) {
          final timeString = DateFormat.jm().format(startDate);
          final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('events').doc(_dateKey(startDate));
          batch.set(docRef, {'items': FieldValue.arrayUnion([{'title': summary, 'time': timeString}])}, SetOptions(merge: true));
        }
      }
      await batch.commit();
      _loadAllEvents();
    } catch (e) {
      debugPrint("Import Error: $e");
    }
  }

  void _showDeleteConfirmation(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event", style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold)),
        content: Text("Delete '${event.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEventSheet({Event? eventToEdit}) {
    if (eventToEdit != null) {
      _eventController.text = eventToEdit.title;
      // Note: If you want to parse the eventToEdit.time back to TimeOfDay, 
      // you would need a helper function. Defaulting to current time for now.
    } else {
      _eventController.clear();
      _selectedTime = TimeOfDay.now();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eventToEdit == null ? "Add New Event" : "Edit Event",
                style: GoogleFonts.comfortaa(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _eventController,
                decoration: const InputDecoration(labelText: 'Event Name', border: OutlineInputBorder()),
              ),
              ListTile(
                title: Text("Time: ${_selectedTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _selectedTime);
                  if (time != null) setModalState(() => _selectedTime = time);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => eventToEdit == null ? _addEvent() : _updateEvent(eventToEdit), 
                  child: Text(eventToEdit == null ? "Add Event" : "Save Changes")
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(heroTag: "import", mini: true, onPressed: _importICS, foregroundColor: Colors.white, backgroundColor: const Color(0xFF1442A6), child: const Icon(Icons.upload_file)),
          const SizedBox(height: 12),
          FloatingActionButton(heroTag: "add", onPressed: () => _showEventSheet(), foregroundColor: Colors.white, backgroundColor:  Color(0xFF1442A6), child: const Icon(Icons.add)),
        ],
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Calendar', style: GoogleFonts.comfortaa(fontSize: 30, fontWeight: FontWeight.w700)),
              ),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _updateSelectedEventsList(selectedDay);
              },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              ),
            ),
            const Divider(),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (_, events, __) {
                  if (events.isEmpty) return const Center(child: Text("No events scheduled"));
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (_, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(event.title, style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold)),
                          subtitle: event.time != null ? Text(event.time!) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEventSheet(eventToEdit: event),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmation(event),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}