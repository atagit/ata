/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 30/01/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Acertar codigo do balancete no lançamento             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#define _CAMPOSC {{"SF1->F1_DOC","SF1->F1_SERIE","SF1->F1_FORNECE","SF1->F1_LOJA","SF1->F1_EMISSAO","SF1->F1_TIPO"},;
				  {"SF2->F2_DOC","SF2->F2_SERIE","SF2->F2_CLIENTE","SF2->F2_LOJA","SF2->F2_EMISSAO","SF2->F2_TIPO"}}
#define _CAMPOSI {{"E2_NUM","E2_PREFIXO","E2_FORNECE","E2_LOJA","E2_BALGER"},;
				  {"D2_ITEM","D2_CONTA","D2_TES","D2_CLVL","","","D2_DOC","D2_SERIE","D2_CLIENTE","D2_LOJA"}}
//#define _EXIBIR  {"D1_ITEM/D1_COD/D1_UM/D1_QUANT/D1_VUNIT/D1_TOTAL/D1_TES/D1_CLVL/D1_CONTA","D2_ITEM/D2_COD/D2_UM/D2_QUANT/D2_PRCVEN/D2_TOTAL/D2_TES/D2_CLVL/D2_CONTA"}
#define _EXIBIR  {"E2_NUM/E2_PREFIXO/E2_FORNECE/E2_LOJA/E2_BALGER"}

user function ACERTABG()
	local oDlg
	local oButton1
	local oButton2
	local oGroup1
	local oSay1
	local oSay2
	
	define msdialog oDlg title "ACERTAR CODIGO BALANCETE" from 000,000 to 350,600 colors 0,16777215 pixel
		@002,002 group oGroup1 to 151,296 of oDlg color 0,16777215 pixel
		@011,006 say oSay1 prompt "Esta rotina tem como objetivo acertar o codigo do balancete gerencial dos lancamentos nas rotinas: Contas a Pagar" size 286,007 of oDlg colors 0,16777215 pixel
		@020,006 say oSay2 prompt "Contas a Receber e Movimentacao Bancaria." size 286,007 of oDlg colors 0,16777215 pixel
		@156,259 button oButton1 prompt "&Fechar" size 037,012 of oDlg action Close(oDlg) pixel
		@156,219 button oButton2 prompt "&Avancar" size 037,012 of oDlg action Tela2(oDlg) pixel
	activate msdialog oDlg center
return

static function Tela2(oDlg)
	local oDlg1
	local oButton1
	local oButton2
	local oButton3
	local oComboBox1
	local nComboBox1 := 1
	local oGet2
	local dGet2 := CToD("")
	local oGet3
	local dGet3 := CToD("")
	local oGroup1
	local oSay1
	local oSay2
	local oSay3
	
	Close(oDlg)
	
	define msdialog oDlg1 title "ACERTAR CODIGO BALANCETE" from 000,000 to 350,600 colors 0,16777215 pixel
		@002,002 group oGroup1 to 151,296 prompt " PARAMETROS " of oDlg1 color 0,16777215 pixel
		@012,037 mscombobox oComboBox1 var nComboBox1 items {"1- A Pagar","2- A Receber","3- Movimto Bancaria"} size 091,010 of oDlg1 colors 0,16777215 pixel
		@013,006 say oSay1 prompt "Rotina" size 032,007 of oDlg1 colors 0,16777215 pixel
		@027,006 say oSay2 prompt "Periodo de" size 032,007 of oDlg1 colors 0,16777215 pixel
		@039,006 say oSay3 prompt "Periodo ate" size 032,007 of oDlg1 colors 0,16777215 pixel
		@025,037 msget oGet2 var dGet2 size 060,010 of oDlg1 colors 0,16777215 pixel
		@037,037 msget oGet3 var dGet3 size 060,010 of oDlg1 colors 0,16777215 pixel
		@156,259 button obutton1 prompt "&Fechar" size 037,012 of oDlg1 action Close(oDlg1) pixel
		@156,219 button obutton2 prompt "&Avancar" size 037,012 of oDlg1 action TelaGrid(oDlg1,nComboBox1,DToS(dGet2),DToS(dGet3)) pixel
	activate msdialog oDlg1 center
