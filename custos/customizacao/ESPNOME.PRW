/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 19/04/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Customizacao do menu Especifico                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "protheus.ch"
#include "tryexception.ch"

user function ESPNOME()
	local aRetMod
	local bError := {|| aRetMod := &(cError)}
	local bSysErrorBlock := SysErrorBlock(bError)
	local nEsp := 0
	local cError := "aRetModName"
	
	tryexception using bError
		ValGroup("")
	endexception
	
	if (ValType(aRetMod) == "A")
		nEsp := aScan(aRetMod,{|aModName| (aModName[2] == "SIGAESP")})
		
		if (nEsp > 0)
			aRetMod[nEsp][5] := "ESPIMG"
		endif
	endif
	
	SysErrorBlock(bSysErrorBlock)
return ("Custos")