/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 21/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Selecionar itens a serem entregues p/ autorizar       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function SELITM(cAlias,cTitulo,aCamposBrw,aCamposTbl,aRelatorio,aOrdemRel)
	local cPerg := "SELITM"
	
	private cMarca := GetMark()
	private nTotal := 0
	private nTotGeral := 0
	private cAutoIncremento := ""
	private cCadastro := ""
	private aRotina := {}
	private aCampos := {}
	private cPedCompra := "''"
	private cDtIni := ""
	private cDtFin := ""
	private lSair := .F.
	private aCamTbl := aCamposTbl
	private aCfgRel := aRelatorio
	private aOrdRel := aOrdemRel
	
	Pergunte("SITM",.T.)
	
	aRotina := {{"Pesquisar","AxPesqui",0,1},;
				{"Gerar Doc.","U_SELITMGravaSZ2('"+cAlias+"')",0,2},;
				{"Re-Imprimir","U_SELITMGerarDoc('SELITM','"+cAlias+"')",0,3},;
				{"Exclui Doc","U_SELITMExcluirDoc('"+cAlias+"')",0,4}}
	aCampos := aCamposBrw
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cCadastro := cTitulo
	
	if cAlias == "SEF"
		cFiltro := "(Empty(EF_TIPO) .or. EF_TIPO = 'PA') .and. (Empty(EF_OK1) .or. EF_OK1 == '"+cMarca+"') .and. EF_IMPRESS <> 'C' .and. EF_IMPRESS <> 'A' .and. DToS(EF_DATA) >= '"+cDtIni+"' .and. DToS(EF_DATA) <= '"+cDtFin+"'"
	elseif cAlias == "SC7"
		cFiltro := "DToS(C7_EMISSAO) >= '"+cDtIni+"' .and. DToS(C7_EMISSAO) <= '"+cDtFin+"' .and. C7_CONAPRO == 'B' .and. "+;
					"(Empty(C7_OK1) .or. C7_OK1 == '"+cMarca+"' .and. DToS(C7_EMISSAO) >= '"+cDtIni+"' .and. DToS(C7_EMISSAO) <= '"+cDtFin+"')"
	elseif cAlias == "SF1"
		cFiltro := "(Empty(F1_OK1) .or. F1_OK1 == '"+cMarca+"') .and. DToS(F1_EMISSAO) >= '"+cDtIni+"' .and. DToS(F1_EMISSAO) <= '"+cDtFin+"'"
	endif
	
	MsFilter(cFiltro)
	MarkBrow(cAlias,aCamTbl[1],,aCampos,,cMarca,"U_SELITMMarcaBox(1,'"+cAlias+"')",,,,"U_SELITMMarcaBox(2,'"+cAlias+"')")
	
	if !(lSair)
		cAtu := "update "+RetSqlName(cAlias)+" "
		cAtu += "set "+aCamTbl[1]+" = '' "
		cAtu += "where "+aCamTbl[1]+" = '"+cMarca+"' and "+aCamTbl[2]+" = '' and D_E_L_E_T_ <> '*'"
		
		nRet := TCSqlExec(cAtu)
		
		if nRet > 0
			MsgBox("Não foi possível limpar os registros selecionados!","Alerta","ALERT")
		endif
	endif
return

user function SELITMMarcaBox(nOpc,cAlias)
	if nOpc == 1
		DbGoTop()
		
		while !Eof()
			RecLock(cAlias,.F.)
				(cAlias)->&(aCamTbl[1]) := If((cAlias)->&(aCamTbl[1]) == cMarca,Space(2),cMarca)
			MsUnLock()
			
			DbSkip()
		enddo
		
		DbGoTop()
	elseif nOpc == 2
		RecLock(cAlias,.F.)
			(cAlias)->&(aCamTbl[1]) := If((cAlias)->&(aCamTbl[1]) == cMarca,Space(2),cMarca)
		MsUnLock()
	endif
return

