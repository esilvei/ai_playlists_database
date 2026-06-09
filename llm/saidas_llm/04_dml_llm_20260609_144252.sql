INSERT INTO "User" (name, email, registration_date) VALUES ('Curador1', 'curador1@company.com', '2023-10-01');
INSERT INTO Genre (name) VALUES ('Metal'), ('Samba'), ('Música Clássica');
INSERT INTO Artist (spotify_id, name, popularity) VALUES
('artist1_spotify', 'Artist A', 75),
('artist2_spotify', 'Artist B', 85);
INSERT INTO Album (title, release_date, release_type, artist_spotify_id) VALUES
('Album 1', '2020-01-01', 'Album', 'artist1_spotify'),
('Album 2', '2021-05-15', 'EP', 'artist2_spotify');
INSERT INTO Music (title, duration_ms, energy, valence, danceability, bpm, album_id) VALUES
('Song A', 240000, 0.8, 0.6, 0.7, 120, 1),
('Song B', 210000, 0.9, 0.5, 0.8, 110, 1),
('Song C', 300000, 0.7, 0.4, 0.6, 100, 2),
('Song D', 280000, 0.6, 0.3, 0.5, 90, 2);
INSERT INTO artist_genre (artist_spotify_id, genre_id) VALUES
('artist1_spotify', 1),
('artist1_spotify', 2),
('artist2_spotify', 2);
INSERT INTO Playlist (spotify_link, created_at, user_id) VALUES
('https://open.spotify.com/playlist/123', '2023-10-02 10:00:00', '00000000-0000-0000-0000-000000000001');
INSERT INTO AuditLog (prompt_text, parameters, playlist_id) VALUES
('alta energia', '{"energy": 0.8, "valence": 0.5}', '00000000-0000-0000-0000-000000000001');
INSERT INTO PlaylistItem (position, playlist_id, music_id) VALUES
(1, '00000000-0000-0000-0000-000000000001', 1),
(2, '00000000-0000-0000-0000-000000000001', 2);
BEGIN;
SAVEPOINT sp_teste;
INSERT INTO Playlist (spotify_link, created_at, user_id) VALUES
('https://open.spotify.com/playlist/transacional', NOW(), '00000000-0000-0000-0000-000000000001');
COMMIT;