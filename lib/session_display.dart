import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/session.dart';

class SessionDisplay extends StatefulWidget {
  @override
  _SessionDisplayState createState() => _SessionDisplayState();
}

class _SessionDisplayState extends State<SessionDisplay> {
  @override
  void initState() {
    super.initState();
    _addFakeSessions();
  }

  Future<void> _addFakeSessions() async {
    var box = await Hive.openBox<Session>('sessions');
    if (box.isEmpty) {
      // Add some fake sessions
      await box.add(Session(
        startTimestamp: DateTime.now().subtract(Duration(days: 1)),
        endTimestamp: DateTime.now().subtract(Duration(days: 1, hours: 1)),
        sliderValues: [20, 40, 60, 80],
        trigger: 'Trigger1',
      ));
      await box.add(Session(
        startTimestamp: DateTime.now().subtract(Duration(days: 2)),
        endTimestamp: DateTime.now().subtract(Duration(days: 2, hours: 1)),
        sliderValues: [10, 30, 50, 70],
        trigger: 'Trigger2',
      ));
      await box.add(Session(
        startTimestamp: DateTime.now().subtract(Duration(days: 3)),
        endTimestamp: DateTime.now().subtract(Duration(days: 3, hours: 1)),
        sliderValues: [15, 25, 35, 45],
        trigger: 'Trigger3',
      ));
    }
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
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sessions.map((session) => _buildSessionWidget(session, sessions.first.startTimestamp)).toList(),
                        ),
                        _buildTimeAxis(sessions),
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

  Widget _buildSessionWidget(Session session, DateTime earliestStartTime) {
    final totalValue = session.sliderValues.reduce((a, b) => a + b);
    final sessionDuration = session.endTimestamp?.difference(session.startTimestamp).inMinutes ?? 60;
    final height = totalValue.toDouble();
    final width = sessionDuration > 0 ? sessionDuration.toDouble() * 2 : 1.0; // Scale width for visibility
    final minWidth = 20.0; // Set a minimum width for visibility
    final maxHeight = 200.0; // Set a maximum height for visibility

    final offset = session.startTimestamp.difference(earliestStartTime).inMinutes * 2; // Calculate offset based on start time

    return GestureDetector(
      onTap: () => _showSessionDetails(session),
      child: Container(
        margin: EdgeInsets.only(left: offset.toDouble(), top: 8.0, bottom: 8.0),
        child: Column(
          children: [
            if (session.trigger != null)
              Text(session.trigger!, style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: width < minWidth ? minWidth : width, // Apply minimum width
              height: height > maxHeight ? maxHeight : height, // Apply maximum height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(session.sliderValues.length, (index) {
                  final value = session.sliderValues[index];
                  final color = _getColorForIndex(index);
                  final proportion = value / totalValue;
                  return Expanded(
                    flex: (proportion * 100).toInt(),
                    child: Container(
                      color: color,
                      child: Center(
                        child: Text(
                          '${_getNameForIndex(index)}: $value',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetails(Session session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Session Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
            ],
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

  Widget _buildTimeAxis(List<Session> sessions) {
    final startTime = sessions.first.startTimestamp;
    final endTime = DateTime.now(); // Ensure the time axis includes the current time
    final duration = endTime.difference(startTime).inMinutes;

    return Container(
      margin: EdgeInsets.only(top: 16.0),
      height: 50.0,
      child: Row(
        children: List.generate(duration ~/ 60 + 1, (index) {
          final time = startTime.add(Duration(hours: index));
          return Container(
            width: 120.0, // 60 minutes * 2 pixels per minute
            child: Center(
              child: Text('${time.month}/${time.day} ${time.hour}:00'),
            ),
          );
        }),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
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