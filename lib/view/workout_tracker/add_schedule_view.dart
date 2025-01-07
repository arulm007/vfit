import 'package:fitness/view/sleep_tracker/sleep_add_alarm_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  TimeOfDay selectedTime = TimeOfDay.now();
  String workout = "Upperbody";
  String difficulty = "Beginner";
  int repetitions = 10;
  double weight = 5.0;

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.primaryColor1,
              onPrimary: TColor.white,
              onSurface: TColor.black,
            ),
            dialogBackgroundColor: TColor.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> selectWorkout(BuildContext context) async {
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Choose Workout",
            style: TextStyle(
                color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "Upperbody");
              },
              child: Text("Upperbody",
                  style: TextStyle(color: TColor.black, fontSize: 14)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "Lowerbody");
              },
              child: Text("Lowerbody",
                  style: TextStyle(color: TColor.black, fontSize: 14)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "Cardio");
              },
              child: Text("Cardio",
                  style: TextStyle(color: TColor.black, fontSize: 14)),
            ),
          ],
        );
      },
    );
    if (picked != null && picked != workout) {
      setState(() {
        workout = picked;
      });
    }
  }

  Future<void> selectDifficulty(BuildContext context) async {
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Choose Difficulty",
            style: TextStyle(
                color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "Beginner");
              },
              child: Text("Beginner",
                  style: TextStyle(color: TColor.black, fontSize: 14)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "Intermediate");
              },
              child: Text("Intermediate",
                  style: TextStyle(color: TColor.black, fontSize: 14)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "Advanced");
              },
              child: Text("Advanced",
                  style: TextStyle(color: TColor.black, fontSize: 14)),
            ),
          ],
        );
      },
    );
    if (picked != null && picked != difficulty) {
      setState(() {
        difficulty = picked;
      });
    }
  }

  Future<void> selectRepetitions(BuildContext context) async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return NumberPickerDialog(
          title: "Custom Repetitions",
          initialValue: repetitions,
          minValue: 1,
          maxValue: 100,
        );
      },
    );
    if (picked != null && picked != repetitions) {
      setState(() {
        repetitions = picked;
      });
    }
  }

  Future<void> selectWeight(BuildContext context) async {
    final double? picked = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return WeightPickerDialog(
          title: "Custom Weights",
          initialValue: weight,
          minValue: 1.0,
          maxValue: 100.0,
        );
      },
    );
    if (picked != null && picked != weight) {
      setState(() {
        weight = picked;
      });
    }
  }

  Future<void> saveWorkoutData() async {
    final response = await http.post(
      Uri.parse('http://172.25.91.241/fitness/store_workout_data.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': 1, // Replace with actual user ID
        'workout_date': widget.date.toIso8601String().split('T')[0],
        'workout_time': '${selectedTime.hour}:${selectedTime.minute}',
        'workout_type': workout,
        'difficulty': difficulty,
        'repetitions': repetitions,
        'weight': weight,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        Fluttertoast.showToast(
          msg: "Workout saved successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to save workout: ${responseData['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Failed to save workout",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Image.asset(
                "assets/img/date.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                style: TextStyle(color: TColor.gray, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Time",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: media.width * 0.35,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newDate) {
                setState(() {
                  selectedTime = TimeOfDay.fromDateTime(newDate);
                });
              },
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Details Workout",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/img/choose_workout.png",
              title: "Choose Workout",
              time: workout,
              color: TColor.lightGray,
              onPressed: () => selectWorkout(context)),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/difficulity.png",
              title: "Difficulty",
              time: difficulty,
              color: TColor.lightGray,
              onPressed: () => selectDifficulty(context)),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Repetitions",
              time: "$repetitions reps",
              color: TColor.lightGray,
              onPressed: () => selectRepetitions(context)),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Weights",
              time: "$weight kg",
              color: TColor.lightGray,
              onPressed: () => selectWeight(context)),
          const Spacer(),
          RoundButton(title: "Save", onPressed: saveWorkoutData),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}

class NumberPickerDialog extends StatefulWidget {
  final String title;
  final int initialValue;
  final int minValue;
  final int maxValue;

  const NumberPickerDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  _NumberPickerDialogState createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(
            color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: NumberPicker(
        value: selectedValue,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedValue);
          },
          child: Text("OK",
              style: TextStyle(color: TColor.primaryColor1, fontSize: 14)),
        ),
      ],
    );
  }
}

class WeightPickerDialog extends StatefulWidget {
  final String title;
  final double initialValue;
  final double minValue;
  final double maxValue;

  const WeightPickerDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  _WeightPickerDialogState createState() => _WeightPickerDialogState();
}

class _WeightPickerDialogState extends State<WeightPickerDialog> {
  late double selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(
            color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: WeightPicker(
        value: selectedValue,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedValue);
          },
          child: Text("OK",
              style: TextStyle(color: TColor.primaryColor1, fontSize: 14)),
        ),
      ],
    );
  }
}

class WeightPicker extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onChanged;

  const WeightPicker({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove, color: TColor.black),
          onPressed: () {
            if (value > minValue) {
              onChanged(value - 0.5);
            }
          },
        ),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(fontSize: 20, color: TColor.black),
        ),
        IconButton(
          icon: Icon(Icons.add, color: TColor.black),
          onPressed: () {
            if (value < maxValue) {
              onChanged(value + 0.5);
            }
          },
        ),
      ],
    );
  }
}
