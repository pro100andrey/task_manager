# Техническое задание: TM HTM — Hierarchical Adaptive Task Manager

**Версия документа**: v1
**Дата**: 02 мая 2026  

---

## Архитектурное обоснование

Это **гибридная система управления задачами**, сочетающая строгую иерархию, адаптивное планирование и защиту от типичных проблем LLM-агентов.

Система является **надстройкой** над классическим DAG-подходом v2.0, а не его заменой. Поддерживает как строгие технические пайплайны (через strong links), так и исследовательские, творческие и agentic workflow.

### Ключевые улучшения по сравнению с предыдущими версиями

| Проблема предыдущих версий | Решение |
| --- | --- |
| Инверсия приоритетов в глубоком дереве | HBP с Hard Cap + разделение BV и US |
| Partial updates при replan | Полностью атомарный `task_replan` (All-or-Nothing) |
| Риск бесконечного планирования | PNR Guardrail + `last_action_type` + `plan_version` |
| Ручное поддержание `depth` | Динамический расчёт через Recursive CTE |
| Сложность Knowledge Graph | Упрощённый + `kg_auto_bridge` |
| Отсутствие защиты от stalled задач | Staleness Score с визуализацией |

---

## 1. Назначение системы

**TM HTM** — инструмент для управления задачами как людьми, так и LLM-агентами. Поддерживает два режима работы:

- **Strict DAG mode** — для технических пайплайнов и CI/CD
- **Adaptive Hierarchical mode** — для исследовательских, продуктовых и agentic процессов

Режимы интерфейса: CLI, TUI, MCP (JSON-RPC 2.0 over stdio/HTTP).

---

## 2. Ключевые принципы

1. **Иерархия первична** — дерево задач (`parent_id`) является основной структурой организации.
2. **Strong + Soft links** — сильные связи блокируют выполнение, мягкие — передают контекст.
3. **Два измерения приоритета**: Business Value (стратегическая важность) и Urgency Score (тактическая срочность).
4. **Hard Cap** — ни одна подзадача не может быть важнее своей родительской ветки.
5. **Встроенная защита от деградации** — guardrails против бесконечной рефлексии и планирования без исполнения.
6. **Knowledge как вспомогательный граф** — не перегружаем систему, но обеспечиваем автоматические связи через `kg_auto_bridge`.
7. **Active Front** — вместо одной следующей задачи система возвращает приоритизированный фронт работы.

---

## 3. Модель данных

### 3.1 Task

| Поле | Тип | Обязательно | Описание |
| --- | --- | --- | --- |
| `id` | UUIDv7 | да | Время-сортируемый идентификатор |
| `parent_id` | UUIDv7 / null | нет | Один родитель — строгое дерево (`null` = корневая) |
| `alias` | string | нет | Уникальный в проекте (`^[a-z0-9_-]+$`) |
| `normalized_alias` | string | да | Нормализованный slug для поиска |
| `title` | string | да | Непустое название |
| `description` | string | нет | Подробное описание |
| `status` | enum | да | Core-статус (см. §3.2) |
| `status_reason` | string | нет | Причина текущего статуса |
| `context_state` | enum | да | Контекстное состояние (см. §3.3), по умолчанию `active` |
| `completion_policy` | enum | да | Политика завершения (см. §3.4), по умолчанию `all_children` |
| `business_value` | integer (0–100) | да | Стратегическая важность (BV), по умолчанию `50` |
| `urgency_score` | integer (0–100) | да | Тактическая срочность (US), по умолчанию `50` |
| `estimated_effort` | float | нет | Оценка в человеко-часах |
| `due_date` | datetime | нет | Срок выполнения (UTC) |
| `tags` | JSON array | нет | Массив строковых тегов |
| `assigned_to` | string | нет | Исполнитель |
| `metadata` | JSON object | нет | Расширенные данные для агентов |
| `plan_version` | integer | да | Инкрементируется при `task_replan`, по умолчанию `0` |
| `last_action_type` | enum | да | `execution`, `planning`, `reflection`, `review`, по умолчанию `execution` |
| `last_progress_at` | datetime | да | UTC — дата последнего реального прогресса (завершение задачи) |
| `created_at` | datetime | да | UTC |
| `updated_at` | datetime | да | UTC |
| `completed_at` | datetime | нет | Дата завершения |

**Вычисляемые поля (не хранятся в БД):**

| Поле | Описание |
| --- | --- |
| `effective_priority` (EP) | HBP — рассчитывается через Recursive CTE (§4.1) |
| `depth` | Глубина в иерархии — динамически из Recursive CTE |
| `staleness_score` | Штраф за простой — рассчитывается по формуле (§4.3) |
| `blocked` | `pending` + незавершённые strong-зависимости |
| `waiting_children` | `pending` + незавершённые дочерние задачи (по `completion_policy`) |

### 3.2 Core-статусы (хранятся в БД)

| Статус | Маркер | Описание |
| --- | --- | --- |
| `pending` | `○` | Ждёт выполнения |
| `in_progress` | `⟳` | Выполняется |
| `completed` | `✓` | Завершена |
| `failed` | `✗` | Завершена с ошибкой |
| `cancelled` | `⊘` | Отменена |
| `on_hold` | `⏸` | Приостановлена |

### 3.3 Context State (контекстное состояние)

Ортогонально статусу выполнения. Отвечает на вопрос "в каком фокусе находится задача".

| Контекст | Маркер | Описание |
| --- | --- | --- |
| `active` | `●` | В текущем фокусе работы |
| `backlog` | `○` | Запланирована, но не в фокусе |
| `in_review` | `◑` | Ждёт проверки/подтверждения |
| `archived` | `◌` | Скрыта из основного представления |

> `context_state` не блокирует выполнение. Задача в `backlog` может быть выполнена при отсутствии strong-блокировок. Однако задачи с `context_state = backlog | archived` **не входят** в Active Front.

### 3.4 Completion Policy (политика завершения)

