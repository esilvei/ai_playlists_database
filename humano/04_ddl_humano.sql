CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE usuarios (
    id_usuario UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email_institucional VARCHAR(100) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artistas (
    id_spotify VARCHAR(50) PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    indice_popularidade INT
);

CREATE TABLE generos (
    id_genero SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL
);

-- ADIÇÃO 1: Tabela associativa recursiva para permitir Herança Múltipla de Gêneros
CREATE TABLE generos_hierarquia (
    genero_pai_id INT NOT NULL REFERENCES generos(id_genero) ON DELETE CASCADE,
    genero_filho_id INT NOT NULL REFERENCES generos(id_genero) ON DELETE CASCADE,
    PRIMARY KEY (genero_pai_id, genero_filho_id)
);

CREATE TABLE artistas_generos (
    artista_id VARCHAR(50) NOT NULL REFERENCES artistas(id_spotify) ON DELETE CASCADE,
    genero_id INT NOT NULL REFERENCES generos(id_genero) ON DELETE CASCADE,
    PRIMARY KEY (artista_id, genero_id)
);

CREATE TABLE albuns (
    id_album VARCHAR(50) PRIMARY KEY,
    artista_id VARCHAR(50) NOT NULL REFERENCES artistas(id_spotify) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    data_lancamento DATE NOT NULL,
    tipo_lancamento VARCHAR(50)
);

-- ADIÇÃO 2: Inclusão das restrições CHECK para garantir a integridade matemática da IA
CREATE TABLE musicas (
    id_musica VARCHAR(50) PRIMARY KEY,
    album_id VARCHAR(50) NOT NULL REFERENCES albuns(id_album) ON DELETE CASCADE,
    nome VARCHAR(200) NOT NULL,
    duracao_ms INT NOT NULL,
    energia REAL CHECK (energia >= 0.0 AND energia <= 1.0),
    valencia REAL CHECK (valencia >= 0.0 AND valencia <= 1.0),
    dancabilidade REAL CHECK (dancabilidade >= 0.0 AND dancabilidade <= 1.0),
    bpm REAL
);

-- ADIÇÃO 3: Tabela associativa conectando Música e Artista (com o atributo de 'papel')
CREATE TABLE musicas_artistas (
    musica_id VARCHAR(50) NOT NULL REFERENCES musicas(id_musica) ON DELETE CASCADE,
    artista_id VARCHAR(50) NOT NULL REFERENCES artistas(id_spotify) ON DELETE CASCADE,
    papel VARCHAR(50) NOT NULL, -- Ex: 'Principal', 'Feature', 'Produtor'
    PRIMARY KEY (musica_id, artista_id, papel)
);

-- ADIÇÃO 4: Tabela associativa conectando Música e Gênero
CREATE TABLE musicas_generos (
    musica_id VARCHAR(50) NOT NULL REFERENCES musicas(id_musica) ON DELETE CASCADE,
    genero_id INT NOT NULL REFERENCES generos(id_genero) ON DELETE CASCADE,
    PRIMARY KEY (musica_id, genero_id)
);

CREATE TABLE playlists (
    id_playlist UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    log_texto_pedido TEXT NOT NULL,
    log_parametros_ia TEXT,
    link_streaming VARCHAR(255),
    data_hora_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE itens_playlist (
    playlist_id UUID NOT NULL REFERENCES playlists(id_playlist) ON DELETE CASCADE,
    musica_id VARCHAR(50) NOT NULL REFERENCES musicas(id_musica) ON DELETE CASCADE,
    posicao INT NOT NULL,
    PRIMARY KEY (playlist_id, posicao)
);

ALTER TABLE playlists ADD COLUMN data_ultima_modificacao TIMESTAMP;

-- Atualização da View para refletir que as músicas continuam acessíveis, mas a lógica se mantém igual
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

CREATE INDEX idx_artistas_nome ON artistas(nome_completo);
CREATE INDEX idx_musicas_nome ON musicas(nome);