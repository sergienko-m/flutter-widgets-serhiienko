#!/usr/bin/env bash
# Розбиває готовий проєкт на 12 логічних комітів.
# Запускати з кореня репозиторію ПІСЛЯ того, як analyze/test проходять.
# Перед запуском: git config user.name "Ваше Імʼя" && git config user.email "ви@example.com"
set -euo pipefail

[ -d .git ] || git init -b main

c() { # c "message" path...
  local msg="$1"; shift
  git add "$@"
  if ! git diff --cached --quiet; then git commit -m "$msg"; fi
}

c "chore: flutter project scaffold, gitignore, lints" \
  .gitignore analysis_options.yaml pubspec.yaml android ios web .metadata scripts/setup_codespaces.sh
c "feat(models): add immutable User and Product models" lib/models
c "feat(theme): add AppThemes and AppStyle ThemeExtension" lib/utils/themes.dart lib/utils/constants.dart
c "feat(widgets): add CustomButton with four styles and loading state" lib/widgets/custom_button.dart
c "feat(widgets): add responsive ProfileWidget (compact/expanded)" lib/widgets/profile_widget.dart
c "feat(state): add AppState (ChangeNotifier) and AppScope" lib/utils/app_state.dart
c "feat(widgets): add AnimatedCounter and BounceTap animations" lib/widgets/animated_counter.dart lib/widgets/bounce_tap.dart
c "feat(widgets): add ProductCard with swipe, zoom and shimmer" lib/widgets/product_card.dart lib/widgets/shimmer.dart
c "feat(screens): add home, showcase, products and profile screens; wire up main" lib/screens lib/main.dart
c "test: add widget, state and app flow tests" test integration_test
c "ci: add GitHub Pages deploy workflow" .github scripts/make_commits.sh
c "docs: add README, theory notes, architecture diagrams" README.md docs

git log --oneline
