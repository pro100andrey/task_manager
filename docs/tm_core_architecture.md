---
version: 3.0
date: 2026-05-04
status: accepted
---

# TM HTM — Архитектура пакета `tm_core`

## 1. Назначение

`tm_core` — это **чистое ядро** системы TM HTM, полностью независимое от инфраструктуры (БД, CLI, TUI, MCP).

Пакет реализует всю бизнес-логику согласно принципам **Clean Architecture**, **DDD** и **Event-Driven Architecture**. Внешние адаптеры (`tm_mcp` и др.) зависят от `tm_core`, но не наоборот.

**Ключевые цели:**

- Содержать всю бизнес-логику и правила системы.
- Быть максимально тестируемым (unit + integration без реальной БД).
- Обеспечивать атомарность мутаций через `TransactionPort`.
- Возвращать ожидаемые бизнес-ошибки через `Result<S, F>`, не через исключения.

---

## 2. Структура пакета

```txt
packages/tm_core/
├── lib/
│   ├── tm_core.dart                  ← Public API (только отсюда импортируют потребители)
│   └── src/
│       ├── application/
│       │   ├── guards/               ← Предусловия операций
│       │   ├── operations/           ← Мутирующие use cases
│       │   │   ├── operation.dart    ← Базовый контракт Operation<C, S, F>
│       │   │   ├── project/
│       │   │   └── task/
│       │   ├── queries/              ← Read-only use cases
│       │   │   ├── project/
│       │   │   └── task/
│       │   └── ports/                ← Интерфейсы (порты) внешних зависимостей и репозиториев
│       ├── domain/
│       │   ├── entities/             ← Бизнес-сущности (freezed)
│       │   ├── enums/                ← Перечисления домена
│       │   ├── events/               ← Domain Events (freezed sealed)
│       │   ├── exceptions/           ← Исключения для неожиданных сбоев
│       │   ├── result.dart           ← Result<T, E> — cross-cutting тип
│       │   └── value_objects/        ← Value Objects (extension types / sealed)
│       ├── di/                       ← Wiring через injectable + get_it
│       └── adapters/
│           ├── events/               ← Реализации DomainEventBus
│           ├── repositories/         ← In-memory реализации репозиториев
│           ├── tracing/              ← Реализация TracingPort
│           └── transaction/          ← Реализация TransactionPort
├── test/
│   ├── unit/                         ← Тесты домена и инфры изолированно
│   ├── integration/                  ← Тесты операций с in-memory зависимостями
│   └── fixtures/                     ← Фабрики тестовых данных
└── example/
```

---

## 3. Слои

### 3.1 Domain (`lib/src/domain/`)

Сердце системы. **Не зависит ни от одного другого слоя.** Содержит только бизнес-правила.

#### `entities/`

Иммутабельные агрегаты и сущности, сгенерированные через `freezed`.

| Класс | Поля |
| ----- | ---- |
| `Project` | `ProjectId id`, `ProjectName name`, `ProjectDescription? description` |
| `Task` | `TaskId id`, `TaskTitle title`, `TaskStatus status`, `TaskId? parentId`, `TaskDescription? description` |

#### `value_objects/`

Строго типизированные обёртки над примитивами. Каждый VO:

- Валидирует данные в конструкторе (бросает `ArgumentError` / `FormatException`).
- Предоставляет `.raw` геттер для доступа к значению.
- Реализован как `extension type` (нулевой рантайм-overhead).

| VO | Тип | Валидация |
| ---- | ----- | ----------- |
| `ProjectId` | `String` (UUID v7) | `UuidValidation.isValidUUID` |
| `ProjectName` | `String` | не пустой |
| `ProjectDescription` | `String` | не пустой, ≤ 500 символов |
| `ProjectRef` | sealed: `_ProjectIdRef` / `_ProjectNameRef` | — |
| `TaskId` | `String` (UUID v7) | `UuidValidation.isValidUUID` |
| `TaskTitle` | `String` | не пустой |
| `TaskDescription` | `String` | не пустой, ≤ 500 символов |

`ProjectRef` — полиморфная ссылка на проект. Предоставляет безопасный API:

```dart
sealed class ProjectRef {
  factory ProjectRef.id(ProjectId id);
  factory ProjectRef.name(ProjectName name);

  ProjectId?   get maybeId;    // null если это NameRef
  ProjectName? get maybeName;  // null если это IdRef
  String       get value;      // сырое строковое значение
}
```

#### `events/`

`DomainEvent` — `freezed` sealed класс. Все события системы живут здесь.

```dart
@freezed
sealed class DomainEvent {
  const factory DomainEvent.projectCreated({required Project project})   = ProjectCreatedEvent;
  const factory DomainEvent.taskCreated({required TaskId taskId})        = TaskCreatedEvent;
  const factory DomainEvent.taskCompleted({required TaskId taskId})      = TaskCompletedEvent;
  const factory DomainEvent.taskReplanned({required TaskId taskId})      = TaskReplannedEvent;
}
```

