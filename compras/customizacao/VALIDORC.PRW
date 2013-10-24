/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 24/05/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar orcamento                                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function VALIDORC(aProjeto,cAlias)
	local lRet := .F.
	
	DbSelectArea("SZ4")
	DbSetOrder(2)
	
	if cAlias == "SC7+"
		for i := 1 to Len(aProjeto)
			if DbSeek(xFilial("SZ4")+aProjeto[i][1],.F.)
				RecLock("SZ4",.F.)
					SZ4->Z4_EMPENHA += aProjeto[i][2]
				MsUnLock()
			else
				cGGrupo := If(SBM->(DbSeek(xFilial("SBM")+Right(aProjeto[i][1],5),.F.)),SBM->BM_ORCGRP,"")
				
				DbSetOrder(3)
				
				if DbSeek(xFilial("SZ4")+Left(aProjeto[i][1],9)+cGGrupo,.F.)
					RecLock("SZ4",.F.)
						SZ4->Z4_EMPENHA += aProjeto[i][2]
					MsUnLock()
				endif
				
				DbSetOrder(2)
			endif
			
			lRet := .T.
		next
	elseif cAlias == "SF1+"
		for i := 1 to Len(aProjeto)
			if DbSeek(xFilial("SZ4")+aProjeto[i][1],.F.)
				RecLock("SZ4",.F.)
					SZ4->Z4_VLREALI += aProjeto[i][2]
					SZ4->Z4_SALDO -= aProjeto[i][2]
				MsUnLock()
			else
				cGGrupo := If(SBM->(DbSeek(xFilial("SBM")+Right(aProjeto[i][1],5),.F.)),SBM->BM_ORCGRP,"")
				
				DbSetOrder(3)
				
				if DbSeek(xFilial("SZ4")+Left(aProjeto[i][1],9)+cGGrupo,.F.)
					RecLock("SZ4",.F.)
						SZ4->Z4_VLREALI += aProjeto[i][2]
						SZ4->Z4_SALDO -= aProjeto[i][2]
					MsUnLock()
				endif
				
				DbSetOrder(2)
			endif
			
			lRet := .T.
		next
	elseif cAlias == "SF1-"
		for i := 1 to Len(aProjeto)
			if DbSeek(xFilial("SZ4")+aProjeto[i][1],.F.)
				RecLock("SZ4",.F.)
					SZ4->Z4_VLREALI =- aProjeto[i][2]
					SZ4->Z4_SALDO += aProjeto[i][2]
				MsUnLock()
			else
				cGGrupo := If(SBM->(DbSeek(xFilial("SBM")+Right(aProjeto[i][1],5),.F.)),SBM->BM_ORCGRP,"")
				
				DbSetOrder(3)
				
				if DbSeek(xFilial("SZ4")+Left(aProjeto[i][1],9)+cGGrupo,.F.)
					RecLock("SZ4",.F.)
						SZ4->Z4_VLREALI -= aProjeto[i][2]
						SZ4->Z4_SALDO += aProjeto[i][2]
					MsUnLock()
				endif
				
				DbSetOrder(2)
			endif
			
			lRet := .T.
		next
	elseif cAlias == "SC7-"
		for i := 1 to Len(aProjeto)
			if DbSeek(xFilial("SZ4")+aProjeto[i][1],.F.)
				RecLock("SZ4",.F.)
					SZ4->Z4_EMPENHA -= aProjeto[i][2]
				MsUnLock()
			else
				cGGrupo := If(SBM->(DbSeek(xFilial("SBM")+Right(aProjeto[i][1],5),.F.)),SBM->BM_ORCGRP,"")
				
				DbSetOrder(3)
				
				if DbSeek(xFilial("SZ4")+Left(aProjeto[i][1],9)+cGGrupo,.F.)
					RecLock("SZ4",.F.)
						SZ4->Z4_EMPENHA -= aProjeto[i][2]
					MsUnLock()
				endif
				
				DbSetOrder(2)
			endif
			
			lRet := .T.
		next
	endif
return (lRet)