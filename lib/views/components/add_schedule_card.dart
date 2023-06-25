import 'dart:developer' as dev;

import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_picker/flutter_picker.dart';

class AddScheduleCard extends StatefulWidget {
  const AddScheduleCard({Key? key, this.onCreate}) : super(key: key);

  final void Function(BuildContext)? onCreate;

  @override
  State<AddScheduleCard> createState() => _AddScheduleCardState();
}

class _AddScheduleCardState extends State<AddScheduleCard> {
  final GlobalKey<FormState> _addScheduleFormKey = GlobalKey<FormState>();

  String _title = "";

  Goal _goal = const QuantityGoal(1);
  RepeatInfo _repeatInfo = const Unrepeated();
  DateTime _startDate = DateTimeUtils.truncateToDay(DateTime.now());
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _addScheduleFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextFormField(
                onSaved: (newValue) => _title = newValue ?? "",
                decoration: const InputDecoration(labelText: "할 일 제목"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '1자 이상 입력해주세요.';
                  }
                  return null;
                },
              ),
              PopupMenuButton(
                child: Wrap(
                  children: [
                    const Icon(Icons.flag_outlined),
                    _getGoalDescText(_goal),
                  ],
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Type>>[
                  const PopupMenuItem<Type>(
                    value: QuantityGoal,
                    child: Text('Quantity Goal'),
                  ),
                  const PopupMenuItem<Type>(
                    value: DurationGoal,
                    child: Text('Duration Goal'),
                  ),
                ],
                onSelected: (Type type) async {
                  if (type == QuantityGoal) {
                    int initialValue = 1;
                    if (_goal is QuantityGoal) {
                      initialValue = (_goal as QuantityGoal).quantity;
                    }
                    final resIdxList = await Picker(
                      adapter: NumberPickerAdapter(data: [
                        NumberPickerColumn(begin: 1, end: 999, initValue: initialValue),
                      ]),
                      hideHeader: true,
                      title: const Text("How many times?"),
                    ).showDialog(context);
                    final newQuantityTargetIdx = resIdxList?[0];

                    if (newQuantityTargetIdx == null) {
                      return;
                    }
                    final newQuantityTarget = newQuantityTargetIdx + 1;
                    dev.log("New quantity target: $newQuantityTarget");

                    setState(() {
                      _goal = QuantityGoal(newQuantityTarget);
                    });
                    return;
                  }
                  if (type == DurationGoal) {
                    int targetHour = 0;
                    int targetMin = 0;
                    int targetSec = 0;
                    if (_goal is DurationGoal) {
                      final existingDuration = (_goal as DurationGoal).duration;
                      targetHour = existingDuration.inHours;
                      targetMin = existingDuration.inMinutes - targetHour * 60;
                      targetSec = existingDuration.inSeconds - targetHour * 3600 - targetMin * 60;
                    }
                    final resDurationFields = await Picker(
                      adapter: NumberPickerAdapter(data: [
                        NumberPickerColumn(begin: 0, end: 999, initValue: targetHour, suffix: const Text("h")),
                        NumberPickerColumn(begin: 0, end: 60, initValue: targetMin, suffix: const Text("m")),
                        NumberPickerColumn(begin: 0, end: 60, initValue: targetSec, suffix: const Text("s")),
                      ]),
                      delimiter: [
                        PickerDelimiter(
                          child: Container(
                            width: 10.0,
                            alignment: Alignment.center,
                            child: const Icon(Icons.more_vert),
                          ),
                          column: 1,
                        ),
                        PickerDelimiter(
                          child: Container(
                            width: 10.0,
                            alignment: Alignment.center,
                            child: const Icon(Icons.more_vert),
                          ),
                          column: 3,
                        ),
                      ],
                      hideHeader: true,
                      title: const Text("How long?"),
                    ).showDialog(context);

                    if (resDurationFields == null) {
                      return;
                    }
                    targetHour = resDurationFields[0];
                    targetMin = resDurationFields[1];
                    targetSec = resDurationFields[2];

                    dev.log("New duration target: $targetHour : $targetMin : $targetSec");
                    setState(() {
                      _goal = DurationGoal(Duration(hours: targetHour, minutes: targetMin, seconds: targetSec));
                    });
                  }
                },
              ),
              PopupMenuButton(
                child: Wrap(
                  children: [
                    const Icon(Icons.loop_outlined),
                    _getRepeatInfoDescText(_repeatInfo),
                  ],
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Type>>[
                  const PopupMenuItem<Type>(
                    value: Unrepeated,
                    child: Text('Unrepeated'),
                  ),
                  const PopupMenuItem<Type>(
                    value: PeriodicRepeat,
                    child: Text('Periodic Repeat'),
                  ),
                ],
                onSelected: (Type type) async {
                  if (type == Unrepeated) {
                    setState(() {
                      _repeatInfo = const Unrepeated();
                      _dueDate = null;
                    });
                    return;
                  }
                  if (type == PeriodicRepeat) {
                    int periodDays = 1;
                    if (_repeatInfo is PeriodicRepeat) {
                      periodDays = (_repeatInfo as PeriodicRepeat).periodDuration.inDays;
                    }
                    final periodIdxList = await Picker(
                      adapter: NumberPickerAdapter(data: [
                        NumberPickerColumn(
                            begin: 1,
                            end: 100,
                            initValue: periodDays,
                            onFormatValue: (v) {
                              if (v == 1) {
                                return "Everyday";
                              }
                              return "Every $v days";
                            }),
                      ]),
                      hideHeader: true,
                      title: const Text("Set repeat period"),
                    ).showDialog(context);
                    final newPeriodIdx = periodIdxList?[0];

                    if (newPeriodIdx == null) {
                      return;
                    }
                    periodDays = newPeriodIdx + 1;
                    final offsetDays = DateTimeUtils.asEpochDay(_startDate) % periodDays;
                    dev.log("New periodic repeat: $periodDays : $offsetDays");
                    setState(() {
                      _repeatInfo = PeriodicRepeat(Duration(days: periodDays), Duration(days: offsetDays));
                      _dueDate = null;
                    });
                  }
                },
              ),
              Wrap(
                spacing: 10.0,
                runSpacing: 5.0,
                children: [
                  InkWell(
                    child: Wrap(
                      children: [
                        const Icon(Icons.start_outlined),
                        Text("From ${DateTimeUtils.formatDate(_startDate)}"),
                      ],
                    ),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTimeUtils.truncateToDay(DateTime.now()),
                        lastDate: DateTime.now().add(const Duration(days: 365000)),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _startDate = selectedDate;
                          if (_repeatInfo is PeriodicRepeat) {
                            final repeatInfo = _repeatInfo as PeriodicRepeat;
                            final newOffsetMicroseconds =
                                selectedDate.microsecondsSinceEpoch % repeatInfo.periodDuration.inMicroseconds;
                            final newOffsetDuration = Duration(microseconds: newOffsetMicroseconds);
                            _repeatInfo = PeriodicRepeat(repeatInfo.periodDuration, newOffsetDuration);
                            _dueDate = null;
                          }
                        });
                      }
                    },
                  ),
                  InkWell(
                    child: Wrap(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(_dueDate == null ? "Continue" : "Until ${DateTimeUtils.formatDate(_dueDate!)}"),
                        Icon(_dueDate == null ? Icons.all_inclusive_outlined : Icons.last_page_outlined),
                      ],
                    ),
                    onTap: () async {
                      final period =
                          _repeatInfo is PeriodicRepeat ? (_repeatInfo as PeriodicRepeat).periodDuration.inDays : 1;
                      final firstDueDate = _startDate.add(Duration(days: period - 1));
                      final inclusiveDueDate = await showDatePicker(
                        context: context,
                        initialDate: firstDueDate,
                        firstDate: firstDueDate,
                        lastDate: DateTime.now().add(const Duration(days: 365000)),
                        selectableDayPredicate: (date) {
                          switch (_repeatInfo) {
                            case PeriodicRepeat r:
                              final epochRemainder = (date.microsecondsSinceEpoch -
                                      r.offsetDuration.inMicroseconds +
                                      const Duration(days: 1).inMicroseconds) %
                                  r.periodDuration.inMicroseconds;
                              return epochRemainder == 0;
                            default:
                              return true;
                          }
                        },
                      );
                      if (inclusiveDueDate != null) {
                        setState(() {
                          _dueDate = inclusiveDueDate.add(const Duration(days: 1));
                        });
                      }
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_addScheduleFormKey.currentState!.validate()) {
                    _addScheduleFormKey.currentState!.save();
                    context.read<ScheduleBloc>().add(AddSchedule(_title, _goal, _repeatInfo, _startDate, null));

                    if (widget.onCreate != null) {
                      widget.onCreate!(context);
                    }
                  }
                },
                child: const Text("Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Text _getGoalDescText(Goal goal) {
    if (goal is QuantityGoal) {
      if (goal.quantity == 1) {
        return const Text("Just Once");
      }
      return Text("${goal.quantity} Times");
    }
    if (goal is DurationGoal) {
      final duration = goal.duration;
      final targetHour = duration.inHours;
      final targetMin = duration.inMinutes - targetHour * 60;
      final targetSec = duration.inSeconds - targetHour * 3600 - targetMin * 60;

      final targetHourStr = targetHour > 0 ? "${targetHour}h " : "";
      final targetMinStr = targetMin > 0 ? "${targetMin}m " : "";
      final targetSecStr = targetSec > 0 ? "${targetSec}s " : "";

      return Text("$targetHourStr$targetMinStr$targetSecStr");
    }
    return const Text("ERROR: Unknown Goal");
  }

  static Text _getRepeatInfoDescText(RepeatInfo repeatInfo) {
    if (repeatInfo is Unrepeated) {
      return const Text("Not repeat");
    }
    if (repeatInfo is PeriodicRepeat) {
      if (repeatInfo.periodDuration.inDays == 1) {
        return const Text("Every day");
      }
      return Text("In every ${repeatInfo.periodDuration.inDays} days");
    }
    return const Text("ERROR: Unknown RepeatInfo");
  }
}
