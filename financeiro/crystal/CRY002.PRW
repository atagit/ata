/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/10/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de Controle de Saldo de Contas Bancarias    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#define _DIASEM {"DOM","SEG","TER","QUA","QUI","SEX","SAB"}
#define _MES {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}
#define _MAXBCO 7

user function CRY002()
/*user function CRY002(cOpc,cConta,cCelula)
	local cRetorno := ""
	local nPos := Val(Right(cCelula,1))
	local aLimite := {"CHEQUE EMPRESA","CONTA GARANTIDA"}
	local cAno := StrZero(Year(dDataBase),4)
	local cMes := StrZero(Month(dDataBase),2)
	local cContas := GetMV("MV_CONTAS")
	
	if cOpc == "EMP"
		return IIf(cFilAnt == "01","ATA","ATF")
	elseif cOpc == "CAB" .and. cConta $ cContas
		do case
			case Left(cCelula,3) == "C3"
				cQry := "select A6_COD, A6_AGENCIA, A6_NUMCON, A6_NREDUZ, A6_CONTATO, A6_TEL, A6_CELULAR "
				cQry += "from "+RetSqlName("SA6")+" "
				cQry += "where A6_NUMCON = '"+cConta+"' and A6_BLOCKED <> '1' and A6_EXIBREL = 'S' and D_E_L_E_T_ <> '*'"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := TMP->A6_NREDUZ
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
			case Left(cCelula,3) == "C4"
				return AllTrim(cRetorno)
			case Left(cCelula,3) == "C5"
				cQry := "select A6_COD, A6_AGENCIA, A6_NUMCON, A6_NREDUZ, A6_CONTATO, A6_TEL, A6_CELULAR "
				cQry += "from "+RetSqlName("SA6")+" "
				cQry += "where A6_NUMCON = '"+cConta+"' and A6_BLOCKED <> '1' and A6_EXIBREL = 'S' and D_E_L_E_T_ <> '*'"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := TMP->A6_CONTATO
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
			case Left(cCelula,3) == "C6"
				cQry := "select A6_COD, A6_AGENCIA, A6_NUMCON, A6_NREDUZ, A6_CONTATO, A6_TEL, A6_CELULAR "
				cQry += "from "+RetSqlName("SA6")+" "
				cQry += "where A6_NUMCON = '"+cConta+"' and A6_BLOCKED <> '1' and A6_EXIBREL = 'S' and D_E_L_E_T_ <> '*'"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := TMP->A6_TEL
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
			case Left(cCelula,3) == "C7"
				cQry := "select A6_COD, A6_AGENCIA, A6_NUMCON, A6_NREDUZ, A6_CONTATO, A6_TEL, A6_CELULAR "
				cQry += "from "+RetSqlName("SA6")+" "
				cQry += "where A6_NUMCON = '"+cConta+"' and A6_BLOCKED <> '1' and A6_EXIBREL = 'S' and D_E_L_E_T_ <> '*'"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := TMP->A6_CELULAR
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
		endcase
	elseif cOpc == "LIM" .and. cConta $ cContas
		do case
			case Left(cCelula,3) $ "A11/A12"
				return aLimite[nPos]
			case Left(cCelula,3) $ "C11/E11/G11/I11/K11/M11"
				cQry := "select ZQ_BANCO, ZQ_AGENCIA, ZQ_CONTA, ZQ_CREDITO, ZQ_VALOR, ZQ_TAXA, ZQ_TIPO "
				cQry += "from "+RetSqlName("SZQ")+" "
				cQry += "where ZQ_CONTA = '"+cConta+"' and ZQ_CREDITO = '"+aLimite[nPos]+"' and ZQ_TIPO = '1' and D_E_L_E_T_ <> '*' "
				cQry += "order by ZQ_TIPO, ZQ_CREDITO"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := Transf(TMP->ZQ_VALOR,"@E 9,999,999")
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
			case Left(cCelula,3) $ "D11/F11/H11/J11/L11/N11"
				cQry := "select ZQ_BANCO, ZQ_AGENCIA, ZQ_CONTA, ZQ_CREDITO, ZQ_VALOR, ZQ_TAXA, ZQ_TIPO "
				cQry += "from "+RetSqlName("SZQ")+" "
				cQry += "where ZQ_CONTA = '"+cConta+"' and ZQ_CREDITO = '"+aLimite[nPos]+"' and ZQ_TIPO = '1' and D_E_L_E_T_ <> '*' "
				cQry += "order by ZQ_TIPO, ZQ_CREDITO"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := Transf(TMP->ZQ_TAXA,"@E 99.99")
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
		endcase
	elseif cOpc == "APL" .and. cConta $ cContas
		do case
			case Left(cCelula,3) $ "A17"
				return "CDB"
			case Left(cCelula,3) $ "C17/E17/G17/I17/K17/M17"
				cQry := "select ZQ_BANCO, ZQ_AGENCIA, ZQ_CONTA, ZQ_CREDITO, ZQ_VALOR, ZQ_TAXA, ZQ_TIPO "
				cQry += "from "+RetSqlName("SZQ")+" "
				cQry += "where ZQ_CONTA = '"+cConta+"' and ZQ_TIPO = '3' and D_E_L_E_T_ <> '*' "
				cQry += "order by ZQ_TIPO, ZQ_CREDITO"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := Transf(TMP->ZQ_VALOR,"@E 9,999,999")
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
			case Left(cCelula,3) $ "D17/F17/H17/J17/L17/N17"
				cQry := "select ZQ_BANCO, ZQ_AGENCIA, ZQ_CONTA, ZQ_CREDITO, ZQ_VALOR, ZQ_TAXA, ZQ_TIPO "
				cQry += "from "+RetSqlName("SZQ")+" "
				cQry += "where ZQ_CONTA = '"+cConta+"' and ZQ_TIPO = '3' and D_E_L_E_T_ <> '*' "
				cQry += "order by ZQ_TIPO, ZQ_CREDITO"
				
				tcquery cQry alias "TMP" new
				
				DbSelectArea("TMP")
				
				cRetorno := Transf(TMP->ZQ_TAXA,"@E 99.99")
				
				TMP->(DbCloseArea())
				
				return AllTrim(cRetorno)
		endcase
	elseif cOpc == "SAL" .and. cConta $ cContas
		cQry := "select ZP_BANCO, ZP_AGENCIA, ZP_CONTA, ZP_DTSALDO, ZP_SALATUA, ZP_PENDENT, day(ZP_DTSALDO) as DIA, datename(weekday,ZP_DTSALDO) as SEMANA "
		cQry += "from "+RetSqlName("SZP")+" "
		cQry += "where ZP_CONTA = '"+cConta+"' and ZP_DTSALDO = '"+cAno+cMes+cCelula+"' and D_E_L_E_T_ <> '*' "
		cQry += "order by ZP_DTSALDO"
		
		tcquery cQry alias "TMP" new
		
		DbSelectArea("TMP")
		
		cRetorno := Transf(TMP->ZP_SALATUA,"@E 9,999,999")
		
		TMP->(DbCloseArea())
		
		return AllTrim(cRetorno)
	endif*/
	
	local oButton1, oButton2
	local oSay1, oSay2, oSay3
	local oGroup1, oGroup2
	local oComboBox1
	local cComboBox1 := StrZero(Month(dDataBase),2)
	local oGet1
	local cGet1 := StrZero(Year(dDataBase),4)
	
	private oDlg
	private oListBox1
	private aArqList := {}
	private oOk := LoadBitmap(GetResources(),"LBOK")
	private oNo := LoadBitmap(GetResources(),"LBNO")
	
	define msdialog oDlg title "Banco a Imprimir" from 000,000 to 360,500 colors 0,16777215 pixel
		@003,003 group oGroup1 to 028,245 prompt "" of oDlg color 0,16777215 pixel
		@011,007 say oSay1 prompt "Seleciona abaixo no máximo "+StrZero(_MAXBCO,2)+" bancos para exibicao do relatorio." size 200,010 of oDlg colors 0,16777215 pixel
		@032,003 group oGroup2 to 159,245 prompt " Bancos " of oDlg color 0,16777215 pixel
		
		FGetList()
		
		@166,007 say oSay2 prompt "MES" size 010,010 of oDlg colors 0,16777215 pixel
		@164,023 mscombobox oComboBox1 var cComboBox1 items {"01","02","03","04","05","06","07","08","09","10","11","12"} size 028,010 of oDlg colors 0,16777215 pixel
		@166,063 say oSay3 prompt "ANO" size 012,010 of oDlg colors 0,16777215 pixel
		@164,079 msget oGet1 var cGet1 size 022,010 of oDlg colors 0,16777215 pixel
		
		@163,167 button oButton1 prompt "OK" size 037,012 of oDlg action Selecionar(cComboBox1,cGet1) pixel
		@163,207 button oButton2 prompt "Cancelar" size 037,012 of oDlg action oDlg:End() pixel
	activate msdialog oDlg centered
