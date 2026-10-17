# Журнал взаємодії з AI

Інструмент: **GitHub Copilot** (VS Code 1.137, Agent mode). Модель вказується для кожного запиту.

Для кожного запиту фіксується: що просили, що згенеровано, що перевірено вручну, які були помилки і яке рішення прийнято.
Секрети, токени та паролі в запити не передаються.

| № | Дата | Що генерувалось | Результат |
|---|---|---|---|
| 1 | 17.10.2026 | manifest `build-engineer.agent.md` | прийнято, знайдено 2 пропуски |
| 2 | 17.10.2026 | виправлення manifest | пропуски усунено через AI |
| 3 | 17.10.2026 | skill `project-scaffold` | прийнято без змін |

---

## #1 — Manifest агента

- **Дата:** 17.10.2026
- **Модель:** GPT-6 Luna (Auto)
- **Запит:** згенерувати `.github/agents/build-engineer.agent.md` на основі `docs/architecture.md`.
- **Результат:** Copilot прочитав `README.md` і `docs/architecture.md`, перевірив, що файл ще не існує,
  і створив лише його (63 рядки). Окремо пояснив, що гілки `develop`/`master` у параметрах — це тригери CI,
  а заборона роботи на цих гілках — правило для самого агента.
- **Ручна перевірка:**
  - [x] є frontmatter (`description`, `tools`)
  - [x] є розділи: Role, Scope, Project parameters, Skills, Commands, File rules, Forbidden actions, Working procedure, Completion criteria
  - [x] заборонено force push, видалення файлів, секрети, коміт `build/` і `dist/`
  - [x] критерії завершення включають тест `BasicAddition`, 3 ОС у CI і `RESULT: PASS`
  - [x] створено лише один файл
- **Помилки / виправлення:** знайдено 2 пропуски:
  1. не заборонено агенту самостійно робити `git commit` / `git push` (за методичкою коміти робить студент після перегляду);
  2. у Working procedure немає кроку звіту про створені/змінені файли.
- **Рішення:** виправити через AI, а не вручну (методичка, етап 4, п. 3) → запис #2.

<details><summary>Текст промпту</summary>

```
Read README.md and docs/architecture.md first. They define the design of an AI build agent
for a cross-platform C++ Hello World project (CMake, GoogleTest via FetchContent, CTest,
GitHub Actions on ubuntu/windows/macos).

Create ONE file: .github/agents/build-engineer.agent.md (VS Code custom agent format).
Do not create any other files.

Frontmatter:
- description: one sentence describing the agent
- tools: ['execute', 'read', 'edit', 'search', 'todo']

Body sections (in English, use exactly these headings):
1. Role
2. Scope of responsibility (in scope / out of scope)
3. Project parameters - table with: project_name=hello, language=C++, cxx_standard=17,
   build_dir=build, dist_dir=dist, build_type=Release, test_name=HelloTest.BasicAddition,
   branches=develop,master, os_matrix=ubuntu-latest,windows-latest,macos-latest
4. Skills it uses - project-scaffold, build-and-test, github-actions with paths
   .github/skills/<name>/SKILL.md
5. Commands it supports - git-init, create-project, create-build, create-actions, check, init
   with paths .github/prompts/<name>.prompt.md; state that init is the orchestrator and the
   order in which it runs the others
6. File rules - create only missing files, update existing files minimally, never silently
   overwrite user changes, never duplicate config, all generated text in English,
   ci.yml may only call ci.sh / ci.bat, ci.sh uses LF and ci.bat uses CRLF
7. Forbidden actions - deleting project files, git push --force, rewriting git history,
   changing branch protection, printing or storing secrets/tokens, committing build/, dist/
   or other generated artifacts, running on develop/master/main branches
8. Working procedure - check preconditions, run step, verify result immediately,
   stop at first failure with "FAILED STEP: <step> - <reason>", never report success
   without a passing check
9. Completion criteria - all required files exist, CMake configures and builds in Release,
   ctest passes including HelloTest.BasicAddition, dist/bin/hello (hello.exe on Windows)
   prints exactly "Hello, World!", workflow covers 3 OS, build/ and dist/ are not tracked,
   check reports RESULT: PASS

Keep it concise and unambiguous. After creating the file, list each section and explain
in one line why it is needed.
```

</details>

---

## #2 — Виправлення manifest

