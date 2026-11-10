# Racha

App de racha do Integration Day da Apple Developer Academy.

Requisitos: Xcode 16 ou mais novo, iOS 18 no simulador.

## Como abrir

1. Abra `Racha.xcodeproj` no Xcode.
2. Escolha um simulador de iPhone e rode com ⌘R.
3. Rode os testes com ⌘U.

## Branches

| Branch | Para quê |
|---|---|
| `main` | A versão atual do app. |
| `feature/skip-absentees` | Feature nova: quem não foi à festa não paga. |

## O que tem em cada arquivo

**App (`Racha/`)**

| Arquivo | O que faz |
|---|---|
| `Models/Purchase.swift` | Uma compra: quem pagou (`buyer`), quanto (`amount`, em centavos), o quê (`item`) e a categoria (`category`). |
| `Models/PurchaseCategory.swift` | Comida, bebida, salgadinho, doce, decoração ou outro. Só serve para deixar a lista mais legível. |
| `Models/Participant.swift` | Uma pessoa do racha. |
| `Models/BillSplit.swift` | As regras: `total`, `shares()`, `amountPaid(by:)`, `balance(of:)` e `settlements()` (quem paga pra quem, com o mínimo de Pix). Tem o atalho `BillSplit(total:people:)` e o exemplo `BillSplit.integrationDaySample`. |
| `Models/Transfer.swift` | Um Pix do acerto: `from` paga `amount` pra `to`. |
| `Models/Money.swift` | Converte centavos em texto (`format(cents:)`) e texto em centavos (`cents(from:)`). |
| `Services/ParticipantsService.swift` | O protocolo `ParticipantsService` e a `APIParticipantsService`, que finge ser a API da turma (espera 1 segundo e devolve os 30 nomes da turma). |
| `ViewModels/BillSplitViewModel.swift` | Compras, participantes, `total`, `canCloseBill`, `add(_:)`, `loadParticipants()` e o `state` (`.loading`, `.empty`, `.failed`, `.loaded`). |
| `Views/RootView.swift` | As duas abas e a carga da turma ao abrir o app. |
| `Views/BalanceView.swift` | Aba **Acerto** (consulta): card do total, cards de pessoas, valor por pessoa e compras, lista de quem paga pra quem e botão Fechar conta. |
| `Views/SettlementView.swift` | O **acerto final**, aberto pelo Fechar conta: os Pix agrupados por quem recebe e o botão que manda a mensagem no grupo da turma. |
| `Views/Components/BalanceRow.swift` | Uma linha do acerto: quanto a pessoa recebe e de quantas pessoas, ou quanto paga e pra quem. |
| `Views/PurchasesView.swift` | Aba **Compras**: lista das compras com total e botão para cadastrar. |
| `Views/AddPurchaseView.swift` | Formulário de nova compra, aberto como sheet. |
| `Views/Components/Style.swift` | Ícone e cor de cada categoria, avatar colorido das pessoas e os cards do resumo. |

Os textos da interface são em português.

**UI Tests (`RachaUITests/`)**: testes que abrem o app no simulador e usam a tela.
