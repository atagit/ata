/*______________________________________________________________________
   �Autor     � Breno Ferreira                      � Data � 18/08/09 �
   +----------+-------------------------------------------------------�
   �Descri��o � Adiciona bot�o na tela de inclus�o de clientes        �
  ����������������������������������������������������������������������*/
#include "rwmake.ch"

user function MA030BUT()
	local aButtons := {}
	
	aadd(aButtons,{"NOTE",{| |U_Correios()},"Correios"})
return (aButtons)