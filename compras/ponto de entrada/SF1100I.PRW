/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/10/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. após gravar o SF1                                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function SF1100I()
	private cEmpresa := SubStr(cNumEmp,1,2)
	private oDlg, oButton, oCancelar, aItems, oRadio
	private cPrazo, cIdent, cEspec, cQuant, cCertif, nRadio
	private cNF := CNFISCAL
	private cPref := CSERIE
	private cForn := CA100FOR
	private cLoja := CLOJA
	private cTipo := IIf(Empty(CTIPO),"N",CTIPO)
	
	aItems := {"Sem avaliacao","Aprovado","Reprovado","Aceito com restricao"}
	nRadio := 0
	
/*	aItems := {"N=Nao","S=Sim"}
	cPrazo := "N"
	cIdent := "N"
	cEspec := "N"
	cQuant := "N"
	cCertif := "N"*/
	
	if INCLUI == .T. .or. ALTERA == .T.
		define msdialog oDlg from 000,000 to 190,430 pixel title "Avaliação do Fornecedor"
			oGroup := TGroup():New(005,007,020,209,"Nota Fiscal / Fornecedor",oDlg,,,.T.)
			@012,010 say cNF+"-"+cPref+" / "+cForn+"-"+cLoja+" - "+If(SA2->(DbSeek(xFilial("SA2")+cForn+cLoja,.F.)),SA2->A2_NREDUZ,"")
			
			oRadio := TRadMenu():New(027,007,aItems,,oDlg,,,,,,,,100,12,,,,.T.)
			oRadio:bSetGet := {|u| IIf(PCount() == 0,nRadio,nRadio := u)}
			
			oRadio:SetOption(1)
			
/*			@027,007 say "Prazo de Entr."
			oCombo := TComboBox():New(025,050,{|u| If(PCount() > 0,cPrazo := u,cPrazo)},aItems,050,020,oDlg,,,,,,.T.,,,,,,,,,"cPrazo")
			@042,007 say "Identif."
			oCombo := TComboBox():New(040,050,{|u| If(PCount() > 0,cIdent := u,cIdent)},aItems,050,020,oDlg,,,,,,.T.,,,,,,,,,"cIdent")
			@057,007 say "Especif."
			oCombo := TComboBox():New(055,050,{|u| If(PCount() > 0,cEspec := u,cEspec)},aItems,050,020,oDlg,,,,,,.T.,,,,,,,,,"cEspec")
			@027,117 say "Quantid."
			oCombo := TComboBox():New(025,160,{|u| If(PCount() > 0,cQuant := u,cQuant)},aItems,050,020,oDlg,,,,,,.T.,,,,,,,,,"cQuant")
			@042,117 say "Certif. do Prod."
			oCombo := TComboBox():New(040,160,{|u| If(PCount() > 0,cCertif := u,cCertif)},aItems,050,020,oDlg,,,,,,.T.,,,,,,,,,"cCertif")*/
			
			oButton := TButton():New(080,145,"Salvar",oDlg,{|| GravarAvaliacao()},030,010,,,,.T.)
			oButton := TButton():New(080,180,"Cancelar",oDlg,{|| Fechar()},030,010,,,,.T.)
		activate msdialog oDlg center
	endif
return

static function Fechar()
	GravaProtocolo()
	GravaOrcamento()
	
	if FunName() <> "MATA116"
		GravaMensagem()
	endif
	
	oDlg:End()
return

static function GravarAvaliacao()
	local aAreaAnt := GetArea()
	local nAvaliac := nRadio - 1
	local cPedido := ""
	
	RecLock("SF1",.F.)
		SF1->F1_AVIQF := Str(nAvaliac,1)
