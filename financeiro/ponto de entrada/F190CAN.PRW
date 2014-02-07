/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Ao cancelar o cheque                                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function F190CAN()
	local aAreaAnt := GetArea()
	
	DbSelectArea("SZ8")
	SZ8->(DbSetOrder(1))
	SZ8->(DbGoTop())
	
	if SZ8->(DbSeek(xFilial("SZ8")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM),.F.))
		RecLock("SZ8",.F.)
			SZ8->Z8_STATUS := "L"
		MsUnLock()
	endif
	
	RestArea(aAreaAnt)
return