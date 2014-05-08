/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 27/01/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relação de notas fiscais emitidas                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _TPPROJ "0001/0002"			// 0001-Usinagem / 0002-Jato e Pintura

user function RELNFEMI()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "NFEMIT"
//	private Cabec1  := "N.F.     | EMISSAO  | NATUREZA             | CLIENTE                        | PROJET | PR.ENTRG |         PESO |          VALOR |   DD"
	private Cabec1  := "N.F.     | EMISSAO  | NATUREZA | CLIENTE | PROJETO                          | PR.ENTRG |         PESO |          VALOR |   DD | NEG"
	private Cabec2  := ""
	private cDesc1  := "NOTAS FISCAIS EMITIDAS"
	private ContFun := 0
	private cString := "SD2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private nLastKey := 0
	private lFilter := .F.
	private lDic	:= .F.
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	private lExterior := .F.
	
	private cDtIni := ""
	private cDtFin := ""
	private cTpPrjIni := ""
	private cTpPrjFin := ""
	private cCliIni := ""
//	private cCliFin := ""
	private cProjIni := ""
	private cProjFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Data Emissao de                                   ³
	//³ mv_par02 - Data Emissao ate                                  ³
	//³ mv_par03 - Tipo Projeto de                                   ³
	//³ mv_par04 - Tipo Projeto ate                                  ³
	//³ mv_par05 - Cliente de                                        ³
	//³ mv_par06 - Cliente ate                                       ³
	//³ mv_par07 - Projeto de                                        ³
	//³ mv_par08 - Projeto ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,lDic,aOrd,,Tamanho,,lFilter)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cTpPrjIni := mv_par03
	cTpPrjFin := IIf(Empty(mv_par04),"ZZZZ",mv_par04)
//	cCliIni := IIf(SA1->(DbSeek(xFilial("SA1")+mv_par05,.F.)),Left(SA1->A1_CGC,8),"")
//	cCliFin := IIf(SA1->(DbSeek(xFilial("SA1")+mv_par06,.F.)),Left(SA1->A1_CGC,8),"ZZZZZZZZZZZZZZ")
	cProjIni := mv_par06
	cProjFin := mv_par07
	
	if SA1->(DbSeek(xFilial("SA1")+mv_par05,.F.))
		if SA1->A1_EST == "EX"
			cCliIni := Left(SA1->A1_NOME,8)
			lExterior := .T.
		else
			cCliIni := Left(SA1->A1_CGC,8)
		endif
	else
		cCliIni := ""
	endif
	
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
	local nTotP := 0
	local nTotV := 0
	local nTotItem := 0
	local nTotPeso := 0
	local nTotValor := 0
	local nPesol := 0
	local cCompara := ""
	local aNegocios := {}
	local aClientes := {}
	local aContas := {}
	local aImpostos := {}
	local aSortNegocios := {}
	local aSortClientes := {}
	local aSortContas := {}
	
	AAdd(aImpostos,{"ICMS",0,0})
	AAdd(aImpostos,{"IPI",0,0})
	AAdd(aImpostos,{"ISS",0,0})
	AAdd(aImpostos,{"INSS",0,0})
	AAdd(aImpostos,{"IRRF",0,0})
	AAdd(aImpostos,{"CSLL",0,0})
	AAdd(aImpostos,{"PIS",0,0})
	AAdd(aImpostos,{"COFIS",0,0})
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	if lExterior
		cCondicao := IIf(!Empty(cCliIni),"(left(A1_NOME,8) like '"+cCliIni+"%' or left(A2_NOME,8) like '"+cCliIni+"%') and ","")
	else
		cCondicao := IIf(!Empty(cCliIni),"(left(A1_CGC,8) = '"+cCliIni+"' or left(A2_CGC,8) = '"+cCliIni+"') and ","")
	endif
	
