/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/05/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ TAIF                                                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#define _EMPRESAS {"ATA","ATF"}
#define _TIPO {"C","M","G"}
#define _MAXMEMO 1000

user function TAIF()
	local oButton1, oButton2, oButton3, oButton4, oButton5, oButton6
	local oCheckBo1, oCheckBo2, oCheckBo3, oCheckBo4, oCheckBo5
	local oComboBo1, oComboBo2, oComboBo3
	local oGet1, oGet2, oGet3, oGet4, oGet5, oGet6
	local oGroup1, oGroup2, oGroup3, oGroup4
	local oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oSay8, oSay9
	local lCheckBo1 := .F.
	local lCheckBo2 := .F.
	local lCheckBo3 := .F.
	local lCheckBo4 := .F.
	local lCheckBo5 := .F.
	local nComboBo1 := _EMPRESAS[1]
	local nComboBo2 := _EMPRESAS[1]
	local nComboBo3 := _EMPRESAS[1]
	local cGet1 := Date()
	local cGet2 := Date()
	local cGet3 := Date()
	local cGet4 := Date()
	local cGet5 := Date()
	local cGet6 := Date()
	local nMeter := 1
	
	private oFolder1
	private oWBrowse1, oWBrowse2, oWBrowse3
	private oMeter1, oMeter2, oMeter3
	private oSay10, oSay11, oSay12
	private aWBrowse1 := {}
	private aWBrowse2 := {}
	private aWBrowse3 := {}
	private lMsErroAuto := .F.
	
	static oDlg
	
	define msdialog oDlg title "IMPORTACAO" from 000,000 to 280,410 colors 0,16777215 pixel
		@000,000 folder oFolder1 size 207,140 of oDlg items "Resumido","Tab. Cadastro","Tab. Movimento" colors 0,16777215 pixel
		
		FWBrowse1()
		
		@086,001 group oGroup4 to 106,201 of oFolder1:aDialogs[3] color 0,16777215 pixel
		@093,005 say oSay7 prompt "Empresa" size 025,007 of oFolder1:aDialogs[3] colors 0,16777215 pixel
		@091,030 mscombobox oComboBo3 var nComboBo3 items _EMPRESAS size 039,010 of oFolder1:aDialogs[3] colors 0,16777215 pixel
		@093,081 say oSay8 prompt "Período" size 025,007 of oFolder1:aDialogs[3] colors 0,16777215 pixel
		@090,104 msget oGet5 var cGet5 size 042,010 of oFolder1:aDialogs[3] picture "99/99/9999" colors 0,16777215 pixel
		@093,149 say oSay9 prompt "à" size 008,007 of oFolder1:aDialogs[3] colors 0,16777215 pixel
		@090,156 msget oGet6 var cGet6 size 042,010 of oFolder1:aDialogs[3] picture "99/99/9999" colors 0,16777215 pixel
		@110,121 button oButton5 prompt "OK" size 037,012 of oFolder1:aDialogs[3] action OkTabMovimento(cGet5,cGet6,If(nComboBo3 == _EMPRESAS[1],1,2)) pixel
		@110,164 button oButton6 prompt "Cancel" size 037,012 of oFolder1:aDialogs[3] action oDlg:End() pixel
		@114,090 say oSay12 prompt "" size 025,007 of oFolder1:aDialogs[3] colors 0,16777215 pixel
		@114,001 meter oMeter3 var nMeter size 085,008 of oFolder1:aDialogs[3] total 100 color 0,16777215 pixel
		
		FWBrowse2()
		
		@086,001 group oGroup3 to 106,201 of oFolder1:aDialogs[2] color 0,16777215 pixel
		@093,005 say oSay4 prompt "Empresa" size 025,007 OF oFolder1:aDialogs[2] colors 0,16777215 pixel
		@091,030 mscombobox oComboBo2 var nComboBo2 items _EMPRESAS size 039,010 of oFolder1:aDialogs[2] colors 0,16777215 pixel
		@110,121 button oButton3 prompt "OK" size 037,012 of oFolder1:aDialogs[2] action OkTabCadastro(If(nComboBo2 == _EMPRESAS[1],1,2)) pixel
		@110,164 button oButton4 prompt "Cancel" size 037,012 of oFolder1:aDialogs[2] action oDlg:End() pixel
		@114,090 say oSay11 prompt "" size 025,007 of oFolder1:aDialogs[2] colors 0,16777215 pixel
		@114,001 meter oMeter2 var nMeter size 085,008 of oFolder1:aDialogs[2] total 100 color 0,16777215 pixel
		
		FWBrowse3()
		
		@086,001 group oGroup1 to 106,201 of oFolder1:aDialogs[1] color 0,16777215 pixel
		@093,005 say oSay1 prompt "Empresa" size 025,007 of oFolder1:aDialogs[1] colors 0,16777215 pixel
		@091,030 mscombobox oComboBo1 var nComboBo1 items _EMPRESAS size 039,010 of oFolder1:aDialogs[1] colors 0,16777215 pixel
		@093,081 say oSay2 prompt "Período" size 025,007 of oFolder1:aDialogs[1] colors 0,16777215 pixel
		@090,104 msget oGet1 var cGet1 size 042,010 of oFolder1:aDialogs[1] colors 0,16777215 pixel
		@093,149 say oSay3 prompt "à" size 008,007 of oFolder1:aDialogs[1] colors 0,16777215 pixel
		@090,156 msget oGet2 var cGet2 size 042,010 of oFolder1:aDialogs[1] colors 0,16777215 pixel
		@110,121 button oButton1 prompt "OK" size 037,012 of oFolder1:aDialogs[1] action OkResumido(cGet1,cGet2,If(nComboBo1 == _EMPRESAS[1],1,2)) pixel
		@110,164 button oButton2 prompt "Cancel" size 037,012 of oFolder1:aDialogs[1] action oDlg:End() pixel
		@114,090 say oSay10 prompt "" size 025,007 of oFolder1:aDialogs[1] colors 0,16777215 pixel
		@114,001 meter oMeter1 var nMeter size 085,008 of oFolder1:aDialogs[1] total 100 color 0,16777215 pixel
	activate msdialog oDlg centered
