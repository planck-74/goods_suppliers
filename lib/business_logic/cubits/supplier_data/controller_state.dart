abstract class ControllerState {}

class ControllerInitial extends ControllerState {}

class ControllerLoaded extends ControllerState {
  final List searchResults;

  ControllerLoaded(this.searchResults);
}

class ControllerLoading extends ControllerState {}

class ControllerError extends ControllerState {
  final String message;

  ControllerError(this.message);
}
