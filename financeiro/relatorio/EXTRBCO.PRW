/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/01/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório extrato bancario para conferencia           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function EXTRBCO()
	private aOrd    := {"Banco"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "EXTBCO"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "EXTRATO BANCARIO"
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
	private cArqTrab1
	private cArqTrab2
	
	private cBancoDe := ""
	private cAgenciaDe := ""
	private cContaDe := ""
	private cDataDe := CToD("")
	private cDataAte := CToD("")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco                                             ³
	//³ mv_par02 - Agencia                                           ³
	//³ mv_par03 - Conta                                             ³
	//³ mv_par04 - Periodo de                                        ³
	//³ mv_par05 - Periodo ate                                       ³
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
	dDataAte := mv_par05
	
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
	
	FErase(cArqTrab1+".dbf")
	FErase(cArqTrab1+".cdx")
	FErase(cArqTrab2+".dbf")
	FErase(cArqTrab2+".cdx")
	FErase("itemp.cdx")
	FErase("ipend.cdx")
	Ms_Flush()
return

static function Impr()
	local nEntrada := 0
	local nSaida := 0
	local cTipoDoc := ""
	local cTipo := ""
	local cBenef := ""
	local cCliFor := ""
	local cDtDispo := ""
	local nValorNF := 0
	local cAlias := GetArea()
	
	private cDef := ""
	private nSaldoAtual := 0
	private nValor := 0
	private nTotReg := 0
	private aConciliados := {}
	private aTempStru := {}
	private aPendentes := {}
	private aPredatado := {}
	private nTotal := 0
	private aLimite := {}
	private aBanco := {}
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
/*	DbSelectArea("SE8")
	SE8->(DbGoTop())
	SE8->(DbSeek(xFilial("SE8")+cBancoDe+cAgenciaDe+cContaDe+cDataDe,.T.))
	SE8->(DbSkip(-1))
	
	nSaldoAtual := SE8->E8_SALATUA*/
	
	DbSelectArea("SZP")
	SZP->(DbGoTop())
	SZP->(DbSeek(xFilial("SZP")+cBancoDe+cAgenciaDe+cContaDe+cDataDe,.T.))
	SZP->(DbSkip(-1))
	
	nSaldoAtual := SZP->ZP_SALATUA
	
/*	cQry := "select E5_DTDISPO, E5_DATA, E5_HISTOR, E5_DOCUMEN, E5_NUMCHEQ, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_VALOR, E5_RECPAG, E5_RECONC, E5_TIPODOC, E5_DTDIGIT, EF_PREDATA, EF_DTPREDA, E5_TIPO, E5_BENEF, E5_CLIFOR, E5_LOJA, SE5.R_E_C_N_O_ as RECNO "
	cQry += "from "+RetSqlName("SE5")+" SE5 left join "+RetSqlName("SEF")+" SEF on (E5_NUMCHEQ = EF_NUM and '' = EF_TIPO) "
	cQry += "where (E5_DTDISPO between '"+cDataDe+"' and '"+cDataAte+"') and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and ((E5_TIPODOC not in ('MT','BA','CH','EC','PA','ES')) or (E5_TIPODOC in ('CH','EC') and E5_RECONC = 'x')) and SE5.D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, SE5.R_E_C_N_O_"*/
	
	AAdd(aTempStru,{"E5_DTDISPO","C",08,0})
	AAdd(aTempStru,{"E5_DATA","C",08,0})
	AAdd(aTempStru,{"E5_HISTOR","C",40,0})
	AAdd(aTempStru,{"E5_DOCUMEN","C",50,0})
	AAdd(aTempStru,{"E5_NUMCHEQ","C",15,0})
	AAdd(aTempStru,{"E5_PREFIXO","C",03,0})
	AAdd(aTempStru,{"E5_NUMERO","C",09,0})
	AAdd(aTempStru,{"E5_PARCELA","C",03,0})
	AAdd(aTempStru,{"E5_VALOR","N",17,2})
	AAdd(aTempStru,{"E5_RECPAG","C",01,0})
	AAdd(aTempStru,{"E5_RECONC","C",01,0})
	AAdd(aTempStru,{"E5_TIPODOC","C",02,0})
	AAdd(aTempStru,{"E5_DTDIGIT","C",08,0})
	AAdd(aTempStru,{"E5_TIPO","C",03,0})
	AAdd(aTempStru,{"E5_BENEF","C",30,0})
	AAdd(aTempStru,{"E5_CLIFOR","C",06,0})
	AAdd(aTempStru,{"E5_LOJA","C",02,0})
	AAdd(aTempStru,{"E5_BANCO","C",03,0})
	AAdd(aTempStru,{"E5_AGENCIA","C",05,0})
	AAdd(aTempStru,{"E5_CONTA","C",10,0})
	AAdd(aTempStru,{"E5_RECNO","C",06,0})
	AAdd(aTempStru,{"E5_MOTBX","C",3,0})
	
	cArqTrab1 := CriaTrab(aTempStru,.T.)
	
	DbUseArea(.T.,,cArqTrab1,"TEMP",.F.,.F.)
//	index on E5_DTDISPO+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ to ITEMP
	
	cQry := "select E5_DTDISPO, E5_DATA, E5_HISTOR, E5_DOCUMEN, E5_NUMCHEQ, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_VALOR, E5_RECPAG, E5_RECONC, E5_TIPODOC, E5_DTDIGIT, E5_TIPO, E5_BENEF, E5_CLIFOR, E5_LOJA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_MOTBX, R_E_C_N_O_ as RECNO "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (E5_DTDISPO between '"+cDataDe+"' and '"+cDataAte+"') and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and E5_SITUACA not in ('C','E','X') and E5_TIPODOC <> 'FAT' and ((E5_TIPODOC not in ('MT','BA','CH','EC','PA','ES','DC','JR')) or (E5_TIPODOC in ('CH','EC') and E5_RECONC = 'x')) and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, R_E_C_N_O_"
//	cQry += "order by E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, R_E_C_N_O_"
//	cQry += "order by SE5.R_E_C_N_O_"
	
	tcquery cQry new alias "QTRB"
	
	DbSelectArea("QTRB")
	ProcRegua(QTRB->(RecCount()))
	QTRB->(DbGoTop())
	
	while !QTRB->(Eof())
		if QTRB->E5_TIPODOC == "EC"
			TEMP->(DbGoTop())
			
			while !TEMP->(Eof())
				if TEMP->E5_NUMCHEQ == QTRB->E5_NUMCHEQ .and. TEMP->E5_VALOR == QTRB->E5_VALOR .and. TEMP->E5_DTDISPO == QTRB->E5_DTDISPO
//				if TEMP->E5_NUMCHEQ == QTRB->E5_NUMCHEQ .and. TEMP->E5_VALOR == QTRB->E5_VALOR
					TEMP->(DbDelete())
					
					exit
				endif
				
				TEMP->(DbSkip())
			enddo
/*			nValorChq := TEMP->E5_VALOR
			 
			TEMP->(DbGoBottom())
			
			if TEMP->E5_TIPODOC == "CH" .and. TEMP->E5_VALOR == nValorChq
				TEMP->(DbDelete())
				
				nValorChq := 0
			endif*/
		else
			TEMP->(DbAppend())
			
			replace TEMP->E5_DTDISPO with QTRB->E5_DTDISPO,;
					TEMP->E5_DATA with QTRB->E5_DATA,;
					TEMP->E5_HISTOR with QTRB->E5_HISTOR,;
					TEMP->E5_DOCUMEN with QTRB->E5_DOCUMEN,;
					TEMP->E5_NUMCHEQ with QTRB->E5_NUMCHEQ,;
					TEMP->E5_PREFIXO with QTRB->E5_PREFIXO,;
					TEMP->E5_NUMERO with QTRB->E5_NUMERO,;
					TEMP->E5_PARCELA with QTRB->E5_PARCELA,;
					TEMP->E5_VALOR with QTRB->E5_VALOR,;
					TEMP->E5_RECPAG with QTRB->E5_RECPAG,;
					TEMP->E5_RECONC with QTRB->E5_RECONC,;
					TEMP->E5_TIPODOC with QTRB->E5_TIPODOC,;
					TEMP->E5_DTDIGIT with QTRB->E5_DTDIGIT,;
					TEMP->E5_TIPO with QTRB->E5_TIPO,;
					TEMP->E5_BENEF with QTRB->E5_BENEF,;
					TEMP->E5_CLIFOR with QTRB->E5_CLIFOR,;
					TEMP->E5_LOJA with QTRB->E5_LOJA,;
					TEMP->E5_BANCO with QTRB->E5_BANCO,;
					TEMP->E5_AGENCIA with QTRB->E5_AGENCIA,;
					TEMP->E5_CONTA with QTRB->E5_CONTA,;
					TEMP->E5_RECNO with Str(QTRB->RECNO,6),;
					TEMP->E5_MOTBX with QTRB->E5_MOTBX
			
			TEMP->(DbCommit())
		endif
		
		IncProc()
		QTRB->(DbSkip())
	enddo
	
	QTRB->(DbCloseArea())
	TEMP->(DbGoTop())
	
/*	while !TEMP->(Eof())
		if TEMP->E5_RECONC == "x"
			AAdd(aConciliados,{TEMP->E5_DTDISPO,TEMP->E5_DATA,TEMP->E5_HISTOR,TEMP->E5_DOCUMEN,TEMP->E5_NUMCHEQ,TEMP->E5_PREFIXO,TEMP->E5_NUMERO,TEMP->E5_PARCELA,TEMP->E5_VALOR,TEMP->E5_RECPAG,TEMP->E5_RECONC,TEMP->E5_TIPODOC,TEMP->E5_DTDIGIT})
		else
			AAdd(aPendentes,{TEMP->E5_DTDISPO,TEMP->E5_DATA,TEMP->E5_HISTOR,TEMP->E5_DOCUMEN,TEMP->E5_NUMCHEQ,TEMP->E5_PREFIXO,TEMP->E5_NUMERO,TEMP->E5_PARCELA,TEMP->E5_VALOR,TEMP->E5_RECPAG,TEMP->E5_RECONC,TEMP->E5_TIPODOC,TEMP->E5_DTDIGIT})
		endif
		
		TEMP->(DbSkip())
	enddo*/
	
	Cabec1 := PadC(U_ConvData(cDataDe)+" A "+U_ConvData(cDataAte),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	nLin++
	
//	BANCO: 999 - AAAAAAAAAAAAAAAAAAAA   AG: 99999   CC: 9999999999                                      SLD. ANTERIOR: 99,999,999,999.99
//	GERENTE: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	if SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.))
		nTamSld := 17 - Len(AllTrim(Transf(nSaldoAtual,"@E 99,999,999,999.99")))
		
		AAdd(aBanco,SA6->A6_CONTATO)
		AAdd(aBanco,SA6->A6_EMAIL)
		AAdd(aBanco,SA6->A6_TEL)
		AAdd(aBanco,SA6->A6_CELULAR)
		AAdd(aBanco,SA6->A6_COD)
		AAdd(aBanco,SA6->A6_NREDUZ)
		AAdd(aBanco,SA6->A6_AGENCIA)
		AAdd(aBanco,SA6->A6_NUMCON)
		
		if SZQ->(DbSeek(xFilial("SZQ")+cBancoDe+cAgenciaDe+cContaDe,.F.))
			nTotal := 0
			
			while !SZQ->(Eof()) .and. SZQ->ZQ_BANCO == cBancoDe .and. SZQ->ZQ_AGENCIA == cAgenciaDe .and. SZQ->ZQ_CONTA == cContaDe .and. SZQ->ZQ_TIPO == "1"
				AAdd(aLimite,{SZQ->ZQ_CREDITO,SZQ->ZQ_VALOR,SZQ->ZQ_TAXA,SZQ->ZQ_VENCTO})
				
				nTotal += SZQ->ZQ_VALOR
				
				SZQ->(DbSkip())
			enddo
		endif
		
		CabecLocal()
		
/*		nLin += 2
		nTotal := 0
		
		@nLin,000 psay PadC("* * * * *   D A D O S  C A D A S T R A I S   * * * * *",131)
		
		nLin += 2
		
		@nLin,000 psay "GERENTE: "+AllTrim(SA6->A6_CONTATO)+"     E-MAIL: "+Lower(AllTrim(SA6->A6_EMAIL))+"     TEL.: "+AllTrim(SA6->A6_TEL)+"     CEL.: "+AllTrim(SA6->A6_CELULAR)
		
		nLin += 2
		
		if SZQ->(DbSeek(xFilial("SZQ")+cBancoDe+cAgenciaDe+cContaDe,.F.))
			@nLin,000 psay PadC("* * * * *   L I M I T E  D E  C R E D I T O   * * * * *",131)
			
			nLin += 2
			nTotal := 0
			
			@nLin,000 psay "DESCRICAO                                  LIMITE    TAXA  VENCTO"
			
			nLin++
			
			while !SZQ->(Eof()) .and. SZQ->ZQ_BANCO == cBancoDe .and. SZQ->ZQ_AGENCIA == cAgenciaDe .and. SZQ->ZQ_CONTA == cContaDe .and. SZQ->ZQ_TIPO == "1"
//				DESCRICAO                                  LIMITE    TAXA  VENCTO
//				AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99,999,999,999.99  999.99  99/99/99
//				0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//				          1         2         3         4         5         6         7         8         9        10        11        12        13
				
				@nLin,000 psay SZQ->ZQ_CREDITO
				@nLin,032 psay Transf(SZQ->ZQ_VALOR,"@E 99,999,999,999.99")
				@nLin,051 psay Transf(SZQ->ZQ_TAXA,"@E 999.99")
				@nLin,059 psay U_ConvData(DToS(SZQ->ZQ_VENCTO),"yy")
				
				nLin++
				nTotal += SZQ->ZQ_VALOR
				
				U_SaltaFolha()
				SZQ->(DbSkip())
			enddo
			
			if !Empty(nTotal)
				@nLin,000 psay "T O T A L"
				@nLin,032 psay Transf(nTotal,"@E 99,999,999,999.99")
			endif
			
			nLin += 2
			nTotal := 0
		endif
		
		@nLin,000 psay PadC("* * * * *   B A N C O   * * * * *",131)
		
		nLin += 2
		
		@nLin,000 psay "BANCO: "+SA6->A6_COD+" - "+SA6->A6_NREDUZ
		@nLin,036 psay "AG: "+SA6->A6_AGENCIA
		@nLin,048 psay "CC: "+SA6->A6_NUMCON
		@nLin,100 + nTamSld psay "SLD. ANTERIOR: "+AllTrim(Transf(nSaldoAtual,"@E 99,999,999,999.99"))
		@++nLin,000 psay __PrtThinLine()*/
		
//		nTamTit := Len("BANCO: "+SA6->A6_COD+" - "+SA6->A6_NREDUZ+"   AG: "+SA6->A6_AGENCIA+"   CC: "+SA6->A6_NUMCON+"   SLD. ANTERIOR: "+AllTrim(Transf(nSaldoAtual,"@E 99,999,999,999.99")))
//		cDef := "BANCO: "+SA6->A6_COD+" - "+SA6->A6_NREDUZ+"   AG: "+SA6->A6_AGENCIA+"   CC: "+SA6->A6_NUMCON+Space(132 - nTamTit)+"   SLD. ANTERIOR: "+AllTrim(Transf(nSaldoAtual,"@E 99,999,999,999.99"))
	endif
	
	
	
//	Cabec1 := PadC(U_ConvData(cDataDe)+" A "+U_ConvData(cDataAte),132)
//	Cabec2 := cDef
	
//	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	nLin++
	
	@nLin,000 psay PadC("* * * * *   C O N C I L I A D O S   * * * * *",132)
	
	nLin += 2
	
//	Conciliado()
	
//	DATA     OPERACAO                                 DOCUMENTO       NT PREFIXO/TITULO          ENTRADAS         SAIDAS     SALDO ATUAL
//	99/99/99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAA AA 999-999999999-999 999,999,999.99 999,999,999.99x 999,999,999.99
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	cDef := "DATA     OPERACAO                                 DOCUMENTO       NT PREFIXO/TITULO          ENTRADAS         SAIDAS     SALDO ATUAL"
	
	@nLin,000 psay cDef
	
	nLin++
	
	while !TEMP->(Eof())
//		if TEMP->E5_TIPODOC == "VL" .and. AllTrim(TEMP->E5_TIPO) == "NF" .and. TEMP->E5_MOTBX == "DEB" .and. Left(TEMP->E5_DOCUMEN,3) == "TED"
		if TEMP->E5_TIPODOC == "VL" .and. TEMP->E5_MOTBX == "DEB" .and. Left(TEMP->E5_DOCUMEN,3) == "TED"
			cTipoDoc := TEMP->E5_TIPODOC
			cTipo := TEMP->E5_TIPO
			cBenef := TEMP->E5_BENEF
			cCliFor := TEMP->E5_CLIFOR
			cLoja := TEMP->E5_LOJA
			cDtDispo := TEMP->E5_DTDISPO
			cMotBx := TEMP->E5_MOTBX
			
//			while !TEMP->(Eof()) .and. TEMP->E5_DTDISPO == cDtDispo .and. TEMP->E5_TIPODOC == cTipoDoc .and. TEMP->E5_TIPO == cTipo .and. TEMP->E5_BENEF == cBenef .and. TEMP->E5_CLIFOR == cCliFor .and. TEMP->E5_LOJA == cLoja .and. TEMP->E5_MOTBX == cMotBx .and. Left(TEMP->E5_DOCUMEN,3) == "TED"
			while !TEMP->(Eof()) .and. TEMP->E5_DTDISPO == cDtDispo .and. TEMP->E5_TIPODOC == cTipoDoc .and. TEMP->E5_BENEF == cBenef .and. TEMP->E5_CLIFOR == cCliFor .and. TEMP->E5_LOJA == cLoja .and. TEMP->E5_MOTBX == cMotBx .and. Left(TEMP->E5_DOCUMEN,3) == "TED"
				nValorNF += TEMP->E5_VALOR
				
				TEMP->(DbSkip())
			enddo
			
			TEMP->(DbSkip(-1))
//		elseif TEMP->E5_TIPODOC == "VL" .and. AllTrim(TEMP->E5_TIPO) $ "NF/FI" .and. TEMP->E5_MOTBX $ "DEB/NOR" .and. Empty(TEMP->E5_NUMCHEQ)
		elseif TEMP->E5_TIPODOC == "VL" .and. TEMP->E5_MOTBX $ "DEB/NOR" .and. Empty(TEMP->E5_NUMCHEQ)
			cTipoDoc := TEMP->E5_TIPODOC
			cTipo := TEMP->E5_TIPO
			cBenef := TEMP->E5_BENEF
			cCliFor := TEMP->E5_CLIFOR
			cLoja := TEMP->E5_LOJA
			cDtDispo := TEMP->E5_DTDISPO
			cMotBx := TEMP->E5_MOTBX
			nValorNF := TEMP->E5_VALOR
			nCont := 0
			
			TEMP->(DbSkip())
			
//			while !TEMP->(Eof()) .and. TEMP->E5_DTDISPO == cDtDispo .and. TEMP->E5_TIPODOC == cTipoDoc .and. TEMP->E5_TIPO == cTipo .and. TEMP->E5_BENEF == cBenef .and. TEMP->E5_CLIFOR == cCliFor .and. TEMP->E5_MOTBX == cMotBx .and. TEMP->E5_LOJA == cLoja .and. Empty(TEMP->E5_NUMCHEQ)
			while !TEMP->(Eof()) .and. TEMP->E5_DTDISPO == cDtDispo .and. TEMP->E5_TIPODOC == cTipoDoc .and. TEMP->E5_BENEF == cBenef .and. TEMP->E5_CLIFOR == cCliFor .and. TEMP->E5_MOTBX == cMotBx .and. TEMP->E5_LOJA == cLoja .and. Empty(TEMP->E5_NUMCHEQ)
				nValorNF += TEMP->E5_VALOR
				nCont++
				
				TEMP->(DbSkip())
			enddo
			
			if Empty(nCont)
				cTipoDoc := "" ; cTipo := "" ; cBenef := "" ; cCliFor := "" ; cLoja := "" ; cDtDispo := "" ; cMotBx := "" ; nValorNF := 0
			endif
			
			TEMP->(DbSkip(-1))
		endif
		
		@nLin,000 psay U_ConvData(TEMP->E5_DTDISPO,"yy")
		@nLin,009 psay Left(IIf(Empty(cBenef),TEMP->E5_HISTOR,cBenef),40)
		@nLin,050 psay Left(IIf(Empty(TEMP->E5_DOCUMEN),TEMP->E5_NUMCHEQ,TEMP->E5_DOCUMEN),15)
		
		if TEMP->E5_TIPODOC == "CH"
			if Select("TMP") <> 0
				TMP->(DbCloseArea())
			endif
			
			cQry := "select * from "+RetSqlName("SEF")+" where EF_NUM = '"+TEMP->E5_NUMCHEQ+"' and EF_TIPO = '' and D_E_L_E_T_ <> '*' "
			
			tcquery cQry new alias "TMP"
			
			DbSelectArea("TMP")
			
			if TMP->EF_PREDATA == "T"
				@nLin,066 psay "PR"
			else
				@nLin,066 psay "AV"
			endif
			
			TMP->(DbCloseArea())
		endif
		
		if !Empty(TEMP->E5_NUMERO)
			if Empty(cBenef)
				@nLin,069 psay TEMP->E5_PREFIXO+"-"+TEMP->E5_NUMERO+"-"+TEMP->E5_PARCELA
			endif
		elseif TEMP->E5_TIPODOC == "CH"
			if Select("TMP") <> 0
				TMP->(DbCloseArea())
			endif
			
			cQry := "select * from "+RetSqlName("SE2")+" where E2_NUMBCO = '"+TEMP->E5_NUMCHEQ+"' and D_E_L_E_T_ <> '*' "
			
			tcquery cQry new alias "TMP"
		
			DbSelectArea("TMP")
			
			count to nTotReg
			
			TMP->(DbGoTop())
			
			if nTotReg == 1
				@nLin,069 psay TMP->E2_PREFIXO+"-"+TMP->E2_NUM+"-"+TMP->E2_PARCELA
			endif
			
			TMP->(DbCloseArea())
		endif
		
		if TEMP->E5_RECPAG == "R"
			if Empty(cBenef)
				@nLin,087 psay Transf(TEMP->E5_VALOR,"@E 999,999,999.99")
				
				nSaldoAtual += TEMP->E5_VALOR
				nEntrada += TEMP->E5_VALOR
			else
				@nLin,087 psay Transf(nValorNF,"@E 999,999,999.99")
				
				nSaldoAtual += nValorNF
				nEntrada += nValorNF
			endif
		else
			if Empty(cBenef)
				@nLin,102 psay Transf(TEMP->E5_VALOR,"@E 999,999,999.99")
				
				nSaldoAtual -= TEMP->E5_VALOR
				nSaida += TEMP->E5_VALOR
			else
				@nLin,102 psay Transf(nValorNF,"@E 999,999,999.99")
				
				nSaldoAtual -= nValorNF
				nSaida += nValorNF
			endif
		endif
		
		@nLin,116 psay TEMP->E5_RECONC
		@nLin,118 psay Transf(nSaldoAtual,"@E 999,999,999.99")
		
		nLin++
		cTipoDoc := "" ; cTipo := "" ; cBenef := "" ; cCliFor := "" ; cDtDispo := "" ; nValorNF := 0 ; cMotBx := "" ; cLoja := ""
		
		U_SaltaFolha()
		
		if nLin == 7
			CabecLocal(cDef)
		endif
		
		TEMP->(DbSkip())
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L  ----->"
	@nLin,087 psay Transf(nEntrada,"@E 999,999,999.99")
	@nLin,102 psay Transf(nSaida,"@E 999,999,999.99")
	@nLin,118 psay Transf(nSaldoAtual,"@E 999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	@++nLin,000 psay PadC("* * * * *   P E N D E N T E S   * * * * *",132)
	
	nLin += 2
	
	U_SaltaFolha()
	Pendentes(@nSaldoAtual)
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	@++nLin,000 psay PadC(" * * * * *   P E N D E N T E S  A  R E C E B E R   * * * * *",132)
	
	nLin++
	
	U_SaltaFolha()
	AReceber()
	
/*	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	@++nLin,000 psay PadC("* * * * *   P R E D A T A D O S   * * * * *",132)
	
	nLin += 2
	
	U_SaltaFolha()*/
	
//	Predatados(@nSaldoAtual)
	
/*	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	@++nLin,000 psay PadC("* * * * *   T O T A I S   * * * * *",132)
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,028 psay "SALDO INICIAL ..........:"
	@nLin,113 psay Transf(SE8->E8_SALATUA,"@E 99,999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "                                                                                     NAO CONCILIADOS    CONCILIADOS          TOTAL"
	@++nLin,028 psay "ENTRADAS NO PERIODO ....:"
	@nLin,086 psay Transf(aNConciliado[1],"@E 999,999,999.99")
	@nLin,101 psay Transf(aConciliado[1],"@E 999,999,999.99")
	@nLin,116 psay Transf(aTotal[1],"@E 999,999,999.99")
	@++nLin,028 psay "SAIDAS NO PERIODO ......:"
	@nLin,086 psay Transf(aNConciliado[2],"@E 999,999,999.99")
	@nLin,101 psay Transf(aConciliado[2],"@E 999,999,999.99")
	@nLin,116 psay Transf(aTotal[2],"@E 999,999,999.99")
	
	nLin +=2
	
	U_SaltaFolha()
	
	@nLin,028 psay "SALDO ATUAL ............:"
	@nLin,113 psay Transf(SE8->E8_SALATUA + aTotal[1] - aTotal[2],"@E 99,999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	
	nLin += 2
	
	U_SaltaFolha()
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	nValPendente := 0
	cQry := "select E5_TIPODOC, E5_NUMCHEQ, E5_VALOR "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (E5_DATA between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"') and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DATA"
	
	tcquery cQry new alias "TEMP"

	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if TEMP->E5_TIPODOC == "CH"
			nValPendente += TEMP->E5_VALOR
		else
			nValPendente -= TEMP->E5_VALOR
		endif
		
		TEMP->(DbSkip())
	enddo
	
	@nLin,000 psay "CHEQUE PENDENTES .......: "
	@nLin,040 psay nValPendente picture TM(nValPendente,16,2)
	
	nLin++
	
	TEMP->(DbCloseArea())
	
	nValPredatado := 0
	aPredatado := {}
	cQry := "select E5_TIPODOC, E5_HISTOR, E5_NUMCHEQ, E5_VALOR, E5_DATA, E5_DTDIGIT "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where ((E5_DATA between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"') or (E5_DTDIGIT between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"')) and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DATA"
	
	tcquery cQry new alias "TEMP"

	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if TEMP->E5_TIPODOC == "CH"
			nValPredatado += TEMP->E5_VALOR
		else
			nValPredatado -= TEMP->E5_VALOR
		endif
		
		if (nInd := AScan(aPredatado,{|x| x[1] = AllTrim(TEMP->E5_NUMCHEQ)})) == 0
			AAdd(aPredatado,{AllTrim(TEMP->E5_NUMCHEQ),TEMP->E5_VALOR,TEMP->E5_HISTOR,TEMP->E5_DATA,TEMP->E5_DTDIGIT})
		else
			if TEMP->E5_TIPODOC == "CH"
				aPredatado[nInd][2] += TEMP->E5_VALOR
			else
				aPredatado[nInd][2] -= TEMP->E5_VALOR
			endif
		endif
		
		TEMP->(DbSkip())
	enddo
	
	@nLin,000 psay "CHEQUE PREDATADO .......: "
	@nLin,040 psay nValPredatado picture TM(nValPredatado,16,2)
	
	if !Empty(aPredatado)
		nLin += 2
		
		U_SaltaFolha()
		
		@nLin,000 psay PadC("*** PREVISAO CHEQUES ***",87)
		@++nLin,000 psay "CHEQUE  HISTORICO                                             VALOR  EMISSAO   PREVISAO"
		
		nLin++
		
		U_SaltaFolha()
//		CHEQUE  HISTORICO                                             VALOR  EMISSAO   PREVISAO
//		999999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99.999.999.999,99  99/99/99  99/99/99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//		          1         2         3         4         5         6         7         8
		
		for i := 1 to Len(aPredatado)
			if aPredatado[i][2] > 0
				@nLin,000 psay aPredatado[i][1]
				@nLin,008 psay aPredatado[i][3]
				@nLin,051 psay aPredatado[i][2] picture TM(aPredatado[i][2],16,2)
				@nLin,069 psay U_ConvData(aPredatado[i][5],"yy")
				@nLin,079 psay U_ConvData(aPredatado[i][4],"yy")
			endif
			
			nLin++
			
			U_SaltaFolha()
		next
	endif*/
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
	PEND->(DbCloseArea())
	QTRB->(DbCloseArea())
	RestArea(cAlias)
return

static function Conciliado()
	local nEntrada := 0
	local nSaida := 0
	
//	DATA     OPERACAO                                     DOCUMENTO       PREFIXO/TITULO          ENTRADAS         SAIDAS    SALDO ATUAL
//	99/99/99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA     AAAAAAAAAAAAAAA 999-999999999-999 999,999,999.99 999,999,999.99 999,999,999.99
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin,000 psay "DATA     OPERACAO                                     DOCUMENTO       PREFIXO/TITULO          ENTRADAS         SAIDAS    SALDO ATUAL"
	
	nLin++
	
	for i := 1 to Len(aConciliados)
		@nLin,000 psay U_ConvData(aConciliados[i][1],"yy")
		@nLin,009 psay Left(aConciliados[i][3],40)
		@nLin,054 psay Left(IIf(Empty(aConciliados[i][4]),aConciliados[i][5],aConciliados[i][4]),15)
		
		if !Empty(aConciliados[i][7])
			@nLin,070 psay aConciliados[i][6]+"-"+aConciliados[i][7]+"-"+aConciliados[i][8]
		elseif aConciliados[i][12] == "CH"
			if Select("TMP") <> 0
				TMP->(DbCloseArea())
			endif
			
			cQry := "select * from "+RetSqlName("SE2")+" where E2_NUMBCO = '"+aConciliados[i][5]+"' and D_E_L_E_T_ <> '*' "
			
			tcquery cQry new alias "TMP"
		
			DbSelectArea("TMP")
			
			count to nTotReg
			
			TMP->(DbGoTop())
			
			if nTotReg == 1
				@nLin,070 psay TMP->E2_PREFIXO+"-"+TMP->E2_NUM+"-"+TMP->E2_PARCELA
			endif
		endif
		
		if aConciliados[i][10] == "R"
			@nLin,088 psay Transf(aConciliados[i][9],"@E 999,999,999.99")
			
			nSaldoAtual += aConciliados[i][9]
			nEntrada += aConciliados[i][9]
		else
			@nLin,103 psay Transf(aConciliados[i][9],"@E 999,999,999.99")
			
			nSaldoAtual -= aConciliados[i][9]
			nSaida += aConciliados[i][9]
		endif
		
		@nLin,118 psay Transf(nSaldoAtual,"@E 999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "T O T A L  G E R A L  ----->"
	@nLin,087 psay Transf(nEntrada,"@E 999,999,999.99")
	@nLin,102 psay Transf(nSaida,"@E 999,999,999.99")
return

static function Pendentes(nSaldoAtual)
	if Select("QTRB") <> 0
		QTRB->(DbCloseArea())
	endif
	
	aTempStru := {}
	
	AAdd(aTempStru,{"PREVISAO","C",08,0})
	AAdd(aTempStru,{"CHEQUE","C",06,0})
	AAdd(aTempStru,{"EMISSAO","C",08,0})
	AAdd(aTempStru,{"NATUREZ","C",02,0})
	AAdd(aTempStru,{"OPERACAO","C",40,0})
	AAdd(aTempStru,{"VALOR","N",17,2})
	
	cArqTrab2 := CriaTrab(aTempStru,.T.)
	
	DbUseArea(.T.,,cArqTrab2,"PEND",.F.,.F.)
	index on PREVISAO+CHEQUE to IPEND
	
	cQry := "select E5_DTDISPO, E5_NUMCHEQ, E5_DTDIGIT, E5_HISTOR, E5_VALOR, EF_DTPREDA, EF_PREDATA, E5_TIPODOC "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SEF")+" SEF on (E5_NUMCHEQ = EF_NUM and '' = EF_TIPO and E5_BANCO = EF_BANCO and E5_AGENCIA = EF_AGENCIA and E5_CONTA = EF_CONTA) "
//	cQry += "where ((E5_DTDISPO between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"') or (E5_DTDISPO <= '"+DToS(mv_par05)+"')) and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and SE5.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' "
	cQry += "where E5_DTDISPO <= '"+DToS(mv_par05)+"' and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and SE5.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DTDISPO, E5_NUMCHEQ"
	
	tcquery cQry new alias "QTRB"
	
	DbSelectArea("QTRB")
	ProcRegua(QTRB->(RecCount()))
	QTRB->(DbGoTop())
	
	while !QTRB->(Eof())
		if QTRB->E5_TIPODOC == "EC"
			PEND->(DbGoTop())
			
			while !PEND->(Eof())
				if AllTrim(PEND->CHEQUE) == AllTrim(QTRB->E5_NUMCHEQ) .and. PEND->VALOR == QTRB->E5_VALOR
					PEND->(DbDelete())
				endif
				
				PEND->(DbSkip())
			enddo
		else
			PEND->(DbAppend())
			
			replace PEND->PREVISAO with QTRB->E5_DTDISPO,;
					PEND->CHEQUE with AllTrim(QTRB->E5_NUMCHEQ),;
					PEND->EMISSAO with QTRB->E5_DTDIGIT,;
					PEND->NATUREZ with IIf(QTRB->EF_PREDATA == "F","AV","PR"),;
					PEND->OPERACAO with QTRB->E5_HISTOR,;
					PEND->VALOR with QTRB->E5_VALOR
			
			PEND->(DbCommit())
		endif
		
		IncProc()
		QTRB->(DbSkip())
	enddo
	
	cDef := "PREVISAO  CHEQUE  EMISSAO   NT  OPERACAO                                                                       VALOR     SALDO ATUAL"
	
//	PREVISAO  CHEQUE  EMISSAO   NT  OPERACAO                                                                       VALOR     SALDO ATUAL
//	99/99/99  999999  99/99/99  AA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                              999,999,999.99  999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	PEND->(DbGoTop())
	
	@nLin,000 psay cDef
	
	nLin++
	
	while !PEND->(Eof())
		@nLin,000 psay U_ConvData(PEND->PREVISAO,"yy")
		@nLin,010 psay PEND->CHEQUE
		@nLin,018 psay U_ConvData(PEND->EMISSAO,"yy")
		@nLin,028 psay PEND->NATUREZ
		@nLin,032 psay PEND->OPERACAO
		@nLin,102 psay Transf(PEND->VALOR,"@E 999,999,999.99")
		
		nValor += PEND->VALOR
		nLin++
		
		U_SaltaFolha()
		
		if nLin == 7
			CabecLocal(cDef)
		endif
		
		PEND->(DbSkip())
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L  ----->"
	@nLin,102 psay Transf(nValor,"@E 999,999,999.99")
	@nLin,118 psay Transf(nSaldoAtual - nValor,"@E 999,999,999.99")
	
/*	cDef := "PREVISAO  CHEQUE  EMISSAO   NT  OPERACAO                                                                       VALOR     SALDO ATUAL"
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select E5_DTDISPO, E5_NUMCHEQ, E5_DTDIGIT, E5_HISTOR, E5_VALOR, EF_DTPREDA, EF_PREDATA "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SEF")+" SEF on (E5_NUMCHEQ = EF_NUM and '' = EF_TIPO) "
//	cQry += "where ((E5_DTDISPO between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"') or (E5_DTDIGIT between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"')) and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and SE5.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' "
	cQry += "where (E5_DTDISPO between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"') and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and SE5.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' "
	cQry += "order by SE5.R_E_C_N_O_"
	
	tcquery cQry new alias "TEMP"

	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if TEMP->EF_PREDATA == "F"
			if (nInd := AScan(aPendentes,{|x| x[1] = "S" .and. x[3] = AllTrim(TEMP->E5_NUMCHEQ)})) == 0
				AAdd(aPendentes,{"S",TEMP->E5_DTDISPO,AllTrim(TEMP->E5_NUMCHEQ),TEMP->E5_DTDIGIT,TEMP->E5_HISTOR,TEMP->E5_VALOR})
			else
				aPendentes[nInd][1] := "N"
			endif
		endif
		
		TEMP->(DbSkip())
	enddo
	
	ASort(aPendentes,,,{|x,y| x[2] < y[2]})*/
	
//	PREVISAO  CHEQUE  EMISSAO   NT  OPERACAO                                                                       VALOR     SALDO ATUAL
//	99/99/99  999999  99/99/99  AA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                              999,999,999.99  999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
/*	@nLin,000 psay cDef
	
	nLin++
	
	for i := 1 to Len(aPendentes)
		if aPendentes[i][1] == "S"
			@nLin,000 psay U_ConvData(aPendentes[i][2],"yy")
			@nLin,010 psay aPendentes[i][3]
			@nLin,018 psay U_ConvData(aPendentes[i][4],"yy")
			@nLin,028 psay "AV"
			@nLin,032 psay Left(aPendentes[i][5],40)
			@nLin,102 psay Transf(aPendentes[i][6],"@E 999,999,999.99")
			
			nValor += aPendentes[i][6]
			nLin++
			
			U_SaltaFolha()
			
			if nLin == 7
				CabecLocal(cDef)
			endif
		endif
	next*/
	
//	@nLin,000 psay "T O T A L  G E R A L  ----->"
//	@nLin,102 psay Transf(nValor,"@E 999,999,999.99")
//	@nLin,118 psay Transf(nSaldoAtual - nValor,"@E 999,999,999.99")
//	TEMP->(DbCloseArea())
return

static function Predatados(nSaldoAtual)
//	aPredatado := aPendentes
	
	cDef := "PREVISAO  CHEQUE  EMISSAO   NT  OPERACAO                                                                       VALOR     SALDO ATUAL"
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select E5_DTDISPO, E5_NUMCHEQ, E5_DTDIGIT, E5_HISTOR, E5_VALOR, EF_DTPREDA, EF_PREDATA "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SEF")+" SEF on (E5_NUMCHEQ = EF_NUM and '' = EF_TIPO) "
//	cQry += "where (E5_DTDISPO between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"') and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and SE5.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' "
	cQry += "where (E5_DTDISPO between '"+DToS(mv_par04)+"' and '"+DToS(mv_par05)+"') and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('EC','CH') and E5_RECONC <> 'x' and SE5.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' "
	cQry += "order by SE5.R_E_C_N_O_"
	
	tcquery cQry new alias "TEMP"

	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if TEMP->EF_PREDATA == "T"
			if (nInd := AScan(aPredatado,{|x| x[1] = "S" .and. x[3] = AllTrim(TEMP->E5_NUMCHEQ)})) == 0
				AAdd(aPredatado,{"S",TEMP->E5_DTDISPO,AllTrim(TEMP->E5_NUMCHEQ),TEMP->E5_DTDIGIT,TEMP->E5_HISTOR,TEMP->E5_VALOR})
			else
				aPredatado[nInd][1] := "N"
			endif
		endif
		
		TEMP->(DbSkip())
	enddo
	
	ASort(aPredatado,,,{|x,y| x[2]+x[3] < y[2]+y[3]})
	
//	PREVISAO  CHEQUE  EMISSAO   NT  OPERACAO                                                                       VALOR     SALDO ATUAL
//	99/99/99  999999  99/99/99  AA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                              999,999,999.99  999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
//	@nLin,000 psay "PREVISAO  CHEQUE  EMISSAO   NT  OPERACAO                                                                       VALOR     SALDO ATUAL"
	
//	nLin++
	
	for i := 1 to Len(aPredatado)
		if aPredatado[i][1] == "S"
			@nLin,000 psay U_ConvData(aPredatado[i][2],"yy")
			@nLin,010 psay aPredatado[i][3]
			@nLin,018 psay U_ConvData(aPredatado[i][4],"yy")
			@nLin,028 psay "PR"
			@nLin,032 psay Left(aPredatado[i][5],40)
			@nLin,102 psay Transf(aPredatado[i][6],"@E 999,999,999.99")
			
			nValor += aPredatado[i][6]
			nLin++
			
			U_SaltaFolha()
			
			if nLin == 7
				CabecLocal(cDef)
			endif
		endif
	next
	
	@nLin,000 psay "T O T A L  G E R A L  ----->"
	@nLin,102 psay Transf(nValor,"@E 999,999,999.99")
	@nLin,118 psay Transf(nSaldoAtual - nValor,"@E 999,999,999.99")
return

static function CabecLocal()
	nLin++
	
/*	if SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.))
		@nLin,000 psay "BANCO "+SA6->A6_COD+" - "+SA6->A6_NREDUZ
		@nLin,035 psay "AGENCIA "+SA6->A6_AGENCIA
		@nLin,051 psay "CONTA "+SA6->A6_NUMCON
		@nLin,115 psay Transf(nSaldoAtual,"@E 99,999,999,999.99")
	endif
	
	nLin += 2
	
	@nLin,000 psay cDef*/
	
	if Empty(aLimite)
//		     * * * * *   D A D O S  C A D A S T R A I S   * * * * *               * * * * *   L I M I T E  D E  C R E D I T O   * * * * *
//		GERENTE.: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        DESCRICAO                         LIMITE   TAXA  VENCTO
//		E-MAIL..: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        AAAAAAAAAAAAAAAAAAAAAAAAA  99,999,999.99  99.99  99/99/99
//		TELEFONE: AAAAAAAAAA
//		CELULAR.: AAAAAAAAAA
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay "     * * * * *   D A D O S  C A D A S T R A I S   * * * * *"
		@++nLin,000 psay "GERENTE.: "+AllTrim(aBanco[1])
		@++nLin,000 psay "E-MAIL..: "+Lower(AllTrim(aBanco[2]))
		@++nLin,000 psay "TELEFONE: "+AllTrim(aBanco[3])
		@++nLin,000 psay "CELULAR.: "+AllTrim(aBanco[4])
	else
		@nLin,000 psay "     * * * * *   D A D O S  C A D A S T R A I S   * * * * *               * * * * *   L I M I T E  D E  C R E D I T O   * * * * *"
		@++nLin,000 psay "GERENTE.: "+AllTrim(aBanco[1])
		@nLin,073 psay "DESCRICAO                         LIMITE   TAXA  VENCTO"
		@++nLin,000 psay "E-MAIL..: "+Lower(AllTrim(aBanco[2]))
		ExibirLimite(1)
		@++nLin,000 psay "TELEFONE: "+AllTrim(aBanco[3])
		ExibirLimite(2)
		@++nLin,000 psay "CELULAR.: "+AllTrim(aBanco[4])
		ExibirLimite(3)
	endif
	
//	nLin++
	nLin += 2
	
	@nLin,000 psay "BANCO: "+aBanco[5]+" - "+aBanco[6]
	@nLin,036 psay "AG: "+aBanco[7]
	@nLin,048 psay "CC: "+aBanco[8]
	@nLin,099 + nTamSld psay "SLD. ANTERIOR: "+AllTrim(Transf(nSaldoAtual,"@E 99,999,999,999.99"))
	@++nLin,000 psay __PrtThinLine()
	@++nLin,000 psay cDef
	
	nLin++
return

static function AReceber()
	local nTotal := 0
	local nValor := 0
	local nTotDia := 0
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select E1_VENCREA, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_NOMCLI, E1_VALOR, E1_SALDO, E1_BAIXA "
	cQry += "from "+RetSqlName("SE1")+" "
//	cQry += "where E1_VENCREA <= '"+DToS(dDataAte + 5)+"' and ((E1_BAIXA = '') or (E1_BAIXA <> '' and E1_SALDO > 0)) and D_E_L_E_T_ <> '*' "
	cQry += "where (E1_VENCREA between '"+cDataDe+"' and '"+DToS(dDataAte + 5)+"') and ((E1_BAIXA = '') or (E1_BAIXA <> '' and E1_SALDO > 0)) and D_E_L_E_T_ <> '*' "
	cQry += "order by E1_VENCREA, E1_NOMCLI"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	@nLin,000 psay PadC("Periodo: "+U_ConvData(cDataDe)+" ate "+U_ConvData(DToS(dDataAte + 5)),132)
//	@nLin,000 psay PadC("Todos os titulos a receber em aberto ate "+U_ConvData(DToS(dDataAte + 5)),132)
	
	nLin += 2
	
	U_SaltaFolha()
	
	if nLin == 7
		CabecLocal(cDef)
	endif
	
	@nLin,000 psay "PREVISAO  CLIENTE               DOCUMENTO      PROJETO  ORDEM COMPRA                 VALOR          TOTAL DIA"
	
	nLin++
	cDef := "PREVISAO  CLIENTE               DOCUMENTO      PROJETO  ORDEM COMPRA                 VALOR          TOTAL DIA"
	
	U_SaltaFolha()
	
	if nLin == 7
		CabecLocal(cDef)
	endif
	
	while !TEMP->(Eof())
//		PREVISAO  CLIENTE               DOCUMENTO      PROJETO  ORDEM COMPRA                 VALOR          TOTAL DIA
//		99/99/99  AAAAAAAAAAAAAAAAAAAA  999999999-999  999999   999999999999999   9,999,999,999.99   9,999,999,999.99
//		01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		nValor := IIf(Empty(TEMP->E1_BAIXA),TEMP->E1_VALOR,TEMP->E1_SALDO)
		cDia := TEMP->E1_VENCREA
		
		@nLin,000 psay U_ConvData(TEMP->E1_VENCREA,"yy")
		@nLin,010 psay TEMP->E1_NOMCLI
		@nLin,032 psay TEMP->E1_NUM+"-"+TEMP->E1_PREFIXO
		
		cQry := "select C6_CLVL, CTH_AF, sum(D2_VALBRUT) as D2_TOTAL "
		cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SC6")+" SC6 on (D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM) "
		cQry += "	inner join "+RetSqlName("CTH")+" CTH on (C6_CLVL = CTH_CLVL) "
		cQry += "where D2_DOC = '"+TEMP->E1_NUM+"' and D2_SERIE = '"+TEMP->E1_PREFIXO+"' and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' "
		cQry += "group by C6_CLVL, CTH_AF"
		
		tcquery cQry new alias "CON1"
		
		DbSelectArea("CON1")
		CON1->(DbGoTop())
		
		if !CON1->(Eof())
			while !CON1->(Eof())
				@nLin,047 psay Left(CON1->C6_CLVL,6)
				@nLin,056 psay CON1->CTH_AF
				@nLin,074 psay Transf(CON1->D2_TOTAL,"@E 9,999,999,999.99")
				
				nLin++
				nTotal += CON1->D2_TOTAL
				nTotDia += CON1->D2_TOTAL
				
				CON1->(DbSkip())
			enddo
		else
			@nLin,074 psay Transf(nValor,"@E 9,999,999,999.99")
			
			nLin++
			nTotal += nValor
			nTotDia += nValor
		endif
		
		TEMP->(DbSkip())
		
		if cDia <> TEMP->E1_VENCREA
			nLin--
			
			@nLin,093 psay Transf(nTotDia,"@E 9,999,999,999.99")
			
			nTotDia := 0
			nLin++
			cDia := TEMP->E1_VENCREA
		endif
		
		CON1->(DbCloseArea())
		U_SaltaFolha()
		
		if nLin == 7
			CabecLocal(cDef)
		endif
	enddo
	
	nLin++
	
	@nLin,000 psay "T O T A L"
	@nLin,074 psay Transf(nTotal,"@E 9,999,999,999.99")
return

static function ExibirLimite(nPosicao)
	if nPosicao <= Len(aLimite)
		@nLin,073 psay Left(aLimite[nPosicao][1],25)
		@nLin,100 psay Transf(aLimite[nPosicao][2],"@E 99,999,999.99")
		@nLin,115 psay Transf(aLimite[nPosicao][3],"@E 99.99")
		@nLin,122 psay U_ConvData(DToS(aLimite[nPosicao][4]),"yy")
	else
		for i := 3 to Len(aLimite)
			@nLin,073 psay Left(aLimite[nPosicao][1],25)
			@nLin,100 psay Transf(aLimite[nPosicao][2],"@E 99,999,999.99")
			@nLin,115 psay Transf(aLimite[nPosicao][3],"@E 99.99")
			@nLin,122 psay U_ConvData(DToS(aLimite[nPosicao][4]),"yy")
		next
		
		if !Empty(nTotal)
			@nLin,073 psay "T O T A L"
			@nLin,100 psay Transf(nTotal,"@E 99,999,999.99")
		endif
	endif
return