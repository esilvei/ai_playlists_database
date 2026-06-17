-- ============================================================
-- 1. Gerar usuários
-- ============================================================
INSERT INTO usuarios (nome, email_institucional)
SELECT
    (ARRAY['Ana','Carlos','João','Mariana','Lucas',
           'Beatriz','Rafael','Juliana','Pedro','Camila'])[floor(random()*10)+1]
    || ' ' ||
    (ARRAY['Silva','Santos','Oliveira','Souza','Costa',
           'Ferreira','Alves','Monteiro','Mendes','Nogueira'])[floor(random()*10)+1],
    'aluno_teste_' || i || '@ufba.br'
FROM generate_series(4, 10000) AS t(i);

-- ============================================================
-- 2. Artistas e álbuns base
-- ============================================================
INSERT INTO artistas (id_spotify, nome_completo, indice_popularidade) VALUES
('art_gn1', 'Gilberto Gil',    95),
('art_gn2', 'Caetano Veloso',  92),
('art_int1', 'Dua Lipa',       99),
('art_int2', 'Bruno Mars',     98)
ON CONFLICT (id_spotify) DO NOTHING;

INSERT INTO albuns (id_album, artista_id, titulo, data_lancamento, tipo_lancamento) VALUES
('alb_m1', 'art_gn1',  'Expresso 2222',   '1978-01-01', 'Álbum'),
('alb_m2', 'art_int1', 'Future Nostalgia', '2020-03-27', 'Álbum')
ON CONFLICT (id_album) DO NOTHING;


-- ============================================================
-- 3. Gerar 100.000 músicas
-- ============================================================
INSERT INTO musicas (id_musica, album_id, nome, duracao_ms, energia, valencia, dancabilidade, bpm)
SELECT
    'mus_rnd_' || i,
    (ARRAY['alb_m1', 'alb_m2'])[floor(random()*2)+1],
    (ARRAY['Sonho','Amor','Noite','Festa','Luz','Vento','Mar','Cidade'])[floor(random()*8)+1]
        || ' ' || i,
    floor(random() * (300000 - 120000 + 1) + 120000)::int,
    random()::real,
    random()::real,
    random()::real,
    floor(random() * (180 - 70 + 1) + 70)::real
FROM generate_series(1, 100000) AS t(i);

INSERT INTO musicas_artistas (musica_id, artista_id, papel)
SELECT
    'mus_rnd_' || i,
    (ARRAY['art_gn1', 'art_gn2', 'art_int1', 'art_int2'])[floor(random()*4)+1],
    'Principal'
FROM generate_series(1, 100000) AS t(i);


-- ============================================================
-- 4. Criar as 5.000 playlists
-- ============================================================
INSERT INTO playlists (usuario_id, log_texto_pedido, log_parametros_ia)
SELECT
    u.id_usuario,
    'Playlist gerada automaticamente #' || row_number() OVER (ORDER BY u.id_usuario),
    '{"modo": "automatico"}'
FROM usuarios u
WHERE u.email_institucional LIKE 'aluno_teste_%'
ORDER BY random()
LIMIT 5000;


-- ============================================================
-- 5. Inserir 250.000 itens nas playlists (50 por playlist)
-- ============================================================
INSERT INTO itens_playlist (playlist_id, musica_id, posicao)
SELECT
    p.id_playlist,
    'mus_rnd_' || floor(random() * 100000 + 1)::int,
    t.i
FROM playlists p
CROSS JOIN generate_series(1, 50) AS t(i)
ON CONFLICT DO NOTHING;