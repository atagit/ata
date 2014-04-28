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
	private nArmaz10 := 1
	
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
	//³ mv_par14 - Armazem 10 (1-Nao/2-Sim/3-Todos)                  ³
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
	nArmaz10 := mv_par14
	
	if nBaixados == 2
		Processa({|| ImprPago()},"","Aguarde processando...",lAborta)
	else
		Processa({|| ImprAPagar()},"","Aguarde processando...",lAborta)
	endif
	
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

static function ImprPago()
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
	local nValPA := 0
	local nValNDF := 0
	local nValOUT := 0
	
	cDesc1 := "TITULOS PAGOS"
	Cabec1 := PadC("Periodo de "+U_ConvData(cBaixaIni)+" a "+U_ConvData(cBaixaFin),132)
	Cabec2 := "VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO  DOCUMTO           BCO                VALOR   DD"
	
//	cQry := "select E2_BAIXA, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_EMISSAO, E2_CR, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_SALDO, datediff(day, E2_VENCTO, getdate()) as DIFF, E2_BANCO, E2_BORDERO, PRIORID = case when E2_PRIORID <> '' then E2_PRIORID else '99' end, E2_NUMBCO, E2_BCOPAG, E2_FATPREF, E2_FATURA, E2_VALLIQ "
//	cQry += "from "+RetSqlName("SE2")+" "
	cQry := "select E2_BAIXA, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_EMISSAO, E2_CR, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_SALDO, datediff(day, E2_VENCTO, getdate()) as DIFF, E2_BANCO, E2_BORDERO, PRIORID = case when E2_PRIORID <> '' then E2_PRIORID else '99' end, E2_NUMBCO, E2_BCOPAG, E2_FATPREF, E2_FATURA, E2_VALLIQ, E5_VALOR, E5_NUMTED, E5_DATA, E5_NUMCHEQ, E5_TIPODOC, E5_DOCUMEN "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SE2")+" SE2 on (E5_NUMERO = E2_NUM and E5_PREFIXO = E2_PREFIXO and E5_PARCELA = E2_PARCELA and E5_FORNECE = E2_FORNECE and E5_LOJA = E2_LOJA and E5_TIPO = E2_TIPO) "
//	cQry += "where (E2_BAIXA between '"+cBaixaIni+"' and '"+cBaixaFin+"') and (E2_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (E2_BORDERO between '"+cBorIni+"' and '"+cBorFin+"') and (E2_PRIORID between '"+cPerIni+"' and '"+cPerFin+"') and (E2_BANCO between '"+cBanIni+"' and '"+cBanFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "where (E2_BAIXA between '"+cBaixaIni+"' and '"+cBaixaFin+"') and (E2_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (E2_BORDERO between '"+cBorIni+"' and '"+cBorFin+"') and (E2_PRIORID between '"+cPerIni+"' and '"+cPerFin+"') and (E2_BANCO between '"+cBanIni+"' and '"+cBanFin+"') and E5_TIPODOC in ('BA','VL','CP') and E5_TIPO not in ('','PA') and E2_FATFOR = '' and SE5.D_E_L_E_T_ <> '*' and SE2.D_E_L_E_T_ <> '*' "
	
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
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO  DOCUMTO           BCO                VALOR   DD
//	99/99/99 99 99 AAAAAAAAAAAAAAAAAAAA AAA 999999999 999  AAA 99999 99/99/99 9999999    999999999999999   AAA     9,999,999,999.99  999
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		if TEMP->E2_TIPO == "NF " .and. SD1->(DbSeek(xFilial("SD1")+TEMP->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),.F.)) .and. nArmaz10 < 3
			if nArmaz10 == 1
				if SD1->D1_LOCAL == "10" ; TEMP->(DbSkip()) ; loop ; endif
			else
				if SD1->D1_LOCAL <> "10" ; TEMP->(DbSkip()) ; loop ; endif
			endif
		endif
		
		if TEMP->E2_TIPO == "NDF"
//			nValor := IIf(Empty(TEMP->E2_SALDO),TEMP->E5_VALOR,TEMP->E5_VALOR - TEMP->E2_SALDO) * -1
			nValor := TEMP->E5_VALOR * -1
			nValNDF += nValor
		else
//			nValor := IIf(Empty(TEMP->E2_SALDO),TEMP->E2_VALLIQ,TEMP->E2_VALLIQ - TEMP->E2_SALDO)
			nValor := TEMP->E5_VALOR
			nValOUT += nValor
		endif
		
//		cBanco := IIf(SA6->(DbSeek(xFilial("SA6")+TEMP->E2_BANCO,.F.)),AllTrim(SA6->A6_NREDUZ)," ")
//		cSigla := IIf(SA6->(DbSeek(xFilial("SA6")+TEMP->E2_BCOPAG,.F.)),SA6->A6_SIGLA," ")
		cSigla := TEMP->E2_BCOPAG
		cPrioridade := IIf(TEMP->PRIORID == "99"," ",TEMP->PRIORID)
