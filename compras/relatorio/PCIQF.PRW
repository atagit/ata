/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 22/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de pedidos de compra atendidos              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PCIQF()
	private aOrd    := {"Pedido de Compra","Fornecedor","Nota Fiscal"}
	private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PCIQF"
	private Cabec1  := "PEDCOMP | EMISSAO    | NOTA FISCAL   |                                               VALOR | APROV | REPRO | ACEIT | MEDIA"
	private Cabec2  := ""
	private cDesc1  := "PEDIDO ATENDIDO"
	private ContFun := 0
	private cString := "SC7"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := cPerg
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= "PONTUACAO: APROV - Aprovado (100)    |    REPRO - Reprovado (5)    |    ACEIT - Aceito com restricao (25)"
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cPedIni := ""
	private cPedFin := ""
	private cDtIni := ""
	private cDtFin := ""
	private nTpRel := 0
	private cForIni := ""
	private cForFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Pedido de                                         ³
	//³ mv_par02 - Pedido ate                                        ³
	//³ mv_par03 - Emissao de                                        ³
	//³ mv_par04 - Emissao ate                                       ³
	//³ mv_par05 - Tipo (1-atendido/2-nao atendido)                  ³
	//³ mv_par06 - Fornecedor de                                     ³
	//³ mv_par07 - Fornecedor ate                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SetPrvt("nCont","nTotGeral","nTotValor","nContApr","nContRep","nContAce","nContSem")
	
	nCont := 0 ; nContApr := 0 ; nContRep := 0 ; nContAce := 0 ; nContSem := 0
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPedIni := mv_par01
	cPedFin := mv_par02
	cDtIni := DToS(mv_par03)
	cDtFin := DToS(mv_par04)
	nTpRel := mv_par05
	cForIni := mv_par06
	cForFin := mv_par07
	
	if nTpRel == 1
		RptStatus({|| Impr()},"","Aguarde processando...",lAborta)
	else
		RptStatus({|| Impr1()},"","Aguarde processando...",lAborta)
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

