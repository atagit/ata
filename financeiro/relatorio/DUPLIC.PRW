/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de duplicatas                                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function DUPLIC()
	private aOrd    := {"Vencimento"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "DUPLIC"
	private Cabec1  := ""
	private Cabec2  := "                              PRESTACAO      PARC  EMISSAO   ATRASO                             VALOR"
	private cDesc1  := ""
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
	
	private cVenIni		:= ""
	private cVenFin		:= ""
	private nContas		:= 0
	private nTipo		:= 0
	private cCliIni		:= ""
	private cLojIni		:= ""
	private cForIni		:= ""
	private nTipoDupli	:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Vencimento de                                     ³
	//³ mv_par02 - Vencimento ate                                    ³
	//³ mv_par03 - Contas a (1-Pagar/2-Receber)                      ³
	//³ mv_par04 - Especifico (1-Sim/2-Nao)                          ³
	//³ mv_par05 - Cliente                                           ³
	//³ mv_par06 - Fornecedor                                        ³
	//³ mv_par07 - Tipo Duplic (1-Em Aberto/2-Vencido/3-Relacao)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cVenIni	:= DToS(mv_par01)
	cVenFin := DToS(mv_par02)
	nContas := mv_par03
	nTipo	:= mv_par04
	cCliIni := Left(mv_par05,6)
	cForIni := Left(mv_par06,6)
	nTipoDupli := mv_par07
	
	if nContas == 1
		cLojIni := Right(mv_par06,2)
	else
		cLojIni := Right(mv_par05,2)
	endif
	
	if nTipoDupli == 3
		if nTipo == 1			//Sim
			Processa({|| Impr()},"","Aguarde processando...",lAborta)
		else					//Nao
			Processa({|| Impr1()},"","Aguarde processando...",lAborta)
		endif
	else
		Processa({|| Impr2()},"","Aguarde processando...",lAborta)
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

//**************************************************************\\
// Impressao cliente/fornecedor especifico                      \\
//**************************************************************\\
static function Impr()
	local nSubTotVenc := 0
	local nSubTotGeral := 0
	local nSubQtdVenc := 0
	local nSubQtdGeral := 0
	
	if nContas == 1
		cQry := "select E2_FORNECE as CLIFOR, E2_LOJA as LOJA, E2_NOMFOR as NOMCLIFOR, E2_VENCREA as VENCREA, E2_NUM as NUM, E2_PREFIXO as PREFIXO, E2_PARCELA as PARCELA, E2_EMISSAO as EMISSAO, E2_VALOR as VALOR, E2_BAIXA as BAIXA, E2_SALDO as SALDO, datediff(day, E2_VENCREA, getdate()) as DIFF "
		cQry += "from "+RetSqlName("SE2")+" "
		cQry += "where (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and E2_FORNECE = '"+cForIni+"' and E2_LOJA = '"+cLojIni+"' and (E2_BAIXA = '' or (E2_BAIXA <> '' and E2_SALDO > 0)) and E2_TIPO <> 'PR' and D_E_L_E_T_ <> '*' "
		cQry += "order by E2_VENCREA"
		cDesc1 := "DUPLICATAS A PAGAR"
	else
		cQry := "select E1_CLIENTE as CLIFOR, E1_LOJA as LOJA, E1_NOMCLI as NOMCLIFOR, E1_VENCREA as VENCREA, E1_NUM as NUM, E1_PREFIXO as PREFIXO, E1_PARCELA as PARCELA, E1_EMISSAO as EMISSAO, E1_VALOR as VALOR, E1_BAIXA as BAIXA, E1_SALDO as SALDO, datediff(day, E1_VENCREA, getdate()) as DIFF "
		cQry += "from "+RetSqlName("SE1")+" "
		cQry += "where (E1_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and E1_CLIENTE = '"+cCliIni+"' and E1_LOJA = '"+cLojIni+"' and (E1_BAIXA = '' or (E1_BAIXA <> '' and E1_SALDO > 0)) and D_E_L_E_T_ <> '*' "
		cQry += "order by E1_VENCREA"
		cDesc1 := "DUPLICATAS A RECEBER"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	if nContas == 1
		cDef := "Fornecedor: "+AllTrim(TEMP->NOMCLIFOR)+" - "+TEMP->CLIFOR+"-"+TEMP->LOJA
//		Cabec1 := "Fornecedor: "+AllTrim(TEMP->NOMCLIFOR)+" - "+TEMP->CLIFOR+"-"+TEMP->LOJA+"     Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin)
	else
		cDef := "Cliente: "+AllTrim(TEMP->NOMCLIFOR)+" - "+TEMP->CLIFOR+"-"+TEMP->LOJA
//		Cabec1 := "Cliente: "+AllTrim(TEMP->NOMCLIFOR)+" - "+TEMP->CLIFOR+"-"+TEMP->LOJA+"        Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin)
	endif
	
	Cabec1 := cDef+Space(49 - Len(cDef))+"Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	                                                       VENCIMENTO: 99/99/99
//	                              PRESTACAO      PARC  EMISSAO   ATRASO                             VALOR
//	                              999999999-999  999   99/99/99  999                     9,999,999,999.99
//	                              SUBTOTAL VENCIMENTO:  0000                             9,999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		cVencimento := TEMP->VENCREA
		
		@nLin,055 psay "VENCIMENTO: "+U_ConvData(cVencimento,"yy")
		
		nLin += 2
		
		U_SaltaFolha()
		
		while !TEMP->(Eof()) .and. TEMP->VENCREA == cVencimento
			nValor := IIf(Empty(TEMP->BAIXA),TEMP->VALOR,TEMP->SALDO)
			
			@nLin,030 psay TEMP->NUM+"-"+TEMP->PREFIXO
			@nLin,045 psay TEMP->PARCELA
			@nLin,051 psay U_ConvData(TEMP->EMISSAO,"yy")
			@nLin,061 psay StrZero(TEMP->DIFF,3)
			@nLin,085 psay Transf(nValor,"@E 9,999,999,999.99")
			
			nLin++
			nSubTotVenc += nValor
			nSubTotGeral += nValor
			nSubQtdVenc++
			nSubQtdGeral++
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,030 psay "SUBTOTAL VENCIMENTO.: "
		@nLin,052 psay Transf(nSubQtdVenc,"@R 9999")
		@nLin,085 psay Transf(nSubTotVenc,"@E 9,999,999,999.99")
		
		nLin++
		nSubTotVenc := 0
		nSubQtdVenc := 0
		
		U_SaltaFolha()
		
		@nLin,000 psay __PrtThinLine()
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,030 psay "T O T A L  G E R A L: "
	@nLin,052 psay Transf(nSubQtdGeral,"@R 9999")
	@nLin,085 psay Transf(nSubTotGeral,"@E 9,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

//**************************************************************\\
// Impressao de todos os cliente/fornecedor                     \\
//**************************************************************\\
static function Impr1()
	local nSubTotVenc := 0
	local nSubTotGeral := 0
	local nSubQtdVenc := 0
	local nSubQtdGeral := 0
	
	if nContas == 1
		cQry := "select E2_FORNECE as CLIFOR, E2_LOJA as LOJA, E2_NOMFOR as NOMCLIFOR, E2_VENCREA as VENCREA, E2_NUM as NUM, E2_PREFIXO as PREFIXO, E2_PARCELA as PARCELA, E2_EMISSAO as EMISSAO, E2_VALOR as VALOR, E2_BAIXA as BAIXA, E2_SALDO as SALDO, datediff(day, E2_VENCREA, getdate()) as DIFF "
		cQry += "from "+RetSqlName("SE2")+" "
		cQry += "where (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E2_BAIXA = '' or (E2_BAIXA <> '' and E2_SALDO > 0)) and E2_TIPO <> 'PR' and D_E_L_E_T_ <> '*' "
		cQry += "order by E2_VENCREA, E2_NOMFOR"
		cDesc1 := "DUPLICATAS A PAGAR - TODOS OS FORNECEDORES"
		Cabec2  := "FORNECEDOR                      PRESTACAO      PARC  EMISSAO   ATRASO                             VALOR"
	else
		cQry := "select E1_CLIENTE as CLIFOR, E1_LOJA as LOJA, E1_NOMCLI as NOMCLIFOR, E1_VENCREA as VENCREA, E1_NUM as NUM, E1_PREFIXO as PREFIXO, E1_PARCELA as PARCELA, E1_EMISSAO as EMISSAO, E1_VALOR as VALOR, E1_BAIXA as BAIXA, E1_SALDO as SALDO, datediff(day, E1_VENCREA, getdate()) as DIFF "
		cQry += "from "+RetSqlName("SE1")+" "
		cQry += "where (E1_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E1_BAIXA = '' or (E1_BAIXA <> '' and E1_SALDO > 0)) and D_E_L_E_T_ <> '*' "
		cQry += "order by E1_VENCREA, E1_NOMCLI"
		cDesc1 := "DUPLICATAS A RECEBER - TODOS OS CLIENTES"
		Cabec2  := "CLIENTE                         PRESTACAO      PARC  EMISSAO   ATRASO                             VALOR"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Periodo de "+U_ConvData(cVenIni)+" a "+U_ConvData(cVenFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	VENCIMENTO: 99/99/99
//	CLIENTE                         PRESTACAO      PARC  EMISSAO   ATRASO                             VALOR
//	999999-99 AAAAAAAAAAAAAAAAAAAA  999999999-999  999   99/99/99  999                     9,999,999,999.99
//	                                SUBTOTAL VENCIMENTO:  0000                             9,999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		cVencimento := TEMP->VENCREA
		
		@nLin,000 psay PadC("VENCIMENTO: "+U_ConvData(cVencimento,"yy"),132)
		
		nLin += 2
		
		U_SaltaFolha()
		
		while !TEMP->(Eof()) .and. TEMP->VENCREA == cVencimento
			cNomCliFor := TEMP->NOMCLIFOR
			
			@nLin,000 psay TEMP->CLIFOR+"-"+TEMP->LOJA
			@nLin,010 psay TEMP->NOMCLIFOR
			
			while !TEMP->(Eof()) .and. TEMP->VENCREA == cVencimento .and. TEMP->NOMCLIFOR == cNomCliFor
				nValor := IIf(Empty(TEMP->BAIXA),TEMP->VALOR,TEMP->SALDO)
				
				@nLin,032 psay TEMP->NUM+"-"+TEMP->PREFIXO
				@nLin,047 psay TEMP->PARCELA
				@nLin,053 psay U_ConvData(TEMP->EMISSAO,"yy")
				@nLin,063 psay StrZero(TEMP->DIFF,3)
				@nLin,087 psay Transf(nValor,"@E 9,999,999,999.99")
				
				nLin++
				nSubTotVenc += nValor
				nSubTotGeral += nValor
				nSubQtdVenc++
				nSubQtdGeral++
				
				U_SaltaFolha()
				IncProc()
				TEMP->(DbSkip())
			enddo
		enddo
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,030 psay "SUBTOTAL VENCIMENTO.: "
		@nLin,052 psay Transf(nSubQtdVenc,"@R 9999")
		@nLin,085 psay Transf(nSubTotVenc,"@E 9,999,999,999.99")
		
		nLin++
		nSubTotVenc := 0
		nSubQtdVenc := 0
		
		U_SaltaFolha()
		
		@nLin,000 psay __PrtThinLine()
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,030 psay "T O T A L  G E R A L: "
	@nLin,052 psay Transf(nSubQtdGeral,"@R 9999")
	@nLin,085 psay Transf(nSubTotGeral,"@E 9,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

//**************************************************************\\
// Impressao de duplicatas em aberto ou vencidas                \\
//**************************************************************\\
static function Impr2()
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	if nContas == 1
		cQry := "select E2_VENCREA as VENC, E2_NUM as NUM, E2_PREFIXO as PREF, E2_PARCELA as PARC, E2_EMISSAO as EMISSAO, E2_TIPO as TIPO, E2_CR as CR, E2_BCOPAG as BCOPAG, E2_SALDO as VALOR, E2_BANCO as BCOCOB, E2_FORNECE as FORCLI, E2_LOJA as LOJA "
		cQry += "from "+RetSqlName("SE2")+" "
//		cQry += "where "+IIf(nTipo == 1,"E2_FORNECE = '"+cForIni+"' and E2_LOJA = '"+cLojIni+"' and ","")+"E2_BAIXA = ''"+IIf(nTipoDupli == 2," and E2_VENCREA <= '"+DToS(dDataBase)+"'","")+" and E2_VALOR > 0 and D_E_L_E_T_ <> '*' "
		cQry += "where "+IIf(nTipo == 1,"E2_FORNECE = '"+cForIni+"' and E2_LOJA = '"+cLojIni+"' and ","")+"E2_BAIXA = '' and (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and E2_VALOR > 0 and D_E_L_E_T_ <> '*' "
		cQry += "order by E2_VENCREA, E2_NUM, E2_PREFIXO, E2_PARCELA"
		
		if nTipoDupli == 1
			cDesc1 := "DUPLICATAS EM ABERTO - PAGAR"
		elseif nTipoDupli == 2
			cDesc1 := "DUPLICATAS VENCIDAS - PAGAR"
		endif
	else
		cQry := "select E1_VENCREA as VENC, E1_NUM as NUM, E1_PREFIXO as PREF, E1_PARCELA as PARC, E1_EMISSAO as EMISSAO, E1_TIPO as TIPO, '' as CR, '' as BCOPAG, E1_SALDO as VALOR, '' as BCOCOB, E1_CLIENTE as FORCLI, E1_LOJA as LOJA "
		cQry += "from "+RetSqlName("SE1")+" "
		cQry += "where "+IIf(nTipo == 1,"E1_CLIENTE = '"+cCliIni+"' and E1_LOJA = '"+cLojIni+"' and ","")+"(E1_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and E1_SALDO > 0 and D_E_L_E_T_ <> '*' "
		cQry += "order by E1_VENCREA, E1_NUM, E1_PREFIXO, E1_PARCELA"
		
		if nTipoDupli == 1
			cDesc1 := "DUPLICATAS EM ABERTO - RECEBER"
		elseif nTipoDupli == 2
			cDesc1 := "DUPLICATAS VENCIDAS - RECEBER"
		endif
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	if Empty(TEMP->(FORCLI+LOJA))
		return
	endif
	
	if nTipo == 1
		Cabec1 := PadC("Periodo de "+U_ConvData(cVenIni,"yy")+" a "+U_ConvData(cVenFin),132)
		Cabec2 := ""
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
//		FORNECEDOR: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA (999999-99)                    TIPO FORNECIMENTO: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  PP: 99
//		CONTATO...: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                                             TEL.: 999 99999-9999    CEL.: 999 99999-9999
//		E-MAIL....: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		OBS.......: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		if nContas == 1
			if SA2->(DbSeek(xFilial("SA2")+TEMP->(FORCLI+LOJA),.F.))
				@nLin,000 psay "FORNECEDOR: "+AllTrim(SA2->A2_NREDUZ)+" ("+TEMP->FORCLI+"-"+TEMP->LOJA+")"
				@nLin,074 psay "TIPO FORNECIMENTO: "+IIf(SX5->(DbSeek(xFilial("SX5")+"Z6"+SA2->A2_TIPFORN,.F.)),Left(SX5->X5_DESCRI,30)," ")
				@nLin,125 psay "PP:"+SA2->A2_PRIOPAG
				@++nLin,000 psay "CONTATO...: "+AllTrim(SA2->A2_NOMRESP)
				@nLin,087 psay "TEL.: "+AllTrim(SA2->A2_DDD1)+" "+AllTrim(SA2->A2_FONE1)
				@nLin,111 psay "CEL.: "+IIf(!Empty(SA2->A2_FONE2),AllTrim(SA2->A2_DDD2)+" "+AllTrim(SA2->A2_FONE2),"")
				
//				if !Empty(SA2->A2_EMAIL1)
					@++nLin,000 psay "E-MAIL....: "+AllTrim(SA2->A2_EMAIL1)
//				endif
				
				cObs := AllTrim(SA2->A2_OBSFIN)
				
//				if !Empty(cObs)
					@++nLin,000 psay "OBS.......: "+MemoLine(cObs,120,1)
					
					for k := 2 to MlCount(cObs,120)
						@++nLin,012 psay MemoLine(cObs,120,k)
					next
//				endif
			endif
		else
			if SA1->(DbSeek(xFilial("SA1")+TEMP->(FORCLI+LOJA),.F.))
				@nLin,000 psay "CLIENTE...: "+AllTrim(SA1->A1_NREDUZ)+" ("+TEMP->FORCLI+"-"+TEMP->LOJA+")"
				@++nLin,000 psay "CONTATO...: "+AllTrim(SA1->A1_NOMRESP)
				@nLin,087 psay "TEL.: "+AllTrim(SA1->A1_DDD1)+" "+AllTrim(SA1->A1_FONE1)
				@nLin,111 psay "CEL.: "+IIf(!Empty(SA1->A1_FONE2),AllTrim(SA1->A1_DDD2)+" "+AllTrim(SA1->A1_FONE2),"")
				
//				if !Empty(SA1->A1_EMAIL)
					@++nLin,000 psay "E-MAIL....: "+AllTrim(SA1->A1_EMAIL1)
//				endif
				
				cObs := AllTrim(SA1->A1_OBSFIN)
				
//				if !Empty(cObs)
					@++nLin,000 psay "OBS.......: "+MemoLine(cObs,120,1)
					
					for k := 2 to MlCount(cObs,120)
						@++nLin,012 psay MemoLine(cObs,120,k)
					next
//				endif
			endif
		endif
		
		nLin++
		
		@nLin,000 psay Replicate("=",132)
		@++nLin,000 psay "VENCIMENTO     NOTA FISCAL    PARC   EMISSAO    TIPO   PROTOCOLO   BANCO                      VALOR   ATRASO"
		@++nLin,000 psay Replicate("-",132)
		
		nLin++
		nTotal := 0 ; nCont := 0 ; nTotVenc := 0 ; nTotAVen := 0
		
		while !TEMP->(Eof())
//			VENCTO   NOTA FISCAL   PARC EMISSAO  TIP PROT.   BCO           VALOR ATRASO
//			VENCIMENTO     NOTA FISCAL    PARC   EMISSAO    TIPO   PROTOCOLO   BANCO                      VALOR   ATRASO
//			99/99/99       999999999-999  999    99/99/99   AAA    9999999     AAAA              999,999,999.99   9999
//			01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			nDias := dDataBase - SToD(TEMP->VENC)
			nValor := IIf(TEMP->TIPO $ "PA /RA ",0,TEMP->VALOR)
			
			@nLin,000 psay U_ConvData(TEMP->VENC,"yy")
			@nLin,015 psay TEMP->NUM+"-"+TEMP->PREF
			@nLin,030 psay TEMP->PARC
			@nLin,037 psay U_ConvData(TEMP->EMISSAO,"yy")
			@nLin,048 psay TEMP->TIPO
			@nLin,055 psay Left(TEMP->CR,7)
			@nLin,067 psay IIf(SA6->(DbSeek(xFilial("SA6")+Left(TEMP->BCOCOB,3),.F.)),SA6->A6_SIGLA," ")
			@nLin,085 psay Transf(IIf(TEMP->TIPO $ "PA /RA ",TEMP->VALOR * -1,TEMP->VALOR),"@E 999,999,999.99")
			@nLin,102 psay Transf(nDias,"@R 9999")
			
			nLin++
			nCont++
			nTotal += nValor
			
			if nDias > 0
				nTotVenc += nValor
			else
				nTotAVen += nValor
			endif
			
			if U_SaltaFolha()
				Cabec2 := "VENCIMENTO     NOTA FISCAL    PARC   EMISSAO    TIPO   PROTOCOLO   BANCO                      VALOR   ATRASO"
			endif
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		if U_SaltaFolha()
			Cabec2 := "VENCIMENTO     NOTA FISCAL    PARC   EMISSAO    TIPO   PROTOCOLO   BANCO                      VALOR   ATRASO"
		endif
		
		@nLin,000 psay "REGISTROS --> "+AllTrim(Transf(nCont,"@R 999999"))
		@nLin,055 psay "T O T A L"
		@nLin,085 psay Transf(nTotal,"@E 999,999,999.99")
		@++nLin,000 psay Replicate("-",132)
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,055 psay "VENCIDAS: "
		@nLin,085 psay Transf(nTotVenc,"@E 999,999,999.99")
		@++nLin,055 psay "A VENCER: "
		@nLin,085 psay Transf(nTotAVen,"@E 999,999,999.99")
		@++nLin,055 psay "TOTAL...: "
		@nLin,085 psay Transf(nTotVenc + nTotAVen,"@E 999,999,999.99")
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	else
//		while !TEMP->(Eof())
			if nContas == 1
				Cabec1 := "VENCIMENTO   FORNECEDOR                          NOTA FISCAL    PARC   EMISSAO   TIPO  PROTOCOLO  BCO             VALOR   ATRASO"
			else
				Cabec1 := "VENCIMENTO   CLIENTE                             NOTA FISCAL    PARC   EMISSAO   TIPO  PROTOCOLO  BCO             VALOR   ATRASO"
			endif
			
			Cabec2 := ""
			
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			nLin++
//			cFornCli := TEMP->(FORCLI+LOJA)
			nTotal := 0 ; nCont := 0 ; nTotVenc := 0 ; nTotAVen := 0
			
//			U_SaltaFolha()
			
//			while !TEMP->(Eof()) .and. TEMP->(FORCLI+LOJA) == cFornCli
			while !TEMP->(Eof())
//				VENCIMENTO   FORNECEDOR                          NOTA FISCAL    PARC   EMISSAO   TIPO  PROTOCOLO  BCO             VALOR   ATRASO
//				99/99/99     AAAAAAAAAAAAAAAAAAAA (999999-99)    999999999-999  999    99/99/99  AAA   9999999    AAAA   999,999,999.99   9999
//				01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//				          1         2         3         4         5         6         7         8         9        10        11        12        13
				
				nDias := dDataBase - SToD(TEMP->VENC)
				
				@nLin,000 psay U_ConvData(TEMP->VENC,"yy")
				
				if nContas == 1
//					@nLin,010 psay IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(FORCLI+LOJA),.F.)),SA2->A2_NREDUZ," ")
					@nLin,013 psay IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(FORCLI+LOJA),.F.)),AllTrim(SA2->A2_NREDUZ)," ")+" ("+TEMP->FORCLI+")"
				else