//		cTed := ""
		
		@nLin,000 psay U_ConvData(TEMP->E5_DATA,"yy")
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
		
/*		if Empty(TEMP->E2_NUMBCO)
			if Empty(TEMP->E2_FATURA)
				cQry := "select E5_NUMTED from "+RetSqlName("SE5")+" where E5_NUMERO = '"+TEMP->E2_NUM+"' and E5_PREFIXO = '"+TEMP->E2_PREFIXO+"' and D_E_L_E_T_ <> '*' "
			else
				cQry := "select E5_NUMTED from "+RetSqlName("SE5")+" where E5_NUMERO = '"+TEMP->E2_FATURA+"' and E5_PREFIXO = '"+E2_FATPREF+"' and D_E_L_E_T_ <> '*' "
			endif
			
			tcquery cQry new alias "CON1"
			
			DbSelectArea("CON1")
			
//			cTed := Left(CON1->E5_DOCUMEN,15)
			cTed := CON1->E5_NUMTED
			
			@nLin,085 psay cTed
			
			CON1->(DbCloseArea())
			DbSelectArea("TEMP")
		else
			@nLin,085 psay Left(TEMP->E2_NUMBCO,15)
		endif*/
		
/*		if !Empty(TEMP->E5_NUMTED)
			@nLin,085 psay "TD"+TEMP->E5_NUMTED
		elseif !Empty(TEMP->E5_NUMCHEQ)
			@nLin,085 psay "CH"+Left(TEMP->E5_NUMCHEQ,13)
		else
			@nLin,085 psay " "
		endif*/
		
		if TEMP->E5_TIPODOC == "CP"
			if Select("CON") <> 0
				CON->(DbCloseArea())
			endif
			
			cQry := "select E5_NUMTED, E5_NUMCHEQ, E5_BANCO "
			cQry += "from "+RetSqlName("SE5")+" "
			cQry += "where E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA = '"+RTrim(TEMP->E5_DOCUMEN)+"' and E5_TIPODOC = 'PA' and D_E_L_E_T_ <> '*' "
			
			tcquery cQry new alias "CON"
			
			DbSelectArea("CON")
			
			cNumDoc := IIf(!Empty(CON->E5_NUMTED),"TD"+CON->E5_NUMTED,Left("CH"+CON->E5_NUMCHEQ,15))
			cSigla := CON->E5_BANCO
			
			CON->(DbCloseArea())
			DbSelectArea("TEMP")
		elseif TEMP->E2_TIPO == "NDF"
			cNumDoc := "DEVOLUCAO"
			cSigla := "  "
		else
			if !Empty(TEMP->E5_NUMTED)
				cNumDoc := "TD"+TEMP->E5_NUMTED
			elseif !Empty(TEMP->E5_NUMCHEQ)
				cNumDoc := Left("CH"+TEMP->E5_NUMCHEQ,15)
			else
				cNumDoc := "  "
			endif
		endif
		
		cSigla := IIf(SA6->(DbSeek(xFilial("SA6")+cSigla,.F.)),SA6->A6_SIGLA," ")
		
		@nLin,085 psay cNumDoc
		@nLin,103 psay cSigla
		@nLin,111 psay Transf(nValor,"@E 9,999,999,999.99")
		
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
		
//		if !Empty(cNumDoc)
			if (nInd := AScan(aDocumento,{|x| x[1] = cNumDoc .and. x[2] = cSigla})) == 0
				AAdd(aDocumento,{cNumDoc,cSigla,1,nValor})
			else
				aDocumento[nInd][3]++
				aDocumento[nInd][4] += nValor
			endif
//		endif
		
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
	@nLin,111 psay Transf(nTotValor - nValNDF,"@E 9,999,999,999.99")
	
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
	
	nLin++
	
	U_SaltaFolha()
	
//	                                                  Devolucao: 9,999,999,999.99                     Total Geral: 9,999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin,050 psay "Devolucao:"
	@nLin,061 psay Transf(nValNDF,"@E 9,999,999,999.99")
	@nLin,098 psay "Total Geral:"
	@nLin,111 psay Transf(nTotValor - nValNDF,"@E 9,999,999,999.99")
	
	nLin++
	
	U_SaltaFolha()
	
	if !Empty(aDocumento)
		ASort(aDocumento,,,{|x,y| x[2]+x[1] <= y[2]+y[1]})
		
		nLin++
		nTotItem := 0
		nTotValor := 0
		nTotDevol := 0
		
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
//			if !Empty(aDocumento[i][2])
				@nLin,000 psay Left(aDocumento[i][2],3)
				@nLin,007 psay Left(aDocumento[i][1],15)
				@nLin,027 psay Transf(aDocumento[i][3],"@E 99999")
				@nLin,040 psay Transf(aDocumento[i][4],"@E 9,999,999,999.99")
				
				nLin++
				nTotItem += aDocumento[i][3]
				nTotValor += aDocumento[i][4]
				
				if Left(aDocumento[i][1],3) == "DEV"
					nTotDevol += aDocumento[i][4]
				endif
				
				U_SaltaFolha()
