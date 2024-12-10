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

umplere:
#Self explanatory
#Umplu cu ID de la un capat dat la altul!!
    lea vector,%edi
    movl 12(%esp),%eax   #ID
    movl 8(%esp), %ecx   #INCEPUT
    movl 4(%esp),%edx    #FINAL
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
    pushl $0
    pushl $1023
    call umplere
    popl %ebx
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
    jmp cautam_spatiu          #eticheta pt cautarea unui spatiu
    avem_spatiu:
    subl spatiu_aidi,%ecx
    decl %ecx
    pushl aidi
    pushl %ecx
    pushl %ebx
    call umplere
    popl %ebx
    popl %ebx
    popl %ebx
    
    call afisare_add
    ret

    cautam_spatiu:#un for de la 0 la 1024-spatiu aidi. verific fiecare elem daca este gol. daca am destule goale,
    #mi-am gasit locul
    xorl %ecx,%ecx
    movl $1024,%edx
    subl spatiu_aidi,%edx
    forVector:
        cmp %edx,%ecx
        jae Space_Unavailable
        movl %ecx,%ebx
        addl spatiu_aidi,%ebx     #EBX TINE LIMITA SUPERIOARA A INTERVALULUI
        movl %ecx,%eax
        forInterval:
            cmp %ebx,%ecx
            ja  avem_spatiu
            cmpb $0,(%edi,%ecx,1)
            jne sfForInterval
            incl %ecx
            jmp forInterval
        sfForInterval:
        movl %eax,%ecx
        incl %ecx
        jmp forVector
    
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
#S-o stricat, am rescris-o
    xorl %eax,%eax
    movb aidi,%al
    pushl %eax
    call gasireInterval
    popl %eax
    pushl final_interval
    pushl inceput_interval
    pushl %eax
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
#Stergem un fisier dupa ID-ul citit de la tastatura, apoi afisez memoria...
    call citire
    pushl var_citire
    call gasireInterval
    popl %ebx
    xorl %ebx,%ebx
    cmp final_interval,%ebx
    je NU_EXISTA
    pushl $0
    pushl inceput_interval
    pushl final_interval
    call umplere
    popl %ebx
    popl %ebx
    popl %ebx
    call afisare_memorie
    NU_EXISTA:
    ret

afisare_memorie:
#Really self explanatory...
    xorl %ecx,%ecx #i-ul meu
    lea vector,%edi
    inceput_for:    #iau fiecare element din vector, daca reprezinta un ID, ii caut marginile si le afisez.
        cmp $1024,%ecx
        jae am_ajuns_la_capat
        xorl %eax,%eax
        movb (%edi,%ecx,1),%al
        cmp $0,%eax
        jne am_gasit_element
        incl %ecx
        revenire:
        jmp inceput_for

    am_gasit_element:
        pushl %eax
        call gasireInterval
        popl %eax
        pushl final_interval
        pushl inceput_interval
        pushl %eax
        pushl $formatInterval
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %eax

        movl final_interval,%ecx
        incl %ecx
        jmp revenire

    am_ajuns_la_capat:
    ret

.global main
main:
    call init_vector
    call ADD_ID
    call GET_BOUNDS
    call DELETE
    call ADD_ID
    call afisare_vector
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