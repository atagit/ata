/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 06/05/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao das notas de entrada                          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function NOTASE()
	private aOrd    := {"Nota Fiscal","Data Digitacao","Fornecedor"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "NOTASE"
	private Cabec1  := "CODIGO LJ RAZAO SOCIAL                              DDD TELEFONE CONTATO"
	private Cabec2  := ""
	private cDesc1  := "RELACAO DE NOTAS FISCAIS (ENTRADA)"
	private ContFun := 0
	private cString := "SD1"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
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
	
	private cDataDe := ""
	private cDataAte := ""
	private cNotaDe := ""
	private cNotaAte := ""
	private cSerieDe := ""
	private cSerieAte := ""
	private cFornecDe := ""
	private cFornecAte := ""
	private nListItens := 0
	private cTesDe := ""
	private cTesAte := ""
	private cProdDe := ""
	private cProdAte := ""
	private cArmzDe := ""
	private cArmzAte := ""
	private cGrupoDe := ""
	private cGrupoAte := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ ------------------------------------------------------------ ³
	//³ mv_par01 - Digitacao de                                      ³
	//³ mv_par02 - Digitacao ate                                     ³
	//³ mv_par03 - Nota de                                           ³
	//³ mv_par04 - Nota ate                                          ³
	//³ mv_par05 - Serie de                                          ³
	//³ mv_par06 - Serie ate                                         ³
	//³ mv_par07 - Fornecedor de                                     ³
	//³ mv_par08 - Fornecedor ate                                    ³
	//³ mv_par09 - Listar Itens (1-Nao/2-Sim)                        ³
	//³ mv_par19 - TES de                                            ³
	//³ mv_par11 - TES ate                                           ³
	//³ mv_par12 - Produto de                                        ³
	//³ mv_par13 - Produto ate                                       ³
	//³ mv_par14 - Armazem de                                        ³
	//³ mv_par15 - Armazem ate                                       ³
	//³ mv_par16 - Grupo de                                          ³
	//³ mv_par17 - Grupo Ate                                         ³
	//³ ------------------------------------------------------------ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDataDe := DToS(mv_par01)
	cDataAte := DToS(mv_par02)
	cNotaDe := mv_par03
	cNotaAte := mv_par04
	cSerieDe := mv_par05
	cSerieAte := mv_par06
	cFornecDe := mv_par07
	cFornecAte := mv_par08
	nListItens := mv_par09
	cTesDe := mv_par10
	cTesAte := mv_par11
	cProdDe := mv_par12
	cProdAte := mv_par13
	cArmzDe := mv_par14
	cArmzAte := mv_par15
	cGrupoDe := mv_par16
	cGrupoAte := mv_par17
	
	if nListItens == 1
		Processa({|| Impr()},"","Aguarde processando...",lAborta)
	else
		Processa({|| Impr1()},"","Aguarde processando...",lAborta)
	endif
	
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
	cQry := "select D1_DOC, D1_SERIE, D1_DTDIGIT, D1_FORNECE, D1_LOJA, F1_COND, D1_VALICM, D1_VALIPI, D1_TOTAL "
	cQry += "from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SF1")+" SF1 on (D1_DOC = F1_DOC and D1_SERIE = F1_SERIE and D1_FORNECE = F1_FORNECE and D1_LOJA = F1_LOJA) "
	cQry += "where (D1_DTDIGIT between '20140101' and '20141231') and (D1_DOC between '' and 'ZZZZZZZZZ') and (D1_SERIE between '' and 'ZZZ') and (D1_TES between '' and 'ZZZ') and (D1_FORNECE between '000188' and '000188') and (D1_COD between '' and 'ZZZZZZZZZZ') and (D1_LOCAL between '' and 'ZZ') and (D1_GRUPO between '' and 'ZZZZ') and SD1.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' "
	
	do case 
		case nOrdem == 1
			cQry += "order by A2_COD, A2_LOJA"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, A2_COD, A2_LOJA"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	if !Empty(cSituacao)
		DbSelectArea("SX5")
		SX5->(DbGoTop())
		
		if SX5->(DbSeek(xFilial("SX5")+"ST"+cSituacao,.F.))
			cCondicao := "TEMP->A2_AVALIAC "+AllTrim(SX5->X5_DESCSPA)+" .and. TEMP->A2_AVALIAC "+AllTrim(SX5->X5_DESCENG)
		endif
	endif
	
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//FORNECEDOR                              | ULT. COMP  | CRIT | PE. | QT. | ESP | ID. | CTF | TOTAL | STATUS
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//          1         2         3         4         5         6         7         8         9        10
	
	while !TEMP->(Eof())
		if !Empty(cCondicao)
			if !(&(cCondicao)) ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		if cCritico <> "A"
			if TEMP->A2_CRITICO <> cCritico ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		nLin++
		
		@nLin,000 psay TEMP->A2_COD+"/"+TEMP->A2_LOJA+" "+TEMP->A2_NREDUZ
		@nLin,042 psay U_ConvData(TEMP->A2_ULTCOM)
		@nLin,055 psay IIf(TEMP->A2_CRITICO == "S","SIM","NAO")
		@nLin,062 psay Transf(TEMP->A2_AVPRZ,"@R 9.9")
		@nLin,068 psay Transf(TEMP->A2_AVIDENT,"@R 9.9")
		@nLin,074 psay Transf(TEMP->A2_AVESPEC,"@R 9.9")
		@nLin,080 psay Transf(TEMP->A2_AVQUANT,"@R 9.9")
		@nLin,086 psay Transf(TEMP->A2_AVCERTI,"@R 9.9")
		@nLin,092 psay Transf(TEMP->A2_AVALIAC,"@R 9.9")
		
		do case
			case TEMP->A2_AVALIAC == 0
				cStatus := "NAO AVALIADO"
			case TEMP->A2_AVALIAC < 2
				cStatus := "DESQUALIFICADO"
			case TEMP->A2_AVALIAC < 3
				cStatus := "COM RESTRICAO"
			case TEMP->A2_AVALIAC < 4
				cStatus := "NORMAL"
			otherwise
				cStatus := "PREFERENCIAL"
		endcase
		
		@nLin,100 psay cStatus
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return