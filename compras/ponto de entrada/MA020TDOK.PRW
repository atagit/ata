/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 19/04/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Ao confirmar a inclusao e alteracao do fornecedor     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
user function MA020TDOK()
	local lRet := .F.
	
	if M->A2_MSBLQL == "1" .and. Empty(M->A2_OBSBLOQ)
		Help("","","NAOVAZIO",,"Para bloquear o fornecedor e obrigatorio explicar o motivo."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+"OBS Bloqueio -> Primeira pasta",1,0)
	else
		lRet := .T.
	endif
return (lRet)