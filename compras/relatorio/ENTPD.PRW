/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 23/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de pedido de compras                        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function ENTPD()
	private aOrd    := {"Prazo de Entrega","Fornecedor"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "ENTPD"
	private Cabec1  := "ENTREGA  | EMISSAO  | DIAS | FONECEDOR            | PEDIDO |          VALOR | PROJETO | NOTA FISCAL"
	private Cabec2  := ""
	private cDesc1  := "ENTREGA DOS PEDIDO DE COMPRA"
	private ContFun := 0
	private cString := "SC7"
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
	
	private cDtIni := ""
	private cDtFin := ""
	private cForIni := ""
	private cForFin := ""
	private cPedIni := ""
	private cPedFin := ""
	private cProIni := ""
	private cProFin := ""
	private cTipo := ""
	private cPCAberto := ""
	private nAtrasado := 0
	private nCritico := 0
	private nResProd := 0
	private aResumo := {0,0}
	private aProduto := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao PC de                                     ³
	//³ mv_par02 - Emissao PC ate                                    ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
	//³ mv_par05 - Pedido de                                         ³
	//³ mv_par06 - Pedido ate                                        ³
	//³ mv_par07 - Projeto de                                        ³
	//³ mv_par08 - Projeto ate                                       ³
	//³ mv_par09 - Tipo Relatorio (1-Sintetico/2-Analitico)          ³
	//³ mv_par10 - So PC Abertos (1-Nao/2-Sim)                       ³
	//³ mv_par11 - So Atrasados (1-Nao/2-Sim)                        ³
	//³ mv_par12 - So Criticos (1-Nao/2-Sim)                         ³
	//³ mv_par13 - Resumo Produtos (1-Nao/2-Sim)                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cForIni := mv_par03
	cForFin := mv_par04
	cPedIni := mv_par05
	cPedFin := mv_par06
	cProIni := mv_par07
	cProFin := mv_par08
	cTipo := Str(mv_par09,1)
	cPCAberto := Str(mv_par10,1)
	nAtrasado := mv_par11
	nCritico := mv_par12
	nResProd := mv_par13
	
	do case
		case cTipo+cPCAberto == "11"
			Processa({|| ImprSinN()},"","Aguarde processando...",lAborta)
		case cTipo+cPCAberto == "12"
			Processa({|| ImprSinS()},"","Aguarde processando...",lAborta)
		case cTipo+cPCAberto == "21"
			Processa({|| ImprAnaN()},"","Aguarde processando...",lAborta)
		case cTipo+cPCAberto == "22"
			Processa({|| ImprAnaS()},"","Aguarde processando...",lAborta)
	endcase
	
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

static function ImprSinN()
	local nCont := 0
	
//	cQry := "select C7_DATPRF, D1_EMISSAO, datediff(day,convert(datetime,C7_DATPRF,126),convert(datetime,D1_EMISSAO,126)) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ , C7_NUM, D1_DOC, D1_SERIE, C7_CLVL, sum(C7_TOTAL) as C7_TOTAL "
//	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SD1")+" SD1 on (SC7.C7_NUM = SD1.D1_PEDIDO and SC7.C7_ITEM = SD1.D1_ITEMPC) "
//	cQry += "	inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
//	cQry += "where (SC7.C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and SC7.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
//	cQry += "group by C7_DATPRF, D1_EMISSAO, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, D1_DOC, D1_SERIE, C7_CLVL "
	
	cQry := "select C7_DATPRF, D1_EMISSAO, datediff(day,convert(datetime,C7_DATPRF,126),convert(datetime,D1_EMISSAO,126)) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ , C7_NUM, D1_DOC, D1_SERIE, C7_CLVL, A2_CRITICO, sum(C7_TOTAL) as C7_TOTAL "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SD1")+" SD1 on (SC7.C7_NUM = SD1.D1_PEDIDO and SC7.C7_ITEM = SD1.D1_ITEMPC) "
	cQry += "	inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where (SC7.C7_DATPRF between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and SC7.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by C7_DATPRF, D1_EMISSAO, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, D1_DOC, D1_SERIE, C7_CLVL, A2_CRITICO "
	
	do case
		case nOrdem == 1
			cQry += "order by C7_DATPRF, D1_EMISSAO, A2_NREDUZ, C7_NUM"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, C7_DATPRF, D1_EMISSAO, C7_NUM"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	ProcRegua(TEMP->(RecCount()))
	
	Cabec1 := "ENTREGA  | EMISSAO  | DIAS | FONECEDOR            | PEDIDO |          VALOR | PROJETO | NOTA FISCAL"
	cCbcRef := PadC("Periodo de: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//ENTREGA  | EMISSAO  | DIAS | FONECEDOR            | PEDIDO |          VALOR | PROJETO | NOTA FISCAL
	//99/99/99   99/99/99   9999   AAAAAAAAAAAAAAAAAAAA   999999   999.999.999,99   999999    999999999-999
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	
	nTotal := 0
	
	while !TEMP->(Eof())
		if nAtrasado == 2
			if TEMP->DIAS <= 0 ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if nCritico == 2
			if TEMP->A2_CRITICO <> "S" ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
//		nLin++
		
		if TEMP->C7_FORNECE <> "000359"
			nValor := TEMP->C7_TOTAL
		else
			SF1->(MsSeek(xFilial("SF1")+TEMP->(D1_DOC+D1_SERIE+C7_FORNECE+C7_LOJA),.F.))
			
			nValor := SF1->F1_VALBRUT
		endif
		
		@nLin,000 psay U_ConvData(TEMP->C7_DATPRF,"yy")
		@nLin,011 psay U_ConvData(TEMP->D1_EMISSAO,"yy")
		@nLin,022 psay AllTrim(Str(TEMP->DIAS))
		@nLin,029 psay IIf(SA2->(DbSeek(xFilial("SA1")+TEMP->C7_FORNECE+TEMP->C7_LOJA,.F.)),SA2->A2_NREDUZ,"")
		@nLin,052 psay TEMP->C7_NUM
		@nLin,061 psay Transf(nValor,"@E 999,999,999.99")
		@nLin,078 psay Left(TEMP->C7_CLVL,6)
		@nLin,088 psay TEMP->D1_DOC+"-"+TEMP->D1_SERIE
		
		nCont++
		
		if TEMP->DIAS > 0
			aResumo[1] += 1
			aResumo[2] += TEMP->DIAS
		endif
		
		nLin++
		nTotal += nValor
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,044 psay "TOTAL"
	@nLin,061 psay Transf(nTotal,"@E 999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "REGISTRO(S): "+Transf(nCont,"@E 999,999")
	@nLin,030 psay "DIAS EM ATRASO: "+Transf(aResumo[2],"@E 999,999,999")
	@nLin,070 psay "MEDIA DE DIAS: "+Transf(aResumo[2] / aResumo[1],"@E 999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function ImprAnaN()
	local nCont := 0
	
//	cQry := "select C7_DATPRF, D1_EMISSAO, datediff(day,convert(datetime,C7_DATPRF,126),convert(datetime,D1_EMISSAO,126)) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, D1_DOC, D1_SERIE, C7_PRODUTO, C7_DESCRI, C7_CLVL, C7_QUANT, C7_TOTAL "
//	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SD1")+" SD1 on (SC7.C7_NUM = SD1.D1_PEDIDO and SC7.C7_ITEM = SD1.D1_ITEMPC) "
//	cQry += "		inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
//	cQry += "where (SC7.C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and SC7.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	
	cQry := "select C7_DATPRF, D1_EMISSAO, datediff(day,convert(datetime,C7_DATPRF,126),convert(datetime,D1_EMISSAO,126)) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, D1_DOC, D1_SERIE, C7_PRODUTO, C7_DESCRI, C7_CLVL, C7_QUANT, C7_TOTAL "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SD1")+" SD1 on (SC7.C7_NUM = SD1.D1_PEDIDO and SC7.C7_ITEM = SD1.D1_ITEMPC) "
	cQry += "		inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where (SC7.C7_DATPRF between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and SC7.C7_FORNECE <> '000359' and SC7.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "union all "
	cQry += "select distinct C7_DATPRF, D1_EMISSAO, datediff(day,convert(datetime,C7_DATPRF,126),convert(datetime,D1_EMISSAO,126)) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, D1_DOC, D1_SERIE, C7_PRODUTO, C7_DESCRI, C7_CLVL, C7_QUANT, C7_TOTAL "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SD1")+" SD1 on (SC7.C7_NUM = SD1.D1_PEDIDO) "
	cQry += "		inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where (SC7.C7_DATPRF between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and SC7.C7_FORNECE = '000359' and SC7.C7_ITEM = '0001' and SC7.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	
	do case
		case nOrdem == 1
			cQry += "order by C7_DATPRF, D1_EMISSAO, A2_NREDUZ, C7_NUM"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, C7_DATPRF, D1_EMISSAO, C7_NUM"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	ProcRegua(TEMP->(RecCount()))
	
	Cabec1 := "ENTREGA  | EMISSAO  | DIAS | FONECEDOR            | PEDIDO"
	Cabec2 := "           PRODUTO                                    | PROJETO |       QUANT |          VALOR | NOTA FISCAL"
	cCbcRef := PadC("Periodo de: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//ENTREGA  | EMISSAO  | DIAS | FONECEDOR            | PEDIDO
	//99/99/99   99/99/99   9999   AAAAAAAAAAAAAAAAAAAA   999999
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	
	//           PRODUTO                                    | PROJETO |       QUANT |          VALOR | NOTA FISCAL
	//           999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        999999    99999999.99   999.999.999,99   999999999-999
	//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10        11
	
	nTotGeral := 0
	
	while !TEMP->(Eof())
		nLin++
		cPedido := TEMP->C7_NUM
		nTotal := 0
		nQuant := 0
		
		if nAtrasado == 2
			if TEMP->DIAS < 0 ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		@nLin,000 psay U_ConvData(TEMP->C7_DATPRF,"yy")
		@nLin,011 psay U_ConvData(TEMP->D1_EMISSAO,"yy")
		@nLin,022 psay AllTrim(Str(TEMP->DIAS))
		@nLin,029 psay IIf(SA2->(DbSeek(xFilial("SA1")+TEMP->C7_FORNECE+TEMP->C7_LOJA,.F.)),SA2->A2_NREDUZ,"")
		@nLin,052 psay TEMP->C7_NUM
		
		if TEMP->C7_FORNECE <> "000359"
			while !TEMP->(Eof()) .and. cPedido == TEMP->C7_NUM
				nLin++
				
				U_SaltaFolha()
				
				@nLin,011 psay Left(TEMP->C7_PRODUTO,6)+" "+Left(TEMP->C7_DESCRI,35)
				@nLin,056 psay Left(TEMP->C7_CLVL,6)
				@nLin,066 psay Transf(TEMP->C7_QUANT,"@E 99999999.99")
				@nLin,080 psay Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")
				@nLin,097 psay TEMP->D1_DOC+"-"+TEMP->D1_SERIE
				
				if (nInd := AScan(aProduto,{|x| x[1] = TEMP->C7_PRODUTO})) == 0
					AAdd(aProduto,{TEMP->C7_PRODUTO,TEMP->C7_DESCRI,TEMP->C7_QUANT,TEMP->C7_TOTAL})
				else
					aProduto[nInd][3] += TEMP->C7_QUANT
					aProduto[nInd][4] += TEMP->C7_TOTAL
				endif
				
				nTotal += TEMP->C7_TOTAL
//				nQuant += TEMP->C7_QUANT
				nTotGeral += TEMP->C7_TOTAL
				
				IncProc()
				TEMP->(DbSkip())
			enddo
		else
			SC7->(MsSeek(xFilial("SC7")+cPedido,.F.))
			
			while !SC7->(Eof()) .and. SC7->C7_NUM == cPedido
				nLin++
				
				U_SaltaFolha()
				
				@nLin,011 psay Left(SC7->C7_PRODUTO,6)+" "+Left(SC7->C7_DESCRI,35)
				@nLin,056 psay Left(SC7->C7_CLVL,6)
				@nLin,066 psay Transf(SC7->C7_QUANT,"@E 99999999.99")
				@nLin,080 psay Transf(SC7->C7_TOTAL,"@E 999,999,999.99")
				@nLin,097 psay TEMP->D1_DOC+"-"+TEMP->D1_SERIE
				
				if (nInd := AScan(aProduto,{|x| x[1] = SC7->C7_PRODUTO})) == 0
					AAdd(aProduto,{SC7->C7_PRODUTO,SC7->C7_DESCRI,SC7->C7_QUANT,SC7->C7_TOTAL})
				else
					aProduto[nInd][3] += SC7->C7_QUANT
					aProduto[nInd][4] += SC7->C7_TOTAL
				endif
				
				nTotal += SC7->C7_TOTAL
//				nQuant += SC7->C7_QUANT
				nTotGeral += SC7->C7_TOTAL
				
				IncProc()
				SC7->(DbSkip())
			enddo
			
			TEMP->(DbSkip())
		endif
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,064 psay "TOTAL"
//		@nLin,066 psay Transf(nQuant,"@E 99999999.99")
		@nLin,080 psay Transf(nTotal,"@E 999,999,999.99")
		
		nLin++
		nCont++
		
		if TEMP->DIAS > 0
			aResumo[1] += 1
			aResumo[2] += TEMP->DIAS
		endif
		
		U_SaltaFolha()
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,056 psay "TOTAL Geral"
	@nLin,080 psay Transf(nTotGeral,"@E 999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "REGISTRO(S): "+Transf(nCont,"@E 999,999")
	@nLin,030 psay "DIAS EM ATRASO: "+Transf(aResumo[2],"@E 999,999,999")
	@nLin,070 psay "MEDIA DE DIAS: "+Transf(aResumo[2] / aResumo[1],"@E 999,999.99")
	
	if nResProd == 2
		Resumo()
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function ImprSinS()
	local nCont := 0
	
//	cQry := "select C7_DATPRF, datediff(day,convert(datetime,C7_DATPRF,126),getdate()) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ , C7_NUM, C7_CLVL, sum(C7_TOTAL) as C7_TOTAL, sum(C7_QUJE) as C7_QUJE "
//	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
//	cQry += "where (SC7.C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and C7_ENCER <> 'E' and C7_RESIDUO <> 'S' and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
//	cQry += "group by C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, C7_CLVL "
	
	cQry := "select C7_DATPRF, datediff(day,convert(datetime,C7_DATPRF,126),getdate()) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ , C7_NUM, C7_CLVL, sum(C7_TOTAL) as C7_TOTAL, sum(C7_QUJE) as C7_QUJE "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where (SC7.C7_DATPRF between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and C7_ENCER <> 'E' and C7_RESIDUO <> 'S' and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, C7_CLVL "
	
	do case
		case nOrdem == 1
			cQry += "order by C7_DATPRF, A2_NREDUZ, C7_NUM"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, C7_DATPRF, C7_NUM"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	ProcRegua(TEMP->(RecCount()))
	
	Cabec1 := "ENTREGA  | ATRASADO | FONECEDOR            | PEDIDO |          VALOR | PROJETO |     ENTREGUE"
	cCbcRef := PadC("Periodo de: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//ENTREGA  | ATRASADO | FONECEDOR            | PEDIDO |          VALOR | PROJETO |     ENTREGUE
	//99/99/99   0000       AAAAAAAAAAAAAAAAAAAA   999999   999.999.999,99   999999    999999999.99
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	
	nTotal := 0
	
	while !TEMP->(Eof())
		nLin++
		
		U_SaltaFolha()
		
		if nAtrasado == 2
			if TEMP->DIAS < 0 ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		@nLin,000 psay U_ConvData(TEMP->C7_DATPRF,"yy")
		@nLin,011 psay AllTrim(Str(TEMP->DIAS))
		@nLin,022 psay IIf(SA2->(DbSeek(xFilial("SA1")+TEMP->C7_FORNECE+TEMP->C7_LOJA,.F.)),SA2->A2_NREDUZ,"")
		@nLin,045 psay TEMP->C7_NUM
		@nLin,054 psay Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")
		@nLin,071 psay Left(TEMP->C7_CLVL,6)
		@nLin,081 psay IIf(TEMP->C7_QUJE > 0,Transf(TEMP->C7_QUJE,"@E 999999999.99"),"")
		
		nCont++
		nTotal += TEMP->C7_TOTAL
		
		if TEMP->DIAS > 0
			aResumo[1] += 1
			aResumo[2] += TEMP->DIAS
		endif
		
//		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,037 psay "TOTAL"
	@nLin,054 psay Transf(nTotal,"@E 999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "REGISTRO(S): "+Transf(nCont,"@E 999,999")
	@nLin,030 psay "DIAS EM ATRASO: "+Transf(aResumo[2],"@E 999,999,999")
	@nLin,070 psay "MEDIA DE DIAS: "+Transf(aResumo[2] / aResumo[1],"@E 999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function ImprAnaS()
	local nCont := 0
	
//	cQry := "select C7_DATPRF, datediff(day,convert(datetime,C7_DATPRF,126),getdate()) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, C7_PRODUTO, C7_DESCRI, C7_CLVL, C7_QUANT, C7_TOTAL, C7_QUJE "
//	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
//	cQry += "where (SC7.C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and C7_ENCER <> 'E' and C7_RESIDUO <> 'S' and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	
	cQry := "select C7_DATPRF, datediff(day,convert(datetime,C7_DATPRF,126),getdate()) as DIAS, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUM, C7_PRODUTO, C7_DESCRI, C7_CLVL, C7_QUANT, C7_TOTAL, C7_QUJE "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where (SC7.C7_DATPRF between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (SC7.C7_CLVL between '"+cProIni+"' and '"+cProFin+"') and C7_ENCER <> 'E' and C7_RESIDUO <> 'S' and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	
	do case
		case nOrdem == 1
			cQry += "order by C7_DATPRF, A2_NREDUZ, C7_NUM"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, C7_DATPRF, C7_NUM"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	ProcRegua(TEMP->(RecCount()))
	
	Cabec1 := "ENTREGA  | ATRASADO | FONECEDOR            | PEDIDO"
	Cabec2 := "           PRODUTO                                    | PROJETO |       QUANT |          VALOR |     ENTREGUE"
	cCbcRef := PadC("Periodo de: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//ENTREGA  | ATRASADO | FONECEDOR            | PEDIDO
	//           PRODUTO                                    | PROJETO |       QUANT |          VALOR |     ENTREGUE
	//99/99/99   9999       AAAAAAAAAAAAAAAAAAAA   999999
	//           999999                                       999999    99999999.99   999,999,999.99   999999999.99
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	
	nTotGeral := 0
	
	while !TEMP->(Eof())
		nLin++
		cPedido := TEMP->C7_NUM
		nTotal := 0
		nQuant := 0
		nEntregue := 0
		
		if nAtrasado == 2
			if TEMP->DIAS < 0 ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		@nLin,000 psay U_ConvData(TEMP->C7_DATPRF,"yy")
		@nLin,011 psay AllTrim(Str(TEMP->DIAS))
		@nLin,022 psay IIf(SA2->(DbSeek(xFilial("SA1")+TEMP->C7_FORNECE+TEMP->C7_LOJA,.F.)),SA2->A2_NREDUZ,"")
		@nLin,045 psay TEMP->C7_NUM
		
		while cPedido == TEMP->C7_NUM
			nLin++
			
			U_SaltaFolha()
			
			@nLin,011 psay Left(TEMP->C7_PRODUTO,6)+" "+Left(TEMP->C7_DESCRI,35)
			@nLin,056 psay Left(TEMP->C7_CLVL,6)
			@nLin,066 psay Transf(TEMP->C7_QUANT,"@E 99999999.99")
			@nLin,080 psay Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")
			@nLin,097 psay IIf(TEMP->C7_QUJE > 0,Transf(TEMP->C7_QUJE,"@E 999999999.99"),"")
			
			if (nInd := AScan(aProduto,{|x| x[1] = TEMP->C7_PRODUTO})) == 0
				AAdd(aProduto,{TEMP->C7_PRODUTO,TEMP->C7_DESCRI,TEMP->C7_QUANT,TEMP->C7_TOTAL})
			else
				aProduto[nInd][3] += TEMP->C7_QUANT
				aProduto[nInd][4] += TEMP->C7_TOTAL
			endif
			
			nTotal += TEMP->C7_TOTAL
			nTotGeral += TEMP->C7_TOTAL
			nQuant += TEMP->C7_QUANT
			nEntregue += TEMP->C7_QUJE
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,052 psay "TOTAL"
		@nLin,066 psay Transf(nQuant,"@E 99999999.99")
		@nLin,080 psay Transf(nTotal,"@E 999,999,999.99")
		@nLin,097 psay IIf(nEntregue > 0,Transf(nEntregue,"@E 999999999.99"),"")
		
		nLin++
		nCont++
		
		if TEMP->DIAS > 0
			aResumo[1] += 1
			aResumo[2] += TEMP->DIAS
		endif
		
		U_SaltaFolha()
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,056 psay "TOTAL"
	@nLin,080 psay Transf(nTotGeral,"@E 999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "REGISTRO(S): "+Transf(nCont,"@E 999,999")
	@nLin,030 psay "DIAS EM ATRASO: "+Transf(aResumo[2],"@E 999,999,999")
	@nLin,070 psay "MEDIA DE DIAS: "+Transf(aResumo[2] / aResumo[1],"@E 999,999.99")
	
	if nResProd == 2
		Resumo()
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function Resumo()
	nLin := 75
	
	ASort(aProduto,,,{|x,y| x[1] > y[1]})
	U_SaltaFolha()
	
	//* * * * *   R E S U M O   P O R   P R O D U T O   * * * * *
	//PRODUTO                                                    |       QUANT |          VALOR
	//999999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   99999999.99   999,999,999.99
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	
	nTotal := 0
	
	@nLin,000 psay PadC("* * * * *   R E S U M O   P O R   P R O D U T O   * * * * *",90)
	
	nLin += 2
	
	for n := 1 to Len(aProduto)
		@nLin,000 psay Left(aProduto[n][1],6)
		@nLin,008 psay Left(aProduto[n][2],50)
		@nLin,061 psay Transf(aProduto[n][3],"@E 99999999.99")
		@nLin,075 psay Transf(aProduto[n][4],"@E 999,999,999.99")
		
		nLin++
		nTotal += aProduto[n][4]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "TOTAL"
	@nLin,075 psay Transf(nTotal,"@E 999,999,999.99")
return