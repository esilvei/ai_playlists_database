ALTER TABLE playlists ADD COLUMN data_ultima_modificacao TIMESTAMP;

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