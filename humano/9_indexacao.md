# Relatório de Análise de Performance: Auditoria de Índices

Este documento consolida os resultados da auditoria de performance, comparando o comportamento do otimizador do PostgreSQL antes e depois da implementação da estratégia de indexação.

## 1. Query de Performance 01: Filtro de Energia (Curadoria)

* **Objetivo:** Identificar músicas de altíssima energia (energia > 0.995) e seus artistas.
* **Cenário SEM Índices:** 25.385 ms (Parallel Seq Scan).
* **Cenário COM Índices:** 2.782 ms (Bitmap Index Scan via `idx_musicas_energia_valencia`).

---

## 2. Query de Performance 02: Navegação por Playlist (Histórico)

* **Objetivo:** Listar músicas de playlists filtrando pelo usuário e calculando médias.
* **Cenário Base (Sem Índices):** 601.845 ms.
* **Cenário Ajustado (Com Índices):** 543.392 ms.
* **Melhoria Observada:** Redução de ~10% no tempo total.
* **Análise do Otimizador:** O PostgreSQL optou por *Sequential Scans* devido à baixa seletividade: o custo de acesso aleatório via índice supera o acesso sequencial em agregações globais. O uso de *External Merge* persiste, refletindo o custo computacional esperado para o volume atual de dados.

---

## 3. Query de Performance 03: Ranqueamento de Dançabilidade (IA)

* **Objetivo:** Ranquear as 3 músicas mais dançantes de cada playlist.
* **Cenário SEM Índices:** 233.286 ms.
* **Cenário COM Índices (Resultados Atuais):** 233.254 ms.
* **Análise do Plano de Execução:**
    * O plano (*Incremental Sort* seguido de *WindowAgg*) ainda apresenta gargalos de I/O, especificamente `temp read=2428` e `written=2434`.
    * A operação de ordenação continua utilizando *External Merge* (Disk: 19424kB).
    * **Diagnóstico:** A implementação dos índices básicos não foi suficiente para eliminar o *spill* para disco, pois a operação de *Window Function* com partição e ordenação ainda exige memória superior à disponível (ou configurada para a sessão) para processar o conjunto completo em memória.

---

## 4. Justificativa pela Manutenção da Estrutura

Optou-se por não realizar ajustes agressivos (como `work_mem`) ou *covering indexes* complexos, baseando-se em:

* **Integridade do Ambiente:** Priorizou-se observar o comportamento orgânico da aplicação para não mascarar o desempenho real em produção.
* **Preservação da Lógica de Negócio:** Evitar desvios artificiais na modelagem garante que a escalabilidade seja genuína e não apenas uma otimização de cenário de teste.
* **Padrão de Acesso:** A natureza da agregação global das queries 2 e 3 justifica o custo computacional atual. O ganho marginal obtido valida a estratégia de indexação como eficaz sem corromper a estrutura relacional.

---

## 5. Conclusão Técnica

Os resultados confirmam que as queries de agregação apresentam comportamento estável, porém limitado pelo I/O de disco em operações de ordenação (*External Merge*).

* **Impacto de I/O:** A implementação reduziu leituras desnecessárias em operações onde a seletividade permite o uso de índices, mas não eliminou a necessidade de *spill* para disco em consultas complexas de ordenação.
