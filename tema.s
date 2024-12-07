.data
    vector: .space 1024
    start_liber: .long 0   #memoram de unde incep zero-urile
    end_vector: .long 1023
    space_available: .long 1024
    inceput_interval: .space 4  #aceste doua variabile le folosesc la functia GET si DELETE
    final_interval: .space 4
    aidi: .space 1 #Variabila pt ID
    spatiu_aidi: .space 4 #Variabila pt spatiul unui ID
    var_citire: .space 4 #Variabila pt citire numere...
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
    pushl %eax
    pushl $formatPrintf
    call printf
    popl %ebx
    popl %ebx
    ret

afisare_vector:
    #Afisez tot vectorul, n-ai nev. de parametrii.
    lea vector, %edi
    xorl %ecx,%ecx
    et1loop:
        cmp $1024,%ecx
        je pls1stop
        xorl %eax,%eax
        movb (%edi,%ecx,1),%al
        pushl %ecx
        call afisare
        popl %ecx
        incl %ecx
        jmp et1loop

    pls1stop:
        ret

umplere_zerouri:
    #Self explanatory
    #Umplu cu zero-uri de la un capat dat la altul!!
    lea vector,%edi
    xorl %eax, %eax
    movl 8(%esp), %ecx
    movl 4(%esp),%edx
    incl %edx

    et2loop:
        cmp %edx,%ecx
        je pls2stop
        movb %al,(%edi,%ecx,1)
        incl %ecx
        jmp et2loop

    pls2stop:
        ret

init_vector:
#am facut functia asta doar sa arate mai clean main-ul
    pushl $0
    pushl $1023
    call umplere_zerouri
    popl %ebx
    popl %ebx
    ret

fct_add:
    #N-am cuvinte...
    call citire    #AICI CITIM ID-UL
    movb var_citire,%al
    movb %al,aidi

    call citire    #AICI CITIM SPATIUL OCUPAT
    movl var_citire,%eax
    movl %eax,spatiu_aidi 

    lea vector,%edi #ma joc cu vectorul
    xorl %edx,%edx 
    movl $8,%ebx
    divl %ebx      #impart la 8
    cmp $0,%edx
    je decrementez  #doar daca spatiul %8 ==0
    GataDecrementarea:

    movl %eax,spatiu_aidi           #pastram dimensiunea efectiva in blockuri - 1
    incl %eax                           #compensare...
    cmp space_available,%eax           #daca consuma mai mult spatiu decat avem, renuntam...
    ja Space_Unavailable
    decl %eax                           #anulez "compensarea"
    movl space_available,%edx           #daca avem destul spatiu, actualizez spatiul ramas
    subl spatiu_aidi,%edx
    decl %edx                           #compensez pt inacuratetea lui spatiu_aidi de mai sus...
    movl %edx,space_available

    #TEST
    #pushl %eax
    #movl space_available,%eax
    #call afisare
    #popl %eax

    #SF. TEST
    
    movb aidi,%cl
    movl start_liber,%edx
    addl start_liber,%eax
    loop_add:        #incep cu edx de la start_liber pana la %eax inclusiv
        cmp %eax,%edx
        ja gata_loopul
        movb %cl,(%edi,%edx,1)
        incl %edx
        jmp loop_add

    gata_loopul:
    incl %eax                   #actualizez inceputul partii libere din vector
    movl %eax,start_liber
    call afisare_add
    ret

    decrementez:
        decl %eax
        jmp GataDecrementarea
    Space_Unavailable:   #cazul in care nu mai avem spatiu pt fisiere  (o sa se complice cand fac DELETE :(  )
        pushl $0
        pushl $0
        pushl $formatGet
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        ret
    
afisare_add:
    #Aici am facut niste chestii neortodoxe, ma folosesc de niste variabile care daca nu-s atent la ele, 
    #s-ar putea sa se piarda
    xorl %ecx,%ecx
    movb aidi,%cl
    movl start_liber,%eax
    decl %eax
    movl %eax,%edx
    subl spatiu_aidi,%edx
    pushl %eax
    pushl %edx
    pushl %ecx
    pushl $formatInterval
    call printf
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    ret

ADD_ID:
    call citire
    movl var_citire,%ecx
    nume_de_loop:
        pushl %ecx
        call fct_add
        popl %ecx
        loop nume_de_loop
    ret

gasireInterval:
    #Uoff incerc sa o fac cu parametru...
    #Inainte de apelare, trb sa pui ID-ul in stiva. Capetele intervalului sunt memorate in variabilele nebune
    #inceput_interval si final_interval
    xorl %ebx,%ebx
    movl 4(%esp),%eax
    lea vector, %edi
    xorl %ecx,%ecx
    caut_inceput:
        cmp $1024,%ecx
        je nam_gasit
        cmp %al,(%edi,%ecx,1)
        je am_gasit
        incl %ecx
        jmp caut_inceput
    
    am_gasit:
        movl %ecx, inceput_interval
        caut_final:
            cmp %al,(%edi,%ecx,1)
            jne gataaa
            incl %ecx
            jmp caut_final
        gataaa:
            decl %ecx
            movl %ecx,final_interval
            ret
    nam_gasit:
        movl $0,%ecx
        movl %ecx, inceput_interval
        movl %ecx,final_interval
        ret

GET_BOUNDS:
    call citire
    pushl var_citire
    call gasireInterval
    popl %ebx
    pushl final_interval
    pushl inceput_interval
    pushl $formatGet
    call printf
    popl %ebx
    popl %ebx
    popl %ebx
    ret

DELETE:
#functia asta trb si sa afiseze ceva... mai ai de lucru dar e bn 
    call citire
    pushl var_citire
    call gasireInterval
    popl %ebx
    xorl %ebx,%ebx
    cmp final_interval,%ebx
    je NU_EXISTA
    pushl inceput_interval
    pushl final_interval
    call umplere_zerouri
    popl %ebx
    popl %ebx

    NU_EXISTA:
    ret

.global main
main:
    call init_vector
    call ADD_ID
    call GET_BOUNDS
    call DELETE
    call afisare_vector

etexit:
    pushl $0
    call fflush
    popl %eax

    movl $1,%eax
    movl $0,%ebx
    int $0x80

#git add .
#git commit -m "mesaj"
#git push origin main