/*		SF1->F1_AVPRZ := cPrazo
		SF1->F1_AVIDENT := cIdent
		SF1->F1_AVESPEC := cEspec
		SF1->F1_AVQUANT := cQuant
		SF1->F1_AVCERTI := cCertif*/
	MsUnLock()
	
	U_AVFORNE(cForn,cLoja,nAvaliac)
	
	if !Empty(nAvaliac)
		if SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
			while !SD1->(Eof()) .and. SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and. SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA
				cPedido := SD1->D1_PEDIDO
				
				SD1->(DbSkip())
			enddo
		endif
		
		if nAvaliac > 1 .and. !Empty(cPedido)
			DbSelectArea("SZR")
			
			cNotif := GetSXENum("SZR","ZR_NOTIF")
			
			if RecLock("SZR",.T.)
				SZR->ZR_FILIAL := xFilial("SZR")
				SZR->ZR_EMISSAO := dDataBase
				SZR->ZR_NUMPC := cPedido
				SZR->ZR_NFISCAL := SF1->F1_DOC
				SZR->ZR_SERIE := SF1->F1_SERIE
				SZR->ZR_DTNF := SF1->F1_EMISSAO
				SZR->ZR_ACDEV := IIf(nAvaliac == 2,"2","1")
				SZR->ZR_NOTIF := cNotif
				SZR->ZR_TIPO := "1"
				SZR->ZR_ENCERR := "3"
				SZR->ZR_FORNECE := SF1->F1_FORNECE
				SZR->ZR_LOJA := SF1->F1_LOJA
				
				MsUnLock()
			endif
			
			SZR->(DbCloseArea())
			ConfirmSX8()
			
			cSubject := "Notificacao de N.C."
			cTo := "compras@ata.ind.br"
			cMensagem := ""
			cEmp := ""
			
			do case
				case cEmpAnt == "01" ; cEmp := "ATA"
				case cEmpAnt == "02" ; cEmp := "ATF"
				otherwise ; cEmp := "TESTE"
			endcase
			
			cMensagem := "<html> "
			cMensagem += "Foi aberto a notificação de não conformidade número <b>"+cNotif+" </b> da empresa "+cEmp+". Favor completar com as informações que faltam para concluir a notificação. "
			cMensagem += "</html> "
			
			if Processa({|| U_EnvMail(cTo,"","",cSubject,,cMensagem,.T.)},"Enviando e-mail...")
				MsgInfo("E-mail enviado com sucesso.")
			endif
		endif
	endif
	
	RestArea(aAreaAnt)
	Fechar()
return

/*static function GravaProtocolo()
	local cLote := IIf(cEmpAnt == "01","","F")+GetSXENum("SZU","ZU_SEQUENC")
	local cLoteAux := cLote
	local nItem := 1
	local cAlias := GetArea()
	
	if "X" $ CSERIE .or. "Z" $ CSERIE
		RecLock("SF1",.F.)
			SF1->F1_CR := "SP"
		MsUnLock()
		
		return
	endif
	
	DbSelectArea("SZU")
	SZU->(DbSetOrder(3))
	
	DbSelectArea("SD1")
	SD1->(DbGoTop())
	SD1->(DbSeek(xFilial("SD1")+CNFISCAL+CSERIE+CA100FOR+CLOJA))
	
	while !SD1->(Eof()) .and. SD1->D1_DOC == CNFISCAL .and. SD1->D1_SERIE == CSERIE .and. SD1->D1_FORNECE == CA100FOR .and. SD1->D1_LOJA == CLOJA
		if Empty(SD1->D1_CR)
			RecLock("SZU",.T.)
				SZU->ZU_FILIAL	:= xFilial()
				SZU->ZU_CODIGO	:= ""
				SZU->ZU_SEQUENC	:= cLote
				SZU->ZU_PEDIDO	:= SD1->D1_CLVL
				SZU->ZU_FORNECE	:= CA100FOR
				SZU->ZU_LOJA	:= CLOJA
				SZU->ZU_NFISCAL	:= CNFISCAL
				SZU->ZU_SERIE	:= CSERIE
				SZU->ZU_EMISSAO	:= SD1->D1_EMISSAO
				SZU->ZU_PRODUTO	:= SD1->D1_COD
				SZU->ZU_NUMCR	:= cLote+StrZero(nItem,2)
				SZU->ZU_USADO	:= "S"
				
				if SD1->D1_TIPO $ "B/D"
					SZU->ZU_CGC := IIf(SA1->(DbSeek(xFilial("SA1")+CA100FOR+CLOJA,.F.)),SA1->A1_CGC,"")
				else
					SZU->ZU_CGC := IIf(SA2->(DbSeek(xFilial("SA2")+CA100FOR+CLOJA,.F.)),SA2->A2_CGC,"")
				endif
				
				SZU->ZU_DTCAD	:= dDataBase
			MsUnLock()
			
			RecLock("SD1",.F.)
				SD1->D1_CR := cLote+StrZero(nItem,2)
			MsUnLock()
		else
			if Left(SD1->D1_CR,1) $ "A/F"
				cLote := Left(SD1->D1_CR,7)
			else
				cLote := Left(SD1->D1_CR,6)
			endif
		endif
		
		nItem++
		SD1->(DbSkip())
	enddo
	
	if cLoteAux == cLote
		ConfirmSX8()
	endif
	
	RecLock("SF1",.F.)
		SF1->F1_CR := cLote
	MsUnLock()
	
	cQry := "update "+RetSqlName("SE2")+" set E2_CR = '"+cLote+"' "
	cQry += "where E2_FILIAL = '"+xFilial("SE2")+"' and E2_NUM = '"+CNFISCAL+"' and E2_PREFIXO = '"+CSERIE+"' and E2_FORNECE = '"+CA100FOR+"' and E2_LOJA = '"+CLOJA+"' and D_E_L_E_T_ <> '*' "
	nRet := TCSqlExec(cQry)
	
	RestArea(cAlias)
return*/

