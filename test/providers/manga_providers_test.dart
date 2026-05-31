import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/models/chapter.dart';
import 'package:frontend/models/manga.dart';
import 'package:frontend/providers/manga_providers.dart';
import 'package:frontend/repositories/manga_repository.dart';

class MockMangaRepository extends Mock implements MangaRepository {}

void main() {
  late MockMangaRepository mockRepo;

  setUp(() {
    mockRepo = MockMangaRepository();
  });

  final sampleManga = Manga.fromJson({
    'id': 'manga-1',
    'title': 'One Piece',
    'slug': 'one-piece',
    'coverUrl': 'https://example.com/cover.jpg',
    'status': 'ONGOING',
  });

  group('ChapterListNotifier', () {
    test('loads chapters on initialization', () async {
      final chapters = [
        const Chapter(id: 'ch-1', mangaId: 'manga-1', number: 1.0),
        const Chapter(id: 'ch-2', mangaId: 'manga-1', number: 2.0),
      ];
      when(() => mockRepo.getChapters('manga-1', ascending: false))
          .thenAnswer((_) async => chapters);

      final notifier = ChapterListNotifier(mockRepo, 'manga-1');
      await Future.delayed(Duration.zero);

      expect(notifier.state.chapters.length, 2);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('sets error on failure', () async {
      when(() => mockRepo.getChapters('manga-1', ascending: false))
          .thenThrow(Exception('Network error'));

      final notifier = ChapterListNotifier(mockRepo, 'manga-1');
      await Future.delayed(Duration.zero);

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.chapters, isEmpty);
    });

    test('toggleSort reloads with reversed order', () async {
      when(() => mockRepo.getChapters('manga-1', ascending: false))
          .thenAnswer((_) async => [const Chapter(id: 'ch-1', mangaId: 'manga-1', number: 1.0)]);
      when(() => mockRepo.getChapters('manga-1', ascending: true))
          .thenAnswer((_) async => [const Chapter(id: 'ch-2', mangaId: 'manga-1', number: 2.0)]);

      final notifier = ChapterListNotifier(mockRepo, 'manga-1');
      await Future.delayed(Duration.zero);

      expect(notifier.state.ascending, false);

      await notifier.toggleSort();

      expect(notifier.state.ascending, true);
      verify(() => mockRepo.getChapters('manga-1', ascending: true)).called(1);
    });

    test('refresh reloads chapters', () async {
      when(() => mockRepo.getChapters('manga-1', ascending: false))
          .thenAnswer((_) async => []);

      final notifier = ChapterListNotifier(mockRepo, 'manga-1');
      await Future.delayed(Duration.zero);

      await notifier.refresh();

      verify(() => mockRepo.getChapters('manga-1', ascending: false)).called(2);
    });
  });

  group('FavoriteNotifier', () {
    test('initializes with isFavorite check', () async {
      when(() => mockRepo.isFavorite('manga-1')).thenAnswer((_) async => true);

      final notifier = FavoriteNotifier(mockRepo, 'manga-1');
      await Future.delayed(Duration.zero);

      expect(notifier.state, true);
    });

    test('toggle changes state and calls repository', () async {
      when(() => mockRepo.isFavorite('manga-1')).thenAnswer((_) async => false);
      when(() => mockRepo.toggleFavorite('manga-1')).thenAnswer((_) async {});

      final notifier = FavoriteNotifier(mockRepo, 'manga-1');
      await Future.delayed(Duration.zero);

      expect(notifier.state, false);

      await notifier.toggle();

      expect(notifier.state, true);
      verify(() => mockRepo.toggleFavorite('manga-1')).called(1);
    });
  });

  group('AllMangaNotifier', () {
    test('loads first page on init', () async {
      final mangas = List.generate(20, (i) => Manga.fromJson({
        'id': 'manga-$i',
        'title': 'Manga $i',
        'coverUrl': 'cover.jpg',
      }));
      when(() => mockRepo.fetchLatest(page: 0, limit: 20))
          .thenAnswer((_) async => mangas);

      final notifier = AllMangaNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state.items.length, 20);
      expect(notifier.state.page, 1);
      expect(notifier.state.hasMore, true);
    });

    test('hasMore is false when less than page size returned', () async {
      when(() => mockRepo.fetchLatest(page: 0, limit: 20))
          .thenAnswer((_) async => [sampleManga]);

      final notifier = AllMangaNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state.hasMore, false);
    });

    test('does not load when already loading', () async {
      when(() => mockRepo.fetchLatest(page: 0, limit: 20))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [sampleManga];
      });

      final notifier = AllMangaNotifier(mockRepo);
      await notifier.loadMore(); // Should be no-op while first load is in progress

      // Only called once from constructor
      verify(() => mockRepo.fetchLatest(page: 0, limit: 20)).called(1);
    });
  });

  group('ChapterListState', () {
    test('copyWith preserves error when not passed', () {
      final state = ChapterListState(error: 'some error');
      final copy = state.copyWith(isLoading: true);
      expect(copy.error, 'some error');
    });

    test('copyWith can set error to null', () {
      final state = ChapterListState(error: 'some error');
      final copy = state.copyWith(error: null);
      expect(copy.error, isNull);
    });
  });
}
