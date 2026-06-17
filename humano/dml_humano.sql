INSERT INTO usuarios (nome, email_institucional)
VALUES ('usuario_generico', 'usuario_generico@startupmusical.com');

INSERT INTO generos (nome) VALUES
('Metal'),
('Samba'),
('Música Clássica');

INSERT INTO artistas (id_spotify, nome_completo, indice_popularidade) VALUES
('art_sepultura', 'Sepultura', 68),
('art_cartola', 'Cartola', 55);

INSERT INTO artistas_generos (artista_id, genero_id) VALUES
('art_sepultura', (SELECT id_genero FROM generos WHERE nome = 'Metal')),
('art_cartola', (SELECT id_genero FROM generos WHERE nome = 'Samba'));

INSERT INTO albuns (id_album, artista_id, titulo, data_lancamento, tipo_lancamento) VALUES
('alb_roots', 'art_sepultura', 'Roots', '1996-02-20', 'album'),
('alb_verde', 'art_cartola', 'Verde Que Te Quero Rosa', '1977-01-01', 'album');

INSERT INTO musicas (id_musica, album_id, nome, duracao_ms, energia, valencia, dancabilidade, bpm) VALUES
('trk_roots', 'alb_roots', 'Roots Bloody Roots', 212000, 0.98, 0.20, 0.45, 108.0),
('trk_ratamahatta', 'alb_roots', 'Ratamahatta', 270000, 0.95, 0.35, 0.50, 115.0),
('trk_rosas', 'alb_verde', 'As Rosas Não Falam', 178000, 0.25, 0.60, 0.55, 90.0),
('trk_moinho', 'alb_verde', 'O Mundo É Um Moinho', 235000, 0.30, 0.45, 0.40, 85.0);

INSERT INTO playlists (usuario_id, log_texto_pedido, log_parametros_ia, link_streaming)
VALUES (
    (SELECT id_usuario FROM usuarios WHERE email_institucional = 'usuario_generico@startupmusical.com'),
    'Quero uma playlist com energia máxima, ritmo pesado e agressivo para treino.',
    '{"energia_alvo": "> 0.90", "bpm_alvo": "> 100"}',
    'https://open.spotify.com/playlist/metal_treino_01'
);

INSERT INTO itens_playlist (playlist_id, musica_id, posicao)
VALUES
    ((SELECT id_playlist FROM playlists LIMIT 1), 'trk_roots', 1),
    ((SELECT id_playlist FROM playlists LIMIT 1), 'trk_ratamahatta', 2);

