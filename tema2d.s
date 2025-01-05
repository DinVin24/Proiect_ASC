.data
    matrice: .space 1048576
    v_aidiuri: .space 256   #aici am toate aidiurile, fiecare element are 1Byte
    v_sizeuri: .space 1024  #aici am toate saizurile, fiecare elem. are 4Bytes
    nr_aidiuri: .byte 0   #asta-mi numara cate aidiuri am salvat
    folosesc_add: .long 1   #bool pt a sti daca folosesc ADD sau Defralalal
    are_puncte: .long 0   #bool pt a sti daca am puncte in numele fisierului
    inceput_interval: .space 4  #aceste doua variabile le folosesc la functia GET si DELETE
    final_interval: .space 4
    rand_actual: .space 4 #iar asta memoreaza randul pe care suntem
    var_citire: .space 4 #Variabila pt citire numere...
    var_citire_string: .space 512 #Variabile pt citire stringuri...
    spatiu_aidi: .space 4 #Variabila care va retine nr de blocuri-1
    aidi: .space 1 #Variabila care va retine aidiul citit
    aidi_fisier: .space 4 #Variabila care va retine aidiul returnat de open
    aidi_folder: .space 4 #Variabila care va retine aidiul de la folder
    formatPrintf: .asciz "%d "
    formatConcrete: .asciz "%d\n%d\n"
    formatInterval: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatGet: .asciz "((%d, %d), (%d, %d))\n"
    formatDebugging: .asciz "AIDI: %d    SPATIU: %d\n"
    formatString: .asciz "%ld"
    formatScanfString: .asciz "%s"
    formatPrintfString: .asciz "%s\n"
    formatPrintfDec: .asciz "%d\n"
    path_folder: .space 512
    #nume_fisier: .space 512
    newLine: .asciz "\n"
    slesh: .asciz "/"
    punctuletz: .asciz "."
    bafarcufisiere: .space 512
    souljaboytellem: .space 256     #Buffer nebun care tine informatii despre fiecare fisier din directory ul meu
                                    #De ce acest nume? voiam sa pun bafardefisiere dar era cam luat...
    catsacitit: .space 4
    stringuri_lipite: .space 1024 #Asta e folosita ca sa lipesc path_folder si nume_fisier impreuna
    OGFileDescriptor: .long 0     #fara niciun fel de discutii!
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
        cmp $4,%eax #ADICA DEFRAGALALAL
        je apelam_defralalala
	    cmp $5,%eax #ADICA CIMENT
	    je apelam_concrete

        revenim:
        popl %ecx
        loop startLoop
        ret
    apelam_add:
        movl $1,%ebx
        movl %ebx,folosesc_add
        call ADD_ID
        jmp revenim
    apelam_get:
        call GET_BOUNDS
        jmp revenim
    apelam_delete:
        call DELETE
        jmp revenim
    apelam_defralalala:
        xorl %ebx,%ebx
        movl %ebx,folosesc_add
        call DEFRAGMENTATION
        jmp revenim
    apelam_concrete:
	    call CONCRETE
	    jmp revenim
    ret

citire:
#Citim de la tast. un numar. Acesta ramane memorat in var_citire!!
    pushl $var_citire
    pushl $formatString
    call scanf
    popl %ebx
    popl %ebx
    ret

citire_string:
#Citim de la tast. un string. Acesta ramane memorat in var_citire_string!!
    pushl $var_citire_string
    pushl $formatScanfString
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
#tot pt debugging
    lea matrice,%edi
    xorl %ecx, %ecx
    forAfisare:
        cmp $1048576,%ecx
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
    movl $1024,%ebx
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
    movl $1048576,%edx
    xorl %ecx,%ecx
    xorl %eax,%eax
    lea matrice,%edi
    forInit:
        cmp %edx,%ecx
        jae gataForInit

        movb %al,(%edi,%ecx,1)

        incl %ecx
        jmp forInit
    gataForInit:
    ret

