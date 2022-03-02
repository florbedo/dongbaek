import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:flutter/material.dart';

import 'blocs/app_state.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final GlobalKey<FormState> _addScheduleFormKey = GlobalKey<FormState>();

  late ScheduleBloc _bloc;

  @override
  void didChangeDependencies() {
    _bloc = AppStateContainer.of(context).blocProvider.scheduleBloc;
    super.didChangeDependencies();
  }

  String _title = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _addScheduleFormKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              onSaved: (newValue) => _title = newValue ?? "",
            ),
            ElevatedButton(
              onPressed: () {
                _addScheduleFormKey.currentState!.save();
                _bloc.addScheduleSink.add(AddScheduleEvent(_title));
                Navigator.pop(context);
              },
              child: const Text("Create"),
            )
          ],
        ),
      ),
    );
  }
}
