class ExerciseSeeds {
  static const List<Map<String, String>> all = [
    // ── Chest ───────────────────────────────────────────────────────────────
    {'name': 'BARBELL BENCH PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    {'name': 'INCLINE BENCH PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    {'name': 'DUMBBELL BENCH PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    {'name': 'INCLINE DUMBBELL PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    {'name': 'CABLE CROSSOVER', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'ISOLATION'},
    {'name': 'DUMBBELL FLY', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'ISOLATION'},
    {'name': 'PUSH UP', 'category': 'STRENGTH', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    // ── Back ────────────────────────────────────────────────────────────────
    {'name': 'DEADLIFT', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    {'name': 'BARBELL ROW', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    {'name': 'PULL UP', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    {'name': 'LAT PULLDOWN', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    {'name': 'SEATED CABLE ROW', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    {'name': 'CHEST SUPPORTED ROW', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    {'name': 'FACE PULL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'ISOLATION'},
    {'name': 'STRAIGHT ARM PULLDOWN', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'ISOLATION'},
    // ── Legs ────────────────────────────────────────────────────────────────
    {'name': 'BARBELL SQUAT', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'FRONT SQUAT', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'HACK SQUAT', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'LEG PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'ROMANIAN DEADLIFT', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'HIP THRUST', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'LEG CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'ISOLATION'},
    {'name': 'LEG EXTENSION', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'ISOLATION'},
    {'name': 'CALF RAISE', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'ISOLATION'},
    {'name': 'WALKING LUNGE', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    // ── Shoulders ───────────────────────────────────────────────────────────
    {'name': 'OVERHEAD PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND'},
    {'name': 'DUMBBELL SHOULDER PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND'},
    {'name': 'LATERAL RAISE', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'ISOLATION'},
    {'name': 'REAR DELT FLY', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'ISOLATION'},
    {'name': 'ARNOLD PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND'},
    // ── Arms ────────────────────────────────────────────────────────────────
    {'name': 'BARBELL CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION'},
    {'name': 'DUMBBELL CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION'},
    {'name': 'HAMMER CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION'},
    {'name': 'PREACHER CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION'},
    {'name': 'TRICEP PUSHDOWN', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION'},
    {'name': 'SKULL CRUSHER', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION'},
    {'name': 'OVERHEAD TRICEP EXTENSION', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION'},
    {'name': 'CLOSE GRIP BENCH PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Arms', 'type': 'COMPOUND'},
    // ── Core ────────────────────────────────────────────────────────────────
    {'name': 'PLANK', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    {'name': 'CABLE CRUNCH', 'category': 'HYPERTROPHY', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    {'name': 'HANGING LEG RAISE', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'COMPOUND'},
    {'name': 'AB WHEEL ROLLOUT', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    {'name': 'RUSSIAN TWIST', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    // ── Cardio ──────────────────────────────────────────────────────────────
    {'name': 'BURPEE', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND'},
    {'name': 'BOX JUMP', 'category': 'CARDIO', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'MOUNTAIN CLIMBER', 'category': 'CARDIO', 'muscleGroup': 'Core', 'type': 'COMPOUND'},
    {'name': 'KETTLEBELL SWING', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND'},
    {'name': 'JUMP ROPE', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND'},
    {'name': 'BATTLE ROPES', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND'},
    // ── Recovery ────────────────────────────────────────────────────────────
    {'name': 'FOAM ROLLING', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY'},
    {'name': 'STATIC STRETCH', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY'},
    {'name': 'YOGA FLOW', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY'},
    {'name': 'MOBILITY DRILLS', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY'},
  ];

  static const List<Map<String, String>> bodyweightExercises = [
    // ── Bodyweight Chest ────────────────────────────────────────────────────
    {'name': 'DIAMOND PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    {'name': 'WIDE GRIP PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    {'name': 'ARCHER PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Chest', 'type': 'COMPOUND'},
    // ── Bodyweight Back ─────────────────────────────────────────────────────
    {'name': 'CHIN UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    {'name': 'WIDE GRIP PULL UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Back', 'type': 'COMPOUND'},
    // ── Bodyweight Legs ─────────────────────────────────────────────────────
    {'name': 'BODYWEIGHT SQUAT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'JUMP SQUAT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'LUNGES', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'JUMP LUNGES', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'GLUTE BRIDGE', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'SINGLE LEG DEADLIFT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    {'name': 'PISTOL SQUAT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND'},
    // ── Bodyweight Shoulders ────────────────────────────────────────────────
    {'name': 'PIKE PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND'},
    {'name': 'HANDSTAND PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND'},
    // ── Bodyweight Arms ─────────────────────────────────────────────────────
    {'name': 'DIPS', 'category': 'BODYWEIGHT', 'muscleGroup': 'Arms', 'type': 'COMPOUND'},
    {'name': 'BENCH DIPS', 'category': 'BODYWEIGHT', 'muscleGroup': 'Arms', 'type': 'COMPOUND'},
    // ── Bodyweight Core ─────────────────────────────────────────────────────
    {'name': 'SIDE PLANK', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    {'name': 'HOLLOW BODY HOLD', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    {'name': 'L-SIT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    {'name': 'DEAD BUG', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION'},
    // ── Bodyweight Full Body ────────────────────────────────────────────────
    {'name': 'BURPEE (BODYWEIGHT)', 'category': 'BODYWEIGHT', 'muscleGroup': 'Full Body', 'type': 'COMPOUND'},
    {'name': 'MOUNTAIN CLIMBER (BODYWEIGHT)', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'COMPOUND'},
    {'name': 'BEAR CRAWL', 'category': 'BODYWEIGHT', 'muscleGroup': 'Full Body', 'type': 'COMPOUND'},
    {'name': 'JUMPING JACKS', 'category': 'BODYWEIGHT', 'muscleGroup': 'Full Body', 'type': 'COMPOUND'},
  ];
}