//	cQry := "select CTH_TPPRJ, D2_DOC, D2_SERIE, D2_CF, F4_TEXTO, D2_EMISSAO, D2_CLIENTE, D2_LOJA, NREDUZ = case when A2_NREDUZ is not null then A2_NREDUZ else A1_NREDUZ end, C6_CLVL, CTH_DTENTR, PESOL = case when left(F4_OPER,1) in ('6','8') then 0 else C5_PESOL end, F4_OPER, F2_VALISS, F2_VALINSS, F2_VALIRRF, F2_VALPIS, F2_VALCOFI, F2_VALCSLL, sum(D2_VALICM) as D2_VALICM, sum(D2_VALIPI) as D2_VALIPI, sum(D2_VALIMP6) as D2_VALIMP6, sum(D2_VALIMP5) as D2_VALIMP5, sum(case when left(F4_OPER,1) in ('6','8') then 0 else D2_TOTAL end) as D2_TOTAL "
	cQry := "select CTH_TPPRJ, D2_DOC, D2_SERIE, D2_CF, F4_TEXTO, D2_EMISSAO, D2_CLIENTE, D2_LOJA, NREDUZ = case when A2_NREDUZ is not null then A2_NREDUZ else A1_NREDUZ end, C6_CLVL, CTH_DTENTR, PESOL = case when left(F4_OPER,1) in ('6','8') then 0 else C5_PESOL end, F4_OPER, F2_VALISS, F2_VALINSS, F2_VALIRRF, F2_VALPIS, F2_VALCOFI, F2_VALCSLL, sum(D2_VALICM) as D2_VALICM, sum(D2_VALIPI) as D2_VALIPI, sum(D2_VALIMP6) as D2_VALIMP6, sum(D2_VALIMP5) as D2_VALIMP5, sum(case when left(F4_OPER,1) in ('6','8') then 0 else D2_TOTAL end) as D2_TOTAL, CNPJ = case when A2_NREDUZ is not null then A2_CGC else A1_CGC end "
	cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SF2")+" SF2 on (D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_CLIENTE = F2_CLIENTE and D2_LOJA = F2_LOJA) "
	cQry += "	inner join "+RetSqlName("SC6")+" SC6 on (D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM) "
	cQry += "	inner join "+RetSqlName("SC5")+" SC5 on (C5_NUM = C6_NUM) "
	cQry += "	inner join "+RetSqlName("CTH")+" CTH on (C6_CLVL = CTH_CLVL) "
	cQry += "	inner join "+RetSqlName("SF4")+" SF4 on (D2_TES = F4_CODIGO) "
	cQry += "	left join "+RetSqlName("SA2")+" SA2 on (D2_CLIENTE = A2_COD and D2_LOJA = A2_LOJA) and D2_TIPO in ('B','D') "
	cQry += "	left join "+RetSqlName("SA1")+" SA1 on (D2_CLIENTE = A1_COD and D2_LOJA = A1_LOJA) and D2_TIPO not in ('B','D') "
//	cQry += "where (D2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (CTH_TPPRJ between '"+cTpPrjIni+"' and '"+cTpPrjFin+"') and SD2.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' and SF2.D_E_L_E_T_ <> '*' "
//	cQry += "where ((left(A1_CGC,8) between '"+cCliIni+"' and '"+cCliFin+"') or (left(A2_CGC,8) between '"+cCliIni+"' and '"+cCliFin+"')) and (D2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (CTH_TPPRJ between '"+cTpPrjIni+"' and '"+cTpPrjFin+"') and D2_SERIE <> 'Z' and SD2.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' and SF2.D_E_L_E_T_ <> '*' "
	cQry += "where "+cCondicao+"(D2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (CTH_TPPRJ between '"+cTpPrjIni+"' and '"+cTpPrjFin+"') and (CTH_CLVL between '"+cProjIni+"' and '"+cProjFin+"') and D2_SERIE <> 'Z' and SD2.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' and SF2.D_E_L_E_T_ <> '*' "
//	cQry += "group by CTH_TPPRJ, D2_DOC, D2_SERIE, D2_CF, F4_TEXTO, D2_EMISSAO, D2_CLIENTE, D2_LOJA, A1_NREDUZ, A2_NREDUZ, C6_CLVL, CTH_DTENTR, C5_PESOL, F4_OPER, F2_VALISS, F2_VALINSS, F2_VALIRRF, F2_VALPIS, F2_VALCOFI, F2_VALCSLL "
	cQry += "group by CTH_TPPRJ, D2_DOC, D2_SERIE, D2_CF, F4_TEXTO, D2_EMISSAO, D2_CLIENTE, D2_LOJA, A1_NREDUZ, A2_NREDUZ, C6_CLVL, CTH_DTENTR, C5_PESOL, F4_OPER, F2_VALISS, F2_VALINSS, F2_VALIRRF, F2_VALPIS, F2_VALCOFI, F2_VALCSLL, A1_CGC, A2_CGC "
	cQry += "order by D2_EMISSAO, D2_DOC, D2_SERIE"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	cCbcRef := "Periodo: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	N.F.     | EMISSAO  | NATUREZA | CLIENTE | PROJETO                          | PR.ENTRG |         PESO |          VALOR |   DD | NEG
