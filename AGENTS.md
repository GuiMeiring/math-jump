# Math Jump - Instruções para o Codex

## Visão geral
Math Jump é um jogo sério de matemática feito em Godot.
É um jogo de plataforma vertical onde o player sobe plataformas e derrota inimigos respondendo cálculos matemáticos.

O jogo terá:
- Operações de multiplicação
- Divisão
- Fatorial
- Raiz
- Quatro cenários durante a subida
- Boss final no fim do percurso

## Objetivo do Codex
Ajudar em:
- Refatorações
- Correção de bugs
- Novas mecânicas
- Organização da arquitetura
- Melhorias de código
- Padronização dos scripts GDScript

## Regras de desenvolvimento
- Não alterar muitos sistemas ao mesmo tempo.
- Antes de modificar, entender a cena e os scripts envolvidos.
- Manter nomes claros para variáveis, funções e cenas.
- Evitar código duplicado.
- Preferir funções pequenas e específicas.
- Não quebrar cenas existentes.
- Sempre explicar quais arquivos foram alterados e por quê.

## Arquitetura esperada
- Player controla movimento, pulo, ataque e estados.
- Inimigos possuem estados próprios, como walk, attack, hurt e dead.
- Sistema de perguntas matemáticas deve ser separado dos inimigos.
- UI de perguntas deve ficar separada da lógica de geração dos cálculos.
- Boss final deve reutilizar sistemas já existentes quando possível.

## Padrões de Godot
- Usar sinais para comunicação entre sistemas quando possível.
- Usar `call_deferred()` quando adicionar nodes durante `_ready()` ou mudanças de árvore.
- Evitar acessar nodes que podem estar nulos sem validação.
- Usar `@onready` para referências de nodes da cena.
- Usar `@export` para valores ajustáveis no editor.

## Antes de implementar
O Codex deve:
1. Ler os scripts relacionados.
2. Identificar dependências.
3. Explicar a solução proposta.
4. Fazer alterações pequenas e testáveis.

## Commits
Usar nomes claros, por exemplo:
- feat: add math question system
- fix: correct enemy attack collision
- refactor: improve player state machine
- feat: add boss final behavior