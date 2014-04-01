/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 31/03/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. para validar produto                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function A010TOK()
	local lExecuta := .F.
	
	SAH->(DbGoTop())
	
	if SAH->(DbSeek(xFilial("SAH")+M->B1_UM,.F.))
		lExecuta := .T.
	else
		MsgAlert("A Unidade de Medida informada para esse produto nao existe.")
		
		lExecuta := .F.
	endif
return lExecuta