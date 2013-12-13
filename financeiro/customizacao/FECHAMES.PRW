/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/12/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Parametros para fechar movimentacoes do mes           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function FECHAMES()
	local oButton1, oButton2
	local oGet1, oGroup1
	local oSay1, oSay2, oSay3
	local cGet1 := GetMV("MV_DATAFIN")
	local cGet2 := GetMV("MV_BXDTFIN")
	
	private oDlg
	
	define msdialog oDlg title "Fechar Mes" from 000,000 to 175,460 colors 0,16777215 pixel
		@003,004 group oGroup1 to 067,225 of oDlg color 0,16777215 pixel
		@010,008 say oSay1 prompt "ATENCAO: Nao podera realizar movimentacoes com data anterior a data de fechamento" size 214,007 of oDlg colors 0,16777215 pixel
		@019,008 say oSay2 prompt "informada abaixo." size 214,007 of oDlg colors 0,16777215 pixel
		@042,008 say oSay3 prompt "Data Fechamento" size 047,007 of oDlg colors 0,16777215 pixel
		@050,008 msget oGet1 var cGet1 size 043,010 of oDlg colors 0,16777215 pixel
		
		@069,148 button oButton1 prompt "OK" size 037,012 of oDlg action Gravar(cGet1) pixel
		@069,187 button oButton2 prompt "Cancel" size 037,012 of oDlg action Close(oDlg) pixel
	activate msdialog oDlg
return

static function Gravar(dFechamento)
	PutMV("MV_DATAFIN",dFechamento)
	PutMV("MV_BXDTFIN","2")
	MsgAlert("Movimentacoes fechado ate a data informada.")
	Close(oDlg)
return