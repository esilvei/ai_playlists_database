BEGIN;

INSERT INTO usuarios (nome, email_institucional) VALUES
('Eduardo Silveira', 'eduardo@startupmusical.com'),
('IA Curadora Bot', 'bot_curadoria@startupmusical.com');

INSERT INTO generos (id_genero, nome) VALUES
(1, 'Metal'), (2, 'Black Metal'), (3, 'Death Metal'), (4, 'Doom Metal'),
(5, 'Sludge Metal'), (6, 'Shoegaze'), (7, 'Blackgaze'), (8, 'Post-Metal'),
(9, 'Progressive Metal'), (10, 'Technical Death Metal'), (11, 'Melodic Death Metal'),
(12, 'Stoner Metal'), (13, 'Pop'), (14, 'Pop-80'), (15, 'Post-Black Metal');

INSERT INTO generos_hierarquia (genero_pai_id, genero_filho_id) VALUES
(1, 2), (1, 3), (1, 4), (1, 9), (1, 12),
(4, 5), (12, 5), (3, 10), (3, 11), (9, 10),
(5, 8), -- Post-Metal derivando de Sludge
(2, 7), (6, 7), -- Blackgaze
(2, 15), (6, 15), -- Post-Black Metal
(13, 14);

INSERT INTO artistas (id_spotify, nome_completo, indice_popularidade) VALUES
('art_darkthrone', 'Darkthrone', 64), ('art_emperor', 'Emperor', 62),
('art_dissection', 'Dissection', 68), ('art_opeth', 'Opeth', 75),
('art_gojira', 'Gojira', 82), ('art_morbid_angel', 'Morbid Angel', 66),
('art_ewizard', 'Electric Wizard', 71), ('art_neurosis', 'Neurosis', 58),
('art_deafheaven', 'Deafheaven', 60), ('art_alcest', 'Alcest', 63),
('art_attila', 'Attila Csihar', 45), ('art_luclemons', 'Luc Lemons', 30),
('art_mayhem', 'Mayhem', 70);

INSERT INTO artistas_generos (artista_id, genero_id) VALUES
('art_darkthrone', 2), ('art_emperor', 2),
('art_dissection', 2), ('art_dissection', 3),
('art_opeth', 3), ('art_opeth', 9), ('art_opeth', 4),
('art_gojira', 3), ('art_gojira', 9), ('art_gojira', 10),
('art_morbid_angel', 3), ('art_ewizard', 4), ('art_ewizard', 12),
('art_neurosis', 5), ('art_neurosis', 8),
('art_deafheaven', 15), ('art_alcest', 15),
('art_attila', 2), ('art_luclemons', 9);

INSERT INTO albuns (id_album, artista_id, titulo, data_lancamento, tipo_lancamento) VALUES
('alb_blaze', 'art_darkthrone', 'A Blaze in the Northern Sky', '1992-02-26', 'Álbum'),
('alb_eclipse', 'art_emperor', 'In the Nightside Eclipse', '1994-02-21', 'Álbum'),
('alb_storm', 'art_dissection', 'Storm of the Light''s Bane', '1995-11-17', 'Álbum'),
('alb_blackwater', 'art_opeth', 'Blackwater Park', '2001-03-12', 'Álbum'),
('alb_sirius', 'art_gojira', 'From Mars to Sirius', '2005-09-27', 'Álbum'),
('alb_altars', 'art_morbid_angel', 'Altars of Madness', '1989-05-12', 'Álbum'),
('alb_dopethrone', 'art_ewizard', 'Dopethrone', '2000-09-25', 'Álbum'),
('alb_silver', 'art_neurosis', 'Through Silver in Blood', '1996-04-23', 'Álbum'),
('alb_sunbather', 'art_deafheaven', 'Sunbather', '2013-06-11', 'Álbum'),
('alb_ecailles', 'art_alcest', 'Écailles de Lune', '2010-03-29', 'Álbum'),
('alb_collab_ep', 'art_deafheaven', 'Atmospheric Sessions', '2026-05-22', 'EP'),
('alb_collab_single', 'art_mayhem', 'Quantum Graves', '2026-01-01', 'Single');