Применяется к задачам с дочерними. Определяет, когда `isCompletable(T)` возвращает `true`.

| Политика | Условие завершаемости |
| --- | --- |
| `all_children` | Все дочерние `completed` |
| `any_child` | Хотя бы одна дочерняя `completed` |
| `manual` | Всегда завершаема явной командой |

### 3.5 TaskLink (связь между задачами)

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | UUIDv7 | PK |
| `from_task_id` | UUIDv7 | FK → tasks.id (ON DELETE CASCADE) |
| `to_task_id` | UUIDv7 | FK → tasks.id (ON DELETE CASCADE) |
| `link_type` | enum | `strong` или `soft` |
| `label` | string | нет - Описание (например "informs", "relates") |
| `created_at` | datetime | UTC |

Составной уникальный ключ: `(from_task_id, to_task_id, link_type)`.  
CHECK: `from_task_id != to_task_id`.

**Семантика:**

| Тип | Блокирует | Цикл | Топосортировка |
| --- | --- | --- | --- |
| `strong` | да | ошибка | включается |
| `soft` | нет | разрешён | не включается |

### 3.6 Knowledge Entity

Упрощённая модель. Автономная именованная концепция.

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | UUIDv7 | PK |
| `name` | string | Уникальное имя в проекте |
| `normalized_name` | string | Нормализованный slug (UNIQUE) |
| `entity_type` | string | `fact`, `decision`, `assumption`, `risk`, `resource`, `concept`, `tool` |
| `content` | string | Содержимое |
| `metadata` | JSON object | Расширенные данные |
| `created_at` | datetime | UTC |
| `updated_at` | datetime | UTC |

### 3.7 Task Knowledge Ref

| Поле | Тип | Описание |
| --- | --- | --- |
| `task_id` | UUIDv7 | FK → tasks.id |
| `entity_id` | UUIDv7 | FK → knowledge_entities.id |
| `ref_type` | enum | `produces`, `consumes`, `updates`, `blocks` |

PK: `(task_id, entity_id, ref_type)`.

> `kg_auto_bridge`: при регистрации пары (task A `produces` X) + (task B `consumes` X) система автоматически создаёт **soft link** A → B, если его ещё нет.

### 3.8 Reflection

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | UUIDv7 | PK |
| `task_id` | UUIDv7 / null | FK → tasks.id ON DELETE SET NULL |
| `content` | string | Текст наблюдения/вывода |
| `reflection_type` | enum | `observation`, `decision`, `blocker`, `insight`, `replan_trigger` |
| `triggered_replan` | boolean | Была ли создана задача переосмысления |
| `reflection_budget` | integer | Максимум итераций рефлексии (по умолчанию `3`) |
| `created_at` | datetime | UTC |
| `source` | enum | `cli`, `tui`, `mcp` |

### 3.9 TaskHistory (Audit Trail)

Фиксирует каждое изменение задачи.

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | UUIDv7 | PK |
| `task_id` | UUIDv7 | FK → tasks.id |
| `field_changed` | string | Имя изменённого поля |
| `old_value` | JSON | Старое значение |
| `new_value` | JSON | Новое значение |
| `changed_at` | datetime | UTC |
| `source` | enum | `cli`, `tui`, `mcp` |

---

## 4. Хранилище

### 4.1 Требования

- SQLite 3 (WAL mode, `journal_mode=WAL`, `foreign_keys=ON`)
- ACID-транзакции
- JSON-поля через SQLite JSON functions
- Без внешних зависимостей

### 4.2 Полная схема

