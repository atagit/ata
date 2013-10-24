/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/12/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Acertar conta contábil do lançamento da nota fiscal   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#define _CAMPOSC {{"SF1->F1_DOC","SF1->F1_SERIE","SF1->F1_FORNECE","SF1->F1_LOJA","SF1->F1_EMISSAO","SF1->F1_TIPO"},;
				  {"SF2->F2_DOC","SF2->F2_SERIE","SF2->F2_CLIENTE","SF2->F2_LOJA","SF2->F2_EMISSAO","SF2->F2_TIPO"}}
#define _CAMPOSI {{"D1_ITEM","D1_CONTA","D1_TES","D1_CLVL","D1_OPER","D1_DESCPRO","D1_DOC","D1_SERIE","D1_FORNECE","D1_LOJA"},;
				  {"D2_ITEM","D2_CONTA","D2_TES","D2_CLVL","","","D2_DOC","D2_SERIE","D2_CLIENTE","D2_LOJA"}}
#define _EXIBIR  {"D1_ITEM/D1_COD/D1_UM/D1_QUANT/D1_VUNIT/D1_TOTAL/D1_TES/D1_CLVL/D1_CONTA","D2_ITEM/D2_COD/D2_UM/D2_QUANT/D2_PRCVEN/D2_TOTAL/D2_TES/D2_CLVL/D2_CONTA"}

user function ACERTACC()
	local oButton1, oButton2
	local oSay1, oSay2
	local oComboBo1
	local cComboBo1 := ""
	local oGroup1
	
	private oDlg
	private lAborta := .T.
	
	define msdialog oDlg title "ACERTAR CONTA CONTABIL" from 000,000 to 110,430 colors 0,16777215 pixel
		@003,004 group oGroup1 to 035,211 of oDlg color 0,16777215 pixel
		@010,008 say oSay1 prompt "Esta rotina tem como objetivo acertar a conta contabil de alguma nota fiscal" size 199,007 of oDlg colors 0,16777215 pixel
		@019,008 say oSay2 prompt "de entrada/saida, cuja necessidade fiscal." size 199,007 of oDlg colors 0,16777215 pixel
		@038,133 button oButton1 prompt "OK" size 037,012 of oDlg action Tela(cComboBo1) pixel
		@038,173 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
		@039,004 mscombobox oComboBo1 var cComboBo1 items {"1- NF Entrada","2- NF Saida"} size 105,010 of oDlg colors 0,16777215 pixel
	activate msdialog oDlg centered
return

static function Tela(cOpc)
	private cCadastro := "Acertar CC"
	private cString := If(Left(cOpc,1) == "1","SF1","SF2")
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar",If(Left(cOpc,1) == "1","A103NFiscal","MC090Visual"),0,2},;
						{"Acerta CC","U_ACERCC1('"+cOpc+"')",0,3}}
	
	DbSelectArea(cString)
	DbSetOrder(1)
	
	Close(oDlg)
	MBrowse(06,01,22,75,cString)
return

user function ACERCC1(cOpc)
	local nI
	local oGetDados
	local oButton, oGroup, oGet
	local nUsado := 0
	local cTit := ""
	local nOpc := Val(Left(cOpc,1))
	local cAliasC := If(nOpc == 1,"SF1","SF2")
	local cAliasI := If(nOpc == 1,"SD1","SD2")
	
	private cDoc := &(_CAMPOSC[nOpc][1])
 	private cSer := &(_CAMPOSC[nOpc][2])
 	private cForCli := &(_CAMPOSC[nOpc][3])
 	private cLoj := &(_CAMPOSC[nOpc][4])
 	private dEmissao := &(_CAMPOSC[nOpc][5])
 	private cTipo := &(_CAMPOSC[nOpc][6])
 	private nLin := 0
 	private oDlg1
	private lRefresh := .T.
	private aHeader := {}
	private aCols := {}
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5}}
	
	DbSelectArea(cAliasC)
	DbSetOrder(1)
	DbGoTop()
	DbSeek(xFilial(cAliasC)+cDoc+cSer+cForCli+cLoj)
	
