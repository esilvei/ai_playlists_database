-- Criar uma playlist específica para o teste
INSERT INTO playlists (id_playlist, usuario_id, log_texto_pedido, link_streaming) 
VALUES (
    '99999999-9999-9999-9999-999999999999', 
    (SELECT id_usuario FROM usuarios LIMIT 1), 
    'Teste de Transação ACID', 
    'https://stream.local/teste_acid'
);

BEGIN; -- INICIA A TRANSAÇÃO

-- 1. A IA insere a 1ª música na posição 1 (SUCESSO)
INSERT INTO itens_playlist (playlist_id, musica_id, posicao) 
VALUES ('99999999-9999-9999-9999-999999999999', (SELECT id_musica FROM musicas LIMIT 1 OFFSET 0), 1);

-- 2. A IA insere a 2ª música na posição 2 (SUCESSO)
INSERT INTO itens_playlist (playlist_id, musica_id, posicao) 
VALUES ('99999999-9999-9999-9999-999999999999', (SELECT id_musica FROM musicas LIMIT 1 OFFSET 1), 2);

-- 3. ERRO FATAL: O bug da IA tenta inserir uma música diferente na POSIÇÃO 1 novamente!
-- Isto vai violar a nossa Primary Key (playlist_id, posicao).
INSERT INTO itens_playlist (playlist_id, musica_id, posicao) 
VALUES ('99999999-9999-9999-9999-999999999999', (SELECT id_musica FROM musicas LIMIT 1 OFFSET 2), 1);

-- Reverte TODAS as ações desde o BEGIN
ROLLBACK; 

-- Vamos verificar se a música 1 e 2 ficaram lá ou se foram salvas:
SELECT * FROM itens_playlist WHERE playlist_id = '99999999-9999-9999-9999-999999999999';