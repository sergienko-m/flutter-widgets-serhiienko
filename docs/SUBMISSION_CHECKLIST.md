# Чекліст здачі (те, що код не зробить за вас)

## Перед комітами
- [ ] `flutter create mobile_widgets_app`, скопіювати файли, видалити `test/widget_test.dart`
- [ ] `flutter pub get && flutter analyze && flutter test` — усе зелене
- [ ] Запустити на Chrome та Android/iOS-емуляторі, пройти всі екрани
- [ ] Прочитати **кожен** файл і зрозуміти його — на захисті буде live-зміна функціоналу

## GitHub (≥ 10 осмислених комітів, репозиторій `flutter-widgets-<прізвище>`)
```
1. chore: flutter create, gitignore, analysis_options
2. feat(models): User, Product
3. feat(theme): AppThemes + AppStyle ThemeExtension
4. feat(widgets): CustomButton (4 стилі, loading)
5. feat(widgets): ProfileWidget (compact/expanded)
6. feat(state): AppState + AppScope
7. feat(widgets): AnimatedCounter + BounceTap
8. feat(widgets): ProductCard (swipe, zoom, shimmer)
9. feat(screens): Home, Products, Profile, Showcase
10. test: widget + state + flow tests
11. ci: GitHub Pages workflow
12. docs: README, THEORY, ARCHITECTURE
```
Комітьте поетапно у міру того, як реально працюєте, а не всі разом в кінці.

## Deliverables
- [ ] **DEL-1** GitHub-репозиторій + README зі скріншотами та AI-декларацією
- [ ] **DEL-2** Live demo: Settings → Pages → Source: GitHub Actions (workflow вже в `.github/workflows/deploy.yml`)
- [ ] **DEL-3** Figma: фрейми кнопок (4 стилі), профілю (2 режими), лічильника, картки; color styles з `AppThemes.seed = #3F51B5`
- [ ] **DEL-4** Відео 2–3 хв: анімації, swipe, zoom, shimmer, адаптивність (змінити ширину вікна), DevTools Performance (60 FPS)
- [ ] **DEL-5** draw.io / Miro: вставити Mermaid-діаграми з `docs/ARCHITECTURE.md`, зробити публічне посилання
- [ ] APK: `flutter build apk --release` → Google Drive (доступ за посиланням)
- [ ] Coverage: `flutter test --coverage` → скріншот/звіт (`genhtml coverage/lcov.info -o coverage/html`)

## Бонуси (за бажанням)
- Accessibility: `Semantics` уже є в аватарі/лічильнику; додайте перевірку `tester.ensureSemantics()` і контраст.
- Custom paint: напр. кільцевий progress у `AnimatedCounter` через `CustomPainter`.
- Performance: `const`-конструктори, `RepaintBoundary` навколо shimmer, скріншот DevTools.

## Підготовка до захисту
Будьте готові пояснити: чому `AppScope` — `InheritedNotifier`; чому `ProductCard` — Stateful;
що відбувається в `didUpdateWidget`; навіщо `TickerMode` в `IndexedStack`; чому колекції в `AppState`
оновлюються через нові копії.
