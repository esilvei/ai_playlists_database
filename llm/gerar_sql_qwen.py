import requests
import datetime
import os
import re


def chamar_ollama(modelo, prompt_completo):
    """Função auxiliar para disparar o prompt para a API do Ollama e forçar a limpeza extrema."""
    url = "http://localhost:11434/api/generate"
    payload = {
        "model": modelo,
        "prompt": prompt_completo,
        "stream": False
    }
    response = requests.post(url, json=payload)
    response.raise_for_status()

    texto_bruto = response.json().get("response", "")

    # 1. Limpeza do Raciocínio (Chain of Thought)
    # Se houver a tag de fechamento, divide o texto e pega apenas tudo o que vem DEPOIS dela
    if "</think>" in texto_bruto:
        texto_limpo = texto_bruto.split("</think>")[-1]
    else:
        texto_limpo = texto_bruto

    # 2. Limpeza de formatação Markdown (remove ```sql, ```md e ```)
    texto_limpo = texto_limpo.replace("```sql", "").replace("```markdown", "").replace("```", "")

    return texto_limpo.strip()


def executar_pipeline_etapas():
    modelo = "qwen3:30b"
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    os.makedirs("saidas_llm", exist_ok=True)

    print(f"🚀 Iniciando Pipeline com Memória Acumulada e Filtro Estrito ({modelo})...")

    # =========================================================================
    # REQUISITOS DE NEGÓCIOS BASE (A raiz de todo o contexto)
    # =========================================================================
    historia_pura = """Uma startup de tecnologia musical deseja desenvolver um sistema interno para gerenciar, auditar e rastrear a criação de playlists personalizadas geradas por Inteligência Artificial. Atualmente, os curadores da empresa utilizam ferramentas soltas para buscar músicas, analisar suas características sonoras e agrupá-las, o que gera inconsistências. Para resolver isso, a empresa decidiu construir um banco de dados relacional robusto que atuará como o núcleo de todo o catálogo musical e do histórico de curadoria, permitindo uma integração fluida com a API do Spotify e garantindo total rastreabilidade.
Para manter a consistência do acervo, o banco de dados deve registrar informações detalhadas sobre os Artistas. Cada artista deve possuir um código de identificação único (proveniente do Spotify) para evitar duplicidade de nomes homônimos, além de armazenar seu nome completo e um índice de popularidade atualizado. Sabendo que a categorização musical é complexa, o sistema precisa catalogar os diversos Gêneros musicais existentes. Como um artista pode transitar por estilos muito diferentes ao longo da carreira, o sistema deve permitir que um mesmo artista seja classificado em vários gêneros, assim como um gênero pode englobar múltiplos artistas.
Os artistas são os responsáveis por lançar os Álbuns. O sistema deve registrar o código único de cada álbum, o título da obra, a data de lançamento oficial e o tipo de lançamento (se é um "single", um "EP" ou um álbum completo). Para garantir a integridade da informação, um álbum deve obrigatoriamente pertencer a um artista específico, não podendo existir álbuns "órfãos" no banco de dados.
Dentro de cada álbum, o banco catalogará as Músicas (ou faixas). Esta é a entidade mais crítica do sistema. Além do código de identificação único de cada música, nome e duração em milissegundos, o banco de dados precisa armazenar os metadados acústicos (audio features) fornecidos pela API. Estes dados incluem índices numéricos detalhados para a energia da música, a valência (que mede a positividade ou obscuridade da faixa), a dançabilidade e o tempo (em BPM). A precisão dessas informações é fundamental, pois será a base matemática que a Inteligência Artificial utilizará para cruzar dados e selecionar as faixas adequadas no futuro. Cada música está vinculada a um único álbum.
A operação do sistema será feita por Usuários internos da empresa (os curadores). O banco deve armazenar o identificador do usuário, seu nome, e-mail institucional e a data de cadastro. Esses usuários farão requisições textuais (prompts) para a IA solicitando compilações específicas.
Para manter a auditoria rígida exigida pela diretoria, toda vez que a IA processar um pedido, o sistema deve registrar a Playlist gerada. O registro desta playlist deve conter um código de identificação próprio, o link de integração para a plataforma de streaming, a data e hora exata da criação, e, mais importante, deve estar obrigatoriamente vinculada ao usuário que fez a solicitação. Além disso, o sistema deve possuir um Log de Auditoria (Prompts), que armazene o texto exato digitado pelo usuário e os parâmetros médios que a IA tentou atingir, para fins de rastreabilidade.
Por fim, é imprescindível saber exatamente quais faixas compõem cada curadoria. Para isso, o banco de dados deve rastrear detalhadamente os Itens da Playlist. O sistema deve registrar quais músicas foram alocadas em quais playlists, armazenando a posição sequencial (ordem de execução) de cada música dentro de uma playlist específica."""

    try:
        # =========================================================================
        # ENTREGÁVEL 1: MODELO CONCEITUAL
        # =========================================================================
        print("\n⏳ [1/4] Gerando Modelo Conceitual a partir da História...")

        contexto_acumulado = f"[REQUISITOS DE NEGÓCIO]\n{historia_pura}\n"

        prompt_diagrama = f"""Aja como um Professor de Banco de Dados. Leia o contexto abaixo:

{contexto_acumulado}

[TAREFA 1 - MODELO CONCEITUAL]
Gere um documento Markdown (.md) contendo o Modelo Conceitual (Diagrama ER Lógico) deduzido a partir do texto.
Liste detalhadamente:
1. As Entidades.
2. Os Atributos de cada entidade, especificando quais são as Chaves Primárias (PK).
3. Os Relacionamentos entre as entidades e suas Cardinalidades (1:1, 1:N, N:N).

Entregue APENAS o documento Markdown final. Não justifique suas escolhas."""

        resultado_diagrama = chamar_ollama(modelo, prompt_diagrama)
        with open(f"saidas_llm/01_diagrama_conceitual_llm_{timestamp}.md", "w", encoding="utf-8") as f:
            f.write(resultado_diagrama)
        print("✅ Entregável 1 salvo!")

        # =========================================================================
        # ENTREGÁVEL 2: ÁLGEBRA RELACIONAL E CÁLCULO
        # =========================================================================
        print("\n⏳ [2/4] Gerando Álgebra e Cálculo Relacional...")

        contexto_acumulado += f"\n[1. MODELO CONCEITUAL GERADO (Base da Arquitetura)]\n{resultado_diagrama}\n"

        prompt_calculos = f"""Aja como um Especialista em Teoria de Banco de Dados. Leia o histórico do projeto até agora:

{contexto_acumulado}

[TAREFA 2 - TEORIA MATEMÁTICA]
Baseado no modelo gerado, gere um documento Markdown (.md) contendo:
1. A Álgebra Relacional para a consulta: "Quais são os nomes das músicas presentes na playlist de identificador X?"
2. O Cálculo Relacional de Tuplas (CRT) para a mesma consulta.
3. Um comando demonstrando o uso do 'pg_dump' para backup lógico do banco.
4. Um comando demonstrando o uso do 'EXPLAIN ANALYZE' para consultar músicas pelo nome.

Utilize a notação matemática padrão LaTeX ($$). Entregue APENAS o documento Markdown."""

        resultado_calculos = chamar_ollama(modelo, prompt_calculos)
        with open(f"saidas_llm/02_algebra_e_calculo_llm_{timestamp}.md", "w", encoding="utf-8") as f:
            f.write(resultado_calculos)
        print("✅ Entregável 2 salvo!")

        # =========================================================================
        # ENTREGÁVEL 3: ESTRUTURA (DDL + SQL 3)
        # =========================================================================
        print("\n⏳ [3/4] Gerando Script DDL (PostgreSQL)...")

        contexto_acumulado += f"\n[2. TEORIA MATEMÁTICA GERADA]\n{resultado_calculos}\n"

        prompt_ddl = f"""Aja como um Arquiteto de Banco de Dados Sênior. Leia todo o escopo do projeto já definido:

{contexto_acumulado}

[TAREFA 3 - SCRIPT DDL E RECURSOS AVANÇADOS]
Gere EXCLUSIVAMENTE o script SQL DDL para PostgreSQL (3ª Forma Normal) contendo:
1. CREATE EXTENSION IF NOT EXISTS pgcrypto.
2. CREATE TABLE para as entidades do Modelo Conceitual (Utilize UUID para usuários e playlists, VARCHAR para códigos do Spotify, metadados com restrição CHECK entre 0.0 e 1.0, e ON DELETE CASCADE).
3. ALTER TABLE na tabela Playlist adicionando a coluna 'data_ultima_modificacao'.
4. CREATE VIEW 'vw_relatorio_curadoria'.
5. CREATE FUNCTION e CREATE TRIGGER atualizando a coluna 'data_ultima_modificacao' no UPDATE da playlist.
6. CREATE INDEX para otimizar buscas por nome de artista e nome da música.

Entregue APENAS o script SQL puro de criação. Não inclua texto explicativo."""

        resultado_ddl = chamar_ollama(modelo, prompt_ddl)
        with open(f"saidas_llm/03_ddl_llm_{timestamp}.sql", "w", encoding="utf-8") as f:
            f.write(resultado_ddl)
        print("✅ Entregável 3 salvo!")

        # =========================================================================
        # ENTREGÁVEL 4: DADOS (DML + TRANSAÇÕES)
        # =========================================================================
        print("\n⏳ [4/4] Gerando Script DML (Inserts e Transações)...")

        contexto_acumulado += f"\n[3. ESTRUTURA DDL GERADA]\n{resultado_ddl}\n"

        prompt_dml = f"""Aja como um Engenheiro de Dados. Este é o repositório completo do projeto atualizado até o momento:

{contexto_acumulado}

[TAREFA 4 - SCRIPT DML E TRANSAÇÕES]
Analisando ESTRITAMENTE as regras de negócio e a estrutura DDL construída, gere EXCLUSIVAMENTE o script SQL DML contendo:
1. INSERT INTO preenchendo as tabelas estruturais com: 1 usuário curador, 3 gêneros (Metal, Samba, Música Clássica), 2 artistas, 2 álbuns e 4 músicas. 
   Lembrete: Como exigido, o gênero 'Música Clássica' NÃO deve ser associado a nenhum artista.
2. INSERT INTO criando 1 Playlist simulando um pedido textual de "alta energia" e mapeando 2 músicas para ela na tabela associativa (respeitando o atributo posição).
3. Um bloco transacional em SQL (BEGIN, SAVEPOINT sp_teste, INSERT INTO inserindo uma nova playlist transacional, COMMIT).

Entregue APENAS o script SQL limpo de DML. Não inclua texto explicativo e não repita o DDL."""

        resultado_dml = chamar_ollama(modelo, prompt_dml)
        with open(f"saidas_llm/04_dml_llm_{timestamp}.sql", "w", encoding="utf-8") as f:
            f.write(resultado_dml)
        print("✅ Entregável 4 salvo!")

        print(f"\n🎉 Pipeline 100% concluído! Arquivos limpos e prontos na pasta 'saidas_llm/'.")

    except requests.exceptions.RequestException as e:
        print(f"❌ Erro de ligação com o Ollama: {e}")


if __name__ == "__main__":
    executar_pipeline_etapas()