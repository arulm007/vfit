import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';

class SleepAddAlarmView extends StatefulWidget {
  final DateTime date;
  const SleepAddAlarmView({super.key, required this.date});

  @override
  State<SleepAddAlarmView> createState() => _SleepAddAlarmViewState();
}

class _SleepAddAlarmViewState extends State<SleepAddAlarmView> {
  bool positive = false;
  TimeOfDay bedtime = TimeOfDay(hour: 21, minute: 0);
  Duration hoursOfSleep = const Duration(hours: 8, minutes: 30);
  List<String> repeatDays = ["Mon", "Tue", "Wed", "Thu", "Fri"];

  Future<void> selectBedtime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: bedtime,
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
    if (picked != null && picked != bedtime) {
      setState(() {
        bedtime = picked;
      });
    }
  }

  Future<void> selectHoursOfSleep(BuildContext context) async {
    final Duration? picked = await showDurationPicker(
      context: context,
      initialDuration: hoursOfSleep,
    );
    if (picked != null && picked != hoursOfSleep) {
      setState(() {
        hoursOfSleep = picked;
      });
    }
  }

  Future<void> selectRepeatDays(BuildContext context) async {
    final List<String>? picked = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return RepeatDaysDialog(selectedDays: repeatDays);
      },
    );
    if (picked != null && picked != repeatDays) {
      setState(() {
        repeatDays = picked;
      });
    }
  }

  Future<void> saveAlarmData() async {
    final response = await http.post(
      Uri.parse('http://172.25.91.241/fitness/store_sleep_data.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': 1, // Replace with actual user ID
        'sleep_date': widget.date.toIso8601String().split('T')[0],
        'sleep_start_time': '${bedtime.hour}:${bedtime.minute}',
        'sleep_end_time':
            '${bedtime.hour + hoursOfSleep.inHours}:${bedtime.minute + hoursOfSleep.inMinutes % 60}',
        'total_sleep_hours':
            hoursOfSleep.inHours + (hoursOfSleep.inMinutes % 60) / 60,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm saved successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to save alarm: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save alarm')),
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
          "Add Alarm",
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
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/img/Bed_Add.png",
              title: "Bedtime",
              time: "${bedtime.format(context)}",
              color: TColor.lightGray,
              onPressed: () => selectBedtime(context)),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/HoursTime.png",
              title: "Hours of sleep",
              time:
                  "${hoursOfSleep.inHours}hours ${hoursOfSleep.inMinutes % 60}minutes",
              color: TColor.lightGray,
              onPressed: () => selectHoursOfSleep(context)),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/Repeat.png",
              title: "Repeat",
              time: repeatDays.join(", "),
              color: TColor.lightGray,
              onPressed: () => selectRepeatDays(context)),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 15,
                ),
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/img/Vibrate.png",
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Vibrate When Alarm Sound",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Transform.scale(
                    scale: 0.7,
                    child: CustomAnimatedToggleSwitch<bool>(
                      current: positive,
                      values: [false, true],
                      dif: 0.0,
                      indicatorSize: const Size.square(30.0),
                      animationDuration: const Duration(milliseconds: 200),
                      animationCurve: Curves.linear,
                      onChanged: (b) => setState(() => positive = b),
                      iconBuilder: (context, local, global) {
                        return const SizedBox();
                      },
                      defaultCursor: SystemMouseCursors.click,
                      onTap: () => setState(() => positive = !positive),
                      iconsTappable: false,
                      wrapperBuilder: (context, global, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                                left: 10.0,
                                right: 10.0,
                                height: 30.0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: TColor.secondaryG),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0)),
                                  ),
                                )),
                            child,
                          ],
                        );
                      },
                      foregroundIndicatorBuilder: (context, global) {
                        return SizedBox.fromSize(
                          size: const Size(10, 10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50.0)),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black38,
                                    spreadRadius: 0.05,
                                    blurRadius: 1.1,
                                    offset: Offset(0.0, 0.8))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          const Spacer(),
          RoundButton(title: "Add", onPressed: saveAlarmData),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}

class RepeatDaysDialog extends StatefulWidget {
  final List<String> selectedDays;
  const RepeatDaysDialog({super.key, required this.selectedDays});

  @override
  State<RepeatDaysDialog> createState() => _RepeatDaysDialogState();
}

class _RepeatDaysDialogState extends State<RepeatDaysDialog> {
  late List<String> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = List.from(widget.selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Select Repeat Days",
        style: TextStyle(
            color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: Text("Monday",
                style: TextStyle(color: TColor.black, fontSize: 14)),
            value: selectedDays.contains("Mon"),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDays.add("Mon");
                } else {
                  selectedDays.remove("Mon");
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text("Tuesday",
                style: TextStyle(color: TColor.black, fontSize: 14)),
            value: selectedDays.contains("Tue"),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDays.add("Tue");
                } else {
                  selectedDays.remove("Tue");
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text("Wednesday",
                style: TextStyle(color: TColor.black, fontSize: 14)),
            value: selectedDays.contains("Wed"),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDays.add("Wed");
                } else {
                  selectedDays.remove("Wed");
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text("Thursday",
                style: TextStyle(color: TColor.black, fontSize: 14)),
            value: selectedDays.contains("Thu"),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDays.add("Thu");
                } else {
                  selectedDays.remove("Thu");
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text("Friday",
                style: TextStyle(color: TColor.black, fontSize: 14)),
            value: selectedDays.contains("Fri"),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDays.add("Fri");
                } else {
                  selectedDays.remove("Fri");
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text("Saturday",
                style: TextStyle(color: TColor.black, fontSize: 14)),
            value: selectedDays.contains("Sat"),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDays.add("Sat");
                } else {
                  selectedDays.remove("Sat");
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text("Sunday",
                style: TextStyle(color: TColor.black, fontSize: 14)),
            value: selectedDays.contains("Sun"),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedDays.add("Sun");
                } else {
                  selectedDays.remove("Sun");
                }
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedDays);
          },
          child: Text("OK",
              style: TextStyle(color: TColor.primaryColor1, fontSize: 14)),
        ),
      ],
    );
  }
}

Future<Duration?> showDurationPicker({
  required BuildContext context,
  required Duration initialDuration,
}) async {
  Duration selectedDuration = initialDuration;
  return showDialog<Duration>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Select Hours of Sleep",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NumberPicker(
              value: selectedDuration.inHours,
              minValue: 0,
              maxValue: 23,
              onChanged: (value) {
                selectedDuration = Duration(
                  hours: value,
                  minutes: selectedDuration.inMinutes % 60,
                );
              },
            ),
            NumberPicker(
              value: selectedDuration.inMinutes % 60,
              minValue: 0,
              maxValue: 59,
              onChanged: (value) {
                selectedDuration = Duration(
                  hours: selectedDuration.inHours,
                  minutes: value,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedDuration);
            },
            child: Text("OK",
                style: TextStyle(color: TColor.primaryColor1, fontSize: 14)),
          ),
        ],
      );
    },
  );
}

class NumberPicker extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const NumberPicker({
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
              onChanged(value - 1);
            }
          },
        ),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 20, color: TColor.black),
        ),
        IconButton(
          icon: Icon(Icons.add, color: TColor.black),
          onPressed: () {
            if (value < maxValue) {
              onChanged(value + 1);
            }
          },
        ),
      ],
    );
  }
}
