class Endpoints {
  static const String baseUrl = 'https://api-staging.liftlogs.my.id';
  static const String apiVersion = 'api/v1';

  // ── Auth Endpoints ────────────────────────────────────────────────────────
  static const String signup = '$baseUrl/$apiVersion/auth/signup';
  static const String login = '$baseUrl/$apiVersion/auth/login';

  // ── Exercises Endpoints ───────────────────────────────────────────────────
  static const String exercises = '$baseUrl/$apiVersion/exercises';
  static const String exercisesGet = '$baseUrl/$apiVersion/exercises';

  // ── Users Endpoints ───────────────────────────────────────────────────────
  static const String users = '$baseUrl/$apiVersion/users';
  static const String userProfile = '$baseUrl/$apiVersion/users/profile';

  // ── Routines Endpoints ────────────────────────────────────────────────────
  static const String routines = '$baseUrl/$apiVersion/routines';
}
