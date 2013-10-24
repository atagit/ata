/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/05/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse cadastro de tabelas TAIF                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

#define _MAXMEMO 1000

user function C_SZT()
	private cCadastro := "Tabelas TAIF"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5},;
						{"Script","U_SZTScript()",0,6}}
	
	DbSelectArea("SZT")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZT")
return

user function SZTScript()
	cTabela := SZT->ZT_TABELA
	cCondicao := ""
	cCondic := ""
	cSelect := ""
	cMemo := ""
	
	if SZT->(DbSeek(xFilial("SZT")+cTabela,.F.))
		aSX3 := VariavelCampo(cTabela)
		aCampos := StrTokArr(SZT->ZT_CHAVE,"+")
		//aCondicao := StrTokArr(SZT->ZT_CONDIC,"+")
		cCondic := AllTrim(SZT->ZT_CONDIC)
		aMemo := StrTokArr(SZT->ZT_MEMO,"+")
		cTipo := SZT->ZT_TIPO
		
		if cTipo == 'G'
			MsgAlert("Tabela "+cTabela+" nao possui script por ser tratar de um grupo!")
			
			break
		endif
		
		if !Empty(aCampos[1])
			for j := 1 to Len(aCampos)
				cCondicao += "PRO."+AllTrim(aCampos[j])+" = OFI."+AllTrim(aCampos[j])+" and "
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
		cQry := "SCRIPT para Visualizacao"+Chr(13)+Chr(10)
		cQry += "--------------------"+Chr(13)+Chr(10)
		cQry += "select "+AllTrim(cSelect)+"OFI."+aCampos[1]+" as OFIC "+Chr(13)+Chr(10)
		cQry += "from [DADOSP11P].dbo."+RetSqlName(cTabela)+" PRO left join [DADOSP11O].dbo."+RetSqlName(cTabela)+" OFI on ("+AllTrim(cCondicao)+") "+Chr(13)+Chr(10)
		
/*		if cTipo == "C"
			cQry += "where PRO.D_E_L_E_T_ <> '*' and OFI."+aCampos[1]+" is null"
		elseif cTipo == "M"
			if Len(aCondicao) == 2
				cQry += "where (PRO."+aCondicao[1]+" between '"+DToS(Date())+"' and '"+DToS(Date())+"') and PRO."+aCondicao[2]+" not like '%X%' and PRO."+aCondicao[2]+" not like '%Z%' and PRO.D_E_L_E_T_ <> '*' and OFI."+aCampos[1]+" is null"
			else
				cQry += "where (PRO."+aCondicao[1]+" between '"+DToS(Date())+"' and '"+DToS(Date())+"') and PRO.D_E_L_E_T_ <> '*' and OFI."+aCampos[1]+" is null"
			endif
		endif*/
		
		cCaract := "" ; cResult := ""
		
		if !Empty(AllTrim(cCondic))
			for j := 1 to Len(cCondic)
				cCaract := SubStr(cCondic,j,1)
				
				do case
					case cCaract == "$"
						j++
						
						do case
							case cCaract+SubStr(cCondic,j,1) == "$1"
								cResult += DToS(Date())
							case cCaract+SubStr(cCondic,j,1) == "$2"
								cResult += DToS(Date())
						endcase
					case cCaract == "!"
						cResult += "OFI"
					case cCaract == "?"
						cResult += "PRO"
					otherwise
						cResult += cCaract
				endcase
			next
			
			cQry += "where "+cResult+" and OFI."+aCampos[1]+" is null and PRO.D_E_L_E_T_ <> '*'"
		else
			cQry += "where OFI."+aCampos[1]+" is null and PRO.D_E_L_E_T_ <> '*'"
		endif
	else
		MsgAlert("Tabela "+cTabela+" nao encontrada no cadastro de tabelas taif (SZT)!")
	endif
	
	TelaScript(cQry)
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
		if X3_CONTEXT <> "V"
			AAdd(aCam,{Trim(X3_CAMPO),X3_TIPO})
		endif
		
		DbSkip()
	enddo
return(aCam)

static function TelaScript(cTexto)
	local oMultiGe1
	local cMultiGe1 := cTexto
	local oSButton1
	local oSButton2
	
	static oDlg
	
	define msdialog oDlg title "SCRIPT" from 000,000 to 375,450 colors 0,16777215 pixel
		@003,003 get oMultiGe1 var cMultiGe1 of oDlg multiline size 218,166 colors 0,16777215 hscroll pixel
		
		define sbutton oSButton1 from 172,163 type 13 of oDlg onstop "Salvar arquivo texto com o script" enable action Salvar(cTexto)
		define sbutton oSButton2 from 172,194 type 01 of oDlg onstop "Fechar janela" enable action Close(oDlg)
	activate msdialog oDlg centered
return

static function Salvar(cTxt)
	local cArq
	local nHdl
	
	cArq := GetClientDir()+"scripttaf.txt"
	nHdl := FCreate(cArq)
	
	if nHdl == -1
		return MsgAlert("O arquivo "+cArq+" nao pode ser criado!","Atencao!")
	endif
	
	if FWrite(nHdl,cTxt,Len(cTxt)) <> Len(cTxt)
		if !MsgAlert("Ocorreu um erro na gravacao do arquivo.","Atencao!")
			return
		endif
	endif
	
	FClose(nHdl)
	MsgInfo("Arquivo TXT gerado ("+AllTrim(cArq)+")!")
return