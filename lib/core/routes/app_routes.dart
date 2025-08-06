class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String signin = '/signin';
  static const String dashboard = '/dashboard';

  static final List<String> protectedRoutes = [dashboard];
}
