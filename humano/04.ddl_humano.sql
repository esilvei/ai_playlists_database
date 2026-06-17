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

CREATE TABLE musicas_artistas (
    musica_id VARCHAR(50) NOT NULL REFERENCES musicas(id_musica) ON DELETE CASCADE,
    artista_id VARCHAR(50) NOT NULL REFERENCES artistas(id_spotify) ON DELETE CASCADE,
    papel VARCHAR(50) NOT NULL,
    PRIMARY KEY (musica_id, artista_id, papel)
);

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

CREATE TABLE playlists_colaboradores (
    playlist_id UUID NOT NULL REFERENCES playlists(id_playlist) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    data_ingresso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, usuario_id)
);

CREATE TABLE itens_playlist (
    playlist_id UUID NOT NULL REFERENCES playlists(id_playlist) ON DELETE CASCADE,
    musica_id VARCHAR(50) NOT NULL REFERENCES musicas(id_musica) ON DELETE CASCADE,
    posicao INT NOT NULL,
    PRIMARY KEY (playlist_id, posicao)
);
