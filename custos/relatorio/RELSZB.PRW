/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de Códigos de Despesas                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"

User Function RELSZB()
	private aOrd    := {"Cod. Despesas"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := ""
	private Cabec1  := "       CODIGO DESPESA                                   UNIDADE"
	private Cabec2  := ""
	private cDesc1  := "CODIGOS DE DESPESAS-CUSTOS"
	private ContFun := 0
	private cString := "SZB"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private nTamanho := IIf(Tamanho == "G",220,132)
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
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
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
	Dbselectarea("SZB")
	DbSetOrder(1)
	ProcRegua(SZB->(RecCount()))
	SZB->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	while !SZB->(Eof())
		if Right(SZB->ZB_CODESP,3) == "999" ; SZB->(DbSkip()) ; loop ; endif
		
		if SZB->ZB_TITULO == "1"
			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay SZB->ZB_CODESP+"-"+Left(SZB->ZB_DESC,40)
			
			nLin++
			
			U_SaltaFolha()
			              
			@nLin,000 psay Replicate("-",80)
			
			nLin++
			
			U_SaltaFolha()
   			SZB->(DbSkip())
   			
			loop
		endif
		
		@nLin,007 psay SZB->ZB_CODESP
		@nLin,014 psay Left(SZB->ZB_DESC,40)
		@nLin,059 psay SZB->ZB_UNID
		
		nLin++
		
		U_SaltaFolha()
		IncProc()
		SZB->(DbSkip())
	enddo
return