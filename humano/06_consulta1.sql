EXPLAIN ANALYSE
SELECT 
    m.nome AS nome_musica, 
    a.nome_completo AS nome_artista, 
    ma.papel
FROM musicas m
JOIN musicas_artistas ma ON m.id_musica = ma.musica_id
JOIN artistas a ON ma.artista_id = a.id_spotify
WHERE m.energia > 0.995;