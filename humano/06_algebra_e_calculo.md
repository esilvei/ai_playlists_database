# Modelagem Matemática: Álgebra e Cálculo Relacional

Este documento formaliza as consultas do Sistema de Curadoria Algorítmica, traduzindo o código SQL para a fundamentação teórica do **Modelo Relacional Clássico de E.F. Codd**.

---

## Consulta 1: Junção e Filtro (SPJ Clássico)

### Consulta Original em SQL

```sql
SELECT m.nome AS nome_musica, a.nome_completo AS nome_artista, ma.papel
FROM musicas m
JOIN musicas_artistas ma ON m.id_musica = ma.musica_id
JOIN artistas a ON ma.artista_id = a.id_spotify
WHERE m.energia > 0.995;
```

### Análise Teórica

Esta consulta utiliza apenas operações de Seleção (`WHERE`), Projeção (`SELECT`) e Junção (`JOIN`). Encaixa-se perfeitamente nas operações de conjuntos da **Álgebra Relacional Clássica (SPJ)**.

---

### 1.1. Álgebra Relacional Clássica

Realiza-se a seleção ($\sigma$) pela energia altíssima e a junção Theta ($\bowtie$) das três relações. No final, projeta-se ($\pi$) os campos desejados.

$$
\pi_{m.nome, \ a.nome\_completo, \ ma.papel} \Big( \sigma_{m.energia > 0.995} \big( Musicas \ m \bowtie_{m.id\_musica = ma.musica\_id} Musicas\_Artistas \ ma \bowtie_{ma.artista\_id = a.id\_spotify} Artistas \ a \big) \Big)
$$

---

### 1.2. Cálculo Relacional de Tuplas (CRT)

$$
\{ t \mid \exists m \in Musicas, \exists ma \in Musicas\_Artistas, \exists a \in Artistas
$$

$$
( m.id\_musica = ma.musica\_id \ \land \ ma.artista\_id = a.id\_spotify \ \land \ m.energia > 0.995
$$

$$
\land \ t.nome\_musica = m.nome \ \land \ t.nome\_artista = a.nome\_completo \ \land \ t.papel = ma.papel ) \}
$$

---

## Consulta 2: Limitação Teórica de Agregações

### Consulta Original em SQL

Utilizava as funções `COUNT(i.musica_id)`, `AVG(m.energia)`, `GROUP BY` e `HAVING COUNT >= 10`.

### Análise Teórica e Simplificação

A **Álgebra Relacional Clássica** não suporta funções de agregação, médias, agrupamentos ou ordenação, uma vez que a Teoria dos Conjuntos não possui ordem ou funções matemáticas internas. Para manter o rigor teórico, a consulta foi simplificada para responder:

> "Quais curadores criaram playlists que contêm pelo menos uma música de energia elevada (> 0.8)?"

O uso do `DISTINCT` emula a propriedade da **Projeção Relacional**, que elimina duplicatas inerentemente.

### Consulta SQL Equivalente Suportada

```sql
SELECT DISTINCT u.nome AS curador, p.log_texto_pedido AS prompt_da_ia
FROM usuarios u
JOIN playlists p ON u.id_usuario = p.usuario_id
JOIN itens_playlist i ON p.id_playlist = i.playlist_id
JOIN musicas m ON i.musica_id = m.id_musica
WHERE m.energia > 0.8;
```

---

### 2.1. Álgebra Relacional Clássica

$$
\pi_{u.nome, \ p.log\_texto\_pedido} \Big( \sigma_{m.energia > 0.8} \big( Usuarios \ u \bowtie Playlists \ p \bowtie Itens\_Playlist \ i \bowtie Musicas \ m \big) \Big)
$$

---

### 2.2. Cálculo Relacional de Tuplas (CRT)

$$
\{ t \mid \exists u \in Usuarios, \exists p \in Playlists, \exists i \in Itens\_Playlist, \exists m \in Musicas
$$

$$
(u.id\_usuario = p.usuario\_id \ \land \ p.id\_playlist = i.playlist\_id \ \land \ i.musica\_id = m.id\_musica
$$

$$
\land \ m.energia > 0.8 \ \land \ t.curador = u.nome \ \land \ t.prompt\_da\_ia = p.log\_texto\_pedido) \}
$$

---

## Consulta 3: Limitação de Funções de Janela (Window Functions)

### Consulta Original em SQL

Utilizava `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)`.

### Análise Teórica e Simplificação

O modelo clássico de E.F. Codd opera sobre multiconjuntos sem suporte a particionamentos sequenciais (*Window Functions*) ou ranqueamento. Para representar uma consulta avançada utilizando apenas as 6 operações originais, aplicámos a **Diferença de Conjuntos** (`EXCEPT`). A nova lógica responde:

> "Quais são as músicas altamente dançáveis (dançabilidade > 0.7) que **NUNCA** foram adicionadas a nenhuma playlist?"

### Consulta SQL Equivalente Suportada

```sql
SELECT nome AS nome_musica, dancabilidade
FROM musicas
WHERE dancabilidade > 0.7

EXCEPT

SELECT m.nome AS nome_musica, m.dancabilidade
FROM musicas m
JOIN itens_playlist i ON m.id_musica = i.musica_id;
```

---

### 3.1. Álgebra Relacional Clássica

O conjunto $A$ (Músicas muito dançáveis) subtraído ($-$) do conjunto $B$ (Músicas já inseridas em itens de playlist).

$$
\pi_{m.nome, \ m.dancabilidade} \Big( \sigma_{dancabilidade > 0.7} (Musicas) \Big)
\ - \
\pi_{m.nome, \ m.dancabilidade} \big( Musicas \ m \bowtie_{m.id\_musica = i.musica\_id} Itens\_Playlist \ i \big)
$$

---

### 3.2. Cálculo Relacional de Tuplas (CRT)

A diferença é expressa pela negação lógica ($\neg$) da existência de vínculos com as playlists.

$$
\{ t \mid \exists m \in Musicas \ (m.dancabilidade > 0.7 \\
\land \ \neg \exists i \in Itens\_Playlist \ (i.musica\_id = m.id\_musica) \\
\land \ t.nome\_musica = m.nome \ \land \ t.dancabilidade = m.dancabilidade) \}
$$