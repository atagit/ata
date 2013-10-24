#include "rwmake.ch"
#include "topconn.ch"

user function REPFORCLI(cTbl,cOpc)
	do case
		case cOpc == "1"	// Inclusao
			Inc(cTbl)
		case cOpc == "2"	// Alteracao
			Alt(cTbl)
		case cOpc == "3"	// Exclusao
			Exc(cTbl)
	endcase
return

static function Inc(cTabela)
	local aCam := {}
	local aItm := {}
	local cCam := ""
	local cItm := ""
	local cTab := cTabela
	local cTab1 := cTab+"->"
	local cTab2 := cTab1+Right(cTab,2)+"_"
	local cAmbOri := Upper(AllTrim(GetEnvServer()))
	local cAmbDes := ""
	local cSxe := ""
	local cSxf := ""
	local cServer := GetMV("MV_RELSERV")
	local cPassword := GetMV("MV_RELPSW")
	local cAccount := GetMV("MV_RELACNT")
	local cSubject := "Inclusão Cadastro de "+If(cTab == "SA1","Cliente","Fornecedor")
	local nCon := -1
	local cFil := xFilial(cTab)
	
	private cCodAtu := &(cTab2+"COD")
	private cLojAtu := &(cTab2+"LOJA")
	private cNomAtu := AllTrim(&(cTab2+"NOME"))
	private cCgcAtu := &(cTab2+"CGC")
	private cEmp := If(cEmpAnt == "01","ATA","ATF")
	private cMensagem := ""
	
	if cAmbOri == "PRODUCAO"
		cAmbDes := "DADOSP11O"
	elseif cAmbOri == "OFICIAL"
		cAmbDes := "DADOSP11P"
	else
		MsgBox("Base não aceita!","Alerta","ALERT")
		
		return
	endif
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cTab)
	
	while !Eof() .and. (X3_ARQUIVO == cTab)
		if X3_CONTEXT <> "V"
			AAdd(aCam,{Trim(X3_CAMPO),X3_TIPO,X3_CONTEXT})
		endif
		
		DbSkip()
	enddo
	
	cCam += aCam[1][1]
	AAdd(aItm,{&(cTab+"->"+aCam[1][1])})
	
	if aCam[1][2] == "N"
		cItm += AllTrim(Str(&(cTab+"->"+aCam[1][1])))
	elseif aCam[1][2] == "D"
		cItm += "'"+DToS(&(cTab+"->"+aCam[1][1]))+"'"
	else
		cItm += "'"+&(cTab+"->"+aCam[1][1])+"'"
	endif
	
	for i := 2 to Len(aCam)
		cCam += ","+aCam[i][1]
		AAdd(aItm,{&(cTab+"->"+aCam[i][1])})
		
		if aCam[i][2] == "N"
			cItm += ","+AllTrim(Str(&(cTab+"->"+aCam[i][1])))
		elseif aCam[i][2] == "D"
			cItm += ",'"+DToS(&(cTab+"->"+aCam[i][1]))+"'"
		else
			cItm += ",'"+&(cTab+"->"+aCam[i][1])+"'"
		endif
	next
	
	TCConType("TCPIP")
	
	if cAmbOri == "PRODUCAO"
		nCon := TCLink("MSSQL7/DADOSP11O","ATFSRV002")
		cSxe := "\system_oficial\SXE.DBF"
		cSxf := "\system_oficial\SXF.DBF"
	elseif cAmbOri == "OFICIAL"
		nCon := TCLink("MSSQL7/DADOSP11P","ATFSRV002")
		cSxe := "\system\SXE.DBF"
		cSxf := "\system\SXF.DBF"
	endif
	
	if nCon >= 0
		TCSetConn(nCon)
		
		if TCCanOpen(RetSqlName(cTab))
			cSql := "select max(R_E_C_N_O_) + 1 as MAIOR from "+RetSqlName(cTab)
			
			tcquery cSql new alias "TMP"
			DbSelectArea("TMP")
			
			nRecno := TMP->MAIOR
			
			TMP->(DbCloseArea())
			
			cIns := "insert into "+RetSqlName(cTab)+"("+cCam+",R_E_C_N_O_,R_E_C_D_E_L_) values("+cItm+","+AllTrim(Str(nRecno))+",0)"
			nRet := TCSqlExec(cIns)
			
			if nRet > 0
				MsgBox("Não foi possível gravar esse registro!","Alerta","ALERT")
			endif
			
			DbUseArea(.T.,,cSxe,"TSXE",.T.,.F.)
			
			index on TSXE->XE_ALIAS+TSXE->XE_FILIAL to TSXEI
			set index to TSXEI
			
			if DbSeek(cTab+cFil+"\"+cTab+cEmpAnt+"0")
				if RecLock("TSXE",.F.)
					TSXE->XE_NUMERO := Soma1(AllTrim(TSXE->XE_NUMERO))
					
					MsUnLock()
				endif
			endif
			
			TSXE->(DbCloseArea())
			
			DbUseArea(.T.,,cSxf,"TSXF",.T.,.F.)
			
			index on TSXF->XF_ALIAS+TSXF->XF_FILIAL to TSXFI
			set index to TSXFI
			
			if DbSeek(cTab+cFil+"\"+cTab+cEmpAnt+"0")
				if RecLock("TSXF",.F.)
					TSXF->XF_NUMERO := Soma1(AllTrim(TSXF->XF_NUMERO))
					
					MsUnLock()
				endif
			endif
			
			TSXF->(DbCloseArea())
			
			MsgHtml()
			
			cTo := "tvcontabilidade@gmail.com"
			
			U_EnvEmail(.T.,.T.,cServer,cAccount,cPassword,cTo,,cSubject,cMensagem)
		else
			MsgBox("Nao foi possivel encontrar a tabela "+RetSqlName(cTab),"Alerta","ALERT")
		endif
		
		TCUnLink(nCon)
	else
		MsgBox("Nao foi possivel realizar a conexao com o MSSQL7/"+cAmbDes+".","Alerta","ALERT")
		
		return
	endif
return

static function Exc(cTabela)
	local aCam := {}
	local aItm := {}
	local cCam := ""
	local cItm := ""
	local cTab := cTabela
	local cTab1 := cTab+"->"
	local cTab2 := cTab1+Right(cTab,2)+"_"
	local cTab3 := Right(cTab,2)+"_"
	local cAmbOri := Upper(AllTrim(GetEnvServer()))
	local cAmbDes := ""
	local nCon := -1
	local cFil := xFilial(cTab)
	
	private cCodAtu := &(cTab2+"COD")
	private cLojAtu := &(cTab2+"LOJA")
	private cEmp := If(cEmpAnt == "01","ATA","ATF")
	
	TCConType("TCPIP")
	
	if cAmbOri == "PRODUCAO"
		cAmbDes := "DADOSP11O"
		nCon := TCLink("MSSQL7/DADOSP11O","ATFSRV002")
	elseif cAmbOri == "OFICIAL"
		cAmbDes := "DADOSP11P"
		nCon := TCLink("MSSQL7/DADOSP11P","ATFSRV002")
	else
		MsgBox("Base não aceita!","Alerta","ALERT")
		
		return
	endif
	
	if nCon >= 0
		TCSetConn(nCon)
		
		if TCCanOpen(RetSqlName(cTab))
			cSql := "select max(R_E_C_D_E_L_) + 1 as MAIOR from "+RetSqlName(cTab)
			
			tcquery cSql new alias "TMP"
			DbSelectArea("TMP")
			
			nRecdel := TMP->MAIOR
			
			TMP->(DbCloseArea())
			
			cUpd := "update "+RetSqlName(cTab)+" set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = "+AllTrim(Str(nRecdel))+" where "+cTab3+"COD = '"+cCodAtu+"' and "+cTab3+"LOJA = '"+cLojAtu+"'"
			nRet := TCSqlExec(cUpd)
			
			if nRet > 0
				MsgBox("Não foi possível atualizar esse registro!","Alerta","ALERT")
			endif
		else
			MsgBox("Nao foi possivel encontrar a tabela "+RetSqlName(cTab),"Alerta","ALERT")
		endif
		
		TCUnLink(nCon)
	else
		MsgBox("Nao foi possivel realizar a conexao com o MSSQL7/"+cAmbDes+".","Alerta","ALERT")
		
		return
	endif
return

static function Alt(cTabela)
	local aCam := {}
	local aItm := {}
	local cCam := ""
	local cItm := ""
	local cTab := cTabela
	local cTab1 := cTab+"->"
	local cTab2 := cTab1+Right(cTab,2)+"_"
	local cTab3 := Right(cTab,2)+"_"
	local cAmbOri := Upper(AllTrim(GetEnvServer()))
	local cAmbDes := ""
	local nCon := -1
	local cFil := xFilial(cTab)
	
	private cCodAtu := &(cTab2+"COD")
	private cLojAtu := &(cTab2+"LOJA")
	private cEmp := If(cEmpAnt == "01","ATA","ATF")
	
	if cAmbOri == "PRODUCAO"
		cAmbDes := "DADOSP11O"
	elseif cAmbOri == "OFICIAL"
		cAmbDes := "DADOSP11P"
	else
		MsgBox("Base não aceita!","Alerta","ALERT")
		
		return
	endif
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cTab)
	
	while !Eof() .and. (X3_ARQUIVO == cTab)
		if X3_CONTEXT <> "V" .and. Trim(X3_CAMPO) <> cTab3+"COD" .and. Trim(X3_CAMPO) <> cTab3+"LOJA"
			AAdd(aCam,{Trim(X3_CAMPO),X3_TIPO,X3_CONTEXT})
		endif
		
		DbSkip()
	enddo
	
	if aCam[1][2] == "N"
		cItm += aCam[1][1]+" = "+AllTrim(Str(&(cTab+"->"+aCam[1][1])))
	elseif aCam[1][2] == "D"
		cItm += aCam[1][1]+" = '"+DToS(&(cTab+"->"+aCam[1][1]))+"'"
	else
		cItm += aCam[1][1]+" = '"+&(cTab+"->"+aCam[1][1])+"'"
	endif
	
	for i := 2 to Len(aCam)
		if aCam[i][2] == "N"
			cItm += ","+aCam[i][1]+" = "+AllTrim(Str(&(cTab+"->"+aCam[i][1])))
		elseif aCam[i][2] == "D"
			cItm += ","+aCam[i][1]+" = '"+DToS(&(cTab+"->"+aCam[i][1]))+"'"
		else
			cItm += ","+aCam[i][1]+" = '"+&(cTab+"->"+aCam[i][1])+"'"
		endif
	next
	
	TCConType("TCPIP")
	
	if cAmbOri == "PRODUCAO"
		nCon := TCLink("MSSQL7/DADOSP11O","ATFSRV002")
	elseif cAmbOri == "OFICIAL"
		nCon := TCLink("MSSQL7/DADOSP11P","ATFSRV002")
	endif
	
	if nCon >= 0
		TCSetConn(nCon)
		
		if TCCanOpen(RetSqlName(cTab))
			cUpd := "update "+RetSqlName(cTab)+" set "+cItm+" where "+cTab3+"COD = '"+cCodAtu+"' and "+cTab3+"LOJA = '"+cLojAtu+"'"
			nRet := TCSqlExec(cUpd)
			
			if nRet > 0
				MsgBox("Não foi possível atualizar esse registro!","Alerta","ALERT")
			endif
		else
			MsgBox("Nao foi possivel encontrar a tabela "+RetSqlName(cTab),"Alerta","ALERT")
		endif
		
		TCUnLink(nCon)
	else
		MsgBox("Nao foi possivel realizar a conexao com o MSSQL7/"+cAmbDes+".","Alerta","ALERT")
		
		return
	endif
return

static function MsgHtml()
	cMensagem := "<html> "
	cMensagem += "	<body> "
	cMensagem += "		<font face='verdana' size='2'> "
	cMensagem += "			Existe um novo cliente/fornecedor cadastrado para atualizar a Conta Contábil.<br><br> "
	cMensagem += "			Segue abaixo dados do fonecedor:<br><br> "
	cMensagem += "			<table border='1'> "
	cMensagem += "				<tr> "
	cMensagem += "					<td height='30' colspan='4' align='center' bgcolor='3C79D5'><font face='verdana' size='3' color='FFFFFF'><b>FORNECEDOR</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Código</font></td> "
	cMensagem += "					<td><font face='verdana' size='2'>&nbsp;<b>"+cCodAtu+"-"+cLojAtu+"</b></font></td> "
	cMensagem += "					<td width='90'><font face='verdana' size='2'>Empresa</font></td> "
	cMensagem += "					<td><font face='verdana' size='2'>&nbsp;<b>"+cEmp+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Razão Social</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>"+AllTrim(cNomAtu)+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>CNPJ</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>"+AllTrim(cCgcAtu)+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td height='5' colspan='4' bgcolor='3C79D5'></td> "
	cMensagem += "				</tr> "
	cMensagem += "			</table> "
	cMensagem += "		</font> "
	cMensagem += "	</body> "
	cMensagem += "</html> "
return