return

static function TelaGrid(oDlg1,nOpc,cDtIni,cDtFin)
	local oDlg2
	local nI
	local oGetDados
	local oButton, oGroup, oGet
	local nUsado := 0
	local cTit := ""
	local cAliasC := "SE2"
	local cAliasI := "SE2"
	
	Close(oDlg1)
	
//	private cDoc := &(_CAMPOSC[nOpc][1])
// 	private cSer := &(_CAMPOSC[nOpc][2])
// 	private cForCli := &(_CAMPOSC[nOpc][3])
// 	private cLoj := &(_CAMPOSC[nOpc][4])
// 	private dEmissao := &(_CAMPOSC[nOpc][5])
// 	private cTipo := &(_CAMPOSC[nOpc][6])
 	private nLin := 0
	private lRefresh := .T.
	private aHeader := {}
	private aCols := {}
	private aRotina := {{"Pesquisar","AxPesqui",0,1}}
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(cAliasI)
	
	while !Eof() .and. SX3->X3_ARQUIVO == cAliasI
		if AllTrim(SX3->X3_CAMPO) $ _EXIBIR[nOpc]
			if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado++
				
				AAdd(aHeader,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,"",SX3->X3_TIPO,"",""})
			endif
		endif
		
		DbSkip()
	enddo
	
	DbSelectArea(cAliasI)
	DbSetOrder(7)
	DbGoTop()
	DbSeek(xFilial("SE2")+cDtIni)
	
	while !Eof() .and. E2_EMIS1 >= cDtIni .and. E2_EMIS1 <= cDtFin
		alert(aHeader[i,2])
/*		if Empty(&(cAliasI+"->"+_CAMPOSI[nOpc][5]))
			AAdd(aCols,Array(nUsado + 1))
			
			for i := 1 to nUsado
				aCols[Len(aCols),i] := FieldGet(FieldPos(aHeader[i,2]))
			next
			
			aCols[Len(aCols),nUsado + 1] := .F.
			nLin++
		endif*/
		
		DbSkip()
	enddo
	
	define msdialog oDlg2 title "Acerto do Codigo do Balancete" from 000,000 to 265,700 colors 0,16777215 pixel
//		@004,003 group oGroup1 to 044,346 prompt " Dados " of oDlg1 color 0,16777215 pixel
//		@014,008 say oSay1 prompt "Nota Fiscal" size 030,007 of oDlg1 colors 0,16777215 pixel
//		@011,041 msget oGet1 var cDoc size 060,010 of oDlg1 when Empty(cDoc) colors 0,16777215 pixel
//		@014,110 say oSay2 prompt "Serie" size 017,007 of oDlg1 colors 0,16777215 pixel
//		@011,128 msget oGet2 var cSer size 020,010 of oDlg1 when Empty(cSer) colors 0,16777215 pixel
//		@014,159 say oSay3 prompt "Emissao" size 025,007 of oDlg1 colors 0,16777215 pixel
//		@011,183 msget oGet3 var„ dEmissao size 043,010 of oDlg1 when Empty(dEmissao) colors 0,16777215 pixel
//		@030,008 say oSay4 prompt AllTrim(cTit) size 032,007 of oDlg1 colors 0,16777215 pixel
//		@027,041 msget oGet4 var cFor size 042,010 of oDlg1 when Empty(cFor) colors 0,16777215 pixel
//		@027,087 msget oGet5 var cDes size 254,010 of oDlg1 when Empty(cDes) colors 0,16777215 pixel
		
		oGetDados := MsGetDados():New(045,003,112,346,4,,,"+"+_CAMPOSI[nOpc][1],.F.,{_CAMPOSI[nOpc][5]},,.F.,nLin,,,,,oDlg2)
		
		@116,267 button oButton1 prompt "OK" size 037,012 of oDlg2 action Acertar(nOpc,cAliasI) pixel
		@116,307 button oButton2 prompt "Cancelar" size 037,012 of oDlg2 action Close(oDlg2) pixel
	activate msdialog oDlg2 centered
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