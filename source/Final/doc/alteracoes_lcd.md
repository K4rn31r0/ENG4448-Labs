# Alterações — Etapa: Módulo LCD

Documento das alterações e adições feitas nesta etapa de desenvolvimento do projeto
Final (CPU), cujo objetivo foi **implementar o módulo de display LCD** e integrá-lo ao
processador.

**Requisitos atendidos (do enunciado):**
- Item 6 — o conteúdo do Registrador de Instruções (IR) é espelhado no LCD (nome da
  instrução escrito na linha 1).
- Item 7 — a segunda linha do LCD apresenta o valor da posição 255 da RAM.
- "Importante" item 1.b — o LCD roda no clock de 50 MHz da FPGA (não no clock lento da CPU).

---

## 1. Arquivos novos

### `LCD.vhd`
Módulo de topo do display (roda a 50 MHz). É um wrapper estrutural que:
- instancia `lcd_init` (inicialização) e `lcd_write` (escrita dinâmica);
- arbitra o barramento com um multiplexador controlado por `init_done`: enquanto a
  inicialização não termina, o LCD é controlado por `lcd_init`; depois, por `lcd_write`;
- mantém `SF_CE0 = '1'` para desabilitar a StrataFlash (o barramento `SF_D` é
  compartilhado com ela).

**Entradas:** `CLK50`, `RST`, `IR(7:0)`, `POS_255(7:0)`.
**Saídas (interface física):** `SF_D(11:8)`, `LCD_E`, `LCD_RS`, `LCD_RW`, `SF_CE0`.

### `lcd_init.vhd`
Sequência de inicialização do LCD em modo 4 bits, por meio de uma FSM de 13 estados
(`STEP0`–`STEP8`, `DONE`). Portada do Lab07 (código já validado em placa). Ao final,
sinaliza `LCD_INIT_DONE = '1'`.

### `lcd_write.vhd`
Escrita **dinâmica com refresh contínuo** (adaptada do `lcd_write` do Lab07). Estrutura:
- **FSM mestre** (`master_fsm`): `SEND_CONFIG` → `LATCH` → `SET_ADDR1` → `SEND_LINE1`
  → `LINE_CHANGE` → `SEND_LINE2` → (volta para `LATCH`).
- **FSM de escrita** (`write_fsm`): envia cada byte em modo 4 bits (dois nibbles com
  pulsos de `LCD_E`, respeitando a temporização do controlador).

Diferenças em relação ao Lab07 (que escrevia uma mensagem fixa uma única vez):
- Recebe `IR` e `POS_255` como entradas.
- No estado `LATCH`, captura o estado atual e monta as duas linhas:
  - **Linha 1** = `ir_to_line(IR)` — nome (mnemônico) da instrução corrente.
  - **Linha 2** = `pos255_to_line(POS_255)` — texto `MEM[255]=<valor decimal>`.
- Após escrever as duas linhas, **volta a capturar** `IR`/`POS_255` e reescreve, em vez
  de parar (`DONE`). Isso mantém o display espelhando continuamente o estado do
  processador. Como não há `clear` no laço, cada refresh apenas reposiciona o cursor
  (comandos `0x80` e `0xC0`) e sobrescreve os 32 caracteres — evitando flicker.

---

## 2. Arquivos modificados

### `lcd_utils_pkg.vhd`

**Adições:**
- Constantes de texto que faltavam: `STR_MOV` (`"mov Rx, Ry"`), `STR_ST`
  (`"st Rx, 0x--"`) e `STR_INVALID` (`"invalid instr."`).
- Infra portada do Lab07 para os módulos de LCD:
  - subtipos `byte_t`, `nibble_t`; tipos `char_array_type`, `initcmd_array_type`;
  - constantes de temporização (`wait750k`, `wait205k`, `wait82k`, `wait5k`, `wait2k`,
    `wait50`, `wait12`, `wait2`);
  - procedimento `increment_and_check` (contador com limite, usado nas esperas).
