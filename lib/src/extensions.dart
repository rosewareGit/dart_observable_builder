extension Utils<T extends Object?> on T {
  R? let<R>(final R? Function(T self) transform) {
    final T? self = this;
    if (self == null) {
      return null;
    }
    return transform(self);
  }
}
