CREATE INDEX idx_artistas_nome ON artistas(nome_completo);
CREATE INDEX idx_musicas_nome ON musicas(nome);

BEGIN;
    SAVEPOINT sp_antes_playlist;

    INSERT INTO playlists (id_playlist, usuario_id, log_texto_pedido, log_parametros_ia, link_streaming)
    VALUES (
        '123e4567-e89b-12d3-a456-426614174000',
        (SELECT id_usuario FROM usuarios LIMIT 1),
        'Playlist transacional de teste',
        '{"energia_alvo": 0.5}',
        'http://streaming.com/teste'
    );

    INSERT INTO itens_playlist (playlist_id, musica_id, posicao)
    VALUES ('123e4567-e89b-12d3-a456-426614174000', 'trk_roots', 1);
COMMIT;

/* -- 3. RECUPERAÇÃO E BACKUP (pg_dump)
-- Comando a ser executado no terminal do SO para disaster recovery:
-- pg_dump -U postgres -F c -d startup_musical_db -f backup_startup_musical.dump

-- 4. ANÁLISE DE DESEMPENHO (Explain Analyze)
-- Comando para verificar o uso do índice 'idx_musicas_nome' criado acima:
-- EXPLAIN ANALYZE SELECT * FROM musicas WHERE nome = 'Ratamahatta';
*/