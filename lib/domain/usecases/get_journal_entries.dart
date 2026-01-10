import '../entities/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

/// Use case for getting journal entries
abstract class GetJournalEntries {
  /// Execute the use case
  Future<List<JournalEntry>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });
}

/// Implementation of GetJournalEntries use case
class GetJournalEntriesImpl implements GetJournalEntries {
  final JournalRepository _repository;

  GetJournalEntriesImpl(this._repository);

  @override
  Future<List<JournalEntry>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getEntries(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }
}