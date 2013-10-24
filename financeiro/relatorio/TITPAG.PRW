/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 29/07/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de titulos a pagar                            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function TITPAG()
	private aOrd    := {"Vencimento","Titulo","Fornecedor","Baixa"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "TITPAG"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := ""
	private ContFun := 0
	private cString := "SE2"
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
	private cForIni	:= ""
	private cForFin	:= ""
	private cBorIni := ""
	private cBorFin := ""
	private cPerIni := ""
	private cPerFin := ""
	private cBanIni := ""
	private cBanFin := ""
	private nBaixados := 0
	private cBaixaIni := ""
	private cBaixaFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Vencimento de                                     ³
	//³ mv_par02 - Vencimento ate                                    ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
	//³ mv_par05 - Bordero de                                        ³
	//³ mv_par06 - Bordero ate                                       ³
	//³ mv_par07 - Prioridade de                                     ³
	//³ mv_par08 - Prioridade ate                                    ³
	//³ mv_par09 - Banco de                                          ³
	//³ mv_par10 - Banco ate                                         ³
	//³ mv_par11 - Titulos Baixados (1-Nao/2-Sim)                    ³
	//³ mv_par12 - Baixa de                                          ³
	//³ mv_par13 - Baixa ate                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cVenIni	:= DToS(mv_par01)
	cVenFin := DToS(mv_par02)
	cForIni := mv_par03
	cForFin := mv_par04
	cBorIni := mv_par05
	cBorFin := mv_par06
	cPerIni := mv_par07
	cPerFin := mv_par08
	cBanIni := mv_par09
	cBanFin := mv_par10
	nBaixados := mv_par11
	cBaixaIni := DToS(mv_par12)
	cBaixaFin := DToS(mv_par13)
	
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
	local cSigla := ""
	local cTed := ""
	local aBordero := {}
	local aPrioridade := {}
	local aBanco := {}
	local aDocumento := {}
	
	cQry := "select E2_BAIXA, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_EMISSAO, E2_CR, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_SALDO, datediff(day, E2_VENCTO, getdate()) as DIFF, E2_BANCO, E2_BORDERO, PRIORID = case when E2_PRIORID <> '' then E2_PRIORID else '99' end, E2_NUMBCO, E2_BCOPAG, E2_FATPREF, E2_FATURA "
	cQry += "from "+RetSqlName("SE2")+" "
	
	if nBaixados == 2
		cQry += "where (E2_BAIXA between '"+cBaixaIni+"' and '"+cBaixaFin+"') and (E2_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (E2_BORDERO between '"+cBorIni+"' and '"+cBorFin+"') and (E2_PRIORID between '"+cPerIni+"' and '"+cPerFin+"') and (E2_BANCO between '"+cBanIni+"' and '"+cBanFin+"') and D_E_L_E_T_ <> '*' "
		cDesc1 := "TITULOS PAGOS"
		Cabec2 := "VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO  DOCUMTO           BCO                 VALOR  DD"
	else
		cQry += "where (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E2_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (E2_BORDERO between '"+cBorIni+"' and '"+cBorFin+"') and (E2_PRIORID between '"+cPerIni+"' and '"+cPerFin+"') and (E2_BANCO between '"+cBanIni+"' and '"+cBanFin+"') and E2_TIPO <> 'PR' and (E2_BAIXA = '' or (E2_BAIXA <> '' and E2_SALDO > 0)) and D_E_L_E_T_ <> '*' "
		cDesc1 := "TITULOS A PAGAR"
		Cabec2 := "VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO BANCO                                   VALOR DD"
	endif
	
	if nOrdem == 1
		cQry += "order by E2_VENCREA, PRIORID, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA"
	elseif nOrdem == 2
		cQry += "order by PRIORID, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_VENCREA"
	elseif nOrdem == 3
		cQry += "order by PRIORID, E2_FORNECE, E2_LOJA, E2_VENCREA, E2_PREFIXO, E2_NUM, E2_PARCELA"
	elseif nOrdem == 4
		cQry += "order by E2_BAIXA, PRIORID, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO BANCO                                  VALOR  DD
//	VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO  DOCUMTO           BCO                 VALOR  DD
//	99/99/99 99 99 AAAAAAAAAAAAAAAAAAAA AAA 999999999 999  AAA 99999 99/99/99 9999999    999999999999999   AAA      9,999,999,999.99  99
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		if TEMP->E2_TIPO == "NF " .and. SD1->(DbSeek(xFilial("SD1")+TEMP->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),.F.))
			if SD1->D1_LOCAL == "10" ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if nBaixados == 2
			if TEMP->E2_TIPO == "NDF"
				nValor := IIf(Empty(TEMP->E2_SALDO),TEMP->E2_VALOR,TEMP->E2_VALOR - TEMP->E2_SALDO) * -1
			else
				nValor := IIf(Empty(TEMP->E2_SALDO),TEMP->E2_VALOR,TEMP->E2_VALOR - TEMP->E2_SALDO)
			endif
		else
			if TEMP->E2_TIPO == "NDF"
				nValor := IIf(Empty(TEMP->E2_BAIXA),TEMP->E2_VALOR,TEMP->E2_SALDO) * -1
			else
				nValor := IIf(Empty(TEMP->E2_BAIXA),TEMP->E2_VALOR,TEMP->E2_SALDO)
			endif
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
		
		cSigla := IIf(SA6->(DbSeek(xFilial("SA6")+TEMP->E2_BCOPAG,.F.)),SA6->A6_SIGLA," ")
		cTed := ""
		
		if nBaixados == 2
			if Empty(TEMP->E2_NUMBCO)
				if Empty(TEMP->E2_FATURA)
					cQry := "select E5_DOCUMEN from "+RetSqlName("SE5")+" where E5_NUMERO = '"+TEMP->E2_NUM+"' and E5_PREFIXO = '"+TEMP->E2_PREFIXO+"' and D_E_L_E_T_ <> '*' "
				else
					cQry := "select E5_DOCUMEN from "+RetSqlName("SE5")+" where E5_NUMERO = '"+TEMP->E2_FATURA+"' and E5_PREFIXO = '"+E2_FATPREF+"' and D_E_L_E_T_ <> '*' "
				endif
				
				tcquery cQry new alias "CON1"
				
				DbSelectArea("CON1")
				
				@nLin,085 psay Left(CON1->E5_DOCUMEN,15)
				
				cTed := Left(CON1->E5_DOCUMEN,15)
				
				CON1->(DbCloseArea())
				DbSelectArea("TEMP")
			else
				@nLin,085 psay Left(TEMP->E2_NUMBCO,15)
			endif
			
			@nLin,103 psay cSigla
		else
			@nLin,084 psay Left(cBanco,10)
		endif
		
		@nLin,113 psay Transf(nValor,"@E 9,999,999,999.99")
		
		if nBaixados <> 2
			@nLin,130 psay Transf(TEMP->DIFF,"@E 99")
		endif
		