return

static function FGetList()
	local nCont := 1
	
	cQry := "select A6_COD, A6_AGENCIA, A6_NUMCON, A6_NREDUZ "
	cQry += "from "+RetSqlName("SA6")+" "
	cQry += "where A6_EXIBREL = 'S' and A6_BLOCKED <> '1' and D_E_L_E_T_ <> '*' "
	cQry += "order by A6_COD, A6_AGENCIA, A6_NUMCON"
	
	tcquery cQry alias "TMP" new
	
	DbSelectArea("TMP")
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if nCont <= _MAXBCO
			AAdd(aArqList,{.T.,TMP->A6_COD,TMP->A6_AGENCIA,TMP->A6_NUMCON,TMP->A6_NREDUZ})
		else
			AAdd(aArqList,{.F.,TMP->A6_COD,TMP->A6_AGENCIA,TMP->A6_NUMCON,TMP->A6_NREDUZ})
		endif
		
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
	
	if Len(aArqList) <= 0
		AAdd(aArqList,{.F.,"","","",""})
	endif
	
	@042,007 listbox oListBox1 fields header "","COD","AGENCIA","CONTA","BANCO" size 235,112 of oDlg pixel colsizes 050,030
		oListBox1:SetArray(aArqList)
		oListBox1:bLine := {|| {IIf(aArqList[oListBox1:nAt][1],oOk,oNo),aArqList[oListBox1:nAt][2],aArqList[oListBox1:nAt][3],aArqList[oListBox1:nAt][4],aArqList[oListBox1:nAt][5]}}
		// DoubleClick event
		oListBox1:bLDblClick := {|| aArqList[oListBox1:nAt,1] := !aArqList[oListBox1:nAt,1],oListBox1:DrawSelect()}
