# APKS Lab 1 — AI build agent (C++ / CMake / GoogleTest)

| | |
|---|---|
| **Студент** | Гнатишин Богдан Степанович |
| **Група** | КІ-405 |
| **Варіант** | 1 (номер у списку — 7): C++ / CMake / GoogleTest + CTest |
| **AI-інструмент** | GitHub Copilot (VS Code, agent mode) |

## Опис проєкту

Репозиторій містить AI-агента `build-engineer` для GitHub Copilot. Агент генерує, складає, тестує і перевіряє
мінімальний кросплатформний проєкт **Hello World на C++**:

- вихідний код `hello` + функція `add()` для юніт-тесту;
- система складання **CMake**;
- юніт-тест **GoogleTest** `HelloTest.BasicAddition`, запуск через **CTest**;
- скрипти збірки `ci.sh` (Linux/macOS) і `ci.bat` (Windows);
- GitHub Actions workflow з матрицею **ubuntu / windows / macos**.

Детальна архітектура агента — у [docs/architecture.md](docs/architecture.md),
точні команди запуску — у [docs/usage.md](docs/usage.md).

## Гілки

| Гілка | Вміст |
|---|---|
| `develop` | лише AI-агент: manifest, skills, commands, документація |
| `feature/lab1` | повний результат запуску агента: код, тести, CMake, CI |
| `master` | фінальний результат після перевірки та злиття |

## Як запустити агента

Передумови: VS Code, розширення GitHub Copilot (активний план), CMake ≥ 3.20, C++ компілятор, Git.

1. Клонувати репозиторій і перейти на робочу гілку (агент не працює на `develop`/`master`):
   ```bash
   git switch develop
   git switch -c feature/lab1
   ```
2. Відкрити папку у VS Code → Copilot Chat → режим **Agent** → обрати агента **build-engineer**.
3. Запустити orchestrator-команду:
   ```
   /init
   ```
4. Окремі операції: `/git-init`, `/create-project`, `/create-build`, `/create-actions`, `/check`.

## Як зібрати та запустити проєкт

```bash
# Linux / macOS
./ci.sh            # configure → build → test → install → run
./dist/bin/hello   # Hello, World!
```

```bat
:: Windows
ci.bat
dist\bin\hello.exe
```

## Структура

```
.github/
  agents/build-engineer.agent.md      # manifest агента
  skills/<name>/SKILL.md              # 3 skills
  prompts/*.prompt.md                 # 6 commands, init — orchestrator
  workflows/ci.yml                    # CI (лише викликає ci.sh / ci.bat)
src/                                  # вихідний код
tests/                                # GoogleTest
docs/                                 # architecture.md, usage.md, ai-log.md
CMakeLists.txt
ci.sh, ci.bat
```
