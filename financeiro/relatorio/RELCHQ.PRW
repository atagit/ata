/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/02/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de relaçao de cheques                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELCHQ()
	private aOrd    := {"Emissao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELCHQ"
	private Cabec1  := ""
	private Cabec2  := "ITM PREVISAO CHEQUE NT EMISSAO   BANCO            OPERACAO                                                                  VALOR ST"
	private cDesc1  := "RELACAO DE CHEQUES EMITIDO"
	private ContFun := 0
	private cString := "SEF"
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
	
	private cBancoDe := ""
	private cAgenciaDe := ""
	private cContaDe := ""
	private cDataDe := ""
	private cDataAte := ""
	private nNatureza := 0
	private cChequeDe := ""
	private cChequeAte := ""
	private nStPredatado := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco                                             ³
	//³ mv_par02 - Agencia                                           ³
	//³ mv_par03 - Conta                                             ³
	//³ mv_par04 - Periodo de                                        ³
	//³ mv_par05 - Periodo ate                                       ³
	//³ mv_par06 - Natureza (1-Ambos/2-Avista/3-Predatado)           ³
	//³ mv_par07 - Cheque de                                         ³
	//³ mv_par08 - Cheque ate                                        ³
	//³ mv_par09 - Status Predatado (1-Ambos/2-Conciliados/3-N Conci)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cBancoDe := mv_par01
	cAgenciaDe := mv_par02
	cContaDe := mv_par03
	cDataDe := DToS(mv_par04)
	cDataAte := DToS(mv_par05)
	nNatureza := mv_par06
	cChequeDe := mv_par07
	cChequeAte := mv_par08
	nStPredatado := mv_par09
	
	if nNatureza <> 3				//Avista ou Ambos
		Processa({|| Impr()},"","Aguarde processando...",lAborta)
	else							//Predatado
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

//**************************************************************\\
// Impressao por natureza Avista ou Ambos                       \\
//**************************************************************\\
static function Impr()
	local nCont := 1
	local nTotal := 0
	local nItem := 0
	local cBanco := ""
	local cCheque := ""
	local aCheques := {}
	local aBancos := {}
	local aNatureza := {}
	local cCondicao := IIf(Empty(cBancoDe),"","and EF_BANCO = '"+cBancoDe+"' and EF_AGENCIA = '"+cAgenciaDe+"' and EF_CONTA = '"+cContaDe+"' ")
	
	cQry := "select EF_DATA, EF_NUM, E5_DTDIGIT, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_HIST, EF_VALOR, EF_PREDATA, EF_DTPREDA, EF_IMPRESS, EF_NATUR, E5_DTDISPO, E5_RECONC "
	cQry += "from "+RetSqlName("SEF")+" SEF inner join "+RetSqlName("SE5")+" SE5 on (EF_NUM = E5_NUMCHEQ and EF_BANCO = E5_BANCO and EF_AGENCIA = E5_AGENCIA and EF_CONTA = E5_CONTA and EF_VALOR = E5_VALOR) "
	cQry += "where (E5_DTDIGIT between '"+cDataDe+"' and '"+cDataAte+"') and (EF_NUM between '"+cChequeDe+"' and '"+cChequeAte+"') "+cCondicao+"and EF_TIPO = '' and EF_IMPRESS <> 'C' and E5_TIPODOC in ('CH','EC') and SEF.D_E_L_E_T_ <> '*' and SE5.D_E_L_E_T_ <> '*' "
	
	if nNatureza <> 3
		cDesc1  := "RELACAO DE CHEQUES EMITIDO"
		cQry += "order by EF_NUM"
	else
		cDesc1  := "RELACAO DE CHEQUES PREDATADO"
		cQry += "order by EF_DATA, EF_NUM"
	endif
//	cQry += "order by EF_DATA+EF_NUM desc"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC(U_ConvData(cDataDe)+" A "+U_ConvData(cDataAte),132)
	Cabec2 := "ITM  CHEQUE  EMISSAO   NT  PREVISAO  BANCO            OPERACAO                                                       VALOR COMPENSA"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	while !TEMP->(Eof())
		if nNatureza == 2			//avista
			if TEMP->EF_PREDATA == "T" ; DbSkip() ; loop ; endif
		elseif nNatureza == 3		//predatado
			if TEMP->EF_PREDATA == "F" ; DbSkip() ; loop ; endif
		endif
		
		cBanco := IIf(SA6->(DbSeek(xFilial("SA6")+TEMP->(EF_BANCO+EF_AGENCIA+EF_CONTA),.F.)),SA6->A6_NREDUZ," ")
		
		if (nInd := AScan(aCheques,{|x| x[2] = AllTrim(TEMP->EF_NUM)})) == 0
			AAdd(aCheques,{TEMP->EF_DATA,AllTrim(TEMP->EF_NUM),TEMP->EF_PREDATA,TEMP->E5_DTDIGIT,cBanco,TEMP->EF_HIST,TEMP->EF_VALOR,TEMP->EF_IMPRESS,TEMP->E5_DTDISPO,TEMP->E5_RECONC})
			
			if (nInd := AScan(aBancos,{|x| x[1] = cBanco})) == 0
				AAdd(aBancos,{cBanco,1,TEMP->EF_VALOR})
			else
				aBancos[nInd][2]++
				aBancos[nInd][3] += TEMP->EF_VALOR
			endif
		endif
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aCheques) > 0
		cCheque := Left(aCheques[1][2],6)
	endif
	
	for i := 1 to Len(aCheques)
