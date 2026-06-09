
/* ====================================================================
   3. RECURSOS AVANÇADOS (SQL 3, OTIMIZAÇÃO E TRANSAÇÕES)
   ==================================================================== */

-- 3.1 ALTERAÇÃO DE TABELA (Preparação para o Trigger)
ALTER TABLE playlists ADD COLUMN data_ultima_modificacao TIMESTAMP;

-- 3.2 SQL 3: CRIAÇÃO DE VIEW
-- Mostra o nome do usuário, log textual do pedido, quantidade de músicas e a média de energia.
CREATE OR REPLACE VIEW vw_relatorio_curadoria AS
SELECT
    u.nome AS nome_usuario,
    p.log_texto_pedido,
    COUNT(i.musica_id) AS total_musicas,
    ROUND(AVG(m.energia)::numeric, 2) AS media_energia
FROM playlists p
JOIN usuarios u ON p.usuario_id = u.id_usuario
JOIN itens_playlist i ON p.id_playlist = i.playlist_id
JOIN musicas m ON i.musica_id = m.id_musica
GROUP BY u.nome, p.log_texto_pedido;

-- 3.3 SQL 3: CRIAÇÃO DE FUNÇÃO E TRIGGER
-- Atualiza automaticamente a coluna data_ultima_modificacao num UPDATE da playlist
CREATE OR REPLACE FUNCTION fn_atualiza_modificacao_playlist()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_ultima_modificacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_modificacao_playlist
BEFORE UPDATE ON playlists
FOR EACH ROW
EXECUTE FUNCTION fn_atualiza_modificacao_playlist();

-- 3.4 OTIMIZAÇÃO E INDEXAÇÃO
-- Criação de índices para otimizar buscas textuais comuns no sistema
CREATE INDEX idx_artistas_nome ON artistas(nome_completo);
CREATE INDEX idx_musicas_nome ON musicas(nome);

/* EXEMPLO DE USO DO EXPLAIN ANALYZE (Comentário Exigido):
Para verificar se o índice está sendo usado na busca por uma música, executar:
EXPLAIN ANALYZE SELECT * FROM musicas WHERE nome = 'Ratamahatta';
Isso mostrará um "Index Scan" ao invés de um "Seq Scan" no plano de execução.
*/

-- 3.5 CONTROLE DE CONCORRÊNCIA E TRANSAÇÕES
-- Simulando a inserção de uma playlist garantindo as propriedades ACID
BEGIN;

    -- Salva um ponto de restauração caso dê erro nos itens
    SAVEPOINT sp_antes_playlist;

    -- Tenta inserir uma nova playlist
    INSERT INTO playlists (id_playlist, usuario_id, log_texto_pedido, log_parametros_ia, link_streaming)
    VALUES (
        '123e4567-e89b-12d3-a456-426614174000', -- UUID fixo para exemplo da transação
        (SELECT id_usuario FROM usuarios LIMIT 1),
        'Playlist transacional de teste',
        '{"energia_alvo": 0.5}',
        'http://streaming.com/teste'
    );

    -- Insere um item na playlist atrelado ao UUID gerado acima
    INSERT INTO itens_playlist (playlist_id, musica_id, posicao)
    VALUES ('123e4567-e89b-12d3-a456-426614174000', 'trk_roots', 1);

    -- Se tudo deu certo até aqui, confirma a transação
COMMIT;
-- Em caso de erro dinâmico na aplicação, o SGBD chamaria ROLLBACK TO sp_antes_playlist;

/* 3.6 COMANDO DE BACKUP (pg_dump)
O comando abaixo deve ser executado no terminal do SO para gerar o backup:

pg_dump -U postgres -F c -d nome_do_banco -f backup_startup_musical.dump
*/