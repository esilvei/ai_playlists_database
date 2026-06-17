CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DROP TABLE IF EXISTS itens_playlist;
DROP TABLE IF EXISTS playlists;
DROP TABLE IF EXISTS musicas;
DROP TABLE IF EXISTS musica_artista;
DROP TABLE IF EXISTS musica_genero;
DROP TABLE IF EXISTS artista_genero;
DROP TABLE IF EXISTS genero_hierarquia;
DROP TABLE IF EXISTS albuns;
DROP TABLE IF EXISTS artistas;
DROP TABLE IF EXISTS generos;
DROP TABLE IF EXISTS curadores;

CREATE TABLE curadores (
    curator_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    registration_date DATE NOT NULL
);

CREATE TABLE artistas (
    spotify_id VARCHAR PRIMARY KEY,
    full_name VARCHAR NOT NULL,
    popularity INTEGER NOT NULL
);

CREATE TABLE albuns (
    album_code VARCHAR PRIMARY KEY,
    title VARCHAR NOT NULL,
    release_date DATE NOT NULL,
    release_type VARCHAR CHECK (release_type IN ('album', 'single', 'EP'))
);

CREATE TABLE musicas (
    song_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR NOT NULL,
    duration_ms INTEGER NOT NULL,
    energy DECIMAL CHECK (energy BETWEEN 0.0 AND 1.0),
    valence DECIMAL CHECK (valence BETWEEN 0.0 AND 1.0),
    danceability DECIMAL CHECK (danceability BETWEEN 0.0 AND 1.0),
    bpm INTEGER NOT NULL,
    album_code VARCHAR NOT NULL REFERENCES albuns(album_code) ON DELETE CASCADE
);

CREATE TABLE generos (
    genre_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL
);

CREATE TABLE genero_hierarquia (
    genre_id UUID NOT NULL REFERENCES generos(genre_id) ON DELETE CASCADE,
    related_genre_id UUID NOT NULL REFERENCES generos(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (genre_id, related_genre_id)
);

CREATE TABLE musica_artista (
    song_id UUID NOT NULL REFERENCES musicas(song_id) ON DELETE CASCADE,
    artist_id VARCHAR NOT NULL REFERENCES artistas(spotify_id) ON DELETE CASCADE,
    role VARCHAR NOT NULL,
    PRIMARY KEY (song_id, artist_id)
);

CREATE TABLE musica_genero (
    song_id UUID NOT NULL REFERENCES musicas(song_id) ON DELETE CASCADE,
    genre_id UUID NOT NULL REFERENCES generos(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (song_id, genre_id)
);

CREATE TABLE artista_genero (
    artist_id VARCHAR NOT NULL REFERENCES artistas(spotify_id) ON DELETE CASCADE,
    genre_id UUID NOT NULL REFERENCES generos(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, genre_id)
);

CREATE TABLE playlists (
    playlist_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_text TEXT NOT NULL,
    ai_parameters JSONB NOT NULL,
    streaming_link VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    curator_id UUID NOT NULL REFERENCES curadores(curator_id) ON DELETE CASCADE,
    data_ultima_modificacao TIMESTAMP
);

CREATE TABLE itens_playlist (
    playlist_id UUID NOT NULL REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    song_id UUID NOT NULL REFERENCES musicas(song_id) ON DELETE CASCADE,
    PRIMARY KEY (playlist_id, position)
);

CREATE OR REPLACE FUNCTION update_playlist_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_ultima_modificacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_playlist_modified_trigger
BEFORE UPDATE ON playlists
FOR EACH ROW
EXECUTE FUNCTION update_playlist_modified();

CREATE VIEW vw_relatorio_curadoria AS
SELECT 
    c.full_name AS curador,
    p.playlist_id,
    p.prompt_text,
    m.nome AS musica_nome,
    ip.position,
    m.energy
FROM playlists p
JOIN curadores c ON p.curator_id = c.curator_id
JOIN itens_playlist ip ON p.playlist_id = ip.playlist_id
JOIN musicas m ON ip.song_id = m.song_id;

CREATE INDEX idx_artistas_nome ON artistas(nome);
CREATE INDEX idx_musicas_nome ON musicas(nome);
CREATE INDEX idx_musicas_energia ON musicas(energia);
CREATE INDEX idx_musicas_dancabilidade ON musicas(dancabilidade);
CREATE INDEX idx_playlists_curador ON playlists(curator_id);

-- EXPLAIN ANALYZE SELECT * FROM musicas WHERE nome = 'Song Title';

-- pg_dump -U postgres -d music_db -F c -b -v -f music_db_backup.dump