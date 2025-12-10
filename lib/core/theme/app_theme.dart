enum AppTheme {
  light,
  dark,
  halloween,
  christmas,
  summer,
  winter,
}

extension AppThemeExtension on AppTheme {
  String get name {
    switch (this) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.halloween:
        return 'Halloween';
      case AppTheme.christmas:
        return 'Christmas';
      case AppTheme.summer:
        return 'Summer';
      case AppTheme.winter:
        return 'Winter';
    }
  }
}
