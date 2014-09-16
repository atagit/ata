/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cópia de Cheque                                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function CPCHEQUE()
	private aOrd    := {"Cheque"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "CPCHQ"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "COPIA DE CHEQUE"
	private ContFun := 0
	private cString := "SEF"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
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
	private cChqIni := ""
	private cChqFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco                                             ³
	//³ mv_par02 - Agencia                                           ³
	//³ mv_par03 - Conta                                             ³
	//³ mv_par04 - Cheque de                                         ³
	//³ mv_par05 - Cheqie ate                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cBancoDe := mv_par01
	cAgenciaDe := mv_par02
	cContaDe := mv_par03
	cChqIni := AllTrim(mv_par04)
	cChqFin := AllTrim(mv_par05)
	
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
	local nItem := 1
	
	private aNatureza := {}
	private lFirst := .T.
	
/*	cQry := "select * "
	cQry += "from "+RetSqlName("SEF")+" "
	cQry += "where (EF_NUM between '"+cChqIni+"' and '"+cChqFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "order by EF_NUM, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_TITULO"*/
	
/*	cQry := "select distinct SEF.*, E5_DTDIGIT "
	cQry += "from "+RetSqlName("SEF")+" SEF inner join "+RetSqlName("SE5")+" SE5 on (EF_NUM = E5_NUMCHEQ and EF_BANCO = E5_BANCO and EF_AGENCIA = E5_AGENCIA and EF_CONTA = E5_CONTA) "
	cQry += "where (EF_NUM between '"+cChqIni+"' and '"+cChqFin+"') and E5_TIPODOC = 'CH' and SEF.D_E_L_E_T_ <> '*' and SE5.D_E_L_E_T_ <> '*' "
	cQry += "order by EF_NUM, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_TITULO"*/
	
	cQry := "select distinct E5_DTDIGIT, SEF.* "
	cQry += "from "+RetSqlName("SEF")+" SEF inner join "+RetSqlName("SE5")+" SE5 on (EF_NUM = E5_NUMCHEQ and EF_BANCO = E5_BANCO and EF_AGENCIA = E5_AGENCIA and EF_CONTA = E5_CONTA and EF_VALOR = E5_VALOR) "
//	cQry += "where (EF_NUM between '"+cChqIni+"' and '"+cChqFin+"') and EF_BANCO = '"+cBancoDe+"' and EF_AGENCIA = '"+cAgenciaDe+"' and EF_CONTA = '"+cContaDe+"' and EF_TITULO = '' and E5_TIPODOC = 'CH' and SEF.D_E_L_E_T_ <> '*' and SE5.D_E_L_E_T_ <> '*' "
	cQry += "where (EF_NUM between '"+cChqIni+"' and '"+cChqFin+"') and EF_BANCO = '"+cBancoDe+"' and EF_AGENCIA = '"+cAgenciaDe+"' and EF_CONTA = '"+cContaDe+"' and ((EF_TITULO = '' and E5_TIPODOC = 'CH') or (EF_TIPO = 'PA')) and SEF.D_E_L_E_T_ <> '*' and SE5.D_E_L_E_T_ <> '*' "
	cQry += "order by EF_NUM, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_TITULO"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cNum := TEMP->EF_NUM
		lPredat := TEMP->EF_PREDATA
		cHistor := AllTrim(TEMP->EF_HIST)
		nTotChq := TEMP->EF_VALOR
		cOrigem := TEMP->EF_ORIGEM
//		dEmiss := SToD(TEMP->EF_DATA)
		dEmiss := SToD(TEMP->E5_DTDIGIT)
		lFirst := .T.
		
		if TEMP->EF_PREDATA == "T"
			dData := SToD(TEMP->EF_DTPREDA)
		else
			dData := SToD(TEMP->EF_DATA)
		endif
		
		U_Cheque(cBancoDe,cAgenciaDe,cContaDe,cNum,nTotChq,TEMP->EF_BENEF,dData)
		Cbc(15)
		
		@nLin  ,002 psay Replicate("=",132)
		@++nLin,003 psay "BANCO           | AGENCIA / CONTA    |          VALOR | NUM CHEQUE      | DT EMISSAO | NATUREZA  | P. COMPENS"
		@++nLin,002 psay Replicate("-",132)
		@++nLin,003 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),SA6->A6_NREDUZ," ")
		@nLin  ,021 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),AllTrim(SA6->A6_AGENCIA)+" / "+SA6->A6_NUMCON," ")
		@nLin  ,042 psay Transf(nTotChq,"@E 999,999,999.99")
		@nLin  ,059 psay cNum
		@nLin  ,077 psay U_ConvData(DToS(dEmiss))
		@nLin  ,090 psay IIf(lPredat == "F","AVISTA","PREDATADO")
		@nLin  ,102 psay U_ConvData(DToS(dData))
