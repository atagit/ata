/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 11/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao copia do TED                                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function CPTED()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "CPTED"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "TITULO PAGOS COM TED"
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
	
	private cTedIni		:= ""
	private cTedFin		:= ""
	private cDataIni	:= ""
	private cDataFin	:= ""
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
	
/*	cQry := "select E5_DTDISPO, E5_DOCUMEN, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_BENEF, E5_HISTOR, E5_VALOR, E5_CLIFOR, E5_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_BALGER, E2_NOMFOR, E5_RECONC "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SE2")+" SE2 on (E5_NUMERO = E2_FATURA and E5_PREFIXO = E2_FATPREF) "
	cQry += "where (E5_DOCUMEN between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') and E5_NATUREZ = '40103' and E5_DOCUMEN <> '' and SE5.D_E_L_E_T_ <> '*' and SE2.D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DOCUMEN, E2_NUM, E2_PARCELA"*/
	
/*	cQry := "select E5_DTDISPO, E5_DOCUMEN, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_BENEF, E5_HISTOR, E5_VALOR, E5_CLIFOR, E5_LOJA, E5_RECONC, E5_PREFIXO, E5_NUMERO, E5_PARCELA "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (E5_DOCUMEN between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and E5_NATUREZ = '40103' and E5_DOCUMEN <> '' and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DOCUMEN"*/
	
/*	cQry := "select E5_DTDISPO, E5_DOCUMEN, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_BENEF, E5_HISTOR, E5_VALOR, E5_CLIFOR, E5_LOJA, E5_RECONC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_NUMCHEQ, E5_TIPO "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (((E5_DOCUMEN between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and E5_NATUREZ = '40103') or ((E5_NUMCHEQ between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and E5_TIPO = 'PA ')) and (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DOCUMEN"*/
	
	cQry := "select E5_DTDISPO, E5_NUMTED, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_BENEF, E5_HISTOR, E5_VALOR, E5_CLIFOR, E5_LOJA, E5_RECONC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_NUMCHEQ, E5_TIPO, E5_TIPODOC "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (((E5_NUMTED between '"+cTedIni+"' and '"+cTedFin+"') and E5_NATUREZ = '40103') or ((E5_NUMCHEQ between 'TED"+cTedIni+"' and 'TED"+cTedFin+"') and E5_TIPO = 'PA ')) and (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_NUMTED"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Periodo de "+U_ConvData(cDataIni)+" a "+U_ConvData(cDataFin),132)
	
	while !TEMP->(Eof())
//		BANCO: AAAAAAAAAAAAAAAAAAAA            AG: 99999            CC: 9999999999            N. TED: 999999            EMISSAO: 99/99/9999
//		01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
//		cTed := AllTrim(TEMP->E5_DOCUMEN)
		cTed := IIf(TEMP->E5_TIPO == "PA ",SubStr(AllTrim(TEMP->E5_NUMCHEQ),4,6),AllTrim(TEMP->E5_NUMTED))
		nValor := 0
		
		if SA6->(DbSeek(xFilial("SA6")+TEMP->(E5_BANCO+E5_AGENCIA+E5_CONTA),.F.))
			@nLin,000 psay "BANCO: "+SA6->A6_NREDUZ
			@nLin,039 psay "AG: "+SA6->A6_AGENCIA
			@nLin,060 psay "CC: "+SA6->A6_NUMCON
		endif
		
		@nLin,086 psay "N. TED: "+cTed
		@nLin,112 psay "EMISSAO: "+U_ConvData(TEMP->E5_DTDISPO)
		
		nLin++
		
		@nLin,000 psay __PrtThinLine()
		@++nLin,000 psay "ITM  FORNECEDOR             PREF  TITULO     PARC   NATUREZA                               PREVISAO  COMPENSA                 VALOR"
		@++nLin,000 psay __PrtThinLine()
		
		nLin++
		
