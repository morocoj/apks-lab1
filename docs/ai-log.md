# Журнал взаємодії з AI

Інструмент: **GitHub Copilot** (VS Code, Agent mode). Модель вказується для кожного запиту.

Для кожного запиту фіксується: що просили, що згенеровано, що перевірено вручну, які були помилки і яке рішення прийнято.
Секрети, токени та паролі в запити не передаються.

---

## #1 — Manifest агента

- **Дата:**
- **Модель:**
- **Запит:** згенерувати `.github/agents/build-engineer.agent.md` на основі `docs/architecture.md`
  (повний текст промпту — нижче).
- **Результат:**
- **Ручна перевірка:**
  - [ ] є frontmatter (`description`, `tools`)
  - [ ] є розділи: Role, Scope, Skills, Commands, File rules, Forbidden actions, Working procedure, Completion criteria
  - [ ] заборонено force push, видалення файлів, секрети, коміт `build/` і `dist/`
  - [ ] критерії завершення включають тест `BasicAddition` і 3 ОС у CI
- **Помилки / виправлення:**
- **Рішення:**

<details><summary>Текст промпту</summary>

```
(вставити)
```

</details>