return

static function Selecionar(cMes,cAno)
	local aBancos := {}
	local lVazio := .T.
	
	if Len(aArqList) > _MAXBCO
		MsgAlert("O relatorio nao exibi mais de "+StrZero(_MAXBCO,2)+" bancos ao mesmo tempo. Favor selecionar novamente!")
		
		return
	endif
	
	for i := 1 to Len(aArqList)
		if aArqList[i][1]
			AAdd(aBancos,{i,aArqList[i][2],aArqList[i][3],aArqList[i][4],aArqList[i][5]})
			
			lVazio := .F.
		endif
	next
	
	if lVazio
		return MsgAlert("Nao foram selecionado nenhum banco para impressao.")
	else
		Processa({|| GeraRel(aBancos,cMes,cAno)},"Aguarde...","Gerando relatorio...",.F.)
	endif
	
	oDlg:End()
return

static function GeraRel(aBancos,cMes,cAno)
	local cArqDBF := ""
	local cQry := ""
	local dUltDiaMes := LastDate(SToD(cAno+cMes+"01"))
	local nContDias := 0
	local nTotDias := 0
	local aContDias := {}
	local aTotDias := {}
	
	private cReport := "CRY002"
	private cOpcoes := "1;0;1;Saldo de Contas Bancarias"
	private cParam  := AllTrim(cEmpAnt)+";"+AllTrim(cFilAnt)+";"
	
	//***** DADOS DO BANCO *****\\
	cArqDBF := GetMV("MV_DBFCRY")+"CRY002_1.DBF"
	
	DbUseArea(.T.,"DBFCDX",cArqDBF,"TRB",.F.,.F.)
	
	ZAP
	
	for i := 1 to Len(aBancos)
		cQry := "select A6_COD, A6_AGENCIA, A6_NUMCON, A6_NREDUZ, A6_CONTATO, A6_TEL, A6_CELULAR "
		cQry += "from "+RetSqlName("SA6")+" "
		cQry += "where A6_COD = '"+aBancos[i][2]+"' and A6_AGENCIA = '"+aBancos[i][3]+"' and A6_NUMCON = '"+aBancos[i][4]+"' and A6_BLOCKED <> '1' and A6_EXIBREL = 'S' and D_E_L_E_T_ <> '*' "
		cQry += "order by A6_COD, A6_AGENCIA, A6_NUMCON"
		
		tcquery cQry alias "TMP" new
		
		DbSelectArea("TMP")
		RecLock("TRB",IIf(i = 1,.T.,.F.))
		
		TRB->&("COD"+Str(i,1)) := TMP->A6_COD
		TRB->&("BANCO"+Str(i,1)) := TMP->A6_NREDUZ
		TRB->&("CONTA"+Str(i,1)) := TMP->A6_NUMCON
		TRB->&("GERENT"+Str(i,1)) := TMP->A6_CONTATO
		TRB->&("TEL"+Str(i,1)) := TMP->A6_TEL
		TRB->&("CEL"+Str(i,1)) := TMP->A6_CELULAR
		TRB->MES := _MES[Val(cMes)]
		TRB->ANO := cAno
		TRB->EMPRESA := AllTrim(cEmpAnt)
		
		MsUnLock()
		TMP->(DbCloseArea())
	next
	
	//***** LIMITE DE CREDITO *****\\
	cArqDBF := GetMV("MV_DBFCRY")+"CRY002_2.DBF"
	lVazio := .T.
	
	TRB->(DbCloseArea())
	FErase(GetMV("MV_DBFCRY")+"ITRB.CDX")
	DbUseArea(.T.,"DBFCDX",cArqDBF,"TRB",.F.,.F.)
	
	index on CREDITO to &(GetMV("MV_DBFCRY")+"ITRB.CDX")
	ZAP
	
	for i := 1 to Len(aBancos)
		cQry := "select ZQ_BANCO, ZQ_AGENCIA, ZQ_CONTA, ZQ_CREDITO, ZQ_VALOR, ZQ_TAXA, ZQ_TIPO "
		cQry += "from "+RetSqlName("SZQ")+" "
		cQry += "where ZQ_BANCO = '"+aBancos[i][2]+"' and ZQ_AGENCIA = '"+aBancos[i][3]+"' and ZQ_CONTA = '"+aBancos[i][4]+"' and ZQ_TIPO = '1' and D_E_L_E_T_ <> '*' "
		cQry += "order by ZQ_TIPO, ZQ_CREDITO"
		
		tcquery cQry alias "TMP" new
		
		DbSelectArea("TMP")
		TMP->(DbGoTop())
		
		while !TMP->(Eof())
			TRB->(DbGoTop())
			
