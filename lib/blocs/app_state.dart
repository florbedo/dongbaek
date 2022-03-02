import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:flutter/material.dart';

class AppStateContainer extends StatefulWidget {
  final Widget child;
  final BlocProvider blocProvider;
  const AppStateContainer({
    Key? key,
    required this.child,
    required this.blocProvider,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppState();

  static AppState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_AppStoreContainer>() as _AppStoreContainer).appData;
  }
}

class AppState extends State<AppStateContainer> {
  BlocProvider get blocProvider => widget.blocProvider;

  @override
  Widget build(BuildContext context) {
    return _AppStoreContainer(
      appData: this,
      blocProvider: widget.blocProvider,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _AppStoreContainer extends InheritedWidget {
  final AppState appData;
  final BlocProvider blocProvider;

  const _AppStoreContainer({
    Key? key,
    required this.appData,
    required child,
    required this.blocProvider,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_AppStoreContainer oldWidget) => oldWidget.appData != appData;
}

class ServiceProvider {

  ServiceProvider();
}

class BlocProvider {
  final ScheduleBloc scheduleBloc;

  BlocProvider(this.scheduleBloc);
}
