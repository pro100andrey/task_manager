import 'dart:async';

/// Port for publishing and subscribing to events in the application.
///
/// Defines the contract for an event-driven communication system between
/// application components. Publishing an event makes it available to all
/// subscribers waiting for that event type.
abstract class EventBus {
  /// Publishes an event to all subscribers.
  ///
  /// The [event] is dispatched to all subscribers listening for events
  /// of the same type via [on].
  FutureOr<void> publish(Object event);

  /// Returns a stream of events of type [T].
  ///
  /// The returned [Stream] emits an event every time [publish] is called
  /// with an object of type [T].
  Stream<T> on<T>();

  /// Subscribes directly to events of type [T].
  ///
  /// Equivalent to [on].listen(), but allows fine-grained control via:
  /// * [onEvent] — callback invoked for each event.
  /// * [onError] — callback invoked on error; if null, errors are unhandled.
  /// * [onDone] — callback invoked when the stream is done.
  /// * [cancelOnError] — if true, the subscription is cancelled on the first
  /// error.
  StreamSubscription<T> listen<T>(
    void Function(T event) onEvent, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  });

  /// Disposes the event bus and releases associated resources.
  ///
  /// The event bus must not be used after calling this method.
  Future<void> dispose();
}
