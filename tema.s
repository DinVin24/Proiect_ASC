.data:
    x: .long 7
.text:
.global main
main:
    movl x,%eax
etexit:
    pushl $0
    call fflush
    popl %eax

    movl $1,%eax
    movl $0,%ebx
    int $0x80