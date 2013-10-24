/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/10/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Saldo em estoque com estoque minimo e maximo          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELEST()
	private aOrd    := {"Codigo","Descricao","Grupo","Est. Minimo","Est. Maximo","Material"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELEST"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "SALDO EM ESTOQUE"
	private ContFun := 0
	private cString := "SB2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nTotGrp := {}
	
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
	private nTpImpr := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Produto de                                        ³
	//³ mv_par02 - Produto ate                                       ³
	//³ mv_par03 - Qtd Negativo (1-sim/2-nao)                        ³
	//³ mv_par04 - Qtd Zerada (1-sim/2-nao)                          ³
	//³ mv_par05 - Grupo                                             ³
	//³ mv_par06 - Armazem de                                        ³
	//³ mv_par07 - Armazem ate                                       ³
	//³ mv_par08 - Imprimir (1-estoque/2-preco/3-gerencial)          ³
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
	nTpImpr := mv_par08
	
	if nTpImpr == 1
		Cabec1 := "CODIGO  TP  GRUPO  DESCRICAO                                      MATERIAL         UN  AMZ  QUANTIDADE  EST MINIMO  EST MAXIMO"
	elseif nTpImpr == 2
		Cabec1 := "CODIGO  TP  GRUPO  DESCRICAO                                      MATERIAL         UN  AMZ  QUANTIDADE   PRECO UNT       TOTAL"
	endif
	
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
	
	cQry := "select B2_COD, B1_DESC, B1_TIPO, B1_GRUPO, B1_UM, B2_QATU, B1_EMIN, B1_EMAX, B2_LOCAL, B2_VATU1, B1_MATERIA "
	cQry += "from "+RetSqlName("SB2")+" SB2 inner join "+RetSqlName("SB1")+" SB1 on (SB2.B2_COD = SB1.B1_COD and SB2.B2_LOCAL = SB1.B1_LOCPAD) "
	cQry += "where (B2_COD between '"+cPrdIni+"' and '"+cPrdFin+"') and (B2_LOCAL between '"+cArmIni+"' and '"+cArmFin+"') and SB2.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SB1.B1_MSBLQL <> '1' "
	
	do case 
		case nOrdem == 1
			cQry += "order by B2_COD"
		case nOrdem == 2
			cQry += "order by B1_DESC"
		case nOrdem == 3
			cQry += "order by B1_GRUPO"
		case nOrdem == 4
			cQry += "order by B1_EMIN"
		case nOrdem == 5
			cQry += "order by B1_EMAX"
		case nOrdem == 6
			cQry += "order by B1_MATERIA"
		otherwise
			cQry += "order by B2_COD"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	while !TEMP->(Eof())
		if nQtdNeg == 2
			if TEMP->B2_QATU < 0 ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if nQtdZer == 2
			if TEMP->B2_QATU = 0 ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if Empty(cGrp)
			cGrp := '*'
		endif
		
		if AllTrim(cGrp) == '*' .or. TEMP->B1_GRUPO $ cGrp
			nPrecoUnit := TEMP->B2_VATU1 / TEMP->B2_QATU
			
			if nTpImpr <> 3
				@nLin,000 psay Left(TEMP->B2_COD,8)
				@nLin,008 psay TEMP->B1_TIPO
				@nLin,012 psay TEMP->B1_GRUPO
				@nLin,019 psay Left(TEMP->B1_DESC,45)
				@nLin,066 psay TEMP->B1_MATERIA
				@nLin,083 psay TEMP->B1_UM
				@nLin,087 psay TEMP->B2_LOCAL
				@nLin,092 psay Transf(TEMP->B2_QATU,"@E 999,999.99")
				
				if nTpImpr == 1
					@nLin,104 psay Transf(TEMP->B1_EMIN,"@E 999,999.99")
					@nLin,116 psay Transf(TEMP->B1_EMAX,"@E 999,999.99")
				elseif nTpImpr ==2
					@nLin,104 psay Transf(nPrecoUnit,"@E 999,999.99")
					@nLin,116 psay Transf(TEMP->B2_VATU1,"@E 999,999.99")
				endif
			endif
			
			if (nInd := AScan(nTotGrp,{|x| x[1] = TEMP->B1_GRUPO})) == 0
				AAdd(nTotGrp,{TEMP->B1_GRUPO,TEMP->B2_QATU,nPrecoUnit,TEMP->B2_VATU1})
			else
				nTotGrp[nInd][2] += TEMP->B2_QATU
				nTotGrp[nInd][3] += nPrecoUnit
				nTotGrp[nInd][4] += TEMP->B2_VATU1
			endif
			
			if nTpImpr <> 3
				nLin++
				nTotItem++
			endif
			
			U_SaltaFolha()
		endif
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	if nTpImpr <> 3
		@nLin+1,000 psay "Foram listados: "+Transf(nTotItem,"@E 9999999")+" item(ns)."
	endif
	
	U_SaltaFolha()
	
	Totais()
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return

static function Totais()
	local nTotalQtd := 0
	local nTotalPrc := 0
	local aSortTotGrp := {}
	
	nLin++
	
	@nLin+1,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",132))
	
	nLin += 2
	
	@nLin,000 psay "GRUPO                                        QUANTIDADE         PRECO UNT (MED)                 TOTAL"
	
	nLin++
	
	aSortTotGrp := ASort(nTotGrp,,,{|x,y| x[1] < y[1]})
	
	for i := 1 to Len(aSortTotGrp)
		@nLin,000 psay aSortTotGrp[i][1]
		@nLin,006 psay If(SBM->(DbSeek(xFilial("SBM")+aSortTotGrp[i][1],.F.)),SBM->BM_DESC," ")
		@nLin,042 psay Transf(aSortTotGrp[i][2],"@E 99,999,999.99")
		@nLin,066 psay Transf((aSortTotGrp[i][4] / aSortTotGrp[i][2]),"@E 99,999,999.99")
		@nLin,085 psay Transf(aSortTotGrp[i][4],"@E 9,999,999,999.99")
		
		nLin++
		
		nTotalQtd += aSortTotGrp[i][2]
		nTotalPrc += aSortTotGrp[i][4]
		
		U_SaltaFolha()
	next
	
	nLin += 1
	
	@nLin,006 psay "T O T A L"
	@nLin,042 psay Transf(nTotalQtd,"@E 99,999,999.99")
	@nLin,085 psay Transf(nTotalPrc,"@E 9,999,999,999.99")
return