//	if Empty(SF1->F1_DTLANC)
		do case
			case cAliasC == "SF1"
				if cTipo $ "B/D"
					cTit := " Cliente "
					cDes := If(SA1->(DbSeek(xFilial("SA1")+cForCli+cLoj,.F.)),SA1->A1_NOME,"NAO ENCONTRADO")
				else
					cTit := " Fornecedor "
					cDes := If(SA2->(DbSeek(xFilial("SA2")+cForCli+cLoj,.F.)),SA2->A2_NOME,"NAO ENCONTRADO")
				endif
			case cAliasC == "SF2"
				if cTipo $ "B/D"
					cTit := " Fornecedor "
					cDes := If(SA2->(DbSeek(xFilial("SA2")+cForCli+cLoj,.F.)),SA2->A2_NOME,"NAO ENCONTRADO")
				else
					cTit := " Cliente "
					cDes := If(SA1->(DbSeek(xFilial("SA1")+cForCli+cLoj,.F.)),SA1->A1_NOME,"NAO ENCONTRADO")
				endif
		endcase
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbGoTop()
		DbSeek(cAliasI)
		
		while !Eof() .and. SX3->X3_ARQUIVO == cAliasI
			if AllTrim(SX3->X3_CAMPO) $ _EXIBIR[nOpc] .or. AllTrim(SX3->X3_CAMPO) == _CAMPOSI[nOpc][6] .or. AllTrim(SX3->X3_CAMPO) == _CAMPOSI[nOpc][5]
				if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
					nUsado++
					
					AAdd(aHeader,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,"",SX3->X3_TIPO,"",""})
				endif
			endif
			
			DbSkip()
		enddo
		
		DbSelectArea(cAliasI)
		DbSetOrder(If(cAliasI == "SD1",1,3))
		DbGoTop()
		DbSeek(xFilial(cAliasI)+cDoc+cSer+cForCli+cLoj)
		
		while !Eof() .and. &(cAliasI+"->"+_CAMPOSI[nOpc][7]) == cDoc .and. &(cAliasI+"->"+_CAMPOSI[nOpc][8]) == cSer .and. &(cAliasI+"->"+_CAMPOSI[nOpc][9]) == cForCli .and. &(cAliasI+"->"+_CAMPOSI[nOpc][10]) = cLoj
			AAdd(aCols,Array(nUsado + 1))
			
			for i := 1 to nUsado
				aCols[Len(aCols),i] := FieldGet(FieldPos(aHeader[i,2]))
			next
			
			aCols[Len(aCols),nUsado + 1] := .F.
			nLin++
			
			DbSkip()
		enddo
		
		cFor := cForCli+cLoj
		
		define msdialog oDlg1 title "Acerto da Conta Contabil" from 000,000 to 265,700 colors 0,16777215 pixel
			@004,003 group oGroup1 to 044,346 prompt " Dados " of oDlg1 color 0,16777215 pixel
			@014,008 say oSay1 prompt "Nota Fiscal" size 030,007 of oDlg1 colors 0,16777215 pixel
			@011,041 msget oGet1 var cDoc size 060,010 of oDlg1 when Empty(cDoc) colors 0,16777215 pixel
			@014,110 say oSay2 prompt "Serie" size 017,007 of oDlg1 colors 0,16777215 pixel
			@011,128 msget oGet2 var cSer size 020,010 of oDlg1 when Empty(cSer) colors 0,16777215 pixel
			@014,159 say oSay3 prompt "Emissao" size 025,007 of oDlg1 colors 0,16777215 pixel
			@011,183 msget oGet3 var dEmissao size 043,010 of oDlg1 when Empty(dEmissao) colors 0,16777215 pixel
			@030,008 say oSay4 prompt AllTrim(cTit) size 032,007 of oDlg1 colors 0,16777215 pixel
			@027,041 msget oGet4 var cFor size 042,010 of oDlg1 when Empty(cFor) colors 0,16777215 pixel
			@027,087 msget oGet5 var cDes size 254,010 of oDlg1 when Empty(cDes) colors 0,16777215 pixel
			
			oGetDados := MsGetDados():New(045,003,112,346,4,,,"+"+_CAMPOSI[nOpc][1],.F.,{_CAMPOSI[nOpc][2]},,.F.,nLin,,,,,oDlg1)
			
			@116,267 button oButton1 prompt "OK" size 037,012 of oDlg1 action Acertar(nOpc,cAliasI) pixel
			@116,307 button oButton2 prompt "Cancelar" size 037,012 of oDlg1 action Close(oDlg1) pixel
		activate msdialog oDlg1 centered
//	else
//		MsgBox("Nota Fiscal ja contabilizada! ","Alerta","ALERT")
//	endif
return

static function Acertar(nOpc,cAliasI)
	nPosItem := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == _CAMPOSI[nOpc][1]})
	nPosConta := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == _CAMPOSI[nOpc][2]})
	
	for i := 1 to nLin
		cUpd := "update "+RetSqlName(cAliasI)+" set "+_CAMPOSI[nOpc][2]+" = '"+aCols[i][nPosConta]+"' where "+_CAMPOSI[nOpc][7]+" = '"+cDoc+"' and "+_CAMPOSI[nOpc][8]+" = '"+cSer+"' and "+_CAMPOSI[nOpc][9]+" = '"+cForCli+"' and "+_CAMPOSI[nOpc][10]+" = '"+cLoj+"' and "+_CAMPOSI[nOpc][1]+" = '"+aCols[i][nPosItem]+"'"
		nRet := TCSqlExec(cUpd)
	next
	
	oDlg1:End()
return