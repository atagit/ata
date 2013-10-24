/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Durante a gravacao de dados complementares tabela SE5 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function SE5FI080()
	if SE5->E5_TIPODOC == "VL" .and. SE5->E5_MOTBX == "DEB" .and. !Empty(_NumTED) .and. SE5->(E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_CLIFOR+E5_LOJA) == Left(_NumTED,23)
		RecLock("SE5",.F.)
			SE5->E5_DOCUMEN := "TED"+Right(_NumTED,6)
			SE5->E5_NATUREZ := "40103"
		SE5->(MsUnLock())
		
		_NumTED := ""
	endif
return