user function SELITMGravaSZ2(cAlias)
	local cSelect := ""
	
	for i := 3 to Len(aCamTbl)
		if !Empty(aCamTbl[i])
			cSelect += aCamTbl[i]+", "
		endif
	next
	
	cQry := "select distinct "+SubStr(cSelect,1,Len(cSelect) - 2)+" "
	cQry += "from "+RetSqlName(cAlias)+" "
	cQry += "where "+aCamTbl[1]+" = '"+cMarca+"' and "+aCamTbl[2]+" = '' and D_E_L_E_T_ <> '*' "
	cQry += "order by "+aCamTbl[3]
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("SZ2")
	DbSelectArea("TEMP")
	DbGoTop()
	
	cAutoIncremento := AutoIncremento(cAlias)
	
	while !TEMP->(Eof())
		SZ2->(DbAppend())
		
		replace SZ2->Z2_FILIAL with xFilial("SZ2"),;
				SZ2->Z2_TABELA with cAlias,;
				SZ2->Z2_SEQUENC with cAutoIncremento,;
				SZ2->Z2_ITEM with If(cAlias <> "SF1",TEMP->&(aCamTbl[3]),TEMP->&(aCamTbl[3])+TEMP->&(aCamTbl[9])),;
				SZ2->Z2_BANCO with TEMP->&(aCamTbl[4]),;
				SZ2->Z2_AGENCIA with TEMP->&(aCamTbl[5]),;
				SZ2->Z2_CONTA with TEMP->&(aCamTbl[6]),;
				SZ2->Z2_FORCLI with TEMP->&(aCamTbl[7]),;
				SZ2->Z2_LOJA with TEMP->&(aCamTbl[8]),;
				SZ2->Z2_OK with cMarca
		
		SZ2->(DbCommit())
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cUpd := "update "+RetSqlName(cAlias)+" set "+aCamTbl[2]+" = '"+cAutoIncremento+"' where "+aCamTbl[3]+" = '"+TEMP->&(aCamTbl[3])+"' and "+aCamTbl[1]+" = '"+cMarca+"' and D_E_L_E_T_ <> '*'"
		nRet := TCSqlExec(cUpd)
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	
	lSair := .T.
	
	CloseBrowse()
	U_SELITMGerarDoc("",cAlias)
return