umplere:
#Umplu cu aidi de la un capat dat la altul!! push id,rand,inceput,final
    lea matrice,%edi
    xorl %edx,%edx
    movl $1024,%ebx
    movl 12(%esp),%eax      #Randul pe care suntem
    movl 8(%esp), %ecx      #INCEPUT
    mull %ebx
    movl 16(%esp),%ebx      #aidi
    movl 4(%esp),%edx       #FINAL
    incl %edx
    addl %eax,%ecx          #adun capetele cu i*1024, i=(0,1023)
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
    lea matrice,%edi #ma joc cu matricea
    movl spatiu_aidi,%eax
    xorl %edx,%edx
    movl $8,%ebx
    divl %ebx      #impart la 8
    cmp $0,%edx
    je decrementez  #doar daca spatiul %8 ==0
    GataDecrementarea:

    movl %eax,spatiu_aidi           #pastram dimensiunea efectiva in blocuri - 1
    xorl %eax, %eax
    xorl %ecx, %ecx
    xorl %edx, %edx
    movb aidi, %cl
    xorl %ebx, %ebx
    cautamAidiExistent:
        cmp $1048576, %ebx
        je GataCautareadeAidi
        movb (%edi, %ebx, 1), %al
        cmpb %al, %cl
        je Space_Unavailable
        incl %ebx
        jmp cautamAidiExistent

    GataCautareadeAidi:

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
        xorl %ebx,%ebx
        movb aidi,%bl
        pushl $0
        pushl $0
        pushl $0
        pushl $0
        pushl %ebx
        pushl $formatInterval
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        ret

cautam_spatiu:
#Returneaza 0 sau 1 in EAX daca n-/avem spatiu in matrice pt aidi
#Daca fumatul iti ia 9 ani din viata, as fi preferat sa fumez timp de 7 vieti decat sa scriu functia asta
    movl spatiu_aidi,%ecx
    cmp $1024,%ecx
    jae navemspatiu

    movl $1024,%ebx
    movl folosesc_add,%ecx
    cmp $1,%ecx
    je sari
    movl rand_actual,%ecx     #daca folosesc defragmentation incep cautarea dupa ultimul aidi adaugat, ca sa nu-mi stric ordinea
    forLinii:       #iterez linie cu linie, daca cumva ajung la final inseamna ca nu incape aidiul
        movl $1024,%ebx
        cmp %ebx,%ecx
        jge navemspatiu
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
    sari:
        xorl %ecx,%ecx
        jmp forLinii

verific_interval_gol:
#Functia asta ma ajuta la add, are ca parametri randul,inceput,final
#Returneaza 0/1 in EAX dupa caz.
    lea matrice,%edi
    movl $1024,%ebx
    xorl %edx,%edx
    movl 12(%esp),%eax      #Randul pe care suntem
    movl 8(%esp), %ecx      #INCEPUT
    mull %ebx
    movl 4(%esp),%edx       #FINAL
    movl %ecx, inceput_interval
    movl %edx, final_interval
    addl %eax,%ecx
    addl %eax,%edx
    incl %edx   #S-AR PUTEA SA NU MEARGA!! AM SCRIS ASTA PT CA LUAM DOAR 6/8 hope it doesnt bite me in the ass later...
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
        cmp $1048576,%ecx
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
        xorl %ecx, %ecx
        movl %ecx, rand_actual
        movl %ecx, inceput_interval
        movl %ecx,final_interval
        ret


formatamIntevalu:   #doar doua impartiri la 1024
    movl inceput_interval,%eax
    xorl %edx,%edx
    movl $1024,%ebx
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
        cmp $1048576,%ecx
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
        movl $1024,%ebx
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
        cmp $1048576,%ecx
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
        movl $1024,%ebx     #inmultesc randul cu 1024 ca sa stiu unde sunt in vector
        mull %ebx
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
    pushl $newLine
    call printf
    popl %ebx
    ret

DEFRAGMENTATION:
#memorez tot ce am in 2 vectori, resetez matricea, pun in aidi si spatiu aidi ce am si dau add din nou
#literalmente clonare, dupa vine discutia filozofica, mai este aceeasi matrice oare? Barca lui Theseus
    call init_vectori
    call chemati_salvarea
    call init_matrice
    xorl %ecx,%ecx
    xorl %eax,%eax
    movl %eax,rand_actual
    aldoileafor:
        xorl %edx,%edx
        movb nr_aidiuri,%dl
        cmp %edx,%ecx
        jae finalaldoileafor
        pushl %ecx

        xorl %eax,%eax
        lea v_aidiuri,%edi
        movb (%edi,%ecx,1),%al
        movb %al,aidi

        lea v_sizeuri,%edi
        movl (%edi,%ecx,4),%eax
        movl %eax,spatiu_aidi

        call fct_add

        popl %ecx
        incl %ecx
        jmp aldoileafor
    finalaldoileafor:
        ret

