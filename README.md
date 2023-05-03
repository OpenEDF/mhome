# mhome：
  I have made up my mind, I want to buy a house, I want to buy a house here.
  
  macro home my home

### build:
```shell
$ cd vsim
$ make install
$ make com
$ make sim
$ make wave
```
### inst:
| Inst   | Description | State | asm | cmd |
|  ---   | --- | --- | --- | --- |
| lui    | load u-imm 20bit to rd  |✔ |  rv32mi_lui.s | make case=lui|
| auipc  | place pc add u-imm 20bit to rd |✔ |  rv32mi_auipc.s | make case=auipc |
| jal    | jump and link |✔ |  rv32mi_jar.s | make case=jal |
| jalr   | jump and link register |✔ |  rv32mi_jarl.s | make case=jalr |
| beq    | branch rs1 equal rs2 |✔ |  rv32mi_beq[n].s | make case=beq[n] |
| bne    | branch rs1 unequal rs2 |✔ |  rv32mi_bne[n].s | make case=bne[n] |
| blt    | branch signed rs1 less than rs2 |✔ |  rv32mi_ble[n].s | make case=ble[n] |
| bltu   | branch unsigned rs1 less than rs2 |✔ |  rv32mi_bltu[n].s | make case=bltu[n] |
| bge    | branch signed rs1 greater than or euqal rs2 |✔ |  rv32mi_bge[n].s | make case=bge[n] |
| bgeu   | branch unsigned rs1 greater than or equal rs2 |✔ |  rv32mi_bgeu[n].s | make case=bgeu[n] |
| auipc  | Text        |❌|                 | |

### debug:
![ifidstage](https://github.com/OpenEDF/mhome/blob/main/doc/pic/ifidstage.png)
