#include "rwmake.ch"
#include "topconn.ch"

user function ExistReg(cTabela,cCampo,cValor)
	local aAreaAnt := GetArea()
	local lRet := .T.
	
	cQry := "select "+cCampo+" as CAMPO from "+RetSqlName(cTabela)+" where "+cCampo+" = '"+cValor+"' and D_E_L_E_T_ <> '*'"
	
	tcquery cQry new alias "CHK"
	
	DbSelectArea("CHK")
	
	if CHK->CAMPO == cValor
		MsgAlert("Valor ja utilizado nesse campo.")
		
		lRet := .F.
	endif
	
	CHK->(DbCloseArea())
	RestArea(aAreaAnt) 
return lRet