static function Impr()
	cQry := "select SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, SF1.F1_AVIQF, SF1.F1_DOC, SF1.F1_SERIE "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SD1")+" SD1 on (SD1.D1_PEDIDO = SC7.C7_NUM and SD1.D1_FORNECE = SC7.C7_FORNECE and SD1.D1_LOJA = SC7.C7_LOJA) inner join "+RetSqlName("SF1")+" SF1 on (SD1.D1_DOC = SF1.F1_DOC and SD1.D1_SERIE = SF1.F1_SERIE and SD1.D1_FORNECE = SF1.F1_FORNECE and SD1.D1_LOJA = SF1.F1_LOJA) inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and SF1.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, SF1.F1_AVIQF, SF1.F1_DOC, SF1.F1_SERIE "
	
	do case 
		case nOrdem == 1
			cQry += "order by SA2.A2_NREDUZ, SC7.C7_NUM, SC7.C7_EMISSAO"
		case nOrdem == 2
			cQry += "order by SA2.A2_NREDUZ, SC7.C7_NUM, SC7.C7_EMISSAO"
		case nOrdem == 3
			cQry += "order by SA2.A2_NREDUZ, SF1.F1_DOC, SF1.F1_SERIE"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	DbSelectArea("SD1")
	DbSetOrder(14)
	
	TEMP->(DbGoTop())
	SetRegua(TEMP->(LastRec()))
	
	cCbcRef := Padc("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	Cabec1 := "PEDCOMP | EMISSAO    | NOTA FISCAL   |                                               VALOR | APROV | REPRO | ACEIT |   TOTAL"
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	PEDCOMP | EMISSAO    | NOTA FISCAL   |                                               VALOR | APROV | REPRO | ACEIT |   TOTAL
//	999999  | 99/99/9999 | 999999999-999 |                                      999,999,999.99     X       X       X     9999.99
//	12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	         1         2         3         4         5         6         7         8         9        10        11        12        13        14
	
	cFor := TEMP->C7_FORNECE
	cLoj := TEMP->C7_LOJA
	nTotApr := 0 ; nTotRep := 0 ; nTotAce := 0 ; nTotSem := 0 ; nTotReg := 0 ; nTotPontos := 0 ; nPonto := 0 ; nContPontos := 0
	
	while !TEMP->(Eof())
		@nLin,000 psay U_Negrito(.T.)+TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ+U_Negrito(.F.)
		
		nLin++
		
		while TEMP->C7_FORNECE == cFor .and. TEMP->C7_LOJA == cLoj
			@nLin,000 psay TEMP->C7_NUM
			@nLin,010 psay U_ConvData(TEMP->C7_EMISSAO)
			@nLin,023 psay TEMP->F1_DOC+"-"+TEMP->F1_SERIE
			
			cCon := "select C7_NUM, sum(C7_TOTAL) as C7_TOTAL "
			cCon += "from "+RetSqlName("SC7")+" "
			cCon += "where C7_NUM = '"+TEMP->C7_NUM+"' and C7_FORNECE = '"+TEMP->C7_FORNECE+"' and C7_LOJA = '"+TEMP->C7_LOJA+"' and D_E_L_E_T_ <> '*' "
			cCon += "group by C7_NUM"
			
			tcquery cCon new alias "CON"
			DbSelectArea("CON")
			
			@nLin,076 psay Transf(CON->C7_TOTAL,"@E 999,999,999.99")
			
			if TEMP->F1_AVIQF == "1" 
				nContApr++
				nTotApr++
				nPonto += 100
				
				@nLin,091 psay "|   X   |       |       |"
				@nLin,118 psay Transf("100","@E 9999")
			elseif TEMP->F1_AVIQF == "2" 
				nContRep++
				nTotRep++
				nPonto += 5
				
				@nLin,091 psay "|       |   X   |       |"
				@nLin,118 psay Transf("5","@E 9999")
			elseif TEMP->F1_AVIQF == "3"
				nContAce++
				nTotAce++
				nPonto += 25
				
				@nLin,091 psay "|       |       |   X   |"
				@nLin,118 psay Transf("25","@E 9999")
			else
				nContSem++
				nTotSem++
				
				@nLin,091 psay "|       |       |       |"
			endif
			
			nLin++
			nCont++
			nTotReg++
			
			U_SaltaFolha()
			
			IncRegua()
			CON->(DbCloseArea())
			TEMP->(DbSkip())
		enddo
		
		@nLin,000 psay "REGISTRO(S): "+AllTrim(Transf(nCont,"@E 999999"))
		@nLin,085 psay "TOTAL"
		@nLin,091 psay "|"
		@nLin,093 psay Transf(nContApr,"@E 99999")
		@nLin,099 psay "|"
		@nLin,101 psay Transf(nContRep,"@E 99999")
		@nLin,107 psay "|"
		@nLin,109 psay Transf(nContAce,"@E 99999")
		@nLin,115 psay "|"
		@nLin,118 psay Transf(nPonto / (nCont - nContSem),"@E 99999.99")
		
		nTotPontos += nPonto
		nLin += 2
		nCont := 0 ; nContApr := 0 ; nContRep := 0 ; nContAce := 0 ; nContSem := 0 ; nPonto := 0
		
		U_SaltaFolha()
		
		cFor := TEMP->C7_FORNECE
		cLoj := TEMP->C7_LOJA
	enddo
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "TOTAL GERAL"
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "REGISTRO(S): "+AllTrim(Transf(nTotReg,"@E 999999"))
	@nLin,085 psay "TOTAL"
	@nLin,091 psay "|"
	@nLin,093 psay Transf(nTotApr,"@E 99999")
	@nLin,099 psay "|"
	@nLin,101 psay Transf(nTotRep,"@E 99999")
	@nLin,107 psay "|"
	@nLin,109 psay Transf(nTotAce,"@E 99999")
	@nLin,115 psay "|"
	@nLin,118 psay Transf(nTotPontos / (nTotReg - nTotSem),"@E 99999.99")
	
//	alert(nTotPontos)
//	alert(nContPontos)
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "SEM AVALIACAO: "+AllTrim(Transf(nTotSem,"@E 999999"))
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	DbSelectArea("TEMP")
return

static function Impr1()
	cQry := "select SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, sum(SC7.C7_TOTAL) as C7_TOTAL "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where SC7.C7_NUM not in ( "
	cQry += "							select distinct D1_PEDIDO "
	cQry += "							from "+RetSqlName("SD1")+" "
	cQry += "							where (D1_EMISSAO between '"+cDtini+"' and '"+cDtFin+"') and D1_PEDIDO <> '' and D_E_L_E_T_ <> '*' "
	cQry += "							) "
	cQry += "		and (C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ "
	
	do case 
		case nOrdem == 1
			cQry += "order by SA2.A2_NREDUZ, SC7.C7_NUM, SC7.C7_EMISSAO"
		case nOrdem == 2
			cQry += "order by SA2.A2_NREDUZ, SC7.C7_NUM, SC7.C7_EMISSAO"
		case nOrdem == 3
			cQry += "order by SA2.A2_NREDUZ, SF1.F1_DOC, SF1.F1_SERIE"
	endcase
	
	DbSelectArea("SD1")
	DbSetOrder(14)
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	SetRegua(TEMP->(LastRec()))
	
	cCbcRef := Padc("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	cDesc1  := "PEDIDO NAO ATENDIDO"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	cFor := TEMP->C7_FORNECE
	cLoj := TEMP->C7_LOJA
	
	while !TEMP->(Eof())
		@nLin,000 psay U_Negrito(.T.)+TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ+U_Negrito(.F.)
		
		nLin++
		
		while TEMP->C7_FORNECE == cFor .and. TEMP->C7_LOJA == cLoj
			@nLin,000 psay TEMP->C7_NUM
			@nLin,010 psay U_ConvData(TEMP->C7_EMISSAO)
			@nLin,023 psay If(SD1->(DbSeek(xFilial("SD1")+TEMP->C7_NUM,.F.)),SD1->D1_DOC+"-"+SD1->D1_SERIE,"")
			@nLin,073 psay Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")
			
			nLin++
			nCont++
			
			U_SaltaFolha()
			
			IncRegua()
			TEMP->(DbSkip())
		enddo
		
		@nLin,000 psay "REGISTRO(S): "+AllTrim(Transf(nCont,"@E 999999"))
		
		nLin += 2
		nCont := 0 ; nContApr := 0 ; nContRep := 0 ; nContAce := 0 ; nContSem := 0
		
		U_SaltaFolha()
		
		cFor := TEMP->C7_FORNECE
		cLoj := TEMP->C7_LOJA
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	DbSelectArea("TEMP")
return