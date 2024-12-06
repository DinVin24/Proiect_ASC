.data
    vector: .space 1024
    aidi: .byte 5 #Variabila pt ID
    spatiu_aidi: .byte 20 #Variabila pt spatiul unui ID
    var_citire: .space 1 #Variabila pt citire numere...
    formatPrintf: .asciz "%d"
    formatString: .asciz "%ld"
    newLine: .asciz "\n"
.text

citire:
    pushl $var_citire
    pushl $formatString
    call scanf
    popl %ebx
    popl %ebx
    ret

afisare:
    pushl %eax
    pushl $formatPrintf
    call printf
    popl %ebx
    popl %ebx
    ret

afisare_vector:
    lea vector, %edi
    xorl %ecx,%ecx
    et1loop:
        cmp $1024,%ecx
        je pls1stop
        movb (%edi,%ecx,1),%al
        pushl %ecx
        call afisare
        popl %ecx
        incl %ecx
        jmp et1loop

    pls1stop:
        ret

umplere_zerouri:
    lea vector,%edi
    xorl %eax, %eax
    xorl %ecx, %ecx

    et2loop:
        cmp $1024,%ecx
        je pls2stop
        movb %al,(%edi,%ecx,1)
        incl %ecx
        jmp et2loop

    pls2stop:
        ret

fct_add:
#EMANUEL TE ROG SA MA REPARI, NU FUNCTIONEZ CONFORM STANDARDELOR!!!
    #call citire 
    #movb var_citire,%al
    #movb %al,aidi
    #call citire
    #movb var_citire,%al
    #movb %al,spatiu_aidi #Pana aici am citit ID-ul si spatiul

    movl spatiu_aidi,%eax   #Aici voi incerca un ceil(spatiu/8)
    xorl %edx,%edx
    movl $8,%ebx
    divl %ebx
    lea vector, %edi
    movl aidi,%ecx
    movb %cl,(%edi,%eax,1)

.global main
main:
    call umplere_zerouri
    call fct_add
    call afisare_vector

etexit:
    pushl $0
    call fflush
    popl %eax

    movl $1,%eax
    movl $0,%ebx
    int $0x80