/*		if (nInd := AScan(aBordero,{|x| x[1] = TEMP->E2_BORDERO})) == 0
			AAdd(aBordero,{TEMP->E2_BORDERO,1,nValor})
		else
			aBordero[nInd][2] += 1
			aBordero[nInd][3] += nValor
		endif
		
		if (nInd := AScan(aPrioridade,{|x| x[1] = cPrioridade})) == 0
			AAdd(aPrioridade,{cPrioridade,1,nValor})
		else
			aPrioridade[nInd][2] += 1
			aPrioridade[nInd][3] += nValor
		endif
		
		if (nInd := AScan(aBanco,{|x| x[1] = TEMP->E2_BANCO})) == 0
			AAdd(aBanco,{TEMP->E2_BANCO,1,nValor,0,cBanco})
		else
			aBanco[nInd][2] += 1
			aBanco[nInd][3] += nValor
		endif*/
		
		if (nInd := AScan(aDocumento,{|x| x[1] = Left(IIf(Empty(cTed),TEMP->E2_NUMBCO,cTed),15) .and. x[2] = cSigla})) == 0
			AAdd(aDocumento,{Left(IIf(Empty(cTed),TEMP->E2_NUMBCO,cTed),15),cSigla,1,nValor})
		else
			aDocumento[nInd][3]++
			aDocumento[nInd][4] += nValor
		endif
		
		nTotItem++
		nTotValor += nValor
		nLin++
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L -----> ("+AllTrim(Str(nTotItem))+" MOVIMENTACOES)"
	@nLin,113 psay Transf(nTotValor,"@E 9,999,999,999.99")
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	
	Cabec2 := ""
	
