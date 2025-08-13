part of 'tezgah_bloc.dart';

abstract class TezgahEvent extends Equatable {
  const TezgahEvent();

  @override
  List<Object?> get props => [];
}

class TezgahFetched extends TezgahEvent {}

class TezgahGroupChanged extends TezgahEvent {
  final String? group;
  const TezgahGroupChanged(this.group);
}

class TezgahToggleSelection extends TezgahEvent {
  final String tezgahId;
  const TezgahToggleSelection(this.tezgahId);
}

class TezgahSelectAll extends TezgahEvent {
  final bool selectAll;
  const TezgahSelectAll(this.selectAll);
}
