import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 2)
class Session extends HiveObject {
  @HiveField(0)
  DateTime startTimestamp;

  @HiveField(1)
  DateTime? endTimestamp;

  @HiveField(2)
  List<int> sliderValues;

  @HiveField(3)
  String? trigger;

  Session({
    required this.startTimestamp,
    this.endTimestamp,
    required this.sliderValues,
    this.trigger,
  });
}