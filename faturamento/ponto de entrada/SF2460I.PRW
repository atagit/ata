/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 02/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. após gravar o pedido de venda                    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function SF2460I()
	local cAlias := Alias()
	local cProjeto := SC5->C5_PROJETO
	local cNum := SC5->C5_NUM
	local cNota := SC5->C5_NOTA
	local cSerie := SC5->C5_SERIE
	
	DbSelectArea("SE1")
	
	if SE1->(DbSeek(xFilial("SE1")+cSerie+cNota,.F.))
		RecLock("SE1",.F.)
			SE1->E1_CLVLCR := cProjeto
		MsUnLock()
	endif
	
	DbSelectArea(cAlias)
return