//		ITM  CHEQUE  EMISSAO   NT  PREVISAO  BANCO            OPERACAO                                                       VALOR COMPENSA
//		999  999999  99/99/99  AA  99/99/99  AAAAAAAAAAAAAAA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 99,999,999,999.99 99/99/99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		if Left(aCheques[i][2],6) <> cCheque
			while Left(aCheques[i][2],6) <> cCheque
				if Select("TMP") <> 0
					TMP->(DbCloseArea())
				endif
				
				cQry := "select D_E_L_E_T_ as DELETA, * from "+RetSqlName("SEF")+" where EF_NUM = '"+cCheque+"' and D_E_L_E_T_ <> '*'"
				
				tcquery cQry new alias "TMP"
				
				DbSelectArea("TMP")
				
				if TMP->(Eof())
					@nLin,000 psay StrZero(nCont,3)
					@nLin,013 psay cCheque
					@nLin,020 psay "EX"
					@nLin,130 psay "E"
					
					nLin++
					nCont++
					nItem++
					
					if (nInd := AScan(aBancos,{|x| x[1] = cBanco})) == 0
						AAdd(aBancos,{cBanco,1,0})
					else
						aBancos[nInd][2]++
					endif
					
					if (nInd := AScan(aNatureza,{|x| x[1] = "EX"})) == 0
						AAdd(aNatureza,{"EX",1,0})
					else
						aNatureza[nInd][2]++
					endif
				endif
				
				cCheque := StrZero(Val(cCheque) + 1,6)
				
				U_SaltaFolha()
				IncProc()
			enddo
		endif
		
		DbSelectArea("TEMP")
		
		cNaturChq := IIf(aCheques[i][3] == "F","AV","PR")
		
		@nLin,000 psay StrZero(nCont,3)
		@nLin,005 psay Left(aCheques[i][2],6)
		@nLin,013 psay U_ConvData(aCheques[i][4],"yy")
		@nLin,023 psay cNaturChq
		@nLin,027 psay U_ConvData(aCheques[i][1],"yy")
		@nLin,037 psay aCheques[i][5]
		@nLin,054 psay Left(aCheques[i][6],50)
		@nLin,105 psay Transf(aCheques[i][7],"@E 99,999,999,999.99")
		@nLin,123 psay IIf(!Empty(aCheques[i][10]),U_ConvData(aCheques[i][9],"yy")," ")
		
		nCont++
		nLin++
		nItem++
		nTotal += aCheques[i][7]
		cCheque := StrZero(Val(cCheque) + 1,6)
		
		if (nInd := AScan(aNatureza,{|x| x[1] = cNaturChq})) == 0
			AAdd(aNatureza,{cNaturChq,1,aCheques[i][7]})
		else
			aNatureza[nInd][2]++
			aNatureza[nInd][3] += aCheques[i][7]
		endif
		
		U_SaltaFolha()
		IncProc()
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L --->  ("+AllTrim(Transf(nItem,"@R 999,999,999"))+" REGISTROS)"
	@nLin,105 psay Transf(nTotal,"@E 99,999,999,999.99")
