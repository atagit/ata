/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/10/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de ponto de pedido                          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PNTPED()
	private aOrd    := {"Codigo","Descricao","Grupo","Ponto de Pedido"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PNTPED"
	private Cabec1  := "CODIGO  | TP | GRUPO | DESCRICAO                                  | UN | AMZ | QUANTIDADE | PNT PEDIDO | SALDO      | CUSTO MEDIO"
	private Cabec2  := ""
	private cDesc1  := "PONTO DE PEDIDO"
	private ContFun := 0
	private cString := "SB2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private aTotGrp := {}
	private nTotCustoMedio := 0
	private nTotQuantidade := 0
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cPrdIni := ""
	private cPrdFin := ""
	private nQtdNeg := 0
	private nQtdZer := 0
	private cGrp := ""
	private cArmIni := ""
	private cArmFin := ""
	private nPntPed := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Produto de                                        ³
	//³ mv_par02 - Produto ate                                       ³
	//³ mv_par03 - Qtd Negativo (1-sim/2-nao)                        ³
	//³ mv_par04 - Qtd Zerada (1-sim/2-nao)                          ³
	//³ mv_par05 - Grupo                                             ³
	//³ mv_par06 - Armazem de                                        ³
	//³ mv_par07 - Armazem ate                                       ³
	//³ mv_par08 - Ponto de Pedido (1-todos/2-somente)               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrdIni := mv_par01
	cPrdFin := mv_par02
	nQtdNeg := mv_par03
	nQtdZer := mv_par04
	cGrp 	:= mv_par05
	cArmIni := mv_par06
	cArmFin := mv_par07
	nPntPed := mv_par08
	
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
	
	cQry := "select B2_COD, B1_DESC, B1_TIPO, B1_GRUPO, B1_UM, B2_QATU, B1_EMIN, B2_LOCAL, B2_VATU1 "
	cQry += "from "+RetSqlName("SB2")+" SB2 inner join "+RetSqlName("SB1")+" SB1 on (SB2.B2_COD = SB1.B1_COD and SB2.B2_LOCAL = SB1.B1_LOCPAD) "
	cQry += "where (B2_COD between '"+cPrdIni+"' and '"+cPrdFin+"') and (B2_LOCAL between '"+cArmIni+"' and '"+cArmFin+"') and SB2.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SB1.B1_MSBLQL <> '1' "
	
	if nOrdem == 1
		cQry += "order by B2_COD"
	elseif nOrdem == 2
		cQry += "order by B1_DESC"
	elseif nOrdem == 3
		cQry += "order by B1_GRUPO"
	elseif nOrdem == 4
		cQry += "order by B1_EMIN"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	while !TEMP->(Eof())
		if nQtdNeg == 2
			if (TEMP->B2_QATU < 0) .and. (TEMP->B1_EMIN <= 0) ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if nQtdZer == 2
			if (TEMP->B2_QATU = 0) .and. (TEMP->B1_EMIN <= 0) ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if nPntPed == 2
			if (TEMP->B2_QATU - TEMP->B1_EMIN) > 0 ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if Empty(cGrp)
			cGrp := '*'
		endif
		
		if AllTrim(cGrp) == '*' .or. TEMP->B1_GRUPO $ cGrp
			nCustoMedio := TEMP->B2_VATU1 / TEMP->B2_QATU
			
			@nLin,000 psay Left(TEMP->B2_COD,8)
			@nLin,010 psay TEMP->B1_TIPO
			@nLin,015 psay Left(TEMP->B1_GRUPO,43)
			@nLin,023 psay Left(TEMP->B1_DESC,40)
			@nLin,069 psay TEMP->B1_UM
			@nLin,075 psay TEMP->B2_LOCAL
			@nLin,080 psay Transf(TEMP->B2_QATU,"@E 99,999,999")
			@nLin,093 psay Transf(TEMP->B1_EMIN,"@E 999,999.99")
			@nLin,106 psay Transf(TEMP->B2_QATU - TEMP->B1_EMIN,"@E 999,999.99")
			@nLin,120 psay Transf(nCustoMedio,"@E 999,999.99")
			
			if (nInd := AScan(aTotGrp,{|x| x[1] = TEMP->B1_GRUPO})) == 0
				AAdd(aTotGrp,{TEMP->B1_GRUPO,TEMP->B2_QATU,nCustoMedio})
			else
				aTotGrp[nInd][2] += TEMP->B2_QATU
				aTotGrp[nInd][3] += nCustoMedio
			endif
			
			nTotQuantidade += TEMP->B2_QATU
			nTotCustoMedio += nCustoMedio
			nLin++
			nTotItem++
			
			U_SaltaFolha()
		endif
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	@nLin+1,000 psay "Foram listados: "+Transf(nTotItem,"@E 9999999")+" item(ns)."
	
	U_SaltaFolha()
	
	Totais()
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return

static function Totais()
	local aSortTotGrp := {}
	
	nLin++
	
	@nLin+1,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",132))
	
	nLin += 2
	
	@nLin,003 psay "GRUPO                                     QUANTIDADE       CUSTO MEDIO"
	
	nLin++
	
	aSortTotGrp := ASort(aTotGrp,,,{|x,y| x[1] < y[1]})
	
	for i := 1 to Len(aSortTotGrp)
		@nLin,000 psay aSortTotGrp[i][1]
		@nLin,006 psay If(SBM->(DbSeek(xFilial("SBM")+aSortTotGrp[i][1],.F.)),SBM->BM_DESC,"")
		@nLin,039 psay Transf(aSortTotGrp[i][2],"@E 9,999,999,999")
		@nLin,057 psay Transf(aSortTotGrp[i][3],"@E 99,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
	next
	
	nLin++
	
	@nLin,006 psay "T O T A L"
	@nLin,039 psay Transf(nTotQuantidade,"@E 9,999,999,999")
	@nLin,057 psay Transf(nTotCustoMedio,"@E 99,999,999.99")
return