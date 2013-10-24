/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 12/12/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de pedidos de compra por projeto para       ¦
   ¦          ¦ gestor de contratos                                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PCGERC()
	private aOrd    := {"Projeto"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PCGERC"
	private Cabec1  := "PEDCOM EMISSAO  ENTREGA  RECEBIM      QUANT UM PRODUTO                               FORNECEDOR               P.UNIT          TOTAL ST"
	private Cabec2  := ""
	private cDesc1  := "PC POR PROJETO P/ GESTOR CONTRATOS"
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
	
	private cPrjIni := ""
	private cPrjFin := ""
	private cPedIni := ""
	private cPedFin := ""
	private cProIni := ""
	private cProFin := ""
	private cSitua := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Projeto de                                        ³
	//³ mv_par02 - Projeto ate                                       ³
	//³ mv_par03 - Pedido de                                         ³
	//³ mv_par04 - Pedido ate                                        ³
	//³ mv_par05 - Produto de                                        ³
	//³ mv_par06 - Produto ate                                       ³
	//³ mv_par07 - Situacao PC (1-Ambos/2-Liberado/3-Bloqueado)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrjIni := mv_par01
	cPrjFin := mv_par02
	cPedIni := mv_par03
	cPedFin := mv_par04
	cProIni := mv_par05
	cProFin := mv_par06
	
	do case
		case mv_par07 == 1 ; cSitua := ""
		case mv_par07 == 2 ; cSitua := "L"
		case mv_par07 == 3 ; cSitua := "B"
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
	local aTotal := {0,0,0}
//	local nTotal := 0
//	local nTotApro := 0
//	local nTotBloq := 0
	local cCondicao := ""
	local aUnidade := {}
	
	if !Empty(cSitua)
		cCondicao := "and C7_CONAPRO = '"+cSitua+"'"
	endif
	
	cQry := "select C7_CLVL, C7_NUM, C7_EMISSAO, C7_DATPRF, C7_QUANT, C7_UM, C7_PRODUTO, B1_DESC, A2_NREDUZ, C7_PRECO, C7_TOTAL, C7_CONAPRO "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (C7_FORNECE = A2_COD and C7_LOJA = A2_LOJA) "
	cQry += "	inner join "+RetSqlName("SB1")+" SB1 on (C7_PRODUTO = B1_COD and C7_LOCAL = B1_LOCPAD) "
	cQry += "where (C7_CLVL between '"+cPrjIni+"' and '"+cPrjFin+"') and (C7_NUM between '"+cPedIni+"' and '"+cPedFin+"') and (C7_PRODUTO between '"+cProIni+"' and '"+cProFin+"') "+cCondicao+" and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by C7_CLVL, B1_DESC, A2_NREDUZ, C7_NUM"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		cProjeto := AllTrim(TEMP->C7_CLVL)
		nLin++
		
//		PROJETO: 999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay U_Negrito(.T.)+"PROJETO: "+Left(cProjeto,6)+" "+IIf(CTH->(DbSeek(xFilial("CTH")+cProjeto,.F.)),CTH->CTH_DESC01,"")+U_Negrito(.F.)
		
		nLin++
		
		U_SaltaFolha()
		
		while AllTrim(TEMP->C7_CLVL) == cProjeto
//	    	PEDCOM EMISSAO  ENTREGA  RECEBIM      QUANT UM PRODUTO                               FORNECEDOR               P.UNIT          TOTAL ST
//			999999 99/99/99 99/99/99 99/99/99 999999.99 AA AAAAAA-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAA 999,999.99 999,999,999.99 AA
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay TEMP->C7_NUM
			@nLin,007 psay U_ConvData(TEMP->C7_EMISSAO,"yy")
			@nLin,016 psay U_ConvData(TEMP->C7_DATPRF,"yy")
			
			SZU->(DbSetOrder(4))
			
			if SZU->(DbSeek(xFilial("SZU")+TEMP->(C7_NUM+C7_PRODUTO),.F.))
				@nLin,025 psay U_ConvData(DToS(SZU->ZU_DTCAD),"yy")
			endif
			
			@nLin,034 psay Transf(TEMP->C7_QUANT,"@E 999999.99")
			@nLin,044 psay TEMP->C7_UM
			@nlin,047 psay Left(TEMP->C7_PRODUTO,6)+"-"+Left(TEMP->B1_DESC,30)
			@nlin,085 psay TEMP->A2_NREDUZ
			@nLin,106 psay Transf(TEMP->C7_PRECO,"@E 999,999.99")
			@nLin,117 psay Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")
			
			if TEMP->C7_CONAPRO == "L"
				@nLin,132 psay "AP"
				
//				nTotApro += TEMP->C7_TOTAL
				aTotal[2] += TEMP->C7_TOTAL
			else
				@nLin,132 psay "BL"
				
//				nTotBloq += TEMP->C7_TOTAL
				aTotal[3] += TEMP->C7_TOTAL
			endif
			
//			nTotal += TEMP->C7_TOTAL
			aTotal[1] += TEMP->C7_TOTAL
			nLin++
			
			if (nInd := AScan(aUnidade,{|x| x[1] = TEMP->C7_UM})) == 0
				AAdd(aUnidade,{TEMP->C7_UM,TEMP->C7_QUANT,TEMP->C7_TOTAL})
			else
				aUnidade[nInd][2] += TEMP->C7_QUANT
				aUnidade[nInd][3] += TEMP->C7_TOTAL
			endif
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
//		TotalUnidade(aUnidade,aTotal,cProjeto)
		
		@nLin,085 psay "TOTAL"
		@nLin,117 psay Transf(aTotal[1],"@E 999,999,999.99")
		
		OrcamentoProj(cProjeto,nLin)
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
		
		aTotal := {0,0,0}
	enddo
	
	TEMP->(DbCloseArea())
return

static function OrcamentoProj(cProjeto,nLin)
	local cSql := ""
	local nTotOrc := 0
	local nTotEmp := 0
	local nTotRea := 0
	local nTotSal := 0
	local aArea := GetArea()
	
	nLinAtu := nLin
	nLin += 4
	
	U_SaltaFolha()
	
	if nLin >= nLinAtu
		nLin := nLinAtu + 2
	else
		nLin++
	endif
	
	cSql := "select Z4_GGRUPO, Z4_DESCGGR, Z4_VLORCAM, Z4_EMPENHA, Z4_VLREALI, Z4_SALDO "
	cSql += "from "+RetSqlName("SZ4")+" "
	cSql += "where Z4_PROJETO = '"+cProjeto+"' and D_E_L_E_T_ <> '*' "
	
	tcquery cSql new alias "TMP"
	DbSelectArea("TMP")
	TMP->(DbGoTop())
	
	@nLin,000 psay Replicate("-",132)
	@++nLin,000 psay "DESCRICAO                                         ORCADO           EMPENHADO               SALDO"
	
	nlin++
	
	U_SaltaFolha()
	
	while !TMP->(Eof())
//		DESCRICAO                                         ORCADO           EMPENHADO               SALDO
//		000 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    999,999,999,999.99  999,999,999,999.99  999,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//		          1         2         3         4         5         6         7         8         9        10        11
		
		@nLin,000 psay TMP->Z4_GGRUPO
		@nLin,004 psay TMP->Z4_DESCGGR
		@nLin,038 psay Transf(TMP->Z4_VLORCAM,"@E 999,999,999,999.99")
		@nLin,058 psay Transf(TMP->Z4_EMPENHA,"@E 999,999,999,999.99")
//		@nLin,078 psay Transf(TMP->Z4_VLREALI,"@E 999,999,999,999.99")
		@nLin,078 psay Transf(TMP->Z4_SALDO,"@E 999,999,999,999.99")
		
		nTotOrc += TMP->Z4_VLORCAM
		nTotEmp += TMP->Z4_EMPENHA
//		nTotRea += TMP->Z4_VLREALI
		nTotSal += TMP->Z4_SALDO
		
		nLin++
		
		U_SaltaFolha()
		TMP->(DbSkip())
	enddo
	
	@nLin,004 psay "TOTAL GERAL"
	@nLin,038 psay Transf(nTotOrc,"@E 999,999,999,999.99")
	@nLin,058 psay Transf(nTotEmp,"@E 999,999,999,999.99")
//	@nLin,078 psay Transf(nTotRea,"@E 999,999,999,999.99")
	@nLin,078 psay Transf(nTotSal,"@E 999,999,999,999.99")
	
	TMP->(DbCloseArea())
	RestArea(aArea)
return