/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Balancete Sintético                                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function BALANCETE()
	private aOrd    := {"Natureza"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "BALAN"
	private Cabec1  := "NATUREZA                                    |       PREVISAO |          VALOR | % RECEITA | % DESPESA"
	private Cabec2  := ""
	private cDesc1  := "BALANCETE GERENCIAL"
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
	
	private cBalExc := GetMV("MV_BALEXC")
	
	private cDtIni := ""
	private cDtFin := ""
	private nTpRel := 0
	private cBalIni := ""
	private cBalFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Data de                                           ³
	//³ mv_par02 - Data ate                                          ³
	//³ mv_par03 - Tipo (1-analitico/2-sintetico)                    ³
	//³ mv_par04 - Balancete de                                      ³
	//³ mv_par05 - Balancete ate                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	nTpRel := mv_par03
	cBalIni := mv_par04
	cBalFin := mv_par05
	
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
	local nTotalV := 0
	local nTotalP := 0
	local nTotGeralP := 0
	local nTotGeralV := 0
	
	private aValores := {}
	private aValoresR := {}
	private aValoresD := {}
	private aValoresP := {}
	private nTotNotDeb := 0
	private nTotDesp := 0
	private nTotRec := 0
	private nTotalPRec := 0
	private nTotalPDes := 0
	
	Totais()
	Valores()
	
	cCbcRef := Padc("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	if Len(aValoresR) > 0
		@nLin,000 psay Padc("R E C E I T A",132)
		nLin++
		
		for i := 1 to Len(aValoresR)
			@nLin,000 psay aValoresR[i][1]+" "+If(SZ5->(DbSeek(xFilial("SZ5")+aValoresR[i][1],.F.)),AllTrim(SZ5->Z5_NOME),"")
			@nLin,046 psay Transf(aValoresR[i][3],"@E 999,999,999.99")
			@nLin,063 psay Transf(aValoresR[i][2],"@E 999,999,999.99")
			@nLin,081 psay Transf(((aValoresR[i][3] + aValoresR[i][2]) / nTotRec) * 100,"@E 99999.99")
			@nLin,093 psay Transf(((aValoresR[i][3] + aValoresR[i][2]) / nTotDesp) * 100,"@E 99999.99")
			
			nLin++
			nTotalPRec += ((aValoresR[i][3] + aValoresR[i][2]) / nTotRec) * 100
			nTotalPDes += ((aValoresR[i][3] + aValoresR[i][2]) / nTotDesp) * 100
			
			U_SaltaFolha()
		next
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,030 psay "TOTAL.........: "
		@nLin,063 psay Transf(nTotRec,"@E 999,999,999.99")
		@nLin,081 psay Transf(nTotalPRec,"@E 99999.99")
		@nLin,093 psay Transf(nTotalPDes,"@E 99999.99")
		
		nLin += 2
		nTotalPRec := 0
		nTotalPDes := 0
	endif
	
	if Len(aValoresD) > 0
		@nLin,000 psay Padc("D E S P E S A",132)
		nLin++
		
		for i := 1 to Len(aValoresD)
			@nLin,000 psay aValoresD[i][1]+" "+If(SZ5->(DbSeek(xFilial("SZ5")+aValoresD[i][1],.F.)),AllTrim(SZ5->Z5_NOME),"")
			@nLin,046 psay Transf(aValoresD[i][3],"@E 999,999,999.99")
			@nLin,063 psay Transf(aValoresD[i][2],"@E 999,999,999.99")
			@nLin,081 psay Transf(((aValoresD[i][3] + aValoresD[i][2]) / nTotRec) * 100,"@E 99999.99")
			@nLin,093 psay Transf(((aValoresD[i][3] + aValoresD[i][2]) / nTotDesp) * 100,"@E 99999.99")
			
			nLin++
			nTotalPRec += ((aValoresD[i][3] + aValoresD[i][2]) / nTotRec) * 100
			nTotalPDes += ((aValoresD[i][3] + aValoresD[i][2]) / nTotDesp) * 100
			
			U_SaltaFolha()
		next
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,030 psay "TOTAL.........: "
		@nLin,063 psay Transf(nTotDesp,"@E 999,999,999.99")
		@nLin,081 psay Transf(nTotalPRec,"@E 99999.99")
		@nLin,093 psay Transf(nTotalPDes,"@E 99999.99")
		
		nLin += 2
		
		U_SaltaFolha()
	endif
	
//	for i := 1 to Len(aValores)
//		NATUREZA                                    |       PREVISAO |          VALOR | % RECEITA | % DESPESA
//		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999.99   999,999,999.99    99999.99    99999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//		          1         2         3         4         5         6         7         8         9        10        11        12
/*		
		if aValores[i][2] > 0
			@nLin,000 psay aValores[i][1]+" "+If(SZ5->(DbSeek(xFilial("SZ5")+aValores[i][1],.F.)),AllTrim(SZ5->Z5_NOME),"")
			@nLin,046 psay Transf(aValores[i][3],"@E 999,999,999.99")
			@nLin,063 psay Transf(aValores[i][2],"@E 999,999,999.99")
			@nLin,081 psay Transf(((aValores[i][3] + aValores[i][2]) / nTotRec) * 100,"@E 99999.99")
			@nLin,093 psay Transf(((aValores[i][3] + aValores[i][2]) / nTotDesp) * 100,"@E 99999.99")
			
			nTotalV += aValores[i][2]
			nTotGeralV += aValores[i][2]
			nTotalP += aValores[i][3]
			nTotGeralP += aValores[i][3]
			
			nLin++
			
			U_SaltaFolha()
		endif
	next*/
	
	@nLin  ,000 psay __PrtThinLine()
	@++nLin,000 psay "TOTAL NOTAS DEBITO"
	@nLin  ,031 psay Transf(nTotNotDeb,"@E 999,999,999.99")
	@++nLin,000 psay "TOTAL RECEITAS"
	@nLin  ,031 psay Transf(nTotRec,"@E 999,999,999.99")
	@++nLin,000 psay "TOTAL DESPESAS"
	@nLin  ,031 psay Transf(nTotDesp,"@E 999,999,999.99")
	@++nLin,000 psay "RESULTADO"
	@nLin  ,031 psay Transf(nTotDesp - nTotRec,"@E 999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return

static function Totais()
	cQry := "select sum(TMP.TOTAL) as TOTAL "
	cQry += "from ( "
	cQry += "		select sum(E2_VALOR) as TOTAL "
	cQry += "		from "+RetSqlName("SE2")+" "
	cQry += "		where (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and left(E2_PREFIXO,1) = 'X' and E2_TIPO not in ('PA','PR') and D_E_L_E_T_ <> '*' "
	cQry += "		union all "
	cQry += "		select sum(E1_VALOR) as TOTAL "
	cQry += "		from "+RetSqlName("SE1")+" "
	cQry += "		where (E1_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and left(E1_PREFIXO,1) = 'X' and E1_TIPO not in ('RA','PR') and D_E_L_E_T_ <> '*' "
	cQry += ") TMP "
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	nTotNotDeb := TEMP->TOTAL
	
	TEMP->(DbCloseArea())
	
	cQry := "select sum(TMP.TOTAL) as TOTAL "
	cQry += "from ( "
	cQry += "		select sum(E2_VALOR) as TOTAL "
	cQry += "		from "+RetSqlName("SE2")+" "
	cQry += "		where (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and E2_BALGER not in ("+cBalExc+") and E2_TIPO not in ('PA','PR') and E2_NATUREZ <> '' and E2_FATURA = '' and E2_NUMLIQ = '' and D_E_L_E_T_ <> '*' or (E2_TIPO = 'PR' and (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and D_E_L_E_T_ <> '*') "
	cQry += ") TMP "
//	cQry += "		where (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and left(E2_NATUREZ,1) in ('2','3') and E2_TIPO not in ('PA','PR') and E2_FATURA = '' and E2_NUMLIQ = '' and D_E_L_E_T_ <> '*' or (E2_TIPO = 'PR' and (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and left(E2_NATUREZ,1) in ('2','3') and D_E_L_E_T_ <> '*') "
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	nTotDesp := TEMP->TOTAL
	
	TEMP->(DbCloseArea())
	
	cQry := "select sum(TMP.TOTAL) as TOTAL "
	cQry += "from ( "
	cQry += "		select sum(E1_VALOR) as TOTAL "
	cQry += "		from "+RetSqlName("SE1")+" "
	cQry += "		where (E1_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and E1_BALGER not in ("+cBalExc+") and E1_TIPO not in ('RA','PR') and E1_NATUREZ <> '' and E1_FATURA = '' and E1_NUMLIQ = '' and D_E_L_E_T_ <> '*' or (E1_TIPO = 'PR' and (E1_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and D_E_L_E_T_ <> '*') "
	cQry += ") TMP "
//	cQry += "		where (E1_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and left(E1_NATUREZ,1) = '1' and E1_TIPO not in ('RA','PR') and E1_FATURA = '' and E1_NUMLIQ = '' and D_E_L_E_T_ <> '*' or (E1_TIPO = 'PR' and (E1_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and left(E1_NATUREZ,1) = '1' and D_E_L_E_T_ <> '*') "
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	nTotRec := TEMP->TOTAL
	
	TEMP->(DbCloseArea())
return

static function Valores()
	local cCampo := If(nTpRel == 1,"TMP.NATUREZ","Z5_CONTASU")
	
	cQry := "select "+cCampo+" as NATUREZ, Z5_TIPO as TIPO, sum(TMP.VALOR) as VALOR "
	cQry += "from ( "
	cQry += "		select E2_BALGER as NATUREZ, E2_TIPO as TIPO, E2_VALOR as VALOR "
	cQry += "		from "+RetSqlName("SE2")+" "
	cQry += "		where (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (E2_BALGER between '"+cBalIni+"' and '"+cBalFin+"') and E2_BALGER not in ("+cBalExc+") and E2_TIPO not in ('PA','PR') and E2_NATUREZ <> '' and E2_FATURA = '' and E2_NUMLIQ = '' and D_E_L_E_T_ <> '*' or (E2_TIPO = 'PR' and (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and D_E_L_E_T_ <> '*') "
	cQry += ") TMP inner join "+RetSqlName("SZ5")+" SZ5 on (NATUREZ = Z5_CONTA) "
	cQry += "where SZ5.D_E_L_E_T_ <> '*' "
	cQry += "group by "+cCampo+", Z5_TIPO "
	cQry += "order by NATUREZ"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	
	while !TEMP->(Eof())
		AAdd(aValoresD,{TEMP->NATUREZ,TEMP->VALOR,0})
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	
	cQry := "select "+cCampo+" as NATUREZ, Z5_TIPO as TIPO, sum(TMP.VALOR) as VALOR "
	cQry += "from ( "
	cQry += "		select E1_BALGER as NATUREZ, E1_TIPO as TIPO, E1_VALOR as VALOR "
	cQry += "		from "+RetSqlName("SE1")+" "
	cQry += "		where (E1_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (E1_BALGER between '"+cBalIni+"' and '"+cBalFin+"') and E1_BALGER not in ("+cBalExc+") and E1_TIPO not in ('RA','PR') and E1_NATUREZ <> '' and E1_FATURA = '' and E1_NUMLIQ = '' and D_E_L_E_T_ <> '*' or (E1_TIPO = 'PR' and (E1_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and D_E_L_E_T_ <> '*') "
	cQry += ") TMP inner join "+RetSqlName("SZ5")+" SZ5 on (NATUREZ = Z5_CONTA) "
	cQry += "where SZ5.D_E_L_E_T_ <> '*' "
	cQry += "group by "+cCampo+", Z5_TIPO "
	cQry += "order by NATUREZ"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	
	while !TEMP->(Eof())
		AAdd(aValoresR,{TEMP->NATUREZ,TEMP->VALOR,0})
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	
	cDtIni1 := DataAnt(cDtIni)
	cDtFin1 := DataAnt(cDtFin)
	
	cQry := "select "+cCampo+" as NATUREZ, Z5_TIPO as TIPO, sum(TMP.VALOR) as VALOR "
	cQry += "from ( "
	cQry += "		select E5_BALGER as NATUREZ, E5_TIPO as TIPO, E5_VALOR as VALOR "
	cQry += "		from "+RetSqlName("SE5")+" "
	cQry += "		where (E5_DATA between '"+cDtIni1+"' and '"+cDtFin1+"') and (E5_BALGER between '"+cBalIni+"' and '"+cBalFin+"') and E5_BALGER not in ("+cBalExc+") and E5_TIPO not in ('PA','PR') and E5_NATUREZ <> '' and E5_FATURA = '' and D_E_L_E_T_ <> '*' or (E5_TIPO = 'PR' and (E5_DATA between '"+cDtIni1+"' and '"+cDtFin1+"') and D_E_L_E_T_ <> '*') "
	cQry += ") TMP inner join "+RetSqlName("SZ5")+" SZ5 on (NATUREZ = Z5_CONTA) "
	cQry += "where SZ5.D_E_L_E_T_ <> '*' "
	cQry += "group by "+cCampo+", Z5_TIPO "
	cQry += "order by NATUREZ"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	
	while !TEMP->(Eof())
		if TEMP->TIPO == "R"
			if (nInd := AScan(aValoresR,{|x| x[1] = TEMP->NATUREZ})) == 0
				AAdd(aValoresR,{TEMP->NATUREZ,0,TEMP->VALOR})
			else
				aValoresR[nInd][3] := TEMP->VALOR
			endif
		else
			if (nInd := AScan(aValoresD,{|x| x[1] = TEMP->NATUREZ})) == 0
				AAdd(aValoresD,{TEMP->NATUREZ,0,TEMP->VALOR})
			else
				aValoresD[nInd][3] := TEMP->VALOR
			endif
		endif
		
		TEMP->(DbSkip())
	enddo
return

static function DataAnt(cDat)
	_cMesAnt := StrZero(Month(SToD(cDat)) - 1,2)
	
	if Month(SToD(cDat)) == 01
		_cMesAnt := "12"
		_cNovaData := Str(Year(SToD(cDat)) - 1)+_cMesAnt+StrZero(Day(SToD(cDat)),2)
	else
		_cNovaData := Str(Year(SToD(cDat)))+_cMesAnt+StrZero(Day(SToD(cDat)),2)
	endif
return (AllTrim(_cNovaData))