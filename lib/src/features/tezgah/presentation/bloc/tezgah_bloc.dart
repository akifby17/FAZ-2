import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tezgah.dart';
import '../../domain/usecases/get_tezgahlar.dart';

part 'tezgah_event.dart';
part 'tezgah_state.dart';

class TezgahBloc extends Bloc<TezgahEvent, TezgahState> {
  final GetTezgahlar getTezgahlar;

  TezgahBloc({required this.getTezgahlar})
      : super(const TezgahState.initial()) {
    on<TezgahFetched>(_onFetched);
    on<TezgahGroupChanged>(_onGroupChanged);
    on<TezgahToggleSelection>(_onToggle);
    on<TezgahSelectAll>(_onSelectAll);
  }

  Future<void> _onFetched(
      TezgahFetched event, Emitter<TezgahState> emit) async {
    emit(state.copyWith(status: TezgahStatus.loading));
    try {
      final List<Tezgah> items =
          await getTezgahlar.call(group: state.selectedGroup);
      final Set<String> uniqueGroups = items
          .map((e) => (e.groupName).trim())
          .where((g) => g.isNotEmpty)
          .toSet();
      final List<String> groupList = uniqueGroups.toList()..sort();
      emit(state.copyWith(
        status: TezgahStatus.success,
        items: _applyFilter(items, state.selectedGroup),
        allItems: items,
        groups: groupList,
      ));
    } catch (e) {
      emit(state.copyWith(status: TezgahStatus.failure));
    }
  }

  Future<void> _onGroupChanged(
      TezgahGroupChanged event, Emitter<TezgahState> emit) async {
    final String? group = event.group;
    final List<Tezgah> filtered = _applyFilter(state.allItems, group);
    emit(state.copyWith(selectedGroup: group, items: filtered));
  }

  void _onToggle(TezgahToggleSelection event, Emitter<TezgahState> emit) {
    final List<Tezgah> updated = state.items
        .map((e) =>
            e.id == event.tezgahId ? e.copyWith(isSelected: !e.isSelected) : e)
        .toList();
    emit(state.copyWith(items: updated));
  }

  void _onSelectAll(TezgahSelectAll event, Emitter<TezgahState> emit) {
    final List<Tezgah> updated = state.items
        .map((e) => e.copyWith(isSelected: event.selectAll))
        .toList();
    emit(state.copyWith(items: updated));
  }
}

List<Tezgah> _applyFilter(List<Tezgah> all, String? group) {
  if (group == null || group.isEmpty) return all;
  return all.where((e) => e.groupName == group).toList();
}
