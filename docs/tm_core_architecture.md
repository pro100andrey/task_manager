---
version: 3.1
date: 2026-05-06
status: accepted
---

# TM HTM: Архитектура пакета tm_core

## 1. Назначение

`tm_core` реализует прикладное и доменное ядро TM HTM и не зависит от внешних интерфейсов (CLI, TUI, MCP).

Пакет следует принципам Clean Architecture:

- бизнес-модель и правила в domain;
- use case-слой в application;
- in-memory/adapters реализации инфраструктурных контрактов;
- композиция зависимостей через DI.

Текущее состояние пакета: в ядре реализованы project/task/task_link операции и Active Front query, а части knowledge/reflection/replan пока не включены в архитектурный контур `tm_core`.

## 2. Структура пакета

```txt
packages/tm_core/
├── lib/
│   ├── tm_core.dart
│   └── src/
│       ├── domain/
│       │   ├── entities/
│       │   ├── enums/
│       │   ├── events/
│       │   ├── exceptions/
│       │   ├── services/
│       │   ├── value_objects/
│       │   └── result.dart
│       ├── application/
│       │   ├── operations/
│       │   │   ├── project/
│       │   │   ├── task/
│       │   │   └── task_link/
│       │   ├── queries/
│       │   │   ├── project/
│       │   │   └── task/
│       │   └── ports/
│       ├── adapters/
│       │   ├── behaviors/
│       │   ├── events/
│       │   ├── repositories/
│       │   ├── tracing/
│       │   └── transaction/
│       └── di/
│           └── modules/
├── test/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
└── example/
```

Примечание: отдельной директории `application/guards` нет. Роль guard'ов выполняют policy-классы в `application/operations/**/policy`.

## 3. Domain

### 3.1 Entities

Сущности объявлены через freezed и иммутабельны.

- `Project`
  - `id`, `name`, `createdAt`, `description?`
- `Task`
  - базовые поля задачи;
  - иерархия (`parentId`), контекст (`contextState`), политика завершения (`completionPolicy`), приоритетные оси (`businessValue`, `urgencyScore`), lifecycle-поля (`status`, `lastActionType`, `lastProgressAt`, `completedAt`), metadata/tags;
- `TaskLink`
  - направленная связь между задачами (`fromTaskId -> toTaskId`) с `linkType` (`strong`/`soft`) и `label?`.

### 3.2 Value Objects

Используются extension type/typed wrappers для доменных примитивов:

- project: `ProjectId`, `ProjectName`, `ProjectDescription`, `ProjectRef`;
- task: `TaskId`, `TaskTitle`, `TaskDescription`, `TaskAlias`.

`ProjectRef` поддерживает оба варианта резолва (id/name) через `ProjectIdRef`/`ProjectNameRef`.

### 3.3 Enums

Ключевые перечисления:

- `TaskStatus`
- `TaskContextState`
- `TaskCompletionPolicy`
- `TaskLastActionType`
- `LinkType`

### 3.4 Domain Services

Чистые функции в domain:

- `task_graph.dart`: построение strong adjacency, `detectCycle`, `topologicalSort`, `findReadyTasks`;
- `task_domain_services.dart`: `normalizeAlias`, `isCompletable`.

### 3.5 Domain Events

`DomainEvent` реализован как sealed/freezed и включает project/task/task_link события:

- project: create/rename/change_description/delete/switch;
- task: create/start/complete/fail/cancel/hold/delete/replanned/update/context_changed/moved/alias_renamed;
- task_link: added/removed.

Важно: наличие типа события не означает наличие соответствующего use case. Например, `taskReplanned` определен как событие, но операция `task_replan` в `tm_core` пока отсутствует.

### 3.6 Ошибки и Result

- ожидаемые исходы операций возвращаются через `Result<S, F>`;
- `Success`/`Failure` используются во всех operation use case;
- исключения в domain остаются для нештатных случаев/валидации VO.

## 4. Application

### 4.1 Operations

Базовый контракт `Operation<C, S, F>`:

- `execute()` запускает pipeline;
- применяет `preconditionPolicies`;
- выполняет `run()`;
- применяет `invariantPolicies`;
- вызывает `collectAndPublishEvents` и `mapResult`.

Политики задаются через:

- `OperationPolicy`
- `PreconditionPolicy`
- `InvariantPolicy`
- `OperationPolicySet`

Реализованные operation-группы:

- Project
  - `ProjectCreateOperation`
  - `ProjectRenameOperation`
  - `ProjectChangeDescriptionOperation`
  - `ProjectUpdateOperation`
  - `ProjectDeleteOperation`
  - `ProjectSwitchOperation`

