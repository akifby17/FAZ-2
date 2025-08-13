part of 'tezgah_bloc.dart';

enum TezgahStatus { initial, loading, success, failure }

class TezgahState extends Equatable {
  final TezgahStatus status;
  final List<Tezgah> items; // filtered list
  final List<Tezgah> allItems; // full list
  final String? selectedGroup;
  final List<String> groups; // unique available groups

  const TezgahState({
    required this.status,
    required this.items,
    required this.allItems,
    required this.selectedGroup,
    required this.groups,
  });

  const TezgahState.initial()
      : status = TezgahStatus.initial,
        items = const <Tezgah>[],
        allItems = const <Tezgah>[],
        selectedGroup = null,
        groups = const <String>[];

  TezgahState copyWith({
    TezgahStatus? status,
    List<Tezgah>? items,
    List<Tezgah>? allItems,
    String? selectedGroup,
    List<String>? groups,
  }) {
    return TezgahState(
      status: status ?? this.status,
      items: items ?? this.items,
      allItems: allItems ?? this.allItems,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      groups: groups ?? this.groups,
    );
  }

  @override
  List<Object?> get props => [status, items, allItems, selectedGroup, groups];
}
