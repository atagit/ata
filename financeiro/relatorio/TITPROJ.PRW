/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/04/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de titulos baixados e abertos por projeto     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function TITPROJ()
	private aOrd    := {"Nota Fiscal/Emissao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "TITPRO"
	private Cabec1  := "EMISSAO"
	private Cabec2  := "    NOTA FISCAL       | TIP | FORNECEDOR                     | VENCTO     | BAIXA      |                  VALOR"
	private cDesc1  := "TITULOS POR PROJETO"
	private ContFun := 0
	private cString := "SE2"
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
	
	private cPrjIni := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ cPrjIni - Projeto de                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrjIni := mv_par01
	
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
	
	cQry := "select E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_BAIXA, E2_VALOR "
	cQry += "from "+RetSqlName("SE2")+" "
	cQry += "where E2_NUM+rtrim(E2_PREFIXO) in ( "
	cQry += "									select SF1.F1_DOC+rtrim(SF1.F1_SERIE) "
	cQry += "									from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SF1")+" SF1 on (SD1.D1_DOC = SF1.F1_DOC and SD1.D1_SERIE = SF1.F1_SERIE) "
	cQry += "									where D1_CLVL = '"+cPrjIni+"' and SD1.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' "
	cQry += "									group by SF1.F1_DOC, SF1.F1_SERIE, SD1.D1_CLVL) and D_E_L_E_T_ <> '*' "
	cQry += "order by E2_EMISSAO, E2_NUM, E2_PREFIXO, E2_PARCELA"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	cCbcRef := U_Negrito(.T.)+cPrjIni+"-"+If(CTH->(DbSeek(xFilial("CTH")+cPrjIni,.F.)),CTH->CTH_DESC01,"")+U_Negrito(.F.)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	EMISSAO
//	    NOTA FISCAL       | TIP | FORNECEDOR                     | VENCTO     | BAIXA      |                  VALOR
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		cEmissao := TEMP->E2_EMISSAO
		
		@nLin,000 psay U_Negrito(.T.)+U_ConvData(TEMP->E2_EMISSAO)+U_Negrito(.F.)
		
		while cEmissao == TEMP->E2_EMISSAO
			nLin++
			
			@nLin,004 psay TEMP->E2_NUM+"-"+TEMP->E2_PREFIXO+" "+TEMP->E2_PARCELA
			@nLin,024 psay TEMP->E2_TIPO
			@nLin,030 psay TEMP->E2_FORNECE+"-"+TEMP->E2_LOJA+" "+TEMP->E2_NOMFOR
			@nLin,063 psay U_ConvData(TEMP->E2_VENCREA)
			@nLin,076 psay U_ConvData(TEMP->E2_BAIXA)
			@nLin,089 psay Transf(TEMP->E2_VALOR,"@E 999,999,999,999,999.99")
			
			IncProc()
			
			nTotItem++
			
			U_SaltaFolha()
			
			TEMP->(DbSkip())
		enddo
		
		nLin++
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return