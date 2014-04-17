/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar numero de cheque com o talao                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function MT120TEL()
	local oNewDialog := PARAMIXB[1]
	local aPosGet := PARAMIXB[2]
	local aObj := PARAMIXB[3]
	local nOpcx := PARAMIXB[4]
	
	public _cNumRequi := SC7->C7_NUMREQU
	
	@044,aPosGet[1,6] say "Requisicao" of oNewDialog pixel size 060,006
	@043,aPosGet[1,7] msget _cNumRequi picture PesqPict("SC7","C7_NUMREQU") when Desbloqueio() of oNewDialog pixel size 040,006
return .T.

static function Desbloqueio()
	local lRet := .F.
	
	if INCLUI
		lRet := .T.
	endif
	
	if ALTERA
		lRet := .T.
	endif
return lRet