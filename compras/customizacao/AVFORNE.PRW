/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 24/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Avaliacao do fornecedor                               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function AVFORNE(cForn,cLoja,nAval)
	local aCalcIQF := {}
	local lOK := .F.
	local cCodigo := ""
	
	if !Empty(nAval)
		DbSelectArea("SZV")
		DbSetOrder(3)
		SZV->(DbGoTop())
		
		if SZV->(DbSeek(xFilial("SZV")+cForn+cLoja,.F.))
			if SZV->ZV_STATUS == "A"
				RecLock("SZV")
					SZV->ZV_QTPEDID += 1
					
					do case
						case nAval == 1
							SZV->ZV_RA += 1
						case nAval == 2
							SZV->ZV_RR += 1
							SZV->ZV_NCD += 1
						case nAval == 3
							SZV->ZV_RC += 1
							SZV->ZV_NCA += 1
					endcase
					
					aCalcIQF := U_CalcIQF(SZV->ZV_RA,SZV->ZV_RC,SZV->ZV_RR)
					SZV->ZV_VALIQF := aCalcIQF[1][1]
					
					if SZV->ZV_QTPEDID == SZV->ZV_MAXPED
						SZV->ZV_STATUS := "F"
						SZV->ZV_FINAVAL := dDataBase
					endif
				MsUnLock()
				
				if aCalcIQF[1][1] < 60
					if SA2->(DbSeek(xFilial("SA2")+cForn+cLoja,.F.))
						RecLock("SA2",.F.)
							SA2->A2_MSBLQL := "1"
							SA2->A2_OBSBLOQ := "BLOQUEADO DEVIDO IQF ("+AllTrim(Str(aCalcIQF[1][1]))+") ABAIXO DO PERMITIDO."
						MsUnLock()
					endif
				endif
				
				lOK := .T.
			else
				while !SZV->(Eof()) .and. SZV->ZV_FORNECE == cForn .and. SZV->ZV_LOJA == cLoja
					cCodigo := SZV->ZV_CODIGO
					
					SZV->(DbSkip())
				enddo
			endif
		endif
		
		if !lOK
			if !Empty(cCodigo)
				SZV->(DbSetOrder(1))
				SZV->(DbGoTop())
				
				if SZV->(DbSeek(xFilial("SZV")+cCodigo,.F.))
					RecLock("SZV",.F.)
						SZV->ZV_USADO := "N"
					MsUnLock()
				endif
			endif
			
			RecLock("SZV",.T.)
				SZV->ZV_FILIAL := xFilial("SZV")
				SZV->ZV_CODIGO := IIf(Empty(cCodigo),"000001",StrZero((Val(cCodigo) + 1),6))
				SZV->ZV_FORNECE := cForn
				SZV->ZV_LOJA := cLoja
				SZV->ZV_INIAVAL := dDataBase
				SZV->ZV_QTPEDID := 1
				SZV->ZV_STATUS := "A"
				SZV->ZV_USADO := "S"
				SZV->ZV_MAXPED := GetMv("MV_MAXPED")
				
				do case
					case nAval == 1
						SZV->ZV_RA := 1
						SZV->ZV_VALIQF := 100
					case nAval == 2
						SZV->ZV_RR := 1
						SZV->ZV_VALIQF := 5
					case nAval == 3
						SZV->ZV_RC := 1
						SZV->ZV_VALIQF := 25
				endcase
			MsUnLock()
		endif
	endif
return