User Function Extenso(NU)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fun‡„o.: EXTENSO()                                                       ³
  ³ Sintaxe: cVAR := EXTENSO(<nNUMERO>,[cVAR1],[cVAR1p],[cVAR2],[cVAR2p])    ³
  ³          Onde, por exemplo:                                              ³
  ³              <nNUMERO> Numero a ser convertido em extenso (2 CASAS DEC.) ³
  ³              [cVAR1]  "real", "UFIR", etc. (unidade no singular)         ³
  ³              [cVAR1p] "reais", "UFIRS", etc. (unidade no singular)       ³
  ³              [cVAR2]  "centavo", "", etc. (segunda unidade no singular)  ³
  ³              [cVAR2p] "centavos", "", etc. (segunda unidade no plural)   ³
  ³              cVAR ser  o n£mero por extenso a ser retornado              ³
  ³ OBS....:  Se o programador enviar um parametro, os outros trˆs           ³
  ³          ser„o necess rios e n„o opcionais.                              ³
  ³           Caso n„o envie nenhum o padr„o ser  "real", etc.               ³
  ³ Autor..: Anderson Cardoso Silva                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

*** CHECAGEM DOS PARAMETROS PASSADOS A FUNCAO ***
IF PCOUNT() = 0
   return ""
ELSEIF PCOUNT() < 2
   cVAR1  := "real"
   cVAR1p := "reais"
   cVAR2  := "centavo"
   cVAR2p := "centavos"
ENDIF
cVAR1  := " " + CVAR1
cVAR1p := " " + CVAR1P
cVAR2  := " " + CVAR2
cVAR2p := " " + CVAR2P

* Unidades
U=ARRAY(10)
U[1]="um"; U[2]="dois"; U[3]="tres"; U[4]="quatro"; U[5]="cinco"
U[6]="seis"; U[7]="sete"; U[8]="oito"; U[9]="nove"

* Dez
DD=ARRAY(10)
DD[1]="onze"; DD[2]="doze"; DD[3]="treze"; DD[4]="quatorze"; DD[5]="quinze"
DD[6]="dezeseis"; DD[7]="dezesete"; DD[8]="dezoito"; DD[9]="dezenove"

* Dezenas
D=ARRAY(10)
D[1]="dez"; D[2]="vinte"; D[3]="trinta"; D[4]="quarenta"; D[5]="cinquenta"
D[6]="sessenta"; D[7]="setenta"; D[8]="oitenta"; D[9]="noventa"; D[10]="cem"

* Centenas
C=ARRAY(10)
C[1]="cento"; C[2]="duzentos"; C[3]="trezentos"; C[4]="quatrocentos"; C[5]="quinhentos"
C[6]="seiscentos"; C[7]="setecentos"; C[8]="oitocentos"; C[9]="novecentos"; C[10]="mil"

NU:=ALLTRIM( STR(NU,15,2) ); EX=""

IF VAL(NU) = INT( VAL(NU)) .and. (AT(".", NU)) = 0
   NU += ".00"
ENDIF

*** CASO O VALOR SEJA NULO ***
IF VAL(NU)=0
   EX="xxx nenhum valor xxx"
   RETURN (EX)
ENDIF

*** CONVERSAO PARA EXTENSO ***
LNU := LEN(NU)
aEX :={} // VETOR DAS PARTES DO EXTENSO (ESTARA' TRAS P/ FRENTE)

*** CENTAVOS ***
X1 := VAL(RIGHT(NU,2))
X2 := VAL( LEFT( ALLTRIM( STR(X1) ), 1) )
X3 := VAL( RIGHT( ALLTRIM( STR(X1) ), 1) )

IF X1 = 0
   EX := ""
ELSEIF X1 = 1
   EX := U[X1] + cVAR2
ELSEIF X1 < 10
   EX := U[X1] + cVAR2p
ELSEIF X1 >= 10 .AND. X1/10 = INT(X1/10)  // DE ROMBO
   EX := D[X2] + cVAR2p
ELSEIF X1 > 10 .AND. X1 < 20
   EX := DD[X3] + cVAR2p
ENDIF

IF X1 > 20
	IF !EMPTY(X3)
	   EX  := D[X2] + " e " + U[X3] + cVAR2p
	ENDIF
ENDIF
X1:=X2:=X3:=0 // PRECAUCAO
aADD(aEX, EX)  // 1

IF VAL(NU) < 0.99
   RETURN (EX)
ENDIF

*** REAIS ***

*** DEZENAS ***
X1 := INT( VAL( RIGHT(NU,5) ) )
X2 := VAL( LEFT( ALLTRIM( STR(X1) ), 1) )
X3 := VAL( RIGHT( ALLTRIM( STR(X1) ), 1) )
IF X1 = 0
   EX := ""
ELSEIF X1 = 1
   EX := U[X1] + cVAR1
   IF LEN(NU) >= 6
      EX := U[X1] + cVAR1p
   ENDIF
ELSEIF X1 < 10
   EX := U[X1] + cVAR1p
ELSEIF X1 >= 10 .AND. X1/10 = INT(X1/10)  // DE ROMBO
   EX := D[X2] + cVAR1p
ELSEIF X1 > 10 .AND. X1 < 20
   EX := DD[X3] + cVAR1p
