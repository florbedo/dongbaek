import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/snapshot_bloc.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final GlobalKey<FormState> _addScheduleFormKey = GlobalKey<FormState>();

  String _title = "";
  DateTime _startDate = DateTimeUtils.truncateToDay(DateTime.now());
  final Set<DayOfWeek> _selectedDaysOfWeek = {};

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
                    DayOfWeek.values.length,
                    (index) {
                      final curDayOfWeek = DayOfWeek.values[index];
                      final isSelected = _selectedDaysOfWeek.contains(curDayOfWeek);
                      return ElevatedButton(
                        child: Text(DayOfWeek.values[index].shortName),
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              _selectedDaysOfWeek.remove(curDayOfWeek);
                            } else {
                              _selectedDaysOfWeek.add(curDayOfWeek);
                            }
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
                ListTile(
                  leading: const Text("Start Date :"),
                  title: InkWell(
                    child: Text(
                        "${_startDate.year}. ${_startDate.month}. ${_startDate.day}. (${DateTimeUtils.getDayOfWeek(_startDate).shortName})"),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTimeUtils.truncateToDay(DateTime.now()),
                        firstDate: DateTimeUtils.truncateToDay(DateTime.now()),
                        lastDate: DateTime.now().add(const Duration(days: 365000)),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _startDate = selectedDate;
                        });
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addScheduleFormKey.currentState!.save();
                    context.read<ScheduleBloc>().add(AddSchedule(_title, _selectedDaysOfWeek.toList(), _startDate, 1));
                    context.read<SnapshotBloc>().add(const SnapshotDataUpdated());
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
