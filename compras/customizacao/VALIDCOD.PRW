/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/06/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar Desbloqueio dos produtos                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function VALIDBLOQ(cProd,cBloq)
	local lRet := .T.
	
	if cBloq <> "1" .and. Len(AllTrim(cProd)) <> 6
		Alert(AllTrim(cProd)+": Produto nao pode ser desbloqueado por esta com o CODIGO fora do padrão de cadastro (3 letras e 3 numeros).")
		
		M->B1_MSBLQL := "1"
		lRet := .F.
	endif
return(lRet)