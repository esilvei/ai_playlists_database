# Modelagem Matemática: Álgebra e Cálculo Relacional

Este documento formaliza as consultas principais do Sistema de Curadoria Algorítmica, atendendo aos requisitos práticos da disciplina de Banco de Dados.

**Consulta de Negócio em Linguagem Natural:** > "Quais são os nomes das músicas presentes na playlist de identificador 'X'?"

---

## 1. Álgebra Relacional

**Objetivo da busca (Álgebra Relacional)**
Recuperar o nome da música, o nome completo do artista e o papel que ele exerce na faixa, filtrando de baixo para cima apenas as músicas que possuem um nível de energia superior a 0.9. A operação realiza a junção (Join) entre as entidades Musica, Artista e a tabela associativa Musicas_Artistas.

**Álgebra**
$$\pi_{nome, nome\_completo, papel} ( \sigma_{energia > 0.9} ( Musicas \bowtie_{id\_musica = musica\_id} Musicas\_Artistas \bowtie_{artista\_id = id\_spotify} Artistas ) )$$

---

## 2. Cálculo Relacional de Tuplas (CRT)

**Objetivo da busca (Cálculo Relacional de Tuplas)**
Declarar formalmente um conjunto de tuplas de retorno $t$ contendo nome, artista e papel, garantindo que existam ($\exists$) tuplas correspondentes nas três relações (Músicas, Musicas_Artistas e Artistas) onde as chaves primárias e estrangeiras sejam equivalentes, e que a condição limitante de energia > 0.9 seja satisfeita.

**Cálculo em LaTeX**
$$\{ t \mid \exists m \in Musicas, \exists ma \in Musicas\_Artistas, \exists a \in Artistas$$
$$( m.id\_musica = ma.musica\_id \land ma.artista\_id = a.id\_spotify$$
$$\land \ m.energia > 0.9$$
$$\land \ t.nome\_musica = m.nome \land t.nome\_artista = a.nome\_completo \land t.papel = ma.papel ) \}$$