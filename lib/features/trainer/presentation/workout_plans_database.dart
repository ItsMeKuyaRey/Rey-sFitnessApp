// lib/features/trainer/presentation/workout_plans_database.dart
// FINAL GOD-TIER VERSION — HAS EVERYTHING — NO MORE ERRORS

import 'package:flutter/material.dart';

class Exercise {
  String name;
  String sets;
  String reps;
  String rest;
  String? notes;

  Exercise({
    required this.name,
    this.sets = "3",
    this.reps = "10",
    this.rest = "60s",
    this.notes,
  });

  // Deep copy
  Exercise copyWith({
    String? name,
    String? sets,
    String? reps,
    String? rest,
    String? notes,
  }) {
    return Exercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      rest: rest ?? this.rest,
      notes: notes ?? this.notes,
    );
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] as String,
      sets: map['sets'] as String,
      reps: map['reps'] as String,
      rest: map['rest'] as String? ?? "90s",
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Exercise &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              sets == other.sets &&
              reps == other.reps &&
              rest == other.rest;

  @override
  int get hashCode => Object.hash(name, sets, reps, rest);
}

class Day {
  String name;                    // ← REMOVED final
  List<Exercise> exercises;      // ← REMOVED final

  Day({required this.name, required this.exercises});

  factory Day.fromMap(Map<String, dynamic> map) {
    return Day(
      name: map['name'] as String,
      exercises: (map['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }
}

class Week {
  int number;                     // ← REMOVED final
  List<Day> days;                 // ← REMOVED final

  Week({required this.number, required this.days});

  factory Week.fromMap(Map<String, dynamic> map) {
    return Week(
      number: map['number'] as int,
      days: (map['days'] as List<dynamic>)
          .map((d) => Day.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'days': days.map((d) => d.toMap()).toList(),
    };
  }
}

class WorkoutPlan {
  final String id;
  final String title;
  final String duration;
  int usersCount;
  final List<String> assignedTo;
  final String imagePath;
  final List<Week> weeks;

  WorkoutPlan({
    required this.id,
    required this.title,
    required this.duration,
    required this.usersCount,
    required this.assignedTo,
    required this.imagePath,
    required this.weeks,
  });

  // THIS WAS MISSING — NOW FIXED
  Map<String, dynamic> toDisplayMap(Color color) => {
    "id": id,
    "title": title,
    "duration": duration,
    "users": usersCount,
    "assignedTo": assignedTo,
    "image": imagePath,
    "color": color,
  };
}

class WorkoutPlansDatabase extends ChangeNotifier {
  static final WorkoutPlansDatabase instance = WorkoutPlansDatabase._internal();
  factory WorkoutPlansDatabase() => instance;
  WorkoutPlansDatabase._internal();

  final List<WorkoutPlan> _plans = [
    WorkoutPlan(
      id: "1",
      title: "Full Body Strength",
      duration: "8 weeks",
      usersCount: 15,
      assignedTo: ["Emma Wilson", "James Carter"],
      imagePath: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800",
      weeks: [],
    ),
    WorkoutPlan(
      id: "2",
      title: "Cardio Blast",
      duration: "6 weeks",
      usersCount: 41,
      assignedTo: ["Sophia Martinez", "Olivia Davis", "Noah Garcia"],
      imagePath: "https://picsum.photos/seed/exercise123/800/600",
      weeks: [],
    ),
  ];

  List<WorkoutPlan> get plans => _plans;

  void addPlan(WorkoutPlan plan) {
    _plans.insert(0, plan);
    notifyListeners();
  }

  void updatePlan(String id, WorkoutPlan updatedPlan) {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index != -1) {
      _plans[index] = updatedPlan;
      notifyListeners();
    }
  }

  WorkoutPlan? getPlanById(String id) {
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void deletePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}