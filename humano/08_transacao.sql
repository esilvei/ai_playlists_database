BEGIN; -- Inicia o bloco de transação para TUDO

-- 1. Cria o registro da Playlist (dentro da transação)
INSERT INTO playlists (id_playlist, usuario_id, log_texto_pedido, link_streaming)
VALUES (
    '99999999-9999-9999-9999-999999999999',
    (SELECT id_usuario FROM usuarios LIMIT 1),
    'Teste de Transação ACID',
    'https://stream.local/teste_acid'
);

-- 2. Insere música 1 (Sucesso)
INSERT INTO itens_playlist (playlist_id, musica_id, posicao)
VALUES ('99999999-9999-9999-9999-999999999999', (SELECT id_musica FROM musicas LIMIT 1 OFFSET 0), 1);

-- 3. Insere música 2 (Sucesso)
INSERT INTO itens_playlist (playlist_id, musica_id, posicao)
VALUES ('99999999-9999-9999-9999-999999999999', (SELECT id_musica FROM musicas LIMIT 1 OFFSET 1), 2);

-- 4. Tenta inserir música na posição 1 novamente (ERRO: Constraint Violation)
INSERT INTO itens_playlist (playlist_id, musica_id, posicao)
VALUES ('99999999-9999-9999-9999-999999999999', (SELECT id_musica FROM musicas LIMIT 1 OFFSET 2), 1);

-- Se o banco de dados detectar o erro acima, este comando reverterá a Playlist e todos os itens
ROLLBACK;

-- Verificação final: o resultado deve retornar 0 linhas, provando que a transação foi atômica
SELECT * FROM itens_playlist WHERE playlist_id = '99999999-9999-9999-9999-999999999999';
SELECT * FROM playlists WHERE id_playlist = '99999999-9999-9999-9999-999999999999';