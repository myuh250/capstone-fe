import '../models/chapter.dart';
import '../models/manga.dart';

abstract class MangaRepository {
  Future<List<Manga>> fetchFeatured();
  Future<List<Manga>> fetchLatest({int page = 1, int limit = 20});
  Future<List<Manga>> fetchPopular({int page = 1, int limit = 20});
  Future<List<Manga>> fetchCompleted({int page = 1, int limit = 20});
  Future<Manga> getById(String id);
  Future<List<Manga>> search(
    String query, {
    List<String> genres = const [],
    MangaStatus? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  });
  Future<List<Chapter>> getChapters(String mangaId, {bool ascending = false});
  Future<List<Manga>> getRelated(String mangaId);
  Future<void> toggleFavorite(String mangaId);
  Future<bool> isFavorite(String mangaId);
}

class FakeMangaRepository implements MangaRepository {
  static final _allManga = <Manga>[
    const Manga(
      id: '1',
      title: 'One Piece',
      description:
          'Gol D. Roger was known as the King of the Pirates, the strongest and most infamous being to have sailed the Grand Line. The capture and death of Roger by the World Government brought a change throughout the world. His last words before his death revealed the location of the greatest treasure in the world, One Piece.',
      coverUrl:
          'https://uploads.mangadex.org/covers/a1c7c817-4e59-43b7-9365-09675a149a6f/1a5a20b4-05d9-4b77-9f85-7be7f21dc490.jpg',
      tags: ['Action', 'Adventure', 'Comedy', 'Fantasy'],
      status: MangaStatus.ongoing,
      averageRating: 4.8,
      totalChapters: 1100,
      author: 'Eiichiro Oda',
    ),
    const Manga(
      id: '2',
      title: 'Naruto',
      description:
          'Naruto Uzumaki, a mischievous adolescent ninja, struggles as he searches for recognition and dreams of becoming the Hokage, the village\'s leader and strongest ninja.',
      coverUrl:
          'https://uploads.mangadex.org/covers/cfc3d743-bd89-48e2-991f-63e680cc4edf/291ef1d6-3a2f-4f5a-9b47-0b69a2a745de.jpg',
      tags: ['Action', 'Adventure', 'Martial Arts'],
      status: MangaStatus.completed,
      averageRating: 4.5,
      totalChapters: 700,
      author: 'Masashi Kishimoto',
    ),
    const Manga(
      id: '3',
      title: 'Attack on Titan',
      description:
          'In a world where humanity lives inside cities surrounded by enormous walls due to the Titans, gigantic humanoid creatures who devour humans seemingly without reason.',
      coverUrl:
          'https://uploads.mangadex.org/covers/304ceac3-8cdb-4fe7-acf7-2b9b3c4c3172/563bd270-9068-4b46-9e03-47fd7b5d4f27.jpg',
      tags: ['Action', 'Drama', 'Horror', 'Mystery'],
      status: MangaStatus.completed,
      averageRating: 4.9,
      totalChapters: 139,
      author: 'Hajime Isayama',
    ),
    const Manga(
      id: '4',
      title: 'Demon Slayer',
      description:
          'A youth begins a journey to restore his sister\'s humanity after she is turned into a demon and to avenge the deaths of his family members.',
      coverUrl:
          'https://uploads.mangadex.org/covers/32d76d19-8a05-4db0-a917-d6b347d68ece/cac24a85-f90f-4efb-a836-a19f7fef7bcd.jpg',
      tags: ['Action', 'Fantasy', 'Historical', 'Supernatural'],
      status: MangaStatus.completed,
      averageRating: 4.7,
      totalChapters: 205,
      author: 'Koyoharu Gotouge',
    ),
    const Manga(
      id: '5',
      title: 'My Hero Academia',
      description:
          'In a world where people with superpowers (known as Quirks) are the norm, Izuku Midoriya has dreams of one day becoming a hero despite being bullied by his classmates for not having a Quirk.',
      coverUrl:
          'https://uploads.mangadex.org/covers/67a28e8e-8d59-4779-bf57-2fb31db03b2b/0827b519-e82a-4409-81e7-c57c4a56cbae.jpg',
      tags: ['Action', 'School Life', 'Superhero'],
      status: MangaStatus.ongoing,
      averageRating: 4.4,
      totalChapters: 420,
      author: 'Kohei Horikoshi',
    ),
    const Manga(
      id: '6',
      title: 'Fullmetal Alchemist',
      description:
          'Two brothers search for a Philosopher\'s Stone after an attempt to revive their deceased mother goes awry and leaves them in damaged physical forms.',
      coverUrl:
          'https://uploads.mangadex.org/covers/dbc9f9f8-be1f-45bf-8e6d-2c15bc63ae3e/2e5e2eef-1f8a-4f02-a3f1-41e88de7cd1b.jpg',
      tags: ['Action', 'Adventure', 'Drama', 'Fantasy'],
      status: MangaStatus.completed,
      averageRating: 4.9,
      totalChapters: 108,
      author: 'Hiromu Arakawa',
    ),
    const Manga(
      id: '7',
      title: 'Dragon Ball Z',
      description:
          'After learning that he is from another planet, a warrior named Goku and his friends are prompted to defend it from an onslaught of villains.',
      coverUrl:
          'https://uploads.mangadex.org/covers/a50b99cd-7fa7-467b-939d-f7ddb34f0fda/2ffe9c5c-8beb-463b-bfad-ac04ed14f96b.jpg',
      tags: ['Action', 'Adventure', 'Comedy', 'Sci-Fi'],
      status: MangaStatus.completed,
      averageRating: 4.6,
      totalChapters: 325,
      author: 'Akira Toriyama',
    ),
    const Manga(
      id: '8',
      title: 'Tokyo Ghoul',
      description:
          'A Tokyo college student is attacked by a ghoul and is saved by another ghoul, whose organs are transplanted into him after she is critically wounded.',
      coverUrl:
          'https://uploads.mangadex.org/covers/b67f2c41-2e24-4b2a-9a6e-70b9d6ec67c5/fc09c27c-c6ba-4b81-8cd6-03cda0789d4b.jpg',
      tags: ['Action', 'Horror', 'Psychological', 'Supernatural'],
      status: MangaStatus.completed,
      averageRating: 4.3,
      totalChapters: 143,
      author: 'Sui Ishida',
    ),
    const Manga(
      id: '9',
      title: 'Bleach',
      description:
          'A teenager gains the powers of a Soul Reaper—a death personification similar to the Grim Reaper—and is tasked with protecting humans from evil spirits and guiding departed souls to the afterlife.',
      coverUrl:
          'https://uploads.mangadex.org/covers/adb5643f-c55a-4e7b-9cb6-9a7cff2cd5b4/5aa5699e-9a5d-46db-96bc-28aef2b00f5a.jpg',
      tags: ['Action', 'Adventure', 'Supernatural'],
      status: MangaStatus.completed,
      averageRating: 4.2,
      totalChapters: 686,
      author: 'Tite Kubo',
    ),
    const Manga(
      id: '10',
      title: 'Hunter x Hunter',
      description:
          'Gon Freecss aspires to become a Hunter, an exceptional being capable of greatness. With his friends and his potential, he seeks for his father who left him when he was younger.',
      coverUrl:
          'https://uploads.mangadex.org/covers/2f5f3c84-5a44-43de-baaf-2fcd6a11e3ab/7dc3b75f-8e5e-4c9b-b1b0-3dce8cd48ee2.jpg',
      tags: ['Action', 'Adventure', 'Fantasy'],
      status: MangaStatus.hiatus,
      averageRating: 4.9,
      totalChapters: 400,
      author: 'Yoshihiro Togashi',
    ),
    const Manga(
      id: '11',
      title: 'Vinland Saga',
      description:
          'As a child, Thorfinn sat at the feet of the great Leif Ericson and thrilled to his tales of a land far to the west. But his youthful fantasies were shattered by a mercenary raid.',
      coverUrl:
          'https://uploads.mangadex.org/covers/d25f9b4e-6f04-4cf4-9e17-2a67e5d31cb2/a2f4e0db-70c5-4bc2-9d9d-cd86e6eedf64.jpg',
      tags: ['Action', 'Adventure', 'Drama', 'Historical'],
      status: MangaStatus.ongoing,
      averageRating: 4.8,
      totalChapters: 200,
      author: 'Makoto Yukimura',
    ),
    const Manga(
      id: '12',
      title: 'Chainsaw Man',
      description:
          'Denji has a simple dream—to live a happy and peaceful life, spending time with a girl he likes. This is a far cry from reality, however, as Denji is forced by the yakuza into killing devils in order to pay off his crushing debts.',
      coverUrl:
          'https://uploads.mangadex.org/covers/a77742b1-befd-49a4-bff5-1ad4e6b328d5/07656d79-f2d8-49c7-a27d-0b7e4e8e3a50.jpg',
      tags: ['Action', 'Comedy', 'Horror', 'Supernatural'],
      status: MangaStatus.ongoing,
      averageRating: 4.7,
      totalChapters: 170,
      author: 'Tatsuki Fujimoto',
    ),
  ];

