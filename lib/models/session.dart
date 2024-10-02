import 'package:hive/hive.dart';
import 'slider_event.dart';

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

  @HiveField(4)
  List<SliderEvent> sliderEvents;

  Session({
    required this.startTimestamp,
    this.endTimestamp,
    required this.sliderValues,
    this.trigger,
    required this.sliderEvents,
  });

  void handleSliderChange(int index, bool isIncrement) {
    DateTime now = DateTime.now();
    SliderEvent event = SliderEvent(
      sliderIndex: index,
      timestamp: now,
      isIncrement: isIncrement,
    );

    if (isIncrement) {
      sliderValues[index]++;
      sliderEvents.add(event);
    } else {
      sliderValues[index] = (sliderValues[index] > 0) ? sliderValues[index] - 1 : 0;
      // Remove the latest event for this slider
      for (int i = sliderEvents.length - 1; i >= 0; i--) {
        if (sliderEvents[i].sliderIndex == index && sliderEvents[i].isIncrement) {
          sliderEvents.removeAt(i);
          break;
        }
      }
    }
  }
}