```sql
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE projects (
  id           TEXT PRIMARY KEY,   -- UUIDv7
  name         TEXT NOT NULL UNIQUE,
  created_at   TEXT NOT NULL
);

CREATE TABLE tasks (
  id                  TEXT PRIMARY KEY,
  project_id          TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  parent_id           TEXT REFERENCES tasks(id) ON DELETE CASCADE,
  alias               TEXT,
  normalized_alias    TEXT,
  title               TEXT NOT NULL CHECK(length(trim(title)) > 0),
  description         TEXT,
  status              TEXT NOT NULL DEFAULT 'pending'
                      CHECK(status IN ('pending','in_progress','completed','failed','cancelled','on_hold')),
  status_reason       TEXT,
  context_state       TEXT NOT NULL DEFAULT 'active'
                      CHECK(context_state IN ('active','backlog','in_review','archived')),
  completion_policy   TEXT NOT NULL DEFAULT 'all_children'
                      CHECK(completion_policy IN ('all_children','any_child','manual')),
  business_value      INTEGER NOT NULL DEFAULT 50 CHECK(business_value BETWEEN 0 AND 100),
  urgency_score       INTEGER NOT NULL DEFAULT 50 CHECK(urgency_score BETWEEN 0 AND 100),
  estimated_effort    REAL,
  due_date            TEXT,
  tags                TEXT DEFAULT '[]',
  assigned_to         TEXT,
  metadata            TEXT DEFAULT '{}',
  plan_version        INTEGER NOT NULL DEFAULT 0,
  last_action_type    TEXT NOT NULL DEFAULT 'execution'
                      CHECK(last_action_type IN ('execution','planning','reflection','review')),
  last_progress_at    TEXT NOT NULL,  -- UTC ISO 8601
  created_at          TEXT NOT NULL,
  updated_at          TEXT NOT NULL,
  completed_at        TEXT
);

-- Уникальность alias и normalized_alias в рамках проекта
CREATE UNIQUE INDEX idx_tasks_alias ON tasks(project_id, normalized_alias)
  WHERE normalized_alias IS NOT NULL;

CREATE INDEX idx_tasks_parent      ON tasks(parent_id);
CREATE INDEX idx_tasks_status      ON tasks(status);
CREATE INDEX idx_tasks_context     ON tasks(context_state);
CREATE INDEX idx_tasks_project     ON tasks(project_id);
CREATE INDEX idx_tasks_bv_us       ON tasks(business_value DESC, urgency_score DESC);

CREATE TABLE task_links (
  id              TEXT PRIMARY KEY,
  from_task_id    TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  to_task_id      TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  link_type       TEXT NOT NULL CHECK(link_type IN ('strong','soft')),
  label           TEXT,
  created_at      TEXT NOT NULL,
  UNIQUE(from_task_id, to_task_id, link_type),
  CHECK(from_task_id != to_task_id)
);

CREATE INDEX idx_task_links_from   ON task_links(from_task_id);
CREATE INDEX idx_task_links_to     ON task_links(to_task_id);
CREATE INDEX idx_task_links_type   ON task_links(link_type);

CREATE TABLE knowledge_entities (
  id               TEXT PRIMARY KEY,
  project_id       TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,
  normalized_name  TEXT NOT NULL,
  entity_type      TEXT NOT NULL DEFAULT 'fact',
  content          TEXT NOT NULL,
  metadata         TEXT DEFAULT '{}',
  created_at       TEXT NOT NULL,
  updated_at       TEXT NOT NULL,
  UNIQUE(project_id, normalized_name)
);

CREATE INDEX idx_ke_type      ON knowledge_entities(entity_type);
CREATE INDEX idx_ke_project   ON knowledge_entities(project_id);

CREATE TABLE task_knowledge_refs (
  task_id      TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  entity_id    TEXT NOT NULL REFERENCES knowledge_entities(id) ON DELETE CASCADE,
  ref_type     TEXT NOT NULL CHECK(ref_type IN ('produces','consumes','updates','blocks'))
               DEFAULT 'consumes',
  PRIMARY KEY(task_id, entity_id, ref_type)
);

CREATE INDEX idx_tkr_task     ON task_knowledge_refs(task_id);
CREATE INDEX idx_tkr_entity   ON task_knowledge_refs(entity_id);

CREATE TABLE reflections (
  id                TEXT PRIMARY KEY,
  task_id           TEXT REFERENCES tasks(id) ON DELETE SET NULL,
  project_id        TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  content           TEXT NOT NULL,
  reflection_type   TEXT NOT NULL DEFAULT 'observation'
                    CHECK(reflection_type IN ('observation','decision','blocker','insight','replan_trigger')),
  triggered_replan  INTEGER NOT NULL DEFAULT 0,
  reflection_budget INTEGER NOT NULL DEFAULT 3,
  created_at        TEXT NOT NULL,
  source            TEXT NOT NULL CHECK(source IN ('cli','tui','mcp'))
);

CREATE INDEX idx_reflections_task      ON reflections(task_id);
CREATE INDEX idx_reflections_project   ON reflections(project_id);

CREATE TABLE task_history (
  id             TEXT PRIMARY KEY,
  task_id        TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  field_changed  TEXT NOT NULL,
  old_value      TEXT,
  new_value      TEXT,
  changed_at     TEXT NOT NULL,
  source         TEXT NOT NULL CHECK(source IN ('cli','tui','mcp'))
);

CREATE INDEX idx_history_task ON task_history(task_id);
```

---

## 5. Алгоритмы

### 5.1 Hierarchical Business Priority (HBP) — формула

**Эффективный приоритет корневой задачи:**

$$
EP_{root} = (business\_value \times 0.85) + (urgency\_score \times 0.15)
$$

**Эффективный приоритет дочерней задачи (рекурсивно):**

$$
EP_{child} = \min\!\bigl(EP_{parent},\; (business\_value_{child} \times 0.85) + (urgency\_score_{child} \times 0.15)\bigr)
$$

**Свойства формулы:**

- Баланс 85/15: стратегическая важность доминирует над тактической срочностью.
- **Hard Cap**: подзадача никогда не превышает EP родительской ветки.
- Business Value задаёт "потолок" важности сверху вниз по дереву.
- Urgency Score позволяет поднять срочную задачу внутри ветки, не нарушая иерархию.

### 5.2 Расчёт Active Front (Recursive CTE)

```sql
WITH RECURSIVE task_hierarchy AS (
    -- База: корневые задачи
    SELECT
        id,
        CAST((business_value * 0.85 + urgency_score * 0.15) AS REAL) AS ep,
        0 AS depth
    FROM tasks
    WHERE parent_id IS NULL
      AND project_id = :project_id

    UNION ALL

    -- Рекурсия: дочерние задачи
    SELECT
        t.id,
        MIN(h.ep, CAST((t.business_value * 0.85 + t.urgency_score * 0.15) AS REAL)) AS ep,
        h.depth + 1
    FROM tasks t
    INNER JOIN task_hierarchy h ON t.parent_id = h.id
),
completed_ids AS (
    SELECT id FROM tasks WHERE status = 'completed'
)
SELECT
    t.*,
    th.ep          AS effective_priority,
    th.depth       AS depth,
    (
        SELECT COUNT(*) FROM task_links l2
        WHERE l2.to_task_id = t.id
          AND l2.link_type = 'strong'
          AND l2.from_task_id NOT IN (SELECT id FROM completed_ids)
    ) AS unblock_score,
    CASE
        WHEN t.estimated_effort IS NULL OR t.estimated_effort = 0 THEN 0.0
        ELSE CAST(
            (strftime('%s','now') - strftime('%s', t.last_progress_at))
            / ((t.estimated_effort * 3600 * 2) + (4 * 3600))
        AS REAL)
    END AS staleness_score
FROM tasks t
INNER JOIN task_hierarchy th ON t.id = th.id
WHERE t.status = 'pending'
  AND t.context_state IN ('active', 'in_review')
  AND NOT EXISTS (
      SELECT 1 FROM task_links l
      WHERE l.from_task_id = t.id
        AND l.link_type = 'strong'
        AND l.to_task_id NOT IN (SELECT id FROM completed_ids)
  )
ORDER BY
    th.ep DESC,          -- 1. Business priority (с Hard Cap)
    unblock_score DESC,  -- 2. Техническая разблокируемость
    staleness_score DESC,-- 3. Поднимаем застрявшие задачи
    t.created_at ASC;    -- 4. FIFO при прочих равных
```

