/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/11/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relação de protocolos das notas fiscais               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELPROT()
	private aOrd    := {"Protocolo","Nota Fiscal","Nome Fornecedor"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PROTOC"
	private Cabec1  := "C.R.    | FORNECEDOR                               | N.F.          | EMISSAO NF |          TOTAL | PED COMPRA"
	private Cabec2  := ""
	private cDesc1  := "PROTOCOLO"
	private ContFun := 0
	private cString := "SF1"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "RELPROT"
	private lAborta := .T.
	
	private cQry    := ""
	private nLin	:= 0
	private nPag	:= 1
	
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
	local nTotItem := 0
	local cProjeto := ""
	
	cQry := "select SF1.F1_CR, SF1.F1_FORNECE, SF1.F1_LOJA, SA2.A2_NREDUZ, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_EMISSAO, SF1.F1_VALBRUT "
	cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SA2")+" SA2 on (SF1.F1_FORNECE = SA2.A2_COD and SF1.F1_LOJA = SA2.A2_LOJA) "
	cQry += "where (SF1.F1_CR between '"+mv_par01+"' and '"+mv_par02+"') and SF1.F1_CR <> '' and SF1.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by SF1.F1_CR"
	elseif nOrdem == 2
		cQry += "order by SF1.F1_DOC, SF1.F1_SERIE"
	elseif nOrdem == 3
		cQry += "order by SA2.A2_NREDUZ, SF1.F1_CR"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	Cbc()
	
	while !TEMP->(Eof())
		@nLin,003 psay TEMP->F1_CR
		@nLin,013 psay TEMP->F1_FORNECE+"/"+TEMP->F1_LOJA+" "+TEMP->A2_NREDUZ
		@nLin,056 psay TEMP->F1_DOC+"-"+TEMP->F1_SERIE
		@nLin,072 psay U_ConvData(TEMP->F1_EMISSAO)
		@nLin,085 psay Transf(TEMP->F1_VALBRUT,"@E 999,999,999.99")
 		
		cProjeto := PedidoCompra(TEMP->F1_DOC,TEMP->F1_SERIE)
		
		@nLin,102 psay MemoLine(cProjeto,28,1)
		
		if MLCount(cProjeto,28) > 1
			for i := 2 to MLCount(cProjeto,28)
				nLin++
				
				@nLin,102 psay MemoLine(cProjeto,28,i)
			next
		endif
		
		nLin++
		nTotItem++
		
		if nLin > 50
			Assinatura()
			
			nPag++
			Cbc()
		endif
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	
	@nLin+1,003 psay "Foram listados: "+Transf(nTotItem,"@E 9999999")+" item(ns)."
	
	if nLin > 50
		Assinatura()
		
		nPag++
		Cbc()
	endif
	
	Assinatura()
return

static function Cbc()
	@000,000 psay U_TamPag(66)+U_Reduz(0)
	
	do case
		case SubStr(cNumEmp,1,2) == "01"
			@001,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T A"+U_Expande(0)+U_AltCar(12)
		case SubStr(cNumEmp,1,2) == "02"
			@001,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T F"+U_Expande(0)+U_AltCar(12)
	endcase
	
	@001,020 psay U_Expande(5)+"PROTOCOLO"+U_Expande(0)
	
	do case
		case SubStr(cNumEmp,1,2) == "01"
			@002,001 psay U_Reduz(5)+"IND MEC DE  USINAGEM"+U_Reduz(0)
		case SubStr(cNumEmp,1,2) == "02"
			@002,001 psay U_Reduz(5)+"ESTRUTURAS METALICAS"+U_Reduz(0)
	endcase
	
	@002,067 psay U_Reduz(5)+"Emissao: "+U_ConvData(DToS(Date()))+U_Reduz(0)
	@002,090 psay U_Reduz(4)+" "+U_Reduz(0)
	
	nLin := 004
	
	@nLin  ,000 psay U_15Cpi(.T.)
	@nLin  ,003 psay "C.R.    | FORNECEDOR                               | N.F.          | EMISSAO NF |          TOTAL | PED COMPRA"
	@nLin+1,002 psay Replicate("-",132)
	
	nLin := 006
return

static function Assinatura()
	nLin := 55
	
	@nLin+1,003 psay Padc("         Elaborado por                                  Recebido por           ",132)
	@nLin+2,003 psay Padc("_______________________________                _______________________________ ",132)
	@nLin+3,003 psay Padc("           /       /                                      /       /            ",132)
return

static function PedidoCompra(cDoc,cSerie)
	local cPedido := ""
	
	cQry := "select distinct D1_CLVL "
	cQry += "from "+RetSqlName("SD1")+" "
	cQry += "where D1_DOC = '"+cDoc+"' and D1_SERIE = '"+cSerie+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by D1_CLVL"
	
	tcquery cQry new alias "PRJ"
	DbSelectArea("PRJ")
	
	PRJ->(DbGoTop())
	
	cPedido += AllTrim(PRJ->D1_CLVL)
	
	PRJ->(DbSkip())
	
	while !PRJ->(Eof())
		cPedido += ","+AllTrim(PRJ->D1_CLVL)
		
		PRJ->(DbSkip())
	enddo
	
	PRJ->(DbCloseArea())
return (cPedido)