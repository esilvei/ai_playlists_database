-- =============================================================================
-- ALTA PRIORIDADE: Performance de Consultas, FKs de Join e Agregação
-- =============================================================================
-- Otimização para ranqueamento e window functions
CREATE INDEX idx_musicas_dancabilidade    ON musicas (dancabilidade DESC);

-- Índices cruciais para JOINs de alta performance (FKs de relacionamento intenso)
CREATE INDEX idx_musicas_album            ON musicas (album_id);
CREATE INDEX idx_itens_musica_covering ON itens_playlist (musica_id, playlist_id);
CREATE INDEX idx_itens_playlist_id        ON itens_playlist (playlist_id);
CREATE INDEX idx_playlists_usuario        ON playlists (usuario_id);

-- Índice para a nova tabela de colaboração (conforme MER)
CREATE INDEX idx_playlists_colab_usuario  ON playlists_colaboradores (usuario_id);
CREATE INDEX idx_playlists_colab_playlist ON playlists_colaboradores (playlist_id);

-- =============================================================================
-- MÉDIA PRIORIDADE: Relacionamentos e Hierarquias
-- =============================================================================

CREATE INDEX idx_artistas_generos_genero  ON artistas_generos (genero_id);
CREATE INDEX idx_musicas_generos_genero   ON musicas_generos (genero_id);
CREATE INDEX idx_musicas_artistas_artista ON musicas_artistas (artista_id);
CREATE INDEX idx_generos_hierarquia_filho ON generos_hierarquia (genero_filho_id);
CREATE INDEX idx_albuns_artista           ON albuns (artista_id);
CREATE INDEX idx_albuns_lancamento        ON albuns (data_lancamento);