### 5.3 Staleness Score (Штраф за простой)

$$
Staleness = \frac{now() - last\_progress\_at}{estimated\_effort_{sec} \times 2 + 4 \times 3600}
$$

- Если `staleness > 1.0` → задача помечается как **stalled**
- Stalled-задачи поднимаются в Active Front (сортировка по `staleness DESC`)
- В TUI отображается значком `⚠️` (stalled: >1.0) или `⏳` (на грани: 0.7–1.0)
- Если `estimated_effort` не задан — Staleness = 0.0 (не участвует в штрафе)

### 5.4 PNR Guardrail (Progress-to-Noise Ratio)

Защита от бесконечного планирования без исполнения.

```txt
checkPNR(taskId, projectId) → void | throws StallDetected

1. Взять последние 10 изменений план версии (plan_version) в ветке taskId
2. delta_completed = count(task_done events за последние N replan-ов)
3. delta_created   = count(task_add events за последние N replan-ов)

4. Если delta_created > 5 И (delta_completed / delta_created) < 0.15:
   → throw StallDetected("Too many plans without execution. Complete tasks first.")

5. Если last_action_type задачи == 'planning' | 'reflection' три раза подряд:
   → throw StallDetected("Consecutive planning without execution detected.")
```

Вызывается **до** выполнения `task_replan`.

### 5.5 Iscompletable (Hierarchical Completion Check)

```txt
isCompletable(task, allTasks) → bool

  children = allTasks.where(t => t.parent_id == task.id)
  if children.isEmpty: return true

  completed_children = children.where(c => c.status == 'completed')

  switch task.completion_policy:
    'all_children' → completed_children.length == children.length
    'any_child'    → completed_children.length >= 1
    'manual'       → true
```

### 5.6 Strong-Link DAG (полная совместимость с v2.0)

Граф строится **только по `link_type = 'strong'`**.

```txt
topologicalSort(strong_adjacency)    → List<id> | throws CycleException(path)
detectCycle(strong_adjacency)        → throws CycleException(path)
findReadyTasks(tasks, strong_links)  → List<Task> | throws CycleException
```

Soft links в топосортировку не входят. Цикл в soft-графе не является ошибкой.

### 5.7 Soft Link Context

```txt
getSoftContext(taskId, links, tasks) → SoftContext {
  informs:    Task[],   // задачи, передающие контекст в taskId
  informedBy: Task[],   // задачи, которые taskId информирует
  related:    Task[]    // задачи с label='related'
}
```

### 5.8 kg_auto_bridge

```txt
kgAutoBridge(taskId, entityId, refType, allRefs, tasks) → TaskLink | null

  if refType == 'produces':
    consumers = allRefs.where(r => r.entity_id == entityId AND r.ref_type == 'consumes')
    for each consumer C:
      if не существует soft link (taskId → C.task_id):
        create soft link (taskId → C.task_id, label='auto_bridge:' + entityId)

  if refType == 'consumes':
    producers = allRefs.where(r => r.entity_id == entityId AND r.ref_type == 'produces')
    for each producer P:
      if не существует soft link (P.task_id → taskId):
        create soft link (P.task_id → taskId, label='auto_bridge:' + entityId)
```

Вызывается автоматически при `kg_task_link`.

### 5.9 Dynamic Planning Loop (формализация)

```txt
PLAN PHASE:
  1. task_breakdown / task_bulk_plan → создать иерархию подзадач
  2. link_add (strong/soft) → задать порядок и контекст

EXECUTE PHASE:
  3. get_active_front → получить фронт работы
  4. task_start (опционально) → зафиксировать начало
  5. [выполнить работу]
  6. kg_task_link → зафиксировать знания (→ kg_auto_bridge срабатывает)
  7. task_done → завершить задачу

REFLECT PHASE:
  8. task_reflect {reflection_budget: N} → зафиксировать наблюдение
  9. если необходимо переосмысление:
     a. checkPNR → убедиться, что не в петле
     b. task_replan (атомарно) → скорректировать план
     c. task_set_context → перевести задачи в active/backlog
  10. → вернуться к пункту 3

TERMINATE:
  11. get_active_front → пустой список
  12. isCompletable(root) → если true: task_done на корневой задаче
```

---

## 6. Нормализация alias

Правила нормализации (применяются к `alias` → `normalized_alias`):

1. Trim пробелов
2. toLowerCase
3. Заменить пробелы и `/` на `-`
4. Удалить символы вне `[a-z0-9_-]`
5. Удалить leading/trailing `-`
6. Если пустая строка после нормализации → ошибка `INVALID_ALIAS`

`normalized_alias` UNIQUE в рамках проекта.

---

## 7. Идентификация задач (Task Reference)

Task reference — строка, разрешаемая в `task.id`:

1. Если соответствует формату UUIDv7 → поиск по `id`
2. Иначе → нормализовать как alias → поиск по `normalized_alias`
3. Если не найдено → `TaskNotFoundError('<ref>')`

---

## 8. CLI

### 8.1 Глобальные параметры

```txt
--db <path>         — путь к SQLite файлу (по умолчанию ~/.tm/tm.db)
--project <name>    — проект (по умолчанию текущий активный)
```

### 8.2 Задачи