//		@nLin  ,102 psay U_ConvData(IIf(TEMP->EF_PREDATA == "F",TEMP->EF_DATA,DToS(dData)))
		@++nLin,003 psay "HISTORICO: "+cHistor
		@++nLin,002 psay Replicate("=",132)
		
		if cOrigem <> "FINA390AVU"
//			   IT | FORNECEDOR                               | PREF | TITULO    | PARC | NATUREZA                           |          VALOR
//			   99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAA    999999999   999    999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			if Select("CON") <> 0
				CON->(DbCloseArea())
			endif
			
			@++nLin,003 psay "IT | FORNECEDOR                               | PREF | TITULO    | PARC | NATUREZA                           |          VALOR"
			@++nLin,002 psay Replicate("-",132)
			
			cQry := "select * "
			cQry += "from "+RetSqlName("SE5")+" "
			cQry += "where E5_NUMCHEQ = '"+cNum+"' and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and E5_TIPODOC not in ('CH','EC','MT','JR') and D_E_L_E_T_ <> '*' "
			cQry += "order by E5_NUMCHEQ"
			
			tcquery cQry new alias "CON"
			
			DbSelectArea("CON")
			CON->(DbGoTop())
			
			nItem := 1
			
			while !CON->(Eof())
				@nLin+1,003 psay StrZero(nItem,2)
				@nLin+1,008 psay CON->E5_BENEF
				@nLin+1,051 psay CON->E5_PREFIXO
				@nLin+1,058 psay CON->E5_NUMERO
				@nLin+1,070 psay CON->E5_PARCELA
				
				if SE2->(DbSeek(xFilial("SE2")+CON->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA),.F.))
					cNatureza := IIf(SZ5->(DbSeek(xFilial("SZ5")+SE2->E2_BALGER,.F.)),SZ5->Z5_NOME," ")
					
					@nLin+1,077 psay SE2->E2_BALGER+" "+cNatureza
					
					if (nInd := AScan(aNatureza,{|x| x[1] = SE2->E2_BALGER})) == 0
						AAdd(aNatureza,{SE2->E2_BALGER,cNatureza,CON->E5_VALOR})
					else
						aNatureza[nInd][3] += CON->E5_VALOR
					endif
				endif
				
				@nLin+1,114 psay Transf(CON->E5_VALOR,"@E 999,999,999.99")
				
				nLin++
				nItem++
				
				if nLin == 79
					@++nLin,002 psay Replicate("-",132)
					@++nLin,068 psay "*** CONTINUA ***"
					@++nLin,002 psay Replicate("-",132)
					
					Cbc(1)
					
					@nLin  ,002 psay Replicate("=",132)
					@++nLin,003 psay "BANCO           | AGENCIA / CONTA    |          VALOR | NUM CHEQUE      | DT EMISSAO | NATUREZA  | P. COMPENS"
					@++nLin,002 psay Replicate("-",132)
					@++nLin,003 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),SA6->A6_NREDUZ," ")
					@nLin  ,021 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),AllTrim(SA6->A6_AGENCIA)+" / "+SA6->A6_NUMCON," ")
					@nLin  ,042 psay Transf(nTotChq,"@E 999,999,999.99")
					@nLin  ,059 psay cNum
					@nLin  ,077 psay U_ConvData(DToS(dEmiss))
					@nLin  ,090 psay IIf(lPredat == "F","AVISTA","PREDATADO")
					@nLin  ,102 psay U_ConvData(DToS(dData))
					@++nLin,003 psay "HISTORICO: "+cHistor
					@++nLin,002 psay Replicate("=",132)
					@++nLin,003 psay "IT | FORNECEDOR                               | PREF | TITULO    | PARC | NATUREZA                           |          VALOR"
					@++nLin,002 psay Replicate("-",132)
				endif
				
				CON->(DbSkip())
			enddo
			
			CON->(DbCloseArea())
			
			@++nLin,002 psay Replicate("-",132)
			@++nLin,077 psay "T O T A L"
			@nLin  ,114 psay Transf(nTotChq,"@E 999,999,999.99")
			@++nLin,002 psay Replicate("-",132)
		endif
		
		nLin += 3
		nItem := 1
		
		Assinatura()
		Rdp()
		