//			if TRB->(DbSeek(TMP->ZQ_CREDITO,.F.))
			if TRB->(DbSeek("CTA.G./CHQ.E.",.F.))
				RecLock("TRB",.F.)
			else
				RecLock("TRB",.T.)
				
//				TRB->CREDITO := TMP->ZQ_CREDITO
				TRB->CREDITO := "CTA.G./CHQ.E."
			endif
			
			TRB->&("VALOR"+Str(i,1)) := TMP->ZQ_VALOR
			TRB->&("TAXA"+Str(i,1)) := TMP->ZQ_TAXA
			lVazio := .F.
			
			MsUnLock()
			TMP->(DbSkip())
		enddo
		
		TMP->(DbCloseArea())
	next
	
	if lVazio
		RecLock("TRB",.T.)
		
		TRB->CREDITO := " "
		TRB->VALOR1 := 0
		TRB->TAXA1 := 0
		
		MsUnLock()
	endif
	
	//***** APLICACAO *****\\
	cArqDBF := GetMV("MV_DBFCRY")+"CRY002_4.DBF"
	lVazio := .T.
	
	TRB->(DbCloseArea())
	FErase(GetMV("MV_DBFCRY")+"ITRB.CDX")
	DbUseArea(.T.,"DBFCDX",cArqDBF,"TRB",.F.,.F.)
	
	index on CREDITO to &(GetMV("MV_DBFCRY")+"ITRB.CDX")
	ZAP
	
	for i := 1 to Len(aBancos)
		cQry := "select ZQ_BANCO, ZQ_AGENCIA, ZQ_CONTA, ZQ_CREDITO, ZQ_VALOR, ZQ_TAXA, ZQ_TIPO "
		cQry += "from "+RetSqlName("SZQ")+" "
		cQry += "where ZQ_BANCO = '"+aBancos[i][2]+"' and ZQ_AGENCIA = '"+aBancos[i][3]+"' and ZQ_CONTA = '"+aBancos[i][4]+"' and ZQ_TIPO = '3' and D_E_L_E_T_ <> '*' "
		cQry += "order by ZQ_TIPO, ZQ_CREDITO"
		
		tcquery cQry alias "TMP" new
		
		DbSelectArea("TMP")
		TMP->(DbGoTop())
		
		while !TMP->(Eof())
			TRB->(DbGoTop())
			
			if TRB->(DbSeek(TMP->ZQ_CREDITO,.F.))
				RecLock("TRB",.F.)
			else
				RecLock("TRB",.T.)
				
				TRB->CREDITO := TMP->ZQ_CREDITO
			endif
			
			TRB->&("VALOR"+Str(i,1)) := TMP->ZQ_VALOR
			TRB->&("TAXA"+Str(i,1)) := TMP->ZQ_TAXA
			lVazio := .F.
			
			MsUnLock()
			TMP->(DbSkip())
		enddo
		
		TMP->(DbCloseArea())
	next
	
	if lVazio
		RecLock("TRB",.T.)
		
		TRB->CREDITO := " "
		TRB->VALOR1 := 0
		TRB->TAXA1 := 0
		
		MsUnLock()
	endif
	
	//***** SALDO DIARIO *****\\
	cArqDBF := GetMV("MV_DBFCRY")+"CRY002_3.DBF"
	
	TRB->(DbCloseArea())
	FErase(GetMV("MV_DBFCRY")+"ITRB.CDX")
	DbUseArea(.T.,"DBFCDX",cArqDBF,"TRB",.F.,.F.)
	
	index on DIA to &(GetMV("MV_DBFCRY")+"ITRB.CDX")
	ZAP
	
	for i := 1 to Len(aBancos)
		if aBancos[i][2] == "033"
			aBancos[i][4] := "000000002"
		endif
		
		cQry := "select ZP_BANCO, ZP_AGENCIA, ZP_CONTA, ZP_DTSALDO, ZP_SALATUA, ZP_PENDENT, day(ZP_DTSALDO) as DIA, datename(weekday,ZP_DTSALDO) as SEMANA "
		cQry += "from "+RetSqlName("SZP")+" "
		cQry += "where ZP_BANCO = '"+aBancos[i][2]+"' and ZP_AGENCIA = '"+aBancos[i][3]+"' and ZP_CONTA = '"+aBancos[i][4]+"' and month(ZP_DTSALDO) = "+cMes+" and year(ZP_DTSALDO) = "+cAno+" and D_E_L_E_T_ <> '*' "
		cQry += "order by ZP_DTSALDO"
		
		tcquery cQry alias "TMP" new
		
		DbSelectArea("TMP")
		TMP->(DbGoTop())
		
		while !TMP->(Eof())
			TRB->(DbGoTop())
			
			if TRB->(DbSeek(StrZero(TMP->DIA,2),.F.))
				RecLock("TRB",.F.)
			else
				RecLock("TRB",.T.)
				
				TRB->DIA := StrZero(TMP->DIA,2)
				TRB->SEMANA := _DIASEM[Dow(SToD(TMP->ZP_DTSALDO))]
			endif
			