```bash
# Создать задачу
tm task add <title>
  [--parent <ref>]
  [--alias <alias>]
  [--bv <0-100>]         # business_value
  [--us <0-100>]         # urgency_score
  [--effort <hours>]
  [--due <datetime>]
  [--context <active|backlog|in_review|archived>]
  [--policy <all_children|any_child|manual>]
  [--tags <tag,...>]
  [--assign <name>]

# Просмотр
tm task list
  [--status <status>]
  [--context <context_state>]
  [--parent <ref>]
  [--tag <tag>]
  [--stalled]            # только stalled задачи

tm task show <ref>       # детали + soft context + знания
tm task front [--limit <n>] [--context <active|all>]
              # Active Front — фронт работы

# Жизненный цикл
tm task start <ref>
tm task done <ref> [--reason <text>]
tm task fail <ref> --reason <text>
tm task cancel <ref> [--reason <text>]
tm task on-hold <ref> [--reason <text>]

# Редактирование
tm task update <ref> [--title <text>] [--description <text>]
                     [--bv <0-100>] [--us <0-100>]
                     [--due <datetime>] [--assign <name>]
tm task alias <ref> <new-alias>
tm task context <ref> <active|backlog|in_review|archived>
tm task move <ref> --parent <ref>       # переместить в дереве
tm task delete <ref>

# Граф и дерево
tm task graph [--root <ref>] [--depth <n>]
tm task tree [--root <ref>]             # иерархическое дерево
```

### 8.3 Связи

```bash
tm task link add <from-ref> --to <to-ref>
  [--type <strong|soft>]   # по умолчанию strong
  [--label <text>]

tm task link remove <from-ref> --to <to-ref> [--type <strong|soft>]
tm task link list <ref> [--type <strong|soft>] [--direction <from|to|both>]

# Обратная совместимость с v2.0:
tm task deps add <from-ref> --to <to-ref>   # = link add --type strong
tm task deps remove <from-ref> --to <to-ref>
```

### 8.4 Планирование

```bash
tm task breakdown <ref>
  [--mode <parallel|sequential|followup>]
  [--subtasks <"title1" "title2" ...>]

tm bulk plan [--dry-run]   # Markdown DSL (совместимость с v2.0)
tm bulk add --file <json>

tm task reflect <ref>
  --type <observation|decision|blocker|insight|replan_trigger>
  [--text <content>]
  [--budget <n>]           # reflection_budget, по умолчанию 3
  [--replan]               # triggerReplan = true
```

### 8.5 Knowledge

```bash
tm kg add --name <name> --type <fact|decision|assumption|risk|concept|tool>
          [--content <text>] [--file <path>]

tm kg list [--type <type>] [--search <text>]
tm kg show <name-or-id>
tm kg update <name-or-id> [--content <text>]

tm kg task link <task-ref> --entity <name> --ref-type <produces|consumes|updates|blocks>
tm kg task entities <task-ref>

# Совместимость с v2.0 flat knowledge:
tm knowledge add <task-ref> <content>
tm knowledge list [--task <ref>]
```

### 8.6 Прочие команды

```bash
tm init [--name <project-name>]
tm project list | create <name> | switch <name> | current

tm mcp [--readonly] [--project <name>]   # запустить MCP-сервер
tm tui                                   # TUI-интерфейс
```

---

## 9. Interactive Task Run (tm task run)

```txt
tm task run [--auto] [--batch]
```

Алгоритм:

```txt
1. getActiveFront()
   → CycleException: показать путь цикла, выйти
   → пустой фронт:
       - если есть waiting_children → показать "Ожидает дочерних задач: N"
       - если есть blocked → показать "Заблокировано зависимостями: N"
       - иначе → "Все задачи выполнены!"
       → выйти

2. Показать фронт задач (с soft-контекстом)
3. Пользователь выбирает задачу T (--auto = первая в списке)
4. Показать T.description + soft context (инфо из связанных задач)
5. Prompt: "Введите результат работы (для сохранения в knowledge):"
6. Сохранить knowledge, перевести T → completed
7. Prompt: "Нужно ли скорректировать план? (Y/N)"
   → Y: ввести рефлексию → task reflect
8. --batch: повторить с пункта 1
```

---

## 10. TUI

### 10.1 Экраны

| Экран | Описание |
| --- | --- |
| `TaskList` | Плоский список задач с фильтрами (совместимость v2.0) |
| `TaskTree` | Иерархическое дерево с раскрытием узлов |
| `ActiveFront` | Карточки текущего фронта работы |
| `TaskDetail` | Полные детали задачи + soft context + знания |
| `KnowledgeList` | Список Knowledge Entities |
| `ReflectionLog` | Лента рефлексий (по задаче или проекту) |
| `DAGGraph` | Визуализация strong/soft графа (ASCII) |

### 10.2 Глобальные горячие клавиши

| Клавиша | Действие |
| --- | --- |
| `1` | Переключиться на TaskList |
| `2` | Переключиться на TaskTree |
| `3` | Переключиться на ActiveFront |
| `4` | Переключиться на DAGGraph |
| `5` | Переключиться на KnowledgeList |
| `?` | Справка |
| `q` | Выйти |

### 10.3 TaskTree — горячие клавиши

| Клавиша | Действие |
| --- | --- |
| `Space` / `→` | Раскрыть/свернуть узел |
| `Enter` | Открыть TaskDetail |
| `a` | Добавить дочернюю задачу |
| `A` | Добавить корневую задачу |
| `m` | Переместить задачу (задать нового родителя) |
| `x` | Завершить задачу |
| `d` | Удалить задачу |
| `/` | Фильтр по context_state |
| `j` / `k` | Навигация |

### 10.4 ActiveFront — горячие клавиши

| Клавиша | Действие |
| --- | --- |
| `Enter` | Взять в работу (status → in_progress) |
| `Space` | Показать soft-контекст |
| `x` | Завершить задачу |
| `r` | Добавить рефлексию |
| `j` / `k` | Навигация |

### 10.5 Визуальные требования

- Рядом с задачей: `[EP: 78 | BV:90 US:60]`
- Значок `🕮` для задач с привязанными Knowledge Entities
- `⚠️` для stalled задач (staleness > 1.0), `⏳` для (0.7–1.0)
- Маркер контекста: `●` active, `○` backlog, `◑` in_review, `◌` archived
- Связи: `───` strong, `···` soft, `→` направление
- Иерархические отступы: `▶ / ▼` для раскрытия в TaskTree

