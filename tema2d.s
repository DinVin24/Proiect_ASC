.data
    matrice: .space 64
    v_aidiuri: .space 256   #aici am toate aidiurile, fiecare element are 1Byte
    v_sizeuri: .space 1024  #aici am toate saizurile, fiecare elem. are 4Bytes
    nr_aidiuri: .byte 0   #asta-mi numara cate aidiuri am salvat
    inceput_interval: .space 4  #aceste doua variabile le folosesc la functia GET si DELETE
    final_interval: .space 4
    rand_actual: .space 4 #iar asta memoreaza randul pe care suntem
    var_citire: .space 4 #Variabila pt citire numere...
    spatiu_aidi: .space 4 #Variabila care va retine nr de blocuri-1
    aidi: .space 1 #Variabila care va retine aidiul citit
    formatPrintf: .asciz "%d "
    formatInterval: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatGet: .asciz "((%d, %d), (%d, %d))\n"
    formatString: .asciz "%ld"
    newLine: .asciz "\n"
.text

the_real_main:
#Aici se apeleaza de fapt functiile, ca sa nu-mi mai umplu main-ul. very clean very nice
    call citire
    movl var_citire,%ecx
    startLoop:
        pushl %ecx
        call citire
        movl var_citire,%eax

        cmp $1,%eax  #ADICA ADD 
        je apelam_add
        cmp $2,%eax #ADICA GET
        je apelam_get
        cmp $3,%eax #ADICA DELETE
        je apelam_delete 
        #cmp $4,%eax #ADICA DEFRAGALALAL
        #je apelam_defralalala

        revenim:
        popl %ecx
        loop startLoop
    ret
    apelam_add:
        call ADD_ID
        jmp revenim
    apelam_get:
        call GET_BOUNDS
        jmp revenim
    apelam_delete:
        call DELETE
        jmp revenim/*
    apelam_defralalala:
        call DEFRAGMENTATION
        jmp revenim*/
    ret

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
        call afisamNewLine
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

    call afisare_add
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

afisare_add:
#Se apeleaza dupa add, afiseaza intervalul in care am salvat aidiul
    xorl %eax,%eax
    movb aidi,%al
    pushl %eax
    call gasireInterval
    popl %eax
    pushl final_interval
    pushl rand_actual
    pushl inceput_interval
    pushl rand_actual
    pushl %eax
    pushl $formatInterval
    call printf
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    
    ret

ADD_ID:
#Asta face doar un loop, adevarata teroare e la fct_add
    call citire
    movl var_citire,%ecx
    nume_de_loop:
        pushl %ecx

        call citire    #AICI CITIM aidiUL
        movb var_citire,%al
        movb %al,aidi

        call citire    #AICI CITIM SPATIUL OCUPAT
        movl var_citire,%eax
        movl %eax,spatiu_aidi 

        call fct_add

        popl %ecx
        loop nume_de_loop
    ret

gasireInterval:
#Inainte de apelare, trb sa pui ID-ul in stiva. Capetele intervalului sunt memorate in variabilele nebune
#inceput_interval, final_interval si rand_actual
    xorl %ebx,%ebx
    movl 4(%esp),%eax
    lea matrice, %edi
    xorl %ecx,%ecx
    caut_inceput:
        cmp $64,%ecx
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
            call formatamIntevalu
            ret
    nam_gasit:
        movl $0,%ecx
        movl %ecx, inceput_interval
        movl %ecx,final_interval
        ret


formatamIntevalu:   #doar doua impartiri la 8
    movl inceput_interval,%eax
    xorl %edx,%edx
    movl $8,%ebx
    divl %ebx
    movl %eax,rand_actual
    movl %edx,inceput_interval
    xorl %edx,%edx
    movl final_interval,%eax
    divl %ebx
    movl %edx,final_interval
    ret

GET_BOUNDS:
#Citim aidiul de cautat si apoi apelam fct. gasireInterval
    call citire
    pushl var_citire
    call gasireInterval
    popl %ebx
    pushl final_interval
    pushl rand_actual
    pushl inceput_interval
    pushl rand_actual
    pushl $formatGet
    call printf
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    ret