init_vectori:
#Mda cam trebuie sa-mi resetez vectorii dupa fiecare defralalalal
    #for de la 1 la 64 in care bag 0 in v_aidi (de ce 64 si nu 256? pt ca bag long-uri si nu bytes B)   )
    movl $64,%edx
    xorl %ecx,%ecx
    xorl %eax,%eax
    movb %al,nr_aidiuri
    lea v_aidiuri,%edi
    forprimul:
        cmp %edx,%ecx
        je foraldoilea
        movl %eax,(%edi,%ecx,4)
        incl %ecx
        jmp gataprimu

    gataprimu:
    movl $256,%edx
    xorl %ecx,%ecx
    lea v_sizeuri,%edi
    foraldoilea:
        cmp %edx,%ecx
        je gatatotu

        movl %eax,(%edi,%ecx,4)

        incl %ecx
        jmp foraldoilea

    gatatotu:
    ret

verifica_puncte:
#Vedem daca numele fisierului este . sau .. pentru ca am inteles ca astea nu sunt bune?
    xorl %eax, %eax
    movb (%edi), %al
    lea punctuletz, %esi
    xorl %ecx, %ecx
    movb (%esi), %cl
    cmpb %al, %cl
    jne nuEstePunct

    verificamSingurPunct:
        # pushl %eax
        # pushl %ecx
        # pushl %edx
        # pushl %edi
        # pushl $formatPrintfString
        # call printf
        # popl %edi
        # popl %edi
        # popl %edx
        # popl %ecx
        # popl %eax
        incl %edi
        movb (%edi), %al
        cmpb $0, %al
        je esteSingurPunct
        jmp verificamDouaPuncte

    esteSingurPunct:
        movl $1, are_puncte
        ret

    verificamDouaPuncte:
        movb (%edi), %al
        cmpb %al, %cl
        je maiVerificamDouaPuncte
        jmp nuEstePunct

    maiVerificamDouaPuncte:
        incl %edi
        movb (%edi), %al
        cmpb $0, %al
        je chiarEsteDouaPuncte
        jmp nuEstePunct

    chiarEsteDouaPuncte:
        movl $1, are_puncte
        ret

    nuEstePunct:
        movl $0, are_puncte
        ret

construiestePathul:
# Practic face din folder path si numele fisierului un singur path (pt a-l folosi la open)
    #mai intai golim stringuri_lipite daca are ceva in el
    xorl %eax, %eax
    lea stringuri_lipite, %ebx
    stergelBine:
        movb (%ebx), %al
        cmpb $0, %al
        je continuaConstructia
        xorl %eax, %eax
        movb %al, (%ebx)
        incl %ebx
        jmp stergelBine

    continuaConstructia:
    lea stringuri_lipite, %ebx
    lea path_folder, %esi
    xorl %eax, %eax
    copiazaNumeFolder:
        movb (%esi), %al
        movb %al, (%ebx)
        incl %esi
        incl %ebx
        cmpb $0, %al
        jne copiazaNumeFolder

    decl %ebx

    copiazaNumeFisier:
        movb (%edi), %al
        movb %al, (%ebx)
        incl %edi
        incl %ebx
        cmpb $0, %al
        jne copiazaNumeFisier

    ret


