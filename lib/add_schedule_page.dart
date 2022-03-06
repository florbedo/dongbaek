import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/schedule_bloc.dart';
import 'models/schedule.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final GlobalKey<FormState> _addScheduleFormKey = GlobalKey<FormState>();

  final List<String> _daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"];

  String _title = "";
  final List<bool> _daysOfWeekSelected = [false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _addScheduleFormKey,
        child: BlocBuilder<ScheduleBloc, List<Schedule>>(
          builder: (BuildContext context, List<Schedule> schedules) {
            return Column(
              children: <Widget>[
                TextFormField(
                  onSaved: (newValue) => _title = newValue ?? "",
                ),
                ToggleButtons(
                  isSelected: _daysOfWeekSelected,
                  onPressed: (index) {
                    setState(() {
                      _daysOfWeekSelected[index] = !_daysOfWeekSelected[index];
                    });
                  },
                  children: List.generate(
                    _daysOfWeek.length,
                    (index) => Text(_daysOfWeek[index]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addScheduleFormKey.currentState!.save();

                    final selectedDaysOfWeek = List.generate(
                      _daysOfWeek.length,
                      (index) => _daysOfWeekSelected[index] ? _daysOfWeek[index] : null,
                    ).whereType<String>().toList();

                    context.read<ScheduleBloc>().add(AddScheduleEvent(_title, selectedDaysOfWeek, 1));
                    Navigator.pop(context);
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