События публикуются через `DomainEventBus` **после** успешного коммита транзакции.

#### `exceptions/`

Исключения для **непредвиденных** сбоев (программные ошибки, нарушения инвариантов).
Ожидаемые бизнес-ошибки возвращаются через `Result<S, F>`, а не бросаются.

```dart
class ProjectNotFound implements Exception { final String ref; }
class ProjectNameAlreadyExists implements Exception { final String name; }
```

#### `result.dart`

Cross-cutting sealed тип для моделирования ожидаемых исходов операций.

```dart
sealed class Result<T, E> {
  bool get isSuccess;
  bool get isFailure;
  R fold<R>({required R Function(T) onSuccess, required R Function(E) onFailure});
}
final class Success<T, E> extends Result<T, E> { final T value; }
final class Failure<T, E> extends Result<T, E> { final E error; }
```

---

### 3.2 Application (`lib/src/application/`)

Оркестрирует выполнение бизнес-сценариев. Зависит от `domain`, но не от `infra`.

#### `operations/`

Мутирующие use cases. Базовый контракт:

```dart
abstract class Operation<C, S, F> {
  Future<Result<S, F>> execute(C command);
}
```

Каждая операция:

1. Принимает типизированный **command** объект.
2. Выполняется внутри `TransactionPort.run()`.
3. Оборачивается в `TracingPort.trace()`.
4. Возвращает `Result<S, F>` — никогда не бросает ожидаемых ошибок.
5. Публикует `DomainEvent` после успешного коммита.

**Текущие операции:**

| Операция | Command | Success | Failure |
| -------- | ------- | ------- | ------- |
| `ProjectCreateOperation` | `ProjectCreateCommand` | `Project` | `ProjectNameAlreadyExists` |
| `TaskDoneOperation` | — | — | — *(в разработке)* |

**Пример — `ProjectCreateOperation`:**

```dart
class ProjectCreateOperation
    extends Operation<ProjectCreateCommand, Project, ProjectNameAlreadyExists> {

  @override
  Future<Result<Project, ProjectNameAlreadyExists>> execute(
    ProjectCreateCommand command,
  ) => _tracing.trace('ProjectCreateOperation', () =>
      _transaction.run(() async {
        final ref = ProjectRef.name(ProjectName(command.name));
        if (await _repository.getByRef(ref) != null) {
          return Failure(ProjectNameAlreadyExists(command.name));
        }
        final project = Project(id: ProjectId.generate(), ...);
        final saved   = await _repository.save(project);
        await _bus.publish(ProjectCreatedEvent(project: saved));
        return Success(saved);
      }),
    );
}
```

#### `queries/`

Read-only use cases. Не используют транзакции и не публикуют события.

| Query | Возвращает |
| ----- | ---------- |
| `GetAllProjectsQuery` | `Future<List<Project>>` |
| `GetCurrentProjectQuery` | `Future<Project?>` |

#### `guards/`

Предусловия, которые вызываются в начале операции. Бросают `Exception` при нарушении.

| Guard | Проверяет |
| ----- | ---------- |
| `ProjectExistsGuard` | Проект с данным `ProjectRef` существует |

#### `ports/`

Абстракции внешних зависимостей и репозиториев — только интерфейсы, без реализаций.

| Порт | Контракт |
| ----- | ---------- |
| `TransactionPort` | `Future<T> run<T>(Future<T> Function() action)` |
| `DomainEventBus` | `publish`, `listen<T>`, `on<T>`, `dispose` |
| `TracingPort` | `trace<T>(name, action, {attributes})` |
| `ProjectRepository` | `getById`, `getByRef`, `save`, `getCurrentProject`, `switchCurrentProject`, `getAllProjects` |

---

### 3.3 Adapters (`lib/src/adapters/`)

Реализует контракты `application/ports/`.
**Зависит от application, но application не зависит от adapters.**

| Реализация | Файл | Интерфейс | Описание |
| ----------- | ---- | ----------- | ---------- |
| `DomainEventBusImpl` | `adapters/events/domain_event_bus_impl.dart` | `DomainEventBus` | Простой broadcast stream |
| `OrderedDomainEventBusImpl` | `adapters/events/ordered_domain_event_bus_impl.dart` | `DomainEventBus` | Queue-based, гарантирует порядок событий |
| `MemProjectsRepositoryImpl` | `adapters/repositories/mem_projects_repository_impl.dart` | `ProjectRepository` | In-memory хранилище (`Map<ProjectId, Project>`) |
| `LoggingTracingPortImpl` | `adapters/tracing/logging_tracing_port_impl.dart` | `TracingPort` | Логирует имя операции и атрибуты |
| `NoOpTransactionPortImpl` | `adapters/transaction/no_op_transaction_port_impl.dart` | `TransactionPort` | Нет транзакций (для тестов и in-memory) |

