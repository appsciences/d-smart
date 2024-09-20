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
      //await box.add(Session(
      //  startTimestamp: DateTime.now().subtract(Duration(days: 1)),
      //  endTimestamp: DateTime.now().subtract(Duration(days: 1, hours: 1)),
      //  sliderValues: [20, 40, 60, 80],
      //  trigger: 'Trigger1',
      //));
      //await box.add(Session(
      //  startTimestamp: DateTime.now().subtract(Duration(days: 2)),
      //  endTimestamp: DateTime.now().subtract(Duration(days: 2, hours: 1)),
      //  sliderValues: [10, 30, 50, 70],
      //  trigger: 'Trigger2',
      //));
      //await box.add(Session(
      //  startTimestamp: DateTime.now().subtract(Duration(days: 3)),
      //  endTimestamp: DateTime.now().subtract(Duration(days: 3, hours: 1)),
      //  sliderValues: [15, 25, 35, 45],
      //  trigger: 'Trigger3',
      //));
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
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      var session = sessions[index];
                      return _buildSessionWidget(session);
                    },
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

  Widget _buildSessionWidget(Session session) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start: ${session.startTimestamp}'),
          Text('End: ${session.endTimestamp ?? 'Ongoing'}'),
          Text('Trigger: ${session.trigger ?? 'None'}'),
          SizedBox(height: 8.0),
          Row(
            children: List.generate(session.sliderValues.length, (index) {
              return Expanded(
                child: Container(
                  height: 100.0,
                  color: Colors.blue,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: session.sliderValues[index].toDouble(),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}