---

## 11. MCP-сервер

### 11.1 Транспорт и протокол

- JSON-RPC 2.0 over stdio (основной) и HTTP (опциональный)
- Версия: `2025-11-25` (с fallback до `2025-03-26`)
- Handshake: `initialize` → `notifications/initialized`
- `ping` / `pong` keepalive

### 11.2 Readonly-режим

```bash
tm mcp --readonly
```

В readonly-режиме доступны только инструменты чтения. Запросы на изменение возвращают `METHOD_NOT_ALLOWED`.

### 11.3 Все инструменты

#### Унаследованные из v2.0 (с расширениями)

| Инструмент | Изменения в v3.3 |
| --- | --- |
| `task_list` | + `context_state?`, `parent_id?`, `stalled?` фильтры |
| `task_show` | + `softContext`, `knowledgeEntities`, `ep`, `staleness` в ответе |
| `task_resolve` | Без изменений |
| `task_graph` | + `link_type` фильтр |
| `task_add` | + `parent_id?`, `context_state?`, `completion_policy?`, `business_value?`, `urgency_score?` |
| `task_update` | + `business_value?`, `urgency_score?`, `context_state?`, `completion_policy?` |
| `task_rename_alias` | Без изменений |
| `task_done` | Без изменений |
| `task_cancel` | Без изменений |
| `task_fail` | Без изменений |
| `task_on_hold` | Без изменений |
| `task_delete` | Без изменений |
| `task_breakdown` | Без изменений |
| `task_bulk_plan` | Без изменений |
| `task_bulk_add` | Без изменений |
| `knowledge_list` | Плоские заметки — совместимость v2.0 |
| `knowledge_add` | Плоские заметки — совместимость v2.0 |
| `project_list` | Без изменений |
| `project_switch` | Без изменений |

**Алиасы для backward compatibility:**  
`dependency_add` → `link_add(linkType: 'strong')`  
`dependency_remove` → `link_remove(linkType: 'strong')`  
`task_next_ready` → `get_active_front(limit: 1)` (возвращает первую задачу)

---

#### Новые инструменты

### 11.4 get_active_front

Главный инструмент планирования.

```txt
params:
  context_state?: 'active' | 'in_review' | 'all'  — по умолчанию 'active'
  limit?:         integer                          — макс. задач (по умолчанию 10)
  include_stalled?: boolean                        — включить stalled даже из backlog

returns:
  front: Array<{
    task:        Task
    ep:          float          — effective_priority
    depth:       integer
    staleness:   float
    softContext: {
      informs:          Task[]
      informedBy:       Task[]
      relatedEntities:  KnowledgeEntity[]
    }
    unblockScore: integer
  }>
  waitingChildren:  Array<{task: Task, policy: string, remaining: integer}>
  blockedByStrong:  Array<{task: Task, unmetDeps: string[]}>
  stalledTasks:     Array<{task: Task, staleness: float}>
```

### 11.5 task_start

```txt
params:  id: string
returns: task: Task  (status = 'in_progress')
```

### 11.6 link_add

```txt
params:
  fromTaskId: string                     — обязательный
  toTaskId:   string                     — обязательный
  linkType:   'strong' | 'soft'          — по умолчанию 'strong'
  label?:     string

returns: link: TaskLink
throws:  CycleException (только для strong links)
```

### 11.7 link_remove

```txt
params:
  fromTaskId: string
  toTaskId:   string
  linkType?:  'strong' | 'soft'    — если не указан: удалить оба типа
```

### 11.8 link_list

```txt
params:
  taskId:     string
  direction?: 'from' | 'to' | 'both'   — по умолчанию 'both'
  linkType?:  'strong' | 'soft'

returns: links: Array<{link: TaskLink, task: Task}>
```

### 11.9 task_set_context

```txt
params:
  id:           string
  contextState: 'active' | 'backlog' | 'in_review' | 'archived'

returns: task: Task
```

### 11.10 task_move

```txt
params:
  id:       string
  parentId: string | null    — null = сделать корневой

returns: task: Task
```

### 11.11 task_reflect

```txt
params:
  taskId?:          string
  content:          string              — обязательный
  reflectionType:   'observation' | 'decision' | 'blocker' | 'insight' | 'replan_trigger'
  reflectionBudget?: integer            — по умолчанию 3
  triggerReplan?:   boolean

returns:
  reflection:  Reflection
  replanTask?: Task   — если triggerReplan=true: создаётся задача "Replan based on reflection"

throws: RecursiveReflectionWarning  — если бюджет рефлексий исчерпан
```

### 11.12 task_replan

**Полностью атомарная операция (All-or-Nothing).**

```txt
params:
  taskId:    string
  changes:   Array<{
    action: 'add_task' | 'remove_task' | 'add_link' | 'remove_link' |
            'update_task' | 'set_context' | 'set_priority' | 'set_policy'
    params: object
  }>
  reason?:   string

returns:
  applied:      Array<{action, result}>
  planVersion:  integer   — новая версия плана
  summary:      string

throws:
  StallDetected          — PNR Guardrail сработал (checkPNR)
  CycleException         — если изменения создают цикл в strong-графе
  ReplanValidationError  — неизвестный action или невалидные params
```

**Гарантия атомарности**: все изменения применяются в одной SQLite-транзакции. При любой ошибке — полный rollback. Partial success невозможен.

**Перед выполнением**: вызывается `checkPNR(taskId)`. При `StallDetected` операция отклоняется.

### 11.13 kg_entity_add

```txt
params:
  name:        string
  entityType:  string
  content:     string
  metadata?:   object

returns: entity: KnowledgeEntity
throws:  EntityAlreadyExists('<normalized_name>')
```

### 11.14 kg_entity_list

```txt
params:
  entityType?: string
  search?:     string   — full-text по name/content

returns: entities: KnowledgeEntity[]
```

### 11.15 kg_entity_show

