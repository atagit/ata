/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 18/01/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de pedidos de compra atendidos              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PCATEND()
	private aOrd    := {"Pedido de Compra","Fornecedor","Nota Fiscal"}
	private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELATD"
//	private Cabec1  := "PEDCOMP | EMISSAO    | NOTA FISCAL   | FORNECEDOR                         |          VALOR | PE. | QT. | ESP | ID. | CTF | TOTAL"
	private Cabec1  := "PEDCOMP | EMISSAO    | NOTA FISCAL   |                                               VALOR | PE. | QT. | ESP | ID. | CTF | TOTAL"
	private Cabec2  := ""
	private cDesc1  := "PEDIDO ATENDIDO"
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
	private cRdpLeg	:= "PE. - Prazo de Entrega | QT. - Quantidade | ESP - Especificacao | ID. - Identificacao | CTF - Certificado do Produto"
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
	
	SetPrvt("nCont","nTotPrz","nTotQuant","nTotEspec","nTotIdent","nTotCerti","nTotGeral")
	SetPrvt("nPrz","nQuant","Espec","Ident","nCerti","nTotValor")
	
	nCont := 0 ; nTotPrz := 0 ; nTotQuant := 0 ; nTotEspec := 0 ; nTotIdent := 0 ; nTotCerti := 0 ; nTotGeral := 0
	nPrz := 0 ; nQuant := 0 ; nEspec := 0 ; nIdent := 0 ; nCerti := 0 ; nTotValor := 0 ; nTotal := 0
	nTPrz := 0 ; nTQuant := 0 ; nTEspec := 0 ; nTIdent := 0 ; nTCerti := 0 ; nTotal := 0 ; nTValor := 0
	
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
		Processa({|| Impr1()},"","Aguarde processando...",lAborta)
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
	cQry := "select SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, SF1.F1_AVPRZ, SF1.F1_AVIDENT, SF1.F1_AVESPEC, SF1.F1_AVQUANT, SF1.F1_AVCERTI, SF1.F1_DOC, SF1.F1_SERIE "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SD1")+" SD1 on (SD1.D1_PEDIDO = SC7.C7_NUM and SD1.D1_FORNECE = SC7.C7_FORNECE and SD1.D1_LOJA = SC7.C7_LOJA) inner join "+RetSqlName("SF1")+" SF1 on (SD1.D1_DOC = SF1.F1_DOC and SD1.D1_SERIE = SF1.F1_SERIE and SD1.D1_FORNECE = SF1.F1_FORNECE and SD1.D1_LOJA = SF1.F1_LOJA) inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
	cQry += "where (SC7.C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (SC7.C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (SC7.C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and SF1.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, SF1.F1_AVPRZ, SF1.F1_AVIDENT, SF1.F1_AVESPEC, SF1.F1_AVQUANT, SF1.F1_AVCERTI, SF1.F1_DOC, SF1.F1_SERIE "
	
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
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	PEDCOMP | EMISSAO    | NOTA FISCAL   | FORNECEDOR                         |          VALOR | PE. | QT. | ESP | ID. | CTF | TOTAL
//	999999  | 99/99/9999 | 999999999-999 | 999999-99 AAAAAAAAAAAAAAAAAAAA
//	12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	         1         2         3         4         5         6         7         8         9        10        11        12        13        14
	
	cFor := TEMP->C7_FORNECE
	cLoj := TEMP->C7_LOJA
	
	while !TEMP->(Eof())
		@nLin,000 psay U_Negrito(.T.)+TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ+U_Negrito(.F.)
		
		nLin++
		
		while TEMP->C7_FORNECE == cFor .and. TEMP->C7_LOJA == cLoj
			nPrz := If(TEMP->F1_AVPRZ == "S",1,0)
			nQuant := If(TEMP->F1_AVQUANT == "S",1,0)
			nEspec := If(TEMP->F1_AVESPEC == "S",1,0)
			nIdent := If(TEMP->F1_AVIDENT == "S",1,0)
			nCerti := If(TEMP->F1_AVCERTI == "S",1,0)
			
			@nLin,000 psay TEMP->C7_NUM
			@nLin,010 psay U_ConvData(TEMP->C7_EMISSAO)
			@nLin,023 psay TEMP->F1_DOC+"-"+TEMP->F1_SERIE