/*	if !Empty(aBordero)
		nLin++
		
		U_SaltaFolha()
		Resumo(aBordero,1,1)
	endif*/
	
/*	if !Empty(aPrioridade)
		nLin++
		
		U_SaltaFolha()
		Resumo(aPrioridade,1,2)
	endif*/
	
/*	if !Empty(aBanco)
		nLin++
		
		U_SaltaFolha()
		Resumo(aBanco,5,3)
	endif*/
	
	if !Empty(aDocumento) .and. nBaixados == 2
		ASort(aDocumento,,,{|x,y| x[2]+x[1] <= y[2]+y[1]})
		
		nLin++
		nTotItem := 0
		nTotValor := 0
		
		U_SaltaFolha()
		
//		================== RESUMO DOCUMENTOS ===================
//		BANCO  DOCUMTO          MOVIMENT                   VALOR
//		AAA    999999999999999     99999        9,999,999,999.99
//		--------------------------------------------------------
//		T O T A L                  99999        9,999,999,999.99
//		========================================================
//		01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay "================== RESUMO DOCUMENTOS ==================="
		@++nLin,000 psay "BANCO  DOCUMTO          MOVIMENT                   VALOR"
		
		nLin++
		
		U_SaltaFolha()
		
		for i := 1 to Len(aDocumento)
			if !Empty(aDocumento[i][2])
				@nLin,000 psay Left(aDocumento[i][2],3)
				@nLin,007 psay Left(aDocumento[i][1],15)
				@nLin,027 psay Transf(aDocumento[i][3],"@E 99999")
				@nLin,040 psay Transf(aDocumento[i][4],"@E 9,999,999,999.99")
				
				nLin++
				nTotItem += aDocumento[i][3]
				nTotValor += aDocumento[i][4]
				
				U_SaltaFolha()
			endif
		next
		
		@nLin,000 psay "--------------------------------------------------------"
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "T O T A L"
		@nLin,027 psay Transf(nTotItem,"@E 99999")
		@nLin,040 psay Transf(nTotValor,"@E 9,999,999,999.99")
		
		@++nLin,000 psay "========================================================"
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function Resumo(aResumo,nOrd,nOpc)
	local nTotItem := 0
	local nTotValor := 0
	local nTotSaldo := 0
	
	aSort(aResumo,,,{|x,y| x[nOrd] <= y[nOrd]})
	
	do case
		case nOpc == 1
			@nLin,000 psay "==================== RESUMO BORDERO ===================="
			@++nLin,000 psay "BORDERO     MOVIMENT                               VALOR"
		case nOpc == 2
			@nLin,000 psay "=================== RESUMO PRIORIDADE =================="
			@++nLin,000 psay "PRIORIDADE  MOVIMENT                               VALOR"
		case nOpc == 3
			@nLin,000 psay "===================== RESUMO BANCO ====================="
			@++nLin,000 psay "BANCO       MOVIMENT                               VALOR"
	endcase
	
	nLin++
	
//	==================== RESUMO BORDERO ====================
//	BORDERO     MOVIMENT                               VALOR
//	99             99999                    9,999,999,999.99
//	--------------------------------------------------------
//	T O T A L      99999                    9,999,999,999.99
//	========================================================
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	for i := 1 to Len(aResumo)
		@nLin,000 psay Left(aResumo[i][nOrd],10)
		@nLin,015 psay Transf(aResumo[i][2],"@E 99999")
		@nLin,040 psay Transf(aResumo[i][3],"@E 9,999,999,999.99")
		
		nLin++
		nTotItem += aResumo[i][2]
		nTotValor += aResumo[i][3]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "--------------------------------------------------------"
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L"
	@nLin,015 psay Transf(nTotItem,"@E 99999")
	@nLin,040 psay Transf(nTotValor,"@E 9,999,999,999.99")
	
	@++nLin,000 psay "========================================================"
	
	nLin++
	
	U_SaltaFolha()
return