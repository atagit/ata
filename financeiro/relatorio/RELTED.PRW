/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de titulos pagos com TED                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELTED()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELTED"
	private Cabec1  := ""
	private Cabec2  := "ITM  DOCUMENTO  FORNECEDOR              BANCO                 PREVISAO  EMISSAO   TITULO         PARC               VALOR"
	private cDesc1  := "RELACAO DE TED"
	private ContFun := 0
	private cString := "SE5"
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
	
	private cDataIni	:= ""
	private cDataFin	:= ""
	private cTedIni 	:= ""
	private cTedFin 	:= ""
	private cBancoDe	:= ""
	private cAgenciaDe	:= ""
	private cContaDe	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - TED de                                            ³
	//³ mv_par02 - TED ate                                           ³
	//³ mv_par03 - Emissao de                                        ³
	//³ mv_par04 - Emissao ate                                       ³
	//³ mv_par05 - Banco                                             ³
	//³ mv_par06 - Agencia                                           ³
	//³ mv_par07 - Conta                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cTedIni 	:= mv_par01
	cTedFin 	:= mv_par02
	cDataIni	:= DToS(mv_par03)
	cDataFin	:= DToS(mv_par04)
	cBancoDe	:= mv_par05
	cAgenciaDe	:= mv_par06
	cContaDe	:= mv_par07
	
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
	local nTotItem := 1
	local nValor := 0
	local nTotValor := 0
	local aTed := {}
	
/*	cQry := "select E5_DTDISPO, E5_DOCUMEN, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_BENEF, E5_HISTOR, E5_VALOR, E5_CLIFOR, E5_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_VALLIQ "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SE2")+" SE2 on (E5_NUMERO = E2_FATURA and E5_PREFIXO = E2_FATPREF) "
	cQry += "where (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') and (E5_DOCUMEN between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and E5_NATUREZ = '40103' and SE5.D_E_L_E_T_ <> '*' and SE2.D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DOCUMEN, E2_NUM, E2_PARCELA"*/
	
	cCondicBco := IIf(Empty(cBancoDe+cAgenciaDe+cContaDe),"","and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' ")
	
	cQry := "select E5_TIPODOC, E5_DTDISPO, E5_NUMTED = case when E5_NUMTED <> '' then 'TED'+E5_NUMTED else E5_NUMCHEQ end, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_BENEF, E5_HISTOR, E5_VALOR, E5_CLIFOR, E5_LOJA, E5_RECONC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_NUMCHEQ, E5_TIPO "
	cQry += "from "+RetSqlName("SE5")+" "
//	cQry += "where (((E5_NUMTED between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and E5_NATUREZ = '40103') or ((E5_NUMCHEQ between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and E5_TIPO = 'PA ')) and (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') "+cCondicBco+"and D_E_L_E_T_ <> '*' "
	cQry += "where (((E5_NUMTED between '"+cTedIni+"' and '"+cTedFin+"') and E5_NATUREZ = '40103') or ((E5_NUMCHEQ between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and E5_TIPO = 'PA ')) and (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') "+cCondicBco+"and D_E_L_E_T_ <> '*' "
	cQry += "order by R_E_C_N_O_, E5_NUMTED"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cTed := AllTrim(TEMP->E5_NUMTED)
		
		if TEMP->E5_TIPODOC $ "EC/ES"
			if (nInd := AScan(aTed,{|x| x[1] = cTed})) > 0
				aTed[nInd][1] := "9999"
			endif
		else
			AAdd(aTed,{cTed,TEMP->(E5_CLIFOR+E5_LOJA),TEMP->(E5_BANCO+E5_AGENCIA+E5_CONTA),TEMP->E5_DTDISPO,TEMP->E5_DATA,TEMP->E5_NUMERO,TEMP->E5_PREFIXO,TEMP->E5_PARCELA,TEMP->E5_VALOR})
		endif
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	Cabec1 := PadC("Periodo de "+U_ConvData(cDataIni)+" a "+U_ConvData(cDataFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	for k := 1 to Len(aTed)
		if aTed[k][1] <> "9999"
			@nLin,000 psay StrZero(nTotItem,3)
			@nLin,005 psay aTed[k][1]
			@nLin,016 psay IIf(SA2->(DbSeek(xFilial("SA2")+aTed[k][2],.F.)),SA2->A2_NREDUZ," ")
			@nLin,040 psay IIf(SA6->(DbSeek(xFilial("SA6")+aTed[k][3],.F.)),SA6->A6_NREDUZ," ")
			@nLin,062 psay U_ConvData(aTed[k][4],"yy")
			@nLin,072 psay U_ConvData(aTed[k][5],"yy")
			@nLin,082 psay aTed[k][6]+"-"+aTed[k][7]
			@nLin,097 psay aTed[k][8]
			@nLin,105 psay Transf(aTed[k][9],"@E 9,999,999,999.99")
			
			nLin++
			nTotItem++
			nTotValor += aTed[k][9]
			
			U_SaltaFolha()
		endif
		
		IncProc()
	next
	
/*	while !TEMP->(Eof())
//		ITM  DOCUMENTO  FORNECEDOR              BANCO                 PREVISAO  EMISSAO   TITULO         PARC               VALOR
//		999  AAA999999  AAAAAAAAAAAAAAAAAAAA    AAAAAAAAAAAAAAAAAAAA  99/99/99  99/99/99  999999999-999  999     9,999,999,999.99
//		01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		cTed := AllTrim(TEMP->E5_NUMTED)
		nValor := 0
		
		while !TEMP->(Eof()) .and. AllTrim(TEMP->E5_NUMTED) == cTed
			@nLin,000 psay StrZero(nTotItem,3)
			@nLin,005 psay cTed
			@nLin,016 psay IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(E5_CLIFOR+E5_LOJA),.F.)),SA2->A2_NREDUZ," ")
			@nLin,040 psay IIf(SA6->(DbSeek(xFilial("SA6")+TEMP->(E5_BANCO+E5_AGENCIA+E5_CONTA),.F.)),SA6->A6_NREDUZ," ")
			@nLin,062 psay U_ConvData(TEMP->E5_DTDISPO,"yy")
			@nLin,072 psay U_ConvData(TEMP->E5_DATA,"yy")
//			@nLin,070 psay U_ConvData(TEMP->E2_EMISSAO,"yy")
			@nLin,082 psay TEMP->E5_NUMERO+"-"+TEMP->E5_PREFIXO
			@nLin,097 psay TEMP->E5_PARCELA
			@nLin,105 psay Transf(TEMP->E5_VALOR,"@E 9,999,999,999.99")
//			@nLin,080 psay TEMP->E2_NUM+"-"+TEMP->E2_PREFIXO
//			@nLin,095 psay TEMP->E2_PARCELA
//			@nLin,103 psay Transf(TEMP->E2_VALLIQ,"@E 9,999,999,999.99")
			
			nLin++
			nTotItem++
			nValor += TEMP->E5_VALOR
			nTotValor += TEMP->E5_VALOR
//			nValor += TEMP->E2_VALLIQ
//			nTotValor += TEMP->E2_VALLIQ
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		@nLin,082 psay "T O T A L"
		@nLin,105 psay Transf(nValor,"@E 9,999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
	enddo*/
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L -----> ("+AllTrim(Str(nTotItem - 1))+" MOVIMENTACOES)"
	@nLin,103 psay Transf(nTotValor,"@E 9,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return