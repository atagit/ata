/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 18/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de erros na importacao do API               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function RELERRAPI()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "IMPAPI"
	private Cabec1  := "EMP CODIGO  TIP  PRODUTO  BAIXA               QUANTD  PROJETO  NUMCR         ID  ERROR"
	private Cabec2  := ""
	private cDesc1  := "ERROS NA IMPORTACAO DA API"
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Baixa de                                          ³
	//³ mv_par02 - BAixa ate                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,lDic,aOrd,,Tamanho,,lFilter)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem := aReturn[8]
	
	cBaixaDe := DToS(mv_par01)
	cBaixaAte := DToS(mv_par02)
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
return

static function Impr()
	local cQry := ""
	local nTotReg := 0
	local aStru := {}
	
	if Select("API") > 0
		API->(DbCloseArea())
	endif
	
	cQry := "select tipo, produto, numcr, quantd, baixa, projeto, id, empresa, codigo, error "
	cQry += "from [DADOSATF].dbo.TBLAPI "
	cQry += "where (baixa between '"+cBaixaDe+"' and '"+cBaixaAte+"') and erro = 'S'"
	cQry += "order by baixa"
	
	tcquery cQry new alias "API"
	count to nTotReg
	
	ProcRegua(nTotReg)
	DbSelectArea("API")
	API->(DbGoTop())
	
	cCbcRef := "Periodo: "+U_ConvData(cBaixaDe)+" a "+U_ConvData(cBaixaAte)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	EMP CODIGO  TIP  PRODUTO  BAIXA               QUANTD  PROJETO  NUMCR         ID  ERROR
//	99  999999  999  AAA999   99/99/99  999,999,999.9999  999999   14120503  999999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12
	
	while !API->(Eof())
		@nLin,000 psay API->empresa
		@nLin,004 psay Trans(API->codigo,"@E 999999")
		@nLin,012 psay API->tipo
		@nLin,017 psay API->produto
		@nLin,026 psay U_ConvData(API->baixa,"yy")
		@nLin,036 psay Transf(API->quantd,"@E 999,999,999.9999")
		@nLin,054 psay API->projeto
		@nLin,063 psay API->numcr
		@nLin,073 psay Transf(API->id,"@E 999999")
		@nLin,081 psay U_MERRORAPI(API->error)
		
		nLin++
		
		IncProc()
		U_SaltaFolha()
		API->(DbSkip())
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	API->(DbCloseArea())
	
	set device to screen
	
	if aReturn[5] == 1
		DbCommitAll()
		
		set printer to
		
		OurSpool(wnrel)
	endif
	
	MS_Flush()
return