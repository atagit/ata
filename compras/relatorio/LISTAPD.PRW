/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/05/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relação de produtos por projeto                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function LISTAPD()
	private aOrd    := {"Data de Entrega","Pedido de Compra"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "LISTPD"
	private Cabec1  := "N.PC   | ENTREGA  |       QUANT | UM | DESCRICAO                                                   |     P.UNIT |        P.TOTAL"
	private Cabec2  := ""
	private cDesc1  := "PRODUTOS POR PROJETO"
	private ContFun := 0
	private cString := "SC7"
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
	
	private nTotQuant := 0
	private nTotValor := 0
	private cProjeto := ""
	private aUnidade := {}
	private cProjIni := ""
	private cProjFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Projeto de                                        ³
	//³ mv_par02 - Projeto ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cProjIni := mv_par01
	cProjFin := mv_par02
	
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
	cQry := "select C7_NUM, C7_DATPRF, C7_QUANT, C7_UM, C7_PRODUTO, C7_DESCRI, C7_PRECO, C7_TOTAL, C7_ITEM, C7_CLVL "
	cQry += "from "+RetSqlName("SC7")+" "
	cQry += "where (C7_CLVL between '"+cProjIni+"' and '"+cProjFin+"') and D_E_L_E_T_ <> '*' "
	
	do case 
		case nOrdem == 1
			cQry += "order by C7_CLVL, C7_DATPRF, C7_NUM, C7_ITEM"
		case nOrdem == 2
			cQry += "order by C7_CLVL, C7_NUM, C7_DATPRF, C7_ITEM"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//N.PC   | ENTREGA  |       QUANT | UM | DESCRICAO                                                   |     P.UNIT |        P.TOTAL
	//999999   99/99/99   99999999.99   UN   999999 - AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999.99   999,999,999.99
	//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//          1         2         3         4         5         6         7         8         9        10        11        12
	
	nLin++
	cProjeto := TEMP->C7_CLVL
	
	@nLin,000 psay U_Negrito(.T.)+AllTrim(cProjeto)+" - "+If(CTH->(DbSeek(xFilial("CTH")+cProjeto,.F.)),CTH->CTH_DESC01," ")+U_Negrito(.F.)
	
	while !TEMP->(Eof())
		if cProjeto <> TEMP->C7_CLVL
			TotalUnidade()
			
			nTotQuant := 0
			nTotValor := 0
			aUnidade := {}
			nLin := 55
			
			U_SaltaFolha()
			
			nLin++
			cProjeto := TEMP->C7_CLVL
			
			@nLin,000 psay U_Negrito(.T.)+AllTrim(cProjeto)+" - "+If(CTH->(DbSeek(xFilial("CTH")+cProjeto,.F.)),CTH->CTH_DESC01," ")+U_Negrito(.F.)
		endif
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay TEMP->C7_NUM
		@nLin,009 psay U_ConvData(TEMP->C7_DATPRF,"yy")
		@nLin,020 psay Transf(TEMP->C7_QUANT,"@E 99999999.99")
		@nLin,034 psay TEMP->C7_UM
		@nLin,039 psay Left(TEMP->C7_PRODUTO,6)+" - "+Left(TEMP->C7_DESCRI,30)
		@nLin,101 psay Transf(TEMP->C7_PRECO,"@E 999,999.99")
		@nLin,114 psay Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")
		
		nTotQuant += TEMP->C7_QUANT
		nTotValor += TEMP->C7_TOTAL
		
		if (nInd := AScan(aUnidade,{|x| x[1] = TEMP->C7_UM})) == 0
			AAdd(aUnidade,{TEMP->C7_UM,TEMP->C7_QUANT,TEMP->C7_TOTAL})
		else
			aUnidade[nInd][2] += TEMP->C7_QUANT
			aUnidade[nInd][3] += TEMP->C7_TOTAL
		endif
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	TotalUnidade()
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function TotalUnidade()
	U_SaltaFolha()
	
	nLin += 2
	
	@nLin,095 psay "TOTAL"
	@nLin,114 psay Transf(nTotValor,"@E 999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "TOTAL P/ UNIDADE"
	@++nLin,000 psay "---------------------------------"
	@++nLin,000 psay "           QUANT            TOTAL"
	
	nLin++
	
	for i := 1 to Len(aUnidade)
		//           QUANT            TOTAL
		//UN   99999999,99   999,999,999.99
		//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		//          1         2         3         4         5         6         7         8         9        10
		
		@nLin,000 psay aUnidade[i][1]
		@nLin,005 psay Transf(aUnidade[i][2],"@E 99999999.99")
		@nLin,019 psay Transf(aUnidade[i][3],"@E 999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
	next
return