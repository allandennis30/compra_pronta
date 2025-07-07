abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<bool> delete(String id);
  Future<List<T>> search(String query);
}

abstract class BaseRepositoryWithCache<T> extends BaseRepository<T> {
  Future<void> clearCache();
  Future<void> refreshCache();
  bool get isCacheValid;
} 