//		if cOrigem == "FINA390AVU"
			TEMP->(DbSkip())
//		endif
	enddo
	
	TEMP->(DbCloseArea())
return

static function Cbc(nPosLin)
//	@000,000 psay U_TamPag(66)+U_Reduz(0)
//	@000,001 psay " "
	
	do case
		case cEmpresa == "01"
			@nPosLin,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T A"+U_Expande(0)+U_AltCar(12)
		case cEmpresa == "02"
			@nPosLin,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T F"+U_Expande(0)+U_AltCar(12)
		otherwise
			@nPosLin,001 PSay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"TESTE"+U_Expande(0)+U_AltCar(12)
	endcase
	
	@nPosLin,020 psay U_Expande(5)+"COPIA DE CHEQUE"+U_Expande(0)
	
	do case
		case cEmpresa == "01"
			@++nPosLin,001 psay U_Reduz(5)+"IND MEC DE  USINAGEM"+U_Reduz(0)
		case cEmpresa == "02"
			@++nPosLin,001 psay U_Reduz(5)+"ESTRUTURAS METALICAS"+U_Reduz(0)
		otherwise
			@++nPosLin,001 PSay U_Reduz(5)+"TESTE DESENVOLVIMENT"+U_Reduz(0)
	endcase
	
//	@nPosLin,070 psay U_Reduz(5)+"Emissao: "+U_ConvData(DToS(Date()))+U_Reduz(0)
	@nPosLin,095 psay U_Reduz(4)+" "+U_Reduz(0)
	@++nPosLin,000 psay U_15Cpi(.T.)
	
	nPosLin++
	
	nLin := nPosLin
return

static function Rdp()
	nPosLin := 079
	
	@nPosLin,000 psay U_15Cpi(.T.)
//	@nPosLin,000 psay cLeg
	@nPosLin+1,002 psay replicate("=",132)
	@nPosLin+2,002 psay "Fonte: ..\"+FunName()+".PRW"
	@nPosLin+2,126 psay "Pag. 001"
//	@nPosLin+1,128 psay "Pag. "+StrZero(nPag,3)
return

static function Assinatura()
	local nTotal := 0
	
	@nLin+1,002 psay Padc("         Elaborado por                             Ger. Adm/Fin                               Diretor            ",132)
	@nLin+2,002 psay Padc("_______________________________          _______________________________          _______________________________",132)
	@nLin+3,002 psay Padc("           /       /                                /       /                                /       /           ",132)
	
	nLin += 6
	
