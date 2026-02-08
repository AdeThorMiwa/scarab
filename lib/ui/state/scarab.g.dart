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

String _$scarabHash() => r'9d26fe8fefb4e45dcde87af8a4569a601d62dcb0';

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

String _$chatMessagesHash() => r'd75409550336cb0d61c8db8006bb939b6d6f8fed';

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
