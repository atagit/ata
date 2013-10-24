/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                       ¦ Data ¦ 19/04/12 ¦
   +----------+--------------------------------------------------------¦
   ¦Descrição ¦ Função de bloqueio de CÓD. DE ESPESAS ref. a titulo,em:¦
   ¦            B1_CODESP, D1_CODESP, D3_CODESP, E2_CODESP             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function V_CODESP(cCodesp)

	local cAlias := Alias()
	local lRet	 := .F. 
    
	DbSelectArea('SZB')
	DbSetOrder(1)
	
	If dbSeek(xfilial('SZB')+cCodesp) 
   
		If SZB->ZB_TITULO == "2"            // nao
			lRet := .T.
		Else
			msgbox("Cód.Despesa '"+cCodesp+"' refere-se a Título. Escolha outro.","Alerta","ALERT")	          
	    EndIf
	   
	Else
		msgbox("Cód.Despesa '"+cCodesp+"' não está cadastrado. Favor verificar.","Alerta","ALERT")	          
	EndIf

DbSelectArea(cAlias)

return (lRet)
            
