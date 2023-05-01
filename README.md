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
| auipc  | Text        |❌|                 | |

### debug:
![ifidstage](https://github.com/OpenEDF/mhome/blob/main/doc/pic/ifidstage.png)
