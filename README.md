# RV32I Single-Cycle Processor (VHDL)

A single-cycle implementation of the RISC-V **RV32I** base integer instruction set, written from scratch in VHDL and targeting the **Digilent Basys 3** board (Xilinx Artix-7, XC7A35T). Verified through behavioral simulation in Vivado, synthesized with timing closure, and brought up on real hardware running GCC-compiled C.

This is an educational project built to understand processor microarchitecture end to end: from individual RTL building blocks, up to a fully integrated datapath that fetches, decodes, executes, accesses memory at byte granularity, performs function calls and returns, and drives physical peripherals from C through memory-mapped I/O.

## Highlights

- **36 of 37** core RV32I instructions implemented and verified (only `ecall` / `ebreak` / `fence` pending).
- Runs **C compiled with GCC**, including **recursion** — verified `fib(10)` (177 nested recursive calls with full stack-frame management) returns 55 correctly per the RISC-V ABI.
- Synthesized and **timing-closed at 50 MHz** on the Artix-7 (WNS +2.64 ns, 0 failed routes, bitstream generated).
- **Memory-mapped I/O**: C running on the core blinks the board's LEDs by writing to a mapped address decoded to a peripheral register.
- Validated by computing the **first 31 prime numbers** (2-127) in hardware, using trial division by repeated subtraction (no hardware divider).

## Architecture

The design follows the classic single-cycle RISC datapath, with a clean separation between the **datapath** (the hardware that moves and transforms data) and the **control unit** (the logic that steers it via control signals).

Key design decisions:

- **Single-cycle**: each instruction completes in one clock cycle. Simple to reason about; the long critical path is the expected trade-off and the motivation for a future pipelined version. This is what caps Fmax at ~50 MHz (see Synthesis).
- **Harvard architecture**: separate instruction and data memories, which keeps the design simple and avoids structural hazards on memory access.
- **Datapath + control separation**: every implemented instruction reuses a single shared datapath (one ALU, one register file, a dedicated branch unit, dedicated load/store alignment units, a set of muxes), reconfigured per instruction by control signals - rather than dedicated hardware per instruction.

### Block overview

| Module | Description |
|--------|-------------|
| `program_counter` | 32-bit PC register with synchronous reset |
| `instruction_memory` | Word-addressed instruction ROM (byte-address input, lower 2 bits dropped) |
| `register_file` | 32 x 32-bit registers, 2 read ports (async) + 1 write port (sync), `x0` hardwired to zero |
| `alu` | 10 operations (add, sub, and, or, xor, sll, srl, sra, slt, sltu) + zero flag |
| `immediate_generator` | Reconstructs sign-extended immediates for the I/S/B/U/J formats |
| `control_unit` | Decodes opcode / funct3 / funct7 into control signals |
| `branch_unit` | Evaluates all six branch conditions (signed and unsigned) from funct3 |
| `load_unit` | Extracts and sign/zero-extends the addressed byte/halfword/word from a memory word |
| `store_unit` | Positions store data into the correct byte lane and generates byte-write enables |
| `data_memory` | Word-addressed RAM with per-byte write enables (synchronous write, asynchronous read) |
| `datapath_top` | Top-level integration: components, muxes, next-PC logic, and memory-mapped LED peripheral |
| `rv32i_pkg` | Shared constants (ALU ops, immediate selectors, writeback selectors, opcodes) |

### Datapath muxes

- **ALU source mux** (`alu_src`): selects `rs2` or the immediate as the ALU's second operand.
- **Writeback mux** (`wb_sel`, 5-way): selects the value written back to the register file - ALU result, loaded memory data, PC+4, immediate, or PC+immediate.
- **Next-PC mux**: selects PC+4, the branch/jal target (PC+imm), or the jalr target (rs1+imm, with the low bit cleared per spec).

## Implemented instructions

**36 of ~37** core RV32I instructions are implemented and verified:

