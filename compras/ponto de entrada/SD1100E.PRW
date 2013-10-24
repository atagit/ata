/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 25/02/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Antes de exluir SD1, atualizar campos                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function SD1100E()
	cQry := "update "+RetSqlName("SZU")+" set ZU_USADO = 'E' "
	cQry += "where ZU_NUMCR = '"+AllTrim(SD1->D1_CR)+"' and D_E_L_E_T_ <> '*' "
	
	nRet := TCSqlExec(cQry)
return