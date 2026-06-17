## Busca
CREATE INDEX idx_musicas_bpm ON musicas USING btree (bpm);
EXPLAIN ANALYSE
SELECT 
    m.nome AS nome_musica, 
    a.nome_completo AS nome_artista, 
    ma.papel
FROM musicas m
JOIN musicas_artistas ma ON m.id_musica = ma.musica_id
JOIN artistas a ON ma.artista_id = a.id_spotify
WHERE m.energia > 0.995;

## Resultados
**SEM INDEX:**
"Planning Time: 0.428 ms"
"Execution Time: 27.391 ms"
**SEM INDEX:**
"Planning Time: 0.695 ms"
"Execution Time: 0.056 ms"

