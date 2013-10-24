#include "rwmake.ch"

user function TiraAcento(Arg1)
	local nConta := 0
	local cLetra := ""
	local cRet   := ""
	
	Arg1 := upper(Arg1)
	
	for nConta:= 1 to len(Arg1)
		cLetra := substr(Arg1,nConta,1)
		
		do case
			case (Asc(cLetra) > 191 .and. Asc(cLetra) < 198) .or. (Asc(cLetra) > 223 .and. Asc(cLetra) < 230)
				cLetra := "A"
			case (Asc(cLetra) > 199 .and. Asc(cLetra) < 204) .or. (Asc(cLetra) > 231 .and. Asc(cLetra) < 236)
				cLetra := "E"
			case (Asc(cLetra) > 204 .and. Asc(cLetra) < 207) .or. (Asc(cLetra) > 235 .and. Asc(cLetra) < 240)
				cLetra := "I"
			case (Asc(cLetra) > 209 .and. Asc(cLetra) < 215) .or. (Asc(cLetra) == 240) .or. (Asc(cLetra) > 241 .and. Asc(cLetra) < 247)
				cLetra := "O"
			case (Asc(cLetra) > 216 .and. Asc(cLetra) < 221) .or. (Asc(cLetra) > 248 .and. Asc(cLetra) < 253)
				cLetra := "U"
			case Asc(cLetra) == 199 .or. Asc(cLetra) == 231
				cLetra := "C"
		endcase
		
		cRet := cRet+cLetra
	next
return (cRet)