ELSEIF X1 > 20
   EX  := D[X2] + " e " + U[X3] + cVAR1p
ENDIF
aADD(aEX, EX)      // 2
EX:=""
IF VAL(NU) < 99.99
   FOR H=LEN(aEX) TO 1 STEP -1
       CONC := ""
       IF H>=2
          IF !EMPTY( aEX[H-1] )
             CONC := " e "
          ENDIF
       ENDIF
       EX += aEX[H] + CONC
   NEXT
   RETURN (EX)
ENDIF
X1:=X2:=X3:=0 // PRECAUCAO

*** CENTENAS ***
X1 := INT( VAL( RIGHT(NU,6) ) )
X2 := VAL( LEFT( ALLTRIM( STR(X1) ), 1) )

IF X1 >= 100
   IF X1=100
      EX := "cem" + cVAR1p
   ELSEIF X1>100 .AND. X1/100 = INT(X1/100)  // DE ROMBO
      EX := C[X2] + cVAR1p
   ELSEIF X1 <= 999
      EX := C[X2]
   ENDIF
   aADD(aEX, EX)   // 3
   EX:=""
   IF VAL(NU) <= 999.99
      FOR H=LEN(aEX) TO 1 STEP -1
          CONC := ""
          IF H>=2
             IF !EMPTY( aEX[H-1] )
                CONC := " e "
             ENDIF
          ENDIF
          EX += aEX[H] + CONC
      NEXT
      RETURN (EX)
   ENDIF
   X1:=X2:=X3:=0 // PRECAUCAO
ENDIF


*** MILHARES ***

*** UNIDADES ***
IF LEN( ALLTRIM(NU) ) = 7
   X1 := RIGHT( ALLTRIM(NU), 7)
   X1 := VAL( LEFT( ALLTRIM( X1 ), 1 ) )
   IF X1 = 0
      EX := ""
   ELSEIF X1 = 1
      EX := U[X1] + " mil"
   ELSEIF X1 < 10
      EX := U[X1] + " mil"
   ENDIF
   aADD(aEX, EX)       // 4
   EX:=""
   IF VAL(NU) < 9999.99
      FOR H=LEN(aEX) TO 1 STEP -1
          CONC := ""
          IF H>=2
             IF H=4
                IF !EMPTY( aEX[H-1] )
                   CONC := ", "
                ENDIF
             ELSEIF !EMPTY( aEX[H-1] )
                CONC := " e "
             ENDIF
          ENDIF
          EX += aEX[H] + CONC
      NEXT
      RETURN (EX)
   ENDIF
   X1:=X2:=X3:=0 // PRECAUCAO
ENDIF

*** DEZENAS ***
X1 := RIGHT( ALLTRIM(NU), 8)
X1 := VAL( LEFT( ALLTRIM( X1 ), 2 ) )
X2 := VAL( LEFT( ALLTRIM( STR(X1) ), 1) )
X3 := VAL( RIGHT( ALLTRIM( STR(X1) ), 1) )
IF X1 = 0
   EX := ""
ELSEIF X1 < 10
   EX := U[X1] + " mil"
ELSEIF X1 >= 10 .AND. X1/10 = INT(X1/10)  // DE ROMBO
   EX := D[X2] + " mil"
ELSEIF X1 > 10 .AND. X1 < 20
   EX := DD[X3] + " mil"
ELSEIF X1 > 20
   EX  := D[X2] + " e " + U[X3] + " mil"
ENDIF
aADD(aEX, EX)  // 5
EX:=""
IF VAL(NU) < 99999.99
   FOR H=LEN(aEX) TO 1 STEP -1
       CONC := ""
       IF H>=2
          IF H=5 .OR. H=4
             IF !EMPTY( aEX[H-1] )
                CONC := ", "
             ENDIF
          ELSEIF !EMPTY( aEX[H-1] )
             CONC := " e "
          ENDIF
       ENDIF
       EX += aEX[H] + CONC
   NEXT
   RETURN (EX)
ENDIF
X1:=X2:=X3:=0 // PRECAUCAO

*** CENTENAS ***
X1 := INT( VAL( RIGHT(NU,9) ) )
X1 := VAL( LEFT( ALLTRIM( STR(X1) ), 3 ) )
X2 := VAL( LEFT( ALLTRIM( STR(X1) ), 1) )
FLAG:=0
IF X1=100
   EX := "cem" + " mil"
ELSEIF X1>100 .AND. X1/100 = INT(X1/100)  // DE ROMBO
   EX := C[X2] + " mil"
ELSE
   EX := C[X2]
   FLAG:=1
ENDIF
aADD(aEX, EX)   // 6
EX:=""
FOR H=LEN(aEX) TO 1 STEP -1
    CONC := ""
       IF H>=2
          IF H=6 .OR. H=5 .OR. H=4
             IF !EMPTY( aEX[H-1] ) .AND. FLAG=0
                CONC := ", "
             ELSE
                CONC := " e "
                FLAG:=0
             ENDIF
          ELSEIF !EMPTY( aEX[H-1] )
             CONC := " e "
          ENDIF
       ENDIF
    EX += aEX[H] + CONC
NEXT
RETURN (EX)
X1:=X2:=X3:=0 // PRECAUCAO

*** NOTE QUE A CONVERSAO S¢ VAI AT 999999.99 ***

RETURN (EX)