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
	local nSubTotVenc := 0
	local nSubTotGeral := 0
	local nSubQtdVenc := 0
	local nSubQtdGeral := 0
	
	if nContas == 1
		cQry := "select E2_VENCREA, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, E2_TIPO, E2_CR, E2_BCOPAG, E2_VALOR, E2_BANCO "
		cQry += "from "+RetSqlName("SE2")+" "
		cQry += "where E2_FORNECE = '"+cForIni+"' and E2_LOJA = '"+cLojIni+"' and E2_BAIXA = '' and D_E_L_E_T_ <> '*' "
		cQry += "order by E2_VENCREA, E2_NUM, E2_PREFIXO, E2_PARCELA"
		cDesc1 := "DUPLICATAS EM ABERTO"
		Cabec2  := "FORNECEDOR                      PRESTACAO      PARC  EMISSAO   ATRASO                             VALOR"
	else
/*		cQry := "select E1_CLIENTE as CLIFOR, E1_LOJA as LOJA, E1_NOMCLI as NOMCLIFOR, E1_VENCREA as VENCREA, E1_NUM as NUM, E1_PREFIXO as PREFIXO, E1_PARCELA as PARCELA, E1_EMISSAO as EMISSAO, E1_VALOR as VALOR, E1_BAIXA as BAIXA, E1_SALDO as SALDO, datediff(day, E1_VENCREA, getdate()) as DIFF "
		cQry += "from "+RetSqlName("SE1")+" "
		cQry += "where (E1_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E1_BAIXA = '' or (E1_BAIXA <> '' and E1_SALDO > 0)) and D_E_L_E_T_ <> '*' "
		cQry += "order by E1_VENCREA, E1_NOMCLI"
		cDesc1 := "DUPLICATAS A RECEBER - TODOS OS CLIENTES"
		Cabec2  := "CLIENTE                         PRESTACAO      PARC  EMISSAO   ATRASO                             VALOR"*/
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
//	FORNECEDOR                     VENCTO   NOTA FISCAL   PARC EMISSAO  TIP PROT.   BCO              VALOR
//	999999-99 AAAAAAAAAAAAAAAAAAAA 99/99/99 999999999-999 999  99/99/99 AAA 9999999 AAAA 99,999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
		@nLin,000 psay "FORNECEDOR: "+IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(E2_FORNECE+E2_LOJA),.F.)),AllTrim(SA2->A2_NREDUZ),"")+" ("+TEMP->E2_FORNECE+"-"+TEMP->E2_LOJA+")"
		
		nLin++
		
		@nLin,000 psay Replicate("-",132)
		
		cFornCli := TEMP->(E2_FORNECE+E2_LOJA)
		nLin++
		
		U_SaltaFolha()
		
		while !TEMP->(Eof()) .and. TEMP->(E2_FORNECE+E2_LOJA) == cFornCli
//			VENCTO   NOTA FISCAL   PARC EMISSAO  TIP PROT.   BCO              VALOR
//			99/99/99 999999999-999 999  99/99/99 AAA 9999999 AAAA 99,999,999,999.99
//			01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay U_ConvData(TEMP->E2_VENCREA,"yy")
			@nLin,010 psay TEMP->NOMCLIFOR
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