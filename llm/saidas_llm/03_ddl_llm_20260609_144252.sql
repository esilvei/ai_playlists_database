CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE Artist (
    spotify_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    popularity INTEGER
);
CREATE TABLE Genre (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);
CREATE TABLE Album (
    album_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_date DATE,
    release_type VARCHAR(50),
    artist_spotify_id VARCHAR(255) NOT NULL,
    FOREIGN KEY (artist_spotify_id) REFERENCES Artist(spotify_id) ON DELETE CASCADE
);
CREATE TABLE Music (
    music_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    duration_ms INTEGER NOT NULL,
    energy NUMERIC(3,2) CHECK (energy BETWEEN 0.0 AND 1.0),
    valence NUMERIC(3,2) CHECK (valence BETWEEN 0.0 AND 1.0),
    danceability NUMERIC(3,2) CHECK (danceability BETWEEN 0.0 AND 1.0),
    bpm INTEGER,
    album_id INTEGER NOT NULL,
    FOREIGN KEY (album_id) REFERENCES Album(album_id) ON DELETE CASCADE
);
CREATE TABLE "User" (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP NOT NULL
);
CREATE TABLE Playlist (
    playlist_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    spotify_link VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    user_id UUID NOT NULL,
    FOREIGN KEY (user_id) REFERENCES "User"(user_id) ON DELETE CASCADE
);
CREATE TABLE AuditLog (
    log_id SERIAL PRIMARY KEY,
    prompt_text TEXT NOT NULL,
    parameters JSONB,
    playlist_id UUID NOT NULL,
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id) ON DELETE CASCADE
);
CREATE TABLE PlaylistItem (
    playlist_item_id SERIAL PRIMARY KEY,
    position INTEGER NOT NULL,
    playlist_id UUID NOT NULL,
    music_id INTEGER NOT NULL,
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(music_id) ON DELETE CASCADE
);
CREATE TABLE artist_genre (
    artist_spotify_id VARCHAR(255) NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (artist_spotify_id, genre_id),
    FOREIGN KEY (artist_spotify_id) REFERENCES Artist(spotify_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) ON DELETE CASCADE
);
