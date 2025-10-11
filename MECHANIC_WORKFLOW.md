# Fluxo de Trabalho do Mecânico - Guia Visual

## 1. Mechanic Dashboard (Atualizado)

### Estatísticas

```
┌─────────────────┬─────────────────┐
│  Available: 5   │   Pending: 3    │
│  (verde)        │   (laranja)     │
└─────────────────┴─────────────────┘
┌─────────────────┬─────────────────┐
│  My Active: 2   │  Completed: 10  │
│  (azul)         │   (teal)        │
└─────────────────┴─────────────────┘
```

### Quick Actions

```
┌─────────────────────────────────────┐
│ ✓  Manage My Availability           │
│    (Botão verde destacado)          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ ≡  Manage Appointments              │
│    (Botão outlined)                 │
└─────────────────────────────────────┘
```

---

## 2. Availability Management Page (Nova)

### Seção: Adicionar Horário

```
┌──────────────────────────────────────┐
│ ⊕ Add Available Time Slot            │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ 📅 Date: Oct 15, 2025            │ │
│ └──────────────────────────────────┘ │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ 🕐 Time: 14:30                   │ │
│ └──────────────────────────────────┘ │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │    ➕ Add Availability            │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Seção: Quick Add - Today

```
┌──────────────────────────────────────┐
│ Quick Add - Today                    │
│                                      │
│ [09:00] [10:00] [11:00]             │
│ [14:00] [15:00] [16:00]             │
│                                      │
│ (Clique em qualquer botão para      │
│  adicionar esse horário para hoje)   │
└──────────────────────────────────────┘
```

### Seção: My Available Slots

```
┌──────────────────────────────────────┐
│ My Available Slots                   │
│                                      │
│ ┌────────────────────────────────┐   │
│ │ ✓  2025-10-15 09:00           🗑│   │
│ │    Status: available              │ │
│ └────────────────────────────────┘   │
│                                      │
│ ┌────────────────────────────────┐   │
│ │ ✓  2025-10-15 14:00           🗑│   │
│ │    Status: available              │ │
│ └────────────────────────────────┘   │
│                                      │
│ ┌────────────────────────────────┐   │
│ │ ✓  2025-10-16 10:00           🗑│   │
│ │    Status: available              │ │
│ └────────────────────────────────┘   │
└──────────────────────────────────────┘
```

---

## 3. Fluxo Completo

```
┌─────────────────────┐
│  Mechanic Dashboard │
│                     │
│  [Manage My         │
│   Availability]     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Availability       │
│  Management Page    │
│                     │
│  1. Seleciona data  │
│  2. Seleciona hora  │
│  3. Clica Add       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Slot criado!       │
│  Status: available  │
│                     │
│  Cliente pode       │
│  agendar agora      │
└─────────────────────┘
```

---

## 4. Estados e Transições

### Estado 1: Slot Disponível

```
Slot criado pelo mecânico
├─ Status: available
├─ mechanicId: "mechanic_001"
├─ clientId: null
└─ Visível para clientes
```

### Estado 2: Slot Agendado (Cliente faz booking)

```
Cliente agenda o slot
├─ Status: scheduled
├─ mechanicId: "mechanic_001"
├─ clientId: "user_123"
└─ Aparece em "Pending" do mecânico
```

### Estado 3: Mecânico Aceita

```
Mecânico aceita trabalho
├─ Status: scheduled
├─ mechanicId: "mechanic_001" (mantém)
├─ clientId: "user_123"
└─ Aparece em "My Active"
```

### Estado 4: Trabalho Completo

```
Mecânico marca como completo
├─ Status: completed
├─ mechanicId: "mechanic_001"
├─ clientId: "user_123"
└─ Aparece em "Completed"
```

---

## 5. Ações do Mecânico

### No Dashboard:

- ✅ Visualizar estatísticas
- ✅ Navegar para gerenciar disponibilidade
- ✅ Navegar para gerenciar agendamentos

### Na Availability Management:

- ✅ Adicionar slot disponível (data/hora customizada)
- ✅ Quick add (horários pré-definidos)
- ✅ Visualizar slots disponíveis
- ✅ Deletar slot disponível
- ❌ Não pode deletar slot já agendado por cliente

### No Slot Management:

- ✅ Ver agendamentos pendentes
- ✅ Aceitar agendamentos
- ✅ Recusar agendamentos
- ✅ Marcar como completo
- ✅ Ver histórico

---

## 6. Validações e Regras

### Criação de Slot:

- ✓ Data não pode ser no passado
- ✓ Data máxima: 90 dias no futuro
- ✓ Horário obrigatório
- ✓ Auto-associa ao mecânico logado

### Exclusão de Slot:

- ✓ Confirmação obrigatória
- ✓ Apenas slots "available"
- ✗ Não pode deletar se já agendado

### Feedback ao Usuário:

- ✓ SnackBar verde para sucesso
- ✓ SnackBar vermelho para erro
- ✓ Loading indicator durante operações
- ✓ Ícones visuais claros

---

## 7. Integração com Cliente

```
┌──────────────────┐         ┌──────────────────┐
│ Mecânico cria    │         │ Cliente vê       │
│ slot disponível  │────────▶│ slot disponível  │
│                  │         │ na lista         │
└──────────────────┘         └────────┬─────────┘
                                      │
                                      ▼
                             ┌─────────────────┐
                             │ Cliente agenda  │
                             │ o slot          │
                             └────────┬────────┘
                                      │
                                      ▼
