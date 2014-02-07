/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Após a gravacao do cheque                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function FA080SEF()
	local aAreaAnt := GetArea()
	
	if !Empty(CCHEQUE)
		DbSelectArea("SZ8")
		SZ8->(DbSetOrder(1))
		SZ8->(DbGoTop())
		
		if SZ8->(DbSeek(xFilial("SZ8")+CBANCO+CAGENCIA+CCONTA+CCHEQUE,.F.))
			RecLock("SZ8",.F.)
				SZ8->Z8_STATUS := "F"
			MsUnLock()
		endif
	endif
	
	RestArea(aAreaAnt)
return