# 🗑️ Remove Unused Localization Keys

[![Pub Version](https://img.shields.io/pub/v/remove_unused_localizations_keys)](https://pub.dev/packages/remove_unused_localizations_keys)


[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-grey?logo=buymeacoffee&logoColor=yellow)](https://ko-fi.com/abdelrhmantolba)

**A powerful Flutter package to identify and remove unused localization keys from your project, ensuring cleaner and more efficient localization files.**

---

## 🚀 Features
✅ Scans your localization files and detects unused keys.
✅ Provides an interactive option to remove them automatically.
✅ Supports multiple language files.
✅ Keeps your project lightweight and optimized.
✅ Supports both Flutter's built-in localization and easy_localization.
✅ Handles various easy_localization patterns including `LocaleKeys`, `tr()`, and `plural()`.

---

## 📦 Installation

Add the package to `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  remove_unused_localizations_keys: latest
```

Then, fetch dependencies:

```sh
flutter pub get
```

---

## 🔧 Usage

### For Flutter's Built-in Localization
Run the following command to analyze your project:

```sh
dart run remove_unused_localizations_keys
```

### For Easy Localization
Run with the `--easy-loc` flag:

```sh
dart run remove_unused_localizations_keys --easy-loc
```

You can also specify a custom path for your translation files:

```sh
dart run remove_unused_localizations_keys --easy-loc path=assets/i18n
```

### 🛠 Advanced Options

| Option | Description |
|--------|-------------|
| `--keep-unused` | Simulates the process without deleting any keys. |
| `--easy-loc` | Enables easy_localization mode. |
| `path=` | Specifies custom path for translation files (works with `--easy-loc`). |
| `--` | Runs without requiring user confirmation. |

Examples:
```sh
# Keep unused keys in easy_localization mode
dart run remove_unused_localizations_keys --easy-loc --keep-unused

# Use custom path for translations
dart run remove_unused_localizations_keys --easy-loc path=assets/i18n
```

---

## 💡 Example Output

```
🔍 Scanning localization files...
✅ Unused keys found:
  - home.welcome_message
  - settings.dark_mode

❓ Do you want to remove these keys? (y/N)
```

---

## 📊 Accuracy Testing Methodology

We tested against three real-world Flutter projects with known unused keys:

### 🔍 Test Projects
| Project | Total Keys | Known Unused | Language Files |
|---------|------------|--------------|----------------|
| 🛒 E-commerce | 1,242 | 87 | 4 (en, ar, fr, de) |
| 📱 Social App | 3,587 | 214 | 6 (en, es, pt, ru, ja, zh) |
| 🏢 Enterprise | 8,921 | 532 | 12 (multi-region) |

---

## 🎯 Roadmap
🚀 **Upcoming Features:**
- [ ] Seamless CI/CD integration
- [ ] Auto-fix feature to replace similar keys
- [ ] Support for more localization packages

---

## 🤝 Contributing
We welcome all contributions! Feel free to submit issues, feature requests, or pull requests. 🙌

---

## 📬 Contact
📩 Need help? Reach out at [AbdelrahmanTolba@protonmail.com] or open an issue on GitHub.

---

## 📜 License
📄 This project is licensed under the **MIT License**.
