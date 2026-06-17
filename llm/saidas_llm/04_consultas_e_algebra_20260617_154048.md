# Consultas SQL e Álgebra Relacional

---

## Consulta 1 — Músicas com Altíssima Energia e seus Artistas

**(a) Enunciado**  
Quais são os nomes das músicas, os nomes dos seus respectivos artistas e os papéis que eles exerceram (Principal, Feature, etc.), mas apenas para músicas com altíssima energia (energia > 0.9)?

**(b) Álgebra Relacional**  
$$
\pi_{\text{nome, full\_name, role}} \left( \sigma_{\text{energy} > 0.9} \left( \text{musicas} \right) \bowtie_{\text{song\_id}} \text{musica\_artista} \bowtie_{\text{artist\_id}} \text{artistas} \right)
$$

**(c) Script SQL PostgreSQL**  
-- Consulta otimizada para obter músicas com energia > 0.9 e seus artistas
SELECT 
    m.nome AS musica_nome,
    a.full_name AS artista_nome,
    ma.role AS papel
FROM musicas m
JOIN musica_artista ma ON m.song_id = ma.song_id
JOIN artistas a ON ma.artist_id = a.spotify_id
WHERE m.energy > 0.9;  -- Filtra músicas com energia > 0.9

---

## Consulta 2 — Curadores das Playlists Mais Energéticas (mínimo 10 músicas)

**(a) Enunciado**  
Quais curadores criaram as playlists mais energéticas, considerando apenas playlists que tenham pelo menos 10 músicas?

**(b) Álgebra Relacional**  
$$
\pi_{\text{full\_name, avg\_energy}} \left( \sigma_{\text{count} \geq 10} \left( \gamma_{\text{playlist\_id}, \text{AVG(energy)} \rightarrow \text{avg\_energy}} \left( \text{playlists} \bowtie_{\text{playlist\_id}} \text{itens\_playlist} \bowtie_{\text{song\_id}} \text{musicas} \right) \right) \bowtie_{\text{curator\_id}} \text{curadores} \right)
$$

**(c) Script SQL PostgreSQL**  
-- Consulta otimizada para playlists com ≥10 músicas e média de energia
SELECT 
    c.full_name AS curador,
    AVG(m.energy) AS media_energia
FROM playlists p
JOIN curadores c ON p.curator_id = c.curator_id
JOIN itens_playlist ip ON p.playlist_id = ip.playlist_id
JOIN musicas m ON ip.song_id = m.song_id
GROUP BY p.playlist_id, c.full_name
HAVING COUNT(ip.song_id) >= 10  -- Filtra playlists com ≥10 músicas
ORDER BY media_energia DESC;  -- Ordena por energia média decrescente

---

## Consulta 3 — TOP 3 Músicas Mais Dançáveis por Playlist (com Prompt da IA)

**(a) Enunciado**  
Quero um relatório que mostre o Prompt que a IA recebeu e APENAS as TOP 3 músicas mais dançáveis de cada playlist gerada.

**(b) Álgebra Relacional**  
$$
\pi_{\text{prompt\_text, nome, danceability}} \left( \sigma_{\text{rn} \leq 3} \left( \gamma_{\text{playlist\_id}, \text{RANK(danceability DESC) AS rn}} \left( \text{playlists} \bowtie_{\text{playlist\_id}} \text{itens\_playlist} \bowtie_{\text{song\_id}} \text{musicas} \right) \right) \right)
$$

**(c) Script SQL PostgreSQL**  
-- Consulta otimizada para TOP 3 músicas por dançabilidade por playlist
WITH ranked_songs AS (
    SELECT 
        p.prompt_text,
        m.nome AS musica_nome,
        m.danceability,
        ROW_NUMBER() OVER (
            PARTITION BY p.playlist_id 
            ORDER BY m.danceability DESC
        ) AS rn
    FROM playlists p
    JOIN itens_playlist ip ON p.playlist_id = ip.playlist_id
    JOIN musicas m ON ip.song_id = m.song_id
)
SELECT 
    prompt_text,
    musica_nome,
    danceability
FROM ranked_songs
WHERE rn <= 3  -- Filtra apenas as TOP 3 por playlist
ORDER BY prompt_text, rn;  -- Ordena por prompt e posição