INSERT INTO musicas (id_musica, album_id, nome, duracao_ms, energia, valencia, dancabilidade, bpm) VALUES
('trk_kathaarian', 'alb_blaze', 'Kathaarian Life Code', 639000, 0.92, 0.03, 0.10, 128.0),
('trk_cosmic', 'alb_eclipse', 'I Am the Black Wizards', 361000, 0.97, 0.05, 0.15, 145.0),
('trk_nights', 'alb_storm', 'Night''s Blood', 401000, 0.98, 0.07, 0.22, 152.0),
('trk_where_dead_ships', 'alb_storm', 'Where Dead Angels Lie', 353000, 0.85, 0.12, 0.28, 118.0),
('trk_leper', 'alb_blackwater', 'The Leper Affinity', 623000, 0.89, 0.15, 0.35, 124.0),
('trk_bwpark', 'alb_blackwater', 'Blackwater Park', 728000, 0.82, 0.09, 0.20, 110.0),
('trk_whales', 'alb_sirius', 'Flying Whales', 464000, 0.91, 0.18, 0.42, 92.0),
('trk_backbone', 'alb_sirius', 'Backbone', 258000, 0.99, 0.11, 0.38, 160.0),
('trk_chapel', 'alb_altars', 'Chapel of Ghouls', 298000, 0.98, 0.02, 0.18, 175.0),
('trk_funeralopolis', 'alb_dopethrone', 'Funeralopolis', 523000, 0.68, 0.01, 0.15, 62.0),
('trk_vinum', 'alb_dopethrone', 'Vinum Sabbathi', 185000, 0.72, 0.05, 0.25, 68.0),
('trk_locust', 'alb_silver', 'Locust Star', 348000, 0.78, 0.04, 0.18, 85.0),
('trk_dream', 'alb_sunbather', 'Dream House', 555000, 0.93, 0.24, 0.32, 142.0),
('trk_sunbather', 'alb_sunbather', 'Sunbather', 617000, 0.88, 0.28, 0.35, 138.0),
('trk_percees', 'alb_ecailles', 'Percées de Lumière', 380000, 0.86, 0.35, 0.28, 145.0),
('trk_split_void', 'alb_collab_single', 'Chamber of Quantum Graves', 420000, 0.95, 0.03, 0.20, 150.0),
('trk_session_atmos', 'alb_collab_ep', 'Ethereal Collision', 510000, 0.84, 0.25, 0.40, 120.0);

INSERT INTO musicas_artistas (musica_id, artista_id, papel) VALUES
('trk_cosmic', 'art_emperor', 'Principal'), ('trk_nights', 'art_dissection', 'Principal'),
('trk_kathaarian', 'art_darkthrone', 'Principal'),('trk_locust',     'art_neurosis',   'Principal'),
('trk_where_dead_ships', 'art_dissection', 'Principal'), ('trk_leper', 'art_opeth', 'Principal'),
('trk_bwpark', 'art_opeth', 'Principal'), ('trk_whales', 'art_gojira', 'Principal'),
('trk_backbone', 'art_gojira', 'Principal'), ('trk_chapel', 'art_morbid_angel', 'Principal'),
('trk_funeralopolis', 'art_ewizard', 'Principal'), ('trk_vinum', 'art_ewizard', 'Principal'),
('trk_dream', 'art_deafheaven', 'Principal'), ('trk_sunbather', 'art_deafheaven', 'Principal'),
('trk_percees', 'art_alcest', 'Principal'),
('trk_split_void', 'art_mayhem', 'Principal'), ('trk_split_void', 'art_dissection', 'Feature'),
('trk_split_void', 'art_attila', 'Feature'),
('trk_session_atmos', 'art_deafheaven', 'Principal'), ('trk_session_atmos', 'art_alcest', 'Feature'),
('trk_session_atmos', 'art_luclemons', 'Produtor');

INSERT INTO musicas_generos (musica_id, genero_id) VALUES
('trk_kathaarian', 2), ('trk_cosmic', 2),
('trk_nights', 2), ('trk_nights', 3), ('trk_where_dead_ships', 2), ('trk_where_dead_ships', 11),
('trk_leper', 3), ('trk_leper', 9), ('trk_leper', 4), ('trk_bwpark', 3), ('trk_bwpark', 9),
('trk_whales', 3), ('trk_whales', 9), ('trk_whales', 10), ('trk_backbone', 3), ('trk_backbone', 10),
('trk_chapel', 3), ('trk_funeralopolis', 4), ('trk_funeralopolis', 5), ('trk_vinum', 4), ('trk_vinum', 12),
('trk_locust', 5), ('trk_locust', 8),
('trk_dream', 15), ('trk_sunbather', 15), ('trk_percees', 15),
('trk_split_void', 2), ('trk_split_void', 3),
('trk_session_atmos', 15);

INSERT INTO playlists (id_playlist, usuario_id, log_texto_pedido, log_parametros_ia, link_streaming)
VALUES (
    '888e4567-e89b-12d3-a456-426614174000',
    (SELECT id_usuario FROM usuarios WHERE email_institucional = 'eduardo@startupmusical.com' LIMIT 1),
    'Gere um relatório dinâmico cruzando faixas de alta dissonância atmosférica.',
    '{"energia_minima": 0.80, "valencia_maxima": 0.30}',
    'http://googleusercontent.com/spotify.com/playlists/888'
);

INSERT INTO itens_playlist (playlist_id, musica_id, posicao) VALUES
('888e4567-e89b-12d3-a456-426614174000', 'trk_dream', 1),
('888e4567-e89b-12d3-a456-426614174000', 'trk_session_atmos', 2),
('888e4567-e89b-12d3-a456-426614174000', 'trk_locust', 3),
('888e4567-e89b-12d3-a456-426614174000', 'trk_sunbather', 4),
('888e4567-e89b-12d3-a456-426614174000', 'trk_bwpark', 5);

COMMIT;