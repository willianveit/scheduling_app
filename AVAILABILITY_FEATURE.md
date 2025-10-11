# Funcionalidade de Gerenciamento de Disponibilidade do Mecânico

## Resumo

Foi adicionado um fluxo completo para o mecânico gerenciar seus horários disponíveis no sistema de agendamento.

## Arquivos Criados

### 1. `/lib/domain/usecases/create_availability_slot.dart`

- **Use case** para criar slots de disponibilidade
- Gera IDs únicos para cada slot
- Define o status como "available" automaticamente
- Associa o slot ao mecânico que o criou

### 2. `/lib/presentation/pages/mechanic/availability_management_page.dart`

- **Página principal** para gerenciamento de disponibilidade
- Recursos implementados:
  - Seletor de data (permite escolher até 90 dias no futuro)
  - Seletor de horário
  - Botões de "Quick Add" para horários comuns (09:00, 10:00, 11:00, 14:00, 15:00, 16:00)
  - Lista de slots disponíveis do mecânico
  - Opção de deletar slots disponíveis
  - Feedback visual com SnackBars
  - Confirmação antes de deletar slots

## Arquivos Modificados

### 1. `/lib/presentation/pages/mechanic/mechanic_dashboard_page.dart`

**Mudanças:**

- Adicionado import da nova página de disponibilidade
- Nova estatística mostrando quantidade de slots "Available"
- Reorganização das estatísticas para incluir:
  - **Available** (verde) - Slots disponíveis do mecânico
  - **Pending** (laranja) - Agendamentos pendentes
  - **My Active** (azul) - Agendamentos ativos do mecânico
  - **Completed** (teal) - Agendamentos completados
- Adicionada seção "Quick Actions" com dois botões:
  - **"Manage My Availability"** (verde, destacado) - Navega para página de disponibilidade
  - **"Manage Appointments"** (outlined) - Navega para gerenciamento de agendamentos

## Fluxo de Uso

### Para o Mecânico:

1. **Acessa o Dashboard**

   - Visualiza estatísticas incluindo slots disponíveis

2. **Clica em "Manage My Availability"**

   - Abre a página de gerenciamento de disponibilidade

3. **Adiciona Horário Disponível**

   **Opção A - Seleção Manual:**

   - Seleciona uma data usando o date picker
   - Seleciona um horário usando o time picker
   - Clica em "Add Availability"

   **Opção B - Quick Add:**

   - Clica em um dos botões de horário pré-definido (09:00, 10:00, etc.)
   - O horário é adicionado para o dia atual instantaneamente

4. **Visualiza Slots Disponíveis**

   - Lista mostra todos os slots disponíveis ordenados por data/hora
   - Cada slot mostra o horário e status

5. **Deleta Slot (se necessário)**
   - Clica no ícone de deletar
   - Confirma a ação no diálogo
   - Slot é removido do sistema

### Para o Cliente:

1. Os slots criados pelo mecânico aparecem como disponíveis
2. Cliente pode agendar esses slots
3. Quando agendado, o status muda de "available" para "scheduled"

## Estrutura de Dados

### Slot com Status "Available"

```dart
Slot(
  slotId: 'mechanic_001_202501012100_timestamp',
  storeId: 'store_001',
  mechanicId: 'mechanic_001',
  appointmentTime: '2025-01-01 21:00',
  status: AppointmentStatus.available,
  clientId: null,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
)
```

## Validações Implementadas

1. **Data mínima**: Não permite datas no passado
2. **Data máxima**: Limita a 90 dias no futuro
3. **Confirmação de exclusão**: Previne exclusões acidentais
4. **Feedback visual**: Todas as ações têm feedback (sucesso ou erro)

## Benefícios

1. **Flexibilidade**: Mecânico controla sua própria agenda
2. **Facilidade de uso**: Interface intuitiva com quick add
3. **Organização**: Lista clara de horários disponíveis
4. **Controle**: Pode remover horários se necessário
5. **Visibilidade**: Dashboard mostra estatísticas em tempo real

## Próximos Passos (Opcionais)

- [ ] Adicionar recorrência (criar múltiplos slots de uma vez)
- [ ] Adicionar filtro de data na lista de slots
- [ ] Implementar edição de slots
- [ ] Adicionar notificações quando slot é agendado
- [ ] Exportar agenda para calendário
