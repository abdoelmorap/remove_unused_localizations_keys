# 🗑️ Remove Unused Localization Keys

[![Pub Version](https://img.shields.io/pub/v/remove_unused_localizations_keys)](https://pub.dev/packages/remove_unused_localizations_keys)


**A powerful Flutter package to identify and remove unused localization keys from your project, ensuring cleaner and more efficient `.arb` files.**

---

## 🚀 Features
✅ Scans your localization files and detects unused keys.
✅ Provides an interactive option to remove them automatically.
✅ Supports multiple language files.
✅ Keeps your project lightweight and optimized.

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

Run the following command to analyze your project:

```sh
dart run remove_unused_localizations_keys
```

### 🛠 Advanced Options

| Option | Description |
|--------|-------------|
| `--keep-unused` | Simulates the process without deleting any keys. |
| `--` | Runs without requiring user confirmation. |

Example:
```sh
dart run remove_unused_localizations_keys --keep-unused
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
- [ ] Support for `easy_localization`
- [ ] Seamless CI/CD integration
- [ ] Auto-fix feature to replace similar keys

---

## 🤝 Contributing
We welcome all contributions! Feel free to submit issues, feature requests, or pull requests. 🙌

---

## 📬 Contact
📩 Need help? Reach out at [AbdelrahmanTolba@protonmail.com] or open an issue on GitHub.

---

## 📜 License
📄 This project is licensed under the **MIT License**.