//			@nLin,039 psay TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ
			
			cCon := "select C7_NUM, sum(C7_TOTAL) as C7_TOTAL "
			cCon += "from "+RetSqlName("SC7")+" "
			cCon += "where C7_NUM = '"+TEMP->C7_NUM+"' and C7_FORNECE = '"+TEMP->C7_FORNECE+"' and C7_LOJA = '"+TEMP->C7_LOJA+"' and D_E_L_E_T_ <> '*' "
			cCon += "group by C7_NUM"
			
			tcquery cCon new alias "CON"
			DbSelectArea("CON")
			
			@nLin,076 psay Transf(CON->C7_TOTAL,"@E 999,999,999.99")
			@nLin,095 psay Transf(nPrz,"@E 9")
			@nLin,101 psay Transf(nQuant,"@E 9")
			@nLin,107 psay Transf(nEspec,"@E 9")
			@nLin,113 psay Transf(nIdent,"@E 9")
			@nLin,119 psay Transf(nCerti,"@E 9")
			@nLin,127 psay Transf(nPrz + nQuant + nEspec + nIdent + nCerti,"@E 9")
			
			nLin++
			nCont++
			nTotValor += CON->C7_TOTAL
			nTValor += CON->C7_TOTAL
			nTPrz += nPrz
			nTQuant += nQuant
			nTEspec += nEspec
			nTIdent += nIdent
			nTCerti += nCerti
			nTotal += nPrz + nQuant + nEspec + nIdent + nCerti
			
			U_SaltaFolha()
			
			IncRegua()
			CON->(DbCloseArea())
			TEMP->(DbSkip())
		enddo
		
		nTotPrz += nTPrz
		nTotQuant += nTQuant
		nTotEspec += nTEspec
		nTotIdent += nTIdent
		nTotCerti += nTCerti
		nTotGeral += nTPrz + nTQuant + nTEspec + nTIdent + nTCerti
		
		@nLin,060 psay "TOTAL"
		@nLin,076 psay Transf(nTValor,"@E 999,999,999.99")
		@nLin,093 psay Transf(nTPrz,"@E 999")
		@nLin,099 psay Transf(nTQuant,"@E 999")
		@nLin,105 psay Transf(nTEspec,"@E 999")
		@nLin,111 psay Transf(nTIdent,"@E 999")
		@nLin,117 psay Transf(nTCerti,"@E 999")
		@nLin,123 psay Transf(nTotal,"@E 99999")
		
		nTPrz := 0 ; nTQuant := 0 ; nTEspec := 0 ; nTIdent := 0 ; nTCerti := 0 ; nTotal := 0 ; nTValor := 0
		nLin += 2
		
		U_SaltaFolha()
		
		cFor := TEMP->C7_FORNECE
		cLoj := TEMP->C7_LOJA
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin  ,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	@++nLin,000 psay "TOTAL DE REGISTROS: "+Transf(nCont,"@E 999999")
	@nLin  ,076 psay Transf(nTotValor,"@E 999,999,999.99")
	@nLin  ,093 psay Transf(nTotPrz,"@E 999")
	@nLin  ,099 psay Transf(nTotQuant,"@E 999")
	@nLin  ,105 psay Transf(nTotEspec,"@E 999")
	@nLin  ,111 psay Transf(nTotIdent,"@E 999")
	@nLin  ,117 psay Transf(nTotCerti,"@E 999")
	@nLin  ,123 psay Transf(nTotGeral,"@E 99999")
	
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
	ProcRegua(TEMP->(RecCount()))
	
	cCbcRef := Padc("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	cDesc1  := "PEDIDO NAO ATENDIDO"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nPrz := 0 ; nQuant := 0 ; nEspec := 0 ; nIdent := 0 ; nCerti := 0 ; nTotPrz := 0
	nTotQuant := 0 ; nTotEspec := 0 ; nTotIdent := 0 ; nTotCerti := 0 ; nTotGeral := 0
	
	while !TEMP->(Eof())
		@nLin,000 psay TEMP->C7_NUM
		@nLin,010 psay U_ConvData(TEMP->C7_EMISSAO)
		@nLin,023 psay If(SD1->(DbSeek(xFilial("SD1")+TEMP->C7_NUM,.F.)),SD1->D1_DOC+"-"+SD1->D1_SERIE,"")
		@nLin,039 psay TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ
		@nLin,076 psay Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")
		@nLin,095 psay Transf(nPrz,"@E 9")
		@nLin,101 psay Transf(nQuant,"@E 9")
		@nLin,107 psay Transf(nEspec,"@E 9")
		@nLin,113 psay Transf(nIdent,"@E 9")
		@nLin,119 psay Transf(nCerti,"@E 9")
		@nLin,127 psay Transf(nPrz + nQuant + nEspec + nIdent + nCerti,"@E 9")
		
		nLin++
		nCont++
		nTotValor += TEMP->C7_TOTAL
		
		U_SaltaFolha()
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin  ,000 psay Replicate("-",136)
	@++nLin,000 psay "TOTAL DE REGISTROS: "+Transf(nCont,"@E 999")
	@nLin  ,076 psay Transf(nTotValor,"@E 999,999,999.99")
	@nLin  ,093 psay Transf(nTotPrz,"@E 999")
	@nLin  ,099 psay Transf(nTotQuant,"@E 999")
	@nLin  ,105 psay Transf(nTotEspec,"@E 999")
	@nLin  ,111 psay Transf(nTotIdent,"@E 999")
	@nLin  ,117 psay Transf(nTotCerti,"@E 999")
	@nLin  ,123 psay Transf(nTotGeral,"@E 99999")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return