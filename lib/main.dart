import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WaterIntakeApp());
}

class WaterIntakeApp extends StatelessWidget {
  const WaterIntakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Intake app',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WaterIntakeHomepage(),
    );
  }
}

class WaterIntakeHomepage extends StatefulWidget {
  const WaterIntakeHomepage({super.key});

  @override
  State<WaterIntakeHomepage> createState() => _WaterIntakeHomepageState();
}

class _WaterIntakeHomepageState extends State<WaterIntakeHomepage> {
  int _waterIntake = 0;
  int _dailyGoal = 8;
  final List<int> _dailyGoalOptions = [8, 10, 12];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = (pref.getInt('WaterIntake') ?? 0);
      _dailyGoal = (pref.getInt('dailyGoal') ?? 8);
    });
  }

  Future<void> _incrementWaterIntake() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake++;
    });
    pref.setInt('waterIntake', _waterIntake);
    if (_waterIntake >= _dailyGoal) {
      // show a dialogue box
      _showGoalReachedDialogue();
    }
  }

  Future<void> _resetWaterIntake() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = 0;
      pref.setInt('waterIntake', _waterIntake);
    });
  }

  Future<void> _setDailyGoal(int newGoal) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = newGoal;
      pref.setInt('dailyGoal', newGoal);
    });
  }

  Future<void> _showGoalReachedDialogue() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Congratulations!"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                      'You have reached your daily goal od $_dailyGoal glasses od water'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  Future<void> _showResetConformationDialogue() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Reset Water Intake"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Are you sure to reset your water intake ??'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    _resetWaterIntake();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _waterIntake / _dailyGoal;
    bool goalReached = _waterIntake >= _dailyGoal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(
                Icons.water_drop,
                size: 120,
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'You have consumed: ',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '$_waterIntake glass(es) of water',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10,
              ),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                minHeight: 20,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Daily Goal',
                style: TextStyle(fontSize: 18),
              ),
              DropdownButton(
                  value: _dailyGoal,
                  items: _dailyGoalOptions.map((int value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text('$value Glasses'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      _setDailyGoal(newValue);
                    }
                  }),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: goalReached ? null : _incrementWaterIntake,
                  child: const Text(
                    'Add a glass of water',
                    style: TextStyle(fontSize: 18),
                  )),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: _showResetConformationDialogue,
                  child: const Text('Reset', style: TextStyle(fontSize: 18)))
            ],
          ),
        ),
      ),
    );
  }
}
