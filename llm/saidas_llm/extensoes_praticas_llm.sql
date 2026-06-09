ALTER TABLE Playlist ADD COLUMN data_ultima_modificacao TIMESTAMP;
CREATE VIEW vw_relatorio_curadoria AS
SELECT
    p.playlist_id,
    p.spotify_link,
    u.name AS curator_name,
    a.prompt_text,
    a.parameters,
    mi.position,
    m.title AS music_title
FROM Playlist p
JOIN "User" u ON p.user_id = u.user_id
JOIN AuditLog a ON p.playlist_id = a.playlist_id
JOIN PlaylistItem mi ON p.playlist_id = mi.playlist_id
JOIN Music m ON mi.music_id = m.music_id;
CREATE OR REPLACE FUNCTION update_playlist_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_ultima_modificacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER update_playlist_modified_trigger
BEFORE UPDATE ON Playlist
FOR EACH ROW
EXECUTE FUNCTION update_playlist_modified();
CREATE INDEX idx_artist_name ON Artist(name);
CREATE INDEX idx_music_title ON Music(title);