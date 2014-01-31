/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Após a confirmação da baixa do contas a pagar         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function FA080TIT()
	local lRet := .T.
	
	public _NumTED := ""
	
	if CMOTBX == "DEBITO CC"
		if MsgYesNo("Gerar um TED para essa baixa?","TED")
			if SA6->(DbSeek(xFilial("SA6")+CBANCO+CAGENCIA+CCONTA,.F.))
				if Empty(SA6->A6_NUMTED)
					MsgAlert("Nao tem numeracao inicial de TED para esse banco.")
					
					lRet := .F.
				else
					if Left(SA6->A6_NUMTED,2) == Right(Str(Year(dDataBase),4),2)
						_NumTED := SA6->A6_NUMTED
						
						RecLock("SA6",.F.)
							SA6->A6_NUMTED := StrZero(Val(_NumTED) + 1,6)
						MsUnLock()
						
						_NumTED := SE2->(E2_NUM+E2_PREFIXO+E2_PARCELA+E2_FORNECE+E2_LOJA)+_NumTED
						
						MsgInfo("O numero do TED e: "+"TED"+Right(_NumTED,6))
					else
						MsgAlert("O ano na numeracao do TED esta diferente.")
						
						lRet := .F.
					endif
				endif
			endif
/*			if SX5->(DbSeek(xFilial("SX5")+"TD"+Str(Year(dDataBase)),.F.))
				_NumTED := AllTrim(SX5->X5_DESCRI)
				
				MsgInfo("O numero do TED e: "+Right(Str(Year(dDataBase)),2)+_NumTED)
				
				RecLock("SX5",.F.)
					SX5->X5_DESCRI := StrZero(Val(_NumTED) + 1,4)
					SX5->X5_DESCSPA := StrZero(Val(_NumTED) + 1,4)
					SX5->X5_DESCENG := StrZero(Val(_NumTED) + 1,4)
				SX5->(MsUnLock())
				
				_NumTED := SE2->E2_NUM+_NumTED
			else
				MsgAlert("Nao numeracao inicial de TED para esse ano.")
				
				lRet := .F.
			endif*/
		endif
	elseif CMOTBX == "NORMAL"
	//
	endif
return lRet