/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 15/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Excluir registros duplicados do SX7 (migracao)        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function SX7DUPL()
	local oButton1, oButton2
	local oSay1, oSay2
	local oGroup1
	
	private oDlg
	private lAborta := .T.
	
	define msdialog oDlg title "SX7 DUPLICADO" from 000,000 to 110,430 colors 0,16777215 pixel
		@003,004 group oGroup1 to 035,211 of oDlg color 0,16777215 pixel
		@010,008 say oSay1 prompt "Esta rotina tem como objetivo deletar todos os registros duplicados da tabela" size 199,007 of oDlg colors 0,16777215 pixel
		@019,008 say oSay2 prompt "SX7, para evitar erros na hora da migracao de versao." size 199,007 of oDlg colors 0,16777215 pixel
		@038,133 button oButton1 prompt "OK" size 037,012 of oDlg action Processa({|| Deletar(oDlg)},"Aguarde...","Deletando registros duplicados...",.F.) pixel
		@038,173 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
	activate msdialog oDlg centered
return

static function Deletar(oDlg)
	local cCampo := ""
	local cSequencia := ""
	
	Close(oDlg)
	
	DbSelectArea("SX7")
	DbSetOrder(1)
	DbGoTop()
	ProcRegua(RecCount())
	
	while !Eof()
		cCampo := X7_CAMPO
		cSequencia := X7_SEQUENC
		
		IncProc()
		DbSkip()
		
		while X7_CAMPO == cCampo .and. X7_SEQUENC == cSequencia
			RecLock("SX7",.F.)
				DbDelete()
			MsUnLock()
			
			IncProc()
			DbSkip()
		enddo
	enddo
	
	MsgInfo("Processo finalizado com sucesso.")
return