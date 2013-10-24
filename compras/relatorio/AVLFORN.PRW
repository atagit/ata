/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 05/05/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de avaliacao do fornecedor                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function AVLFORN()
	private aOrd    := {"Codigo","N. Fantasia"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "AVLFOR"
	private Cabec1  := "FORNECEDOR                              | ULT. COMP  | CRIT | PE. | QT. | ESP | ID. | CTF | TOTAL | STATUS"
	private Cabec2  := ""
	private cDesc1  := "AVALIACAO FORNECEDOR"
	private ContFun := 0
	private cString := "SA2"
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
	private cRdpLeg	:= "PE. - Prazo de Entrega | QT. - Quantidade | ESP - Especificacao | ID. - Identificacao | CTF - Certificado do Produto"
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cForIni := ""
	private cForFin := ""
	private cSituacao := ""
	private cCritico := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Fornecedor de                                     ³
	//³ mv_par02 - Fornecedor ate                                    ³
	//³ mv_par03 - Situacao                                          ³
	//³ mv_par04 - Forn. Critico                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cForIni := mv_par01
	cForFin := mv_par02
	cSituacao := mv_par03
	
	do case
		case mv_par04 == 1
			cCritico := "S"
		case mv_par04 == 2
			cCritico := "N"
		case mv_par04 == 3
			cCritico := "A"
	endcase
	
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
	local cCondicao := ""
	
	cQry := "select A2_COD, A2_LOJA, A2_NREDUZ, A2_ULTCOM, A2_AVPRZ, A2_AVIDENT, A2_AVESPEC, A2_AVQUANT, A2_AVCERTI, A2_AVALIAC, A2_CRITICO "
	cQry += "from "+RetSqlName("SA2")+" "
	cQry += "where (A2_COD between '"+cForIni+"' and '"+cForFin+"') and A2_MSBLQL = 2 and D_E_L_E_T_ <> '*' "
	
	do case 
		case nOrdem == 1
			cQry += "order by A2_COD, A2_LOJA"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, A2_COD, A2_LOJA"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	if !Empty(cSituacao)
		DbSelectArea("SX5")
		SX5->(DbGoTop())
		
		if SX5->(DbSeek(xFilial("SX5")+"ST"+cSituacao,.F.))
			cCondicao := "TEMP->A2_AVALIAC "+AllTrim(SX5->X5_DESCSPA)+" .and. TEMP->A2_AVALIAC "+AllTrim(SX5->X5_DESCENG)
		endif
	endif
	
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//FORNECEDOR                              | ULT. COMP  | CRIT | PE. | QT. | ESP | ID. | CTF | TOTAL | STATUS
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//          1         2         3         4         5         6         7         8         9        10
	
	while !TEMP->(Eof())
		if !Empty(cCondicao)
			if !(&(cCondicao)) ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if cCritico <> "A"
			if TEMP->A2_CRITICO <> cCritico ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		nLin++
		
		@nLin,000 psay TEMP->A2_COD+"/"+TEMP->A2_LOJA+" "+TEMP->A2_NREDUZ
		@nLin,042 psay U_ConvData(TEMP->A2_ULTCOM)
		@nLin,055 psay IIf(TEMP->A2_CRITICO == "S","SIM","NAO")
		@nLin,062 psay Transf(TEMP->A2_AVPRZ,"@R 9.9")
		@nLin,068 psay Transf(TEMP->A2_AVIDENT,"@R 9.9")
		@nLin,074 psay Transf(TEMP->A2_AVESPEC,"@R 9.9")
		@nLin,080 psay Transf(TEMP->A2_AVQUANT,"@R 9.9")
		@nLin,086 psay Transf(TEMP->A2_AVCERTI,"@R 9.9")
		@nLin,092 psay Transf(TEMP->A2_AVALIAC,"@R 9.9")
		
		do case
			case TEMP->A2_AVALIAC == 0
				cStatus := "NAO AVALIADO"
			case TEMP->A2_AVALIAC < 2
				cStatus := "DESQUALIFICADO"
			case TEMP->A2_AVALIAC < 3
				cStatus := "COM RESTRICAO"
			case TEMP->A2_AVALIAC < 4
				cStatus := "NORMAL"
			otherwise
				cStatus := "PREFERENCIAL"
		endcase
		
		@nLin,100 psay cStatus
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return