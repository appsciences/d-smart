import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data/database.dart';
import 'models/event.dart';
import 'signup_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> events = [];
  List<FlSpot> annotations = [];
  List<TextAnnotation> textAnnotations = [];

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Simple App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRecordButton(databaseService),
            _buildClearDatabaseButton(databaseService),
            _buildGraph(),
            _buildSignupButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton(DatabaseService databaseService) {
    return ElevatedButton(
      onPressed: () async {
        await databaseService.addEvent(Event(timestamp: DateTime.now()));
        setState(() {
          events = [...events, Event(timestamp: DateTime.now())];
        });
      },
      child: Text('Record Button Push'),
    );
  }

  Widget _buildClearDatabaseButton(DatabaseService databaseService) {
    return ElevatedButton(
      onPressed: () async {
        await databaseService.clearDatabase();
        setState(() {
          events = [];
          annotations = [];
          textAnnotations = [];
        });
      },
      child: Text('Clear Database'),
    );
  }

  Widget _buildGraph() {
    return Expanded(
      child: Container(
        color: Colors.yellow.withOpacity(0.3), // Visual debugging
        child: Stack(
          children: [
            BarChart(
              _buildBarChartData(),
              swapAnimationDuration: Duration(milliseconds: 150), // Optional
              swapAnimationCurve: Curves.linear, // Optional
            ),
            ...textAnnotations.map((annotation) => Positioned(
              left: annotation.position.dx,
              top: annotation.position.dy,
              child: Text(
                annotation.text,
                style: TextStyle(
                  color: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignupScreen()),
        );
      },
      child: Text('Go to Signup'),
    );
  }

  BarChartData _buildBarChartData() {
    return BarChartData(
      barGroups: _generateBarGroups(),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
      ),
      borderData: FlBorderData(show: true),
      gridData: FlGridData(show: true),
      barTouchData: BarTouchData(
        touchCallback: (FlTouchEvent event, barTouchResponse) async {
          if (event is FlTapUpEvent) {
            final position = event.localPosition;
            print('Graph tapped at: $position'); // Debugging line
            final annotation = await _showAnnotationDialog(context);
            if (annotation != null) {
              setState(() {
                textAnnotations.add(TextAnnotation(
                  position: position,
                  text: annotation,
                ));
                print('Annotation added: $position, $annotation'); // Debugging line
                print('Current annotations: $textAnnotations'); // Debugging line
              });
            }
          }
        },
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    Map<int, int> eventCounts = {};
    for (var event in events) {
      int minute = event.timestamp.minute;
      eventCounts[minute] = (eventCounts[minute] ?? 0) + 1;
    }

    List<BarChartGroupData> barGroups = [];
    for (int minute = 0; minute < 60; minute++) {
      barGroups.add(
        BarChartGroupData(
          x: minute,
          barRods: [
            BarChartRodData(
              toY: eventCounts[minute]?.toDouble() ?? 0,
              color: Colors.blue,
            ),
          ],
        ),
      );
    }

    print('Bar Groups: $barGroups'); // Debugging line

    return barGroups;
  }

  Future<String?> _showAnnotationDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Annotation'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter annotation'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }
}

class TextAnnotation {
  final Offset position;
  final String text;

  TextAnnotation({required this.position, required this.text});
}