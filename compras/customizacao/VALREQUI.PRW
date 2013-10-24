/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 25/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Valida requisicao de aquisicao de servico             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
user function VALREQUI()
	local lRet := .F.
	
	if Left(M->C7_PRODUTO,3) == "SER" .and. Empty(M->C7_REQUISI)
		Help("","","NAOVAZIO",,"Para pedido de compra de SERVICO tem que selecionar os Requisitos de Aquisicao.",1,0)
	else
		lRet := .T.
	endif
return (lRet)