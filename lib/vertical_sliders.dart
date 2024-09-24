import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'models/session.dart';

class VerticalSliders extends StatefulWidget {
  @override
  _VerticalSlidersState createState() => _VerticalSlidersState();
}

class _VerticalSlidersState extends State<VerticalSliders> {
  List<int> sliderValues = [0, 0, 0, 0];
  final List<String> labels = ['Beer', 'Wine', 'Liquor', 'Food'];
  final List<Color> ballColors = [Colors.brown[300]!, Colors.yellow[200]!, Colors.pink[200]!, Colors.purple[200]!];
  final List<int> multipliers = [1, 2, 3, 0];
  String selectedTrigger = 'Trigger1';
  Session? currentSession;
  bool _isSessionStarted = false;
  bool _canEndSession = false;
  DateTime? _sessionStartTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  List<double> actionSliderValues = [0.0, 0.0, 0.0, 0.0];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionStarted = true;
      _sessionStartTime = DateTime.now();
      _canEndSession = false;
      _elapsedTime = Duration.zero;
      currentSession = Session(
        startTimestamp: _sessionStartTime!,
        sliderValues: List.from(sliderValues),
        trigger: selectedTrigger,
      );
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_sessionStartTime!);
      });
    });

    // Enable the "End Session" button after a sufficient amount of time has passed
    Future.delayed(Duration(minutes: 5), () {
      setState(() {
        _canEndSession = true;
      });
    });
  }

  void _endSession() async {
    if (currentSession != null) {
      currentSession!.endTimestamp = DateTime.now();
      currentSession!.sliderValues = List.from(sliderValues);
      currentSession!.trigger = selectedTrigger;

      var box = await Hive.openBox<Session>('sessions');
      await box.add(currentSession!);

      setState(() {
        currentSession = null;
        _isSessionStarted = false;
        _canEndSession = false;
        _timer?.cancel();
        _elapsedTime = Duration.zero;
      });
    }
  }

  int _calculateSum() {
    int sum = 0;
    for (int i = 0; i < sliderValues.length; i++) {
      sum += sliderValues[i] * multipliers[i];
    }
    return sum;
  }

  Color _getSliderColor(int index) {
    if (index == 3) {
      // Food slider should always be white
      return Colors.white;
    }

    int sum = _calculateSum();
    int potentialSum = sum + multipliers[index];

    if (sum >= 20) {
      return Colors.redAccent;
    } else if (potentialSum >= 20) {
      return Colors.redAccent;
    } else if (sum >= 10) {
      return Colors.orange;
    } else if (potentialSum >= 10) {
      return Colors.orange;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Triggers: '),
            DropdownButton<String>(
              value: selectedTrigger,
              dropdownColor: Colors.white,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTrigger = newValue!;
                });
              },
              items: <String>['Trigger1', 'Trigger2', 'Trigger3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: _isSessionStarted ? null : _startSession,
              child: Text('Start Session'),
            ),
            SizedBox(width: 8.0),
            Text(
              _formatElapsedTime(_elapsedTime),
              style: TextStyle(
                color: _elapsedTime < Duration(minutes: 5) ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: _canEndSession ? _endSession : null,
              child: Text('End Session'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          color: Colors.black, // Black region
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return _buildActionSlider(index);
            }),
          ),
        ),
      ),
    );
  }

  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildActionSlider(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          labels[index],
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        RotatedBox(
          quarterTurns: -1,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getSliderColor(index), // Controls the color during sliding
              inactiveTrackColor: _getSliderColor(index), // Controls the dormant color
              thumbColor: ballColors[index],
              overlayColor: ballColors[index].withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
            ),
            child: Slider(
              value: actionSliderValues[index],
              min: -1,
              max: 1,
              divisions: 2,
              label: actionSliderValues[index] == 0 ? 'Neutral' : (actionSliderValues[index] > 0 ? 'Increment' : 'Decrement'),
              onChanged: (double value) {
                setState(() {
                  actionSliderValues[index] = value;
                });
              },
              onChangeEnd: (double value) {
                setState(() {
                  if (value == 1) {
                    sliderValues[index]++;
                    if (currentSession != null) {
                      currentSession!.sliderValues[index]++;
                    }
                  } else if (value == -1) {
                    sliderValues[index] = (sliderValues[index] > 0) ? sliderValues[index] - 1 : 0;
                    if (currentSession != null) {
                      currentSession!.sliderValues[index] = (currentSession!.sliderValues[index] > 0) ? currentSession!.sliderValues[index] - 1 : 0;
                    }
                  }
                  // Snap back to the middle position
                  actionSliderValues[index] = 0;
                });
              },
            ),
          ),
        ),
        Text(
          '${labels[index]}: ${sliderValues[index]}',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}