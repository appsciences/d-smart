import 'package:flutter/material.dart';

class VerticalSliders extends StatefulWidget {
  @override
  _VerticalSlidersState createState() => _VerticalSlidersState();
}

class _VerticalSlidersState extends State<VerticalSliders> {
  List<int> sliderValues = [0, 0, 0, 0];
  final List<String> labels = ['Beer', 'Wine', 'Liquor', 'Food'];
  String selectedTrigger = 'Trigger1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
              onPressed: () {
                // Start session logic
              },
              child: Text('Start Session'),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () {
                // End session logic
              },
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
              return _buildVerticalSlider(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSlider(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          labels[index],
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            setState(() {
              sliderValues[index] = (sliderValues[index] + 1).clamp(0, 100);
            });
          },
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.0),
              bottom: Radius.circular(16.0),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: RotatedBox(
            quarterTurns: -1,
            child: Slider(
              value: sliderValues[index].toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: sliderValues[index].toString(),
              onChanged: (double newValue) {
                setState(() {
                  sliderValues[index] = newValue.toInt();
                });
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.remove, color: Colors.white),
          onPressed: () {
            setState(() {
              sliderValues[index] = (sliderValues[index] - 1).clamp(0, 100);
            });
          },
        ),
        Text(
          sliderValues[index].toString(),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}