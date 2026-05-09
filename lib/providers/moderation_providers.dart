import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report.dart';
import '../repositories/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return FakeModerationRepository();
});

final reportsFilterProvider = StateProvider<ReportStatus?>((ref) => null);
final reportsTypeFilterProvider = StateProvider<ReportType?>((ref) => null);

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<List<Report>>>(
  (ref) {
    final status = ref.watch(reportsFilterProvider);
    final type = ref.watch(reportsTypeFilterProvider);
    return ReportsNotifier(
      ref.read(moderationRepositoryProvider),
      status: status,
      type: type,
    );
  },
);

class ReportsNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  ReportsNotifier(
    this._repo, {
    this.status,
    this.type,
  }) : super(const AsyncValue.loading()) {
    _load();
  }

  final ModerationRepository _repo;
  final ReportStatus? status;
  final ReportType? type;

  Future<void> _load() async {
    try {
      final reports = await _repo.getReports(status: status, type: type);
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resolveReport(String id, String resolution) async {
    await _repo.resolveReport(id, resolution);
    await _load();
  }

  Future<void> dismissReport(String id, String reason) async {
    await _repo.dismissReport(id, reason);
    await _load();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}

final reportDetailProvider =
    FutureProvider.family<Report, String>((ref, id) async {
  return ref.read(moderationRepositoryProvider).getReportById(id);
});