//	999999-9   99/99/99   AAAAAAAA   AAAAAAA   999999 AAAAAAAAAAAAAAAAAAAAAAAAA   99/99/99   999999999.99   99999999999.99   9999   AAA
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		@nLin,000 psay Right(TEMP->D2_DOC,6)+"-"+Left(TEMP->D2_SERIE,1)
		@nLin,011 psay U_ConvData(TEMP->D2_EMISSAO,"yy")
		@nLin,022 psay Left(TEMP->F4_TEXTO,8)
		@nLin,033 psay Left(TEMP->NREDUZ,7)
		@nLin,043 psay Left(TEMP->C6_CLVL,6)
		@nLin,050 psay IIf(CTH->(DbSeek(xFilial("CTH")+TEMP->C6_CLVL,.F.)),Left(AllTrim(CTH->CTH_DESC01),25)," ")
		@nLin,078 psay U_ConvData(TEMP->CTH_DTENTR,"yy")
//		@nLin,089 psay Transf(If(TEMP->CTH_TPPRJ $ _TPPROJ,0,TEMP->PESOL),"@E 999999999.99")
		
		if TEMP->CTH_TPPRJ $ _TPPROJ
			nPesol := 0
		else
			if cCompara == TEMP->D2_DOC+TEMP->D2_SERIE+TEMP->D2_CF+TEMP->D2_EMISSAO+TEMP->D2_CLIENTE+TEMP->D2_LOJA+Str(TEMP->PESOL)
				nPesol := 0
			else
				cCompara := TEMP->D2_DOC+TEMP->D2_SERIE+TEMP->D2_CF+TEMP->D2_EMISSAO+TEMP->D2_CLIENTE+TEMP->D2_LOJA+Str(TEMP->PESOL)
				nPesol := TEMP->PESOL
			endif
		endif
		
		@nLin,089 psay Transf(nPesol,"@E 999999999.99")
		
		nValTot := TEMP->D2_TOTAL
		
//		DbSelectArea("SD1")
//		SD1->(DbOrderNickname("NFORI"))
//		SD1->(DbSetOrder(16))
//		SD1->(DbGoTop())
		
//		if SD1->(DbSeek(xFilial("SD1")+TEMP->(D2_DOC+D2_SERIE),.F.))
//			nValTot := TEMP->D2_TOTAL
			
/*			while !SD1->(Eof()) .and. SD1->D1_NFORI >= TEMP->D2_DOC .and. SD1->D1_NFORI <= TEMP->D2_DOC .and. SD1->D1_SERIORI >= TEMP->D2_SERIE .and. SD1->D1_SERIORI <= TEMP->D2_SERIE .and. SD1->D1_TIPO <> "C"
				nValTot -= SD1->D1_TOTAL
				
				SD1->(DbSkip())
			enddo*/
			
			cAliasTMP := GetArea()
			cQry := "select * "
			cQry += "from "+RetSqlName("SD1")+" "
			cQry += "where D1_NFORI = '"+TEMP->D2_DOC+"' and D1_SERIORI = '"+TEMP->D2_SERIE+"' and D1_TIPO <> 'C' and D_E_L_E_T_ <> '*'"
			
			tcquery cQry new alias "CON"
			DbSelectArea("CON")
			
			while !CON->(Eof())
				if CON->D1_TOTAL == TEMP->D2_TOTAL
					nValTot := IIf(Empty(CON->D1_VALDEV),CON->D1_VALDEV,CON->D1_TOTAL - CON->D1_VALDEV)
				endif
				
				CON->(DbSkip())
			enddo
			
			CON->(DbCloseArea())
			RestArea(cAliasTMP)
//		endif
			@nLin,104 psay Transf(nValTot,"@E 99999999999.99")
//		else
//			@nLin,104 psay Transf(TEMP->D2_TOTAL,"@E 99999999999.99")
//		endif
		
