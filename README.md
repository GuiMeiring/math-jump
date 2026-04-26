# Math Jump

Math Jump é um jogo sério de matemática feito em Godot.

A proposta do projeto é misturar plataforma vertical com desafios matemáticos: o player sobe pelas fases, enfrenta inimigos e, no desenho final do jogo, derrota ameaças a partir de cálculos e respostas corretas.

## Visão Geral

O projeto foi pensado para evoluir para:

- multiplicação
- divisão
- fatorial
- raiz
- quatro cenários ao longo da subida
- boss final no fim do percurso

Hoje, o projeto já possui uma base jogável com:

- player controlável com movimento, pulo, defesa e estado de dano
- inimigo `Skeleton` com patrulha, ataque e morte
- projétil `SpinningBone`
- caixa de diálogo da placa
- geração de perguntas matemáticas
- balão de cálculo exibido acima dos inimigos

## Tecnologias

- Godot 4
- GDScript

## Cena Principal

- Cena inicial: `scene/tropic.tscn`
- Projeto: `project.godot`

## Controles Atuais

- `A` / seta esquerda: mover para a esquerda
- `D` / seta direita: mover para a direita
- `W` / seta para cima: pular
- `S` / seta para baixo: defender / abaixar
- `J` ou `Espaço`: atacar
- `I`: interagir com a placa
- `O`: avançar diálogo

## Arquitetura Atual

### Player

O player está centralizado em `scripts/player.gd` e usa uma máquina de estados simples:

- `idle`
- `walk`
- `jump`
- `fall`
- `duck`
- `hurt`

Responsabilidades atuais do player:

- movimento horizontal
- pulo e pulo duplo
- defesa contra projétil
- detecção de dano
- ataque corpo a corpo
- reinício da cena ao morrer

### Inimigo Skeleton

O `Skeleton` está em `scripts/skeleton.gd` e representa o inimigo principal atual.

Responsabilidades atuais:

- patrulha com raycasts
- detecção do player
- ataque com osso arremessado
- estado de dano / morte
- exibição do cálculo associado ao inimigo

Estados atuais:

- `walk`
- `attack`
- `hurt`

### Sistema de Perguntas

O sistema matemático está dividido hoje em duas partes principais:

- `scripts/math_system.gd`: gera pergunta, resposta correta e opções
- `scripts/dialog_manager.gd`: controla balão e persistência temporária do estado das perguntas por inimigo

Situação atual da arquitetura:

- a lógica matemática já existe como sistema separado
- o `Skeleton` ainda consome esse sistema diretamente
- a UI da pergunta ainda não está totalmente separada do fluxo de combate

Isso está alinhado parcialmente com a arquitetura esperada, mas ainda há espaço para evoluir para um controlador próprio de encontros matemáticos.

### Diálogos e UI

Arquivos principais:

- `scripts/dialog_manager.gd`
- `scripts/math_question_box.gd`
- `scripts/warning_sign.gd`

Funções atuais:

- abrir diálogo da placa
- avançar falas por input
- criar balão de cálculo para inimigos

### Câmera

- `scripts/camera.gd`

A câmera segue o primeiro node do grupo `player`.

## Estrutura de Pastas

```text
math-jump/
|- entities/      # cenas reutilizáveis de player, inimigos, câmera e UI
|- scene/         # fases do jogo
|- scripts/       # scripts GDScript principais
|- singletons/    # arquivos antigos / auxiliares
|- sprites/       # arte, fontes e efeitos
|- tiles/         # tilesets
|- project.godot  # configuração do projeto
```

## Arquivos Principais

- `scripts/player.gd`: controle do player
- `scripts/skeleton.gd`: IA e comportamento do inimigo skeleton
- `scripts/spinning_bone.gd`: comportamento do projétil
- `scripts/math_system.gd`: geração das operações matemáticas
- `scripts/dialog_manager.gd`: diálogos e balões
- `scripts/warning_sign.gd`: interação com a placa
- `entities/player.tscn`: cena do player
- `entities/skeleton.tscn`: cena do skeleton
- `scene/tropic.tscn`: fase principal atual

## Diretrizes de Desenvolvimento

Este repositório segue as orientações do `AGENTS.md`.

Princípios mais importantes:

- não alterar muitos sistemas ao mesmo tempo
- antes de modificar, entender a cena e os scripts envolvidos
- manter nomes claros para variáveis, funções e cenas
- evitar código duplicado
- preferir funções pequenas e específicas
- não quebrar cenas existentes
- sempre explicar quais arquivos foram alterados e por quê

## Padrões Esperados no Código

- usar sinais para comunicação entre sistemas quando fizer sentido
- usar `@onready` para referências de nodes
- usar `@export` para valores ajustáveis no editor
- validar referências antes de acessar nodes que podem não existir
- usar `call_deferred()` ao adicionar nodes em momentos sensíveis da árvore

## Arquitetura Esperada para Evolução

Direção desejada para o projeto:

- player separado por responsabilidades de movimento, combate e estados
- inimigos com estados claros como `walk`, `attack`, `hurt` e `dead`
- sistema de perguntas matemáticas desacoplado dos inimigos
- UI de perguntas separada da lógica de geração das contas
- boss final reaproveitando sistemas existentes sempre que possível

## Fluxo Recomendado para Novas Implementações

Antes de implementar qualquer alteração:

1. Ler os scripts relacionados.
2. Identificar dependências.
3. Explicar a solução proposta.
4. Fazer alterações pequenas e testáveis.

## Convenção de Commits

Exemplos de mensagens:

- `feat: add math question system`
- `fix: correct enemy attack collision`
- `refactor: improve player state machine`
- `feat: add boss final behavior`

## Estado Atual do Projeto

O projeto está em fase de base / protótipo jogável.

Já existe:

- locomoção do player
- combate básico
- inimigo funcional
- projétil
- diálogo de placa
- sistema inicial de cálculos

Ainda são passos naturais de evolução:

- separar melhor o sistema de perguntas do inimigo
- criar fluxo completo de responder pergunta e validar resultado
- adicionar mais inimigos e cenários
- introduzir progressão vertical mais completa
- implementar boss final