```txt
params:  id: string  — id или name

returns:
  entity: KnowledgeEntity
  tasks:  Array<{task: Task, refType: string}>
```

### 11.16 kg_entity_update

```txt
params:
  id:       string
  content?: string
  metadata?: object

returns: entity: KnowledgeEntity
```

### 11.17 kg_task_link

```txt
params:
  taskId:   string
  entityId: string
  refType:  'produces' | 'consumes' | 'updates' | 'blocks'

returns:
  ref:          TaskKnowledgeRef
  autoBridges:  TaskLink[]    — автоматически созданные soft links
```

### 11.18 kg_task_entities

```txt
params:
  taskId:   string
  refType?: string

returns: entities: Array<{entity: KnowledgeEntity, refType: string}>
```

### 11.19 reflection_list

```txt
params:
  taskId?:          string
  reflectionType?:  string
  since?:           string  — ISO 8601

returns: reflections: Reflection[]
```

---

## 12. Обработка ошибок

### 12.1 Коды ошибок пользователя

| Код | Условие |
| --- | --- |
| `TASK_NOT_FOUND` | Задача по ref не найдена |
| `ALIAS_ALREADY_EXISTS` | Alias занят в проекте |
| `INVALID_ALIAS` | Alias не прошёл нормализацию |
| `STRONG_CYCLE_DETECTED` | Цикл в strong-графе (+ путь цикла) |
| `ENTITY_ALREADY_EXISTS` | Knowledge entity с таким normalized_name уже есть |
| `STALL_DETECTED` | PNR Guardrail — планирование без исполнения |
| `RECURSIVE_REFLECTION_WARNING` | Бюджет рефлексий исчерпан |
| `HARD_CAP_VIOLATION` | (опционально) Попытка задать BV ребёнка выше EP родителя |
| `REPLAN_VALIDATION_ERROR` | Неизвестный action или невалидные params |
| `STATUS_TRANSITION_INVALID` | Недопустимый переход статуса |
| `COMPLETION_POLICY_BLOCKED` | `isCompletable` вернул false |

### 12.2 MCP ошибки протокола

| code | message | Условие |
| --- | --- | --- |
| -32700 | Parse error | Невалидный JSON |
| -32600 | Invalid request | Структура JSON-RPC нарушена |
| -32601 | Method not found | Неизвестный инструмент |
| -32602 | Invalid params | Отсутствуют обязательные поля |
| -32000 | Application error | Ошибки приложения (§12.1) |
| -32001 | Method not allowed | Readonly-режим + мутирующий запрос |

---

## 13. Инварианты системы

1. **Strong links образуют DAG** — цикл в strong-графе недопустим в любой момент времени.
2. **Soft links — произвольный граф** — циклы разрешены.
3. **Иерархия — строгое дерево** — `parent_id` указывает на единственного родителя.
4. **EP рассчитывается динамически** через Recursive CTE, никогда не хранится.
5. **Hard Cap гарантирован** — EP ребёнка ≤ EP родителя по построению рекурсии.
6. **`blocked` и `waiting_children` — вычисляемые** — не хранятся в БД.
7. **`task_replan` — All-or-Nothing** — partial success невозможен.
8. **`task_breakdown` атомарна** — полный откат при ошибке.
9. **Alias уникален в проекте** после нормализации.
10. **Knowledge entity `normalized_name` уникален** в проекте.
11. **Все datetime — UTC ISO 8601** (`2026-05-02T12:00:00Z`).
12. **`last_progress_at` обновляется** только при `status → completed`.

---

## 14. Тестируемость

### 14.1 Чистые функции (без side effects)

```txt
topologicalSort(adjacency)                        → List<id> | CycleException
detectCycle(adjacency)                            → CycleException?
findReadyTasks(tasks, strongLinks)                → Task[] | CycleException
getActiveFront(tasks, links)                      → Task[] | CycleException
isCompletable(task, allTasks)                     → bool
getSoftContext(taskId, links, tasks)              → SoftContext
calculateUnblockScore(taskId, tasks, strongLinks) → int
calculateStaleness(task, now)                     → float
checkPNR(history)                                 → void | StallDetected
normalizeAlias(raw)                               → string | InvalidAlias
kgAutoBridge(taskId, entityId, refType, refs)     → TaskLink[]
```

### 14.2 Обязательные тестовые сценарии

**HBP / Hard Cap:**

- Корневая задача: EP = BV×0.85 + US×0.15
- Дочерняя задача с BV выше родителя: EP = EP(parent) (Hard Cap)
- Трёхуровневая иерархия: EP убывает или равен по каждому уровню

**Active Front:**

- Задача в `backlog` не входит во фронт
- Задача с незавершёнными strong-deps не входит
- Stalled задача поднимается выше нестalled при равном EP
- Сортировка детерминирована

**Иерархия:**

- `all_children`: родитель не completable до завершения всех детей
- `any_child`: completable после первого завершённого ребёнка
- `manual`: completable независимо от детей
- `task_move` корректно меняет parent_id
- Удаление родителя каскадно удаляет детей

**Strong links (DAG):**

- Добавление цикла → `CycleException`
- Topological sort на DAG без цикла — детерминирован
- `findReadyTasks` возвращает только задачи с завершёнными deps

**Soft links:**

- Soft link не блокирует выполнение
- Цикл в soft links не ошибка
- Soft link виден в `getSoftContext`

**PNR Guardrail:**

- Менее 5 новых задач за серию replan-ов → guardrail не срабатывает
- ΔCompleted/ΔCreated < 0.15 при ΔCreated > 5 → `StallDetected`
- Три consecutive planning без execution → `StallDetected`

**task_replan атомарность:**

- При ошибке на шаге N (из M) — откат всех шагов 1..N
- После успешного replan: `plan_version` инкрементирован

**kg_auto_bridge:**

- `produces` + `consumes` на одной сущности → soft link создан
- Повторный вызов → дубликат не создаётся

**Staleness:**

