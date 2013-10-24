/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/10/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar NCM dos produtos inseridos                    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function VALIDNCM(cPro,cNcm)
	local lRet := .T.
	
	do case
		case Empty(cNcm)
			MsgAlert("Esse produto nao pode ser utilizado devido o codigo NCM esta em branco! Favor acertar para utilização do mesmo.")
			
			lRet := .F.
		case Len(AllTrim(cNcm)) < 8
			MsgAlert("Esse produto nao pode ser utilizado devido o codigo NCM esta errado! Favor acertar para utilização do mesmo.")
			
			lRet := .F.
		case AllTrim(cNcm) == "99999999"
			if Left(cPro,3) <> "SER"
				MsgAlert("Esse produto nao pode ser utilizado devido o codigo NCM esta errado! Favor acertar para utilização do mesmo.")
				
				lRet := .F.
			endif
		otherwise
			if !SYD->(DbSeek(xFilial("SYD")+cNcm,.F.))
				MsgAlert("Esse produto nao pode ser utilizado devido o codigo NCM esta errado! Favor acertar para utilização do mesmo.")
				
				lRet := .F.
			endif
	endcase
return(lRet)