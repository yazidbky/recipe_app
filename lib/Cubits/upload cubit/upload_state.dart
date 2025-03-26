abstract class UploadState {}

class UploadInitial extends UploadState {}

class UploadInProgress extends UploadState {}

class UploadSuccess extends UploadState {}

class UploadFailure extends UploadState {
  final String error;

  UploadFailure(this.error);
}
