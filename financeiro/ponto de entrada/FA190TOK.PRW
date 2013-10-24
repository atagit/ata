/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/03/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Adiciona botão na tela de geração cheques             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function FA190TOK()
	local cBanco, cAgencia, cConta, cCheque
	local nIndBanco, nIndAgencia, nIndConta, nIndCheque
	local nError := 1
	
	nIndBanco := AScan(ParamIxb:aControls,{|e| Upper(e:cReadVar) = "CBANCO190"})
	nIndAgencia := AScan(ParamIxb:aControls,{|e| Upper(e:cReadVar) = "CAGENCIA190"})
	nIndConta := AScan(ParamIxb:aControls,{|e| Upper(e:cReadVar) = "CCONTA190"})
	nIndCheque := AScan(ParamIxb:aControls,{|e| Upper(e:cReadVar) = "CCHEQUE190"})
	
	if nIndCheque > 0
		cBanco := ParamIxb:aControls[nIndBanco]:Buffer
		cAgencia := ParamIxb:aControls[nIndAgencia]:Buffer
		cConta := ParamIxb:aControls[nIndConta]:Buffer
		cCheque := ParamIxb:aControls[nIndCheque]:Buffer
		
		DbSelectArea("SZ8")
		SZ8->(DbSetOrder(1))
		SZ8->(DbGoTop())
		
		if SZ8->(DbSeek(xFilial("SZ8")+cBanco+cAgencia+cConta+cCheque,.F.))
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
return(MsgError(nError))

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
			MsgAlert("Esse cheque nao pode ser usado devido nao ter mais folha de cheque para essa numeracao.")
		case nError == 4
			MsgAlert("Esse cheque esta bloqueado para uso.")
		case nError == 5
			MsgAlert("O cheque nao esta cadastrado para uso.")
	endcase
return(lRet)