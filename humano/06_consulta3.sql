-- Parte 1: A CTE (Uma tabela temporária na memória durante a consulta)
WITH RanqueamentoDanca AS (
    SELECT 
        p.id_playlist,
        p.log_texto_pedido,
        m.nome AS nome_musica,
        m.dancabilidade,
        -- A magia acontece aqui: cria um ranking de 1 a N para as músicas DENTRO de cada playlist
        ROW_NUMBER() OVER (
            PARTITION BY p.id_playlist 
            ORDER BY m.dancabilidade DESC
        ) AS posicao_ranking_danca
    FROM playlists p
    JOIN itens_playlist i ON p.id_playlist = i.playlist_id
    JOIN musicas m ON i.musica_id = m.id_musica
)
-- Parte 2: O Filtro Final sobre a CTE
SELECT 
    log_texto_pedido AS pedido_original,
    nome_musica,
    dancabilidade,
    posicao_ranking_danca
FROM RanqueamentoDanca
WHERE posicao_ranking_danca <= 3
ORDER BY id_playlist, posicao_ranking_danca;