/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar numero de cheque com o talao                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function MT120GRV()
	Alert(aCols[n][Len(aHeader) + 1])
/*	if !Empty(_cNumRequi)
		if !aCols[n][Len(aHeader) + 1]
			RecLock("SC7",.F.)
				SC7->C7_NUMREQU := _cNumRequi
			MsUnLock("SC7")
		endif
	endif*/
return .T.