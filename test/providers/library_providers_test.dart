import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/models/manga.dart';
import 'package:frontend/models/reading_history.dart';
import 'package:frontend/providers/library_providers.dart';
import 'package:frontend/repositories/library_repository.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository mockRepo;

  setUp(() {
    mockRepo = MockLibraryRepository();
  });

  final sampleHistory = ReadingHistory(
    id: '1',
    mangaId: 'manga-1',
    mangaTitle: 'One Piece',
    coverUrl: 'cover.jpg',
    lastChapterId: 'ch-100',
    lastChapterNumber: 100.0,
    lastReadAt: DateTime(2024, 6, 1),
    totalChapters: 1100,
    chaptersRead: 100,
  );

  group('ReadingHistoryNotifier', () {
    test('loads history on init', () async {
      when(() => mockRepo.getReadingHistory())
          .thenAnswer((_) async => [sampleHistory]);

      final notifier = ReadingHistoryNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state.value?.length, 1);
      expect(notifier.state.value?.first.mangaTitle, 'One Piece');
    });

    test('sets error state on failure', () async {
      when(() => mockRepo.getReadingHistory())
          .thenThrow(Exception('Network error'));

      final notifier = ReadingHistoryNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state, isA<AsyncError>());
    });

    test('removeEntry calls repo and reloads', () async {
      when(() => mockRepo.getReadingHistory())
          .thenAnswer((_) async => [sampleHistory]);
      when(() => mockRepo.removeFromHistory('1'))
          .thenAnswer((_) async {});

      final notifier = ReadingHistoryNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      await notifier.removeEntry('1');

      verify(() => mockRepo.removeFromHistory('1')).called(1);
      verify(() => mockRepo.getReadingHistory()).called(2);
    });

    test('refresh reloads data', () async {
      when(() => mockRepo.getReadingHistory())
          .thenAnswer((_) async => []);

      final notifier = ReadingHistoryNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      await notifier.refresh();

      verify(() => mockRepo.getReadingHistory()).called(2);
    });
  });

  group('FavoritesNotifier', () {
    test('loads favorites on init', () async {
      final manga = Manga.fromJson({
        'id': 'manga-1',
        'title': 'Fav Manga',
        'coverUrl': 'cover.jpg',
      });
      when(() => mockRepo.getFavorites())
          .thenAnswer((_) async => [manga]);

      final notifier = FavoritesNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state.value?.length, 1);
    });

    test('sets error on failure', () async {
      when(() => mockRepo.getFavorites())
          .thenThrow(Exception('Error'));

      final notifier = FavoritesNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state, isA<AsyncError>());
    });

    test('refresh reloads', () async {
      when(() => mockRepo.getFavorites())
          .thenAnswer((_) async => []);

      final notifier = FavoritesNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      await notifier.refresh();

      verify(() => mockRepo.getFavorites()).called(2);
    });
  });
}
