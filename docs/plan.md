# TM Core — Implementation & Test Coverage Plan

Документ отслеживает статус реализации функций и тестового покрытия относительно [speс.md](speс.md).

Легенда: ✅ готово · ⏳ в работе · ❌ не реализовано · 🧪 есть тест · ⚠️ тест нужен

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
| `task_bulk_add` | §11.3, §8.4 | ✅ `task_bulk_add_operation.dart` | 🧪 `task_bulk_add_operation_test.dart` |
| `task_bulk_plan` | §11.3, §8.4 | ❌ не реализовано | ⚠️ нужен тест |
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
| `task_list` | §11.3 | ❌ не реализовано | ⚠️ нужен тест |
| `task_show` | §11.3 | ❌ не реализовано | ⚠️ нужен тест |
| `task_resolve` | §7, §11.3 | ❌ не реализовано | ⚠️ нужен тест |
| `link_list` | §11.8 | ❌ не реализовано | ⚠️ нужен тест |
| `task_graph` | §8.2 | ❌ не реализовано | ⚠️ нужен тест |
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
| `getSoftContext(taskId, links, tasks)` | §5.7 | ❌ не реализовано | ⚠️ нужен тест |
| `calculateStaleness(task, now)` | §5.3 | ❌ отдельной функции нет (inline в query) | ⚠️ нужен тест |
| `calculateUnblockScore(...)` | §14.1 | ❌ отдельной функции нет (inline в query) | ⚠️ нужен тест |
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
| `front[].softContext` | §11.4 | ❌ отсутствует в `ActiveFrontItem` |
| `waitingChildren` | §11.4 | ✅ |
| `blockedByStrong` | §11.4 | ✅ |
| `stalledTasks` | §11.4 | ✅ |

---

## 5. Приоритизация реализации

### Высокий приоритет (нужны для MCP-сервера)

1. `task_list` query — базовый листинг задач
2. `task_show` query — детали + softContext + ep + staleness
3. `task_resolve` query — UUID / alias → Task
4. `link_list` query — список связей
5. `getSoftContext(...)` — доменная функция (нужна для task_show и front)
6. `softContext` в `ActiveFrontItem`

### Средний приоритет

7. `task_bulk_plan` operation — Markdown DSL batch
8. `task_graph` query — ASCII граф

### Низкий приоритет

9. Выделить `calculateStaleness` и `calculateUnblockScore` в чистые функции (§14.1)
10. Тесты для `project_list`, `project_current`, `reflection_list` queries

---

## 6. Тестовые сценарии из §14.2 — покрытие

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
