import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/session.dart';
import 'models/drink.dart';

class DrinkDisplay extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;

  DrinkDisplay({required this.startTime, required this.endTime});

  @override
  _DrinkDisplayState createState() => _DrinkDisplayState();
}

class _DrinkDisplayState extends State<DrinkDisplay> {
  List<Session> _sessions = [];
  List<Drink> _drinks = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    var box = await Hive.openBox<Session>('sessions');
    var sessions = box.values.toList();
    setState(() {
      _sessions = sessions;
      _extractDrinks();
    });
  }

  void _extractDrinks() {
    final drinks = <Drink>[];
    for (var session in _sessions) {
      if (session.startTimestamp.isAfter(widget.startTime) && session.startTimestamp.isBefore(widget.endTime)) {
        for (var event in session.sliderEvents) {
          if (event.isIncrement) {
            drinks.add(Drink(
              name: 'Drink ${event.sliderIndex}',
              timestamp: event.timestamp,
              isAlcoholic: true, // Assuming all increments are alcoholic drinks
            ));
          }
        }
      }
    }
    drinks.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    setState(() {
      _drinks = drinks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 200),
      painter: DrinkPainter(drinks: _drinks, startTime: widget.startTime, endTime: widget.endTime),
    );
  }
}

class DrinkPainter extends CustomPainter {
  final List<Drink> drinks;
  final DateTime startTime;
  final DateTime endTime;

  DrinkPainter({required this.drinks, required this.startTime, required this.endTime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    int currentLevel = 0;
    double lastX = 0;

    for (var drink in drinks) {
      if (drink.isAlcoholic) {
        currentLevel++;
      }

      final x = (drink.timestamp.difference(startTime).inMinutes / endTime.difference(startTime).inMinutes) * size.width;
      final y = size.height - (currentLevel * 20);

      textPainter.text = TextSpan(
        text: drink.name,
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 20));

      if (drink.isAlcoholic) {
        canvas.drawLine(Offset(lastX, y), Offset(x, y), paint);
        canvas.drawLine(Offset(x, y), Offset(x, y - 20), paint);
        lastX = x;
      }
    }

    if (currentLevel > 0) {
      canvas.drawLine(Offset(lastX, size.height - (currentLevel * 20)), Offset(size.width, size.height - (currentLevel * 20)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}