- Task
  - `TaskCreateOperation`
  - `TaskStartOperation`
  - `TaskDoneOperation`
  - `TaskFailOperation`
  - `TaskCancelOperation`
  - `TaskHoldOperation`
  - `TaskDeleteOperation`
  - `TaskUpdateOperation`
  - `TaskSetContextOperation`
  - `TaskMoveOperation`
  - `TaskRenameAliasOperation`

- TaskLink
  - `TaskLinkAddOperation`
  - `TaskLinkRemoveOperation`

### 4.2 Queries

Реализованные read-only use case:

- `GetAllProjectsQuery`
- `GetCurrentProjectQuery`
- `GetActiveFrontQuery`

`GetActiveFrontQuery` возвращает агрегированный read-model (`ActiveFrontResult`) с:

- `front`
- `waitingChildren`
- `blockedByStrong`
- `stalledTasks`

Логика включает вычисление EP/Hard Cap/depth/staleness на уровне query.

### 4.3 Ports

Порты application-слоя:

- `ProjectRepository`
- `TaskRepository`
- `TaskLinkRepository`
- `DomainEventBus`
- `TracingPort`
- `TransactionPort`

## 5. Adapters

### 5.1 Behaviors (pipeline middleware)

- `TracingBehavior`: оборачивает операцию через `TracingPort.trace(...)` и отдельно логирует `Failure` как domain failure;
- `TransactionBehavior`: оборачивает операцию через `TransactionPort.run(...)`.

### 5.2 Events

- `DomainEventBusImpl`: broadcast stream;
- `OrderedDomainEventBusImpl`: очередь + последовательная публикация событий.

### 5.3 Repositories

In-memory реализации:

- `MemProjectsRepositoryImpl`
- `MemTasksRepositoryImpl`
- `MemTaskLinkRepositoryImpl`

### 5.4 Tracing/Transaction

- `LoggingTracingPortImpl` + `TracingLoggingConfig`;
- `NoOpTransactionPortImpl`.

## 6. DI

DI конфигурация построена на `injectable + get_it`:

- `CoreModule`: биндинги портов на адаптеры + `OperationPipeline`;
- `modules/ApplicationModule`: регистрации operation/query сервисов;
- `configureTmCoreDependencies(...)` в `di/injection.dart`.

Параметры инициализации:

- `environment`;
- `useOrderedBus` (опциональная замена реализации `DomainEventBus` на `OrderedDomainEventBusImpl`).

## 7. Потоки выполнения

### 7.1 Мутирующий use case

```txt
Adapter -> Operation.execute(command)
        -> OperationPipeline
           -> TracingBehavior
           -> TransactionBehavior
              -> policies (preconditions/invariants)
              -> run(command)
              -> Result<Success|Failure>
```

Важно:

- публикация событий выполняется на success-path конкретной операции;
- при текущем `NoOpTransactionPortImpl` транзакционная семантика фактически passthrough;
- гарантия "событие строго после коммита БД" появится только с транзакционным persistent adapter.

### 7.2 Query use case

```txt
Adapter -> Query.execute(params)
        -> repository read(s)
        -> projection/aggregation
        -> DTO/read model
```

Query не публикуют события и не изменяют состояние.

## 8. Public API

Единая точка импорта для потребителей: `lib/tm_core.dart`.

Файл экспортирует:

- operation framework;
- команды/ошибки/операции project/task/task_link;
- project/task/task_link queries;
- domain entities/enums/events/services/exceptions/result;
- DI bootstrap;
- часть adapter-утилит, используемых в интеграционных сценариях.

Практика для потребителей: импортировать только `package:tm_core/tm_core.dart`.

## 9. Тестирование

Фактическое покрытие тестами:

- unit/domain: `result`, value objects, `task_graph`, `task_domain_services`;
- unit/adapters: event bus;
- integration/operations:
  - project create/update/delete/switch;
  - task lifecycle и editing;
  - task links;
  - active front query.

Тесты выполняются с in-memory репозиториями и без внешнего I/O.

## 10. Границы текущей версии

В текущем `tm_core` отсутствуют отдельные подсистемы:

- knowledge entities/refs;
- reflection log и budget;
- atomic replan + PNR;
- audit trail (`task_history`);
- SQLite persistence слой.

Это сознательно фиксирует текущую архитектурную границу пакета и не противоречит разделению core/adapters.

## 11. Definition of Done для текущего контура

- `dart analyze` в `packages/tm_core` без критических замечаний.
- Все реализованные operations возвращают `Result<S, F>`.
- Pipeline применяется ко всем operation use case.
- Реализованные integration тесты проходят на in-memory контурах.
- Публичный контракт доступен через `lib/tm_core.dart`.