- Задача без `estimated_effort` → staleness = 0.0
- Задача с просроченным `last_progress_at` → staleness > 1.0

---

## 15. Сравнение версий

| Аспект | v2.0 (final_spec) | v3.0-alt (alternative_spec) | v3.3-final (этот документ) |
| --- | --- | --- | --- |
| Структура задач | Flat list | Иерархия | Иерархия |
| Приоритет | Единый integer | Единый integer | BV + US с Hard Cap (HBP) |
| Зависимости | Strong only | Strong + Soft | Strong + Soft |
| Следующий шаг | `task_next_ready` (одна) | `get_active_front` (фронт) | `get_active_front` (фронт + staleness) |
| Knowledge | Плоские заметки | KG с отношениями | KG упрощённый + `kg_auto_bridge` |
| Рефлексия | Нет | `task_reflect` | `task_reflect` + `reflection_budget` |
| Replan | Нет | Partial (best-effort) | **All-or-Nothing** (атомарный) |
| Защита от LLM-деградации | Нет | Нет | **PNR Guardrail** |
| Staleness | Нет | Нет | **Staleness Score** |
| Глубина иерархии | — | Хранится | Динамический CTE |
| Атомарность replan | — | Partial | **Полная** |

---

## Приложение A: Маркеры

```txt
Статусы выполнения:
  ○ pending   ⟳ in_progress   ✓ completed   ✗ failed   ⊘ cancelled   ⏸ on_hold

Вычисляемые:
  🔒 blocked (strong deps)   ⏳ waiting_children

Контекстные состояния:
  ● active   ○ backlog   ◑ in_review   ◌ archived

Staleness:
  ⚠️ stalled (>1.0)   ⏳ aging (0.7–1.0)

Связи (TUI):
  ─── strong link   ··· soft link   → направление

Приоритет (TUI):
  [EP: 78 | BV:90 US:60]

Knowledge:
  🕮  задача с привязанными Knowledge Entities
```

## Приложение B: Пример Dynamic Planning Loop (MCP)

```jsonc
// ═══ PLAN PHASE ═══
→ tools/call task_add {
    title: "Build auth system",
    alias: "auth",
    business_value: 90,
    urgency_score: 60
  }
← {task: {id: "aaa1", alias: "auth", ep: 85.5, ...}}

→ tools/call task_breakdown {
    taskId: "aaa1",
    mode: "parallel",
    subtasks: [
      {title: "Design schema",   business_value: 80, urgency_score: 70},
      {title: "Implement JWT",   business_value: 85, urgency_score: 65},
      {title: "Write tests",     business_value: 75, urgency_score: 50},
      {title: "Deploy to prod",  business_value: 90, urgency_score: 80}
    ]
  }
// Hard Cap: все подзадачи получают EP ≤ EP("auth") = 85.5

→ tools/call link_add {
    fromTaskId: "bbb3",
    toTaskId: "bbb4",
    linkType: "soft",
    label: "test results inform deploy"
  }

// ═══ EXECUTE PHASE ═══
→ tools/call get_active_front {}
← {front: [
    {task: {id:"bbb2", title:"Implement JWT"}, ep: 80.5, staleness: 0.0, unblockScore: 2},
    {task: {id:"bbb1", title:"Design schema"}, ep: 78.0, staleness: 0.0, unblockScore: 1}
  ]}

→ tools/call task_done {id: "bbb1"}

→ tools/call kg_task_link {
    taskId: "bbb1",
    entityId: "schema-entity-id",
    refType: "produces"
  }
← {ref: {...}, autoBridges: [{from: "bbb1", to: "bbb2", type: "soft", label: "auto_bridge:schema-entity-id"}]}

// ═══ REFLECT PHASE ═══
→ tools/call task_reflect {
    taskId: "bbb2",
    content: "JWT library v3 has breaking change. Test suite needs update.",
    reflectionType: "blocker",
    reflectionBudget: 2,
    triggerReplan: true
  }
← {reflection: {...}, replanTask: {id: "ccc1", title: "Replan based on reflection"}}

→ tools/call task_replan {
    taskId: "aaa1",
    reason: "JWT v3 breaking change",
    changes: [
      {action: "add_task", params: {
        title: "Upgrade JWT to v3",
        parent_id: "aaa1",
        business_value: 85,
        urgency_score: 90
      }},
      {action: "add_link", params: {
        fromTaskId: "bbb2",
        toTaskId: "ddd1",
        linkType: "strong"
      }}
    ]
  }
// PNR проверка: ΔCompleted=1, ΔCreated=1 → 1/1 ≥ 0.15 → OK
← {applied: [...], planVersion: 1, summary: "Plan updated: 1 task added, 1 strong link added"}
```

## Приложение C: Рекомендации по выбору

| Сценарий | Рекомендация |
| --- | --- |
| CI/CD пайплайн, строгий порядок шагов | v2.0 (классический DAG) |
| Разработка фичи с параллельными задачами | v3.3-final |
| LLM-агент с Planner-Executor-Reflector loop | v3.3-final |
| Простой personal TODO с зависимостями | v2.0 |
| Исследовательский проект с неопределённостью | v3.3-final |
| Команда с несколькими агентами | v3.3-final |
| Продакшн система с требованием атомарности | v3.3-final |

## Приложение D: Datetime формат

ISO 8601 UTC: `2026-05-02T12:00:00Z`

---

Заключение

TM HTM v3.3-final представляет собой зрелую архитектуру, устраняющую ключевые проблемы предыдущих версий:

- **HBP + Hard Cap** обеспечивают корректную приоритизацию в глубоких деревьях
- **Атомарный `task_replan`** устраняет риск partial updates
- **PNR Guardrail** защищает от типичной LLM-деградации (бесконечное планирование)
- **Staleness Score** поднимает застрявшие задачи автоматически
- **`kg_auto_bridge`** создаёт информационные связи без ручного управления
- **Динамический EP через CTE** гарантирует консистентность без хранения вычисляемых полей