//	***** RESUMO DA NATUREZA *****
//	  CONTA NATUREZA                                  VALOR
//	  999   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999.99
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	@nLin,002 psay Padc("***** RESUMO DA NATUREZA *****",52)
	@++nLin,002 psay "CONTA NATUREZA                                  VALOR"
	
	nLin++
	
	ASort(aNatureza,,,{|x,y| x[2] < y[2]})
	
	for i := 1 to Len(aNatureza)
		@nLin,002 psay aNatureza[i][1]
		@nLin,008 psay aNatureza[i][2]
		@nLin,041 psay Transf(aNatureza[i][3],"@E 999,999,999.99")
		
		nLin++
		nTotal += aNatureza[i][3]
		
		if nLin == 79
			Cbc(1)
			
			@nLin  ,002 psay Replicate("=",132)
			@++nLin,003 psay "BANCO           | AGENCIA / CONTA    |          VALOR | NUM CHEQUE      | DT EMISSAO | NATUREZA  | P. COMPENS"
			@++nLin,002 psay Replicate("-",132)
			@++nLin,003 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),SA6->A6_NREDUZ," ")
			@nLin  ,021 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),AllTrim(SA6->A6_AGENCIA)+" / "+SA6->A6_NUMCON," ")
			@nLin  ,042 psay Transf(nTotChq,"@E 999,999,999.99")
			@nLin  ,059 psay cNum
			@nLin  ,077 psay U_ConvData(DToS(dData))
			@nLin  ,090 psay IIf(TEMP->EF_PREDATA == "F","AVISTA","PREDATADO")
			@nLin  ,102 psay IIf(TEMP->EF_PREDATA == "F",U_ConvData(DToS(dData)),U_ConvData(TEMP->EF_DATA))
			@++nLin,003 psay "HISTORICO: "+AllTrim(TEMP->EF_HIST)
			@++nLin,002 psay Replicate("=",132)
			@++nLin,002 psay Padc("***** RESUMO DA NATUREZA *****",52)
			@++nLin,002 psay "CONTA NATUREZA                                  VALOR"
		endif
	next
	
	nLin++
	
	if nLin == 79
		Cbc(1)
		
		@nLin  ,002 psay Replicate("=",132)
		@++nLin,003 psay "BANCO           | AGENCIA / CONTA    |          VALOR | NUM CHEQUE      | DT EMISSAO | NATUREZA  | P. COMPENS"
		@++nLin,002 psay Replicate("-",132)
		@++nLin,003 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),SA6->A6_NREDUZ," ")
		@nLin  ,021 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.)),AllTrim(SA6->A6_AGENCIA)+" / "+SA6->A6_NUMCON," ")
		@nLin  ,042 psay Transf(nTotChq,"@E 999,999,999.99")
		@nLin  ,059 psay cNum
		@nLin  ,077 psay U_ConvData(DToS(dData))
		@nLin  ,090 psay IIf(TEMP->EF_PREDATA == "F","AVISTA","PREDATADO")
		@nLin  ,102 psay IIf(TEMP->EF_PREDATA == "F",U_ConvData(DToS(dData)),U_ConvData(TEMP->EF_DATA))
		@++nLin,003 psay "HISTORICO: "+AllTrim(TEMP->EF_HIST)
		@++nLin,002 psay Replicate("=",132)
		@++nLin,002 psay Padc("***** RESUMO DA NATUREZA *****",52)
		@++nLin,002 psay "CONTA NATUREZA                                  VALOR"
	endif
	
	@nLin,002 psay "T O T A L"
	@nLin,041 psay Transf(nTotal,"@E 999,999,999.99")
return

