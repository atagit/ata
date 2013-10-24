/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho para retornar a loja automatico do cliente    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function A1COD(cCodigo)
	local cLoja := "01"
	local cAlias := "SA1"
	
	if (cAlias)->(MsSeek(xFilial(cAlias)+cCodigo,.F.))
		if (cAlias)->(MsSeek(xFilial(cAlias)+cCodigo,.T.,.T.))
			cLoja := StrZero(Val((cAlias)->A1_LOJA) + 1,2)
		endif
	endif
return(cLoja)