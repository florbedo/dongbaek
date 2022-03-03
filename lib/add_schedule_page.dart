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
                ElevatedButton(
                  onPressed: () {
                    _addScheduleFormKey.currentState!.save();
                    context.read<ScheduleBloc>().add(AddScheduleEvent(_title));
                    Navigator.pop(context);
                  },
                  child: const Text("Create"),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
