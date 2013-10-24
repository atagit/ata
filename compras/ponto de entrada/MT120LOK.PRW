/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 25/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. validacao das linhas getdados                    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MT120LOK()
	local lRet := .F.
	local _nPosProd := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C7_PRODUTO"})
	local _nPosResq := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C7_REQUISI"})
	
	if Left(aCols[n][_nPosProd],3) == "SER" .and. Empty(aCols[n][_nPosResq])
		Help("","","NAOVAZIO",,"Para pedido de compra de SERVICO tem que selecionar os Requisitos de Aquisicao.",1,0)
	else
		lRet := .T.
	endif
return(lRet)