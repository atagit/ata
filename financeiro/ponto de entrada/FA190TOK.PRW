/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/03/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar dados na juncao do cheque                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function FA190TOK()
	local lRet := .F.
	
	if !Empty(CCHEQUE190)
		lRet := U_VALCHQ(CBANCO190+CAGENCIA190+CCONTA190,CCHEQUE190)
	endif
return lRet