//		@nLin,121 psay IIf(!Empty(TEMP->CTH_DTENTR),Transf(SToD(TEMP->D2_EMISSAO) - SToD(TEMP->CTH_DTENTR),"@E 9999"),"   -")
		@nLin,121 psay IIf(!Empty(TEMP->CTH_DTENTR),Transf(SToD(TEMP->D2_EMISSAO) - SToD(TEMP->CTH_DTENTR),"@E 9999"),"    ")
		@nLin,128 psay IIf(SX5->(DbSeek(xFilial("SX5")+"Z1"+TEMP->CTH_TPPRJ,.F.)),AllTrim(SX5->X5_DESCSPA),"-")
		
		IncProc()
		
		if Left(TEMP->F4_OPER,1) == "6" .or. Left(TEMP->F4_OPER,1) == "8"		//Remessa e Retorno
			cTpProje := "9999"
			cDescProje := "SIMPLES REMESSA"
		elseif Left(TEMP->F4_OPER,1) == "7"										//Devolucao
			cTpProje := "9998"
			cDescProje := "DEVOLUCAO"
		elseif Left(TEMP->F4_OPER,1) == "9"										//ICMS
			cTpProje := "9997"
			cDescProje := "COMPLEM. ICMS"
		elseif TEMP->F4_OPER == "55" .or. "SUCATA" $ TEMP->F4_TEXTO				//Sucata
			cTpProje := "0009"
			cDescProje := If(SX5->(DbSeek(xFilial("SX5")+"Z1"+cTpProje,.F.)),Left(SX5->X5_DESCRI,30),"")
		else																	//Normal
			cTpProje := TEMP->CTH_TPPRJ
			cDescProje := If(SX5->(DbSeek(xFilial("SX5")+"Z1"+cTpProje,.F.)),Left(SX5->X5_DESCRI,30),"")
		endif
		
/*		if cTpProje == "9998"
			cDescProje := "DEVOLUCAO"
		elseif cTpProje == "9999"
			cDescProje := "SIMPLES REMESSA"
		else
			cDescProje := If(SX5->(DbSeek(xFilial("SX5")+"Z1"+cTpProje,.F.)),Left(SX5->X5_DESCRI,30),"")
		endif*/
		
		if !(cTpProje $ "0009/9997/9998/9999")
			if (nInd := AScan(aNegocios,{|x| x[1] = cTpProje})) == 0
//				AAdd(aNegocios,{cTpProje,TEMP->PESOL,nValTot,1,cDescProje})
				AAdd(aNegocios,{cTpProje,nPesol,nValTot,1,cDescProje})
			else
//				aNegocios[nInd][2] += TEMP->PESOL
				aNegocios[nInd][2] += nPesol
				aNegocios[nInd][3] += nValTot
				aNegocios[nInd][4] += 1
			endif
		else
			if (nInd := AScan(aContas,{|x| x[1] = cTpProje})) == 0
//				AAdd(aContas,{cTpProje,TEMP->PESOL,nValTot,1,cDescProje})
				AAdd(aContas,{cTpProje,nPesol,nValTot,1,cDescProje})
			else
//				aContas[nInd][2] += TEMP->PESOL
				aContas[nInd][2] += nPesol
				aContas[nInd][3] += nValTot
				aContas[nInd][4] += 1
			endif
		endif
		
		if (nInd := AScan(aClientes,{|x| x[1] = TEMP->(D2_CLIENTE+D2_LOJA)})) == 0
			AAdd(aClientes,{TEMP->(D2_CLIENTE+D2_LOJA),TEMP->PESOL,nValTot,1,TEMP->NREDUZ})
		else
//			aClientes[nInd][2] += TEMP->PESOL
			aClientes[nInd][2] += nPesol
			aClientes[nInd][3] += nValTot
			aClientes[nInd][4] += 1
		endif
		
		if !Empty(TEMP->D2_VALICM)
			aImpostos[1][2] += TEMP->D2_VALICM
			aImpostos[1][3] += 1
		endif
		
		if !Empty(TEMP->D2_VALIPI)
			aImpostos[2][2] += TEMP->D2_VALIPI
			aImpostos[2][3] += 1
		endif
		
		if !Empty(TEMP->F2_VALISS)
			aImpostos[3][2] += TEMP->F2_VALISS
			aImpostos[3][3] += 1
		endif
		
		if !Empty(TEMP->F2_VALINSS)
			aImpostos[4][2] += TEMP->F2_VALINSS
			aImpostos[4][3] += 1
		endif
		
		if !Empty(TEMP->F2_VALIRRF)
			aImpostos[5][2] += TEMP->F2_VALIRRF
			aImpostos[5][3] += 1
		endif
		
		if !Empty(TEMP->F2_VALCSLL)
			aImpostos[6][2] += TEMP->F2_VALCSLL
			aImpostos[6][3] += 1
		endif
		
		if !Empty(TEMP->F2_VALPIS + TEMP->D2_VALIMP6)
			aImpostos[7][2] += TEMP->F2_VALPIS + TEMP->D2_VALIMP6
			aImpostos[7][3] += 1
		endif
		
		if !Empty(TEMP->F2_VALCOFIS + TEMP->D2_VALIMP5)
			aImpostos[8][2] += TEMP->F2_VALCOFIS + TEMP->D2_VALIMP5
			aImpostos[8][3] += 1
		endif
		
		nTotItem++
		nLin++