return

static function Importar(nOpcao,aTabelas,nCbo1,cGt1,cGt2,lCanc)
	local aCampos := {}
	local aRegistros := {}
	local aTaif := {}
	local aSX3 := {}
	local aItm := {}
	local aMemo := {}
	local aRegistros := {}
	local aCondicao := {}
	local cCam := ""
	local cCondicao := ""
	local cCondic := ""
	local cQry := ""
	local cTipo := ""
	local cMemo := ""
	local cSelect := ""
	local nCont := 0
	local cCanc := ""
	local lDocSeq := .F.
	local lConcluido := .F.
	
	if !Empty(aTabelas[1])
		for i := 1 to Len(aTabelas)
			cAlias := aTabelas[i]+"0"+AllTrim(Str(nCbo1))+"0"
			lDocSeq := IIf(aTabelas[i] $ "SD1/SD2/SD3",.T.,lDocSeq)
			
			DbSelectArea("SZT")
			SZT->(DbGoTop())
			
			if SZT->(DbSeek(xFilial("SZT")+aTabelas[i],.F.))
				cCaract := "" ; cResult := ""
				aSX3 := VariavelCampo(aTabelas[i])
				aCampos := StrTokArr(SZT->ZT_CHAVE,"+")
				cCondic := AllTrim(SZT->ZT_CONDIC)
				aMemo := StrTokArr(SZT->ZT_MEMO,"+")
				cTipo := SZT->ZT_TIPO
				cCanc := IIf(lCanc == .T.,AllTrim(SZT->ZT_DTCANC)+" <> '' and ","")
				
				if !Empty(aCampos[1])
					for j := 1 to Len(aCampos)
						cCondicao += "PRO."+AllTrim(aCampos[j])+" = OFI."+Alltrim(aCampos[j])+" and "
					next
					
					cCondicao := SubStr(cCondicao,1,Len(cCondicao) - 5)
				endif
				
				if !Empty(aMemo[1])
					for j := 1 to Len(aMemo)
						cMemo += "convert(varchar("+AllTrim(Str(_MAXMEMO))+"),convert(varbinary("+AllTrim(Str(_MAXMEMO))+"),PRO."+AllTrim(aMemo[j])+")) as "+AllTrim(aMemo[j])+","
					next
				endif
				
				for j := 1 to Len(aSX3)
					if Empty(aMemo[1])
						cSelect += "PRO."+aSX3[j][1]+","
					else
						if !(aSX3[j][1] $ SZT->ZT_MEMO)
							cSelect += "PRO."+aSX3[j][1]+","
						endif
					endif
				next
				
				cSelect += cMemo
				cQry := "select "+AllTrim(cSelect)+"OFI."+AllTrim(aCampos[1])+" as OFIC "
				cQry += "from [DADOSP11P].dbo."+cAlias+" PRO left join [DADOSP11O].dbo."+cAlias+" OFI on ("+AllTrim(cCondicao)+") "
				
				if !Empty(AllTrim(cCondic))
					for k := 1 to Len(cCondic)
						cCaract := SubStr(cCondic,k,1)
						
						do case
							case cCaract == "$"
								k++
								
								do case
									case cCaract+SubStr(cCondic,k,1) == "$1"
										cResult += DToS(cGt1)
									case cCaract+SubStr(cCondic,k,1) == "$2"
										cResult += DToS(cGt2)
								endcase
							case cCaract == "!"
								cResult += "OFI"
							case cCaract == "?"
								cResult += "PRO"
							otherwise
								cResult += cCaract
						endcase
					next
					
					cQry += "where "+cResult+" and "+cCanc+"OFI."+AllTrim(aCampos[1])+" is null and PRO.D_E_L_E_T_ <> '*'"
				else
					cQry += "where "+cCanc+"OFI."+AllTrim(aCampos[1])+" is null and PRO.D_E_L_E_T_ <> '*'"
				endif
				
				tcquery cQry new alias "TAIF"
				
				DbSelectArea("TAIF")
				
				count to nRegTAIF
				
				TAIF->(DbGoTop())
				
				&("oMeter"+AllTrim(Str(nOpcao))):Set(nCont)
				&("oMeter"+AllTrim(Str(nOpcao))):SetTotal(nRegTAIF)
				&("oSay"+AllTrim(Str(nOpcao + 9))):SetText(Left(cAlias,3))
				
				if nRegTAIF > 0
					while !TAIF->(Eof())
						cCam := aSX3[1][1]
						
						AAdd(aItm,{TAIF->&(aSX3[1][1])})
						
						if aSX3[1][2] == "C" .or. aSX3[1][2] == "D" .or. aSX3[1][2] == "L"
							cIns := "'"+RetiraAspas(TAIF->&(aSX3[1][1]))+"'"
						elseif aSX3[1][2] == "M"
							cIns := "'"+AllTrim(TAIF->&(aSX3[1][1]))+"'"
						elseif aSX3[1][2] == "N"
							cIns := AllTrim(Str(TAIF->&(aSX3[1][1])))
						endif
						
						for j := 2 to Len(aSX3)
							cCam += ","+aSX3[j][1]
							
							AAdd(aItm,{TAIF->&(aSX3[j][1])})
							
							if aSX3[j][2] == "C" .or. aSX3[j][2] == "D" .or. aSX3[j][2] == "L"
								cIns += ",'"+RetiraAspas(TAIF->&(aSX3[j][1]))+"'"
							elseif aSX3[j][2] == "M"
								cIns += ",'"+AllTrim(TAIF->&(aSX3[j][1]))+"'"
							elseif aSX3[j][2] == "N"
								cIns += ","+AllTrim(Str(TAIF->&(aSX3[j][1])))
							endif
						next
						
						cCon := "select max(R_E_C_N_O_) + 1 as NRECNO from [DADOSP11O].dbo."+cAlias
						
						tcquery cCon new alias "CONTMP"
						
						DbSelectArea("CONTMP")
						
						cRecno := AllTrim(Str(CONTMP->NRECNO))
						
						CONTMP->(DbCloseArea())
						
						cSql := "insert into [DADOSP11O].dbo."+cAlias+"("+cCam+",R_E_C_N_O_) values("+cIns+","+cRecno+")"
						
						if TCSqlExec(cSql) < 0
							AAdd(aRegistros,{cAlias,0})
							
							return Msg("TCSqlError() "+TCSqlError())
						endif
						
						nCont++
						
						&("oMeter"+AllTrim(Str(nOpcao))):Set(nCont)
						
						TAIF->(DbSkip())
					enddo
					
					AAdd(aRegistros,{cAlias,nCont})
					
					lConcluido := .T.
				else
					Msg("Nenhum registro encontrado para importacao!!!","Aviso")
					
					lConcluido := .F.
				endif
				
				TAIF->(DbCloseArea())
				
				cAlias := "" ; aSX3 := {} ; aCampos := {} ; cCondic := "" ; cTipo := "" ; cCondicao := "" ; cQry := ""
				cSelect := "" ; aMemo := {} ; cMemo := "" ; nCont := 0
			else
				lConcluido := .F.
				
				Msg("Tabela "+aTabelas[i]+" nao encontrada no cadastro de tabelas taif (SZT)!","Aviso")
			endif
		next
	endif
	
	SZT->(DbCloseArea())
	
	cMsg := ""
	
	for i := 1 to Len(aRegistros)
		cMsg += Chr(13)+Chr(10)+aRegistros[i][1]+" => "+AllTrim(Str(aRegistros[i][2]))
	next
	
	if lDocSeq
		cNumSD := ""
		
		for i := 1 to 3
			cQry += "select max(D"+AllTrim(Str(i))+"_NUMSEQ) as MAIOR from [DADOSP11O].dbo.SD"+AllTrim(Str(i))+"0"+AllTrim(Str(nCbo1))+"0 where D_E_L_E_T_ <> '*' "
			
			tcquery cQry new alias "TMPDOC"
			
			DbSelectArea("TMPDOC")
			
			if AllTrim(TMPDOC->MAIOR) >= cNumSD
				cNumSD := AllTrim(TMPDOC->MAIOR)
			endif
			
			TMPDOC->(DbCloseArea())
		next
		
		cMsg += Chr(13)+Chr(10)+"MV_DOCSEQ => "+AllTrim(cNumSD)
	endif
	
	&("oMeter"+AllTrim(Str(nOpcao))):Set(0)
	
	if lConcluido
		Msg("Importacao realizada com sucesso!"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+"Abaixo a quantidade de registro(s) importado: "+cMsg,"Aviso")
	endif
