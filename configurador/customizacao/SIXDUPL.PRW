/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 16/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Excluir registros duplicados do SIX (migracao)        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function SIXDUPL()
	local oButton1, oButton2
	local oSay1, oSay2
	local oGroup1
	
	private oDlg
	private lAborta := .T.
	
	define msdialog oDlg title "SIX DUPLICADO" from 000,000 to 110,430 colors 0,16777215 pixel
		@003,004 group oGroup1 to 035,211 of oDlg color 0,16777215 pixel
		@010,008 say oSay1 prompt "Esta rotina tem como objetivo deletar todos os registros duplicados da tabela" size 199,007 of oDlg colors 0,16777215 pixel
		@019,008 say oSay2 prompt "SIX (indice), para evitar erros na hora da migracao de versao." size 199,007 of oDlg colors 0,16777215 pixel
		@038,133 button oButton1 prompt "OK" size 037,012 of oDlg action Processa({|| Deletar(oDlg)},"Aguarde...","Deletando registros duplicados...",.F.) pixel
		@038,173 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
	activate msdialog oDlg centered
return

static function Deletar(oDlg)
	local cIndice := ""
	local cChave := ""
	local cArq := AllTrim(GetSrvProfString("Startpath",""))+"SIX"+cEmpAnt+"0T.cdx"
	
	Close(oDlg)
	
	DbSelectArea("SIX")
	DBCreateIndex(cArq,"INDICE+CHAVE",{ || INDICE+CHAVE},.T.)
	DbSetIndex(cArq)
	DbGoTop()
	ProcRegua(RecCount())
	
	while !Eof()
		cIndice := INDICE
		cChave := CHAVE
		
		IncProc()
		DbSkip()
		
		while INDICE == cIndice .and. CHAVE == cChave
			RecLock("SIX",.F.)
				DbDelete()
			MsUnLock()
			
			IncProc()
			DbSkip()
		enddo
	enddo
	
	MsgInfo("Processo finalizado com sucesso.")
return