CONCRETE:
# Deci, ce face concrete? Nici eu nu as putea explica...
    call citire_string
    lea path_folder, %edi
    lea var_citire_string, %esi
    xorl %eax, %eax
    # Initializam path ul de la folder
    forpath:
        movb (%esi), %al
        movb %al, (%edi)
        incl %esi
        incl %edi
        cmpb $0, %al
        jne forpath

    # Acum verificam daca se termina cu / (cred ca asa e mai bine si in alt mod imi e lene)
    curatarea:
    decl %edi
    decl %edi
    lea slesh, %ebx
    xorl %eax, %eax
    xorl %ecx, %ecx
    movb (%ebx), %al
    movb (%edi), %cl
    cmpb %al, %cl       #Daca path-ul nare slesh la final, ii punem noi unul
    jne repara_pathul
    gatacuratarea:      #De aici avem un path corespunzator. N-ar fi fost nevoie de atata scris daca aveam exemplu in enunt :(

    #pushl $path_folder  #Debugging, afisam pe ecran ca am inteles ce director cautam
    #pushl $formatPrintfString
    #call printf
    #popl %ebx
    #popl %ebx

    # Hai sa deschidem folderul!!!! XD
    movl $5, %eax
    lea path_folder, %ebx
    movl $0, %ecx 
    int $0x80

    cmpl $0, %eax
    jle amMuscatDeConcrete

    movl %eax, aidi_folder
    
    #Folosim un getdents frumos, foarte specific numele. Get Dentists...
    deschidemFolderu:

    movl $141, %eax
    movl aidi_folder, %ebx
    lea bafarcufisiere, %ecx    #aici am despre tot de la toti
    movl $256, %edx
    int $0x80

    cmpl $0, %eax #Daca ceva nu a mers bine sau s-a terminat folderu, la revedere ^~^
    jle amMuscatDeConcrete

    movl %eax, catsacitit
    lea bafarcufisiere, %edi

    addl $10, %edi # Asa ajungem la numele fisierului
    neJucamCuFisierul:
        movl %edi, %ebx
        call verifica_puncte
        movl %ebx, %edi
        movl $1, %eax
        cmpl %eax, are_puncte
        je sariLaUrmatorul

        movl %edi, %ecx
        call construiestePathul
        movl %ecx, %edi

        #lea stringuri_lipite, %ecx  
        #pushl %ecx                          #SCOATE COMENTARIILE DACA VR SA VEZI FILE_PATH
        #pushl $formatPrintfString
        #call printf
        #popl %ebx
        #popl %ebx

        # Deschidem si fisierul x 3
        movl $5, %eax
        lea stringuri_lipite, %ebx
        movl $0, %ecx
        int $0x80
        movl %eax,OGFileDescriptor

        xorl %edx, %edx     #Aici ne batem joc de descriptor, il reducem la o forma mai mica...
        movl $255, %ecx
        divl %ecx
        incl %edx
        movl %edx, aidi

        # Luam marimea fisierului (in bytes!!)
        movl $106, %eax
        lea stringuri_lipite, %ebx
        lea souljaboytellem, %ecx
        int $0x80

        # Impartim la 1024 ca sa aflam kB
        lea souljaboytellem, %ecx
        movl 20(%ecx), %eax # s-ar putea sa nu mearga!!!!
        movl $1024, %ecx
        xorl %edx, %edx
        divl %ecx
        movl %eax, spatiu_aidi


        push %eax
        push %ecx
        push %ebx
        push %edx
        push %esi
        push %edi

        call afisam_concrete

        jmp verificam_daca_este_vrednic
        este_vrednic:

        call fct_add
        jmp foarte_vrednic

        nu_este_vrednic:

        pushl $0
        pushl $0
        pushl $0
        pushl $0
        pushl aidi
        pushl $formatInterval
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        #call inchidem_fisierul
        foarte_vrednic:

        popl %edi
        popl %esi
        popl %edx
        popl %ebx
        popl %ecx
        popl %eax

        sariLaUrmatorul:
        xorl %eax, %eax
        movw -2(%edi), %ax
        addl %eax, %edi
        movl catsacitit, %edx
        leal bafarcufisiere(%edx), %ebx
        cmpl %ebx, %edi
        jl neJucamCuFisierul
        jmp deschidemFolderu #aici de fapt vreau doar sa termin citirea din folder :v


    repara_pathul:
        incl %edi
        movb %al, (%edi)
        incl %edi
        movb $0, (%edi)
        jmp gatacuratarea

    amMuscatDeConcrete:
    # Ma dor dintii :( auagshahfasdja
        movl $6,%eax
        movl aidi_folder,%ebx
        int $0x80
        ret
    verificam_daca_este_vrednic:
        movl $9,%eax
        movl spatiu_aidi,%ebx
        cmp %ebx,%eax      #DACA EBX < 9 NU ESTE VREDNIC!
        ja nu_este_vrednic
        pushl aidi
        call gasireInterval
        popl %eax
        xorl %eax,%eax
        cmp final_interval,%eax #Daca deja avem acest aidi in matrice, nu-l mai bagam wtf
        jne nu_este_vrednic
        jmp este_vrednic

inchidem_fisierul:
    movl $6,%eax
    movl OGFileDescriptor,%ebx
    int $0x80
    ret 
afisam_concrete:
    pushl spatiu_aidi
    pushl aidi
    pushl $formatConcrete
    call printf
    popl %ebx
    popl %ebx
    popl %ebx
    ret

.global main
main:
    call init_matrice
    call the_real_main

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