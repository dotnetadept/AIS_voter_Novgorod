import 'dart:math';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<TimePlannerTask> tasks = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: const Text('Календарь'),
      actions: [
        FloatingActionButton(
          onPressed: () => _addObject(context),
          tooltip: 'Add random task',
          child: const Icon(Icons.add),
        ),
      ],
      body: TimePlanner(
        startHour: 6,
        endHour: 23,
        headers: const [
          TimePlannerTitle(
            date: "3/10/2021",
            title: "sunday",
          ),
          TimePlannerTitle(
            date: "3/11/2021",
            title: "monday",
          ),
          TimePlannerTitle(
            date: "3/12/2021",
            title: "tuesday",
          ),
          TimePlannerTitle(
            date: "3/13/2021",
            title: "wednesday",
          ),
          TimePlannerTitle(
            date: "3/14/2021",
            title: "thursday",
          ),
          TimePlannerTitle(
            date: "3/15/2021",
            title: "friday",
          ),
          TimePlannerTitle(
            date: "3/16/2021",
            title: "saturday",
          ),
          TimePlannerTitle(
            date: "3/17/2021",
            title: "sunday",
          ),
          TimePlannerTitle(
            date: "3/18/2021",
            title: "monday",
          ),
          TimePlannerTitle(
            date: "3/19/2021",
            title: "tuesday",
          ),
          TimePlannerTitle(
            date: "3/20/2021",
            title: "wednesday",
          ),
          TimePlannerTitle(
            date: "3/21/2021",
            title: "thursday",
          ),
          TimePlannerTitle(
            date: "3/22/2021",
            title: "friday",
          ),
          TimePlannerTitle(
            date: "3/23/2021",
            title: "saturday",
          ),
          TimePlannerTitle(
            date: "3/24/2021",
            title: "tuesday",
          ),
          TimePlannerTitle(
            date: "3/25/2021",
            title: "wednesday",
          ),
          TimePlannerTitle(
            date: "3/26/2021",
            title: "thursday",
          ),
          TimePlannerTitle(
            date: "3/27/2021",
            title: "friday",
          ),
          TimePlannerTitle(
            date: "3/28/2021",
            title: "saturday",
          ),
          TimePlannerTitle(
            date: "3/29/2021",
            title: "friday",
          ),
          TimePlannerTitle(
            date: "3/30/2021",
            title: "saturday",
          ),
        ],
        tasks: tasks,
        style: TimePlannerStyle(
          // cellHeight: 60,
          // cellWidth: 60,
          showScrollBar: true,
        ),
      ),
    );
  }

  void _addObject(BuildContext context) {
    List<Color?> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.lime[600]
    ];

    setState(() {
      tasks.add(
        TimePlannerTask(
          color: colors[Random().nextInt(colors.length)],
          dateTime: TimePlannerDateTime(
              day: Random().nextInt(14),
              hour: Random().nextInt(18) + 6,
              minutes: Random().nextInt(60)),
          minutesDuration: Random().nextInt(90) + 30,
          daysDuration: Random().nextInt(4) + 1,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('You click on time planner object')));
          },
          child: Text(
            'this is a demo',
            style: TextStyle(color: Colors.grey[350], fontSize: 12),
          ),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Random task added to time planner!')));
  }
}
