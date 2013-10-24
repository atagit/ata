/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 06/02/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gravar o "bom para" no cheque                         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function BOMPARA()
	local oDlg, oButton1, oButton2, oCheckBox1
	local oGet1, oSay1, oSay2, oGroup1
	local lCheckBox1 := .F.
	local dGet1 := CToD("")
	local lValid := .T.
	local aArea := GetArea()
	
	if !Empty(SEF->EF_TIPO) .and. lValid
		lValid := .F.
		
		MsgInfo("Esse registro nao e o cheque aglutinado.")
	endif
	
	if SEF->EF_IMPRESS == "S" .and. lValid
		lValid := .F.
		
		MsgInfo("Esse cheque ja foi impresso.")
	endif
	
	if SEF->EF_IMPRESS == "C" .and. lValid
		lValid := .F.
		
		MsgInfo("Esse cheque esta cancelado.")
	endif
	
	cQry := "select E5_RECONC "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where E5_NUMCHEQ = '"+SEF->EF_NUM+"' and E5_TIPODOC = 'CH' and E5_TIPO = '' and D_E_L_E_T_ <> '*'"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if !Empty(TEMP->E5_RECONC) .and. lValid
			lValid := .F.
			
			MsgInfo("Esse cheque esta conciliado.")
		endif
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	RestArea(aArea)
	
	if lValid
		lValidCheck := SEF->EF_PREDATA
		lCheckBox1 := SEF->EF_PREDATA
		dGet1 := SEF->EF_DTPREDA
		
		define msdialog oDlg title OemToAnsi("BOM PARA") from 000,000 to 115,190 colors 0,16777215 pixel
			@003,003 group oGroup1 to 040,095 of oDlg color 0,16777215 pixel
			@025,008 say oSay1 prompt "Bom para" size 025,007 of oDlg colors 0,16777215 pixel
			@012,040 checkbox oCheckBox1 var lCheckBox1 size 009,008 when !lValidCheck of oDlg colors 0,16777215 pixel
			@013,008 say oSay2 prompt "Predatado" size 025,007 of oDlg colors 0,16777215 pixel
			@023,040 msget oGet1 var dGet1 size 044,010 when !lValidCheck of oDlg colors 0,16777215 pixel
			@043,019 button oButton1 prompt "&OK" size 037,012 when !lValidCheck of oDlg action Gravar(oDlg,lCheckBox1,dGet1) pixel
			@043,058 button oButton2 prompt "&Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
		activate msdialog oDlg center
	endif
return

static function Gravar(oDlg,lCheckBox1,dGet1)
	Close(oDlg)
	
	if RecLock("SEF",.F.)
		SEF->EF_PREDATA := lCheckBox1
		
		if !Empty(dGet1)
			SEF->EF_DTPREDA := dGet1
		endif
		
		MsUnLock()
	endif
return