
================ PROMTP REQUISITOS ===============================
Com base nessa documentação, você precisa que a IA atue como o DBA (Database Administrator) para gerar o script SQL DDL (Data Definition Language) perfeito e alinhado com o seu MEER. Copie e cole o texto abaixo:

    Prompt para a IA:

    Atue como um Arquiteto de Dados e DBA Sênior especialista em PostgreSQL.

    Eu possuo um Documento de Requisitos e um Modelo de Entidades e Relacionamentos (MEER) para um "Sistema de Controle e Curadoria de Playlists por IA". Com base nas Regras de Negócio e Requisitos Funcionais listados abaixo, preciso que você gere o Script SQL DDL completo para a criação do banco de dados.

    Entidades e Atributos Básicos:

        usuarios (id_usuario UUID, nome, email_institucional, data_cadastro)

        artistas (id_spotify VARCHAR PK, nome_completo, indice_popularidade)

        generos (id_genero SERIAL PK, nome)

        albuns (id_album VARCHAR PK, titulo, data_lancamento, tipo_lancamento)

        musicas (id_musica VARCHAR PK, nome, duracao_ms INT, energia REAL, valencia REAL, dancabilidade REAL, bpm REAL)

        playlists (id_playlist UUID, log_texto_pedido, log_parametros_ia, link_streaming, data_hora_criacao)

    Regras de Negócio (Constraints e Cardinalidades Críticas):

        Relacionamentos 1:N: Usuário cria múltiplas Playlists. Álbum possui múltiplas Músicas. Artista lança múltiplos Álbuns. Propague as Chaves Estrangeiras (FK) adequadamente com ON DELETE CASCADE.

        Relacionamentos N:M (Criar tabelas associativas): >    - Artista x Gênero.

            Música x Gênero.

            Artista x Música (deve conter o atributo 'papel' VARCHAR).

        Recursividade de Gênero: Crie uma tabela associativa para representar a hierarquia (genero_pai, genero_filho).

        A Regra de Ouro da Playlist (Atenção redobrada): Crie a tabela itens_playlist. Ela resolve a relação N:M entre Playlist e Música. Ela deve ter o atributo posicao INT. A Chave Primária (PK) desta tabela DEVE ser composta apenas por (playlist_id, posicao) para permitir que a mesma música apareça mais de uma vez na mesma playlist em posições diferentes.

        Restrições Matemáticas (CHECK): Embutir constraints na tabela musicas para garantir que energia, valencia e dancabilidade fiquem entre 0.0 e 1.0.

    Formato de Saída:
    Entregue apenas o código SQL limpo, utilizando boas práticas de nomenclatura (snake_case) e garantindo que todas as tabelas sejam criadas na ordem correta para não violar as restrições de chave estrangeira. Inclua comentários curtos no SQL explicando a implementação da Regra 4 e da Regra 5.

====== PROMPT MEER ========
Apenas pedir para fazer com base nos requisitos

======== Mapeamento =========
Fazer com base no MEER 

=========== PROMPT ALGEBRA/CALCULO/SQL ==================
Atue como um Professor Universitário de Banco de Dados e especialista em PostgreSQL.

Estou a fazer um trabalho para a disciplina de MATA60 (Banco de Dados) na UFBA sobre a modelagem de uma plataforma de streaming de música. Para o meu artigo e apresentação, preciso demonstrar o domínio sobre Álgebra Relacional e Cálculo Relacional de Tuplas (TRC).

Considere o seguinte trecho do meu esquema lógico:

    Tabela musicas: possui id_musica (PK), nome e energia (float).

    Tabela artistas: possui id_spotify (PK) e nome_completo.

    Tabela musicas_artistas: tabela associativa com musica_id (FK), artista_id (FK) e papel (ex: Principal, Feature).

A Tarefa:
Crie uma consulta do tipo SPJ (Select-Project-Join) para a seguinte regra de negócio: "Retornar o nome da música, o nome completo do artista e o papel que ele exerceu, mas apenas para músicas que possuam energia estritamente maior que 0.9."

Formato de Saída Exigido:

    O Código SQL: A consulta em SQL limpo e otimizado para PostgreSQL.

    Álgebra Relacional: A expressão matemática rigorosa utilizando a notação clássica ( π para projeção, σ para seleção e ⋈ para junção theta). Inclua uma breve explicação semântica do plano de execução de dentro para fora.

    Cálculo Relacional de Tuplas (TRC): A expressão matemática declarativa usando a lógica de predicados de primeira ordem (variáveis ligadas, quantificadores existenciais ∃, conjunções ∧). Inclua uma breve explicação passo a passo.

Formate as equações matemáticas usando notação LaTeX para que eu possa exportar para os meus slides e artigo da SBC.

=========== PROMPTS CONSULTAS ==================
Consulta1:
Quais são os nomes das músicas, os nomes dos seus respectivos artistas e os papéis que eles exerceram (Principal, Feature, etc.), mas apenas para músicas com altíssima energia (energia > 0.9)?

Consulta2:
Quais curadores criaram as playlists mais energéticas, mas considerando apenas playlists que tenham pelo menos 10 músicas 

Consulta3:
Quero um relatório que mostre o Prompt que a IA recebeu e APENAS as TOP 3 músicas mais dançáveis de cada playlist gerada. 

======== PROMPT INDEXAÇÃO =================
Traga-me as 5 músicas mais rápidas (maior BPM) e aplique a indexação

========== PROMPT RECUPERAÇÃO E BACKUP =============
Agora, para a seção final do nosso artigo ('Recuperação e Backup'), crie um texto teórico e prático estruturado da seguinte forma:

Explique como o PostgreSQL garante a Durabilidade das playlists geradas com sucesso em caso de queda de energia do servidor, focando na explicação do mecanismo nativo de WAL (Write-Ahead Logging).

Apresente uma estratégia prática de Backup (Disaster Recovery) para a nossa startup musical. Inclua exemplos reais de comandos de terminal (Linux) utilizando o pg_dump para um backup lógico diário automatizado de toda a estrutura e dados.

Finalize mencionando brevemente a importância do PITR (Point-in-Time Recovery) e do arquivamento de WAL para evitarmos a perda dos logs contínuos gerados pela IA entre os backups diários.