user function SELITMGerarDoc(cPergun,cAlias)
	local aPedido := {}
	local aProjeto := {}
	
	private aOrd    := aOrdRel
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := cPergun
	private Cabec1  := aCfgRel[1]
	private Cabec2  := ""
	private cDesc1  := aCfgRel[2]
	private cString := cAlias
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
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27
		lSair := .F.
		
		return
	endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	if cAlias == "SEF"
		if Empty(cPerg)
			cQry := "select SEF.EF_NUM, SZ2.Z2_SEQUENC, SZ2.Z2_BANCO, SZ2.Z2_AGENCIA, SZ2.Z2_CONTA, SEF.EF_DATA, sum(SEF.EF_VALOR) as EF_VALOR "
			cQry += "from "+RetSqlName("SZ2")+" SZ2 inner join "+RetSqlName("SEF")+" SEF on (rtrim(SZ2.Z2_ITEM) = SEF.EF_NUM) "
			cQry += "where SZ2.Z2_TABELA = '"+cAlias+"' and SZ2.Z2_SEQUENC = '"+cAutoIncremento+"' and SEF.EF_OK1 = '"+cMarca+"' and SZ2.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' and SEF.EF_IMPRESS not in ('C','A') and (SEF.EF_TIPO = '' or SEF.EF_TIPO = 'PA') "
			cQry += "group by SEF.EF_NUM, SZ2.Z2_SEQUENC, SZ2.Z2_BANCO, SZ2.Z2_AGENCIA, SZ2.Z2_CONTA, SEF.EF_DATA "
		else
			cAutoIncremento := mv_par01
			
			cQry := "select SEF.EF_NUM, SZ2.Z2_SEQUENC, SZ2.Z2_BANCO, SZ2.Z2_AGENCIA, SZ2.Z2_CONTA, SEF.EF_DATA, sum(SEF.EF_VALOR) as EF_VALOR "
			cQry += "from "+RetSqlName("SZ2")+" SZ2 inner join "+RetSqlName("SEF")+" SEF on (rtrim(SZ2.Z2_ITEM) = SEF.EF_NUM) "
			cQry += "where SZ2.Z2_TABELA = '"+cAlias+"' and SZ2.Z2_SEQUENC = '"+cAutoIncremento+"' and SZ2.Z2_OK = SEF.EF_OK1 and SZ2.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' and SEF.EF_IMPRESS not in ('C','A') and (SEF.EF_TIPO = '' or SEF.EF_TIPO = 'PA') "
			cQry += "group by SEF.EF_NUM, SZ2.Z2_SEQUENC, SZ2.Z2_BANCO, SZ2.Z2_AGENCIA, SZ2.Z2_CONTA, SEF.EF_DATA "
		endif
		
		if nOrdem == 1
			cQry += "order by SEF.EF_NUM"
		endif
		
		tcquery cQry new alias "TEMP"
		DbSelectArea("TEMP")
		
		cCbcRef := "Liberacao: "+cAutoIncremento
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		if TEMP->(Eof())
			MsgBox("Esse numero de liberacao nao existe!","Alerta","ALERT")
			
			TEMP->(DbCloseArea())
			Ms_Flush()
			Return(.F.)
		endif
		
		while !Eof()
			@nLin,000 psay "[    ]"
			@nLin,010 psay TEMP->EF_NUM
			@nLin,028 psay U_ConvData(TEMP->EF_DATA)
			@nLin,041 psay TEMP->Z2_BANCO+" - "+AllTrim(TEMP->Z2_AGENCIA)+"/"+TEMP->Z2_CONTA
			@nLin,070 psay Transf(TEMP->EF_VALOR,"@E 999,999,999.99")
			
			nTotal += TEMP->EF_VALOR
			nTotGeral += TEMP->EF_VALOR
			nLin++
			
			if nLin >= 55
				nRdpPag++
				
				Assinatura(nTotal,0,0,0,0,0,cAlias)
				U_Rdp(nRdpPag,cRdpLeg,Tamanho)
				U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
				
				nTotal := 0
			endif
			
			DbSkip()
		enddo
		
		Assinatura(nTotal,0,0,nTotGeral,0,0,cAlias)
	elseif cAlias == "SC7"
		nT := 0 ; nTIcm := 0 ; nTIpi := 0
		nTotal := 0 ; nTotIcm := 0 ; nTotIpi := 0
		nTotGeral := 0 ; nTotGerIcm := 0 ; nTotGerIpi := 0
		
		if Empty(cPerg)
//			cQry := "select SZ2.Z2_SEQUENC, SC7.C7_NUM, SC7.C7_CLVL, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, sum(SC7.C7_TOTAL) as C7_TOTAL, sum(SC7.C7_VALIPI) as C7_VALIPI, sum(SC7.C7_VALICM) as C7_VALICM "
//			cQry += "from "+RetSqlName("SZ2")+" SZ2 inner join "+RetSqlName("SC7")+" SC7 on (rtrim(SZ2.Z2_ITEM) = SC7.C7_NUM) inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) "
			cQry := "select SZ2.Z2_SEQUENC, SC7.C7_NUM, SC7.C7_CLVL, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, SC7.C7_PRODUTO, SB1.B1_ICMPC, SC7.C7_TOTAL, SC7.C7_VALIPI, SC7.C7_VALICM "
			cQry += "from "+RetSqlName("SZ2")+" SZ2 inner join "+RetSqlName("SC7")+" SC7 on (rtrim(SZ2.Z2_ITEM) = SC7.C7_NUM) inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) inner join "+RetSqlName("SB1")+" SB1 on (SC7.C7_PRODUTO = SB1.B1_COD) "
			cQry += "where SZ2.Z2_TABELA = '"+cAlias+"' and SZ2.Z2_SEQUENC = '"+cAutoIncremento+"' and SC7.C7_OK1 = '"+cMarca+"' and SZ2.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*' "
