CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE genero (
    id_genero SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE artista (
    id_spotify VARCHAR(255) PRIMARY KEY,
    nome_completo VARCHAR(255) NOT NULL,
    indice_popularidade FLOAT
);

CREATE TABLE pertence (
    id_spotify VARCHAR(255) REFERENCES artista(id_spotify) ON DELETE CASCADE,
    id_genero INTEGER REFERENCES genero(id_genero) ON DELETE CASCADE,
    PRIMARY KEY (id_spotify, id_genero)
);

CREATE TABLE album (
    id_album VARCHAR(255) PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    data_lancamento DATE NOT NULL,
    tipo_lancamento VARCHAR(50) NOT NULL CHECK (tipo_lancamento IN ('single', 'EP', 'album')),
    id_artista VARCHAR(255) REFERENCES artista(id_spotify) ON DELETE CASCADE
);

CREATE TABLE musica (
    id_musica VARCHAR(255) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    duracao_ms INTEGER NOT NULL,
    energia FLOAT CHECK (energia BETWEEN 0.0 AND 1.0),
    valencia FLOAT CHECK (valencia BETWEEN 0.0 AND 1.0),
    dancabilidade FLOAT CHECK (dancabilidade BETWEEN 0.0 AND 1.0),
    bpm INTEGER,
    id_album VARCHAR(255) REFERENCES album(id_album) ON DELETE CASCADE
);

CREATE TABLE usuario (
    id_usuario UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    email_institucional VARCHAR(255) NOT NULL,
    data_cadastro DATE NOT NULL
);

CREATE TABLE playlist (
    id_playlist UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    log_texto_pedido TEXT,
    log_parametros_ia TEXT,
    link_streaming VARCHAR(255),
    data_hora_criacao TIMESTAMP NOT NULL,
    id_usuario UUID REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE contem (
    id_playlist UUID REFERENCES playlist(id_playlist) ON DELETE CASCADE,
    id_musica VARCHAR(255) REFERENCES musica(id_musica) ON DELETE CASCADE,
    posicao INTEGER NOT NULL,
    PRIMARY KEY (id_playlist, id_musica)
);

-- DML Inicial
INSERT INTO genero (nome) VALUES
('Metal'),
('Samba'),
('Música Clássica');

INSERT INTO artista (id_spotify, nome_completo, indice_popularidade) VALUES
('artist1', 'Metallica', 0.85),
('artist2', 'Carmen Miranda', 0.75);

INSERT INTO pertence (id_spotify, id_genero) VALUES
('artist1', 1),
('artist1', 2),
('artist2', 2);

INSERT INTO album (id_album, titulo, data_lancamento, tipo_lancamento, id_artista) VALUES
('album1', 'Ride the Lightning', '1984-07-27', 'album', 'artist1'),
('album2', 'Samba da Benção', '1950-01-01', 'single', 'artist2');

INSERT INTO musica (id_musica, nome, duracao_ms, energia, valencia, dancabilidade, bpm, id_album) VALUES
('music1', 'Fade to Black', 300000, 0.8, 0.2, 0.7, 120, 'album1'),
('music2', 'Master of Puppets', 320000, 0.9, 0.3, 0.8, 130, 'album1'),
('music3', 'Samba do Avião', 200000, 0.5, 0.6, 0.9, 100, 'album2'),
('music4', 'Benção', 250000, 0.4, 0.7, 0.8, 90, 'album2');

INSERT INTO usuario (nome, email_institucional, data_cadastro) VALUES
('Curador1', 'curador1@startup.com', '2023-10-01');

INSERT INTO playlist (log_texto_pedido, log_parametros_ia, link_streaming, data_hora_criacao, id_usuario) VALUES
('Criar uma lista de faixas de metal com BPM alto e baixa valência', 'energia: 0.8, BPM: 120', 'https://open.spotify.com/playlist/123', '2023-10-05 14:30:00', (SELECT id_usuario FROM usuario WHERE email_institucional = 'curador1@startup.com'));

INSERT INTO contem (id_playlist, id_musica, posicao) VALUES
((SELECT id_playlist FROM playlist WHERE log_texto_pedido = 'Criar uma lista de faixas de metal com BPM alto e baixa valência'), 'music1', 1),
((SELECT id_playlist FROM playlis