//					@nLin,010 psay IIf(SA1->(DbSeek(xFilial("SA1")+TEMP->(FORCLI+LOJA),.F.)),SA1->A1_NREDUZ," ")
					@nLin,013 psay IIf(SA1->(DbSeek(xFilial("SA1")+TEMP->(FORCLI+LOJA),.F.)),AllTrim(SA1->A1_NREDUZ)," ")+" ("+TEMP->FORCLI+")"
				endif
				
				@nLin,049 psay TEMP->NUM+"-"+TEMP->PREF
				@nLin,064 psay TEMP->PARC
				@nLin,071 psay U_ConvData(TEMP->EMISSAO,"yy")
				@nLin,081 psay TEMP->TIPO
				@nLin,087 psay Left(TEMP->CR,7)
				@nLin,098 psay IIf(SA6->(DbSeek(xFilial("SA6")+Left(TEMP->BCOCOB,3),.F.)),SA6->A6_SIGLA," ")
				@nLin,105 psay Transf(TEMP->VALOR,"@E 999,999,999.99")
				@nLin,122 psay Transf(nDias,"@R 9999")
				
				nLin++
				nCont++
				nTotal += TEMP->VALOR
				
				if nDias > 0
					nTotVenc += TEMP->VALOR
				else
					nTotAVen += TEMP->VALOR
				endif
				
				U_SaltaFolha()
				IncProc()
				TEMP->(DbSkip())
			enddo
			
			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay "REGISTROS --> "+AllTrim(Transf(nCont,"@R 999999"))
			@nLin,087 psay "T O T A L"
			@nLin,105 psay Transf(nTotal,"@E 999,999,999.99")
			
			nLin += 2
			
			U_SaltaFolha()
			
			@nLin,087 psay "VENCIDAS: "
			@nLin,105 psay Transf(nTotVenc,"@E 999,999,999.99")
			@++nLin,087 psay "A VENCER: "
			@nLin,105 psay Transf(nTotAVen,"@E 999,999,999.99")
			@++nLin,087 psay "TOTAL...: "
			@nLin,105 psay Transf(nTotVenc + nTotAVen,"@E 999,999,999.99")
			
			U_Rdp(nRdpPag,cRdpLeg,Tamanho)
//		enddo
	endif
	
	TEMP->(DbCloseArea())
return