static function GravaProtocolo()
	local cQry := ""
	local nRet := 0
	local cLote, cAno := ""
	local cAlias := Alias()
	local lGrava := .F.
	
	cQry := "select D1_CR, D1_CR1 "
	cQry += "from "+RetSqlName("SD1")+" "
	cQry += "where D1_FILIAL = '"+xFilial("SD1")+"' and D1_DOC = '"+cNF+"' and D1_SERIE = '"+cPref+"' and D1_FORNECE = '"+cForn+"' and D1_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*' "
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
/*	if Empty(TEMP->D1_CR)
		cLote := ""
	elseif !Empty(TEMP->D1_CR1)
		cLote := If(cEmpresa == "01",Left(TEMP->D1_CR1,7),Left(TEMP->D1_CR1,6))
	else
		cLote := If(cEmpresa == "01",Left(TEMP->D1_CR,7),Left(TEMP->D1_CR,6))
		
		lGrava := .T.
	endif*/
	
	if Empty(TEMP->D1_CR)
		cLote := ""
	else
		if Left(TEMP->D1_CR,1) $ "A/F"
			cLote := Left(TEMP->D1_CR,7)
		else
			cLote := Left(TEMP->D1_CR,6)
		endif
		
		lGrava := .T.
	endif
	
//	cQry := "update "+RetSqlName("SD1")+" set D1_CR = D1_CR1 "
//	cQry += "where D1_FILIAL = '"+xFilial("SD1")+"' and D1_DOC = '"+cNF+"' and D1_SERIE = '"+cPref+"' and D1_FORNECE = '"+cForn+"' and D1_LOJA = '"+cLoja+"' and D1_CR1 <> '' and D_E_L_E_T_ <> '*' "
	
