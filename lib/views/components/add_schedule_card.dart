import 'dart:developer' as dev;

import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/utils/duration_utils.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Type _goalType = QuantityGoal;
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
                decoration: const InputDecoration(labelText: "할 일"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '구분할 수 있는 할 일을 적어주세요!';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text("목표"),
                  ),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<Type>(
                      value: _goalType,
                      items: const [
                        DropdownMenuItem(
                          value: QuantityGoal,
                          child: Text("횟수"),
                        ),
                        DropdownMenuItem(
                          value: DurationGoal,
                          child: Text("시간"),
                        ),
                      ],
                      onChanged: (Type? value) {
                        if (value != null) {
                          setState(() {
                            switch (value) {
                              case QuantityGoal:
                                _goalType = QuantityGoal;
                                _goal = const QuantityGoal(1);
                              case DurationGoal:
                                _goalType = DurationGoal;
                                _goal = const DurationGoal(Duration(minutes: 30));
                            }
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _goalType == QuantityGoal
                        ? TextFormField(
                            initialValue: _goal is QuantityGoal ? (_goal as QuantityGoal).quantity.toString() : "1",
                            onSaved: (newValue) {
                              if (newValue == null) {
                                return;
                              }
                              final cnt = int.tryParse(newValue);
                              if (cnt == null) {
                                return;
                              }
                              _goal = QuantityGoal(cnt);
                            },
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                          )
                        : TextButton(
                            onPressed: () async {
                              final newDuration = await showDurationPicker(
                                context: context,
                                initialTime: _goal is DurationGoal
                                    ? (_goal as DurationGoal).duration
                                    : const Duration(minutes: 30),
                              );
                              if (newDuration != null) {
                                setState(() {
                                  _goal = DurationGoal(newDuration);
                                });
                              }
                            },
                            child: Text((_goal as DurationGoal).duration.text),
                          ),
                  )
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text("반복"),
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
                ],
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
                    context.read<ScheduleBloc>().add(AddSchedule(_title, _goal, _repeatInfo, _startDate, _dueDate));

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
