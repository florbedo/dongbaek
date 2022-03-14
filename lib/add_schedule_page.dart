import 'package:dongbaek/utils/datetime_utils.dart';
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

  String _title = "";
  final List<bool> _daysOfWeekSelected = List.generate(DayOfWeek.values.length, (i) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Schedule")),
      body: Form(
        key: _addScheduleFormKey,
        child: BlocBuilder<ScheduleBloc, List<Schedule>>(
          builder: (BuildContext context, List<Schedule> schedules) {
            return Column(
              children: <Widget>[
                TextFormField(
                  onSaved: (newValue) => _title = newValue ?? "",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _daysOfWeekSelected.length,
                    (index) {
                      final isSelected = _daysOfWeekSelected[index];
                      return ElevatedButton(
                        child: Text(DayOfWeek.values[index].shortName),
                        onPressed: () {
                          setState(() {
                            _daysOfWeekSelected[index] = !_daysOfWeekSelected[index];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPrimary: isSelected ? Colors.white : Theme.of(context).primaryColor,
                          primary: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addScheduleFormKey.currentState!.save();

                    final selectedDaysOfWeek = List.generate(
                      _daysOfWeekSelected.length,
                      (index) => _daysOfWeekSelected[index] ? DayOfWeek.values[index] : null,
                    ).whereType<DayOfWeek>().toList();

                    context.read<ScheduleBloc>().add(AddSchedule(_title, selectedDaysOfWeek, 1));
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
