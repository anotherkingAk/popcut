import 'package:flutter/foundation.dart';

/// Abstract command for undoable operations
abstract class Command {
  String get description;
  bool get canMerge => false;
  Command? mergeWith(Command other) => null;
  void execute();
  void undo();
}

/// Command history manager with composite commands, grouping, and coalescing
class CommandHistory extends ChangeNotifier {
  final List<Command> _commands = [];
  int _currentIndex = -1;
  int _maxCommands = 100;
  bool _isExecuting = false;
  bool _grouping = false;
  String? _groupName;
  List<Command>? _groupBuffer;

  bool get canUndo => _currentIndex >= 0;
  bool get canRedo => _currentIndex < _commands.length - 1;
  int get commandCount => _commands.length;
  int get currentIndex => _currentIndex;
  String? get undoDescription => canUndo ? _commands[_currentIndex].description : null;
  String? get redoDescription => canRedo ? _commands[_currentIndex + 1].description : null;
  List<Command> get commands => List.unmodifiable(_commands);

  void execute(Command command) {
    if (_isExecuting) return;
    _isExecuting = true;

    if (_grouping && _groupBuffer != null) {
      _groupBuffer!.add(command);
      _isExecuting = false;
      return;
    }

    if (_currentIndex < _commands.length - 1) {
      _commands.removeRange(_currentIndex + 1, _commands.length);
    }

    if (_commands.isNotEmpty && command.canMerge) {
      final merged = _commands.last.mergeWith(command);
      if (merged != null) {
        _commands[_commands.length - 1] = merged;
        notifyListeners();
        _isExecuting = false;
        return;
      }
    }

    command.execute();
    _commands.add(command);

    if (_commands.length > _maxCommands) {
      _commands.removeAt(0);
      _currentIndex--;
    }

    _currentIndex = _commands.length - 1;
    _isExecuting = false;
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _isExecuting = true;
    _commands[_currentIndex].undo();
    _currentIndex--;
    _isExecuting = false;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _isExecuting = true;
    _currentIndex++;
    _commands[_currentIndex].execute();
    _isExecuting = false;
    notifyListeners();
  }

  void startGroup([String? name]) {
    _grouping = true;
    _groupName = name;
    _groupBuffer = [];
  }

  void endGroup() {
    if (!_grouping || _groupBuffer == null) return;
    if (_groupBuffer!.isNotEmpty) {
      final composite = CompositeCommand(_groupName ?? 'Group', List.from(_groupBuffer!));
      _groupBuffer!.clear();
      execute(composite);
    }
    _grouping = false;
    _groupName = null;
    _groupBuffer = null;
  }

  void cancelGroup() {
    _grouping = false;
    _groupName = null;
    _groupBuffer = null;
  }

  void clear() {
    _commands.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  void setMaxCommands(int max) {
    _maxCommands = max;
    if (_commands.length > _maxCommands) {
      final excess = _commands.length - _maxCommands;
      _commands.removeRange(0, excess);
      _currentIndex = _currentIndex - excess;
      if (_currentIndex < -1) _currentIndex = -1;
      notifyListeners();
    }
  }
}

/// Composite command that bundles multiple commands as one undoable action
class CompositeCommand extends Command {
  final String _description;
  final List<Command> _commands;

  @override
  String get description => _description;

  CompositeCommand(this._description, this._commands);

  @override
  void execute() {
    for (final cmd in _commands) {
      cmd.execute();
    }
  }

  @override
  void undo() {
    for (final cmd in _commands.reversed) {
      cmd.undo();
    }
  }
}
