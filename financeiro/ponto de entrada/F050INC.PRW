/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Após a inclusão do titulo no contas a pagar           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function F050INC()
	local cNumTED := ""
	
	if SE2->E2_TIPO == "PA " .and. Left(SE2->E2_NUMBCO,3) == "TED"
		if SA6->(DbSeek(xFilial("SA6")+CBANCOADT+CAGENCIAADT+CNUMCON,.F.))
			cNumTED := Right(AllTrim(SE2->E2_NUMBCO),6)
			
			RecLock("SA6",.F.)
				SA6->A6_NUMTED := StrZero(Val(cNumTED) + 1,6)
			MsUnLock()
		endif
	endif
return