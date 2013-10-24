/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 16/05/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validacao do e-mail                                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"

user function VALIDEMAIL(cEmail)
	local lRet := .T.
	local cEmail := AllTrim(cEmail)
	
/*	static oDlg
	static oButton1
	static oGet1
	static cGet1 := Space(50)
	static oGroup1
	
	define msdialog oDlg title "Validar E-mail" from 000,000 to 085,465 colors 0,16777215 pixel
		@002,002 group oGroup1 to 024,228 prompt " E-MAIL " of oDlg color 0,16777215 pixel
		@010,006 msget oGet1 var cGet1 size 217,010 of oDlg colors 0,16777215 pixel
		@026,191 button oButton1 prompt "Validar" size 037,012 of oDlg action ValidEmail(AllTrim(cGet1)) pixel
	activate msdialog oDlg*/
	
	if !Empty(cEmail) .and. !IsEmail(cEmail)
		MsgAlert("A conta de e-mail nao foi digitada corretamente, favor conferir!")
		
		lRet := .F.
	endif
return(lRet)