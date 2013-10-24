/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 27/08/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de pedidos de compra por projeto            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PEDPROJ()
	private aOrd    := {"Pedido de Compra","Nom. Fornecedor"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PEDPROJ"
//	private Cabec1  := "PROJETO"
//	private Cabec2  := "PED COMP | EMISSAO    | FORNECEDOR                     |        QUANT |          TOTAL |            IPI |       TOTAL C/ IPI"
	private Cabec1  := "PROJETO                                                                                                                       ORCADO"
	private Cabec2  := "PED COMP | EMISSAO    | ENTREGA    | FORNECEDOR                     |        QUANT |              TOTAL | ST    |              SALDO"
	private cDesc1  := "PED. COMPRA POR PROJETO"
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
	private cSitua := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Projeto de                                        ³
	//³ mv_par02 - Projeto ate                                       ³
	//³ mv_par03 - Situacao PC (1-Ambos/2-Liberado/3-Bloqueado       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrjIni := mv_par01
	cPrjFin := mv_par02
	
	do case
		case mv_par03 == 1 ; cSitua := ""
		case mv_par03 == 2 ; cSitua := "L"
		case mv_par03 == 3 ; cSitua := "B"
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
	local nQuant := 0
	local nTotal := 0
	local nIpi := 0
	local nTotIpi := 0
	local cCondicao := ""
	local aSaldoSZ3 := {}
	
	if !Empty(cSitua)
		cCondicao := "and C7_CONAPRO = '"+cSitua+"'"
	endif
	
	cQry := "select C7_CLVL, C7_NUM, C7_EMISSAO, C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_CONAPRO, sum(C7_QUANT) as C7_QUANT, sum(C7_TOTAL) as C7_TOTAL, sum(C7_VALIPI) as C7_VALIPI, sum(C7_TOTAL)+sum(C7_VALIPI) as TOTALIPI "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (C7_FORNECE = A2_COD and C7_LOJA = A2_LOJA) "
	cQry += "where (C7_CLVL between '"+cPrjIni+"' and '"+cPrjFin+"') "+cCondicao+" and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by C7_CLVL, C7_NUM, C7_EMISSAO, C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_CONAPRO "
	
	if nOrdem == 1
		cQry += "order by C7_CLVL, C7_NUM, A2_NREDUZ"
	elseif nOrdem == 2
		cQry += "order by C7_CLVL, A2_NREDUZ, C7_NUM"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	while !TEMP->(Eof())
		cProjeto := AllTrim(TEMP->C7_CLVL)
		
		aSaldoSZ3 := SaldoSZ3(cProjeto)
		
//		PROJETO                                                                                                                       ORCADO
//		999999999 - AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                      999,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@++nLin,000 psay U_Negrito(.T.)+cProjeto+" - "+IIf(CTH->(DbSeek(xFilial("CTH")+cProjeto,.F.)),CTH->CTH_DESC01,"")
		@nLin,114 psay Transf(aSaldoSZ3[1][1],"@E 999,999,999,999.99")+U_Negrito(.F.)
//		@nLin,114 psay Transf(aSaldoSZ3[1][2],"@E 999,999,999,999.99")+U_Negrito(.F.)
		
		nTotalOrc := aSaldoSZ3[1][1]
		nLin++
		
		while AllTrim(TEMP->C7_CLVL) == cProjeto
			nTotalOrc := (nTotalOrc - (TEMP->C7_TOTAL + TEMP->C7_VALIPI))
			
			@nLin,000 psay TEMP->C7_NUM
			@nLin,011 psay U_ConvData(TEMP->C7_EMISSAO)
			@nLin,024 psay U_ConvData(TEMP->C7_DATPRF)
			@nLin,037 psay TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ
			@nLin,070 psay Transf(TEMP->C7_QUANT,"@R 999999999.99")
			@nLin,085 psay Transf(TEMP->C7_TOTAL + TEMP->C7_VALIPI,"@E 999,999,999,999.99")
			@nLin,106 psay IIf(TEMP->C7_CONAPRO == "L","AP","BL")
//			@nLin,089 psay Transf(TEMP->C7_VALIPI,"@E 999,999,999.99")
//			@nLin,106 psay Transf(TEMP->TOTALIPI,"@E 999,999,999,999.99")
			@nLin,114 psay Transf(nTotalOrc,"@E 999,999,999,999.99")
			
			nQuant += TEMP->C7_QUANT
			nTotal += (TEMP->C7_TOTAL + TEMP->C7_VALIPI)
//			nIpi += TEMP->C7_VALIPI
//			nTotIpi += TEMP->TOTALIPI
			
			nLin++
			
//			PED COMP | EMISSAO    | ENTREGA    | FORNECEDOR                     |        QUANT |              TOTAL | ST    |              SALDO
//			999999     99/99/9999   99/99/9999   999999-99 AAAAAAAAAAAAAAAAAAAA   999999999.99   999,999,999,999.99   AA      999,999,999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			U_SaltaFolha()
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,070 psay Transf(nQuant,"@R 999999999.99")
		@nLin,085 psay Transf(nTotal,"@E 999,999,999,999.99")
//		@nLin,089 psay Transf(nIpi,"@E 999,999,999.99")
//		@nLin,106 psay Transf(nTotIpi,"@E 999,999,999,999.99")
		@nLin,114 psay Transf(nTotalOrc,"@E 999,999,999,999.99")
		
		nQuant := 0 ; nTotal := 0 ; nIpi := 0 ; nTotIpi := 0 ; nTotalOrc := 0
		nLin++
		
		OrcamentoProj(cProjeto,nLin)
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	
	TEMP->(DbCloseArea())
return

static function SaldoSZ3(cProj)
	local aRet := {}
	
	DbSelectArea("SZ3")
	DbSetOrder(2)
	SZ3->(DbGoTop())
	
	if SZ3->(DbSeek(xFilial("SZ3")+AllTrim(cProj),.F.))
		AAdd(aRet,{SZ3->Z3_ORCADO,SZ3->Z3_SALDO})
	else
		AAdd(aRet,{0,0})
	endif
return(aRet)

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
		@nLin,078 psay Transf(TMP->Z4_SALDO,"@E 999,999,999,999.99")
		
		nTotOrc += TMP->Z4_VLORCAM
		nTotEmp += TMP->Z4_EMPENHA
		nTotSal += TMP->Z4_SALDO
		
		nLin++
		
		U_SaltaFolha()
		TMP->(DbSkip())
	enddo
	
	@nLin,004 psay "TOTAL GERAL"
	@nLin,038 psay Transf(nTotOrc,"@E 999,999,999,999.99")
	@nLin,058 psay Transf(nTotEmp,"@E 999,999,999,999.99")
	@nLin,078 psay Transf(nTotSal,"@E 999,999,999,999.99")
	
	TMP->(DbCloseArea())
	RestArea(aArea)
return