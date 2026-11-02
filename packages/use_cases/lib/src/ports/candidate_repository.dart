import 'package:domain/domain.dart';

abstract interface class CandidateRepository {
  Future<List<Candidate>> candidatesWithIds(Set<UserId> ids);
}