return

static function RetiraAspas(cTexto)
	local cTxt := ""
	
	for k := 1 to Len(cTexto)
		if SubStr(cTexto,k,1) == "'"
			cTxt += "''"
		else
			cTxt += SubStr(cTexto,k,1)
		endif
	next
return(cTxt)

static function VariavelCampo(cTabela)
	local aCam := {}
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cTabela)
	
	while !Eof() .and. X3_ARQUIVO == cTabela
		//if X3_CONTEXT <> "V" .and. X3Uso(X3_USADO)
		if X3_CONTEXT <> "V"
			AAdd(aCam,{Trim(X3_CAMPO),X3_TIPO})
		endif
		
		DbSkip()
	enddo
return(aCam)

static function OkTabMovimento(cGt1,cGt2,nCbo1)
	local aTabelas := {}
	
	if Empty(cGt1) .or. Empty(cGt2)
		return Msg("O periodo nao pode esta em branco!")
	endif
	
	if Len(aWBrowse1) > 0
		for i := 1 to Len(aWBrowse1)
			if aWBrowse1[i,1]
				AAdd(aTabelas,aWBrowse1[i,2])
			endif
		next
		
		Processa({|| Importar(3,aTabelas,nCbo1,cGt1,cGt2)},"Aguarde...","Processando a importacao...",.F.)
	else
		return Msg("Nao foram selecionado nenhuma tabela para importacao!","Aviso")
	endif
