#include "protheus.ch"
#include "rwmake.ch"

user function CalcIQF(nRA,nRC,nRR,nTOT)
	local aRet := {}
	local nIQF := 0
	local cClassif := ""
	
	default nTOT := 0
	
	if Empty(nTOT)
		nIQF := ((100 * nRA) + (25 * nRC) + (5 * nRR)) / (nRA + nRC + nRR)
	else
		nIQF := nTOT
	endif
	
	do case
		case nIQF < 60
			cClassif := "DESQUALIFICADO"
		case nIQF >= 60 .and. nIQF < 80
			cClassif := " ACEITO COM RESTRICAO"
		case nIQF >= 80
			cClassif := "QUALIFICADO"
	endcase
	
	AAdd(aRet,{nIQF,cClassif})
return(aRet)