//			cQry += "group by SZ2.Z2_SEQUENC, SC7.C7_NUM, SC7.C7_CLVL, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ "
		else
			cAutoIncremento := mv_par01
			
			cQry := "select SZ2.Z2_SEQUENC, SC7.C7_NUM, SC7.C7_CLVL, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, SC7.C7_PRODUTO, SB1.B1_ICMPC, SC7.C7_TOTAL, SC7.C7_VALIPI, SC7.C7_VALICM "
			cQry += "from "+RetSqlName("SZ2")+" SZ2 inner join "+RetSqlName("SC7")+" SC7 on (rtrim(SZ2.Z2_ITEM) = SC7.C7_NUM) inner join "+RetSqlName("SA2")+" SA2 on (SC7.C7_FORNECE = SA2.A2_COD and SC7.C7_LOJA = SA2.A2_LOJA) inner join "+RetSqlName("SB1")+" SB1 on (SC7.C7_PRODUTO = SB1.B1_COD) "
			cQry += "where SZ2.Z2_TABELA = '"+cAlias+"' and SZ2.Z2_SEQUENC = '"+cAutoIncremento+"' and SZ2.Z2_OK = SC7.C7_OK1 and SZ2.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*'"
		endif
		
		if nOrdem == 1
			cQry += "order by SC7.C7_NUM"
		elseif nOrdem == 2
			cQry += "order by SC7.C7_FORNECE"
		elseif nOrdem == 3
			cQry += "order by SA2.A2_NREDUZ"
		elseif nOrdem == 4
			cQry += "order by SC7.C7_CLVL"
		endif
		
		tcquery cQry new alias "TEMP"
		DbSelectArea("TEMP")
		DbGoTop()
		
		cCbcRef := "Liberacao: "+cAutoIncremento
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		if TEMP->(Eof())
			MsgBox("Esse numero de liberacao nao existe!","Alerta","ALERT")
			
			TEMP->(DbCloseArea())
			Ms_Flush()
			Return(.F.)
		endif
		
		while !Eof()
			cNumero := TEMP->C7_NUM
			cProjeto := TEMP->C7_CLVL
			
			@nLin,000 psay "[    ]"
			@nLin,010 psay TEMP->C7_NUM
			@nLin,019 psay TEMP->C7_CLVL
			@nLin,031 psay U_ConvData(TEMP->C7_EMISSAO)
			@nLin,044 psay TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ
			
			cPedCompra += ",'"+AllTrim(TEMP->C7_NUM)+"'"
			
			while TEMP->C7_NUM == cNumero .and. TEMP->C7_CLVL == cProjeto
				nT += TEMP->C7_TOTAL
				nTotal += TEMP->C7_TOTAL
				nTotGeral += TEMP->C7_TOTAL
				nTIpi += TEMP->C7_VALIPI
				nTotIpi += TEMP->C7_VALIPI
				nTotGerIpi += TEMP->C7_VALIPI
				
				if TEMP->B1_ICMPC == "1"
					nTIcm += TEMP->C7_VALICM
					nTotIcm += TEMP->C7_VALICM
					nTotGerIcm += TEMP->C7_VALICM
				endif
				
				TEMP->(DbSkip())
			enddo
			
			@nLin,081 psay Transf(nT,"@E 999,999.99")
			@nLin,092 psay Transf(nTIcm,"@E 999,999.99")
			@nLin,104 psay Transf(nTIpi,"@E 999,999.99")
			
			nT := 0 ; nTIcm := 0 ; nTIpi := 0
			nLin++
			
			if nLin >= 55
				nRdpPag++
				
				Assinatura(nTotal,nTotIcm,nTotIpi,0,0,0,cAlias)
				U_Rdp(nRdpPag,cRdpLeg,Tamanho)
				U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
				
				nTotal := 0 ; nTotIcm := 0 ; nTotIpi := 0
			endif
		enddo
		
		Assinatura(nTotal,nTotIcm,nTotIpi,nTotGeral,nTotGerIcm,nTotGerIpi,cAlias)
	elseif cAlias == "SF1"
		nTotal := 0
		
		if Empty(cPerg)
			cQry := "select SZ2.Z2_SEQUENC, SF1.F1_CR, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_VALBRUT, NREDUZ = case when SF1.F1_TIPO in ('B','D') then SA1.A1_NREDUZ else SA2.A2_NREDUZ end "
			cQry += "from "+RetSqlName("SZ2")+" SZ2 inner join "+RetSqlName("SF1")+" SF1 on (rtrim(SZ2.Z2_ITEM) = SF1.F1_DOC+rtrim(SF1.F1_SERIE) and SF1.F1_FORNECE = SZ2.Z2_FORCLI and SF1.F1_LOJA = SZ2.Z2_LOJA) left join "+RetSqlName("SA2")+" SA2 on (SF1.F1_FORNECE = SA2.A2_COD and SF1.F1_LOJA = SA2.A2_LOJA and SF1.F1_TIPO not in ('B','D')) left join "+RetSqlName("SA1")+" SA1 on (SF1.F1_FORNECE = SA1.A1_COD and SF1.F1_LOJA = SA1.A1_LOJA and SF1.F1_TIPO in ('B','D')) "
			cQry += "where SZ2.Z2_TABELA = '"+cAlias+"' and SZ2.Z2_SEQUENC = '"+cAutoIncremento+"' and SF1.F1_OK1 = '"+cMarca+"' and SZ2.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' "
		else
			cAutoIncremento := mv_par01
			
			cQry := "select SZ2.Z2_SEQUENC, SF1.F1_CR, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_VALBRUT, NREDUZ = case when SF1.F1_TIPO in ('B','D') then SA1.A1_NREDUZ else SA2.A2_NREDUZ end "
			cQry += "from "+RetSqlName("SZ2")+" SZ2 inner join "+RetSqlName("SF1")+" SF1 on (rtrim(SZ2.Z2_ITEM) = SF1.F1_DOC+rtrim(SF1.F1_SERIE) and SF1.F1_FORNECE = SZ2.Z2_FORCLI and SF1.F1_LOJA = SZ2.Z2_LOJA) left join "+RetSqlName("SA2")+" SA2 on (SF1.F1_FORNECE = SA2.A2_COD and SF1.F1_LOJA = SA2.A2_LOJA and SF1.F1_TIPO not in ('B','D')) left join "+RetSqlName("SA1")+" SA1 on (SF1.F1_FORNECE = SA1.A1_COD and SF1.F1_LOJA = SA1.A1_LOJA and SF1.F1_TIPO in ('B','D')) "
			cQry += "where SZ2.Z2_TABELA = '"+cAlias+"' and SZ2.Z2_SEQUENC = '"+cAutoIncremento+"' and SZ2.Z2_OK = SF1.F1_OK1 and SZ2.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' "
		endif
		
		if nOrdem == 1
			cQry += "order by SF1.F1_CR, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA"
		elseif nOrdem == 2
			cQry += "order by SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA"
		endif
		
		tcquery cQry new alias "TEMP"
		DbSelectArea("TEMP")
		TEMP->(DbGoTop())
		
		cCbcRef := "Liberacao: "+cAutoIncremento
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		if TEMP->(Eof())
			MsgBox("Esse numero de liberacao nao existe!","Alerta","ALERT")
			
			TEMP->(DbCloseArea())
			Ms_Flush()
			Return(.F.)
		endif
		
		while !TEMP->(Eof())
			//15
			@nLin,015 psay TEMP->F1_CR
			@nLin,025 psay TEMP->F1_FORNECE+"/"+TEMP->F1_LOJA+" "+TEMP->NREDUZ
			@nLin,068 psay TEMP->F1_DOC+"-"+TEMP->F1_SERIE
			@nLin,084 psay U_ConvData(TEMP->F1_EMISSAO)
			@nLin,097 psay Transf(TEMP->F1_VALBRUT,"@E 999,999,999.99")
	 		
			aProjeto := PedidoCompra("D1_CLVL",TEMP->F1_DOC,TEMP->F1_SERIE,TEMP->F1_FORNECE,TEMP->F1_LOJA)
			aPedido := PedidoCompra("D1_PEDIDO",TEMP->F1_DOC,TEMP->F1_SERIE,TEMP->F1_FORNECE,TEMP->F1_LOJA)
			nMaior := If(Len(aProjeto) > Len(aPedido),Len(aProjeto),Len(aPedido))
			
			for i := 1 to nMaior
				@nLin,114 psay If(i <= Len(aPedido),aPedido[i],"      ")
				@nLin,123 psay If(i <= Len(aProjeto),aProjeto[i],"")
				
				nLin++
			next
			
			nTotal += TEMP->F1_VALBRUT
			nTotGeral += TEMP->F1_VALBRUT
			aProjeto := {}
			aPedido := {}
			
			if nLin >= 55
				nRdpPag++
				
				Assinatura(nTotal,0,0,0,0,0,cAlias)
				U_Rdp(nRdpPag,cRdpLeg,Tamanho)
				U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
				
				nTotal := 0
			endif
			
			TEMP->(DbSkip())
		enddo
		
		Assinatura(nTotal,0,0,nTotGeral,0,0,cAlias)
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	
	if Empty(cPerg)
		cUPD := "update "+RetSqlName("SX5")+" set X5_DESCRI = '"+cAutoIncremento+"', X5_DESCSPA = '"+cAutoIncremento+"', X5_DESCENG = '"+cAutoIncremento+"' "
		cUPD += "where X5_TABELA = 'IT' and X5_CHAVE = '"+cAlias+"' and D_E_L_E_T_ <> '*'"
		
		nRet := TCSqlExec(cUPD)
	endif
	
	DbSelectArea("TEMP")
	
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
	CloseBrowse()
