/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validacao do campo cheque quando for tipo PA          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function F050CHEQ()
	local cNumTED := ""
	
	if AllTrim(CCHEQUEADT) == "TEDPA"
		if SA6->(DbSeek(xFilial("SA6")+CBANCOADT+CAGENCIAADT+CNUMCON,.F.))
			if Empty(SA6->A6_NUMTED)
				cNumTED := Right(Str(Year(dDataBase),4),2)+"0001"
			else
				if Right(Str(Year(dDataBase),4),2) > Left(SA6->A6_NUMTED,2)
					cNumTED := Right(Str(Year(dDataBase),4),2)+"0001"
				else
					cNumTED := SA6->A6_NUMTED
				endif
			endif
			
			CCHEQUEADT := "TED"+cNumTED
		endif
	endif
return .T.