//		nTotPeso += TEMP->PESOL
		nTotPeso += nPesol
//		nTotValor += TEMP->D2_TOTAL
		nTotValor += nValTot
		
		U_SaltaFolha()
		
		TEMP->(DbSkip())
	enddo
		
	nLin++
	
	U_SaltaFolha()
	
	@nLin  ,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	@++nLin,000 psay StrZero(nTotItem,4)
	@nLin  ,005 psay "REGISTROS"
	@nLin  ,070 psay "TOTAL GERAL"
	@nLin  ,089 psay Transf(nTotPeso,"@E 999999999.99")
	@nLin  ,104 psay Transf(nTotValor,"@E 99999999999.99")
	
	aSortNegocios := ASort(aNegocios,,,{|x,y| x[5] < y[5]})
	aSortContas := ASort(aContas,,,{|x,y| x[5] < y[5]})
	aSortClientes := ASort(aClientes,,,{|x,y| x[5] < y[5]})
	nTotalP := 0 ; nTotalV := 0 ; nTotItem := 0
	
	nLin += 2
	
	U_SaltaFolha()
	
//	NEGOCIOS                                      QUANT      (%)                PESO      (%)                  VALOR      (%)
//	9999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA           99999   999.99      999,999,999.99   999.99      99,999,999,999.99   999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin  ,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	@++nLin,000 psay "NEGOCIOS                                      QUANT      (%)                PESO      (%)                  VALOR      (%)"
	@++nLin,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	
	for i := 1 to Len(aSortNegocios)
		nTotItem += aSortNegocios[i][4]
	next
	
	for i := 1 to Len(aSortNegocios)
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay aSortNegocios[i][1]+" "+aSortNegocios[i][5]
		@nLin,046 psay Transf(aSortNegocios[i][4],"@E 99999")
		@nLin,054 psay Transf((aSortNegocios[i][4] / nTotItem) * 100,"@E 999.99")
		@nLin,066 psay Transf(aSortNegocios[i][2],"@E 999,999,999.99")
		@nLin,083 psay Transf((aSortNegocios[i][2] / nTotPeso) * 100,"@E 999.99")
		@nLin,095 psay Transf(aSortNegocios[i][3],"@E 99,999,999,999.99")
		@nLin,115 psay Transf((aSortNegocios[i][3] / nTotValor) * 100,"@E 999.99")
		
		nTotalP += aSortNegocios[i][2]
		nTotalV += aSortNegocios[i][3]
	next
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin  ,000 psay "TOTAL"
	@nLin  ,046 psay Transf(nTotItem,"@E 99999")
	@nLin  ,066 psay Transf(nTotalP,"@E 999,999,999.99")
	@nLin  ,095 psay Transf(nTotalV,"@E 99,999,999,999.99")
	@++nLin,000 psay "MEDIA"
	@nLin  ,066 psay Transf((nTotalP / nTotItem),"@E 999,999,999.99")
	@nLin  ,095 psay Transf((nTotalV / nTotItem),"@E 99,999,999,999.99")
	
	nLin += 2
	nTotalP := 0 ; nTotalV := 0 ; nTotItem := 0
	
	U_SaltaFolha()
	