return

static function AutoIncremento(cTabela)
	local cNum := 0
	local cCon := ""
	
	cCon := "select X5_DESCRI "
	cCon += "from "+RetSqlName("SX5")+" "
	cCon += "where X5_FILIAL = '"+xFilial("SX5")+"' and X5_TABELA = 'IT' and X5_CHAVE = '"+cTabela+"'"
	
	tcquery cCon new alias "CON"
	DbSelectArea("CON")
	
	cNum := StrZero(Val(CON->X5_DESCRI) + 1,6)
	
	CON->(DbCloseArea())
return (cNum)

static function Assinatura(nT,nTIc,nTIp,nTG,nTGIc,nTGIp,cAlias)
	nLin++
	
	if cAlias = "SEF"
		@nLin,041 psay "TOTAL "
		@nLin,070 psay Transf(nT,"@E 999,999,999.99")
	elseif cAlias = "SC7"
		@nLin,044 psay "T O T A L "
		@nLin,077 psay Transf(nT,"@E 999,999,999.99")
		@nLin,092 psay Transf(nTIc,"@E 999,999.99")
		@nLin,104 psay Transf(nTIp,"@E 999,999.99")
	elseif cAlias = "SF1"
		@nLin,059 psay "T O T A L "
		@nLin,097 psay Transf(nT,"@E 999,999,999.99")
	endif
	
	if nTG <> 0
		if cAlias == "SEF"
			@++nLin,041 psay "TOTAL  GERAL"
			@nLin  ,070 psay Transf(nTG,"@E 999,999,999.99")
		elseif cAlias == "SC7"
			@++nLin,044 psay "T O T A L   G E R A L"
			@nLin  ,077 psay Transf(nTG,"@E 999,999,999.99")
			@nLin  ,092 psay Transf(nTGIc,"@E 999,999.99")
			@nLin  ,104 psay Transf(nTGIp,"@E 999,999.99")
		elseif cAlias == "SF1"
			@++nLin,059 psay "T O T A L   G E R A L"
			@nLin  ,097 psay Transf(nTG,"@E 999,999,999.99")
		endif
		
