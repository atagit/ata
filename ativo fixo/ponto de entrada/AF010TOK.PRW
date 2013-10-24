/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 04/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar numero da plaqueta                            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function AF010TOK()
	local aArea := GetArea()
	local cMensagem := ""
	local lRet := .T.
	local cChapa := AllTrim(M->N1_CHAPA)
	
	if !Empty(cChapa)
		if Len(cChapa) <> 5
			cMensagem := "Numero da Plaqueta nao esta no padrao de digitos."
			
			lRet := .F.
		endif
	endif
	
	if !Empty(cMensagem)
		Help("ATFA010",1,"HELP","VALCHAPA",cMensagem,1,0)
	endif
	
	RestArea(aArea)
	SN1->(DbSetOrder(1))
return lRet