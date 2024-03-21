import 'package:flutter/foundation.dart';

class SelectionMode with ChangeNotifier {
  bool _selectionMode = false; // Selection mode ON or OFF
  final List<int> _selectedNoteIDs = [];

  List<int> get selectedNoteIDs => _selectedNoteIDs;
  bool get selectionMode => _selectionMode;

  void turnOnSelectionMode() {
    _selectionMode = true;
    notifyListeners();
  }

  void turnOffSelectionMode() {
    _selectionMode = false;
    _selectedNoteIDs.clear();
    notifyListeners();
  }

  void toggleSelection(int noteId) {
    if (_selectedNoteIDs.contains(noteId)) {
      _selectedNoteIDs.remove(noteId);
    } else {
      _selectedNoteIDs.add(noteId);
    }

    if (_selectedNoteIDs.isEmpty) {
      turnOffSelectionMode();
    }

    notifyListeners();
  }

  bool isSelected(int noteId) {
    if (_selectedNoteIDs.contains(noteId)) {
      return true;
    } else {
      return false;
    }
  }
}