//			TRB->&("SALDO"+Str(i,1)) := TMP->(ZP_SALATUA + ZP_PENDENT)
			TRB->&("SALDO"+Str(i,1)) := TMP->ZP_SALATUA
			TRB->&("PENDT"+Str(i,1)) := TMP->ZP_PENDENT
			nTotDias += TMP->ZP_SALATUA
			nContDias++
			
			MsUnLock()
			TMP->(DbSkip())
		enddo
		
		AAdd(aTotDias,nTotDias)
		AAdd(aContDias,nContDias)
		
		nTotDias := 0
		nContDias := 0
		
		TMP->(DbCloseArea())
	next
	
	for i := 1 to Day(dUltDiaMes)
		TRB->(DbGoTop())
		
		if !(TRB->(DbSeek(StrZero(i,2),.F.)))
			RecLock("TRB",.T.)
			
			dData := SToD(cAno+cMes+StrZero(i,2))
			nDiaSemana := Dow(dData)
			
			if nDiaSemana > 0
				TRB->DIA := StrZero(i,2)
				TRB->SEMANA := _DIASEM[nDiaSemana]
			endif
			
			MsUnLock()
		endif
	next
	
	TRB->(DbGoTop())
	
	aMatriz := {}
	
	while !TRB->(Eof())
		AAdd(aMatriz,TRB->(U_Scatter()))
		
		TRB->(DbSkip())
	enddo
	
	ZAP
	
	ASort(aMatriz,,,{|x,y| x[1] < y[1]})
	
	for i := 1 to Len(aMatriz)
		if !Empty(aMatriz[i][1]) .and. aMatriz[i][1] <> "**"
			RecLock("TRB",.T.)
				TRB->(U_Gather(aMatriz[i]))
			MsUnLock()
		endif
	next
	
	//***** SALDO MEDIO *****\\
	cArqDBF := GetMV("MV_DBFCRY")+"CRY002_5.DBF"
	
	DbUseArea(.T.,"DBFCDX",cArqDBF,"TMP",.F.,.F.)
	
	ZAP
	
	for i := 1 to Len(aBancos)
		if i == 1
			RecLock("TMP",.T.)
		else
			RecLock("TMP",.F.)
		endif
		
		TMP->&("VALOR"+Str(i,1)) := aTotDias[i] / aContDias[i]
		
		MsUnLock()
	next
	
	CallCrys(cReport,cParam,cOpcoes)
	
	TMP->(DbCloseArea())
	TRB->(DbCloseArea())
	FErase(GetMV("MV_DBFCRY")+"ITRB.CDX")
return