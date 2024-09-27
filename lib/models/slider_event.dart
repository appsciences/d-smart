import 'package:hive/hive.dart';

part 'slider_event.g.dart';

@HiveType(typeId: 3)
class SliderEvent extends HiveObject {
  @HiveField(0)
  int sliderIndex;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  bool isIncrement;

  SliderEvent({
    required this.sliderIndex,
    required this.timestamp,
    required this.isIncrement,
  });
}