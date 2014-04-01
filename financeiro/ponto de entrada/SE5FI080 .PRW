/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Durante a gravacao de dados complementares tabela SE5 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function SE5FI080()
	local aAreaAnt := GetArea()
	
	if SE5->E5_TIPODOC == "VL" .and. SE5->E5_MOTBX == "DEB" .and. !Empty(__NumTED) .and. SE5->(E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_CLIFOR+E5_LOJA) == Left(__NumTED,23)
		RecLock("SE5",.F.)
//			SE5->E5_DOCUMEN := "TED"+Right(__NumTED,6)
			SE5->E5_NUMTED := Right(__NumTED,6)
			SE5->E5_NATUREZ := "40103"
		MsUnLock()
		
		__NumTED := ""
	elseif SE5->E5_TIPODOC == "PA" .and. SE5->E5_MOTBX == "NOR" .and. Left(SE5->E5_NUMCHEQ,3) == "TED"
		RecLock("SE5",.F.)
			SE5->E5_NUMTED := Right(AllTrim(SE5->E5_NUMCHEQ),6)
		MsUnLock()
	endif
	
	RestArea(aAreaAnt)
return