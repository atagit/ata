/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/06/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Validar Desbloqueio dos produtos e fornecedores       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function VALIDBLOQ(cTab,cCodigo,cBloq,cObs)
	local lRet := .T.
	local cObsAux := cObs
	
	default cObs := ""
	
	do case
		case cTab == "SB1"
			if cBloq <> "1" .and. Len(AllTrim(cCodigo)) <> 6
				Alert(AllTrim(cCodigo)+": Produto nao pode ser desbloqueado por esta com o CODIGO fora do padrão de cadastro (3 letras e 3 numeros).")
				
				M->B1_MSBLQL := "1"
				lRet := .F.
			endif
		case cTab == "SA2"
			if cBloq <> "1" .and. !Empty(cObs)
				if MsgYesNo("O fornecedor esta bloqueado, deseja desbloquea-lo assim mesmo?"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+"MOTIVO"+Chr(13)+Chr(10)+AllTrim(cObs))
					M->A2_MSBLQL := "2"
					M->A2_OBSBLOQ := ""
				else
					M->A2_MSBLQL := "1"
					M->A2_OBSBLOQ := cObsAux
				endif
			endif
	endcase
return lRet