return

static function OkTabCadastro(nCbo1)
	local aTabelas := {}
	
	if Len(aWBrowse2) > 0
		for i := 1 to Len(aWBrowse2)
			if aWBrowse2[i,1]
				AAdd(aTabelas,aWBrowse2[i,2])
			endif
		next
		
		Processa({|| Importar(2,aTabelas,nCbo1)},"Aguarde...","Processando a importacao...",.F.)
	else
		return Msg("Nao foram selecionado nenhuma tabela para importacao!","Aviso")
	endif
return

static function OkResumido(cGt1,cGt2,nCbo1)
	local aTabelas := {}
	local cTabelas := ""
	local aTabCanc := {}
	local cTabCanc := ""
	Alert("1")
	Alert(cGt1)
	Alert(cGt2)
	if Empty(cGt1) .or. Empty(cGt2)
		return MsgStop("O periodo nao pode esta em branco!")
	endif
	
	if Len(aWBrowse3) > 0
		DbSelectArea("SZT")
		
		for i := 1 to Len(aWBrowse3)
			if aWBrowse3[i,1]
				if aWBrowse3[i,2] <> "999"
					SZT->(DbGoTop())
					
					if SZT->(DbSeek(xFilial("SZT")+aWBrowse3[i,2],.F.))
						cTabelas += "/"+AllTrim(SZT->ZT_CHAVE)
					endif
				else
					SZT->(DbGoTop())
					
					if SZT->(DbSeek(xFilial("SZT")+aWBrowse3[i,2],.F.))
						cTabCanc += "/"+AllTrim(SZT->ZT_CHAVE)
					endif
				endif
			endif
		next
		
		SZT->(DbCloseArea())
		
		aTabelas := StrTokArr(cTabelas,"/")
		aTabCanc := StrTokArr(cTabCanc,"/")
		
		if Len(aTabelas) > 0
			Processa({|| Importar(1,aTabelas,nCbo1,cGt1,cGt2)},"Aguarde...","Processando a importacao...",.F.)
		endif
		
		if Len(aTabCanc) > 0
