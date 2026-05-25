# Finalizar Cena Tropic

## Estado atual observado

- Cena principal atual: `scene/tropic.tscn`.
- Viewport do projeto: 400 x 208 px.
- TileMap atual: aproximadamente 1168 px de largura por 416 px de altura.
- Camera atual: `limit_right = 1148`.
- A cena atual esta larga demais para uma fase vertical.
- Existem 2 inimigos `Skeleton`:
  - `Skeleton`: `operation_type = "fact"`.
  - `Skeleton2`: `operation_type = "pow"`.
- A cena atual usa poucos encontros e ainda parece mais um trecho curto de teste do que a segunda fase completa.
- O parallax deve permanecer sem alteracao por enquanto.

## Respostas de design

Comprimento recomendado:

- Usar comprimento vertical de 1000 a 1250 px.
- Isso equivale a cerca de 5 a 6 telas de altura, considerando viewport de 208 px.
- Para a segunda cena, o alvo pratico e 1100 px de subida jogavel.

Largura recomendada:

- Reduzir para 480 a 640 px de largura jogavel.
- Alvo recomendado: 560 px.
- A largura atual, perto de 1168 px, esta mais adequada para side-scroller do que para plataforma vertical.

Operacoes recomendadas:

- Tropic deve ser a cena de divisao.
- Usar `div` como operacao principal.
- Manter `mult` como revisao.
- Para 6 inimigos: 2 com `mult` e 4 com `div`.
- Evitar `fact` e `sqrt` nesta cena.
- Evitar `pow` no caminho principal, a menos que seja uma plataforma opcional de desafio.

Quantidade recomendada de plataformas:

- Total: 26 a 30 grupos de plataforma.
- Alvo recomendado: 28 grupos.
- Distribuicao sugerida:
  - 1 plataforma inicial.
  - 18 plataformas de travessia.
  - 5 plataformas de combate.
  - 3 plataformas de respiro, escolha ou recuperacao.
  - 1 plataforma final/saida.

Quantidade recomendada de inimigos:

- Total: 5 a 7 inimigos.
- Alvo recomendado: 6 `Skeleton`.
- Distribuicao:
  - 1 inimigo introdutor na parte baixa.
  - 2 inimigos no miolo da subida.
  - 2 inimigos na parte alta.
  - 1 inimigo guardando a saida ou a plataforma final.

Variacao de plataformas:

- Misturar plataformas de 2, 3, 4, 5, 7 e 10 tiles.
- Usar plataformas pequenas apenas para travessia.
- Usar plataformas largas para combate.
- Alternar caminho em zigue-zague, pares deslocados, pequenos degraus, plataforma de descanso e arenas curtas.
- Evitar que a subida vire uma escada repetida.

Espacamento recomendado:

- Gap vertical comum: 48 a 64 px.
- Gap vertical de desafio: ate 72 px.
- Gap horizontal comum: 48 a 112 px.
- Evitar quedas livres acima de 220 px sem plataforma de recuperacao, por causa do dano de queda.

## Tarefas

- [x] Definir os limites finais da cena com largura alvo de 560 px.
- [x] Reduzir o chao horizontal longo e manter apenas areas necessarias para inicio, combate e saida.
- [x] Atualizar limites fisicos laterais depois que o novo layout for definido.
- [x] Atualizar limites da camera depois que a largura e altura finais forem definidas.
- [x] Expandir a cena verticalmente ate cerca de 1100 px de subida jogavel.
- [x] Criar 28 grupos de plataforma com variacao de largura, altura e formato.
- [x] Criar 5 plataformas de combate com largura suficiente para patrulha do `Skeleton`.
- [x] Criar 3 plataformas de respiro para reduzir punicao entre encontros.
- [x] Evitar alteracoes no parallax.
- [x] Reposicionar o player no inicio da rota vertical.
- [x] Reposicionar a placa/tutorial sem bloquear o fluxo de subida.
- [x] Reposicionar os inimigos atuais em plataformas adequadas.
- [x] Adicionar inimigos ate chegar em 6 encontros totais.
- [x] Trocar operacoes dos inimigos da rota principal para 2 `mult` e 4 `div`.
- [x] Remover `fact` e `pow` da rota principal desta cena.
- [x] Criar uma plataforma final clara para transicao futura para a terceira cena.
- [ ] Validar todos os saltos com movimento normal e pulo duplo.
- [ ] Validar que nenhum inimigo cai da plataforma durante patrulha.
- [ ] Validar que todos os inimigos abrem modal matematico corretamente.
- [ ] Validar que a camera nao mostra area vazia lateral demais.
- [ ] Validar que a cena ainda recarrega corretamente quando o player morre.

## Definicao de pronto

- A cena Tropic funciona como segunda fase completa.
- A rota principal e vertical, com largura controlada.
- O jogador sobe por cerca de 5 a 6 telas.
- Existem 26 a 30 plataformas visualmente variadas.
- Existem 5 a 7 inimigos, idealmente 6.
- A matematica da cena foca em divisao e revisa multiplicacao.
- O parallax permanece inalterado.
- A cena pode ser jogada do inicio ate a saida sem atalhos do editor.
