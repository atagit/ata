/*______________________________________________________________________
   �Autor     � Breno Ferreira                      � Data � 08/11/10 �
   +----------+-------------------------------------------------------�
   �Descri��o � Verificar se j� foi lan�ado uma verba                 �
  ����������������������������������������������������������������������*/
#include "rwmake.ch"

user function RCPDVALID()
	local i := 0
	local lRet := .T.
	local nPos := AScan(aHeader,{|x| AllTrim(x[2]) == "RC_PD"})
	
	for i := 1 to Len(aCols)
		if M->RC_PD == aCols[i][nPos] .and. i != n
			MsgBox("Essa verba j� est� lan�ada na "+AllTrim(Str(i))+"� linha!","Atencao","ALERT")
			
			lRet := .F.
			
			exit
		endif
	next
return (lRet)