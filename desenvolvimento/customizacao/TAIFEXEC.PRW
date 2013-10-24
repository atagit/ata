/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/05/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Executar funcao TAIF diretamente                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"
#include "tbiconn.ch"

#define _MODULO "SIGACOM"

user function TAIFEXEC(cEmpFil)
	local aEmpFil
	local bWindowInit := {|| __Execute("U_TAIF()","xxxxxxxxxxxxxxxxxxxx","TAIF",_MODULO,_MODULO,1,.T.)}
	local cEmp
	local cFil
	local cMod
	local cModName := _MODULO
	
	default cEmpFil := "01;01"
	
	aEmpFil := StrTokArr(cEmpFil,";")
	cEmp := aEmpFil[1]
	cFil := aEmpFil[2]
	
	setModulo(@cModName,@cMod)
	
	prepare environment Empresa(cEmp) Filial(cFil) Modulo(cMod)
	
	InitPublic()
	SetsDefault()
	SetModulo(@cModName,@cMod)
	
	define window oMainWnd from 001,001 to 400,500 title OemToAnsi(FunName())
	activate window oMainWnd maximized on init(Eval(bWindowInit),oMainWnd:End())
	
	reset environment
return(nil)

static function SetModulo(cModName,cMod)
	local aRetModName := RetModName(.T.)
	local cSvcModulo
	local nSvnModulo
	
	if Type("nModulo") == "U"
		_SetOwnerPrvt("nModulo",0)
	else
		nSvnModulo := nModulo
	endif
	
	cModName := Upper(AllTrim(cModName))
	
	if nModulo <> AScan(aRetModName,{|x| Upper(AllTrim(x[2])) == cModName})
		nModulo := AScan(aRetModName,{|x| Upper(AllTrim(x[2])) == cModName})
		
		if nModulo == 0
			cModName := _MODULO
			nModulo := AScan(aRetModName,{|x| Upper(AllTrim(x[2])) == cModName})
		endif
	endif
	
	if Type("cModulo") == "U"
		_SetOwnerPrvt("cModulo","")
	else
		cSvcModulo := cModulo
	endif
	
	cMod := SubStr(cModName,5)
	
	if cModulo <> cMod
		cModulo := cMod
	endif
return({cSvcModulo,nSvnModulo})