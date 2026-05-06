# Task Module - Реализация и пробелы

Критично не реализовано

## Подсистема Knowledge полностью отсутствует

src

- Нет сущности KnowledgeEntity, связей task_knowledge_refs, операций kg_entity_add/list/show/update, kg_task_link, kg_task_entities.
- Нет логики kg_auto_bridge.

## Подсистема Reflection отсутствует

src

- Нет модели Reflection.
- Нет операций task_reflect и reflection_list.
- Нет учета reflection_budget и RecursiveReflectionWarning.

## Replan/PNR отсутствуют

src

- Нет task_replan (атомарный all-or-nothing).
- Нет checkPNR/STALL_DETECTED.
- TaskReplannedEvent есть только как тип события, без реальной операции:
domain_event.dart

## Планировочные операции из spec не реализованы

- task_breakdown
- task_bulk_plan
- task_bulk_add
Подтверждение: соответствующих файлов нет в core.

## История изменений (TaskHistory/audit trail) отсутствует

src

Есть, но расходится со спецификацией

### Неверные дефолты TaskCreate

- business_value должен быть 50, сейчас 0:
task_create_command.dart
- urgency_score должен быть 50, сейчас 0:
task_create_command.dart
- completion_policy должен быть all_children, сейчас manual:
task_create_command.dart

### Начальные поля Task расходятся

- plan_version по spec = 0, сейчас 1:
task_create_operation.dart
- last_action_type по spec = execution, сейчас planning:
task_create_operation.dart

### Нарушен инвариант last_progress_at

- По spec обновляется только при status -> completed.
- Сейчас обновляется и при start/fail/create:
task_start_operation.dart
task_fail_operation.dart
task_create_operation.dart

### Active Front трактует completed_ids как terminal

get_active_front_query.dart
В spec completed_ids = только completed.

### UUIDv7 не валидируется строго

task_id.dart
Сейчас проверяется любой UUID.

### get_active_front не возвращает softContext/relatedEntities как в spec

active_front_result.dart

Инфраструктурно не хватает для spec-уровня

1. SQLite-слой и транзакционный адаптер (сейчас in-memory + no-op transaction):
core_module.dart
2. Каскадные удаления и SQL-инварианты из schema (в core сейчас это не обеспечено на уровне хранилища).

Тестовые пробелы

1. Нет тестов для PNR/replan/knowledge/reflection (потому что функций нет).
2. Нет полноценных сценариев stalled > 1.0 и include_stalled behavior.
3. Нет тестов атомарности replan/task_breakdown.
4. Нет тестов TaskHistory.

## Roadmap реализации

Ниже приоритизированный roadmap для `tm_core`, чтобы быстро выйти на минимально совместимое v3.3, а потом добрать расширения.*

### Sprint 0: Выправить текущие расхождения со spec

- Исправить дефолты создания задачи: BV/US/completion policy в task_create_command.dart.
- Исправить стартовые поля `planVersion`/`lastActionType` в task_create_operation.dart.
- Привести `last_progress_at` к инварианту (обновление только при completed) в task_create_operation.dart, task_start_operation.dart, task_fail_operation.dart.
- В `get_active_front` считать completed только по `status=completed` в get_active_front_query.dart.
- Усилить валидацию UUIDv7 в task_id.dart.
- Добавить/обновить тесты под эти фиксы.

### Sprint 1: Knowledge vertical slice

- Ввести domain-модель KnowledgeEntity + TaskKnowledgeRef.
- Добавить порты репозиториев и in-memory адаптеры.
- Реализовать операции: `kg_entity_add/list/show/update`, `kg_task_link`, `kg_task_entities`.
- Реализовать `kg_auto_bridge` (идемпотентно, без дублей soft link).
- Покрыть unit + integration тестами (включая auto-bridge сценарии).

### Sprint 2: Reflection + Guardrails

- Ввести модель Reflection + репозиторий.
- Реализовать `task_reflect` и `reflection_list`.
- Добавить `reflection_budget` и ошибку budget exceeded.
- Реализовать `checkPNR` как чистый сервис + интеграцию в replan-пайплайн.
- Тесты на stall detection и “3 planning/reflection подряд”.

### Sprint 3: Atomic Replan + Planning Ops

- Реализовать `task_replan` с all-or-nothing через `TransactionPort`.
- Валидаторы `ReplanValidationError`, цикл strong-link, `StallDetected`.
- Инкремент `planVersion`, обновление `lastActionType`, публикация replan-события.
- Реализовать `task_breakdown`, `task_bulk_plan`, `task_bulk_add`.
- Интеграционные тесты на rollback при ошибке шага N.

### Sprint 4: Audit Trail + Persistence readiness

- Ввести TaskHistory и запись изменений на каждую мутацию.
- Подключить историю в операции task/project/link.
- Подготовить SQLite-адаптеры (минимум для tasks/links/projects; затем knowledge/reflection/history).
- Тесты каскадов и инвариантов на уровне репозиториев.

### Sprint 5: Spec parity polishing

- Добавить `softContext` и `relatedEntities` в результат active front.
- Доработать stalled-сценарии (`>1.0`, `include_stalled`) и тесты сортировки.
- Свести контракт ошибок к spec-кодам и финализировать README/доки.

## Что даст “минимально совместимый v3.3”

1. После Sprint 0-3 у вас уже будет рабочий контур: hierarchy + active front + knowledge + reflection + atomic replan + PNR.
2. Sprint 4-5 доводят до production-grade (audit, persistence, полнота контракта).

Рекомендуемый порядок PR

1. PR1: Sprint 0 (фиксы текущих расхождений).
2. PR2: Sprint 1 (knowledge).
3. PR3: Sprint 2 (reflection + PNR).
4. PR4: Sprint 3 (replan + planning ops).
5. PR5: Sprint 4-5 (audit + sqlite + polishing).

Если нужно, следующим сообщением дам детальный backlog для PR1 в формате “файл -> точечные изменения -> тест-кейсы”
