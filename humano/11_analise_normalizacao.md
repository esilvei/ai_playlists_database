# Análise de Normalização do Esquema de Banco de Dados

Esta auditoria verifica se a estrutura atende aos requisitos teóricos de integridade e minimização de redundância.

---

## 1. Primeira Forma Normal (1NF)
* **Critério:** Atributos atômicos, sem grupos repetitivos e com identificadores únicos (PKs).
* **Avaliação:** **Conforme.**
    * Todas as tabelas possuem Chaves Primárias (`PRIMARY KEY`) definidas.
    * Os valores são atômicos. Note que a tabela `itens_playlist` utiliza uma PK composta (`playlist_id`, `posicao`) para garantir a unicidade de cada slot na playlist, permitindo repetições de músicas de forma normalizada.

## 2. Segunda Forma Normal (2NF)
* **Critério:** Estar na 1NF e não conter dependências parciais (atributos não chave dependendo apenas de parte de uma PK composta).
* **Avaliação:** **Conforme.**
    * Em todas as tabelas com chaves compostas (`generos_hierarquia`, `artistas_generos`, `musicas_artistas`, `musicas_generos`, `playlists_colaboradores` e `itens_playlist`), os atributos não-chave dependem da totalidade da chave composta.
    * **Exemplo:** O papel na tabela `musicas_artistas` depende da combinação (`musica` + `artista` + `papel`), garantindo que não haja dependência parcial.

## 3. Terceira Forma Normal (3NF)
* **Critério:** Estar na 2NF e não conter dependências transitivas (atributos não-chave dependendo de outros atributos não-chave).
* **Avaliação:** **Conforme.**
    * O modelo elimina dependências transitivas ao separar entidades em tabelas distintas.
    * **Exemplo de sucesso:** A relação entre Músicas e Álbuns. Em vez de duplicar metadados do artista dentro de cada música, a música aponta para o álbum, e o álbum aponta para o artista. Isso evita que, se o nome de um artista mudar, você precise atualizar milhares de músicas.
    * **Exemplo de sucesso:** O uso da tabela `generos_hierarquia` (recursiva) evita que o grafo de conhecimento seja armazenado dentro da tabela de gêneros, mantendo a estrutura limpa e sem redundância.

## 4. Observações Técnicas Importantes

* **Tabelas Associativas:** O uso extensivo de tabelas associativas (com chaves estrangeiras (`REFERENCES`) e `ON DELETE CASCADE`) é a forma correta de implementar relacionamentos N:M, mantendo o banco normalizado e protegendo a integridade referencial.
* **CHECK Constraints:** A inclusão de `CHECK` (`energia >= 0.0 AND energia <= 1.0`) na tabela `musicas` adiciona uma camada de "Regra de Negócio de Domínio" que garante que, mesmo estando normalizado, o dado seja semanticamente válido para a sua IA.
* **Integridade Referencial:** O uso de `ON DELETE CASCADE` em todas as FKs garante que, se uma entidade pai (ex: Usuário) for excluída, toda a árvore de dados relacionada seja limpa, evitando registros órfãos (o que também mantém a sanidade da normalização).

---

## Conclusão
O modelo está **100% normalizado em 3NF**. Ele não apresenta anomalias de inserção, exclusão ou atualização. A estrutura é altamente resiliente e preparada para escala, refletindo um design de banco de dados profissional.