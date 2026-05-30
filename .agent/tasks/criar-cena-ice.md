# Criar Cena Ice

## Objetivo

- Criar `scene/ice.tscn` como fase vertical baseada em `scene/tropic.tscn`.
- Reutilizar a estrutura jogavel ja existente: player, camera, limites laterais, inimigos, placa e guia de controles.
- Trocar o visual da fase para Winter World usando `terrain-ice`, `entities-ice` e background parts de inverno.

## Decisoes de implementacao

- Manter o layout vertical da Tropic para evitar mexer em varios sistemas ao mesmo tempo.
- Converter o `Terrain` para o source `terrain-ice` do `tiles/terrain.tres`.
- Recriar a camada `Decoration` com o source `entities-ice` do `tiles/decoration.tres`.
- Trocar o parallax da Tropic por:
  - `3 - Big_mountain_BG.png`
  - `2 - Smaller_mountains.png`
  - `1 - Snowy_foreground_area.png`
- Manter os `Skeleton` como inimigos atuais da fase, com revisao de `div` e `sqrt`, depois progressao para `pow` e `fact`.

## Tarefas

- [x] Ler `AGENTS.md`, `README.md` e skills locais da `.agent`.
- [x] Inspecionar `scene/tropic.tscn` e `scene/ice.tscn`.
- [x] Identificar `terrain-ice` em `tiles/terrain.tres`.
- [x] Identificar `entities-ice` em `tiles/decoration.tres`.
- [x] Criar a cena `Ice` baseada na estrutura da `Tropic`.
- [x] Trocar o parallax para assets de Winter World.
- [x] Usar terrain ice na camada `Terrain`.
- [x] Usar entities ice na camada `Decoration`.
- [x] Manter camera, player, limites, placa, guia e inimigos funcionais.
- [ ] Validar a cena abrindo no editor Godot.
- [ ] Jogar do inicio ao topo para confirmar saltos, camera e patrulha dos inimigos.
- [ ] Confirmar visualmente que as decoracoes ice nao escondem enemies, player ou plataformas.

## Definicao de pronto

- `scene/ice.tscn` abre no Godot sem erro.
- A fase usa terreno e decoracoes de gelo.
- O parallax usa somente background parts do Winter World.
- A rota segue a mesma base vertical da Tropic.
- A fase pode ser jogada do spawn ate o topo sem atalhos do editor.
