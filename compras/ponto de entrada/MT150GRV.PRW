/*______________________________________________________________________
   �Autor     � Breno Ferreira                      � Data � 28/08/09 �
   +----------+-------------------------------------------------------�
   �Descri��o � Lan�amento do frete, ap�s grava��o da cotacao no SC8  �
  ����������������������������������������������������������������������*/
#include "rwmake.ch"

user function MT150GRV()
	if SC8->C8_ITEM == "0001"
		U_FRETE("COTACAO",CA150NUM,CA150FORN,CA150LOJ,"SC8")
	endif
return