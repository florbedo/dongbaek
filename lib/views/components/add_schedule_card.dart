import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddScheduleCard extends StatefulWidget {
  const AddScheduleCard({Key? key}) : super(key: key);

  @override
  State<AddScheduleCard> createState() => _AddScheduleCardState();
}

class _AddScheduleCardState extends State<AddScheduleCard> {
  final GlobalKey<FormState> _addScheduleFormKey = GlobalKey<FormState>();

  String _title = "";

  Goal _goal = _getDefaultGoal(QuantityGoal);
  RepeatInfo _repeatInfo = const Unrepeated();
  DateTime _startDate = DateTimeUtils.truncateToDay(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Form(
        key: _addScheduleFormKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              onSaved: (newValue) => _title = newValue ?? "",
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<Type>(
                    value: _goal.runtimeType,
                    items: [QuantityGoal, DurationGoal].map<DropdownMenuItem<Type>>((Type i) {
                      return DropdownMenuItem<Type>(
                        value: i,
                        child: Text(i.toString()),
                      );
                    }).toList(),
                    onChanged: (Type? value) {
                      if (value != null) {
                        setState(() {
                          _goal = _getDefaultGoal(value);
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: DropdownButton<Type>(
                    value: _repeatInfo.runtimeType,
                    items: [Unrepeated, PeriodicRepeat].map<DropdownMenuItem<Type>>((Type i) {
                      return DropdownMenuItem<Type>(
                        value: i,
                        child: Text(i.toString()),
                      );
                    }).toList(),
                    onChanged: (Type? value) {
                      if (value != null) {
                        setState(() {
                          _repeatInfo = _getDefaultRepeatInfo(value);
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Text("Start Date :"),
                    title: InkWell(
                      child: Text(
                          "${_startDate.year}. ${_startDate.month}. ${_startDate.day}. (${DateTimeUtils.getDayOfWeek(_startDate).shortName})"),
                      onTap: () async {
                        _startDate = await showDatePicker(
                              context: context,
                              initialDate: DateTimeUtils.truncateToDay(DateTime.now()),
                              firstDate: DateTimeUtils.truncateToDay(DateTime.now()),
                              lastDate: DateTime.now().add(const Duration(days: 365000)),
                            ) ??
                            DateTimeUtils.truncateToDay(DateTime.now());
                      },
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _addScheduleFormKey.currentState!.save();
                context.read<ScheduleBloc>().add(AddSchedule(_title, _goal, _repeatInfo, _startDate, null));
                // Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  static Goal _getDefaultGoal(Type type) {
    switch (type) {
      case QuantityGoal:
        return QuantityGoal(1);
      case DurationGoal:
        return DurationGoal(const Duration(hours: 1));
      default:
        throw UnimplementedError("INVALID_GOAL_TYPE $type");
    }
  }

  static RepeatInfo _getDefaultRepeatInfo(Type type) {
    switch (type) {
      case Unrepeated:
        return const Unrepeated();
      case PeriodicRepeat:
        return PeriodicRepeat(7, 0);
      default:
        throw UnimplementedError("INVALID_REPEAT_INFO_TYPE $type");
    }
  }
}
