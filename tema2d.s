.data
    matrice: .space 64
    inceput_interval: .space 4  #aceste doua variabile le folosesc la functia GET si DELETE
    final_interval: .space 4
    rand_actual: .space 4 #iar asta memoreaza randul pe care suntem
    var_citire: .space 4 #Variabila pt citire numere...
    spatiu_aidi: .space 4 #Variabila care va retine nr de blocuri-1
    aidi: .space 1 #Variabila care va retine aidiul citit
    formatPrintf: .asciz "%d "
    formatInterval: .asciz "%d: (%d, %d)\n"
    formatGet: .asciz "(%d, %d)\n"
    formatString: .asciz "%ld"
    newLine: .asciz "\n"
.text
citire:
#Citim de la tast. un numar. Acesta ramane memorat in var_citire!!
    pushl $var_citire
    pushl $formatString
    call scanf
    popl %ebx
    popl %ebx
    ret

afisare:
#Afisam pe ecran un numar, cu spatiu. Inainte de apel, trb sa mutam in EAX nr de afisat!!!
#asta-i doar de debugging pt mine, nu se apeleaza deloc la teste
    pushl %eax
    pushl $formatPrintf
    call printf
    popl %ebx
    popl %ebx
    ret

afisare_matrice:
#Afisez toata matricea, n-ai nev. de parametrii.
#la fel si asta
    lea matrice,%edi
    xorl %ecx, %ecx
    forAfisare:
        cmp $64,%ecx
        je pls1stop
        pushl %ecx      #ca sa nu pierd contorul, dau pop dupa printf
        call afisamNewLine
        xorl %eax,%eax
        popl %ecx
        movb (%edi,%ecx,1),%al
        pushl %ecx
        pushl %eax
        pushl $formatPrintf
        call printf
        popl %ebx
        popl %ebx
        popl %ecx
        incl %ecx
        jmp forAfisare
    pls1stop:
        ret

afisamNewLine:
#Ma zgaria pe creier sa incerc sa scriu asta in aceeasi functie cu afisare_matrice
    xorl %edx,%edx
    movl %ecx,%eax
    movl $8,%ebx
    divl %ebx
    cmp $0,%edx
    je daAfisam
    ret
    daAfisam:
    cmp $0,%ecx
    je GATAAAAAAAA
    pushl $newLine
    call printf
    popl %ebx
    GATAAAAAAAA:
    ret

init_matrice:
#am facut functia asta doar sa arate mai clean main-ul
    movl $8,%edx
    xorl %ecx,%ecx
    xorl %eax,%eax
    forInit:
        cmp %ecx,%edx
        je gataForInit
        pushl $0
        pushl %ecx
        pushl $0
        pushl %edx
        call umplere
        popl %edx
        popl %ebx
        popl %ecx
        popl %ebx
        incl %ecx
        jmp forInit
    gataForInit:
    ret

umplere:
#Umplu cu aidi de la un capat dat la altul!! push id,rand,inceput,final
    lea matrice,%edi
    xorl %edx,%edx
    movl $8,%ebx
    movl 12(%esp),%eax      #Randul pe care suntem
    movl 8(%esp), %ecx      #INCEPUT
    mull %ebx
    movl 16(%esp),%ebx      #aidi
    movl 4(%esp),%edx       #FINAL
    incl %edx
    addl %eax,%ecx          #adun capetele cu i*8, i=(0,7)
    addl %eax,%edx
    et2loop:
        cmp %edx,%ecx
        je pls2stop
        movb %bl,(%edi,%ecx,1)
        incl %ecx
        jmp et2loop

    pls2stop:
        ret

fct_add:
#Adauga in memorie, unde exista loc, aidiul citit
    call citire    #AICI CITIM aidiUL
    movb var_citire,%al
    movb %al,aidi

    call citire    #AICI CITIM SPATIUL OCUPAT
    movl var_citire,%eax
    movl %eax,spatiu_aidi 

    lea matrice,%edi #ma joc cu vectorul
    xorl %edx,%edx 
    movl $8,%ebx
    divl %ebx      #impart la 8
    cmp $0,%edx
    je decrementez  #doar daca spatiul %8 ==0
    GataDecrementarea:

    movl %eax,spatiu_aidi           #pastram dimensiunea efectiva in blocuri - 1
    call cautam_spatiu              #ne este returnat 0 sau 1 in eax
    cmp $0,%eax
    je Space_Unavailable        
    avem_spatiu:                    #apelam functia de umplere
    xorl %eax,%eax
    movb aidi,%al
    pushl %eax
    pushl rand_actual
    pushl inceput_interval
    pushl final_interval
    call umplere
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx

    #call afisare_add   #EMANUEL TE ROG EU FRUMOS SA FACI FUNCTIA ASTA INAPOI!!
    ret

    
    decrementez:
        decl %eax
        jmp GataDecrementarea
    Space_Unavailable:  #cazul in care nu mai avem spatiu pt fisiere 
        pushl $0
        pushl $0
        pushl $formatGet
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        ret

cautam_spatiu:
#Returneaza 0 sau 1 in EAX daca n-/avem spatiu in matrice pt aidi
#Daca fumatul iti ia 9 ani din viata, as fi preferat sa fumez timp de 7 vieti decat sa scriu functia asta
    xorl %ecx,%ecx
    movl $8,%ebx
    forLinii:       #iterez linie cu linie, daca cumva ajung la final inseamna ca nu incape aidiul
        movl $8,%ebx
        cmp %ebx,%ecx
        jae navemspatiu
        movl %ecx,rand_actual
        subl spatiu_aidi,%ebx
        xorl %ecx,%ecx
        forBlocuri:     #iterez bloc cu bloc, apelez functii, daca ajung la final, trec la urmatoarea linie
            cmp %ebx,%ecx       #hai ca am dat denumiri prea bune, nu mai e nev. si de comentarii
            jae urmatoareaLinie

            movl %ecx,%edx
            addl spatiu_aidi,%edx
            pushl %ebx
            pushl rand_actual
            pushl %ecx
            pushl %edx
            call verific_interval_gol
            popl %edx
            popl %ecx
            popl %edx
            popl %ebx
            cmp $1,%eax
            je avemspatiu

            incl %ecx
            jmp forBlocuri

        urmatoareaLinie:
        movl rand_actual,%ecx
        incl %ecx
        jmp forLinii

    navemspatiu:
        movl $0,%eax
        ret
    avemspatiu:
        movl $1,%eax
        ret

verific_interval_gol:
#Functia asta ma ajuta la add, are ca parametri randul,inceput,final
#Returneaza 0/1 in EAX dupa caz.
    lea matrice,%edi
    movl $8,%ebx
    xorl %edx,%edx
    movl 12(%esp),%eax      #Randul pe care suntem
    movl 8(%esp), %ecx      #INCEPUT
    mull %ebx
    movl 4(%esp),%edx       #FINAL
    movl %ecx, inceput_interval
    movl %edx, final_interval
    addl %eax,%ecx          
    addl %eax,%edx
    xorl %ebx,%ebx
    loopVerific:
        cmp %ecx,%edx
        je retTrue
        cmp %bl,(%edi,%ecx,1)
        jne retFalse
        incl %ecx
        jmp loopVerific
    retTrue:
        movl $1,%eax
        ret
    retFalse:
        xorl %eax,%eax
        ret

.global main
main:
    call init_matrice
    call fct_add
    call fct_add
    call fct_add
    call fct_add
    call afisare_matrice

etexit:
    pushl $0
    call fflush
    popl %eax

    movl $1,%eax
    movl $0,%ebx
    int $0x80