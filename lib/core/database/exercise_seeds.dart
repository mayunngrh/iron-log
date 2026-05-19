class ExerciseSeeds {
  static const List<Map<String, String>> all = [
    // ── Chest ───────────────────────────────────────────────────────────────
    {'name': 'BARBELL BENCH PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'INCLINE BENCH PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'DUMBBELL BENCH PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'INCLINE DUMBBELL PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'CABLE CROSSOVER', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    {'name': 'DUMBBELL FLY', 'category': 'HYPERTROPHY', 'muscleGroup': 'Chest', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'PUSH UP', 'category': 'STRENGTH', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    // ── Back ────────────────────────────────────────────────────────────────
    {'name': 'DEADLIFT', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'BARBELL ROW', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'PULL UP', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'LAT PULLDOWN', 'category': 'STRENGTH', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'MACHINE'},
    {'name': 'SEATED CABLE ROW', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'MACHINE'},
    {'name': 'CHEST SUPPORTED ROW', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'FACE PULL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    {'name': 'STRAIGHT ARM PULLDOWN', 'category': 'HYPERTROPHY', 'muscleGroup': 'Back', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    // ── Legs ────────────────────────────────────────────────────────────────
    {'name': 'BARBELL SQUAT', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'FRONT SQUAT', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'HACK SQUAT', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'MACHINE'},
    {'name': 'LEG PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'MACHINE'},
    {'name': 'ROMANIAN DEADLIFT', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'HIP THRUST', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'LEG CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    {'name': 'LEG EXTENSION', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    {'name': 'CALF RAISE', 'category': 'HYPERTROPHY', 'muscleGroup': 'Legs', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    {'name': 'WALKING LUNGE', 'category': 'STRENGTH', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    // ── Shoulders ───────────────────────────────────────────────────────────
    {'name': 'OVERHEAD PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'DUMBBELL SHOULDER PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'LATERAL RAISE', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'REAR DELT FLY', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'ARNOLD PRESS', 'category': 'HYPERTROPHY', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    // ── Arms ────────────────────────────────────────────────────────────────
    {'name': 'BARBELL CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'DUMBBELL CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'HAMMER CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'PREACHER CURL', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'TRICEP PUSHDOWN', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    {'name': 'SKULL CRUSHER', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'OVERHEAD TRICEP EXTENSION', 'category': 'HYPERTROPHY', 'muscleGroup': 'Arms', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'CLOSE GRIP BENCH PRESS', 'category': 'STRENGTH', 'muscleGroup': 'Arms', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    // ── Core ────────────────────────────────────────────────────────────────
    {'name': 'PLANK', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'BODYWEIGHT'},
    {'name': 'CABLE CRUNCH', 'category': 'HYPERTROPHY', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'MACHINE'},
    {'name': 'HANGING LEG RAISE', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'AB WHEEL ROLLOUT', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    {'name': 'RUSSIAN TWIST', 'category': 'STRENGTH', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'FREE_WEIGHT'},
    // ── Cardio ──────────────────────────────────────────────────────────────
    {'name': 'BURPEE', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'BOX JUMP', 'category': 'CARDIO', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'MOUNTAIN CLIMBER', 'category': 'CARDIO', 'muscleGroup': 'Core', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'KETTLEBELL SWING', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND', 'equipment': 'FREE_WEIGHT'},
    {'name': 'JUMP ROPE', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'BATTLE ROPES', 'category': 'CARDIO', 'muscleGroup': 'Full Body', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    // ── Recovery ────────────────────────────────────────────────────────────
    {'name': 'FOAM ROLLING', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY', 'equipment': 'FREE_WEIGHT'},
    {'name': 'STATIC STRETCH', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY', 'equipment': 'BODYWEIGHT'},
    {'name': 'YOGA FLOW', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY', 'equipment': 'BODYWEIGHT'},
    {'name': 'MOBILITY DRILLS', 'category': 'RECOVERY', 'muscleGroup': 'Full Body', 'type': 'RECOVERY', 'equipment': 'BODYWEIGHT'},
  ];

  static const List<Map<String, String>> bodyweightExercises = [
    // ── Bodyweight Chest ────────────────────────────────────────────────────
    {'name': 'DIAMOND PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'WIDE GRIP PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'ARCHER PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Chest', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    // ── Bodyweight Back ─────────────────────────────────────────────────────
    {'name': 'CHIN UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'WIDE GRIP PULL UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Back', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    // ── Bodyweight Legs ─────────────────────────────────────────────────────
    {'name': 'BODYWEIGHT SQUAT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'JUMP SQUAT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'LUNGES', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'JUMP LUNGES', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'GLUTE BRIDGE', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'SINGLE LEG DEADLIFT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'PISTOL SQUAT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Legs', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    // ── Bodyweight Shoulders ────────────────────────────────────────────────
    {'name': 'PIKE PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'HANDSTAND PUSH UP', 'category': 'BODYWEIGHT', 'muscleGroup': 'Shoulders', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    // ── Bodyweight Arms ─────────────────────────────────────────────────────
    {'name': 'DIPS', 'category': 'BODYWEIGHT', 'muscleGroup': 'Arms', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'BENCH DIPS', 'category': 'BODYWEIGHT', 'muscleGroup': 'Arms', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    // ── Bodyweight Core ─────────────────────────────────────────────────────
    {'name': 'SIDE PLANK', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'BODYWEIGHT'},
    {'name': 'HOLLOW BODY HOLD', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'BODYWEIGHT'},
    {'name': 'L-SIT', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'BODYWEIGHT'},
    {'name': 'DEAD BUG', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'ISOLATION', 'equipment': 'BODYWEIGHT'},
    // ── Bodyweight Full Body ────────────────────────────────────────────────
    {'name': 'BURPEE (BODYWEIGHT)', 'category': 'BODYWEIGHT', 'muscleGroup': 'Full Body', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'MOUNTAIN CLIMBER (BODYWEIGHT)', 'category': 'BODYWEIGHT', 'muscleGroup': 'Core', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'BEAR CRAWL', 'category': 'BODYWEIGHT', 'muscleGroup': 'Full Body', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
    {'name': 'JUMPING JACKS', 'category': 'BODYWEIGHT', 'muscleGroup': 'Full Body', 'type': 'COMPOUND', 'equipment': 'BODYWEIGHT'},
  ];
}
