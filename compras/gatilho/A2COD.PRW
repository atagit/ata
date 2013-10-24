/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho para retornar a loja automatico do fornecedor ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function A2COD(cCodigo)
	local cLoja := "01"
	local cAlias := "SA2"
	
	if (cAlias)->(MsSeek(xFilial(cAlias)+cCodigo,.F.))
		if (cAlias)->(MsSeek(xFilial(cAlias)+cCodigo,.T.,.T.))
			cLoja := StrZero(Val((cAlias)->A2_LOJA) + 1,2)
		endif
	endif
return(cLoja)