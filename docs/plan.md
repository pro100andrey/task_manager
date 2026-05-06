# TM Core — Implementation & Test Coverage Plan

Документ отслеживает статус реализации функций и тестового покрытия относительно [speс.md](speс.md).

Легенда: ✅ готово · ⏳ в работе · ❌ не реализовано · 🧪 есть тест · ⚠️ тест нужен · 🐛 баг

---

## 0. Критические замечания

### 0.1 Баги

| # | Файл | Описание | Severity |
|---|---|---|---|
| B1 | `task_bulk_add_operation.dart` | ~~`TaskTitle(spec.title.trim())` может бросить исключение на пустом title~~ | ~~HIGH~~ **FIXED** |
| B2 | `task_bulk_add_operation.dart` | ~~Невалидный `contextState` / `completionPolicy` строка — тихий fallback~~ | ~~MEDIUM~~ **FIXED** |
| B3 | `task_bulk_add_failure.dart` | ~~`TaskBulkAddTaskCreationFailed` определён но никогда не используется~~ | ~~LOW~~ **FIXED** |

### 0.2 Отсутствующие в plan.md сущности

| Что | Спека | Статус |
|---|---|---|
| `TaskHistory` (Audit Trail) | §3.9 | ❌ **полностью отсутствует** — нет entity, port, adapter, ни одной записи при изменениях |
| `source` enum в операциях | §3.8, §3.9 | ⚠️ команды (напр. `TaskReflectCommand`) принимают `source` как raw String, не enum |

### 0.3 Архитектурные наблюдения

| Тема | Описание |
|---|---|
| **Дублирование валидации** | `task_replan._addTask()` дублирует логику `TaskCreateOperation.run()` через нетипизированный `Map<String,dynamic>`. Любое изменение в правилах создания задачи нужно синхронизировать в двух местах |
| **task_breakdown vs task_bulk_add** | Оба создают дочерние задачи, но семантика разная: breakdown обновляет `last_action_type` родителя и создаёт strong links между сиблингами; bulk_add — просто батч-создание без связей. Это разумно, но нигде не задокументировано в коде |
| **Атомарность через pipeline** | `task_bulk_add` и `task_replan` полагаются на `TransactionBehavior` в pipeline для rollback. Сами операции не управляют транзакцией — это правильно, но неочевидно |
| **String vs enum в командах** | `TaskReflectCommand`, `TaskBulkAddTaskSpec`, `TaskReplanCommand` используют raw strings для enum-полей. `TaskUpdateCommand` — типизирован правильно. Непоследовательно |
| **getSoftContext** | Упомянут в §5.7 и §11.4 как обязательный для active front и task_show, но не реализован нигде. Блокирует MCP |

### 0.4 Целесообразность / Приоритет пересмотра

| Что | Текущая оценка | Рекомендация |
|---|---|---|
| `task_bulk_plan` (Markdown DSL) | Нужен только для backward compat с v2.0 | Низкий приоритет: сначала запросы |
| `TaskHistory` | Заложен в схему БД, нужен для audit trail | Средний: добавить entity+port сейчас, адаптер — с SQLite |
| `getSoftContext` | Блокирует `task_show`, `ActiveFrontItem.softContext` | **Высокий**: одна чистая функция, нет I/O |
| String→enum в командах | Технический долг | Низкий: можно оставить для API-слоя, главное — validate |
| `calculateStaleness` как pub function | §14.1 требует тестируемой чистой функции | Низкий: inline в query — нормально, просто вынести |

---

## 1. Операции записи (Commands / Operations)

### 1.1 Project

| Операция | Спека | Реализация | Тест |
|---|---|---|---|
| `project_create` | §11.3 | ✅ `project_create_operation.dart` | 🧪 `project_create_operation_test.dart` |
| `project_rename` | §11.3 | ✅ `project_rename_operation.dart` | 🧪 `project_update_operations_test.dart` |
| `project_change_description` | §11.3 | ✅ `project_change_description_operation.dart` | 🧪 `project_update_operations_test.dart` |
| `project_delete` | §11.3 | ✅ `project_delete_operation.dart` | 🧪 `project_delete_switch_operations_test.dart` |
| `project_switch` | §11.3 | ✅ `project_switch_operation.dart` | 🧪 `project_delete_switch_operations_test.dart` |

