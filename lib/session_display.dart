import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/session.dart';

class SessionDisplay extends StatefulWidget {
  @override
  _SessionDisplayState createState() => _SessionDisplayState();
}

class _SessionDisplayState extends State<SessionDisplay> {
  final ScrollController _horizontalScrollController = ScrollController();
  Map<String, List<Session>> sessionsByDateHour = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_horizontalScrollController.hasClients) {
        _horizontalScrollController.jumpTo(_horizontalScrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sessions')),
      body: FutureBuilder(
        future: Hive.openBox<Session>('sessions'),
        builder: (context, AsyncSnapshot<Box<Session>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              var box = snapshot.data!;
              return StreamBuilder(
                stream: box.watch(),
                builder: (context, snapshot) {
                  var sessions = box.values.toList();
                  sessions.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
                  _groupSessionsByDateHour(sessions);
                  return SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Row(
                          children: _buildTimeAxis(),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _groupSessionsByDateHour(List<Session> sessions) {
    sessionsByDateHour.clear();
    for (var session in sessions) {
      DateTime startDate = session.startTimestamp;
      DateTime endDate = session.endTimestamp ?? startDate;
      int startHour = startDate.hour;
      int endHour = endDate.hour;

      for (int hour = startHour; hour <= endHour; hour++) {
        String key = '${startDate.year}-${startDate.month}-${startDate.day}-$hour';
        if (!sessionsByDateHour.containsKey(key)) {
          sessionsByDateHour[key] = [];
        }
        sessionsByDateHour[key]!.add(session);
      }
    }
  }

  List<Widget> _buildTimeAxis() {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(hours: 72));
    final duration = now.difference(startTime).inHours;

    return List.generate(duration + 1, (index) {
      final time = startTime.add(Duration(hours: index));
      final dateHourKey = '${time.year}-${time.month}-${time.day}-${time.hour}';
      final hasSession = sessionsByDateHour.containsKey(dateHourKey);

      return GestureDetector(
        onTap: hasSession ? () => _showSessionsForDateHour(dateHourKey) : null,
        child: Container(
          width: 120.0, // 60 minutes * 2 pixels per minute
          child: Center(
            child: Text(
              '${time.month}/${time.day} ${time.hour}:00',
              style: TextStyle(
                color: hasSession ? Colors.red : Colors.black,
                fontWeight: hasSession ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showSessionsForDateHour(String dateHourKey) {
    final sessions = sessionsByDateHour[dateHourKey]!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sessions for ${dateHourKey.split('-').sublist(0, 3).join('-')} ${dateHourKey.split('-').last}:00'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sessions.map((session) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trigger: ${session.trigger ?? 'N/A'}'),
                  Text('Start Time: ${session.startTimestamp}'),
                  Text('End Time: ${session.endTimestamp ?? 'N/A'}'),
                  Text('Slider Values:'),
                  ...session.sliderValues.asMap().entries.map((entry) {
                    int index = entry.key;
                    int value = entry.value;
                    return Text('${_getNameForIndex(index)}: $value');
                  }).toList(),
                  Divider(),
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _getNameForIndex(int index) {
    switch (index) {
      case 0:
        return 'Beer';
      case 1:
        return 'Wine';
      case 2:
        return 'Liquor';
      case 3:
        return 'Food';
      default:
        return 'Unknown';
    }
  }
}