/*static function Cheque(cBanco,cAG,cCT,cNum,nTotChq,cBenef,dData)
	local lRet := .F.
	local lFirst := .T.
	local aMes := {"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
	local cExtenso := Extenso(nTotChq,.F.,1)
	local lFa480Dat := ExistBlock("FA480DAT")
	local cAlias := Alias()
	local cExt1
	local cExt2
	local nTamanho
	local nLoop
	local nRepete
	local nLinLoc
	local nColLoc
	local nColDat
	local nColBco
	local nColCta
	local cValor
	local Munic
	
	DbSelectArea("SA6")
	DbSeek(xFilial("SA6")+cBanco+cAG+cCT+cNum,.F.)
	
	if !Empty(SA6->A6_LAYOUT)
		nTamChq := Val(SubStr(SA6->A6_LAYOUT,1,2))
		nSalto  := Val(SubStr(SA6->A6_LAYOUT,3,1))
		nLinVlr := Val(SubStr(SA6->A6_LAYOUT,4,1))
		nColVlr := Val(SubStr(SA6->A6_LAYOUT,25,3))
		nColVlr := IIf(nColVlr == 0,93,nColVlr)
		nLin1Ext:= Val(SubStr(SA6->A6_LAYOUT,5,1)) - nLinVlr
		nCol1Ext:= Val(SubStr(SA6->A6_LAYOUT,6,2))
		nLin2Ext:= Val(SubStr(SA6->A6_LAYOUT,8,1)) - Val(SubStr(SA6->A6_LAYOUT,5,1))
		nCol2Ext:= Val(SubStr(SA6->A6_LAYOUT,9,2))
		nTamExt := Val(SubStr(SA6->A6_LAYOUT,23,2))
		nTamExt := IIf(nTamExt == 0,95,nTamExt)
		nLinFav := Val(SubStr(SA6->A6_LAYOUT,11,2)) - Val(SubStr(SA6->A6_LAYOUT,8,1))
		nColFav := Val(SubStr(SA6->A6_LAYOUT,13,2))
		nLinDat := Val(SubStr(SA6->A6_LAYOUT,15,2)) - Val(SubStr(SA6->A6_LAYOUT,11,2))
		nColVir := Val(SubStr(SA6->A6_LAYOUT,17,2))
		nCasas  := Val(SubStr(SA6->A6_LAYOUT,19,1))
		nCasas  := IIf(nCasas == 0,2,nCasas)
		nColAno := Val(SubStr(SA6->A6_LAYOUT,20,3))
		lComp   := (SubStr(SA6->A6_LAYOUT,28,1) == "S" .or. SubStr(SA6->A6_LAYOUT,28,1) == " ")
		cMunic  := SA6->A6_MUN
		
		DbCloseArea()
		DbSelectArea(cAlias)
		
		cExt1 := SubStr(cExtenso,1,nTamExt)
		nLoop := Len(cExt1)
		
		while .T.
			if Len(cExtenso) == Len(cExt1) .and. Len(cExt1) + nCol1Ext <= nTamExt
				Exit
			endif
			
			if SubStr(cExtenso,Len(cExt1),1) == " " .and. Len(cExt1) + nCol1Ext <= nTamExt
				Exit
			endif
			
			cExt1 := SubStr(cExtenso,1,nLoop)
			nLoop--
			
			if nLoop <= 0
				MsgAlert("Erro na configuracao do cheque."+Chr(13)+"Verifique o tamanho das linhas de extenso.")
				return .F.
			endif
		enddo
		
		cExt2 := SubStr(cExtenso,Len(cExt1) + 1,nTamExt)
		
		if Empty(cExt2)
			cExt1 += Replicate("*",nTamExt - Len(cExt1) - nCol1Ext)
		else
			cExt1 := StrTran(cExt1," ","  ",,nTamExt - Len(cExt1) - nCol1Ext + 1)
		endif
		
		cExt2 += Replicate("*",nTamExt - Len(cExt2) - nCol2Ext)
		nComp := GetMv("MV_COMP")
		cSimb := GetMv("MV_SIMB1")
		cValor := AllTrim(Transf(nTotChq,"@E 99,999,999,999.99"))
		
		if lFirst
			@nLinVlr,0 psay Chr(27)+Chr(64)
			
			if nSalto = 8
				@nLinVlr,0 psay Chr(27)+Chr(48)
			endif
			
			if lComp .and. !Empty(nComp)
				@nLinVlr,0 psay Chr(nComp)
			endif
		endif
		
		__LogPages()
		
		if lFirst
			if lComp
				SetPrc(nLinVlr,0)
				@nLinVlr,nColVlr + 1 psay cSimb
			else
				SetPrc(nLinVlr,0)
				@nLinVlr,nColVlr + 2 psay cSimb
			endif
			
			lFirst := .F.
		else
			@nLinVlr,nColVlr psay cSimb
		endif
		
		nRepete := PCol() + Len(cValor) + 17 - Len(cValor) - nTamExt
		
		if nRepete > 0
			cValor += Replicate("*",17 - Len(cValor) - nRepete)
		else
			cValor += Replicate("*",17 - Len(cValor))
		endif
		
		@nLinVlr,PCol() psay cValor
		@PRow() + nLin1Ext,nCol1Ext psay cExt1
		@PRow() + nLin2Ext,nCol2Ext psay cExt2
		@PRow() + nLinFav ,nColFav psay cBenef
		
		nTamanho := 1 + Len(Trim(cMunic))
		
		@PRow() + nLinDat,nColVir - nTamanho psay IIf(!Empty(cMunic),Trim(cMunic)," ")
		@PRow(),nColVir + 1 psay Day(dData) picture "99"
		@PRow(),PCol() + 6 psay aMes[Month(dData)]
		
		if nCasas == 1
			@PRow(),nColAno psay SubStr(Str(Year(dData),4),4,1)
		elseif nCasas == 2
			@PRow(),nColAno psay SubStr(Str(Year(dData),4),3,2)
		elseif nCasas == 3
			@PRow(),nColAno psay SubStr(Str(Year(dData),4),2,3)
		else
			@PRow(),nColAno psay Str(Year(dData),4)
		endif
	else
		DbCloseArea()
		DbSelectArea(cAlias)
	endif
return*/