### 1.2 Task

| Операция | Спека | Реализация | Тест |
|---|---|---|---|
| `task_add` | §11.3 | ✅ `task_create_operation.dart` | 🧪 `task_operations_test.dart` |
| `task_update` | §11.3 | ✅ `task_update_operation.dart` | 🧪 `task_editing_operations_test.dart` |
| `task_rename_alias` | §11.3 | ✅ `task_rename_alias_operation.dart` | 🧪 `task_editing_operations_test.dart` |
| `task_delete` | §11.3 | ✅ `task_delete_operation.dart` | 🧪 `task_operations_test.dart` |
| `task_start` | §11.5 | ✅ `task_start_operation.dart` | 🧪 `task_operations_test.dart` |
| `task_done` | §11.3 | ✅ `task_done_operation.dart` | 🧪 `task_operations_test.dart` |
| `task_cancel` | §11.3 | ✅ `task_cancel_operation.dart` | 🧪 `task_operations_test.dart` |
| `task_fail` | §11.3 | ✅ `task_fail_operation.dart` | 🧪 `task_operations_test.dart` |
| `task_on_hold` | §11.3 | ✅ `task_hold_operation.dart` | 🧪 `task_operations_test.dart` |
| `task_set_context` | §11.9 | ✅ `task_set_context_operation.dart` | 🧪 `task_editing_operations_test.dart` |
| `task_move` | §11.10 | ✅ `task_move_operation.dart` | 🧪 `task_editing_operations_test.dart` |
| `task_breakdown` | §11.3 | ✅ `task_breakdown_operation.dart` | 🧪 `task_breakdown_operation_test.dart` |
| `task_bulk_add` | §11.3, §8.4 | ✅ `task_bulk_add_operation.dart` | 🧪 `task_bulk_add_operation_test.dart` (8 тестов) |
| `task_bulk_plan` | §11.3, §8.4 | ❌ не реализовано | ⚠️ нужен тест | |
| `task_replan` | §11.12 | ✅ `task_replan_operation.dart` | 🧪 `task_replan_operation_test.dart` |
| `task_reflect` | §11.11 | ✅ `task_reflect_operation.dart` | 🧪 `reflection_operations_test.dart` |

### 1.3 TaskLink

| Операция | Спека | Реализация | Тест |
|---|---|---|---|
| `link_add` | §11.6 | ✅ `task_link_add_operation.dart` | 🧪 `task_link_operations_test.dart` |
| `link_remove` | §11.7 | ✅ `task_link_remove_operation.dart` | 🧪 `task_link_operations_test.dart` |

### 1.4 Knowledge

| Операция | Спека | Реализация | Тест |
|---|---|---|---|
| `kg_entity_add` | §11.13 | ✅ `kg_entity_add_operation.dart` | 🧪 `kg_entity_operations_test.dart` |
| `kg_entity_update` | §11.16 | ✅ `kg_entity_update_operation.dart` | 🧪 `kg_entity_operations_test.dart` |
| `kg_task_link` | §11.17 | ✅ `kg_task_link_operation.dart` | 🧪 `kg_task_link_operations_test.dart` |

---

## 2. Запросы (Queries)

| Запрос | Спека | Реализация | Тест |
|---|---|---|---|
| `get_active_front` | §11.4 | ✅ `get_active_front_query.dart` | 🧪 `active_front_query_test.dart` |
| `task_list` | §11.3 | ✅ `task_list_query.dart` | 🧪 `task_queries_test.dart` |
| `task_show` | §11.3 | ✅ `task_show_query.dart` | 🧪 `task_queries_test.dart` |
| `task_resolve` | §7, §11.3 | ✅ `get_task_by_ref_query.dart` | 🧪 `task_queries_test.dart` |
| `link_list` | §11.8 | ✅ `link_list_query.dart` | 🧪 `task_queries_test.dart` |
| `task_graph` | §8.2 | ✅ `task_graph_query.dart` | 🧪 `task_queries_test.dart` |
| `project_list` | §11.3 | ✅ `get_all_projects_query.dart` | ⚠️ нужен тест |
| `project_current` | §11.3 | ✅ `get_current_project_query.dart` | ⚠️ нужен тест |
| `kg_entity_list` | §11.14 | ✅ `get_knowledge_entities_query.dart` | 🧪 `get_knowledge_entity_query_test.dart` |
| `kg_entity_show` | §11.15 | ✅ `get_knowledge_entity_query.dart` | 🧪 `get_knowledge_entity_query_test.dart` |
| `kg_task_entities` | §11.18 | ✅ `get_task_knowledge_entities_query.dart` | 🧪 `get_task_knowledge_entities_query_test.dart` |
| `reflection_list` | §11.19 | ✅ `reflection_list_query.dart` | ⚠️ нужен тест |

