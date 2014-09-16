/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de baixa de materia prima da API              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function RELBAIAPI()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RBAIAPI"
	private Cabec1  := "CODIGO ARM DESCRICAO                                          EMISSAO            QUANTD  PROJETO  CODAPI  NUMSEQ"
	private Cabec2  := ""
	private cDesc1  := "BAIXAS DE MATERIA PRIMA"
	private ContFun := 0
	private cString := "SD3"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private nLastKey := 0
	private lFilter := .F.
	private lDic	:= .F.
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	private lExterior := .F.
	
	private cBaixaDe := CToD("")
	private cBaixaAte := CToD("")
	private cProdDe := ""
	private cProdAte := ""
	private cProjDe := ""
	private cProjAte := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Baixa de                                          ³
	//³ mv_par02 - Baixa ate                                         ³
	//³ mv_par03 - Produto de                                        ³
	//³ mv_par04 - Produto ate                                       ³
	//³ mv_par05 - Projeto de                                        ³
	//³ mv_par06 - Projeto ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,lDic,aOrd,,Tamanho,,lFilter)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem := aReturn[8]
	
	cBaixaDe := DToS(mv_par01)
	cBaixaAte := DToS(mv_par02)
	cProdDe := mv_par03
	cProdAte := mv_par04
	cProjDe := mv_par05
	cProjAte := mv_par06
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
return

static function Impr()
	local cQry := ""
	local nTotReg := 0
	local aStru := {}
	
	if Select("TEMP") > 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select D3_COD, D3_LOCAL, B1_DESC, D3_EMISSAO, D3_QUANT, D3_CLVL, D3_NUMSEQ, D3_CODAPI "
	cQry += "from "+RetSqlName("SD3")+" SD3 inner join "+RetSqlName("SB1")+" SB1 on (D3_COD = B1_COD) "
	cQry += "where (D3_EMISSAO between '"+cBaixaDe+"' and '"+cBaixaAte+"') and (D3_COD between '"+cProdDe+"' and '"+cProdAte+"') and (D3_CLVL between '"+cProjDe+"' and '"+cProjAte+"') and D3_CODAPI <> '' and SD3.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	cQry += "order by D3_EMISSAO, D3_CODAPI"
	
	tcquery cQry new alias "TEMP"
	count to nTotReg
	
	ProcRegua(nTotReg)
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	cCbcRef := "Periodo: "+U_ConvData(cBaixaDe)+" a "+U_ConvData(cBaixaAte)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	CODIGO ARM DESCRICAO                                          EMISSAO            QUANTD  PROJETO  CODAPI  NUMSEQ
//	999999 99  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 99/99/99 999,999,999.9999  999999   999999  999999
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12
	
	while !TEMP->(Eof())
		@nLin,000 psay Left(TEMP->D3_COD,6)
		@nLin,007 psay TEMP->D3_LOCAL
		@nLin,011 psay TEMP->B1_DESC
		@nLin,062 psay U_ConvData(TEMP->D3_EMISSAO,"yy")
		@nLin,071 psay Transf(TEMP->D3_QUANT,"@E 999,999,999.9999")
		@nLin,089 psay Left(TEMP->D3_CLVL,6)
		@nLin,098 psay Transf(Val(TEMP->D3_CODAPI),"@E 999999")
		@nLin,106 psay Transf(TEMP->D3_NUMSEQ,"@E 999999")
		
		nLin++
		
		IncProc()
		U_SaltaFolha()
		TEMP->(DbSkip())
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
	
	set device to screen
	
	if aReturn[5] == 1
		DbCommitAll()
		
		set printer to
		
		OurSpool(wnrel)
	endif
	
	MS_Flush()
return