//		TEMP->(DbCloseArea())
		
		if cAlias == "SC7"
			nLin += 2
			
			cQry := "select SB1.B1_GRUPO, SBM.BM_DESC, sum(SC7.C7_TOTAL) as C7_TOTAL "
			cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SB1")+" SB1 on (SC7.C7_PRODUTO = SB1.B1_COD) inner join "+RetSqlName("SBM")+" SBM on (SB1.B1_GRUPO = SBM.BM_GRUPO) "
			cQry += "where SC7.C7_NUM in ("+cPedCompra+") and SC7.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SBM.D_E_L_E_T_ <> '*' "
			cQry += "group by SB1.B1_GRUPO, SBM.BM_DESC "
			cQry += "order by SB1.B1_GRUPO"
			
			tcquery cQry new alias "TMP"
			DbSelectArea("TMP")
			DbGoTop()
			
			nTot := 0
			
			while !TMP->(Eof())
				nLin++
				
				@nLin,010 psay TMP->B1_GRUPO
				@nLin,016 psay TMP->BM_DESC
				@nLin,077 psay Transf(TMP->C7_TOTAL,"@E 999,999,999.99")
				
				nTot += TMP->C7_TOTAL
				
				TMP->(DbSkip())
			enddo
			
			TMP->(DbCloseArea())
			
			nLin+= 2
			
			if nTot > 0
				@nLin,044 psay "T O T A L "
				@nLin,077 psay Transf(nTot,"@E 999,999,999.99")
			endif
		endif
	endif
	
	nLin += 3
	
	if aReturn[5] == 1
		@++nLin,000 psay "+----------------------------------------------------------------------------------------------------------------------------------+"
		@++nLin,000 psay "|                         Elaborado por                         |                           Recebido por                           |"
		@++nLin,000 psay "|                _______________________________                |                 ________________________________                 |"
		@++nLin,000 psay "|                           /       /                           |                             /       /                            |"
		@++nLin,000 psay "+----------------------------------------------------------------------------------------------------------------------------------+"
	else
		@++nLin,000 psay "+--------------------------------------------------------------------------------------------------------------------------------------+"
		@++nLin,000 psay "|                          Elaborado por                          |                            Recebido por                            |"
		@++nLin,000 psay "|                 _______________________________                 |                  ________________________________                  |"
		@++nLin,000 psay "|                            /       /                            |                              /       /                             |"
		@++nLin,000 psay "+--------------------------------------------------------------------------------------------------------------------------------------+"
	endif