//	@++nLin,000 psay "LEGENDA STATUS: I - Impresso  /  C - Canelado  /  E - Excluido"
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	@++nLin,000 psay "******  R E S U M O  B A N C A R I O  ******"
	@++nLin,000 psay "BANCO              QUANT               VALOR"
	
	nLin++
	nTotal := 0
	nItem := 0
	
	U_SaltaFolha()
	
	for i := 1 to Len(aBancos)
//		******  R E S U M O  B A N C A R I O  ******
//		BANCO              QUANT               VALOR
//		AAAAAAAAAAAAAAA   999999   99,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay aBancos[i][1]
		@nLin,018 psay Transf(aBancos[i][2],"@R 999999")
		@nLin,027 psay Transf(aBancos[i][3],"@E 99,999,999,999.99")
		
		nLin++
		nItem += aBancos[i][2]
		nTotal += aBancos[i][3]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "T O T A L"
	@nLin,018 psay Transf(nItem,"@R 999999")
	@nLin,027 psay Transf(nTotal,"@E 99,999,999,999.99")
	
	nLin++
	
	U_SaltaFolha()
	
	@++nLin,000 psay "******  R E S U M O  N A T U R E Z A  ******"
	@++nLin,000 psay "NATUREZA           QUANT               VALOR"
	
	nLin++
	nTotal := 0
	nItem := 0
	
	U_SaltaFolha()
	
	for i := 1 to Len(aNatureza)
