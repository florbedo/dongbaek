class Counter {
  static int _count = 0;

  static int next() {
    return ++_count;
  }
}
