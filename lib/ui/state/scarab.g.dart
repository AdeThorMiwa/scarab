// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scarab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Scarab)
final scarabProvider = ScarabProvider._();

final class ScarabProvider extends $NotifierProvider<Scarab, AppState> {
  ScarabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scarabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scarabHash();

  @$internal
  @override
  Scarab create() => Scarab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppState>(value),
    );
  }
}

String _$scarabHash() => r'31065aac1ae19b884203097646eab5957ccee262';

abstract class _$Scarab extends $Notifier<AppState> {
  AppState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppState, AppState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppState, AppState>,
              AppState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(chatMessages)
final chatMessagesProvider = ChatMessagesProvider._();

final class ChatMessagesProvider
    extends
        $FunctionalProvider<
          List<ChatMessage>,
          List<ChatMessage>,
          List<ChatMessage>
        >
    with $Provider<List<ChatMessage>> {
  ChatMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatMessagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesHash();

  @$internal
  @override
  $ProviderElement<List<ChatMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ChatMessage> create(Ref ref) {
    return chatMessages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ChatMessage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ChatMessage>>(value),
    );
  }
}

String _$chatMessagesHash() => r'13334f41652949a56f5b59bad670ae42d8351f5e';

@ProviderFor(upcomingSessions)
final upcomingSessionsProvider = UpcomingSessionsProvider._();

final class UpcomingSessionsProvider
    extends $FunctionalProvider<List<Session>, List<Session>, List<Session>>
    with $Provider<List<Session>> {
  UpcomingSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingSessionsHash();

  @$internal
  @override
  $ProviderElement<List<Session>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Session> create(Ref ref) {
    return upcomingSessions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Session> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Session>>(value),
    );
  }
}

String _$upcomingSessionsHash() => r'a51106e0a12634eece8ad27eabe3e8e2b26097d3';

@ProviderFor(executionLog)
final executionLogProvider = ExecutionLogProvider._();

final class ExecutionLogProvider
    extends
        $FunctionalProvider<
          List<ExecutionLogEntry>,
          List<ExecutionLogEntry>,
          List<ExecutionLogEntry>
        >
    with $Provider<List<ExecutionLogEntry>> {
  ExecutionLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'executionLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$executionLogHash();

  @$internal
  @override
  $ProviderElement<List<ExecutionLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ExecutionLogEntry> create(Ref ref) {
    return executionLog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExecutionLogEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExecutionLogEntry>>(value),
    );
  }
}

String _$executionLogHash() => r'5f8668e8ca82fd83c4ff54071816bb0bf29e549f';