//	nRet := TCSqlExec(cQry)
	
	cQry := "update "+RetSqlName("SF1")+" set F1_CR = '"+cLote+"' "
	cQry += "where F1_FILIAL = '"+xFilial("SF1")+"' and F1_DOC = '"+cNF+"' and F1_SERIE = '"+cPref+"' and F1_FORNECE = '"+cForn+"' and F1_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*' "
	
	nRet := TCSqlExec(cQry)
	
	cQry := "update "+RetSqlName("SE2")+" set E2_CR = '"+cLote+"' "
	cQry += "where E2_FILIAL = '"+xFilial("SE2")+"' and E2_NUM = '"+cNF+"' and E2_PREFIXO = '"+cPref+"' and E2_FORNECE = '"+cForn+"' and E2_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*' "
	
	nRet := TCSqlExec(cQry)
	
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cQry := "update "+RetSqlName("SZU")+" set ZU_USADO = 'S' "
		cQry += "where ZU_NUMCR = '"+AllTrim(TEMP->D1_CR)+"' and D_E_L_E_T_ <> '*' "
		
		nRet := TCSqlExec(cQry)
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	
/*	if !Empty(cLote) .and. lGrava == .T.
		if nRet == 0
			cQry := "select F1_EMISSAO "
			cQry += "from "+RetSqlName("SF1")+" "
			cQry += "where F1_FILIAL = '"+xFilial("SF1")+"' and F1_DOC = '"+cNF+"' and F1_SERIE = '"+cPref+"' and F1_FORNECE = '"+cForn+"' and F1_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*' "
			
			tcquery cQry new alias "TEMP"
			DbSelectArea("TEMP")
			
			if cEmpresa == "01"			// ATA
				cAno := "A"+SubStr(TEMP->F1_EMISSAO,3,2)
			else
				cAno := SubStr(TEMP->F1_EMISSAO,3,2)
			endif
			
			TEMP->(DbCloseArea())
			
			cQry := "select X5_DESCRI "
			cQry += "from "+RetSqlName("SX5")+" "
			cQry += "where X5_FILIAL = '"+xFilial("SX5")+"' and X5_TABELA = 'PT' and X5_CHAVE = '"+cAno+"' and D_E_L_E_T_ <> '*' "
			
			tcquery cQry new alias "TEMP"
			DbSelectArea("TEMP")
			
			nNum := Val(TEMP->X5_DESCRI) + 1
			
			TEMP->(DbCloseArea())
			
			cQry := "update "+RetSqlName("SX5")+" "
			cQry += "set X5_DESCRI = '"+StrZero(nNum,4)+"', X5_DESCSPA = '"+StrZero(nNum,4)+"', X5_DESCENG = '"+StrZero(nNum,4)+"' "
			cQry += "where X5_FILIAL = '"+xFilial("SX5")+"' and X5_TABELA = 'PT' and X5_CHAVE = '"+cAno+"' and D_E_L_E_T_ <> '*' "
			
			cRet := TCSqlExec(cQry)
		endif
    endif*/
	
	DbSelectArea(cAlias)
return

static function GravaOrcamento()
	local nPosTot := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_TOTAL"})
	local nPosIpi := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_IPI"})
	local nPosProj := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_CLVL"})
	local nPosProd := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
	local aProj := {}
	local lRet := .F.
	
	for nX := 1 to Len(aCols)
		nTotal := (((aCols[nX][nPosTot] * aCols[nX][nPosIpi]) / 100) + aCols[nX][nPosTot])
		cGrupo := If(SB1->(DbSeek(xFilial("SB1")+aCols[nX][nPosProd],.F.)),SB1->B1_GRUPO,"")
		cProj := aCols[nX][nPosProj]+cGrupo
		
		if (nInd := AScan(aProj,{|x| x[1] = cProj})) == 0
			AAdd(aProj,{cProj,nTotal})
		else
			aProj[nInd][2] += nTotal
		endif
		
		nTotal := 0 ; cGrupo := "" ; cProj := ""
	next nX
	
	U_ValidOrc(aProj,"SF1+")
return

static function GravaMensagem()
	local cQry := ""
	local nRet := 0
	
//	cQry := "update "+RetSqlName("SF1")+" set F1_MENNOTA = '"+_cMenP+"', F1_MENNOT2 = '"+_cMen2+"', F1_MENNOT3 = '"+_cMen3+"', F1_CHVNFE = '"+_cChvNfe+"' "
	cQry := "update "+RetSqlName("SF1")+" set F1_MENNOTA = '"+_cMenP+"', F1_MENNOT2 = '"+_cMen2+"', F1_MENNOT3 = '"+_cMen3+"' "
	cQry += "where F1_FILIAL = '"+xFilial("SF1")+"' and F1_DOC = '"+cNF+"' and F1_SERIE = '"+cPref+"' and F1_FORNECE = '"+cForn+"' and F1_LOJA = '"+cLoja+"' and F1_TIPO = '"+cTipo+"' and D_E_L_E_T_ <> '*'"
	
	nRet := TCSqlExec(cQry)
return