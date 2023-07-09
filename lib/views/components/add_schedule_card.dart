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
  Type _repeatInfoType = Unrepeated;
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
                  Expanded(
                    flex: 1,
                    child: DropdownButton<Type>(
                      value: _repeatInfoType,
                      items: const [
                        DropdownMenuItem(
                          value: Unrepeated,
                          child: Text("반복안함"),
                        ),
                        DropdownMenuItem(
                          value: PeriodicRepeat,
                          child: Text("기간동안"),
                        ),
                      ],
                      onChanged: (Type? value) {
                        if (value != null) {
                          setState(() {
                            switch (value) {
                              case Unrepeated:
                                _repeatInfoType = Unrepeated;
                                _repeatInfo = const Unrepeated();
                              case PeriodicRepeat:
                                _repeatInfoType = PeriodicRepeat;
                                _setPeriodicRepeat(const Duration(days: 1), _startDate);
                            }
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _repeatInfoType == Unrepeated
                        ? Container()
                        : TextFormField(
                            decoration: const InputDecoration(prefix: Text("매 "), suffix: Text("일동안")),
                            initialValue: _repeatInfo is PeriodicRepeat
                                ? (_repeatInfo as PeriodicRepeat).periodDuration.inDays.toString()
                                : "1",
                            onChanged: (newValue) {
                              final periodDays = int.tryParse(newValue.trim());
                              if (periodDays == null || periodDays < 1) {
                                return;
                              }

                              final periodDuration = Duration(days: periodDays);
                              _setPeriodicRepeat(periodDuration, _startDate);
                            },
                            validator: (newValue) {
                              final periodDays = int.tryParse(newValue ?? "");
                              if (periodDays == null || periodDays < 1) {
                                return "1일 이상 입력해주세요";
                              }
                            },
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text("시작"),
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      child: Text(DateTimeUtils.formatDate(_startDate)),
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
                            switch (_repeatInfo) {
                              case PeriodicRepeat r:
                                final existingPeriodDuration = r.periodDuration;
                                _setPeriodicRepeat(existingPeriodDuration, _startDate);
                              default:
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text("종료"),
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      child: Text(_dueDate == null
                          ? "계속"
                          : DateTimeUtils.formatDate((_dueDate!).subtract(const Duration(days: 1)))),
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

  void _setPeriodicRepeat(Duration periodDuration, DateTime startDateTime) {
    final offsetDuration = Duration(microseconds: startDateTime.microsecondsSinceEpoch % periodDuration.inMicroseconds);
    setState(() {
      _repeatInfo = PeriodicRepeat(periodDuration, offsetDuration);
      _dueDate = null;
    });
  }
}