//	CONTAS                                        QUANT      (%)                PESO      (%)                  VALOR      (%)
//	9999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA           99999   999.99      999,999,999.99   999.99      99,999,999,999.99   999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin  ,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	@++nLin,000 psay "CONTAS                                        QUANT      (%)                PESO      (%)                  VALOR      (%)"
	@++nLin,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	
	for i := 1 to Len(aSortContas)
		nTotItem += aSortContas[i][4]
	next
	
	for i := 1 to Len(aSortContas)
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay aSortContas[i][1]+" "+aSortContas[i][5]
		@nLin,046 psay Transf(aSortContas[i][4],"@E 99999")
		@nLin,054 psay Transf((aSortContas[i][4] / nTotItem) * 100,"@E 999.99")
		@nLin,066 psay Transf(aSortContas[i][2],"@E 999,999,999.99")
		@nLin,083 psay Transf((aSortContas[i][2] / nTotPeso) * 100,"@E 999.99")
		@nLin,095 psay Transf(aSortContas[i][3],"@E 99,999,999,999.99")
		@nLin,115 psay Transf((aSortContas[i][3] / nTotValor) * 100,"@E 999.99")
		
		nTotalP += aSortContas[i][2]
		nTotalV += aSortContas[i][3]
	next
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin  ,000 psay "TOTAL"
	@nLin  ,046 psay Transf(nTotItem,"@E 99999")
	@nLin  ,066 psay Transf(nTotalP,"@E 999,999,999.99")
	@nLin  ,095 psay Transf(nTotalV,"@E 99,999,999,999.99")
	@++nLin,000 psay "MEDIA"
	@nLin  ,066 psay Transf((nTotalP / nTotItem),"@E 999,999,999.99")
	@nLin  ,095 psay Transf((nTotalV / nTotItem),"@E 99,999,999,999.99")
	
	nLin += 2
	nTotalP := 0 ; nTotalV := 0 ; nTotItem := 0
	
	U_SaltaFolha()
	
//	CLIENTES                                      QUANT      (%)                PESO      (%)                  VALOR      (%)
//	99999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA       99999   999.99      999,999,999.99   999.99      99,999,999,999.99   999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin  ,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	@++nLin,000 psay "CLIENTES                                      QUANT      (%)                PESO      (%)                  VALOR      (%)"
	@++nLin,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	
	for i := 1 to Len(aSortClientes)
		nTotItem += aSortClientes[i][4]
	next
	
	for i := 1 to Len(aSortClientes)
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay aSortClientes[i][1]+" "+aSortClientes[i][5]
		@nLin,046 psay Transf(aSortClientes[i][4],"@E 99999")
		@nLin,054 psay Transf((aSortClientes[i][4] / nTotItem) * 100,"@E 99.99")
		@nLin,066 psay Transf(aSortClientes[i][2],"@E 999,999,999.99")
		@nLin,083 psay Transf((aSortClientes[i][2] / nTotPeso) * 100,"@E 99.99")
		@nLin,095 psay Transf(aSortClientes[i][3],"@E 99,999,999,999.99")
		@nLin,115 psay Transf((aSortClientes[i][3] / nTotValor) * 100,"@E 99.99")
		
		nTotalP += aSortClientes[i][2]
		nTotalV += aSortClientes[i][3]
	next
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin  ,000 psay "TOTAL"
	@nLin  ,046 psay Transf(nTotItem,"@E 99999")
	@nLin  ,066 psay Transf(nTotalP,"@E 999,999,999.99")
	@nLin  ,095 psay Transf(nTotalV,"@E 99,999,999,999.99")
	@++nLin,000 psay "MEDIA"
	@nLin  ,066 psay Transf((nTotalP / nTotItem),"@E 999,999,999.99")
	@nLin  ,095 psay Transf((nTotalV / nTotItem),"@E 99,999,999,999.99")
	
	nLin += 2
	nTotalP := 0 ; nTotalV := 0 ; nTotItem := 0
	
	U_SaltaFolha()
	
//	IMPOSTOS                   QUANT      (%)                  VALOR      (%)
//	AAAAAAAAAAAAAAAAAAAA       99999   999.99      99,999,999,999.99   999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin  ,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	@++nLin,000 psay "IMPOSTOS                   QUANT      (%)                  VALOR      (%)"
	@++nLin,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
	
	for i := 1 to Len(aImpostos)
		nTotItem += aImpostos[i][3]
	next
	
	U_SaltaFolha()
		
	for i := 1 to Len(aImpostos)
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay aImpostos[i][1]
		@nLin,027 psay Transf(aImpostos[i][3],"@E 99999")
		@nLin,035 psay Transf((aImpostos[i][3] / nTotItem) * 100,"@E 999.99")
		@nLin,047 psay Transf(aImpostos[i][2],"@E 99,999,999,999.99")
		@nLin,067 psay Transf((aImpostos[i][2] / nTotValor) * 100,"@E 999.99")
		
		nTotalV += aImpostos[i][2]
	next
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin  ,000 psay "TOTAL"
	@nLin  ,027 psay Transf(nTotItem,"@E 99999")
	@nLin  ,047 psay Transf(nTotalV,"@E 99,999,999,999.99")
	@++nLin,000 psay "MEDIA"
	@nLin  ,047 psay Transf((nTotalV / nTotItem),"@E 99,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return