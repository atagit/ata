/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/05/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Lista de produtos inventariado                        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function LISTINV()
	private aOrd    := {"Codigo do Produto","Descricao do Produto"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "LISINV"
	private Cabec1  := ""
	private Cabec2  := "CODIGO  DESCRICAO                                           TP  GRUPO  UN           QUANT      VL. INVENT  DOCUMENTO"
	private cDesc1  := "LISTAGEM PARA INVENTARIAR"
	private ContFun := 0
	private cString := "SB7"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	private lFilter := .F.
	private lDic := .F.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cDataDe := ""
	private cProdDe := ""
	private cProdAte := ""
	private cArmzDe := ""
	private cArmzAte := ""
	private cGrupoDe := ""
	private cGrupoAte := ""
	private nQtdZerado := 0
	private nCustMedio := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ ------------------------------------------------------------ ³
	//³ mv_par01 - Data do Inventario                                ³
	//³ mv_par02 - Produto de                                        ³
	//³ mv_par03 - Produto ate                                       ³
	//³ mv_par04 - Armazem de                                        ³
	//³ mv_par05 - Armazem ate                                       ³
	//³ mv_par06 - Grupo de                                          ³
	//³ mv_par07 - Grupo ate                                         ³
	//³ mv_par08 - Quant. Zerada (1-Nao/2-Sim)                       ³
	//³ mv_par09 - Usar Custo Medio (1-Atual/2-Ult.Fechamento)       ³
	//³ ------------------------------------------------------------ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,lDic,aOrd,,Tamanho,,lFilter)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDataDe := DToS(mv_par01)
	cProdDe := mv_par02
	cProdAte := mv_par03
	cArmzDe := mv_par04
	cArmzAte := mv_par05
	cGrupoDe := mv_par06
	cGrupoAte := mv_par07
	nQtdZerado := mv_par08
	nCustMedio := mv_par09
	
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
	local nValor := 0
	local nCont := 0
	local nTotValor := 0
	local nTotCont := 0
	
	Cabec1 := "INVENTARIO: "+U_ConvData(cDataDe)
	cCampoCM := IIf(nCustMedio == 1,"B2_CM1","B2_CMFIM1")
	cCondicao := IIf(nQtdZerado == 1,"and B7_QUANT > 0 ","")
	
	cQry := "select B7_DOC, B7_DATA, B7_COD, B1_DESC, B7_TIPO, B1_GRUPO, B1_UM, B7_LOCAL, B7_QUANT, (B7_QUANT * "+cCampoCM+") as VALOR, B2_QATU, B2_VATU1, "+cCampoCM+" as VLCUSTM "
	cQry += "from "+RetSqlName("SB7")+" SB7 inner join "+RetSqlName("SB1")+" SB1 on (B7_COD = B1_COD) "
	cQry += "	inner join "+RetSqlName("SB2")+" SB2 on (B7_COD = B2_COD and B7_LOCAL = B2_LOCAL) "
	cQry += "where B7_DATA = '"+cDataDe+"' and (B7_COD between '"+cProdDe+"' and '"+cProdAte+"') and (B7_LOCAL between '"+cArmzDe+"' and '"+cArmzAte+"') and (B1_GRUPO between '"+cGrupoDe+"' and '"+cGrupoAte+"') "+cCondicao+"and SB7.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SB2.D_E_L_E_T_ <> '*' "
	
	do case
		case nOrdem == 1
			cQry += "order by B7_LOCAL, B7_COD"
		otherwise
			cQry += "order by B7_LOCAL, B1_DESC"
	endcase
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	//CODIGO  DESCRICAO                                           TP  GRUPO  UN           QUANT      VL. INVENT  DOCUMENTO
	//AAA999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  AA  9999   AA  999,999,999.99  999,999,999.99  AAA999999
	//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//          1         2         3         4         5         6         7         8         9        10        11        12
	
	while !TEMP->(Eof())
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
		@nLin,000 psay TEMP->B7_LOCAL+" --> "+IIf(SX5->(DbSeek(xFilial("SX5")+"AM"+TEMP->B7_LOCAL,.F.)),AllTrim(SX5->X5_DESCRI),"")
		
		cArmazem := TEMP->B7_LOCAL
		nLin += 2
		
		while !TEMP->(Eof()) .and. TEMP->B7_LOCAL == cArmazem
			@nLin,000 psay IIf(Len(AllTrim(TEMP->B7_COD)) == 6,Left(TEMP->B7_COD,6),"***")
			@nLin,008 psay TEMP->B1_DESC
			@nLin,060 psay TEMP->B7_TIPO
			@nLin,064 psay TEMP->B1_GRUPO
			@nLin,071 psay TEMP->B1_UM
			@nLin,075 psay Transf(TEMP->B7_QUANT,"@E 999,999,999.99")
			@nLin,091 psay Transf(TEMP->VALOR,"@E 999,999,999.99")
			@nLin,107 psay TEMP->B7_DOC
			
			nLin++
			nCont++
			nTotCont++
			nValor += TEMP->VALOR
			nTotValor += TEMP->VALOR
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "REGISTRO(S) --> "+AllTrim(Str(nCont))
		@nLin,078 psay "T O T A L"
		@nLin,091 psay Transf(nValor,"@E 999,999,999.99")
		
		nValor := 0 ; nCont := 0
	enddo
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "REGISTRO(S) GERAL  -->  "+AllTrim(Str(nTotCont))
	@nLin,071 psay "T O T A L  GERAL"
	@nLin,091 psay Transf(nTotValor,"@E 999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return