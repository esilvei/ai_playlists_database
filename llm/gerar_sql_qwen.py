import requests
import datetime
import os

def chamar_ollama(modelo, prompt_completo):
    """Função auxiliar para disparar o prompt para a API do Ollama e forçar a limpeza extrema."""
    url = "http://localhost:11434/api/generate"
    payload = {
        "model": modelo,
        "prompt": prompt_completo,
        "stream": False,
        "options": {
            "temperature": 0.1  # Temperatura baixa para forçar precisão técnica em SQL e Matemática
        }
    }
    response = requests.post(url, json=payload)
    response.raise_for_status()

    texto_bruto = response.json().get("response", "")

    # 1. Limpeza do Raciocínio (Chain of Thought)
    if "</think>" in texto_bruto:
        texto_limpo = texto_bruto.split("</think>")[-1]
    else:
        texto_limpo = texto_bruto

    # 2. Limpeza de formatação Markdown
    texto_limpo = (
        texto_limpo
        .replace("```sql\n", "")
        .replace("```markdown\n", "")
        .replace("```\n", "")
        .replace("```", "")
    )

    return texto_limpo.strip()


def executar_pipeline_etapas():
    modelo = "qwen3:30b"
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    os.makedirs("saidas_llm", exist_ok=True)

    print(f"🚀 Iniciando Pipeline com Memória Acumulada e Filtro Estrito ({modelo})...")

    # =========================================================================
    # REQUISITOS DE NEGÓCIOS BASE (A raiz de todo o contexto)
    # =========================================================================
    historia_pura = """
    Uma startup de tecnologia musical deseja desenvolver um sistema interno para gerenciar,
    auditar e rastrear a criação de playlists personalizadas geradas por Inteligência Artificial.

    ## Requisitos Funcionais (RF)

    RF01 - Gestão de Curadores: O sistema deve armazenar os usuários internos (curadores) contendo
    identificador único (UUID), nome completo, e-mail institucional e data de cadastro.

    RF02 - Catálogo de Artistas: O sistema deve registrar os artistas utilizando o código único do
    Spotify como identificador, armazenando também o nome completo e o índice de popularidade.

    RF03 - Catálogo de Álbuns: O sistema deve armazenar álbuns musicais com seu código único, título,
    data de lançamento e tipo de lançamento (álbum, single, EP).

    RF04 - Acervo de Músicas: O sistema deve registrar as músicas com suas características acústicas
    utilizadas pela IA (duração em milissegundos, energia, valência, dançabilidade e BPM).

    RF05 - Gestão de Gêneros: O sistema deve cadastrar os gêneros musicais, permitindo a criação de
    uma rede de relacionamentos (Grafo de Conhecimento) entre eles, suportando mapeamento de
    derivações e fusão de estilos (herança múltipla N:M).

    RF06 - Auditoria de Playlists (IA): O sistema deve registrar as playlists geradas pela
    inteligência artificial. Cada registro deve conter um identificador único, o texto exato do pedido
    (prompt), os parâmetros interpretados pela IA (log em JSON), o link de streaming gerado, a
    data/hora de criação e qual curador solicitou.

    RF07 - Rastreamento de Itens da Playlist: O sistema deve armazenar exatamente quais músicas
    compõem cada playlist, registrando a ordem exata (posição) de reprodução.

    RF08 - Histórico e Relatórios: O banco deve fornecer dados rastreáveis para a geração de
    relatórios gerenciais sobre gêneros mais pedidos, médias acústicas (ex: energia média) e
    contagem de artistas nas curadorias.

    ## Regras de Negócio (RN)

    RN01 (Unicidade de Álbum): Uma música pertence a um, e somente um, álbum. Não existem músicas
    "órfãs" de álbum.

    RN02 (Autoria Múltipla e Papéis): Uma música pode ser gravada por múltiplos artistas e um artista
    pode gravar múltiplas músicas. O sistema deve registrar qual foi o papel do artista na faixa
    (ex: Artista Principal, Feature, Produtor).

    RN03 (Classificação Multi-Gênero): Um artista pode ser classificado em vários gêneros musicais
    distintos, assim como uma música também pode pertencer a múltiplos gêneros.

    RN04 (Herança de Gêneros): Um gênero pode ser subdividido em vários subgêneros, e um subgênero
    pode derivar de múltiplos gêneros pais (relação recursiva N:M).

    RN05 (Repetição em Playlists): A mesma música pode ser adicionada várias vezes na mesma playlist,
    desde que ocupe posições de reprodução diferentes. A identificação única do item na playlist é a
    combinação rigorosa da Chave Primária Composta [ID da Playlist + Posição].

    RN06 (Restrições de Domínio - CHECK): Os parâmetros acústicos gerados pela IA (Energia, Valência e
    Dançabilidade) devem obrigatoriamente ser valores decimais restritos ao intervalo entre 0.0 e 1.0.

    RN07 (Dependência de Curador): Nenhuma playlist pode existir sem estar obrigatoriamente vinculada
    ao usuário (curador) que fez a requisição à IA.
    """

    try:
        # =========================================================================
        # ENTREGÁVEL 1: MODELO CONCEITUAL
        # =========================================================================
        print("\n⏳ [1/4] Gerando Modelo Conceitual a partir dos Requisitos...")
        contexto_acumulado = f"[REQUISITOS DE NEGÓCIO]\n{historia_pura}\n"

        prompt_conceitual = f"""Aja como um Arquiteto de Banco de Dados Sênior. Leia o contexto abaixo:

{contexto_acumulado}

[TAREFA 1 - MODELO CONCEITUAL]
Gere um documento Markdown (.md) contendo o Modelo Conceitual Entidade-Relacionamento completo.
Liste detalhadamente:

1. As Entidades (Principais e Associativas), identificando claramente as entidades fracas se houver.
2. Os Atributos de cada entidade, marcando:
   - PKs (Chaves Primárias)
   - FKs (Chaves Estrangeiras)
   - Atributos que residem no relacionamento N:N (ex: papel em Musica-Artista, posição em Playlist-Musica)
3. Os Relacionamentos entre as entidades com:
   - Nome do relacionamento
   - Cardinalidade (1:1, 1:N, N:M)
   - Participação (total/parcial)
   - Destaque especial para: resolução dos N:M em tabelas associativas, o auto-relacionamento N:M
     recursivo de gêneros (hierarquia de herança múltipla) e a chave primária composta de
     itens_playlist (id_playlist + posicao).

Garanta que o modelo cubra TODAS as regras de negócio RN01 a RN07.
Entregue APENAS o documento Markdown final, sem preâmbulo."""

        resultado_conceitual = chamar_ollama(modelo, prompt_conceitual)
        with open(f"saidas_llm/01_modelo_conceitual_{timestamp}.md", "w", encoding="utf-8") as f:
            f.write(resultado_conceitual)
        print("✅ Entregável 1 salvo! → 01_modelo_conceitual")

        # =========================================================================
        # ENTREGÁVEL 2: SCRIPT DDL + RECURSOS AVANÇADOS (indexação, backup)
        # =========================================================================
        print("\n⏳ [2/4] Gerando Script DDL + Recursos Avançados (PostgreSQL)...")
        contexto_acumulado += f"\n[1. MODELO CONCEITUAL GERADO]\n{resultado_conceitual}\n"

        prompt_ddl = f"""Aja como um DBA PostgreSQL Sênior. Leia todo o escopo definido:

{contexto_acumulado}

[TAREFA 2 - SCRIPT DDL E RECURSOS AVANÇADOS]
Gere EXCLUSIVAMENTE o script SQL DDL em PostgreSQL, na 3ª Forma Normal (3FN), contendo:

1. CREATE EXTENSION IF NOT EXISTS "pgcrypto";
2. DROP TABLE IF EXISTS ... em ordem reversa de dependência antes de criar.
3. CREATE TABLE para TODAS as entidades e tabelas associativas:
   - curadores (UUID como PK, gerado com gen_random_uuid())
   - artistas (spotify_id como PK, texto)
   - albuns (FK para artistas, CHECK para tipo em ('album','single','EP'))
   - musicas (FK para albuns, CHECK para energia/valencia/dancabilidade BETWEEN 0.0 AND 1.0)
   - generos (auto-relacionamento via tabela associativa genero_hierarquia)
   - musica_artista (PK composta: id_musica + spotify_id, atributo 'papel' NOT NULL)
   - musica_genero (PK composta: id_musica + id_genero)
   - artista_genero (PK composta: spotify_id + id_genero)
   - genero_hierarquia (PK composta: id_genero_filho + id_genero_pai — auto-relacionamento N:M)
   - playlists (FK para curadores, campo 'prompt_texto' TEXT, 'log_parametros' JSONB,
     'data_ultima_modificacao' TIMESTAMP)
   - itens_playlist (PK composta: id_playlist + posicao, FK para musicas — implementa RN05)
4. ON DELETE CASCADE em todas as FKs pertinentes.
5. CREATE OR REPLACE FUNCTION + CREATE TRIGGER para atualizar 'data_ultima_modificacao'
   automaticamente em qualquer UPDATE na tabela playlists.
6. CREATE VIEW 'vw_relatorio_curadoria' que cruze: curador, playlist, prompt, e as músicas
   (com nome, posição e energia) — útil para RF08.
7. Indexação e Recuperação:
   - CREATE INDEX idx_artistas_nome ON artistas(nome);
   - CREATE INDEX idx_musicas_nome ON musicas(nome);
   - CREATE INDEX idx_musicas_energia ON musicas(energia);
   - CREATE INDEX idx_musicas_dancabilidade ON musicas(dancabilidade);
   - CREATE INDEX idx_playlists_curador ON playlists(id_curador);
   - EXPLAIN ANALYZE (como comentário SQL) para a consulta de músicas por nome.
8. Comando pg_dump para backup lógico completo (como comentário SQL ao final).

Entregue APENAS o script SQL puro, sem explicações fora do código."""

        resultado_ddl = chamar_ollama(modelo, prompt_ddl)
        with open(f"saidas_llm/02_ddl_{timestamp}.sql", "w", encoding="utf-8") as f:
            f.write(resultado_ddl)
        print("✅ Entregável 2 salvo! → 02_ddl")

        # =========================================================================
        # ENTREGÁVEL 3: SCRIPT DML (Inserts + Transações)
        # =========================================================================
        print("\n⏳ [3/4] Gerando Script DML (Inserts e Transações)...")
        contexto_acumulado += f"\n[2. ESTRUTURA DDL GERADA]\n{resultado_ddl}\n"

        prompt_dml = f"""Aja como um Engenheiro de Dados. Este é o projeto atual:

{contexto_acumulado}

[TAREFA 3 - SCRIPT DML E TRANSAÇÕES]
Gere EXCLUSIVAMENTE o script SQL DML para popular o banco, validando TODAS as regras de negócio.
O script deve conter, nesta ordem:

1. INSERT de 2 curadores (usando gen_random_uuid() para o UUID).
2. INSERT de 3 gêneros formando hierarquia de herança múltipla:
   - Ex: 'Metal' e 'Eletrônico' como pais; 'Industrial Metal' como filho de ambos.
   - Inserir as relações na tabela genero_hierarquia.
3. INSERT de 3 artistas com seus gêneros associados (tabela artista_genero).
4. INSERT de 1 álbum (tipo 'album') e 3 músicas com metadados acústicos variados:
   - Pelo menos 1 música com energia > 0.9 (para a Consulta 1).
   - Metadados variados de dançabilidade entre as músicas.
5. INSERT na tabela musica_artista:
   - 1 artista como 'Principal' em cada música.
   - 1 artista diferente como 'Feature' em ao menos 1 música.
6. INSERT de 1 gênero para pelo menos 1 música (tabela musica_genero).
7. Criação de 2 playlists em bloco transacional:
   BEGIN;
     SAVEPOINT sp_playlist1;
     INSERT INTO playlists ... (com prompt_texto e log_parametros JSONB preenchidos);
     -- Adicionar pelo menos 10 músicas à playlist 1 (mesmo repetindo, em posições diferentes)
     -- para satisfazer a Consulta 2 (playlists com >= 10 músicas).
     INSERT INTO itens_playlist ... (várias posições);
     SAVEPOINT sp_playlist2;
     INSERT INTO playlists ... (segunda playlist com prompt e log diferentes);
     INSERT INTO itens_playlist ... (pelo menos 3 músicas para a Consulta 3);
   COMMIT;

Entregue APENAS o script SQL limpo, sem texto explicativo fora do código."""

        resultado_dml = chamar_ollama(modelo, prompt_dml)
        with open(f"saidas_llm/03_dml_{timestamp}.sql", "w", encoding="utf-8") as f:
            f.write(resultado_dml)
        print("✅ Entregável 3 salvo! → 03_dml")

        # =========================================================================
        # ENTREGÁVEL 4: 3 CONSULTAS SQL + ÁLGEBRA RELACIONAL
        # =========================================================================
        print("\n⏳ [4/4] Gerando Consultas SQL e Álgebra Relacional...")
        contexto_acumulado += f"\n[3. DADOS DML GERADOS]\n{resultado_dml}\n"

        prompt_consultas = f"""Aja como um Especialista em Banco de Dados com domínio em Álgebra Relacional e PostgreSQL.
Leia todo o histórico do projeto:

{contexto_acumulado}

[TAREFA 4 - CONSULTAS SQL E ÁLGEBRA RELACIONAL]
Gere um documento Markdown (.md) contendo as 3 consultas abaixo. Para cada consulta, entregue:
  (a) Enunciado da consulta
  (b) A Álgebra Relacional formal usando notação LaTeX ($$...$$), com os operadores:
      σ (seleção), π (projeção), ⨝ (junção natural ou com condição), ρ (renomeação),
      γ (agregação com GROUP BY), e operadores de conjunto se necessário.
  (c) O script SQL PostgreSQL equivalente, otimizado e comentado.

---

### Consulta 1 — Músicas com Altíssima Energia e seus Artistas

Enunciado: Quais são os nomes das músicas, os nomes dos seus respectivos artistas e os papéis
que eles exerceram (Principal, Feature, etc.), mas apenas para músicas com altíssima energia
(energia > 0.9)?

Dicas de álgebra: use σ para filtrar energia > 0.9, ⨝ para juntar musicas, musica_artista e
artistas, e π para projetar apenas nome_musica, nome_artista e papel.

---

### Consulta 2 — Curadores das Playlists Mais Energéticas (mínimo 10 músicas)

Enunciado: Quais curadores criaram as playlists mais energéticas, considerando apenas playlists
que tenham pelo menos 10 músicas?

Dicas de álgebra: use γ (agrupamento) por id_playlist com COUNT(*) >= 10 e AVG(energia),
depois ⨝ com curadores, e ordene por média de energia decrescente.

---

### Consulta 3 — TOP 3 Músicas Mais Dançáveis por Playlist (com Prompt da IA)

Enunciado: Quero um relatório que mostre o Prompt que a IA recebeu e APENAS as TOP 3 músicas
mais dançáveis de cada playlist gerada.

Dicas de álgebra: use uma subexpressão com ROW_NUMBER() ou RANK() particionado por id_playlist
ordenado por dançabilidade DESC, depois filtre rank <= 3 e projete prompt_texto + nome_musica
+ dançabilidade. Na álgebra relacional, represente o ranqueamento com γ e uma notação de
janela (window function).

---

Entregue APENAS o documento Markdown final, sem preâmbulo."""

        resultado_consultas = chamar_ollama(modelo, prompt_consultas)
        with open(f"saidas_llm/04_consultas_e_algebra_{timestamp}.md", "w", encoding="utf-8") as f:
            f.write(resultado_consultas)
        print("✅ Entregável 4 salvo! → 04_consultas_e_algebra")

        # =========================================================================
        # RESUMO FINAL
        # =========================================================================
        print(f"""
🎉 Pipeline 100% concluído! Arquivos gerados na pasta 'saidas_llm/':
   📄 01_modelo_conceitual_{timestamp}.md   → Modelo Conceitual ER
   📄 02_ddl_{timestamp}.sql               → DDL + Indexação + Backup
   📄 03_dml_{timestamp}.sql               → DML + Transações
   📄 04_consultas_e_algebra_{timestamp}.md → 3 Consultas SQL + Álgebra Relacional
        """)

    except requests.exceptions.RequestException as e:
        print(f"❌ Erro de conexão com o Ollama: {e}")
        print("   Certifique-se de que o servidor Ollama está rodando em http://localhost:11434")


if __name__ == "__main__":
    executar_pipeline_etapas()