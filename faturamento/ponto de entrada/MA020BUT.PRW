/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Adiciona botão na tela de inclusão de fornecedores    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MA020BUT()
	local aButtons := {}
	
	aadd(aButtons,{"NOTE",{| |U_Correios()},"Completar Informacoes","Correios"})
return (aButtons)