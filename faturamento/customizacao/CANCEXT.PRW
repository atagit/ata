/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/01/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Refazer o saldo bancário                              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function CANCEXT()
	local oButton1, oSay1, oButton2, oComboBox1
	local nComboBox1 := "Sim"
	
	private oDlg
	
	define msdialog oDlg title "Canc. Extemporaneo" from 000,000 to 085,305 colors 0,16777215 pixel
		@003,004 say oSay1 prompt "Para ativar o cancelamento extemporaneo, configure abaixo:" size 152,007 of oDlg colors 0,16777215 pixel
		@012,004 mscombobox oComboBox1 var nComboBox1 items{"Sim","Nao"} size 072,010 of oDlg colors 0,16777215 pixel
		@026,071 button oButton1 prompt "Confirmar" size 037,012 of oDlg action Ativar(nComboBox1) pixel
		@026,110 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
	activate msdialog oDlg
return

static function Ativar(nComboBox1)
	if nComboBox1 == "Sim"
		PutMV("MV_SPEDEXC",720)		//em horas
		PutMV("MV_CANCEXT",30)		//em dias
	else
		PutMV("MV_SPEDEXC",24)		//em horas
		PutMV("MV_CANCEXT",1)		//em dias
	endif
	
	Close(oDlg)
return