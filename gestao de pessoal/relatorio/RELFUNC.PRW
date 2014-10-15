/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de funcionarios                               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELFUNC()
	private aOrd    := {"Matricula","Nome"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELFUN"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "RELACAO DE FUNCIONARIOS"
	private cString := "SRA"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cMatDe := ""
	private cMatAte := ""
	private cFunDe := ""
	private cFunAte := ""
	private nExibirSal := 0
	private nExibirFun := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Matricula de                                      ³
	//³ mv_par02 - Matricula ate                                     ³
	//³ mv_par03 - Funcao de                                         ³
	//³ mv_par04 - Funcao ate                                        ³
	//³ mv_par05 - Exibir Salario (1-Nao/2-Sim)                      ³
	//³ mv_par06 - Exibir Funcionar. (1-Ambos/2-Ativos/3-Demitidos)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cMatDe := mv_par01
	cMatAte := mv_par02
	cFunDe := mv_par03
	cFunAte := mv_par04
	nExibirSal := mv_par05
	nExibirFun := mv_par06
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
	
	set device to screen
	
	if aReturn[5] == 1
		set printer to
		
		DbCommitAll()
		DbCloseArea()
		OurSpool(wnrel)
	else
		DbCloseArea()
	endif
	
	Ms_Flush()
return

static function Impr()
	do case
		case nExibirFun == 2
			cCondicao := "and RA_DEMISSA = '' "
		case nExibirFun == 3
			cCondicao := "and RA_DEMISSA <> '' "
		otherwise
			cCondicao := ""
	endcase
	cQry := "select RA_MAT, RA_NOME, RA_NUMCP, RA_SERCP, RJ_NREDUZ, RA_ADMISSA, RA_DEMISSA, RA_SALARIO, RA_HRSMES, RA_CATFUNC "
	cQry += "from "+RetSqlName("SRA")+" SRA inner join "+RetSqlName("SRJ")+" SRJ on (RA_CODFUNC = RJ_FUNCAO) "
	cQry += "where (RA_MAT between '"+cMatDe+"' and '"+cMatAte+"') and (RA_CODFUNC between '"+cFunDe+"' and '"+cFunAte+"') "+cCondicao+"and SRA.D_E_L_E_T_ <> '*' and SRJ.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by RA_MAT"
	else
		cQry += "order by RA_NOME, RA_MAT"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
//	   CODIGO | NOME                           | C.PROF/SERIE  | FUNCAO     | ADMISSAO | RESCISAO |     SAL. MENSAL
//	   999999   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   9999999/99999   AAAAAAAAAA   99/99/99   99/99/99    999,999,999.99
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	if nExibirSal == 1
		Cabec1  := "   CODIGO | NOME                           | C.PROF/SERIE  | FUNCAO     | ADMISSAO | RESCISAO"
	else
		Cabec1  := "   CODIGO | NOME                           | C.PROF/SERIE  | FUNCAO     | ADMISSAO | RESCISAO |     SAL. MENSAL"
	endif
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	nReg := 0
	nTotal := 0
	
	while !TEMP->(Eof())
		@nLin,003 psay TEMP->RA_MAT
		@nLin,012 psay TEMP->RA_NOME
		@nLin,045 psay TEMP->RA_NUMCP+"/"+TEMP->RA_SERCP
		@nLin,061 psay TEMP->RJ_NREDUZ
		@nLin,074 psay U_ConvData(RA_ADMISSA,"yy")
		@nLin,085 psay U_ConvData(RA_DEMISSA,"yy")
		
		if nExibirSal == 2
			if TEMP->RA_CATFUNC $ "P/E"
				nSalario := TEMP->RA_SALARIO
			else
				nSalario := TEMP->RA_SALARIO * TEMP->RA_HRSMES
			endif
			
			@nLin,097 psay Transf(nSalario,"@E 999,999,999.99")
			nTotal += nSalario
		endif
		
		nLin++
		nReg++
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin++
	
	@nLin,000 psay __PrtThinLine()
	
	nLin++
	
	@nLin,000 psay "TOTAL DE REGISTRO(S)  -->  "+AllTrim(Transf(nReg,"@R 999999"))
	
	if nExibirSal == 2
		@nLin,097 psay Transf(nTotal,"@E 999,999,999.99")
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return