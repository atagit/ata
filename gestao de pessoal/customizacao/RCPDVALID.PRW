/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/11/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Verificar se já foi lançado uma verba                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function RCPDVALID()
	local i := 0
	local lRet := .T.
	local nPos := AScan(aHeader,{|x| AllTrim(x[2]) == "RC_PD"})
	
	for i := 1 to Len(aCols)
		if M->RC_PD == aCols[i][nPos] .and. i != n
			MsgBox("Essa verba já está lançada na "+AllTrim(Str(i))+"ª linha!","Atencao","ALERT")
			
			lRet := .F.
			
			exit
		endif
	next
return (lRet)