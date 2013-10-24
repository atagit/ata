/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 23/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de pedido de compras                        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _MAXCOL 100

user function RELPED()
	private aOrd    := {"Ped Compra"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELPED"
	private Cabec1  := ""
	private Cabec2  := "PEDIDO  ST  EMISSAO   FORNECEDOR            PROGRAMA  REALIZAD  ATRA  NOTA FISCAL    EMISSAO            TOTAL  COMPRADOR"
	private cDesc1  := "RELACAO DE PEDIDOS DE COMPRA EMITIDOS"
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
	
	private cDtIni := ""
	private cDtFin := ""
	private cForIni := ""
	private cForFin := ""
	private cComIni := ""
	private cComFin := ""
	private nPCReceb := 0
	private nRelGerenc := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
	//³ mv_par05 - Comprador de                                      ³
	//³ mv_par06 - Comprador ate                                     ³
	//³ mv_par07 - So PC Recebido (1-Nao/2-Sim)                      ³
	//³ mv_par08 - Rel Gerencial (1-Nao/2-Sim)                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cForIni := mv_par03
	cForFin := mv_par04
	cComIni := mv_par05
	cComFin := mv_par06
	nPCReceb := mv_par07
	nRelGerenc := mv_par08
	
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
	local aPedido := {}
	
	private nTotQuant := 0, nTotGerQuant := 0 ; nTotAtras := 0
	private nTotValor := 0, nTotGerValor := 0
	private aComprador := {}
	private aFornecedor := {}
	private aAtrasado := {}
	
	AFill(aAtrasado,0)
	
	DbSelectArea("SY1")
	SY1->(DbSetOrder(3))
	
	DbSelectArea("SZU")
	SZU->(DbSetOrder(2))
	
	do case
		case nPCReceb == 1 .and. nRelGerenc == 1
			cDesc1  := "RELACAO DE PEDIDOS DE COMPRA EMITIDOS"
		case nPCReceb == 2 .and. nRelGerenc == 1
			cDesc1  := "RELACAO DE PEDIDOS DE COMPRA RECEBIDOS"
		case nPCReceb == 1 .and. nRelGerenc == 2
			cDesc1  := "RELATORIO GERENCIAL PC EMITIDOS"
		case nPCReceb == 2 .and. nRelGerenc == 2
			cDesc1  := "RELATORIO GERENCIAL PC RECEBIDOS"
	endcase
	
	cQry := "select C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA, C7_NOMFORN, C7_DATPRF, C7_USER, C7_CONAPRO, sum((C7_TOTAL + C7_VALIPI)) as C7_TOTAL "
	cQry += "from "+RetSqlName("SC7")+" "
	cQry += "where (C7_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (C7_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (C7_USER between '"+cComIni+"' and '"+cComFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "group by C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA, C7_NOMFORN, C7_DATPRF, C7_USER, C7_CONAPRO "
	cQry += "order by C7_NUM"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		aAlias := GetArea()
		
		cCon := "select D1_DOC, D1_SERIE, D1_EMISSAO, D1_DTDIGIT, sum((D1_TOTAL + D1_VALIPI)) as D1_TOTAL "
		cCon += "from "+RetSqlName("SD1")+" "
		cCon += "where D1_PEDIDO = '"+TEMP->C7_NUM+"' and D_E_L_E_T_ <> '*' "
		cCon += "group by D1_DOC, D1_SERIE, D1_EMISSAO, D1_DTDIGIT "
		cCon += "order by D1_DOC, D1_SERIE"
		
		tcquery cCon new alias "TEMP1"
		
		DbSelectArea("TEMP1")
		TEMP1->(DbGoTop())
		
		if !TEMP1->(Eof())
			nRepeti := 0
			
			while !TEMP1->(Eof())
				
				if Empty(nRepeti)
					AAdd(aPedido,{TEMP->C7_NUM,;
									TEMP->C7_CONAPRO,;
									U_ConvData(TEMP->C7_EMISSAO,"yy"),;
									Left(TEMP->C7_NOMFORN,20),;
									U_ConvData(TEMP->C7_DATPRF,"yy"),;
									U_ConvData(TEMP1->D1_EMISSAO,"yy"),;
									AllTrim(Str(SToD(TEMP1->D1_EMISSAO) - SToD(TEMP->C7_DATPRF))),;
									TEMP1->(D1_DOC+"-"+D1_SERIE),;
									TEMP1->D1_TOTAL,;
									IIf(SY1->(DbSeek(xFilial("SY1")+TEMP->C7_USER,.F.)),Left(SY1->Y1_NOME,10),""),;
									U_ConvData(TEMP1->D1_DTDIGIT,"yy")})
				else
					AAdd(aPedido,{" ",;
									" ",;
									" ",;
									Left(TEMP->C7_NOMFORN,20),;
									U_ConvData(TEMP->C7_DATPRF,"yy"),;
									U_ConvData(TEMP1->D1_EMISSAO,"yy"),;
									AllTrim(Str(SToD(TEMP1->D1_EMISSAO) - SToD(TEMP->C7_DATPRF))),;
									TEMP1->(D1_DOC+"-"+D1_SERIE),;
									TEMP1->D1_TOTAL,;
									IIf(SY1->(DbSeek(xFilial("SY1")+TEMP->C7_USER,.F.)),Left(SY1->Y1_NOME,10),""),;
									U_ConvData(TEMP1->D1_DTDIGIT,"yy")})
				endif
				
				nRepeti++
				
				TEMP1->(DbSkip())
			enddo
		else
			if nPCReceb == 1
				AAdd(aPedido,{TEMP->C7_NUM,;
								TEMP->C7_CONAPRO,;
								U_ConvData(TEMP->C7_EMISSAO,"yy"),;
								Left(TEMP->C7_NOMFORN,20),;
								U_ConvData(TEMP->C7_DATPRF,"yy"),;
								" ",;
								" ",;
								" ",;
								TEMP->C7_TOTAL,;
								IIf(SY1->(DbSeek(xFilial("SY1")+TEMP->C7_USER,.F.)),Left(SY1->Y1_NOME,10)," "),;
								" "})
			endif
		endif
		
		TEMP1->(DbCloseArea())
		RestArea(aAlias)
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	Cabec1 := PadC("Periodo de: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	ProcRegua(TEMP->(Len(aPedido)))
	
	if nRelGerenc == 2
		for i := 1 to Len(aPedido)
			nAtraso := IIf(Val(aPedido[i][7]) > 0,1,0)
			
			if (nInd := AScan(aComprador,{|x| x[1] = aPedido[i][10]})) == 0
				AAdd(aComprador,{aPedido[i][10],1,aPedido[i][9],nAtraso})
			else
				aComprador[nInd][2]++
				aComprador[nInd][3] += aPedido[i][9]
				aComprador[nInd][4] += nAtraso
			endif
			
			if (nInd := AScan(aFornecedor,{|x| x[1] = aPedido[i][4]})) == 0
				AAdd(aFornecedor,{aPedido[i][4],1,aPedido[i][9],nAtraso})
			else
				aFornecedor[nInd][2]++
				aFornecedor[nInd][3] += aPedido[i][9]
				aFornecedor[nInd][4] += nAtraso
			endif
			
			if (nInd := AScan(aAtrasado,{|x| x[1] = nAtraso})) == 0
				AAdd(aAtrasado,{nAtraso,1,aPedido[i][9]})
			else
				aAtrasado[nInd][2]++
				aAtrasado[nInd][3] += aPedido[i][9]
			endif
			
			nTotQuant++
			nTotValor += aPedido[i][9]
			nTotGerQuant++
			nTotGerValor += aPedido[i][9]
		next
	else
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		for i := 1 to Len(aPedido)
//			PEDIDO  ST  EMISSAO   FORNECEDOR            PROGRAMA  REALIZAD  ATRA  NOTA FISCAL    EMISSAO            TOTAL  COMPRADOR
//			999999  A   99/99/99  AAAAAAAAAAAAAAAAAAAA  99/99/99  99/99/99  9999  999999999/999  99/99/99  999,999,999.99  AAAAAAAAAA
//			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11
			nLin++
			
			@nLin,000 psay aPedido[i][1]
			@nLin,008 psay aPedido[i][2]
			@nLin,012 psay aPedido[i][3]
			@nLin,022 psay IIf(Empty(aPedido[i][1])," ",aPedido[i][4])
			@nLin,044 psay aPedido[i][5]
			@nLin,054 psay aPedido[i][11]
			@nLin,064 psay aPedido[i][7]
			@nLin,070 psay aPedido[i][8]
			@nLin,085 psay aPedido[i][6]
			@nLin,095 psay Transf(aPedido[i][9],"@E 999,999,999.99")
			@nLin,111 psay IIf(Empty(aPedido[i][1])," ",aPedido[i][10])
			
			nAtraso := IIf(Val(aPedido[i][7]) > 0,1,0)
			
			if (nInd := AScan(aComprador,{|x| x[1] = aPedido[i][10]})) == 0
				AAdd(aComprador,{aPedido[i][10],1,aPedido[i][9],nAtraso})
			else
				aComprador[nInd][2]++
				aComprador[nInd][3] += aPedido[i][9]
				aComprador[nInd][4] += nAtraso
			endif
			
			if (nInd := AScan(aFornecedor,{|x| x[1] = aPedido[i][4]})) == 0
				AAdd(aFornecedor,{aPedido[i][4],1,aPedido[i][9],nAtraso})
			else
				aFornecedor[nInd][2]++
				aFornecedor[nInd][3] += aPedido[i][9]
				aFornecedor[nInd][4] += nAtraso
			endif
			
			if (nInd := AScan(aAtrasado,{|x| x[1] = nAtraso})) == 0
				AAdd(aAtrasado,{nAtraso,1,aPedido[i][9]})
			else
				aAtrasado[nInd][2]++
				aAtrasado[nInd][3] += aPedido[i][9]
			endif
			
			nTotQuant++
			nTotValor += aPedido[i][9]
			nTotGerQuant++
			nTotGerValor += aPedido[i][9]
			
			if nLin >= 53
	//			REGISTRO...:  999999        TOTAL.....:  999,999,999,999.99        VLR MEDIO:  999,999,999.99
	//			REGIS. GER.:  999999        TOTAL GER.:  999,999,999,999.99        VLR MEDIO:  999,999,999.99
	//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//			          1         2         3         4         5         6         7         8         9        10
				nLin += 2
				
				@nLin,000 psay "REGISTRO...:  "+AllTrim(Transf(nTotQuant,"@E 999999"))
				@nLin,028 psay "TOTAL.....:  "+AllTrim(Transf(nTotValor,"@E 999,999,999,999.99"))
				@nLin,067 psay "VLR MEDIO:  "+AllTrim(Transf((nTotValor / nTotQuant),"@E 999,999,999.99"))
				
				nTotQuant := 0
				nTotValor := 0
				nLin := 57
			endif
			
			U_SaltaFolha()
			IncProc()
		next
		
		if nLin < 53
			nLin += 2
			
			@nLin,000 psay "REGISTRO...:  "+AllTrim(Transf(nTotQuant,"@E 999999"))
			@nLin,028 psay "TOTAL.....:  "+AllTrim(Transf(nTotValor,"@E 999,999,999,999.99"))
			@nLin,067 psay "VLR MEDIO:  "+AllTrim(Transf((nTotValor / nTotQuant),"@E 999,999,999.99"))
			
			nLin++
			
			U_SaltaFolha()
		endif
		
		@nLin,000 psay "REGIS. GER.:  "+AllTrim(Transf(nTotGerQuant,"@E 999999"))
		@nLin,028 psay "TOTAL GER.:  "+AllTrim(Transf(nTotGerValor,"@E 999,999,999,999.99"))
		@nLin,067 psay "VLR MEDIO:  "+AllTrim(Transf((nTotGerValor / nTotGerQuant),"@E 999,999,999.99"))
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	endif
	
	Resumos()
	TEMP->(DbCloseArea())
return

static function Resumos()
	ASort(aComprador,,,{|x,y| x[1] < y[1]})
	ASort(aFornecedor,,,{|x,y| x[3] > y[3]})
	ASort(aAtrasado,,,{|x,y| x[1] > y[1]})
	
	Cabec2 := ""
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	nTotQuant := 0 ; nTotAtras := 0 ; nTotValor := 0 ; nTotMedio := 0 ; nTotPerc := 0
	
	@nLin,000 psay PadC("**********  RESUMO POR COMPRADOR  **********",_MAXCOL)
	@++nLin,000 psay "COMPRADOR                    N. PEDIDO     EM ATRASO          VLR PEDIDO         %         VLR MEDIO"
	
	for i := 1 to Len(aComprador)
//		**********  RESUMO POR COMPRADOR  **********
//		COMPRADOR                    N. PEDIDO     EM ATRASO          VLR PEDIDO         %         VLR MEDIO
//		AAAAAAAAAAAAAAAAAAAA            999999        999999      999,999,999.99    999.99    999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay aComprador[i][1]
		@nLin,032 psay Transf(aComprador[i][2],"@E 999999")
		@nLin,046 psay Transf(aComprador[i][4],"@E 999999")
		@nLin,058 psay Transf(aComprador[i][3],"@E 999,999,999.99")
		@nLin,076 psay Transf((aComprador[i][3] / nTotGerValor) * 100,"@E 999.99")
		@nLin,086 psay Transf(aComprador[i][3] / aComprador[i][2],"@E 999,999,999.99")
		
		nTotQuant += aComprador[i][2]
		nTotAtras += aComprador[i][4]
		nTotValor += aComprador[i][3]
		nTotMedio += (aComprador[i][3] / aComprador[i][2])
		nTotPerc += ((aComprador[i][3] / nTotGerValor) * 100)
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay Replicate("-",_MAXCOL)
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "TOTAL"
	@nLin,032 psay Transf(nTotQuant,"@E 999999")
	@nLin,046 psay Transf(nTotAtras,"@E 999999")
	@nLin,058 psay Transf(nTotValor,"@E 999,999,999.99")
	@nLin,076 psay Transf(nTotPerc,"@E 999.99")
	@nLin,086 psay Transf(nTotMedio,"@E 999,999,999.99")
	
	nLin += 3
	nTotQuant := 0 ; nTotAtras := 0 ; nTotValor := 0 ; nTotMedio := 0 ; nTotPerc := 0
	
	U_SaltaFolha()
	
	@nLin,000 psay PadC("**********  RESUMO POR FORNECEDOR  **********",_MAXCOL)
	@++nLin,000 psay "FORNECEDOR                   N. PEDIDO     EM ATRASO          VLR PEDIDO         %         VLR MEDIO"
	
	for i := 1 to Len(aFornecedor)
//		**********  RESUMO POR FORNECEDOR  **********
//		FORNECEDOR                   N. PEDIDO     EM ATRASO          VLR PEDIDO         %         VLR MEDIO
//		AAAAAAAAAAAAAAAAAAAA            999999        999999      999,999,999.99    999.99    999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay aFornecedor[i][1]
		@nLin,032 psay Transf(aFornecedor[i][2],"@E 999999")
		@nLin,046 psay Transf(aFornecedor[i][4],"@E 999999")
		@nLin,058 psay Transf(aFornecedor[i][3],"@E 999,999,999.99")
		@nLin,076 psay Transf((aFornecedor[i][3] / nTotGerValor) * 100,"@E 999.99")
		@nLin,086 psay Transf(aFornecedor[i][3] / aFornecedor[i][2],"@E 999,999,999.99")
		
		nTotQuant += aFornecedor[i][2]
		nTotAtras += aFornecedor[i][4]
		nTotValor += aFornecedor[i][3]
		nTotMedio += (aFornecedor[i][3] / aFornecedor[i][2])
		nTotPerc += ((aFornecedor[i][3] / nTotGerValor) * 100)
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay Replicate("-",_MAXCOL)
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "TOTAL"
	@nLin,032 psay Transf(nTotQuant,"@E 999999")
	@nLin,046 psay Transf(nTotAtras,"@E 999999")
	@nLin,058 psay Transf(nTotValor,"@E 999,999,999.99")
	@nLin,076 psay Transf(nTotPerc,"@E 999.99")
	@nLin,086 psay Transf(nTotMedio,"@E 999,999,999.99")
	
	nLin += 3
	nTotQuant := 0 ; nTotAtras := 0 ; nTotValor := 0 ; nTotMedio := 0 ; nTotPerc := 0
	
	U_SaltaFolha()
	
	@nLin,000 psay PadC("**********  RESUMO POR ATRASADO  **********",_MAXCOL)
	@++nLin,000 psay "ATRASADO                     N. PEDIDO                        VLR PEDIDO         %         VLR MEDIO"
	
	for i := 1 to Len(aAtrasado)
//		**********  RESUMO POR ATRASADO  **********
//		ATRASADO                     N. PEDIDO                        VLR PEDIDO         %         VLR MEDIO
//		AAAAAAAAAAAAAAAAAAAA            999999                    999,999,999.99    999.99    999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay IIf(aAtrasado[i][1] == 1,"ATRASADO","NORMAL")
		@nLin,032 psay Transf(aAtrasado[i][2],"@E 999999")
		@nLin,058 psay Transf(aAtrasado[i][3],"@E 999,999,999.99")
		@nLin,076 psay Transf((aAtrasado[i][3] / nTotGerValor) * 100,"@E 999.99")
		@nLin,086 psay Transf(aAtrasado[i][3] / aAtrasado[i][2],"@E 999,999,999.99")
		
		nTotQuant += aAtrasado[i][2]
		nTotValor += aAtrasado[i][3]
		nTotMedio += (aAtrasado[i][3] / aAtrasado[i][2])
		nTotPerc += ((aAtrasado[i][3] / nTotGerValor) * 100)
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay Replicate("-",_MAXCOL)
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "TOTAL"
	@nLin,032 psay Transf(nTotQuant,"@E 999999")
	@nLin,058 psay Transf(nTotValor,"@E 999,999,999.99")
	@nLin,076 psay Transf(nTotPerc,"@E 999.99")
	@nLin,086 psay Transf(nTotMedio,"@E 999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return