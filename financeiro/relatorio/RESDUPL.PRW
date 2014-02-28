/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de Resumo de Duplicadas em Aberto           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RESDUPL()
	private aOrd    := {"Fornecedor","PP"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RESDUP"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1	:= "RESUMO DUPLICATAS EM ABERTO"
	private ContFun := 0
	private cString := "SE2"
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
	
	private cVenIni		:= ""
	private cVenFin		:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Vencimento de                                     ³
	//³ mv_par02 - Vencimento ate                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cVenIni	:= DToS(mv_par01)
	cVenFin := DToS(mv_par02)
	
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
	local aRegistros := {}
	
	private nTotalG := 0
	private aTF := {}
	private aPP := {}
	
	cQry := "select E2_FORNECE, E2_LOJA, A2_NREDUZ, A2_PRIOPAG, A2_TIPFORN, sum(E2_VALOR) as E2_VALOR, count(E2_FORNECE) as EVENTOS "
	cQry += "from "+RetSqlName("SE2")+" SE2 inner join "+RetSqlName("SA2")+" SA2 on (E2_FORNECE = A2_COD and E2_LOJA = A2_LOJA) "
	cQry += "where (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and E2_BAIXA = '' and E2_VALOR > 0 and E2_TIPO <> 'PA' and SE2.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by E2_FORNECE, E2_LOJA, A2_NREDUZ, A2_PRIOPAG, A2_TIPFORN "
	
	if nOrdem == 1
		cQry += "order by A2_NREDUZ"
		Cabec2 := "FORNECEDOR                                   EVENTOS                VALOR        %   PP   TIPO FORNECIMENTO"
	else
		cQry += "order by A2_PRIOPAG, A2_NREDUZ"
		Cabec2 := "PP   FORNECEDOR                                   EVENTOS                VALOR        %   TIPO FORNECIMENTO"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Vencimento de "+U_ConvData(cVenIni,"yy")+" a "+U_ConvData(cVenFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	FORNECEDOR                                   EVENTOS                VALOR        %   PP   TIPO FORNECIMENTO
//	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA (999999-99)    9999     999,999,999,999.99   999.99   99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13

//	PP   FORNECEDOR                                   EVENTOS                VALOR        %   TIPO FORNECIMENTO
//	99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA (999999-99)    9999     999,999,999,999.99   999.99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	nLin++
	nCont := 0  ; nTotal := 0 ; nEvento := 0
	
	while !TEMP->(Eof())
		AAdd(aRegistros,{TEMP->A2_NREDUZ,TEMP->E2_FORNECE,TEMP->E2_LOJA,TEMP->EVENTOS,TEMP->E2_VALOR,TEMP->A2_PRIOPAG,TEMP->A2_TIPFORN})
		
		if (nInd := AScan(aPP,{|x| x[1] = TEMP->A2_PRIOPAG})) == 0
			AAdd(aPP,{TEMP->A2_PRIOPAG,TEMP->EVENTOS,TEMP->E2_VALOR})
		else
			aPP[nInd][2] += TEMP->EVENTOS
			aPP[nInd][3] += TEMP->E2_VALOR
		endif
		
		if (nInd := AScan(aTF,{|x| x[1] = TEMP->A2_TIPFORN})) == 0
			AAdd(aTF,{TEMP->A2_TIPFORN,TEMP->EVENTOS,TEMP->E2_VALOR})
		else
			aTF[nInd][2] += TEMP->EVENTOS
			aTF[nInd][3] += TEMP->E2_VALOR
		endif
		
		nCont++
		nTotal += TEMP->E2_VALOR
		nTotalG += TEMP->E2_VALOR
		nEvento += TEMP->EVENTOS
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	for i := 1 to Len(aRegistros)
		if nOrdem == 1
			@nLin,000 psay AllTrim(aRegistros[i][1])+" ("+aRegistros[i][2]+"-"+aRegistros[i][3]+")"
			@nLin,046 psay Transf(aRegistros[i][4],"@R 9999")
			@nLin,055 psay Transf(aRegistros[i][5],"@E 999,999,999,999.99")
			@nLin,076 psay Transf((aRegistros[i][5] / nTotal) * 100,"@E 999.99")
			@nLin,085 psay aRegistros[i][6]
		else
			@nLin,000 psay aRegistros[i][6]
			@nLin,015 psay AllTrim(aRegistros[i][1])+" ("+aRegistros[i][2]+"-"+aRegistros[i][3]+")"
			@nLin,051 psay Transf(aRegistros[i][4],"@R 9999")
			@nLin,060 psay Transf(aRegistros[i][5],"@E 999,999,999,999.99")
			@nLin,081 psay Transf((aRegistros[i][5] / nTotal) * 100,"@E 999.99")
		endif
		
		@nLin,090 psay IIf(SX5->(DbSeek(xFilial("SX5")+"Z6"+aRegistros[i][7],.F.)),Left(SX5->X5_DESCRI,30)," ")
		
		nLin++
		
		U_SaltaFolha()
	next
	
/*	while !TEMP->(Eof())
		if nOrdem == 1
			@nLin,000 psay AllTrim(TEMP->A2_NREDUZ)+" ("+TEMP->E2_FORNECE+"-"+TEMP->E2_LOJA+")"
			@nLin,046 psay Transf(TEMP->EVENTOS,"@R 9999")
			@nLin,055 psay Transf(TEMP->E2_VALOR,"@E 999,999,999,999.99")
			@nLin,076 psay Transf(0,"@E 999.99")
			@nLin,085 psay TEMP->A2_PRIOPAG
		else
			@nLin,000 psay TEMP->A2_PRIOPAG
			@nLin,015 psay AllTrim(TEMP->A2_NREDUZ)+" ("+TEMP->E2_FORNECE+"-"+TEMP->E2_LOJA+")"
			@nLin,051 psay Transf(TEMP->EVENTOS,"@R 9999")
			@nLin,060 psay Transf(TEMP->E2_VALOR,"@E 999,999,999,999.99")
			@nLin,081 psay Transf(0,"@E 999.99")
		endif
		
		@nLin,090 psay IIf(SX5->(DbSeek(xFilial("SX5")+"Z6"+TEMP->A2_TIPFORN,.F.)),Left(SX5->X5_DESCRI,30)," ")
		
		if (nInd := AScan(aPP,{|x| x[1] = TEMP->A2_PRIOPAG})) == 0
			AAdd(aPP,{TEMP->A2_PRIOPAG,TEMP->EVENTOS,TEMP->E2_VALOR})
		else
			aPP[nInd][2] += TEMP->EVENTOS
			aPP[nInd][3] += TEMP->E2_VALOR
		endif
		
		if (nInd := AScan(aTF,{|x| x[1] = TEMP->A2_TIPFORN})) == 0
			AAdd(aTF,{TEMP->A2_TIPFORN,TEMP->EVENTOS,TEMP->E2_VALOR})
		else
			aTF[nInd][2] += TEMP->EVENTOS
			aTF[nInd][3] += TEMP->E2_VALOR
		endif
		
		nLin++
		nCont++
		nTotal += TEMP->E2_VALOR
		nEvento += TEMP->EVENTOS
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo*/
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "REGISTROS --> "+AllTrim(Transf(nCont,"@R 999999"))
	
	if nOrdem == 1
		@nLin,031 psay "T O T A L"
		@nLin,046 psay Transf(nEvento,"@E 9999")
		@nLin,055 psay Transf(nTotal,"@E 999,999,999,999.99")
	else
		@nLin,036 psay "T O T A L"
		@nLin,051 psay Transf(nEvento,"@E 9999")
		@nLin,060 psay Transf(nTotal,"@E 999,999,999,999.99")
	endif
	
	ASort(aPP,,,{|x,y| x[1] < y[1]})
	ASort(aTF,,,{|x,y| x[1] < y[1]})
	
	ResumoPP()
	ResumoTF()
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function ResumoPP()
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay PadC("* * *  RESUMO POR PP  * * *",69)
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "PP                               EVENTO               VALOR        %"
	
	nLin++
	nCont := 0 ; nTotal := 0
	
	U_SaltaFolha()
	
	for i := 1 to Len(aPP)
//		PP                               EVENTOS               VALOR        %
//		99                                9999    999,999,999,999.99   999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay aPP[i][1]
		@nLin,034 psay Transf(aPP[i][2],"@E 9999")
		@nLin,042 psay Transf(aPP[i][3],"@E 999,999,999,999.99")
		@nLin,063 psay Transf((aPP[i][3] / nTotalG) * 100,"@E 999.99")
		
		nLin++
		nCont += aPP[i][2]
		nTotal += aPP[i][3]
		
		U_SaltaFolha()
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L"
	@nLin,034 psay Transf(nCont,"@E 9999")
	@nLin,042 psay Transf(nTotal,"@E 999,999,999,999.99")
return

static function ResumoTF()
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay PadC("* * *  RESUMO POR TIPO FORNECIMENTO  * * *",69)
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "TIPO FORNECIMENTO                EVENTOS               VALOR        %"
	
	nLin++
	nCont := 0 ; nTotal := 0
	
	U_SaltaFolha()
	
	for i := 1 to Len(aTF)
//		TIPO FORNECIMENTO                EVENTOS               VALOR        %
//		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    9999    999,999,999,999.99   999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
//		@nLin,000 psay aTF[i][1]
		@nLin,000 psay IIf(SX5->(DbSeek(xFilial("SX5")+"Z6"+aTF[i][1],.F.)),Left(SX5->X5_DESCRI,30)," ")
		@nLin,034 psay Transf(aTF[i][2],"@E 9999")
		@nLin,042 psay Transf(aTF[i][3],"@E 999,999,999,999.99")
		@nLin,063 psay Transf((aTF[i][3] / nTotalG) * 100,"@E 999.99")
		
		nLin++
		nCont += aTF[i][2]
		nTotal += aTF[i][3]
		
		U_SaltaFolha()
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L"
	@nLin,034 psay Transf(nCont,"@E 9999")
	@nLin,042 psay Transf(nTotal,"@E 999,999,999,999.99")
return