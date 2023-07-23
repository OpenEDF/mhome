/* command: riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -S mul_div_ctoasm.c */
void divu_c_to_asm_test(void)
{
    unsigned int a, b;
    unsigned int c;
    a = 100;
    b = 25;
    c = a / b;
}

void div_c_to_asm_test(void)
{
    int a, b;
    int c;
    a = 100;
    b = 25;
    c = a / b;
}

void remu_c_to_asm_test(void)
{
    unsigned int a, b;
    unsigned int c;
    a = 100;
    b = 25;
    c = a % b;
}

void rem_c_to_asm_test(void)
{
    int a, b;
    int c;
    a = 100;
    b = 25;
    c = a % b;
}

void mul_c_to_asm_test(void)
{
    int a, b;
    int c;
    a = 100;
    b = 25;
    c = a * b;
}

void mulu_c_to_asm_test(void)
{
    unsigned int a, b;
    unsigned int c;
    a = 100;
    b = 25;
    c = a * b;
}
