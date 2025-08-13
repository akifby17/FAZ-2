import 'package:equatable/equatable.dart';

class Operation extends Equatable {
  final String code;
  final String name;

  const Operation({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}
