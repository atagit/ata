/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 30/10/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho para retornar o número do protocolo           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

//user function D1COD(cProduto,cArmazem,cItem,cAno)
user function D1COD(cProduto)
	local cRet := ""
	
	if "X" $ CSERIE .or. "Z" $ CSERIE
		cRet := "SP"
	else
		if !Empty(cProduto)
/*			SB1->(DbSetOrder(12))
			
			if SB1->(DbSeek(xFilial("SB1")+cProduto+cArmazem,.F.))
				if SubStr(cNumEmp,1,2) == "01"		// ATA
					cAno := "A"+cAno
				endif
				
				DbSelectArea("SX5")
				
				if SX5->(DbSeek(xFilial("SX5")+"PT"+cAno,.F.))
					cRet := If(AllTrim(SX5->X5_DESCRI) == "SP","SP",AllTrim(SX5->X5_CHAVE)+AllTrim(SX5->X5_DESCRI)+"/"+Right(cItem,2))
				else
					MsgBox("Não possui numeração na tabela SX5!","Alerta","ALERT")
				endif
			endif*/
			
			cNota := AllTrim(CNFISCAL+CSERIE+CA100FOR+CLOJA+cProduto)
			
			DbSelectArea("SZU")
			SZU->(DbSetOrder(3))
			SZU->(DbGoTop())
			
			if SZU->(DbSeek(xFilial("SZU")+cNota,.F.))
				while SZU->(ZU_NFISCAL+ZU_SERIE+ZU_FORNECE+ZU_LOJA+ZU_PRODUTO) == cNota
					if SZU->ZU_USADO <> "C"
						if SZU->ZU_USADO == "E"
							if MsgNoYes("O protocolo ("+AllTrim(SZU->ZU_NUMCR)+") foi excluido, deseja reutiliza-lo?"," Confirmar ")
								cRet := SZU->ZU_NUMCR
								
								return (cRet)
							endif
						elseif SZU->ZU_USADO == "N"
							cRet := SZU->ZU_NUMCR
						else
							MsgBox("O protocolo "+AllTrim(SZU->ZU_NUMCR)+" ja foi utilizado em outra nota fiscal!","Alerta","ALERT")
						endif
					endif
					
					SZU->(DbSkip())
				enddo
			else
				SZU->(DbGoTop())
				
				if SZU->(DbSeek(xFilial("SZU")+CNFISCAL+CSERIE+CA100FOR+CLOJA,.F.))
					if SZU->ZU_PRODUTO == "AAA001"
						if SZU->ZU_USADO <> "C"
							if SZU->ZU_USADO == "E"
								if MsgNoYes("O protocolo ("+AllTrim(SZU->ZU_NUMCR)+") foi excluido, deseja reutiliza-lo?"," Confirmar ")
									cRet := SZU->ZU_NUMCR
									
									return (cRet)
								endif
							elseif SZU->ZU_USADO == "N"
								cRet := SZU->ZU_NUMCR
							else
								MsgBox("O protocolo "+AllTrim(SZU->ZU_NUMCR)+" ja foi utilizado em outra nota fiscal!","Alerta","ALERT")
							endif
						endif
					else
						MsgBox("Protocolo nao encontrado para esse produto nessa nota, favor conferir o produto digitado!","Alerta","ALERT")
					endif
				endif
			endif
		endif
	endif
return (cRet)

static function NovoD1COD(cProduto)
	local cRet := ""
	
	if "X" $ CSERIE .or. "Z" $ CSERIE
		cRet := "SP"
		
		return (cRet)
	else
		if !Empty(cProduto)
/*			SB1->(DbSetOrder(12))
			
			if SB1->(DbSeek(xFilial("SB1")+cProduto+cArmazem,.F.))
				if SubStr(cNumEmp,1,2) == "01"		// ATA
					cAno := "A"+cAno
				endif
				
				DbSelectArea("SX5")
				
				if SX5->(DbSeek(xFilial("SX5")+"PT"+cAno,.F.))
					cRet := If(AllTrim(SX5->X5_DESCRI) == "SP","SP",AllTrim(SX5->X5_CHAVE)+AllTrim(SX5->X5_DESCRI)+"/"+Right(cItem,2))
				else
					MsgBox("Não possui numeração na tabela SX5!","Alerta","ALERT")
				endif
			endif*/
			
			cNota := AllTrim(CNFISCAL+CSERIE+CA100FOR+CLOJA+cProduto)
			
			DbSelectArea("SZU")
			SZU->(DbSetOrder(3))
			SZU->(DbGoTop())
			
			if SZU->(DbSeek(xFilial("SZU")+cNota,.F.))
				while SZU->(ZU_NFISCAL+ZU_SERIE+ZU_FORNECE+ZU_LOJA+ZU_PRODUTO) == cNota
//					if SZU->ZU_USADO <> "C"
						if SZU->ZU_USADO == "E"
							if MsgNoYes("O protocolo ("+AllTrim(SZU->ZU_NUMCR)+") foi excluido, deseja reutiliza-lo?"," Confirmar ")
								cRet := SZU->ZU_NUMCR
								
								RecLock("SZU",.F.)
									SZU->ZU_USADO := "S"
								MsUnLock()
								
								return (cRet)
							else
								return (cRet)
							endif
//						elseif SZU->ZU_USADO == "N"
//							cRet := SZU->ZU_NUMCR
//						else
//							MsgBox("O protocolo "+AllTrim(SZU->ZU_NUMCR)+" ja foi utilizado em outra nota fiscal!","Alerta","ALERT")
						endif
//					endif
					
					SZU->(DbSkip())
				enddo
/*			else
				SZU->(DbGoTop())
				
				if SZU->(DbSeek(xFilial("SZU")+CNFISCAL+CSERIE+CA100FOR+CLOJA,.F.))
					if SZU->ZU_PRODUTO == "AAA001"
						if SZU->ZU_USADO <> "C"
							if SZU->ZU_USADO == "E"
								if MsgNoYes("O protocolo ("+AllTrim(SZU->ZU_NUMCR)+") foi excluido, deseja reutiliza-lo?"," Confirmar ")
									cRet := SZU->ZU_NUMCR
									
									return (cRet)
								endif
							elseif SZU->ZU_USADO == "N"
								cRet := SZU->ZU_NUMCR
							else
								MsgBox("O protocolo "+AllTrim(SZU->ZU_NUMCR)+" ja foi utilizado em outra nota fiscal!","Alerta","ALERT")
							endif
						endif
					else
						MsgBox("Protocolo nao encontrado para esse produto nessa nota, favor conferir o produto digitado!","Alerta","ALERT")
					endif
				endif*/
			endif
		endif
	endif
return (cRet)