- **Дата:** 17.10.2026
- **Модель:** GPT-6 Luna (Auto)
- **Запит:** мінімально доповнити manifest двома правилами, не змінюючи інших розділів.
- **Результат:** змінено лише `build-engineer.agent.md`:
  - Forbidden actions: `Do not run git commit, git push or create branches; the user reviews and commits all changes.`
  - Working procedure: `Report which files were created or updated and the verification result of each step.`
- **Ручна перевірка:**
  - [x] обидва рядки в потрібних розділах (рядки 51 і 58)
  - [x] інші розділи не змінені
- **Перевірка ідемпотентності:** той самий запит випадково надіслано повторно — Copilot відповів, що обидва
  рядки вже присутні, і не вніс змін. Це відповідає правилу manifest «не дублювати конфігурацію».
- **Рішення:** manifest прийнято, коміт `agent: add build-engineer manifest`.

<details><summary>Текст промпту</summary>

```
Update .github/agents/build-engineer.agent.md minimally, do not change other sections:
1. In "Forbidden actions" add: "Do not run git commit, git push or create branches; the user reviews and commits all changes."
2. In "Working procedure" add as the last item: "Report which files were created or updated and the verification result of each step."
```

</details>

---

## #3 — Skill `project-scaffold`

- **Дата:** 17.10.2026
- **Модель:** GPT-6 Luna (Auto)
- **Запит:** згенерувати `.github/skills/project-scaffold/SKILL.md` з точним вмістом вихідних файлів,
  правилами для `.gitignore` і перевіркою README.
- **Результат:** створено лише skill-файл. Містить точний код `src/hello.h`, `src/hello.cpp`, `src/main.cpp`,
  список записів `.gitignore` (single source of truth для `git-init`), перевірку розділів README
  та smoke check через `c++`. Smoke check під час генерації не запускався — skill лише описує дії.
- **Ручна перевірка:**
  - [x] frontmatter `name` + `description` («Use when ...»)
  - [x] усі 9 розділів (Purpose … Failure scenarios)
  - [x] код збігається з еталонним прототипом, який збирається і проходить `HelloTest.BasicAddition`
  - [x] існуючі файли не перезаписуються, `.gitignore` лише доповнюється, README не переписується
- **Що Copilot додав понад запит:** перевірку розбіжностей для всіх вихідних файлів (не лише `main.cpp`),
  англомовні шаблони для відсутніх розділів README, зупинку при параметрах, відмінних від `hello`/C++.
- **Зауваження:** порожня тека `tests/` не відстежується Git; не критично, бо наступний крок
  (`create-build`) створює в ній `test_basic.cpp`.
- **Рішення:** прийнято без змін.

<details><summary>Текст промпту</summary>

```
Create ONE file: .github/skills/project-scaffold/SKILL.md (VS Code agent skill format).
Follow .github/agents/build-engineer.agent.md and docs/architecture.md. Do not create other files.

Frontmatter: name: project-scaffold, description starting with "Use when ...".

Sections (English): Purpose, When to use, Inputs, Steps, Idempotency, Outputs,
Verification, Example input and expected result, Failure scenarios and handling.

Inputs: language (default C++), project_name (default hello).

Steps must contain the EXACT content of each file in fenced code blocks:
1. src/hello.h - namespace hello with: int add(int a, int b); std::string greeting();
2. src/hello.cpp - add returns a + b, greeting returns "Hello, World!"
3. src/main.cpp - prints hello::greeting() followed by a newline, returns 0
4. tests/ directory (test files are created later by the build-and-test skill)
5. .gitignore - list of required entries: build/, dist/, cmake-build-*/, .cache/,
   CMakeUserPresets.json, *.log, .env, .DS_Store. Append only missing entries,
   never remove or reorder existing ones. This list is the single source of truth;
   the git-init command will reuse it.
6. README.md - already exists. Only verify it has sections about running the agent,
   building/running the project and project structure (headings may be in Ukrainian:
   "Як запустити агента", "Як зібрати та запустити проєкт", "Структура").
   Append a missing section only if absent; never rewrite existing text.

Verification: files exist; on Linux/macOS compile a smoke check:
c++ -std=c++17 -Isrc src/main.cpp src/hello.cpp -o build/scaffold-check
and confirm ./build/scaffold-check prints exactly "Hello, World!".
On Windows skip the smoke check (full build is done by build-and-test).

Failure scenarios: compiler not found; src/main.cpp already exists with different
content (do not overwrite, report the difference); README missing.

After creating the file, summarize what it does in 3 lines.
```

</details>
