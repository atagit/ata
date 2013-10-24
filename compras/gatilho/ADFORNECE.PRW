/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 04/05/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho validar a avaliacao do fornecedor             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function ADFORNECE(cFor,cLoj)
	local aCalcIQF := {{0},{0}}
	
	DbSelectArea("SZY")
	SZV->(DbSetOrder(4))
	
	if SZV->(DbSeek(xFilial("SZV")+cFor+cLoj,.F.))
		while !SZV->(Eof()) .and. SZV->ZV_FORNECE == cFor .and. SZV->ZV_LOJA == cLoj
			if SZV->ZV_USADO == "S"
				aCalcIQF := U_CalcIQF(0,0,0,SZV->ZV_VALIQF)
			endif
			
			SZV->(DbSkip())
		enddo
	endif
	
	if Empty(aCalcIQF[1][1])
		MsgAlert("Fornecedor SEM AVALIACAO.")
	else
		MsgAlert("Fornecedor "+aCalcIQF[1][2]+" ("+AllTrim(Str(aCalcIQF[1][1]))+").")
	endif
return cFor