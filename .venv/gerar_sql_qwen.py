import requests
import datetime
import os


def executar_pipeline_ollama():
    url = "http://localhost:11434/api/generate"

    modelo = "qwen3:30b"

    mega_prompt = """Aja como um Arquiteto de Banco de Dados Sênior. Sua tarefa é ler os Requisitos de Negócio e o mapeamento do Diagrama Entidade-Relacionamento (ER) abaixo para projetar o Esquema Físico (DDL) e os Dados Iniciais (DML) em PostgreSQL. Siga as regras técnicas estritas e faça adaptações estruturais apenas se for vital para a integridade do banco.

[REQUISITOS DE NEGÓCIO]
Uma startup de tecnologia musical deseja desenvolver um sistema interno para gerenciar, auditar e rastrear a criação de playlists personalizadas geradas por Inteligência Artificial. Atualmente, os curadores da empresa utilizam ferramentas soltas para buscar músicas, analisar suas características sonoras e agrupá-las, o que gera inconsistências. Para resolver isso, a empresa decidiu construir um banco de dados relacional robusto que atuará como o núcleo de todo o catálogo musical e do histórico de curadoria, permitindo uma integração fluida com a API do Spotify e garantindo total rastreabilidade.
Para manter a consistência do acervo, o banco de dados deve registrar informações detalhadas sobre os Artistas. Cada artista deve possuir um código de identificação único (proveniente do Spotify) para evitar duplicidade de nomes homônimos, além de armazenar seu nome completo e um índice de popularidade atualizado. Sabendo que a categorização musical é complexa, o sistema precisa catalogar os diversos Gêneros musicais existentes. Como um artista pode transitar por estilos muito diferentes ao longo da carreira, o sistema deve permitir que um mesmo artista seja classificado em vários gêneros, assim como um gênero pode englobar múltiplos artistas.
Os artistas são os responsáveis por lançar os Álbuns. O sistema deve registrar o código único de cada álbum, o título da obra, a data de lançamento oficial e o tipo de lançamento (se é um 'single', um 'EP' ou um álbum completo). Para garantir a integridade da informação, um álbum deve obrigatoriamente pertencer a um artista específico, não podendo existir álbuns 'órfãos' no banco de dados.
Dentro de cada álbum, o banco catalogará as Músicas (ou faixas). Esta é a entidade mais crítica do sistema. Além do código de identificação único de cada música, nome e duração em milissegundos, o banco de dados precisa armazenar os metadados acústicos (audio features) fornecidos pela API. Estes dados incluem índices numéricos detalhados para a energia da música, a valência (que mede a positividade ou obscuridade da faixa), a dançabilidade e o tempo (em BPM). A precisão dessas informações é fundamental, pois será a base matemática que a Inteligência Artificial utilizará para cruzar dados e selecionar as faixas adequadas no futuro. Cada música está vinculada a um único álbum.
A operação do sistema será feita por Usuários internos da empresa (os curadores). O banco deve armazenar o identificador do usuário, seu nome, e-mail institucional e a data de cadastro. Esses usuários farão requisições textuais (prompts) para a IA solicitando compilações específicas, como por exemplo: 'Criar uma lista de faixas de metal com BPM alto e baixa valência'.
Para manter a auditoria rígida exigida pela diretoria, toda vez que a IA processar um pedido, o sistema deve registrar a Playlist gerada. O registro desta playlist deve conter um código de identificação próprio, o link de integração para a plataforma de streaming, a data e hora exata da criação, e, mais importante, deve estar obrigatoriamente vinculada ao usuário que fez a solicitação. Além disso, o sistema deve possuir um Log de Auditoria (Prompts), que armazene o texto exato digitado pelo usuário e os parâmetros médios que a IA tentou atingir (ex: energia alvo), para fins de rastreabilidade.
Por fim, é imprescindível saber exatamente quais faixas compõem cada curadoria. Para isso, o banco de dados deve rastrear detalhadamente os Itens da Playlist. O sistema deve registrar quais músicas foram alocadas em quais playlists, permitindo que uma mesma música seja utilizada em diversas compilações diferentes ao longo do tempo. Para garantir a experiência de reprodução, este registro de alocação também deve armazenar a posição sequencial (ordem de execução) de cada música dentro de uma playlist específica. Com todas essas informações cruzadas, o chefe de curadoria poderá emitir relatórios mensais que demonstrem quais gêneros são mais requisitados, a média de energia das playlists criadas por cada usuário e quais artistas dominam as curadorias geradas pela inteligência artificial.

[MAPEAMENTO DO DIAGRAMA ER]
O banco deve seguir ESTRITAMENTE as entidades, atributos e relacionamentos definidos no diagrama oficial:
- Usuário: Atributos id_usuario (PK), nome, email_institucional, data_cadastro.
- Artista: Atributos id_spotify (PK), nome_completo, indice_popularidade.
- Gênero: Atributos id_genero (PK), nome.
- Álbum: Atributos id_album (PK), titulo, data_lancamento, tipo_lancamento. Relaciona-se com Artista (um artista Lança vários álbuns).
- Música: Atributos id_musica (PK), nome, duracao_ms, energia, valencia, dancabilidade, bpm. Relaciona-se com Álbum (um álbum Possui várias músicas).
- Playlist: Atributos id_playlist (PK), log_texto_pedido, log_parametros_ia, link_streaming, data_hora_criacao. Relaciona-se com Usuário (um usuário Solicita várias playlists).
- Pertence (Tabela Associativa Artista_Genero): Relação N:N entre Artista e Gênero.
- Contém (Tabela Associativa Playlist_Musica): Relação N:N entre Playlist e Música. OBRIGATÓRIO conter o atributo posicao para definir a ordem sequencial da faixa.

[REGRAS TÉCNICAS OBRIGATÓRIAS]
- Normalize o banco na Terceira Forma Normal (3NF).
- Habilite a extensão 'pgcrypto' e use UUID como chave primária autogerada para Usuário e Playlist.
- Use VARCHAR para os identificadores originais do Spotify (id_spotify, id_album, id_musica).
- As métricas acústicas (energia, valencia, dancabilidade) devem ser FLOAT/REAL com restrições (CHECK) entre 0.0 e 1.0.
- Aplique ON DELETE CASCADE nas chaves estrangeiras.

[CARGA DE DADOS - DML]
Gere scripts de INSERT INTO populando as tabelas com:
- 1 usuário curador.
- 3 gêneros diversificados (Metal, Samba e Música Clássica).
- 2 artistas relevantes pertencentes a esses gêneros (deixando 1 gênero propositalmente sem artista).
- 2 álbuns e 4 músicas.
- Crie 1 registro em Playlist simulando um pedido textual de "alta energia" e mapeie 2 músicas para ela na tabela Contém, preenchendo a posicao.

Entregue apenas o código SQL limpo e formatado."""

    payload = {
        "model": modelo,
        "prompt": mega_prompt,
        "stream": False
    }

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()

        resultado_sql = response.json().get("response", "")


        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        nome_arquivo = f"saida_{modelo.replace(':', '_')}_{timestamp}.txt"

        with open(nome_arquivo, "w", encoding="utf-8") as arquivo:
            arquivo.write("/* =========================================================\n")
            arquivo.write(f"   LOG DE AUDITORIA   \n")
            arquivo.write(f"   Data/Hora: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            arquivo.write(f"   Modelo Utilizado: {modelo}\n")
            arquivo.write("   =========================================================\n")
            arquivo.write("   PROMPT ENVIADO:\n")
            arquivo.write(f"   {mega_prompt}\n")
            arquivo.write("   ========================================================= */\n\n")

            arquivo.write(resultado_sql)

        print(f"✅ Sucesso! Artefato salvo com sucesso em: {nome_arquivo}")

    except requests.exceptions.RequestException as e:
        print(f"❌ Erro ao conectar com o Ollama: {e}")
        print("Certifique-se de que o Ollama está rodando no terminal.")


if __name__ == "__main__":
    executar_pipeline_ollama()