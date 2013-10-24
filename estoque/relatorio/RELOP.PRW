/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 29/12/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relação de Ordem de Produção                          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELOP()
	private aOrd    := {"Ord. Producao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELOP"
	private Cabec1  := "PRODUTO                                  |      QUANTIDADE"
	private Cabec2  := ""
	private cDesc1  := "RELACAO ORDEM DE PRODUCAO"
	private cString := "SC2"
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
	
	private cOpIni := ""
	private cOpFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - O.P. de                                           ³
	//³ mv_par02 - O.P. ate                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cOpIni := mv_par01
	cOpFin := mv_par02
	
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
	local nItem := 0
	local nTotal := 0
	
	cQry := "select C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_LOCAL, SB11.B1_DESC as DESC1, C2_QUANT, C2_EMISSAO, D4_COD, D4_LOCAL, SB12.B1_DESC as DESC2, SB12.B1_UM, D4_QTDEORI "
	cQry += "from "+RetSqlName("SC2")+" SC2 inner join "+RetSqlName("SD4")+" SD4 on (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN = SD4.D4_OP) inner join "+RetSqlName("SB1")+" SB11 on (SC2.C2_PRODUTO = SB11.B1_COD) inner join "+RetSqlName("SB1")+" SB12 on (SD4.D4_COD = SB12.B1_COD) "
	cQry += "where (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN between '"+cOpIni+"' and '"+cOpFin+"') and SC2.D_E_L_E_T_ <> '*' and SD4.D_E_L_E_T_ <> '*' "
	
	do case 
		case nOrdem == 1
			cQry += "order by C2_NUM, C2_ITEM, C2_SEQUEN, D4_COD"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	while !TEMP->(Eof())
		cOP := TEMP->(C2_NUM+C2_ITEM+C2_SEQUEN)
		
		@nLin,000 psay U_Negrito(.T.)+TEMP->(C2_NUM+C2_ITEM+C2_SEQUEN)+" - "+AllTrim(TEMP->C2_PRODUTO)+" "+Left(TEMP->DESC1,50)+U_Negrito(.F.)
		@nLin,079 psay U_ConvData(TEMP->C2_EMISSAO,"yyyy")
		@nLin,093 psay Transf(TEMP->C2_QUANT,"@E 999,999,999.999")
		
		nLin++
		
		while cOP == TEMP->(C2_NUM+C2_ITEM+C2_SEQUEN)

//		99999999999 - 999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        99/99/9999    999.999.999,999
//		PRODUTO                                     |      QUANTIDADE
// 		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11
//		999999 99 AA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999.999
		
			@nLin,000 psay AllTrim(TEMP->D4_COD)
			@nLin,007 psay TEMP->D4_LOCAL
			@nLin,010 psay TEMP->B1_UM
			@nLin,013 psay Left(TEMP->DESC2,30)
			@nLin,046 psay Transf(TEMP->D4_QTDEORI,"@E 999,999,999.999")
			
			nTotal += TEMP->D4_QTDEORI
			
			nItem++
			nLin++
			
			U_SaltaFolha()
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		@nLin,000 psay "Item(s): "+AllTrim(Str(nItem))
		@nLin,037 psay "TOTAL..: "+Transf(nTotal,"@E 999,999,999.999")
		
		nTotal := 0
		nItem := 0
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return