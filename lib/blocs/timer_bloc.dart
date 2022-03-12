import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

enum TimerEvent {
  tick,
  start,
  stop,
}

class TimerBloc extends Bloc<TimerEvent, DateTime> {
  late Timer _timer;

  TimerBloc() : super(DateTime.now()) {
    on<TimerEvent>((event, emit) {
      if (event == TimerEvent.tick) {
        emit(DateTime.now());
      }
      if (event == TimerEvent.start && !_timer.isActive) {
        _timer = _createTimer();
      }
      if (event == TimerEvent.stop) {
        _timer.cancel();
      }
    });
    _timer = _createTimer();
  }

  Timer _createTimer() {
    return Timer.periodic(const Duration(milliseconds: 10), (_) {
      add(TimerEvent.tick);
    });
  }
}
