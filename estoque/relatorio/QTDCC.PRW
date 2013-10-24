/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 21/02/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Quantidade de requisicao por centro de custos         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function QTDCC()
	private aOrd    := {"C. Custos"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "QTDCC"
	private Cabec1  := "C.CUSTOS                                                       QUANT       %"
	private Cabec2  := ""
	private cDesc1  := "QUANTIDADE REQUISICAO POR C.C."
	private ContFun := 0
	private cString := "SD3"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nTotGrp := {}
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cDataIni := ""
	private cDataFin := ""
	private nSubcentro := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Periodo de                                        ³
	//³ mv_par02 - Periodo ate                                       ³
	//³ mv_par03 - SubCentro (1-Ambos/2-Sim/3-Nao)                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDataIni := DToS(mv_par01)
	cDataFin := DToS(mv_par02)
	nSubcentro := mv_par03
	
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
	local nQuant := 0
	local nQtdSubCC := 0
	local nPercent := 0
	local aCCustos := {}
	
	cQry := "select D3_CC, CTT_DESC01, count(D3_QUANT) as D3_QUANT "
	cQry += "from "+RetSqlName("SD3")+" SD3 inner join "+RetSqlName("CTT")+" CTT on (D3_CC = CTT_CUSTO) "
	cQry += "where (D3_EMISSAO between '"+cDataIni+"' and '"+cDataFin+"') and SD3.D_E_L_E_T_ <> '*' and CTT.D_E_L_E_T_ <> '*' "
	cQry += "group by D3_CC, CTT_DESC01 "
	cQry += "order by D3_CC, CTT_DESC01"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if Left(TEMP->D3_CC,1) == "9" ; TEMP->(DbSkip()) ; loop ; endif
		
		if Left(TEMP->D3_CC,1) == "0"
			AAdd(aCCustos,{TEMP->D3_CC,TEMP->CTT_DESC01,TEMP->D3_QUANT})
			
			nQtdSubCC += TEMP->D3_QUANT
		else
			nQuant += TEMP->D3_QUANT
		endif
		
		TEMP->(DbSkip())
	enddo
	
	if nSubcentro <> 2
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		TEMP->(DbGoTop())
		
		nLin++
		
		while !TEMP->(Eof())
//			C.CUSTOS                                                       QUANT       %
//			9999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99999999.99  999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			if Left(TEMP->D3_CC,1) $ "0/9" ; TEMP->(DbSkip()) ; loop ; endif
			
			@nLin,000 psay Left(TEMP->D3_CC,4)
			@nLin,005 psay Left(TEMP->CTT_DESC01,50)
			@nLin,057 psay Transf(TEMP->D3_QUANT,"@E 99999999.99")
			@nLin,070 psay Transf((TEMP->D3_QUANT / nQuant) * 100,"@R 999.99")
			
			nPercent += (TEMP->D3_QUANT / nQuant) * 100
			nLin++
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		if nQuant > 0
			@nLin,057 psay Transf(nQuant,"@E 99999999.99")
			@nLin,070 psay Transf(nPercent,"@R 999.99")
		endif
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	endif
	
	if nSubcentro <> 3
		Cabec1 := "SUBCENTRO                                                      QUANT       %"
		nPercent := 0
		
		ProcRegua(Len(aCCustos))
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
		for i := 1 to Len(aCCustos)
//			SUBCENTRO                                                      QUANT       %
//			9999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99999999.99  999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay Left(aCCustos[i][1],4)
			@nLin,005 psay Left(aCCustos[i][2],50)
			@nLin,057 psay Transf(aCCustos[i][3],"@E 99999999.99")
			@nLin,070 psay Transf((aCCustos[i][3] / nQtdSubCC) * 100,"@R 999.99")
			
			nPercent += (aCCustos[i][3] / nQtdSubCC) * 100
			nLin++
			
			U_SaltaFolha()
			IncProc()
		next
		
		if nQtdSubCC > 0
			@nLin,057 psay Transf(nQtdSubCC,"@E 99999999.99")
			@nLin,070 psay Transf(nPercent,"@R 999.99")
		endif
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	endif
	
	TEMP->(DbCloseArea())
return