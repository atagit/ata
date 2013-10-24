/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de titulos a receber                          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function TITREC()
	private aOrd    := {"Vencimento"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "TITREC"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "TITULOS A RECEBER"
	private ContFun := 0
	private cString := "SE1"
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
	
	private cVenIni	:= ""
	private cVenFin	:= ""
	private cCliIni	:= ""
	private cCliFin	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Vencimento de                                     ³
	//³ mv_par02 - Vencimento ate                                    ³
	//³ mv_par03 - Cliente de                                        ³
	//³ mv_par04 - Cliente ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cVenIni	:= DToS(mv_par01)
	cVenFin := DToS(mv_par02)
	cCliIni := mv_par03
	cCliFin := mv_par04
	
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
	local nTotItem := 0
	local nTotValor := 0
	local nTotSaldo := 0
	local cBanco := ""
	local cPrioridade := ""
	local aBordero := {}
	local aPrioridade := {}
	local aBanco := {}
	
	cQry := "select E1_BAIXA, E1_VENCREA, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_NATUREZ, E1_EMISSAO, E1_VALOR, E1_SALDO, datediff(day, E1_VENCTO, getdate()) as DIFF "
	cQry += "from "+RetSqlName("SE1")+" "
	cQry += "where (E1_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E1_CLIENTE between '"+cCliIni+"' and '"+cCliFin+"') and (E1_BAIXA = '' or (E1_BAIXA <> '' and E1_SALDO > 0)) and D_E_L_E_T_ <> '*' "
	cQry += "order by E1_VENCREA"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	DUPLICATA      PARC  EMISSAO   ATRASO
//	999999999-999  999   99/99/99  999 9,999,999,999.99 9,999,999,999.99 99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		if TEMP->E2_TIPO == "NDF"
			nValor := TEMP->E2_VALOR * -1
			nSaldo := TEMP->E2_SALDO * -1
		else
			nValor := TEMP->E2_VALOR
			nSaldo := TEMP->E2_SALDO
		endif
		
		cBanco := IIf(SA6->(DbSeek(xFilial("SA6")+TEMP->E2_BANCO,.F.)),AllTrim(SA6->A6_NREDUZ)," ")
		cPrioridade := IIf(TEMP->PRIORID == "99"," ",TEMP->PRIORID)
		
		@nLin,000 psay U_ConvData(IIf(nBaixados == 2,TEMP->E2_BAIXA,TEMP->E2_VENCREA),"yy")
		@nLin,009 psay TEMP->E2_BORDERO
		@nLin,012 psay cPrioridade
		@nLin,015 psay TEMP->E2_NOMFOR
		@nLin,036 psay TEMP->E2_PREFIXO
		@nLin,040 psay TEMP->E2_NUM
		@nLin,050 psay TEMP->E2_PARCELA
		@nLin,055 psay TEMP->E2_TIPO
		@nLin,059 psay Left(TEMP->E2_NATUREZ,5)
		@nLin,065 psay U_ConvData(TEMP->E2_EMISSAO,"yy")
		@nLin,074 psay Left(TEMP->E2_CR,7)
		@nLin,084 psay Left(cBanco,10)
		@nLin,096 psay Transf(nValor,"@E 9,999,999,999.99")
		@nLin,113 psay Transf(nSaldo,"@E 9,999,999,999.99")
		
		if nBaixados <> 2
			@nLin,130 psay Transf(TEMP->DIFF,"@E 99")
		endif
		
		if (nInd := AScan(aBordero,{|x| x[1] = TEMP->E2_BORDERO})) == 0
			AAdd(aBordero,{TEMP->E2_BORDERO,1,nValor,nSaldo})
		else
			aBordero[nInd][2] += 1
			aBordero[nInd][3] += nValor
			aBordero[nInd][4] += nSaldo
		endif
		
		if (nInd := AScan(aPrioridade,{|x| x[1] = cPrioridade})) == 0
			AAdd(aPrioridade,{cPrioridade,1,nValor,nSaldo})
		else
			aPrioridade[nInd][2] += 1
			aPrioridade[nInd][3] += nValor
			aPrioridade[nInd][4] += nSaldo
		endif
		
		if (nInd := AScan(aBanco,{|x| x[1] = TEMP->E2_BANCO})) == 0
			AAdd(aBanco,{TEMP->E2_BANCO,1,nValor,nSaldo,cBanco})
		else
			aBanco[nInd][2] += 1
			aBanco[nInd][3] += nValor
			aBanco[nInd][4] += nSaldo
		endif
		
		nTotItem++
		nTotValor += nValor
		nTotSaldo += nSaldo
		nLin++
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L -----> ("+AllTrim(Str(nTotItem))+" MOVIMENTACOES)"
	@nLin,096 psay Transf(nTotValor,"@E 9,999,999,999.99")
	@nLin,113 psay Transf(nTotSaldo,"@E 9,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	
	if !Empty(aBordero) .or. !Empty(aPrioridade) .or. !Empty(aBanco)
		Cabec1 := PadC("Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin),132)
		Cabec2 := ""
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	endif
	
	if !Empty(aBordero)
		nLin++
		
		U_SaltaFolha()
//		Bordero(aBordero)
		Resumo(aBordero,1,1)
	endif
	
	if !Empty(aPrioridade)
		nLin++
		
		U_SaltaFolha()
//		Prioridade(aPrioridade)
		Resumo(aPrioridade,1,2)
	endif
	
	if !Empty(aBanco)
		nLin++
		
		U_SaltaFolha()
//		Banco(aBanco)
		Resumo(aBanco,5,3)
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return

static function Resumo(aResumo,nOrd,nOpc)
	local nTotItem := 0
	local nTotValor := 0
	local nTotSaldo := 0
	
	aSort(aResumo,,,{|x,y| x[nOrd] <= y[nOrd]})
	
	do case
		case nOpc == 1
			@nLin,000 psay "==================== RESUMO BORDERO ===================="
			@++nLin,000 psay "BORDERO     MOVIMENT             VALOR         VALOR LIQ"
		case nOpc == 2
			@nLin,000 psay "=================== RESUMO PRIORIDADE =================="
			@++nLin,000 psay "PRIORIDADE  MOVIMENT             VALOR         VALOR LIQ"
		case nOpc == 3
			@nLin,000 psay "===================== RESUMO BANCO ====================="
			@++nLin,000 psay "BANCO       MOVIMENT             VALOR         VALOR LIQ"
	endcase
	
	nLin++
	
//	==================== RESUMO BORDERO ====================
//	BORDERO     MOVIMENT             VALOR         VALOR LIQ
//	99             99999  9,999,999,999.99  9,999,999,999.99
//	--------------------------------------------------------
//	T O T A L      99999  9,999,999,999.99  9,999,999,999.99
//	========================================================
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	for i := 1 to Len(aResumo)
		@nLin,000 psay Left(aResumo[i][nOrd],10)
		@nLin,015 psay Transf(aResumo[i][2],"@E 99999")
		@nLin,022 psay Transf(aResumo[i][3],"@E 9,999,999,999.99")
		@nLin,040 psay Transf(aResumo[i][4],"@E 9,999,999,999.99")
		
		nLin++
		nTotItem += aResumo[i][2]
		nTotValor += aResumo[i][3]
		nTotSaldo += aResumo[i][4]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "--------------------------------------------------------"
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L"
	@nLin,015 psay Transf(nTotItem,"@E 99999")
	@nLin,022 psay Transf(nTotValor,"@E 9,999,999,999.99")
	@nLin,040 psay Transf(nTotSaldo,"@E 9,999,999,999.99")
	
	@++nLin,000 psay "========================================================"
	
	nLin++
	
	U_SaltaFolha()
return