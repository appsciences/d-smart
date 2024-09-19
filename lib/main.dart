import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'data/event_database.dart';
import 'home_screen.dart'; // Import the home screen
import 'vertical_sliders.dart'; // Import the vertical sliders

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path); // Initialize Hive with the documents directory
  final databaseService = DatabaseService();
  await databaseService.init();
  runApp(MyApp(databaseService: databaseService));
  print('Hive is storing data at: ${appDocumentDir.path}');
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  MyApp({required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => databaseService,
      child: MaterialApp(
        home: HomeSwitcher(), // Use the HomeSwitcher widget
      ),
    );
  }
}

class HomeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Switcher')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Go to Home Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VerticalSliders()),
                );
              },
              child: Text('Go to Vertical Sliders'),
            ),
          ],
        ),
      ),
    );
  }
}