#include "rwmake.ch"

user function FUsuario(cNUsuario)
	local cResult := ""
	
	_NomeUser := cNUsuario
	
	psworder(2)
	if pswseek(_NomeUser,.T.)
		_aRetUser := pswret(1)
		cResult := alltrim(_aRetUser[1,14])
	endif
return (cResult)