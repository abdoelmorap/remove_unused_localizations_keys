## 0.0.1 - Initial Release
- 🎉 First version of `remove_unused_localizations_keys`.
- 🛠 Automatically detects and removes unused localization keys.
- 🚀 Supports all `.arb` files dynamically.
- 🔍 Excludes important localization files to prevent accidental deletions.
- 📊 Provides detailed output on removed keys.

## 0.0.2 
- 🎉 Add new feature & Handle more cases like
  localizations.welcome
  S.of(context).welcome
  AppLocalizations.of(context)!.welcome
  _appLocalizations.key
  cubit.appLocalizations.key
  SomeClass.someVariable.appLocalizations.key
  Localizations.of(context) Access
  Localizations.of(context)!.key
  Localizations.of(context)?.key
  Localizations.of(AppNavigation.context)!.key
  Localizations.of(this.context)!.key
  Localizations.of(BuildContext ctx)!.key

## 0.0.3 
- 🎉 Add new feature catch yaml file.


## 0.0.4 - Fixes for Initial Release
- 🎉 Speed Up Package & Remove any unused dev dependencies .