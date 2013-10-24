/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/10/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho para alterar a natureza do cliente            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function C5NATUREZ(cCliente,cLojaCli,cNatureza)
	local cAlias := alias()
	
	dbselectarea("SA1")
	
	if SA1->(dbseek(xFilial("SA1")+cCliente+cLojaCli,.F.))
		reclock("SA1",.F.)
			SA1->A1_NATUREZ := cNatureza
		msunlock()
	endif
	
	dbselectarea(cAlias)
return