# Racha

App de racha do Integration Day, usado no workshop de testes em Swift da Apple Developer Academy.

Requisitos: Xcode 16 ou mais novo, iOS 18 no simulador.

## Como abrir

1. Abra `Racha.xcodeproj` no Xcode.
2. Escolha um simulador de iPhone e rode com ⌘R.
3. Rode os testes com ⌘U.

## Branches

| Branch | Para quê |
|---|---|
| `main` | O app funcionando. É aqui que os alunos escrevem os testes. |
| `feature/skip-absentees` | A feature “quem não foi à festa não paga”, escrita “pela IA”. Tem o bug do centavo: a divisão inteira descarta o resto. Usada no Engage e no slide dos testes parametrizados. |

## O que tem em cada arquivo

**App (`Racha/`)**

| Arquivo | O que faz |
|---|---|
| `Models/Purchase.swift` | Uma compra: quem pagou (`buyer`), quanto (`amount`, em centavos), o quê (`item`) e a categoria (`category`). |
| `Models/PurchaseCategory.swift` | Comida, bebida, salgadinho, doce, decoração ou outro. Só serve para deixar a lista mais legível. |
| `Models/Participant.swift` | Uma pessoa do racha. |
| `Models/BillSplit.swift` | As regras: `total`, `shares()`, `amountPaid(by:)`, `balance(of:)`. Tem o atalho `BillSplit(total:people:)` e o exemplo `BillSplit.integrationDaySample`. |
| `Models/Money.swift` | Converte centavos em texto (`format(cents:)`) e texto em centavos (`cents(from:)`). Bom alvo extra para quem terminar cedo. |
| `Services/ParticipantsService.swift` | O protocolo `ParticipantsService` e a `APIParticipantsService`, que finge ser a API da turma (espera 1 segundo e devolve 23 nomes). |
| `ViewModels/BillSplitViewModel.swift` | Compras, participantes, `total`, `canCloseBill`, `add(_:)`, `loadParticipants()` e o `state` (`.loading`, `.empty`, `.failed`, `.loaded`). |
| `Views/RootView.swift` | As duas abas e a carga da turma ao abrir o app. |
| `Views/BalanceView.swift` | Aba **Acerto** (consulta): resumo da festa, quem recebe e quem paga, botão Fechar conta. |
| `Views/PurchasesView.swift` | Aba **Compras**: lista das compras com total e botão para cadastrar. |
| `Views/AddPurchaseView.swift` | Formulário de nova compra, aberto como sheet. |
| `Views/Components/Style.swift` | Ícone e cor de cada categoria, avatar colorido das pessoas e o estilo dos saldos (verde recebe, vermelho paga). |

Os textos da interface são em português.

**Testes (`RachaTests/`)**

| Arquivo | O que tem |
|---|---|
| `BillSplitTests.swift` | Vazio. Bloco 1. |
| `BillSplitViewModelTests.swift` | Suíte vazia com `@MainActor`. Blocos 2 e 3. |
| `BillSplitViewModelAITests.swift` | Os 8 testes “escritos pela IA” do desafio do bloco 2: 3 bons e 5 ruins. Todos passam. |

**UI Tests (`RachaUITests/`)**: o exemplo `testCloseBillStartsDisabled`, usado no slide dos próximos passos.

## O que fica de fora de propósito

- O `StubParticipantsService` não existe no starter: os alunos criam no bloco 3.
- Nenhum teste de `BillSplit` vem pronto.

## Regras do código

- Todo identificador em inglês (tipos, funções, variáveis, testes).
- Textos que aparecem na tela em português.
- Dinheiro sempre em centavos (`Int`).
