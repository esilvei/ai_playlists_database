# Modelagem Matemática: Álgebra e Cálculo Relacional

Este documento formaliza as consultas principais do Sistema de Curadoria Algorítmica, atendendo aos requisitos práticos da disciplina de Banco de Dados.

**Consulta de Negócio em Linguagem Natural:** > "Quais são os nomes das músicas presentes na playlist de identificador 'X'?"

---

## 1. Álgebra Relacional

A expressão abaixo utiliza os operadores teóricos de Seleção ($\sigma$), Junção ($\bowtie$) e Projeção ($\pi$) para isolar os itens da playlist desejada e resgatar os nomes na tabela de músicas.

$$\pi_{nome} ( \sigma_{playlist\_id = 'X'} (itens\_playlist) \bowtie_{itens\_playlist.musica\_id = musicas.id\_musica} musicas )$$

**Passo a passo da Execução Algébrica:**
1. **$\sigma_{playlist\_id = 'X'} (itens\_playlist)$**: Filtra a tabela associativa `itens_playlist`, mantendo apenas as tuplas (linhas) correspondentes à playlist solicitada ('X').
2. **$\bowtie_{...} musicas$**: Realiza a junção do resultado anterior com a entidade `musicas`, cruzando a chave estrangeira da tabela associativa com a chave primária da música.
3. **$\pi_{nome}$**: Projeta (filtra verticalmente) apenas a coluna contendo o `nome` da música, descartando os metadados acústicos (energia, bpm, valência, etc.).

---

## 2. Cálculo Relacional de Tuplas (CRT)

O Cálculo Relacional descreve "o que" queremos encontrar usando a lógica de predicados de primeira ordem, atuando de forma declarativa (teoria que fundamenta a linguagem SQL).

$$\{ t.nome \mid musicas(t) \land \exists i (itens\_playlist(i) \land i.musica\_id = t.id\_musica \land i.playlist\_id = 'X') \}$$

**Leitura Lógica (Interpretação do Predicado):**
"Recupere o atributo *nome* da tupla *t*, tal que *t* pertence à relação *musicas*, **E** existe uma tupla *i* que pertence à relação *itens_playlist*, de modo que a chave estrangeira da música em *i* seja igual à chave primária em *t*, **E** o identificador da playlist em *i* seja estritamente igual a 'X'."