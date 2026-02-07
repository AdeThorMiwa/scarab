// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scarab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Scarab)
final scarabProvider = ScarabProvider._();

final class ScarabProvider extends $NotifierProvider<Scarab, ScarabState> {
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
  Override overrideWithValue(ScarabState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScarabState>(value),
    );
  }
}

String _$scarabHash() => r'7dff6958d5c54114d1a2b4ec30f30cc5d74ee2b0';

abstract class _$Scarab extends $Notifier<ScarabState> {
  ScarabState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScarabState, ScarabState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScarabState, ScarabState>,
              ScarabState,
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