//			MsgAlert("*** EM DESENVOLVIMENTO ***")
			Processa({|| Importar(1,aTabCanc,nCbo1,cGt1,cGt2,.T.)},"Aguarde...","Processando a importacao...",.F.)
		endif
	else
		return MsgAlert("Nao foram selecionado nenhuma tabela para importacao!")
	endif
return

static function FWBrowse1()
	local oOk := LoadBitmap(GetResources(),"LBOK")
	local oNo := LoadBitmap(GetResources(),"LBNO")
	
	DbSelectArea("SZT")
	SZT->(DbSetOrder(3))
	SZT->(DbSeek(xFilial("SZT")+_TIPO[2],.F.))
	
	while SZT->ZT_TIPO == _TIPO[2]
		AAdd(aWBrowse1,{.F.,SZT->ZT_TABELA,SZT->ZT_DESCRI})
		
		SZT->(DbSkip())
	enddo
	
	SZT->(DbCloseArea())
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{.F.,"",""})
	endif
	
	@001,001 listbox oWBrowse1 fields header "","TABELA","DESCRICAO" size 200,085 of oFolder1:aDialogs[3] pixel colsizes 50,30
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {If(aWBrowse1[oWBrowse1:nAt,1],oOk,oNo),aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3]}}
		// DoubleClick event
		oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],oWBrowse1:DrawSelect()}
