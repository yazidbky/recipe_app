import 'package:equatable/equatable.dart';

abstract class RegistreState extends Equatable {
  const RegistreState();

  @override
  List<Object> get props => [];
}

class RegistreInitial extends RegistreState {}

class RegistreLoading extends RegistreState {}

class RegistreSuccess extends RegistreState {
  final String message;

  const RegistreSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class RegistreFailure extends RegistreState {
  final String error;

  const RegistreFailure(this.error);

  @override
  List<Object> get props => [error];
}
