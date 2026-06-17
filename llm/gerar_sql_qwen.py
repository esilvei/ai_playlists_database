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
        "stream": False,
        "options": {
            "temperature": 0.1 # Temperatura baixa para forçar precisão técnica em SQL e Matemática
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
    texto_limpo = texto_limpo.replace("```sql\n", "").replace("```markdown\n", "").replace("```\n", "").replace("```", "")

    return texto_limpo.strip()

def executar_pipeline_etapas():
    modelo = "qwen3:30b"
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    os.makedirs("saidas_llm", exist_ok=True)

    print(f"🚀 Iniciando Pipeline com Memória Acumulada e Filtro Estrito ({modelo})...")

    # =========================================================================
    # REQUISITOS DE NEGÓCIOS BASE (A raiz de todo o contexto)
    # =========================================================================
    historia_pura = """Uma startup de tecnologia musical deseja desenvolver um sistema interno para gerenciar, auditar e rastrear a criação de playlists personalizadas geradas por Inteligência Artificial.
Para manter a consistência do acervo, o banco deve registrar os Artistas, possuindo um código de identificação único (Spotify ID), nome completo e índice de popularidade. 
O sistema precisa catalogar Gêneros musicais. Sabendo que a categorização musical é complexa, um mesmo artista pode ser classificado em vários gêneros e vice-versa. Além disso, a taxonomia musical possui uma relação de hierarquia e herança múltipla entre si (por exemplo, um subgênero pode derivar de múltiplos gêneros pais).
Os artistas lançam Álbuns, contendo código único, título, data de lançamento e tipo de lançamento ("single", "EP" ou álbum). Um álbum deve obrigatoriamente pertencer a um único artista principal responsável pelo lançamento.
Dentro de cada álbum, o banco catalogará as Músicas (faixas), contendo ID, nome, duração em milissegundos e metadados acústicos (energia, valência, dançabilidade e BPM). Cada música está vinculada a um único álbum. Refletindo a indústria atual, uma música pode ser interpretada por vários artistas, sendo estritamente necessário registrar o 'papel' de cada artista na faixa (ex: Principal, Feature, Produtor). Da mesma forma, uma mesma faixa musical pode ser classificada em múltiplos gêneros distintos.
A operação do sistema será feita por Usuários internos (identificador, nome, e-mail institucional e data de cadastro). 
Toda vez que a IA processar um pedido, o sistema registrará a Playlist, contendo ID, link de integração, data/hora e o vínculo obrigatório com o usuário solicitante. O sistema também deve possuir atributos na playlist para o log de auditoria, armazenando o texto exato do prompt e os parâmetros da IA em formato textual ou JSON.
Por fim, o banco deve registrar quais músicas foram alocadas em quais playlists, armazenando a posição sequencial (ordem de execução) de cada faixa na playlist."""

    try:
        # =========================================================================
        # ENTREGÁVEL 1: MODELO CONCEITUAL
        # =========================================================================
        print("\n⏳ [1/4] Gerando Modelo Conceitual a partir da História...")
        contexto_acumulado = f"[REQUISITOS DE NEGÓCIO]\n{historia_pura}\n"

        prompt_diagrama = f"""Aja como um Arquiteto de Banco de Dados Sênior. Leia o contexto abaixo:

{contexto_acumulado}

[TAREFA 1 - MODELO CONCEITUAL]
Gere um documento Markdown (.md) contendo o Modelo Conceitual Lógico.
Liste detalhadamente:
1. As Entidades (Principais e Associativas).
2. Os Atributos de cada entidade, especificando PKs e atributos que ficam em relacionamentos N:N (ex: papel, posição).
3. Os Relacionamentos entre as entidades e suas Cardinalidades (identifique as resoluções de N:N e o auto-relacionamento de gêneros).
Entregue APENAS o documento Markdown final."""

        resultado_diagrama = chamar_ollama(modelo, prompt_diagrama)
        with open(f"saidas_llm/01_diagrama_conceitual_llm_{timestamp}.md", "w", encoding="utf-8") as f:
            f.write(resultado_diagrama)
        print("✅ Entregável 1 salvo!")

        # =========================================================================
        # ENTREGÁVEL 2: ÁLGEBRA RELACIONAL E CÁLCULO
        # =========================================================================
        print("\n⏳ [2/4] Gerando Álgebra e Cálculo Relacional...")
        contexto_acumulado += f"\n[1. MODELO CONCEITUAL GERADO (Base da Arquitetura)]\n{resultado_diagrama}\n"

        prompt_calculos = f"""Aja como um Especialista em Teoria de Banco de Dados. Leia o histórico do projeto:

{contexto_acumulado}

[TAREFA 2 - TEORIA MATEMÁTICA]
Gere um documento Markdown (.md) contendo:
1. A Álgebra Relacional para a consulta: "Nomes das músicas na playlist de ID X".
2. O Cálculo Relacional de Tuplas (CRT) para a mesma consulta.
3. Comando 'pg_dump' para backup lógico do banco.
4. Comando 'EXPLAIN ANALYZE' para consultar músicas pelo nome.
Utilize notação matemática LaTeX ($$). Entregue APENAS o documento Markdown."""

        resultado_calculos = chamar_ollama(modelo, prompt_calculos)
        with open(f"saidas_llm/02_algebra_e_calculo_llm_{timestamp}.md", "w", encoding="utf-8") as f:
            f.write(resultado_calculos)
        print("✅ Entregável 2 salvo!")

        # =========================================================================
        # ENTREGÁVEL 3: ESTRUTURA (DDL + SQL 3)
        # =========================================================================
        print("\n⏳ [3/4] Gerando Script DDL (PostgreSQL)...")
        contexto_acumulado += f"\n[2. TEORIA MATEMÁTICA GERADA]\n{resultado_calculos}\n"

        prompt_ddl = f"""Aja como um DBA PostgreSQL Sênior. Leia todo o escopo definido:

{contexto_acumulado}

[TAREFA 3 - SCRIPT DDL E RECURSOS AVANÇADOS]
Gere EXCLUSIVAMENTE o script SQL DDL (3ª Forma Normal) contendo:
1. CREATE EXTENSION IF NOT EXISTS pgcrypto.
2. CREATE TABLE para as entidades. Garanta as tabelas associativas para: Músicas-Artistas (com atributo papel), Músicas-Gêneros, Artistas-Gêneros e Hierarquia Recursiva de Gêneros.
3. Restrições CHECK para metadados (0.0 a 1.0) e ON DELETE CASCADE nas FKs.
4. ALTER TABLE na Playlist adicionando 'data_ultima_modificacao'.
5. CREATE VIEW 'vw_relatorio_curadoria' cruzando usuários, playlists e músicas.
6. CREATE FUNCTION e CREATE TRIGGER para atualizar 'data_ultima_modificacao' no UPDATE da playlist.
7. CREATE INDEX B-Tree para nome de artista e música.
Entregue APENAS o script SQL puro."""

        resultado_ddl = chamar_ollama(modelo, prompt_ddl)
        with open(f"saidas_llm/03_ddl_llm_{timestamp}.sql", "w", encoding="utf-8") as f:
            f.write(resultado_ddl)
        print("✅ Entregável 3 salvo!")

        # =========================================================================
        # ENTREGÁVEL 4: DADOS (DML + TRANSAÇÕES)
        # =========================================================================
        print("\n⏳ [4/4] Gerando Script DML (Inserts e Transações)...")
        contexto_acumulado += f"\n[3. ESTRUTURA DDL GERADA]\n{resultado_ddl}\n"

        prompt_dml = f"""Aja como um Engenheiro de Dados. Este é o projeto atual:

{contexto_acumulado}

[TAREFA 4 - SCRIPT DML E TRANSAÇÕES]
Gere EXCLUSIVAMENTE o script SQL DML validando as regras complexas:
1. INSERT INTO de 1 usuário curador.
2. INSERT INTO de 3 gêneros formando uma hierarquia (Ex: Metal -> Black Metal -> Blackgaze).
3. INSERT INTO de 2 artistas, 1 álbum e 2 músicas. Aloque um dos artistas como 'Feature' na música usando a tabela associativa correta.
4. INSERT INTO criando 1 Playlist transacional (BEGIN, SAVEPOINT, INSERT, COMMIT) com as 2 músicas.
Entregue APENAS o script SQL limpo."""

        resultado_dml = chamar_ollama(modelo, prompt_dml)
        with open(f"saidas_llm/04_dml_llm_{timestamp}.sql", "w", encoding="utf-8") as f:
            f.write(resultado_dml)
        print("✅ Entregável 4 salvo!")

        print(f"\n🎉 Pipeline 100% concluído! Arquivos na pasta 'saidas_llm/'.")

    except requests.exceptions.RequestException as e:
        print(f"❌ Erro de ligação com o Ollama: {e}")

if __name__ == "__main__":
    executar_pipeline_etapas()