//			endif
		next
		
		@nLin,000 psay "--------------------------------------------------------"
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "T O T A L"
		@nLin,027 psay Transf(nTotItem,"@E 99999")
		@nLin,040 psay Transf(nTotValor - nTotDevol,"@E 9,999,999,999.99")
		
		@++nLin,000 psay "========================================================"
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function ImprAPagar()
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
	local nValPA := 0
	local nValNDF := 0
	local nValOUT := 0
	
	cDesc1 := "TITULOS A PAGAR"
	Cabec1 := PadC("Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin),132)
	Cabec2 := "VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO  BANCO                                VALOR   DD"
	
	cQry := "select E2_BAIXA, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_EMISSAO, E2_CR, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_SALDO, datediff(day, E2_VENCTO, getdate()) as DIFF, E2_BANCO, E2_BORDERO, PRIORID = case when E2_PRIORID <> '' then E2_PRIORID else '99' end, E2_NUMBCO, E2_BCOPAG, E2_FATPREF, E2_FATURA, E2_VALLIQ "
	cQry += "from "+RetSqlName("SE2")+" "
	cQry += "where (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E2_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (E2_BORDERO between '"+cBorIni+"' and '"+cBorFin+"') and (E2_PRIORID between '"+cPerIni+"' and '"+cPerFin+"') and (E2_BANCO between '"+cBanIni+"' and '"+cBanFin+"') and E2_TIPO <> 'PR' and (E2_BAIXA = '' or (E2_BAIXA <> '' and E2_SALDO > 0)) and D_E_L_E_T_ <> '*' "
	
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
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	VENCTO   BR PR FORNECEDOR           PRF NFISCAL   PARC TIP NATUR EMISSAO  PROTOCOLO  BANCO                                VALOR   DD
//	99/99/99 99 99 AAAAAAAAAAAAAAAAAAAA AAA 999999999 999  AAA 99999 99/99/99 9999999    AAA                        9,999,999,999.99  999
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		if TEMP->E2_TIPO == "NF " .and. SD1->(DbSeek(xFilial("SD1")+TEMP->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),.F.)) .and. nArmaz10 < 3
			if nArmaz10 == 1
				if SD1->D1_LOCAL == "10" ; TEMP->(DbSkip()) ; loop ; endif
			else
				if SD1->D1_LOCAL <> "10" ; TEMP->(DbSkip()) ; loop ; endif
			endif
		endif
		
		do case
			case TEMP->E2_TIPO == "NDF"
				nValor := IIf(Empty(TEMP->E2_BAIXA),TEMP->E2_VALOR,TEMP->E2_SALDO) * -1
				nValNDF += nValor
			case TEMP->E2_TIPO == "PA "
				nValor := IIf(Empty(TEMP->E2_BAIXA),TEMP->E2_VALOR,TEMP->E2_SALDO) * -1
				nValPA += nValor
			otherwise
				nValor := IIf(Empty(TEMP->E2_BAIXA),TEMP->E2_VALOR,TEMP->E2_SALDO)
				nValOUT += nValor
		endcase
		
/*		if TEMP->E2_TIPO == "NDF"
			nValor := IIf(Empty(TEMP->E2_BAIXA),TEMP->E2_VALOR,TEMP->E2_SALDO) * -1
		else
			nValor := IIf(Empty(TEMP->E2_BAIXA),TEMP->E2_VALOR,TEMP->E2_SALDO)
		endif*/
		
		cBanco := IIf(SA6->(DbSeek(xFilial("SA6")+TEMP->E2_BANCO,.F.)),AllTrim(SA6->A6_NREDUZ)," ")
		cPrioridade := IIf(TEMP->PRIORID == "99"," ",TEMP->PRIORID)
		
		@nLin,000 psay U_ConvData(TEMP->E2_VENCREA,"yy")
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
		@nLin,111 psay Transf(nValor,"@E 9,999,999,999.99")
		@nLin,129 psay Transf(TEMP->DIFF,"@E 999")
		
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
	@nLin,111 psay Transf(nTotValor - nValPA - nValNDF,"@E 9,999,999,999.99")
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	
	nLin++
	
	U_SaltaFolha()
	
//	Pagto. Antecipado: 9,999,999,999.99               Devolucao: 9,999,999,999.99                     Total Geral: 9,999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin,000 psay "Pagto. Antecipado:"
	@nLin,019 psay Transf(nValPA,"@E 9,999,999,999.99")
	@nLin,050 psay "Devolucao:"
	@nLin,061 psay Transf(nValNDF,"@E 9,999,999,999.99")
	@nLin,098 psay "Total Geral:"
	@nLin,111 psay Transf(nTotValor - nValPA - nValNDF,"@E 9,999,999,999.99")
	
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