/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 27/10/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Estatística de compra                                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _MES {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}

user function ESTCOM()
	private aOrd    := {"Codigo"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "ESTCOM"
	private Cabec1  := "CODIGO  | DESCRICAO                                  | UN | AMZ | SALDO      | PNT PEDIDO | QUANT REQ.  | QUANT APROV |"
	private Cabec2  := ""
	private cDesc1  := "HISTORICO DE MATERIAL"
	private ContFun := 0
	private cString := "SC1"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := cPerg
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
	
	private cPrdIni := ""
	private cPrdFin := ""
	private nQtdFor := 0
	private nQtdPed := 0
	private nQtdSol := 0
	private nPntPed := 0
	private nQtdNeg := 0
	private nQtdZer := 0
	private cGrp := ""
	private cArmIni := ""
	private cArmFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Produto de                                        ³
	//³ mv_par02 - Produto ate                                       ³
	//³ mv_par03 - Qtd Ult. Fornec.                                  ³
	//³ mv_par04 - Qtd Ult. Ped. Compra                              ³
	//³ mv_par05 - Qtd Solicitacoes                                  ³
	//³ mv_par06 - So do PNT Pedido (1-nao/2-sim)                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrdIni := mv_par01
	cPrdFin := mv_par02
	nQtdFor := mv_par03
	nQtdPed := mv_par04
	nQtdSol := mv_par05
	nPntPed := mv_par06
	
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
	
	if nPntPed == 1
		cQry1 := "select SB1.B1_COD "
		cQry1 += "from "+RetSqlName("SB1")+" SB1 inner join "+RetSqlName("SB2")+" SB2 on (SB1.B1_COD = SB2.B2_COD and SB1.B1_LOCPAD = SB2.B2_LOCAL) "
		cQry1 += "where (SB1.B1_COD between '"+cPrdIni+"' and '"+cPrdFin+"') and SB1.D_E_L_E_T_ <> '*' "
		cQry1 += "order by SB1.B1_COD"
		
		tcquery cQry1 New Alias "PROD"
		DbSelectArea("PROD")
		DbGoTop()
		
		while !PROD->(Eof())
			cProduto := PROD->B1_COD
			
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			Produto(cProduto)
			ConsumoMes(cProduto)
			Solicitacao(cProduto,nQtdSol)
	 		PedidoCompra(cProduto,nQtdPed)
			Fornecedores(cProduto,nQtdFor)
			
			Assinatura()
			U_Rdp(nRdpPag,cRdpLeg,Tamanho)
			
			PROD->(DbSkip())
		enddo
		
		DbSelectArea("PROD")
	else
		nCont1 := nQtdSol
		nCont2 := nQtdPed
		nCont3 := nQtdFor
		
		Pergunte("PNTPED",.T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parametros utilizados pelo programa                          ³
		//³ mv_par01 - Produto de                                        ³
		//³ mv_par02 - Produto ate                                       ³
		//³ mv_par03 - Qtd Negativo (1-sim/2-nao)                        ³
		//³ mv_par04 - Qtd Zerada (1-sim/2-nao)                          ³
		//³ mv_par05 - Grupo                                             ³
		//³ mv_par06 - Armazem de                                        ³
		//³ mv_par07 - Armazem ate                                       ³
		//³ mv_par08 - Ponto de Pedido (1-todos/2-somente)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cPrdIni := mv_par01
		cPrdFin := mv_par02
		nQtdNeg := mv_par03
		nQtdZer := mv_par04
		cGrp 	:= mv_par05
		cArmIni := mv_par06
		cArmFin := mv_par07
		nPntPed := mv_par08
		
		PontoPedido(nCont1,nCont2,nCont3)
	endif
return

static function Produto(cProduto)
	cQry := "select SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_LOCPAD, SB2.B2_QATU, SB1.B1_EMIN, SB1.B1_CEME "
	cQry += "from "+RetSqlName("SB1")+" SB1 inner join "+RetSqlName("SB2")+" SB2 on (SB1.B1_COD = SB2.B2_COD and SB1.B1_LOCPAD = SB2.B2_LOCAL) "
	cQry += "where SB1.B1_COD = '"+cProduto+"' and SB1.D_E_L_E_T_ <> '*' "
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	@++nLin,000 psay Left(TEMP->B1_COD,8)
	@nLin  ,010 psay TEMP->B1_DESC
	@nLin  ,056 psay TEMP->B1_UM
	@nLin  ,061 psay TEMP->B1_LOCPAD
	@nLin  ,067 psay Transf(TEMP->B2_QATU,"@E 999,999.99")
	@nLin  ,080 psay Transf(TEMP->B1_EMIN,"@E 999,999.99")
	@nLin  ,092 psay " ___________   ___________"
	@nLin+1,000 psay TEMP->B1_CEME
	
	TEMP->(DbCloseArea())
return

static function ConsumoMes(cProduto)
	local nMes := Month(Date())
	local nAno := Year(Date())
	local aMesAno := Array(12)
	local aQtdMes := Array(12)
	local nCol := 003
	
	cQry := "select * "
	cQry += "from "+RetSqlName("SB3")+" "
	cQry += "where B3_COD = '"+cProduto+"' and D_E_L_E_T_ <> '*' "
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	for i := 1 to nMes
		aMesAno[i] := _MES[i]+"/"+Right(Str(nAno,4),2)
		aQtdMes[i] := &("TEMP->B3_Q"+StrZero(i,2))
	next
	
	for i := 12 to nMes + 1 step -1
		aMesAno[i] := _MES[i]+"/"+Right(Str(nAno - 1,4),2)
		aQtdMes[i] := &("TEMP->B3_Q"+StrZero(i,2))
	next
	
	nLin += 3
	
	@nLin  ,000 psay U_Negrito(.T.)+"CONSUMO DOS 12 ULTIMOS MESES"+U_Negrito(.F.)
	@nLin+1,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",132))
	
	for i := 1 to 3
		@nLin+i+1,000 psay aMesAno[i]+":  "+Transf(aQtdMes[i],"@E 999,999.99")
		@nLin+i+1,026 psay "|"
		@nLin+i+1,034 psay aMesAno[i+3]+":  "+Transf(aQtdMes[i+3],"@E 999,999.99")
		@nLin+i+1,059 psay "|"
		@nLin+i+1,067 psay aMesAno[i+6]+":  "+Transf(aQtdMes[i+6],"@E 999,999.99")
		@nLin+i+1,092 psay "|"
		@nLin+i+1,100 psay aMesAno[i+9]+":  "+Transf(aQtdMes[i+9],"@E 999,999.99")
	next
	
	TEMP->(DbCloseArea())
return

static function Solicitacao(cProduto,nContador)
	local nCont := 1
	
	nLin := If(aReturn[5] == 1,17,16)
	
	cQry := "select distinct C1_NUM, C1_EMISSAO, C1_COTACAO, C1_PEDIDO "
	cQry += "from "+RetSqlName("SC1")+" "
	cQry += "where C1_PRODUTO = '"+cProduto+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by C1_NUM desc"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	@nLin  ,000 psay U_Negrito(.T.)+"SOLICITACAO DE COMPRA"+U_Negrito(.F.)
	@nLin+1,000 psay "NUM    | DT EMISSAO | COTACAO | PED COM |"
	@nLin+2,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",132))
	
	nLin += 2
	
	while !TEMP->(Eof()) .and. nCont <= nContador
		nLin++
		
		U_SaltaFolha()
		
		if !Empty(TEMP->C1_NUM)
			@nLin,000 psay TEMP->C1_NUM
			@nLin,009 psay U_ConvData(TEMP->C1_EMISSAO)
			@nLin,022 psay TEMP->C1_COTACAO
			@nLin,032 psay TEMP->C1_PEDIDO
		endif
		
		nCont++
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
return

static function PedidoCompra(cProduto,nContador)
	local nCont := 1
	local nQuant := 0
	local nTotal := 0
	
	nLin += 2
	
	U_SaltaFolha()
	
	cQry := "select SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_NOMFORN, SC7.C7_DATPRF, SC7.C7_QUANT, SC7.C7_PRECO, SB1.B1_EMIN, SC7.C7_TOTAL, SC7.C7_QUJE, SB1.B1_COD, SC7.C7_CONAPRO "
	cQry += "from "+RetSqlName("SB1")+" SB1 inner join "+RetSqlName("SB2")+" SB2 on (SB1.B1_COD = SB2.B2_COD and SB1.B1_LOCPAD = SB2.B2_LOCAL) inner join "+RetSqlName("SC7")+" SC7 on (SB1.B1_COD = SC7.C7_PRODUTO) "
	cQry += "where SB1.B1_COD = '"+cProduto+"' and SB1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*' "
	cQry += "order by SC7.C7_NUM desc"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	@nLin  ,000 psay U_Negrito(.T.)+"ULTIMOS PEDIDOS"+U_Negrito(.F.)
	@nLin+1,000 psay "NUM    | DT EMISSAO | FORNECEDOR                  | DT ENTREGA |       QUANT |      P UNIT |     PRC TOT |     QTD ENT | STS |"
	@nLin+2,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",132))
	
	nLin += 2
	
	while !TEMP->(Eof()) .and. nCont <= nContador
		nPedido := TEMP->C7_NUM
		nLin++
		
		U_SaltaFolha()
		
		if !Empty(TEMP->C7_NUM)
			@nLin,000 psay nPedido
			@nLin,009 psay U_ConvData(TEMP->C7_EMISSAO)
			@nLin,022 psay TEMP->C7_FORNECE+" "+Left(TEMP->C7_NOMFORN,20)
			@nLin,052 psay U_ConvData(TEMP->C7_DATPRF)
			@nLin,066 psay Transf(TEMP->C7_QUANT,"@E 999,999.99")
			@nLin,080 psay Transf(TEMP->C7_PRECO,"@E 999,999.99")
			@nLin,094 psay Transf(TEMP->C7_TOTAL,"@E 999,999.99")
			@nLin,108 psay Transf(TEMP->C7_QUJE,"@E 999,999.99")
			@nLin,122 psay TEMP->C7_CONAPRO
		endif
		
		nTotal += TEMP->C7_TOTAL
		nQuant += TEMP->C7_QUANT
		
		while nPedido == TEMP->C7_NUM .and. !Empty(TEMP->C7_NUM)
			TEMP->(DbSkip())
		enddo
		
		nCont++
	enddo
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,029 psay "T O T A L"
	@nLin,062 psay Transf(nQuant,"@E 999,999,999.99")
	@nLin,090 psay Transf(nTotal,"@E 999,999,999.99")
	
	TEMP->(DbCloseArea())
return

static function Fornecedores(cProduto,nContador)
	local nCont := 1
	
	nLin += 2
	
	U_SaltaFolha()
	
	cQry := "select SA5.A5_FORNECE, SA5.A5_LOJA, SA5.A5_NOMEFOR, SA2.A2_ULTCOM, SA2.A2_MSBLQL, SA5.A5_PRODUTO "
	cQry += "from "+RetSqlName("SA5")+" SA5 inner join "+RetSqlName("SA2")+" SA2 on (SA5.A5_FORNECE = SA2.A2_COD and SA5.A5_LOJA = SA2.A2_LOJA) "
	cQry += "where SA5.A5_PRODUTO = '"+cProduto+"' and SA5.D_E_L_E_T_ <> '*' "
	cQry += "order by SA5.A5_NOMEFOR"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	@nLin  ,000 psay U_Negrito(.T.)+"FORNECEDORES DO PRODUTO"+U_Negrito(.F.)
	@nLin+1,000 psay "COD/LOJ   | FORNECEDOR                               | STATUS     | ULT COMPRA |"
	@nLin+2,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",132))
	
	nLin += 2
	
	while !TEMP->(Eof()) .and. nCont <= nContador
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay TEMP->A5_FORNECE+"/"+TEMP->A5_LOJA
		@nLin,012 psay Left(TEMP->A5_NOMEFOR,30)
		
		if TEMP->A2_MSBLQL == "2"
			@nLin,055 psay "ATIVO"
		elseif TEMP->A2_MSBLQL == "1"
			@nLin,055 psay "INATIVO"
		endif
		
		@nLin,068 psay U_ConvData(TEMP->A2_ULTCOM)
		
		nCont++
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
return

static function Assinatura()
	nLin += 3
	
	U_SaltaFolha()
	
	@nLin+1,000 psay Padc("         Solicitado por                           Verificado por                            Aprovado por         ",132)
	@nLin+2,000 psay Padc("_______________________________          _______________________________          _______________________________",132)
	@nLin+3,000 psay Padc("           /       /                                /       /                                /       /           ",132)
return

static function PontoPedido(nCont1,nCont2,nCont3)
	cQry := "select B2_COD, B1_DESC, B1_TIPO, B1_GRUPO, B1_UM, B2_QATU, B1_EMIN, B2_LOCAL, B2_CM1 "
	cQry += "from "+RetSqlName("SB2")+" SB2 inner join "+RetSqlName("SB1")+" SB1 on (SB2.B2_COD = SB1.B1_COD) "
	cQry += "where (B2_COD between '"+cPrdIni+"' and '"+cPrdFin+"') and (B2_LOCAL between '"+cArmIni+"' and '"+cArmFin+"') and SB2.D_E_L_E_T_ <> '*' "
	cQry += "order by B2_COD"
	
	tcquery cQry new alias "PNT"
	DbSelectArea("PNT")
	
	PNT->(DbGoTop())
	ProcRegua(PNT->(RecCount()))
	
	while !PNT->(Eof())
		if nQtdNeg == 2
			if PNT->B2_QATU < 0 ; PNT->(DbSkip()) ; loop ; endif
		endif
		
		if nQtdZer == 2
			if (PNT->B2_QATU = 0) .and. (PNT->B1_EMIN <= 0) ; PNT->(DbSkip()) ; loop ; endif
		endif
		
		if nPntPed == 2
			if (PNT->B2_QATU - PNT->B1_EMIN) > 0 ; PNT->(DbSkip()) ; loop ; endif
		endif
		
		if Empty(cGrp)
			cGrp := '*'
		endif
		
		if AllTrim(cGrp) == '*' .or. PNT->B1_GRUPO $ cGrp
			cProduto := PNT->B2_COD
			
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			Produto(cProduto)
			ConsumoMes(cProduto)
			Solicitacao(cProduto,nCont1)
	 		PedidoCompra(cProduto,nCont2)
			Fornecedores(cProduto,nCont3)
			
			Assinatura()
			U_Rdp(nRdpPag,cRdpLeg,Tamanho)
		endif
		
		IncProc()
		PNT->(DbSkip())
	enddo
	
	DbSelectArea("PNT")
return