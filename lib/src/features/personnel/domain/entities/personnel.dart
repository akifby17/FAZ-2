import 'package:equatable/equatable.dart';

class Personnel extends Equatable {
  final int id;
  final String name;

  const Personnel({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
