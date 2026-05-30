# Balancear Operacoes em Duas Fases

## Objetivo

- Ajustar as operacoes matematicas dos inimigos considerando que o jogo tera apenas `Tropic` e `Ice`.
- Garantir progressao de dificuldade usando `mult`, `div`, `sqrt`, `pow` e `fact`.
- Manter a quantidade atual de inimigos: 10 em `scene/tropic.tscn` e 10 em `scene/ice.tscn`.

## Progressao definida

### Tropic

- Comeca com revisao facil de multiplicacao.
- Passa por divisao no meio da subida.
- Introduz raiz e potencia nos encontros finais.

Distribuicao:

- `Skeleton`, `Skeleton2`, `Skeleton3`: `mult`
- `Skeleton4`, `Skeleton5`, `Skeleton6`: `div`
- `Skeleton7`, `Skeleton8`: `sqrt`
- `Skeleton9`, `Skeleton10`: `pow`

### Ice

- Comeca com uma revisao de divisao.
- Reforca raiz no inicio.
- Aumenta dificuldade com potencia.
- Fecha a fase com fatorial.

Distribuicao:

- `Skeleton`: `div`
- `Skeleton2`, `Skeleton3`: `sqrt`
- `Skeleton4`, `Skeleton5`, `Skeleton6`: `pow`
- `Skeleton7`, `Skeleton8`, `Skeleton9`, `Skeleton10`: `fact`

## Tarefas

- [x] Ler operacoes suportadas em `scripts/math_system.gd`.
- [x] Atualizar `scene/tropic.tscn`.
- [x] Atualizar `scene/ice.tscn`.
- [x] Manter a quantidade de inimigos das duas cenas.
- [ ] Validar no Godot se todos os inimigos geram perguntas corretamente.
- [ ] Jogar as duas fases para confirmar que a curva de dificuldade esta adequada.
