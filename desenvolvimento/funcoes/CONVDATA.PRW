#include "rwmake.ch"

user function ConvData(cData,cMskAno)
	local cRet := " "
	
	if !Empty(cData)
		if Empty(cMskAno)
			cRet := Right(cData,2)+"/"+SubStr(cData,5,2)+"/"+Left(cData,4)
		else
			cRet := Right(cData,2)+"/"+SubStr(cData,5,2)+"/"+Right(Left(cData,4),Len(cMskAno))
		endif
	endif
return cRet