return

static function FWBrowse2()
	local oOk := LoadBitmap(GetResources(),"LBOK")
	local oNo := LoadBitmap(GetResources(),"LBNO")
	
	DbSelectArea("SZT")
	SZT->(DbSetOrder(3))
	SZT->(DbSeek(xFilial("SZT")+_TIPO[1],.F.))
	
	while SZT->ZT_TIPO == _TIPO[1]
		AAdd(aWBrowse2,{.F.,SZT->ZT_TABELA,SZT->ZT_DESCRI})
		
		SZT->(DbSkip())
	enddo
	
	SZT->(DbCloseArea())
	
	if Len(aWBrowse2) <= 0
		AAdd(aWBrowse2,{.F.,"",""})
	endif
	
	@001,001 listbox oWBrowse2 fields header "","TABELA","DESCRICAO" size 200,085 of oFolder1:aDialogs[2] pixel colsizes 50,30
		oWBrowse2:SetArray(aWBrowse2)
		oWBrowse2:bLine := {|| {If(aWBrowse2[oWBrowse2:nAt,1],oOk,oNo),aWBrowse2[oWBrowse2:nAt,2],aWBrowse2[oWBrowse2:nAt,3]}}
		// DoubleClick event
		oWBrowse2:bLDblClick := {|| aWBrowse2[oWBrowse2:nAt,1] := !aWBrowse2[oWBrowse2:nAt,1],oWBrowse2:DrawSelect()}
return

static function FWBrowse3()
	local oOk := LoadBitmap(GetResources(),"LBOK")
	local oNo := LoadBitmap(GetResources(),"LBNO")
	
	DbSelectArea("SZT")
	SZT->(DbSetOrder(3))
	SZT->(DbSeek(xFilial("SZT")+_TIPO[3],.F.))
	
	while SZT->ZT_TIPO == _TIPO[3]
		AAdd(aWBrowse3,{.F.,SZT->ZT_TABELA,SZT->ZT_DESCRI})
		
		SZT->(DbSkip())
	enddo
	
	SZT->(DbCloseArea())
	
	if Len(aWBrowse3) <= 0
		AAdd(aWBrowse3,{.F.,"",""})
	endif
	alert("teste")
	@001,001 listbox oWBrowse3 fields header "","TABELA","DESCRICAO" size 200,085 of oFolder1:aDialogs[1] pixel colsizes 50,30
		oWBrowse3:SetArray(aWBrowse3)
		oWBrowse3:bLine := {|| {If(aWBrowse3[oWBrowse3:nAt,1],oOk,oNo),aWBrowse3[oWBrowse3:nAt,2],aWBrowse3[oWBrowse3:nAt,3]}}
		// DoubleClick event
		oWBrowse3:bLDblClick := {|| aWBrowse3[oWBrowse3:nAt,1] := !aWBrowse3[oWBrowse3:nAt,1],oWBrowse3:DrawSelect()}
return

static function Msg(cMsg,cTit,lEdt)
	local oButton1Msg
	local oGroup1Msg
	local oMultiGe1Msg
	local cMultiGe1Msg := cMsg
	
	static oDlgMsg
	
	default cTit := "Error"
	default lEdt := .F.
	
	define msdialog oDlgMsg title cTit from 000,000 to 295,500 colors 0,16777215 pixel
		@002,002 group oGroup1Msg to 128,247 of oDlgMsg color 0,16777215 pixel
		@006,003 get oMultiGe1Msg var cMultiGe1Msg of oDlgMsg multiline size 243,121 when lEdt colors 0,16777215 hscroll pixel
		@132,209 button oButton1Msg prompt "OK" size 037,012 of oDlgMsg action oDlgMsg:End() pixel
	activate msdialog oDlgMsg centered
return