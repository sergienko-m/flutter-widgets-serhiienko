# flutter-widgets-serhiienko

**Автор:** Сергієнко Максим (Maksym Serhiienko)

Практична робота 5 «Розробка віджетів у Flutter» (Програмування для мобільних платформ).
Застосунок демонструє власні Stateless/Stateful віджети, анімації, простий state management
(`ChangeNotifier` + `InheritedNotifier`), адаптивну верстку, тести та деплой.

**Live demo:** https://sergienko-m.github.io/flutter-widgets-serhiienko/

**APK:** https://github.com/sergienko-m/flutter-widgets-serhiienko/releases/latest  
**Покриття тестами:** [docs/COVERAGE.md](docs/COVERAGE.md)  
**Діаграми архітектури:** [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) (Mermaid, рендеряться на GitHub)

## Запуск

Потрібно: Flutter SDK ≥ 3.16.0, Dart ≥ 3.0.

**GitHub Codespaces / новий клон:**

```bash
bash scripts/setup_codespaces.sh      # ставить Flutter, додає android/ios/web
flutter analyze
flutter test --coverage               # coverage/lcov.info
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0   # відкрити порт 8080
```

**Локально:**

```bash
flutter pub get
flutter run -d chrome                 # або -d <android/ios пристрій>
flutter test integration_test         # потрібен пристрій / Chrome
flutter build web --release           # build/web
flutter build apk --release           # build/app/outputs/flutter-apk/app-release.apk
```

Деплой на GitHub Pages: Settings → Pages → Source: **GitHub Actions**, потім push у `main`
(workflow `.github/workflows/deploy.yml` виконує analyze, test і build web).

## Реалізовані віджети

| Віджет | Тип | Що демонструє |
|---|---|---|
| `CustomButton` | Stateless | 4 стилі, іконка, `isLoading`, стилізація через `Theme` |
| `ProfileWidget` | Stateless | compact / expanded, `LayoutBuilder`, `ThemeExtension` |
| `AnimatedCounter` | Stateful | scale, зміна кольору на max, bounce кнопок, плавний progress, lifecycle |
| `ProductCard` | Stateful | swipe-to-favorite, tap-анімації, zoom зображення, shimmer |
| `BounceTap`, `ShimmerBox`, `ProductArt` | допоміжні | пружинний ефект, skeleton-завантаження, зображення/плейсхолдер |

Екрани: `HomeScreen` (адаптивна навігація), `ShowcaseScreen` (бібліотека компонентів з інтерактивними
контролами), `ProductsScreen` (`CustomScrollView`, `SliverGrid`/`SliverList`), `ProfileScreen`.

## Структура

```
lib/
├── main.dart
├── screens/   home_screen, showcase_screen, products_screen, profile_screen
├── widgets/   custom_button, profile_widget, animated_counter, product_card, bounce_tap, shimmer
├── models/    user, product
└── utils/     app_state, constants, themes
test/          widgets/*, state/*, app_flow_test.dart
integration_test/app_test.dart
docs/          THEORY.md, ARCHITECTURE.md, SUBMISSION_CHECKLIST.md
scripts/       setup_codespaces.sh, make_commits.sh
```

## Документація

* [Теорія (Stateless/Stateful, layout, списки, Material, Cupertino, lifecycle)](docs/THEORY.md)
* [Архітектура, діаграми, state flow, API contract](docs/ARCHITECTURE.md)

---

## 🤖 Декларація використання ШІ

* **Інструмент ШІ:** Claude (Anthropic).
* **Мета використання:** згенерувати початковий каркас проєкту за завданням практичної роботи 5:
  код віджетів, екранів, `AppState`, тестів, CI-конфігурації та чернетки документації
  (`docs/THEORY.md`, `docs/ARCHITECTURE.md`), а також скрипти для налаштування Codespaces,
  розбиття на коміти й формування звіту покриття.
* **Текстовий запит (промпт):** _«[додана PDF практичної роботи 5] Stateless vs Stateful віджети:
  відмінності та використання. Layout віджети: Container, Row, Column, Stack, Positioned. Списки:
  ListView, GridView, CustomScrollView. Material Design компоненти: AppBar, Scaffold, Button, Card,
  Dialog. Cupertino (iOS-style) віджети. Створення власних custom віджетів. Lifecycle методи віджетів.
  виконай це завдання повністю правильно»_ та подальші уточнювальні запити щодо налаштування
  репозиторію, Codespaces, GitHub Pages і збірки APK.
* **Які фрагменти увійшли до роботи:** увесь код у `lib/`, тести в `test/` та `integration_test/`,
  документація в `docs/`, скрипти в `scripts/` і workflow в `.github/workflows/` згенеровані ШІ;
  логіку віджетів, екранів і тестів використано без змін.
* **Власне доопрацювання:**
  * створив публічний репозиторій, налаштував GitHub Codespaces і встановив Flutter SDK;
  * запустив `flutter analyze` (No issues found) та `flutter test` (34 тести пройдено);
  * розклав проєкт на логічні коміти та відправив їх на GitHub;
  * налаштував GitHub Pages (Source: GitHub Actions), перевірив збірку й деплой, додав посилання на демо;
  * сформував звіт покриття тестами та зібрав APK через GitHub Actions;
  * вказав автора та посилання в README.