- **R-type (10):** `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`
- **I-type arithmetic (9):** `addi`, `andi`, `ori`, `xori`, `slti`, `sltiu`, `slli`, `srli`, `srai`
- **Loads (5):** `lw`, `lh`, `lhu`, `lb`, `lbu`
- **Stores (3):** `sw`, `sh`, `sb`
- **Branches (6):** `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
- **Jumps:** `jal`, `jalr`
- **Upper immediate:** `lui`, `auipc`

Pending: `ecall`, `ebreak`, `fence` (only meaningful for traps / formal test harnesses on this single-core design).

### Sub-word memory access

Loads and stores support byte and halfword granularity. Since the data memory is word-organized (32-bit words), the low two address bits select the byte lane within a word:

- **Loads** read the full word and extract the addressed byte/halfword, sign-extending (`lb`/`lh`) or zero-extending (`lbu`/`lhu`).
- **Stores** position the source bytes into the correct lane and assert **per-byte write enables**, so a `sb`/`sh` updates only its bytes and leaves the rest of the word intact (read-modify-write for free). This is the idiom Xilinx infers as native Block-RAM byte-write-enable.

Verified to preserve adjacent bytes: four `sb` to addresses 0-3 of the same word produce `0x44332211` when read back with `lw`, and the same `0x80` byte reads as `0xFFFFFF80` via `lb` (signed) and `0x00000080` via `lbu` (unsigned).

## Verification

Each stage of the datapath was verified independently in Vivado behavioral simulation before adding the next, so integration bugs could be isolated as they appeared: fetch (PC increments), decode/execute (ALU results), memory round-trips, all six branches via the branch unit, `jal`/`jalr` target and link, and `lui`/`auipc`.

### End-to-end validation

**Prime sieve.** The processor computes the first 31 primes (2-127) using a triple-nested loop with trial division by repeated subtraction, exercising arithmetic, all six branch types, signed/unsigned comparison, backward branches, and memory stores at once. Data memory ends up holding 2, 3, 5, ... 127, with the 31st prime (`0x7F`) in the final slot.

**GCC-compiled C.** The core runs C compiled with `riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32`, linked with a custom startup (`crt0`) and linker script. Verified programs:

- A trivial `return 5 + 3` puts 8 in `a0` per the ABI.
- A recursive `fib(10)` combined with array iteration returns 205 - exercising deep recursion (177 nested calls), stack-frame setup/teardown, and `jal`/`jalr` call/return under realistic load.

**Hardware bring-up.** Synthesized, implemented, and run on the Basys 3. A C program toggles the LEDs through memory-mapped I/O (a store to a decoded address updates a peripheral register driving the LEDs), with a software delay loop - C controlling physical hardware on a self-designed CPU.

## Synthesis & timing

Synthesized and implemented in Vivado for the Artix-7 XC7A35T:

- **Closes timing at 50 MHz**: WNS +2.64 ns, TNS 0, 0 failed routes, bitstream generated.
- At 100 MHz the single-cycle critical path (fetch -> decode -> register read -> ALU -> data memory -> writeback in one cycle) does not close (WNS -4.16 ns) - expected for this microarchitecture, and the motivation for a pipelined version to raise Fmax.
- Resource usage: ~1.2k LUTs, 32 FFs (the 32x32-bit register file dominates).

## Toolchain (C -> hardware)

C programs are compiled to RV32I, converted to a VHDL ROM initializer, and loaded into the instruction memory. A helper script (`c2vhdl.sh`) automates compile -> objcopy -> VHDL generation and warns on any unsupported instruction. Memory-mapped peripherals (e.g. LEDs at a fixed address) are accessed from C via `#define`d `volatile` pointers so the address is materialized inline rather than placed in `.data`.

## Roadmap

- [ ] System instructions: `ecall`, `ebreak`, `fence`
- [ ] UART peripheral + "Hello World" over serial (same memory-mapped pattern as the LEDs)
- [ ] Formal verification against the official `riscv-tests`
- [ ] Evolve to a 5-stage pipeline (forwarding, hazard detection) to raise Fmax

## Tools

- **Language:** VHDL (VHDL-2008)
- **HDL toolchain:** Xilinx Vivado
- **Software toolchain:** `riscv64-unknown-elf-gcc` (bare-metal, `-march=rv32i`)
- **Target:** Digilent Basys 3 (Artix-7 XC7A35T)

## Repository structure

```
.
├── rv32i.srcs/          # VHDL source (design + simulation)
├── sw/                  # C programs, crt0, linker script, c2vhdl.sh
├── rv32i.xpr            # Vivado project file
├── .gitignore
└── README.md
```

