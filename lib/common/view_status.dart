/// Generic async status for cubit states (SRS §2.5 — explicit loading/error).
enum ViewStatus { initial, loading, success, failure }

extension ViewStatusX on ViewStatus {
  bool get isLoading => this == ViewStatus.loading;
  bool get isSuccess => this == ViewStatus.success;
  bool get isFailure => this == ViewStatus.failure;
}