---

## 3. Доменные сервисы (чистые функции)

| Функция | Спека | Реализация | Тест |
|---|---|---|---|
| `normalizeAlias(raw)` | §6 | ✅ `task_domain_services.dart` | 🧪 `task_domain_services_test.dart` |
| `isCompletable(task, allTasks)` | §5.5 | ✅ `task_domain_services.dart` | 🧪 `task_domain_services_test.dart` |
| `checkPNR(history)` | §5.4 | ✅ `task_domain_services.dart` | 🧪 `task_domain_services_test.dart` |
| `taskActionHistory(task)` | §5.4 | ✅ `task_domain_services.dart` | 🧪 `task_domain_services_test.dart` |
| `topologicalSort(adjacency)` | §5.6 | ✅ `task_graph.dart` | 🧪 `task_graph_test.dart` |
| `detectCycle(adjacency)` | §5.6 | ✅ `task_graph.dart` | 🧪 `task_graph_test.dart` |
| `findReadyTasks(tasks, links)` | §5.6 | ✅ `task_graph.dart` | 🧪 `task_graph_test.dart` |
| `getSoftContext(taskId, links, tasks)` | §5.7 | ✅ `task_domain_services.dart` | 🧪 `task_domain_services_test.dart` |
| `calculateStaleness(task, now)` | §5.3, §14.1 | ✅ `task_domain_services.dart` | 🧪 `task_domain_services_test.dart` |
| `calculateUnblockScore(...)` | §14.1 | ✅ `task_domain_services.dart` | 🧪 `task_domain_services_test.dart` |
| `kgAutoBridge(...)` | §5.8 | ✅ `knowledge_domain_services.dart` | 🧪 `kg_task_link_operations_test.dart` |

---

## 4. `get_active_front` — детализация §11.4

| Поле результата | Спека | Статус |
|---|---|---|
| `front[].task` | §11.4 | ✅ |
| `front[].ep` | §11.4 | ✅ |
| `front[].depth` | §11.4 | ✅ |
| `front[].staleness` | §11.4 | ✅ |
| `front[].unblockScore` | §11.4 | ✅ |
| `front[].softContext` | §11.4 | ✅ `SoftContext` в `ActiveFrontItem`, расчёт через `getSoftContext` |
| `waitingChildren` | §11.4 | ✅ |
| `blockedByStrong` | §11.4 | ✅ |
| `stalledTasks` | §11.4 | ✅ |

> **Замечание**: `stalledTasks` берётся только из задач `front`, а не из всех задач проекта. Задача в `backlog` со staleness > 1 попадёт в `stalledTasks` только при `includeStalled=true`. Соответствует ли это спеке §11.4 — неоднозначно.

---

## 5. Отсутствующие сущности (не упомянуты в предыдущем плане)

| Что | Спека | Описание |
|---|---|---|
| `TaskHistory` entity | §3.9 | Audit trail. Нет entity, нет port, нет adapter, нет записей нигде |
| `TaskHistory` port | §3.9 | `TaskHistoryRepository` — отсутствует |
| `TaskHistory` mem adapter | §3.9 | Для тестов и in-memory mode |

---

## 6. Приоритизация реализации

### Высокий приоритет (блокируют MCP)