//		******  R E S U M O  N A T U R E Z A  ******
//		NATUREZA           QUANT               VALOR
//		AAAAAAAAAAAAAAA   999999   99,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		do case
			case aNatureza[i][1] == "AV"
				@nLin,000 psay "AVISTA"
			case aNatureza[i][1] == "PR"
				@nLin,000 psay "PREDATADO"
			case aNatureza[i][1] == "CN"
				@nLin,000 psay "CANCELADO"
			case aNatureza[i][1] == "EX"
				@nLin,000 psay "EXCLUIDO"
		endcase
		
		@nLin,018 psay Transf(aNatureza[i][2],"@R 999999")
		@nLin,027 psay Transf(aNatureza[i][3],"@E 99,999,999,999.99")
		
		nLin++
		nItem += aNatureza[i][2]
		nTotal += aNatureza[i][3]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "T O T A L"
	@nLin,018 psay Transf(nItem,"@R 999999")
	@nLin,027 psay Transf(nTotal,"@E 99,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

//**************************************************************\\
// Impressao por natureza Predatado                             \\
//**************************************************************\\
static function Impr1()
	local nCont := 1
	local j := 1
	local nTotal := 0
	local nItem := 0
	local cBanco := ""
	local cCheque := ""
	local aCheques := {}
	local aBancos := {}
	local aNatureza := {}
	local cCondicao := IIf(Empty(cBancoDe),"","and EF_BANCO = '"+cBancoDe+"' and EF_AGENCIA = '"+cAgenciaDe+"' and EF_CONTA = '"+cContaDe+"' ")
	local aTempStru := {}
	local aTotDia := {}
	local cArqTrab1
	
	AAdd(aTempStru,{"PREVISAO","C",08,0})
	AAdd(aTempStru,{"CHEQUE","C",06,0})
	AAdd(aTempStru,{"NATUREZ","C",02,0})
	AAdd(aTempStru,{"EMISSAO","C",08,0})
	AAdd(aTempStru,{"BANCO","C",15,0})
	AAdd(aTempStru,{"OPERACAO","C",50,0})
	AAdd(aTempStru,{"VALOR","N",17,2})
	AAdd(aTempStru,{"STATUS","C",01,0})
	
	cDesc1 := "RELACAO DE CHEQUES PREDATADO"
	Cabec1 := "ITM PREVISAO CHEQUE NT EMISSAO   BANCO            OPERACAO                                                                  VALOR ST"
	Cabec2 := ""
	cArqTrab1 := CriaTrab(aTempStru,.T.)
	
	DbUseArea(.T.,,cArqTrab1,"TEMP",.F.,.F.)
	index on PREVISAO+CHEQUE to ITEMP
	
	do case
		case nStPredatado == 1
			cCondicao1 := ""
		case nStPredatado == 2
			cCondicao1 := "and E5_RECONC = 'x' "
		case nStPredatado == 3
			cCondicao1 := "and E5_RECONC = ' ' "
	endcase
	
	cQry := "select EF_DATA, EF_NUM, E5_DTDIGIT, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_HIST, EF_VALOR, EF_PREDATA, EF_DTPREDA, EF_IMPRESS, EF_NATUR, E5_DTDISPO, E5_RECONC, E5_TIPODOC "
	cQry += "from "+RetSqlName("SEF")+" SEF inner join "+RetSqlName("SE5")+" SE5 on (EF_NUM = E5_NUMCHEQ and EF_BANCO = E5_BANCO and EF_AGENCIA = E5_AGENCIA and EF_CONTA = E5_CONTA and EF_VALOR = E5_VALOR) "
	cQry += "where (EF_NUM between '"+cChequeDe+"' and '"+cChequeAte+"') "+cCondicao+cCondicao1+"and EF_TIPO = '' and EF_IMPRESS <> 'C' and E5_TIPODOC in ('CH','EC') and EF_PREDATA = 'T' and SEF.D_E_L_E_T_ <> '*' and SE5.D_E_L_E_T_ <> '*' "
	cQry += "order by SE5.R_E_C_N_O_"
	
	tcquery cQry new alias "QTRB"
	
	DbSelectArea("QTRB")
	ProcRegua(QTRB->(RecCount()))
	QTRB->(DbGoTop())
	
	while !QTRB->(Eof())
		if QTRB->E5_TIPODOC == "EC"
/*			TEMP->(DbGoBottom())
			
			if QTRB->EF_NUM == TEMP->CHEQUE
				TEMP->(DbDelete())
			endif*/
			TEMP->(DbGoTop())
			
			while !TEMP->(Eof())
				if TEMP->CHEQUE == AllTrim(QTRB->EF_NUM) .and. TEMP->VALOR == QTRB->EF_VALOR
					TEMP->(DbDelete())
				endif
				
				TEMP->(DbSkip())
			enddo
		else
			TEMP->(DbAppend())
			
			cNaturChq := IIf(QTRB->EF_PREDATA == "F","AV","PR")
			cBanco := IIf(SA6->(DbSeek(xFilial("SA6")+QTRB->(EF_BANCO+EF_AGENCIA+EF_CONTA),.F.)),SA6->A6_NREDUZ," ")
			
			replace TEMP->PREVISAO with QTRB->E5_DTDISPO,;
					TEMP->CHEQUE with QTRB->EF_NUM,;
					TEMP->NATUREZ with cNaturChq,;
					TEMP->EMISSAO with QTRB->E5_DTDIGIT,;
					TEMP->BANCO with cBanco,;
					TEMP->OPERACAO with QTRB->EF_HIST,;
					TEMP->VALOR with QTRB->EF_VALOR,;
					TEMP->STATUS with QTRB->EF_IMPRESS
			
			TEMP->(DbCommit())
		endif
		
		IncProc()
		QTRB->(DbSkip())
	enddo
	
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	while !TEMP->(Eof())
		if (nInd := AScan(aCheques,{|x| x[2] = AllTrim(TEMP->CHEQUE)})) == 0
			AAdd(aCheques,{TEMP->PREVISAO,AllTrim(TEMP->CHEQUE),TEMP->NATUREZ,TEMP->EMISSAO,TEMP->BANCO,TEMP->OPERACAO,TEMP->VALOR,TEMP->STATUS})
			
			if (nInd := AScan(aBancos,{|x| x[1] = TEMP->BANCO})) == 0
				AAdd(aBancos,{TEMP->BANCO,1,TEMP->VALOR})
			else
				aBancos[nInd][2]++
				aBancos[nInd][3] += TEMP->VALOR
			endif
			
			if (nInd := AScan(aTotDia,{|x| x[1] = TEMP->PREVISAO})) == 0
				AAdd(aTotDia,{TEMP->PREVISAO,1,TEMP->VALOR})
			else
				aTotDia[nInd][2]++
				aTotDia[nInd][3] += TEMP->VALOR
			endif
		endif
		
		TEMP->(DbSkip())
	enddo
	
	ASort(aCheques,,,{|x,y| x[1] < y[1]})
	
	if Len(aCheques) > 0
		cCheque := Left(aCheques[1][2],6)
	endif
	
	for i := 1 to Len(aCheques)
//		ITM PREVISAO CHEQUE NT EMISSAO   BANCO            OPERACAO                                                                  VALOR ST
//		999 999999 99/99/99 AA 99/99/99 AAAAAAAAAAAAAAA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99,999,999,999.99 AA
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		if aTotDia[j][1] <> aCheques[i][1]
			@nLin,050 psay "T O T A L  --->  ("+AllTrim(Transf(aTotDia[j][2],"@R 999,999,999"))+" REGISTROS)"
			@nLin,112 psay Transf(aTotDia[j][3],"@E 99,999,999,999.99")
			
/*			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay __PrtThinLine()*/
			
			j++
			nLin += 2
			
			if U_SaltaFolha()
				nLin++
			endif
		endif
		
		cNaturChq := IIf(aCheques[i][3] == "F","AV","PR")
		
		@nLin,000 psay StrZero(nCont,3)
		@nLin,004 psay U_ConvData(aCheques[i][1],"yy")
		@nLin,013 psay Left(aCheques[i][2],6)
		@nLin,020 psay cNaturChq
		@nLin,023 psay U_ConvData(aCheques[i][4],"yy")
		@nLin,033 psay aCheques[i][5]
		@nLin,050 psay Left(aCheques[i][6],60)
		@nLin,112 psay Transf(aCheques[i][7],"@E 99,999,999,999.99")
		@nLin,130 psay IIf(aCheques[i][8] == "S","I",aCheques[i][8])
		
		nCont++
		nLin++
		nItem++
		nTotal += aCheques[i][7]
		cCheque := StrZero(Val(cCheque) + 1,6)
		
		if (nInd := AScan(aNatureza,{|x| x[1] = cNaturChq})) == 0
			AAdd(aNatureza,{cNaturChq,1,aCheques[i][7]})
		else
			aNatureza[nInd][2]++
			aNatureza[nInd][3] += aCheques[i][7]
		endif
		
		U_SaltaFolha()
		IncProc()
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L --->  ("+AllTrim(Transf(nItem,"@R 999,999,999"))+" REGISTROS)"
	@nLin,112 psay Transf(nTotal,"@E 99,999,999,999.99")
	@++nLin,000 psay "LEGENDA STATUS: I - Impresso  /  C - Canelado  /  E - Excluido"
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	@++nLin,000 psay "******  R E S U M O  B A N C A R I O  ******"
	@++nLin,000 psay "BANCO              QUANT               VALOR"
	
	nLin++
	nTotal := 0
	nItem := 0
	
	U_SaltaFolha()
	
	for i := 1 to Len(aBancos)
//		******  R E S U M O  B A N C A R I O  ******
//		BANCO              QUANT               VALOR
//		AAAAAAAAAAAAAAA   999999   99,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay aBancos[i][1]
		@nLin,018 psay Transf(aBancos[i][2],"@R 999999")
		@nLin,027 psay Transf(aBancos[i][3],"@E 99,999,999,999.99")
		
		nLin++
		nItem += aBancos[i][2]
		nTotal += aBancos[i][3]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "T O T A L"
	@nLin,018 psay Transf(nItem,"@R 999999")
	@nLin,027 psay Transf(nTotal,"@E 99,999,999,999.99")
	
	nLin++
	
	U_SaltaFolha()
	
	@++nLin,000 psay "******  R E S U M O  N A T U R E Z A  ******"
	@++nLin,000 psay "NATUREZA           QUANT               VALOR"
	
	nLin++
	nTotal := 0
	nItem := 0
	
	U_SaltaFolha()
	
	for i := 1 to Len(aNatureza)
//		******  R E S U M O  N A T U R E Z A  ******
//		NATUREZA           QUANT               VALOR
//		AAAAAAAAAAAAAAA   999999   99,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		do case
			case aNatureza[i][1] == "AV"
				@nLin,000 psay "AVISTA"
			case aNatureza[i][1] == "PR"
				@nLin,000 psay "PREDATADO"
			case aNatureza[i][1] == "CN"
				@nLin,000 psay "CANCELADO"
			case aNatureza[i][1] == "EX"
				@nLin,000 psay "EXCLUIDO"
		endcase
		
		@nLin,018 psay Transf(aNatureza[i][2],"@R 999999")
		@nLin,027 psay Transf(aNatureza[i][3],"@E 99,999,999,999.99")
		
		nLin++
		nItem += aNatureza[i][2]
		nTotal += aNatureza[i][3]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "T O T A L"
	@nLin,018 psay Transf(nItem,"@R 999999")
	@nLin,027 psay Transf(nTotal,"@E 99,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
	QTRB->(DbCloseArea())
return