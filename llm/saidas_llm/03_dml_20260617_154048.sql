INSERT INTO curadores (full_name, email, registration_date)
VALUES
('Ana Silva', 'ana.silva@startup.com', '2023-01-01'),
('Carlos Mendes', 'carlos.mendes@startup.com', '2023-01-02');

INSERT INTO generos (name)
VALUES
('Metal'),
('Eletrônico'),
('Industrial Metal');

INSERT INTO genero_hierarquia (genre_id, related_genre_id)
SELECT g1.genre_id, g2.genre_id
FROM generos g1
JOIN generos g2 ON g2.name = 'Industrial Metal'
WHERE g1.name = 'Metal';

INSERT INTO genero_hierarquia (genre_id, related_genre_id)
SELECT g1.genre_id, g2.genre_id
FROM generos g1
JOIN generos g2 ON g2.name = 'Industrial Metal'
WHERE g1.name = 'Eletrônico';

INSERT INTO artistas (spotify_id, full_name, popularity)
VALUES
('artist1', 'Metallica', 85),
('artist2', 'Daft Punk', 90),
('artist3', 'Muse', 75);

INSERT INTO artista_genero (artist_id, genre_id)
SELECT 'artist1', genre_id FROM generos WHERE name = 'Metal';

INSERT INTO artista_genero (artist_id, genre_id)
SELECT 'artist2', genre_id FROM generos WHERE name = 'Eletrônico';

INSERT INTO artista_genero (artist_id, genre_id)
SELECT 'artist3', genre_id FROM generos WHERE name = 'Metal';

INSERT INTO artista_genero (artist_id, genre_id)
SELECT 'artist3', genre_id FROM generos WHERE name = 'Eletrônico';

INSERT INTO albuns (album_code, title, release_date, release_type)
VALUES ('album1', 'Metal Album', '2023-01-01', 'album');

INSERT INTO musicas (nome, duration_ms, energy, valence, danceability, bpm, album_code)
VALUES
('Metallica - Master of Puppets', 240000, 0.95, 0.7, 0.8, 120, 'album1'),
('Daft Punk - Get Lucky', 210000, 0.6, 0.5, 0.5, 100, 'album1'),
('Muse - Starlight', 220000, 0.7, 0.6, 0.9, 110, 'album1');

INSERT INTO musica_artista (song_id, artist_id, role)
SELECT m.song_id, 'artist1', 'Principal'
FROM musicas m
WHERE m.nome = 'Metallica - Master of Puppets';

INSERT INTO musica_artista (song_id, artist_id, role)
SELECT m.song_id, 'artist2', 'Feature'
FROM musicas m
WHERE m.nome = 'Metallica - Master of Puppets';

INSERT INTO musica_artista (song_id, artist_id, role)
SELECT m.song_id, 'artist2', 'Principal'
FROM musicas m
WHERE m.nome = 'Daft Punk - Get Lucky';

INSERT INTO musica_artista (song_id, artist_id, role)
SELECT m.song_id, 'artist3', 'Principal'
FROM musicas m
WHERE m.nome = 'Muse - Starlight';

INSERT INTO musica_genero (song_id, genre_id)
SELECT m.song_id, g.genre_id
FROM musicas m
JOIN generos g ON g.name = 'Metal'
WHERE m.nome = 'Metallica - Master of Puppets';

INSERT INTO playlists (prompt_text, ai_parameters, streaming_link, curator_id)
VALUES
('Create a high-energy playlist for a workout', '{"tempo": 120, "mood": "energetic"}'::jsonb, 'https://spotify.com/playlist1', (SELECT curator_id FROM curadores WHERE full_name = 'Ana Silva')),
('Create a chill playlist with electronic vibes', '{"tempo": 90, "mood": "chill"}'::jsonb, 'https://spotify.com/playlist2', (SELECT curator_id FROM curadores WHERE full_name = 'Carlos Mendes'));

INSERT INTO itens_playlist (playlist_id, position, song_id)
SELECT p.playlist_id, 1, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Metallica - Master of Puppets'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 2, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Daft Punk - Get Lucky'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 3, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Metallica - Master of Puppets'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 4, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Muse - Starlight'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 5, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Daft Punk - Get Lucky'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 6, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Metallica - Master of Puppets'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 7, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Muse - Starlight'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 8, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Daft Punk - Get Lucky'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 9, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Metallica - Master of Puppets'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout'

UNION ALL
SELECT p.playlist_id, 10, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Muse - Starlight'
WHERE p.prompt_text = 'Create a high-energy playlist for a workout';

INSERT INTO itens_playlist (playlist_id, position, song_id)
SELECT p.playlist_id, 1, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Muse - Starlight'
WHERE p.prompt_text = 'Create a chill playlist with electronic vibes'

UNION ALL
SELECT p.playlist_id, 2, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Daft Punk - Get Lucky'
WHERE p.prompt_text = 'Create a chill playlist with electronic vibes'

UNION ALL
SELECT p.playlist_id, 3, m.song_id
FROM playlists p
JOIN musicas m ON m.nome = 'Metallica - Master of Puppets'
WHERE p.prompt_text = 'Create a chill playlist with electronic vibes';