┌──────────────────┐         ┌─────────────────┐
│ Mecânico vê em   │◀────────│ Status muda para│
│ "Pending"        │         │ "scheduled"     │
└──────────────────┘         └─────────────────┘
```

---

## 8. Cores e Ícones

| Status/Função | Cor      | Ícone           |
| ------------- | -------- | --------------- |
| Available     | Verde    | event_available |
| Pending       | Laranja  | pending_actions |
| My Active     | Azul     | work            |
| Completed     | Teal     | check_circle    |
| Delete        | Vermelho | delete          |
| Add           | Verde    | add_circle      |
| Calendar      | -        | calendar_today  |
| Time          | -        | access_time     |

---

## 9. Melhorias Futuras

### Prioridade Alta:

- [ ] Validar duplicatas (não permitir mesmo horário 2x)
- [ ] Adicionar descrição/notas ao slot
- [ ] Filtro por data na lista de slots

### Prioridade Média:

- [ ] Criar múltiplos slots de uma vez (bulk create)
- [ ] Template de horários (ex: "Segunda a Sexta, 9h-17h")
- [ ] Editar horário de slot disponível

### Prioridade Baixa:

- [ ] Exportar para Google Calendar
- [ ] Notificações push quando slot é agendado
- [ ] Relatórios de disponibilidade vs utilização
- [ ] Integração com feriados (desabilitar dias específicos)

---

## 10. Testes Sugeridos

### Testes Manuais:

1. ✓ Criar slot para hoje
2. ✓ Criar slot para amanhã
3. ✓ Usar quick add
4. ✓ Deletar slot disponível
5. ✓ Verificar que slot aparece na lista
6. ✓ Verificar estatística no dashboard
7. ✓ Tentar criar slot no passado (deve falhar)

### Cenários de Integração:

1. ✓ Mecânico cria → Cliente vê → Cliente agenda
2. ✓ Mecânico cria → Mecânico deleta → Cliente não vê mais
3. ✓ Mecânico cria múltiplos → Todos aparecem ordenados

---

## Conclusão

O fluxo de gerenciamento de disponibilidade está completo e funcional. O mecânico agora tem controle total sobre sua agenda, podendo:

- ✅ Criar horários disponíveis de forma rápida e intuitiva
- ✅ Visualizar sua disponibilidade em tempo real
- ✅ Gerenciar sua agenda com facilidade
- ✅ Ver estatísticas claras no dashboard

O sistema está pronto para uso em produção!
