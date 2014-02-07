/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar numero de cheque com o talao                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function VALCHQ(cNumBanco,cNumCheque)
	local aAreaAnt := GetArea()
	local nError := 1
	
	if !Empty(cNumBanco)
		if !Empty(cNumCheque)
			DbSelectArea("SZ8")
			SZ8->(DbSetOrder(1))
			SZ8->(DbGoTop())
			
			if SZ8->(DbSeek(xFilial("SZ8")+cNumBanco+cNumCheque,.F.))
				do case
					case SZ8->Z8_STATUS == "F"
						nError := 3
					case SZ8->Z8_STATUS == "B"
						nError := 4
					case SZ8->Z8_STATUS == "L"
						nError := 0
				endcase
			else
				nError := 5
			endif
		else
			nError := 2
		endif
	else
		nError := 6
	endif
	
	RestArea(aAreaAnt)
return MsgError(nError)

static function MsgError(nError)
	local lRet := .F.
	
	do case
		case nError == 0
			lRet := .T.
		case nError == 1
			MsgAlert("Nao foi cadastrado o talao de cheque referente a esse numero de cheque.")
		case nError == 2
			MsgAlert("O numero do cheque nao foi digitado.")
		case nError == 3
			MsgAlert("Esse cheque ja foi utilizado.")
		case nError == 4
			MsgAlert("Esse cheque esta bloqueado para uso.")
		case nError == 5
			MsgAlert("O cheque nao esta cadastrado no talao.")
		case nError == 6
			MsgAlert("O dados do banco nao foram informado.")
	endcase
return lRet