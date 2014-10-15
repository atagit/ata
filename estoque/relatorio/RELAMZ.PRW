/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 23/09/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao dos almoxarifados                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELAMZ()
	private aOrd    := {"Codigo","Descricao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := ""
	private Cabec1  := "ARMAZEM  DESCRICAO"
	private Cabec2  := ""
	private cDesc1  := "RELACAO DE ALMOXARIFADO"
	private cString := "NNR"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nTotItem := 0
	private nTotGrp := {}
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
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
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select NNR_CODIGO, NNR_DESCRI "
	cQry += "from "+RetSqlName("NNR")+" "
	cQry += "where D_E_L_E_T_ <> '*' "
	cQry += IIf(nOrdem == 2,"order by NNR_DESCRI","order by NNR_CODIGO")
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	ARMAZEM  DESCRICAO
//	99       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12
	
	while !TEMP->(Eof())
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay TEMP->NNR_CODIGO
		@nLin,009 psay AllTrim(TEMP->NNR_DESCRI)
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return