//		ITM  FORNECEDOR             PREF  TITULO     PARC   NATUREZA                               PREVISAO  COMPENSA                 VALOR
//		999  AAAAAAAAAAAAAAAAAAAA   999   999999999  999    999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA     99/99/99  99/99/99      9,999,999,999.99
//		01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		if TEMP->E5_PREFIXO == "FAT"
			cQry := "select E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_BALGER, E2_NOMFOR, E2_VALLIQ "
			cQry += "from "+RetSqlName("SE2")+" "
			cQry += "where E2_FATURA = '"+TEMP->E5_NUMERO+"' and E2_FATPREF = '"+TEMP->E5_PREFIXO+"' and D_E_L_E_T_ <> '*' "
		else
//			cCondPA := IIf(TEMP->E5_TIPO == "PA ","and E2_BCOPAG = '"+TEMP->E5_BANCO+"' ","")
			cQry := "select E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, (E2_VALOR + E2_ACRESC - E2_DECRESC) as E2_VALOR, E2_BALGER, E2_NOMFOR, E2_VALLIQ "
			cQry += "from "+RetSqlName("SE2")+" "
//			cQry += "where E2_NUM = '"+TEMP->E5_NUMERO+"' and E2_PREFIXO = '"+TEMP->E5_PREFIXO+"' and E2_PARCELA = '"+TEMP->E5_PARCELA+"' and E2_FORNECE = '"+TEMP->E5_CLIFOR+"' and E2_LOJA = '"+TEMP->E5_LOJA+"' "+cCondPA+"and D_E_L_E_T_ <> '*' "
			cQry += "where E2_NUM = '"+TEMP->E5_NUMERO+"' and E2_PREFIXO = '"+TEMP->E5_PREFIXO+"' and E2_PARCELA = '"+TEMP->E5_PARCELA+"' and E2_FORNECE = '"+TEMP->E5_CLIFOR+"' and E2_LOJA = '"+TEMP->E5_LOJA+"' and "+IIf(TEMP->E5_TIPODOC == 'PA',"E2_TIPO = 'PA '","E2_BCOPAG = '"+TEMP->E5_BANCO+"'")+" and D_E_L_E_T_ <> '*' "
		endif
		
		tcquery cQry new alias "CON1"
		
		DbSelectArea("CON1")
		ProcRegua(CON1->(RecCount()))
		CON1->(DbGoTop())
		
		nTotItem := 1
		
		while !CON1->(Eof())
			nValPA := IIf(TEMP->E5_TIPO == "PA ",CON1->E2_VALOR,CON1->E2_VALLIQ)
			
			@nLin,000 psay StrZero(nTotItem,3)
			@nLin,005 psay CON1->E2_NOMFOR
			@nLin,028 psay CON1->E2_PREFIXO
			@nLin,034 psay CON1->E2_NUM
			@nLin,045 psay CON1->E2_PARCELA
			@nLin,052 psay CON1->E2_BALGER
			@nLin,056 psay IIf(SZ5->(DbSeek(xFilial("SZ5")+CON1->E2_BALGER,.F.)),SZ5->Z5_NOME," ")
			@nLin,091 psay U_ConvData(TEMP->E5_DTDISPO,"yy")
			@nLin,101 psay IIf(!Empty(TEMP->E5_RECONC),U_ConvData(TEMP->E5_DTDISPO,"yy")," ")
			@nLin,115 psay Transf(nValPA,"@E 9,999,999,999.99")
			
			nLin++
			nTotItem++
			nValor += nValPA
			nTotValor += nValPA
			
			U_SaltaFolha()
			IncProc()
			CON1->(DbSkip())
		enddo
		
		CON1->(DbCloseArea())
		
		@++nLin,000 psay "T O T A L"
		@nLin,115 psay Transf(nValor,"@E 9,999,999,999.99")
		
		nLin += 4
		
		U_SaltaFolha()
		
		@++nLin,002 psay Padc("         Elaborado por                             Ger. Adm/Fin                               Diretor            ",132)
		@++nLin,002 psay Padc("_______________________________          _______________________________          _______________________________",132)
		@++nLin,002 psay Padc("           /       /                                /       /                                /       /           ",132)
		
		TEMP->(DbSkip())
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
	
	TEMP->(DbCloseArea())
return