return

user function SELITMExcluirDoc(cAlias)
	local aNum := {}
	
	Pergunte("SELITM",.T.)
	DbSelectArea("SZ2")
	
	if !Empty(AllTrim(mv_par01))
		if SZ2->(DbSeek(xFilial("SZ2")+cAlias+mv_par01,.F.))
			cMarcador := SZ2->Z2_OK
			
			while !SZ2->(Eof()) .and. SZ2->Z2_TABELA == cAlias .and. SZ2->Z2_SEQUENC == mv_par01 .and. SZ2->Z2_OK == cMarcador
				AAdd(aNum,{AllTrim(SZ2->Z2_ITEM)})
				
	            RecLock("SZ2",.F.)
	            	DbDelete()
	            MsUnLock()
	            
				SZ2->(DbSkip())
			enddo
			
			cUpd := "update "+RetSqlName(cAlias)+" set "+aCamTbl[1]+" = '', "+aCamTbl[2]+" = '' where "+aCamTbl[1]+" = '"+cMarcador+"' and "+aCamTbl[2]+" = '"+mv_par01+"' and D_E_L_E_T_ <> '*'"
			nRet := TCSqlExec(cUpd)
			
			if nRet > 0
				MsgBox("Não foi possivel limpar os marcadores na tabela "+cAlias+"!","Alerta","ALERT")
			else
				MsgBox("Registro excluido com sucesso!","Alerta","ALERT")
			endif
		else
			MsgBox("Registro nao encontrado para excluir!","Alerta","ALERT")
		endif
	endif
	
	lSair := .F.
return

static function PedidoCompra(cCampo,cDoc,cSerie,cFornece,cLoja)
	local aReturno := {}
	
	cQry := "select distinct "+cCampo+" as CAMPO "
	cQry += "from "+RetSqlName("SD1")+" "
	cQry += "where D1_DOC = '"+cDoc+"' and D1_SERIE = '"+cSerie+"' and D1_FORNECE = '"+cFornece+"' and D1_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by "+cCampo
	
	tcquery cQry new alias "TMP1"
	
	DbSelectArea("TMP1")
	TMP1->(DbGoTop())
	
	while !TMP1->(Eof())
		AAdd(aReturno,TMP1->CAMPO)
		
		TMP1->(DbSkip())
	enddo
	
	TMP1->(DbCloseArea())
return(aReturno)