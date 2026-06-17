# Documento de Requisitos: Sistema de Controle e Curadoria de Playlists por IA

**Equipe:** Guilherme Dorea Almeida, João Pedro Lima Ribeiro, Eduardo Fontes Baltazar da Silveira.
**Disciplina:** MATA60 - Banco de Dados (UFBA)

---

## 1. Requisitos Funcionais (RF)

Os Requisitos Funcionais descrevem o que o sistema (banco de dados) deve ser capaz de armazenar, rastrear e executar para satisfazer as necessidades da plataforma de streaming.

* **RF01 - Gestão de Curadores:** O sistema deve armazenar os usuários internos (curadores) contendo identificador único (UUID), nome completo, e-mail institucional e data de cadastro.
* **RF02 - Catálogo de Artistas:** O sistema deve registrar os artistas utilizando o código único do Spotify como identificador, armazenando também o nome completo e o índice de popularidade.
* **RF03 - Catálogo de Álbuns:** O sistema deve armazenar álbuns musicais com seu código único, título, data de lançamento e tipo de lançamento (álbum, single, EP).
* **RF04 - Acervo de Músicas:** O sistema deve registrar as músicas com suas características acústicas utilizadas pela IA (duração em milissegundos, energia, valência, dançabilidade e BPM).
* **RF05 - Gestão de Gêneros:** O sistema deve cadastrar os gêneros musicais, permitindo a criação de uma rede de relacionamentos (Grafo de Conhecimento) entre eles, suportando mapeamento de derivações e fusão de estilos.
* **RF06 - Auditoria de Playlists (IA):** O sistema deve registrar as playlists geradas pela inteligência artificial. Cada registro deve conter um identificador único, o texto exato do pedido (prompt), os parâmetros interpretados pela IA (log), o link de streaming gerado, a data/hora de criação e qual curador solicitou.
* **RF07 - Rastreamento de Itens da Playlist:** O sistema deve armazenar exatamente quais músicas compõem cada playlist, registrando a ordem exata (posição) de reprodução.
* **RF08 - Histórico e Relatórios:** O banco deve fornecer dados rastreáveis para a geração de relatórios gerenciais sobre gêneros mais pedidos, médias acústicas (ex: energia média) e contagem de artistas nas curadorias.

---

## 2. Regras de Negócio (RN)

As Regras de Negócio definem as restrições lógicas, integridade e cardinalidades que o banco de dados deve forçar fisicamente (Constraints).

* **RN01 (Unicidade de Álbum):** Uma música pertence a um, e somente um, álbum. Não existem músicas "órfãs" de álbum.
* **RN02 (Autoria Múltipla e Papéis):** Uma música pode ser gravada por múltiplos artistas e um artista pode gravar múltiplas músicas. O sistema deve registrar qual foi o papel do artista na faixa (ex: Artista Principal, Feature, Produtor).
* **RN03 (Classificação Multi-Gênero):** Um artista pode ser classificado em vários gêneros musicais distintos, assim como uma música também pode pertencer a múltiplos gêneros.
* **RN04 (Herança de Gêneros):** Um gênero pode ser subdividido em vários subgêneros, e um subgênero pode derivar de múltiplos gêneros pais (relação recursiva N:M).
* **RN05 (Repetição em Playlists):** A mesma música pode ser adicionada várias vezes na mesma playlist, **desde que ocupe posições de reprodução diferentes**. A identificação única do item na playlist é a combinação rigorosa da Chave Primária Composta `[ID da Playlist + Posição]`.
* **RN06 (Restrições de Domínio - CHECK):** Os parâmetros acústicos gerados pela IA (Energia, Valência e Dançabilidade) devem obrigatoriamente ser valores decimais restritos ao intervalo matemático entre `0.0` e `1.0`.
* **RN07 (Dependência de Curador):** Nenhuma playlist pode existir sem estar obrigatoriamente vinculada ao usuário (curador) que fez a requisição à IA.