  static List<Chapter> _generateChapters(String mangaId, int count) {
    final now = DateTime.now();
    return List.generate(
      count > 30 ? 30 : count,
      (i) => Chapter(
        id: '${mangaId}_ch_${count - i}',
        mangaId: mangaId,
        number: (count - i).toDouble(),
        title: i == 0
            ? 'The Beginning'
            : i == 1
                ? 'A New Challenge'
                : null,
        pageCount: 18 + (i % 5),
        isRead: i > 5,
        publishedAt: now.subtract(Duration(days: i * 7)),
      ),
    );
  }

  @override
  Future<List<Manga>> fetchFeatured() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _allManga.take(5).toList();
  }

  @override
  Future<List<Manga>> fetchLatest({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allManga.take(limit).toList();
  }

  @override
  Future<List<Manga>> fetchPopular({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sorted = List<Manga>.from(_allManga)
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<Manga>> fetchCompleted({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allManga
        .where((m) => m.status == MangaStatus.completed)
        .take(limit)
        .toList();
  }

  @override
  Future<Manga> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allManga.firstWhere(
      (m) => m.id == id,
      orElse: () => _allManga.first,
    );
  }

  @override
  Future<List<Manga>> search(
    String query, {
    List<String> genres = const [],
    MangaStatus? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var results = List<Manga>.from(_allManga);

    if (query.isNotEmpty) {
      results = results
          .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (genres.isNotEmpty) {
      results = results
          .where((m) => genres.any((g) => m.tags.contains(g)))
          .toList();
    }

    if (status != null) {
      results = results.where((m) => m.status == status).toList();
    }

    if (sortBy == 'rating') {
      results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    } else if (sortBy == 'title') {
      results.sort((a, b) => a.title.compareTo(b.title));
    }

    return results.take(limit).toList();
  }

  @override
  Future<List<Chapter>> getChapters(
    String mangaId, {
    bool ascending = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final manga = _allManga.firstWhere(
      (m) => m.id == mangaId,
      orElse: () => _allManga.first,
    );
    final chapters = _generateChapters(mangaId, manga.totalChapters);
    if (ascending) {
      return chapters.reversed.toList();
    }
    return chapters;
  }

  @override
  Future<List<Manga>> getRelated(String mangaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allManga.where((m) => m.id != mangaId).take(6).toList();
  }

  @override
  Future<void> toggleFavorite(String mangaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<bool> isFavorite(String mangaId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ['1', '3', '6'].contains(mangaId);
  }
}
