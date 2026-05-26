import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/proposal_record.dart';

abstract class ProposalStoreRepository {
  Stream<List<ProposalRecord>> watchRecentProposals({int limit = 20});

  Future<Result<ProposalRecord?>> getProposal(String id);

  Future<Result<String>> createDraft(ProposalDraftInput input);

  Future<Result<void>> updateDraft(String id, ProposalDraftInput input);

  Future<Result<void>> saveGeneratedProposal(GeneratedProposalInput input);

  Future<Result<void>> markNeedsClarification(ClarificationProposalInput input);

  Future<Result<void>> archiveProposal(String id);
}
