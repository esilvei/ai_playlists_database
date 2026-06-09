# Relational Algebra and Database Query Documentation

## 1. Álgebra Relacional

$$
\pi_{\text{title}} \left( \sigma_{\text{playlist\_id} = X}(\text{Playlist}) \bowtie \text{PlaylistItem} \bowtie \text{Music} \right)
$$

*Explicação:*  
A consulta seleciona o título das músicas (`title`) após aplicar uma seleção (`σ`) na tabela `Playlist` para o identificador `X`, seguida de junções (`bowtie`) com `PlaylistItem` e `Music` para relacionar as playlists com suas respectivas músicas.

---

## 2. Cálculo Relacional de Tuplas (CRT)

$$
\{ t.\text{title} \mid \text{Music}(t) \land \exists i \, (\text{PlaylistItem}(i) \land i.\text{playlist\_id} = X \land i.\text{music\_id} = t.\text{music\_id}) \}
$$

*Explicação:*  
Esta expressão retorna os títulos (`title`) de músicas (`Music(t)`) cujas entradas em `PlaylistItem` (`i`) correspondem ao identificador `X` da playlist e vinculam a música via `music_id`.

---

## 3. Comando `pg_dump` para Backup Lógico

bash
pg_dump -U postgres -h localhost -d music_db -f music_db_backup_$(date +\%Y\%m\%d).sql


*Explicação:*  
Este comando realiza um backup lógico completo do banco `music_db`, salvando-o em um arquivo SQL com data de criação no formato `YYYYMMDD`.

---

## 4. Comando `EXPLAIN ANALYZE` para Consulta por Nome de Música


EXPLAIN ANALYZE SELECT title FROM Music WHERE title = 'Example Song';


*Explicação:*  
O comando executa uma análise detalhada da consulta que busca o título de uma música específica (`'Example Song'`), exibindo o plano de execução e métricas de performance do PostgreSQL.