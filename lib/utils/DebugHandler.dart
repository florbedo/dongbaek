import 'dart:developer' as dev;

import 'package:dongbaek/repositories/local/local_database.dart';
import 'package:flutter/services.dart';

class DebugHandler {
  static void init() {
    HardwareKeyboard.instance.addHandler(_PrintDbKeyboardHandler().handleEvent);
    HardwareKeyboard.instance.addHandler(_DropDbKeyboardHandler().handleEvent);
  }
}

abstract class _DebugKeyboardHandler {
  Duration getActivationDuration() {
    return const Duration(seconds: 1);
  }

  List<LogicalKeyboardKey> getActivationKeys();

  void execDebug();

  DateTime? _pressStartDateTime;

  bool handleEvent(KeyEvent event) {
    if (!HardwareKeyboard.instance.logicalKeysPressed.containsAll(getActivationKeys())) {
      _pressStartDateTime = null;
      return false;
    }
    if (HardwareKeyboard.instance.logicalKeysPressed.containsAll(getActivationKeys())) {
      switch (_pressStartDateTime) {
        case DateTime dt:
          if (DateTime.now().difference(dt).compareTo(getActivationDuration()) >= 0) {
            execDebug();
            _pressStartDateTime = DateTime.now();
          }
        case null:
          _pressStartDateTime = DateTime.now();
      }
    } else {
      _pressStartDateTime = null;
      return false;
    }
    return false;
  }
}

class _PrintDbKeyboardHandler extends _DebugKeyboardHandler {
  @override
  List<LogicalKeyboardKey> getActivationKeys() {
    return const [LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.f8];
  }

  @override
  void execDebug() {
    LocalDatabase().printDatabase();
  }
}

class _DropDbKeyboardHandler extends _DebugKeyboardHandler {
  @override
  List<LogicalKeyboardKey> getActivationKeys() {
    return const [LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.f9, LogicalKeyboardKey.f10];
  }

  @override
  void execDebug() {
    dev.log("TRUNCATE_DATABASE");
    LocalDatabase().truncateDatabase();
  }
}