1. ~~**[B1] Исправить** `task_bulk_add`: поймать исключение при `TaskTitle(...)`~~ ✅ **DONE**
2. ~~**[B2] Исправить** `task_bulk_add`: невалидные enum-строки → validation error~~ ✅ **DONE**
3. ~~`getSoftContext(taskId, links, tasks)` — чистая функция~~ ✅ **DONE**
4. ~~`softContext` поле в `ActiveFrontItem`~~ ✅ **DONE**
5. ~~`task_list` query~~ ✅ **DONE**
6. ~~`task_show` query~~ ✅ **DONE**
7. ~~`task_resolve` query~~ ✅ **DONE**
8. ~~`link_list` query~~ ✅ **DONE**

### Средний приоритет

9. `TaskHistory` entity + port (без адаптера пока — заглушка)
10. ~~`calculateStaleness(task, now)` и `calculateUnblockScore` как публичные функции~~ ✅ **DONE**
11. ~~`task_graph` query~~ ✅ **DONE**
12. ~~**[B3]** `TaskBulkAddTaskCreationFailed`~~ ✅ **DONE** (используется при B1 fix)

### Низкий приоритет

13. `task_bulk_plan` operation — Markdown DSL (backward compat v2.0)
14. Тесты для `project_list`, `project_current`, `reflection_list` queries
15. Унификация string→enum в командах (`TaskReflectCommand`, `TaskBulkAddTaskSpec`)

---

## 7. Тестовые сценарии из §14.2 — покрытие

| Сценарий | Статус |
|---|---|
| HBP корневой EP = BV×0.85 + US×0.15 | 🧪 `active_front_query_test.dart` |
| Hard Cap: дочерняя с BV выше родителя → EP=EP(parent) | 🧪 `active_front_query_test.dart` |
| Трёхуровневая иерархия, EP убывает | 🧪 `active_front_query_test.dart` |
| Задача в backlog не в Active Front | 🧪 `active_front_query_test.dart` |
| Задача с незавершёнными strong-deps не в Active Front | 🧪 `active_front_query_test.dart` |
| Stalled задача поднимается выше нестalled при равном EP | ⚠️ нужен тест |
| `all_children`: родитель не completable до всех детей | 🧪 `task_domain_services_test.dart` |
| `any_child`: completable после первого ребёнка | 🧪 `task_domain_services_test.dart` |
| `manual`: всегда completable | 🧪 `task_domain_services_test.dart` |
| `task_move` корректно меняет parent_id | 🧪 `task_editing_operations_test.dart` |
| Удаление родителя каскадно удаляет детей | ⚠️ нужен тест |
| Добавление цикла → CycleException | 🧪 `task_graph_test.dart` |
| Topological sort на DAG детерминирован | 🧪 `task_graph_test.dart` |
| `findReadyTasks` — только задачи с завершёнными deps | 🧪 `task_graph_test.dart` |
| Soft link не блокирует выполнение | 🧪 `task_link_operations_test.dart` |
| Цикл в soft links не ошибка | ⚠️ нужен тест |
| Soft link виден в `getSoftContext` | ❌ функция не реализована |
| PNR: ΔCreated ≤ 5 → guardrail не срабатывает | 🧪 `task_domain_services_test.dart` |
| PNR: ΔCompleted/ΔCreated < 0.15 при ΔCreated > 5 → StallDetected | 🧪 `task_domain_services_test.dart` |
| PNR: 3 consecutive planning → StallDetected | 🧪 `task_domain_services_test.dart` |
| `task_replan` атомарность: ошибка на шаге N → rollback | 🧪 `task_replan_operation_test.dart` |
| После replan: `plan_version` инкрементирован | 🧪 `task_replan_operation_test.dart` |
| kg_auto_bridge: produces + consumes → soft link | 🧪 `kg_task_link_operations_test.dart` |
| kg_auto_bridge: повторный вызов → нет дубликата | 🧪 `kg_task_link_operations_test.dart` |
| Staleness без `estimated_effort` → 0.0 | ⚠️ нужен тест |
| Staleness с просроченным `last_progress_at` → > 1.0 | ⚠️ нужен тест |
| `task_move` в собственного потомка → ошибка цикла | 🧪 (проверить: `_isDescendant` guard есть) |
| `task_bulk_add` пустой title → validation error (не exception) | ⚠️ нужен тест (связан с B1) |
| `task_bulk_add` задачи с общим parentId создаются без sibling links | ⚠️ нужен тест (в отличие от breakdown) |