---

### 3.4 DI (`lib/src/di/`)

Связывает интерфейсы с реализациями через `injectable` + `get_it`.

```dart
// Точка входа
await configureTmCoreDependencies();

// После этого доступно:
GetIt.instance<ProjectCreateOperation>()
GetIt.instance<DomainEventBus>()
```

По умолчанию регистрируется `OrderedDomainEventBusImpl` (гарантированный порядок событий).

---

## 4. Правила слоёв

```txt
domain  ←  application  ←  adapters
                ↑
               di
```

1. `domain` не имеет зависимостей внутри пакета.
2. `application` зависит только от `domain`.
3. `adapters` реализует контракты из `application/ports/`.
4. `di` знает обо всех слоях и соединяет их.
5. Потребители пакета импортируют **только** из `lib/tm_core.dart`.

---

## 5. Флоу мутирующей операции

```txt
Адаптер (CLI / MCP / TUI)
  │
  ▼
Operation.execute(command)
  │
  ├─► TracingPort.trace(...)        ← оборачивает весь вызов
  │     │
  │     └─► TransactionPort.run(...)  ← атомарная единица
  │           │
  │           ├─► Guard.check(...)    ← предусловия (до изменений)
  │           │
  │           ├─► Repository.getBy*  ← загрузка данных
  │           │
  │           ├─► [бизнес-логика / Value Object валидация]
  │           │
  │           ├─► Repository.save(...)  ← сохранение
  │           │
  │           └─► DomainEventBus.publish(...)  ← события после коммита
  │
  └─► Result<Success, Failure>  →  Адаптер
```

**Правила флоу:**

- Ожидаемые бизнес-ошибки → `Failure(...)`, не `throw`.
- Непредвиденные сбои (нарушение инварианта, I/O) → `throw Exception`.
- События публикуются только при `Success` пути.
- Трейсинг охватывает полный жизненный цикл операции включая ошибки.

---

## 6. Флоу read-only запроса

```txt
Адаптер
  │
  ▼
Query.execute([params])
  │
  └─► Repository.get*(...)  →  данные / null / список
  │
  └─► [опционально: фильтрация / маппинг]
  │
  └─► List<T> / T?  →  Адаптер
```

Запросы не используют `TransactionPort`, не публикуют события и не мутируют состояние.

---

## 7. Флоу событий

```txt
Operation
  │
  └─► DomainEventBus.publish(DomainEvent)
          │
          ├─► OrderedDomainEventBusImpl: помещает в очередь, обрабатывает последовательно
          │
          └─► Подписчики (listen<T> / on<T>):
                - другие части application
                - адаптеры (например, tm_mcp транслирует события в MCP notifications)
```

`OrderedDomainEventBusImpl` гарантирует, что события обрабатываются в порядке публикации, даже если обработчик асинхронный.

---

## 8. Public API (`lib/tm_core.dart`)

Всё, что нужно потребителям пакета, экспортируется из одного файла. Импорт из `src/` напрямую не допускается.

```dart
export 'src/application/operations/operation.dart';
export 'src/application/operations/project/project_create_command.dart';
export 'src/application/operations/project/project_create_operation.dart';
export 'src/application/queries/project/get_all_projects_query.dart';
export 'src/application/queries/project/get_current_project_query.dart';
export 'src/di/injection.dart';
export 'src/domain/entities/project.dart';
export 'src/domain/entities/task.dart';
export 'src/domain/events/domain_event.dart';
export 'src/domain/exceptions/project_exceptions.dart';
export 'src/domain/result.dart';
export 'src/domain/value_objects/value_objects.dart';
```

---

## 9. Тестирование

| Уровень | Папка | Что тестируется |
| ----- | ------- | ----------------- |
| Unit | `test/unit/domain/` | `Result`, Value Objects, чистые функции |
| Unit | `test/unit/adapters/` | `DomainEventBus` реализации |
| Integration | `test/integration/operations/` | Операции с in-memory зависимостями |
| Fixtures | `test/fixtures/` | Фабрики и builders тестовых данных |

**Правила тестов:**

- Integration-тесты используют `MemProjectsRepositoryImpl`, `NoOpTransactionPortImpl`, `DomainEventBusImpl`.
- Unit-тесты не используют DI — зависимости передаются напрямую.
- Ни один тест не зависит от внешнего I/O или файловой системы.

---

## 10. Definition of Done

- `dart analyze` в `packages/tm_core` — No issues.
- Все операции возвращают `Result<S, F>`.
- Нет `UnimplementedError` в активно используемых методах.
- Нет ожидаемых бизнес-ошибок через `throw` (только через `Failure`).
- Потребители пакета не импортируют из `src/`.
