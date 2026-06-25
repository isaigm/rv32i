# RV32I Single-Cycle Processor (VHDL)

A single-cycle implementation of the RISC-V **RV32I** base integer instruction set, written from scratch in VHDL and targeting the **Digilent Basys 3** board (Xilinx Artix-7, XC7A35T). Verified through behavioral simulation in Vivado, stage by stage.

This is an educational project built to understand processor microarchitecture end to end: from individual RTL building blocks up to a fully integrated datapath that fetches, decodes, executes, accesses memory, and performs control flow.

## Architecture

The design follows the classic single-cycle RISC datapath, with a clean separation between the **datapath** (the hardware that moves and transforms data) and the **control unit** (the logic that steers it via control signals).

Key design decisions:

- **Single-cycle**: each instruction completes in one clock cycle. Simple to reason about; the long critical path is the expected trade-off and the motivation for a future pipelined version.
- **Harvard architecture**: separate instruction and data memories, which keeps the design simple and avoids structural hazards on memory access.
- **Datapath + control separation**: the ~25 implemented instructions reuse a single shared datapath (one ALU, one register file, a set of muxes), reconfigured per instruction by control signals — rather than dedicated hardware per instruction.

### Block overview

| Module | Description |
|--------|-------------|
| `program_counter` | 32-bit PC register with synchronous reset |
| `instruction_memory` | Word-addressed instruction ROM (byte-address input, lower 2 bits dropped) |
| `register_file` | 32 × 32-bit registers, 2 read ports (async) + 1 write port (sync), `x0` hardwired to zero |
| `alu` | 10 operations (add, sub, and, or, xor, sll, srl, sra, slt, sltu) + zero flag |
| `immediate_generator` | Reconstructs sign-extended immediates for the I/S/B/U/J formats |
| `control_unit` | Decodes opcode / funct3 / funct7 into control signals |
| `data_memory` | Word-addressed RAM, synchronous write + asynchronous read |
| `datapath_top` | Top-level integration: instantiates all components, muxes, and next-PC logic |
| `rv32i_pkg` | Shared constants (ALU ops, immediate selectors, writeback selectors, opcodes) |

### Datapath muxes

- **ALU source mux** (`alu_src`): selects `rs2` or the immediate as the ALU's second operand.
- **Writeback mux** (`wb_sel`, 5-way): selects the value written back to the register file — ALU result, memory data, PC+4, immediate, or PC+immediate.
- **Next-PC mux**: selects PC+4 or the branch/jump target.

## Implemented instructions

**25 of ~37** core RV32I instructions are implemented and verified:

- **R-type (10):** `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`
- **I-type arithmetic (9):** `addi`, `andi`, `ori`, `xori`, `slti`, `sltiu`, `slli`, `srli`, `srai`
- **Load / Store:** `lw`, `sw`
- **Branch:** `beq`
- **Jump:** `jal`
- **Upper immediate:** `lui`, `auipc`

## Verification

Each stage of the datapath was verified independently in Vivado behavioral simulation before adding the next, so that integration bugs could be isolated as they appeared:

1. **Fetch** — confirmed the PC increments by 4 each cycle (0, 4, 8, 12 …).
2. **Decode + Execute** — ran `addi` instructions and confirmed correct ALU results.
3. **Memory** — ran a register → memory → register round-trip (`addi`, `sw`, `lw`) and confirmed the value survived.
4. **Branch** — confirmed `beq` skips the correct instruction and the PC jumps over it.
5. **Jump** — confirmed `jal` jumps to the target *and* saves the return address (PC+4) in `rd`.
6. **Upper immediate** — confirmed `lui` places the immediate in the upper bits and `auipc` computes PC + immediate.

Individual leaf modules (ALU, register file, immediate generator) were also inspected via the synthesized RTL schematic to confirm they elaborate as expected (no inferred latches, correct mux structure, `x0` zero-forcing logic present).

## Roadmap

Planned next steps, roughly in order:

- [ ] `jalr` (requires a dedicated next-PC target: `rs1 + imm`)
- [ ] Remaining branches: `bne`, `blt`, `bge`, `bltu`, `bgeu`
- [ ] Sub-word loads/stores: `lb`, `lh`, `lbu`, `lhu`, `sb`, `sh`
- [ ] System instructions: `ecall`, `ebreak`, `fence`
- [ ] Formal verification against the official `riscv-tests`
- [ ] Synthesis, timing closure, and bring-up on the Basys 3
- [ ] Run compiled C / Rust (`no_std`) with a memory-mapped UART ("Hello World")
- [ ] Evolve to a 5-stage pipeline (forwarding, hazard detection)

## Tools

- **Language:** VHDL (VHDL-2008)
- **Toolchain:** Xilinx Vivado
- **Target:** Digilent Basys 3 (Artix-7 XC7A35T)

## Repository structure

```
.
├── rv32i.srcs/          # VHDL source (design + simulation)
├── rv32i.xpr            # Vivado project file
├── .gitignore
└── README.md
```

>