afisare_memorie:
#Am pus un nume prea bun functiei ca sa mai explic in comentariu ce face
    xorl %ecx,%ecx #i-ul meu
    lea matrice,%edi
    inceput_for:    #iau fiecare element din matrice, daca reprezinta un aidi, ii caut marginile si le afisez.
        cmp $64,%ecx
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
        pushl rand_actual
        pushl inceput_interval
        pushl rand_actual
        pushl %eax
        pushl $formatInterval
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        
        movl rand_actual,%eax
        movl $8,%ebx
        xorl %edx,%edx
        mull %ebx
        addl final_interval,%eax
        movl %eax,%ecx
        incl %ecx
        jmp revenire

    am_ajuns_la_capat:
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
    pushl rand_actual
    pushl inceput_interval
    pushl final_interval
    call umplere
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    NU_EXISTA:
    call afisare_memorie
    ret

chemati_salvarea:
#Salvam toate aidiurile si size urile lor in doi vectori
    xorl %ecx,%ecx
    chem_for:
        cmp $64,%ecx
        jae termin_for
        
        lea matrice,%edi #iau aidiul
        xorl %eax,%eax
        movb (%edi,%ecx,1),%al
        movb %al,aidi
        pushl %ecx

        cmp $0,%eax #cazul in care aidi = 0
        je skip

        pushl %eax
        call gasireInterval #l-am pierdut pe ecx :(
        popl %eax

        movl final_interval,%ecx
        cmp $0,%ecx 
        jne memoram

        skip:
        popl %ecx
        incl %ecx
        jmp chem_for

    memoram:
        lea v_aidiuri,%edi
        xorl %eax,%eax
        xorl %ecx,%ecx
        movb aidi,%al
        movb nr_aidiuri,%cl
        movb %al,(%edi,%ecx,1) #aici am bagat aidiul

        lea v_sizeuri,%edi
        #calculam size-ul...
        movl final_interval,%eax
        subl inceput_interval,%eax
        incl %eax
        xorl %edx,%edx
        movl $8,%ebx
        mull %ebx   #acum am size-ul in biti in eax
        movl %eax,(%edi,%ecx,4)
        incl %ecx
        movb %cl,nr_aidiuri

        #acum ies de aici dar trb sa-l cresc pe ecx
        xorl %edx,%edx
        movl rand_actual,%eax
        mull %ebx   #inca am 8 in ebx
        addl final_interval,%eax
        movl %eax,%ecx
        popl %ebx
        pushl %ecx
        jmp skip

    termin_for:
    ret


afisez_vectorii:
    xorl %ecx,%ecx
    primulfor:
        xorl %edx,%edx
        movb nr_aidiuri,%dl
        cmp %edx,%ecx
        jge sadasdssdf  #scuze nu mai am inspiratie la etichete...
        pushl %ecx

        lea v_aidiuri,%edi
        xorl %eax,%eax
        movb (%edi,%ecx,1),%al
        call afisare

        lea v_sizeuri,%edi
        popl %ecx
        movl (%edi,%ecx,4),%eax
        pushl %ecx
        call afisare

        popl %ecx
        incl %ecx
        jmp primulfor

    sadasdssdf:
    ret

DEFRAGMENTATION:
#memorez tot ce am in 2 vectori, resetez matricea, pun in aidi si spatiu aidi ce am si dau add din nou
#literalmente clonare, dupa vine discutia filozofica, mai este aceeasi matrice oare? Barca lui Thesseus
    call chemati_salvarea
    call afisez_vectorii
    pushl $newLine
    call printf
    popl %ebx

    #mai trb doar sa faci partea de ADD. Am incercat dar habar n-am de ce nu merge :/

    ret

.global main
main:
    call init_matrice
    call the_real_main
    call afisare_matrice
    call DEFRAGMENTATION
    call afisare_matrice

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