- Funções de decodificação para o LCD:
  - `ir_to_line(ir)` — mapeia o `IR` no mnemônico da instrução (16 caracteres),
    usando as constantes `STR_*`. Cobre toda a tabela de instruções do enunciado;
    opcodes/detalhes não definidos retornam `STR_INVALID`.
  - `pos255_to_line(pos)` — monta `"MEM[255]=DDD    "` com o valor em decimal, usando
    a função `to_bcd` (double-dabble) já existente no pacote.

**Correção de bug (pré-existente):**
- A função `to_std_logic_vector(string) return std_logic_vector` (usada apenas pelo
  `TEXT_MAP_ROM`) tinha indexação 1-based e escrevia **fora dos limites** do vetor no
  último caractere (`ret(i*8+7 downto i*8)` com `i` começando em 1). Isso causava
  estouro em tempo de elaboração e **quebraria qualquer simulação no ISim** que usasse
  este pacote. Corrigido normalizando o índice para 0-based (`idx := i - a'low`).
- Observação: o `TEXT_MAP_ROM` (ROM de 256 entradas, preenchida só parcialmente) não é
  usado em lugar nenhum — foi substituído pela abordagem `STR_*` + `ir_to_line`. Foi
  mantido intacto (apenas a função que o inicializa foi corrigida).

### `cpu.vhd`
- Adicionado o port de saída `IR_OUT : out std_logic_vector(7 downto 0)`.
- Adicionada a atribuição `IR_OUT <= IR;` — espelha a instrução corrente para o LCD.
- Nenhuma outra lógica da CPU foi alterada.

### `main.vhd`
- Adicionados os pinos do LCD à entidade: `SF_D(11:8)`, `LCD_E`, `LCD_RS`, `LCD_RW`,
  `SF_CE0`.
- Adicionados os sinais internos `r_IR` e `r_POS_255`.
- `u_cpu`: ligado o novo port `IR_OUT => r_IR`.
- `u_memory`: `POS_255` deixou de ser `open` e passou a alimentar `r_POS_255`.
- Adicionada a instância `u_lcd : entity work.LCD`, ligada ao **clock de 50 MHz**
  (`CLK50`, não o clock lento da CPU), a `r_IR`, `r_POS_255` e aos pinos físicos.

---

## 3. Validação (GHDL)

Toda a etapa foi validada com o GHDL 0.37 (`--std=93`):
- **Análise:** todos os módulos compilam sem erros, na ordem de dependência
  (`lcd_utils_pkg`, `alu`, `memory`, `clk_gen`, `lcd_init`, `lcd_write`, `LCD`, `cpu`,
  `main`).
- **Elaboração:** o topo `main` elabora (árvore de componentes liga corretamente).
- **Smoke test funcional:** um testbench capturou os nibbles enviados ao display,
  remontou os bytes e imprimiu o texto. Resultados confirmados:
  - `IR = 0x00`, `RAM[255] = 42`  →  linha 1 `add Rx, Ry`,  linha 2 `MEM[255]=042`.
  - `IR = 0x8A`, `RAM[255] = 255` →  linha 1 `st Rx, 0x--`, linha 2 `MEM[255]=255`.
  - Sequência de config correta (`0x28`, `0x06`, `0x0F`, `0x01`) e loop de refresh
    contínuo funcionando.

---

## 4. Pendências (fora do escopo desta etapa)

- Arquivo de constraints (`.ucf`) — inclusive os pinos do LCD e a atribuição dos LEDs
  (CLOCK + EQUAL/GREATER/SMALLER/ZERO/OVERFLOW).
- Adicionar os novos arquivos/pinos ao projeto ISE e sintetizar (o GHDL valida o VHDL,
  mas o XST do ISE pode ter nuances).
- Carregar um programa na RAM (`memory.vhd` ainda inicializa tudo com zeros).
- Testbench de topo para simulação completa da CPU.
