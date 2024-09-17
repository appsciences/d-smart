// lib/data/event_database.dart
import 'package:hive/hive.dart';
import '../models/event.dart';

class DatabaseService {
  late Box<Event> eventBox;

  Future<void> init() async {
    Hive.registerAdapter(EventAdapter());
    eventBox = await Hive.openBox<Event>('events');
  }

  Future<void> addEvent(Event event) async {
    await eventBox.add(event);
  }

  List<Event> getAllEvents() {
    return eventBox.values.toList();
  }
  Future<void> clearDatabase() async {
    var box = Hive.box<Event>('events');
    await box.clear();
  }
}