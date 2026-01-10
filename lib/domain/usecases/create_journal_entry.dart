import '../entities/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

/// Abstract use case for creating journal entries
abstract class CreateJournalEntry {
  /// Execute the use case
  Future<JournalEntry> call(JournalEntry entry);
}

/// Implementation of CreateJournalEntry use case
class CreateJournalEntryImpl implements CreateJournalEntry {
  final JournalRepository _repository;

  CreateJournalEntryImpl(this._repository);

  @override
  Future<JournalEntry> call(JournalEntry entry) async {
    return await _repository.createEntry(entry);
  }
}
