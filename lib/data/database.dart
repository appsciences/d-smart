import 'package:hive/hive.dart';
import '../models/session.dart';
import '../models/event.dart';
//part '../models/event.g.dart';
//import '../models/session.g.dart';
//part 'database.g.dart';

class EventAdapter extends TypeAdapter<Event> {
   @override
   final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    return Event(
      timestamp: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.write(obj.timestamp);
  }
}

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 2;

  @override
  Session read(BinaryReader reader) {
    return Session(
      startTimestamp: reader.read() as DateTime,
      endTimestamp: reader.read() as DateTime?,
      sliderValues: (reader.read() as List).cast<int>(),
      trigger: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer.write(obj.startTimestamp);
    writer.write(obj.endTimestamp);
    writer.write(obj.sliderValues);
    writer.write(obj.trigger);
  }
}

class DatabaseService {
  late Box<Event> eventBox;
  late Box<Session> sessionBox;

  Future<void> init() async {
   Hive.registerAdapter(EventAdapter());
   Hive.registerAdapter(SessionAdapter());
    eventBox = await Hive.openBox<Event>('events');
    sessionBox = await Hive.openBox<Session>('sessions');
  }

  Future<void> addEvent(Event event) async {
    await eventBox.add(event);
  }

  Future<void> addSession(Session session) async {
    await sessionBox.add(session);
  }

  List<Event> getAllEvents() {
    return eventBox.values.toList();
  }

  List<Session> getAllSessions() {
    return sessionBox.values.toList();
  }

  Future<void> clearDatabase() async {
    await eventBox.clear();
    await sessionBox.clear();
  }
}