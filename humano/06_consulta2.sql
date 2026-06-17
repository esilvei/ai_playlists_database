SELECT 
    u.nome AS curador,
    p.log_texto_pedido AS prompt_da_ia,
    COUNT(i.musica_id) AS total_musicas,
    ROUND(AVG(m.energia)::numeric, 3) AS energia_media
FROM usuarios u
JOIN playlists p ON u.id_usuario = p.usuario_id
JOIN itens_playlist i ON p.id_playlist = i.playlist_id
JOIN musicas m ON i.musica_id = m.id_musica
GROUP BY u.nome, p.log_texto_pedido
HAVING COUNT(i.musica_id) >= 10
ORDER BY energia_media DESC;