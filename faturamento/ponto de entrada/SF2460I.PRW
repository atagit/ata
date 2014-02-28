/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 02/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. após gravar o pedido de venda                    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function SF2460I()
	local cAlias := Alias()
/*	local cProjeto := SC5->C5_PROJETO
	local cNum := SC5->C5_NUM
	local cNota := SC5->C5_NOTA
	local cSerie := SC5->C5_SERIE
	
	DbSelectArea("SE1")
	
	if SE1->(DbSeek(xFilial("SE1")+cSerie+cNota,.F.))
		RecLock("SE1",.F.)
			SE1->E1_CLVLCR := cProjeto
		MsUnLock()
	endif*/
	
	cQry := "update "+RetSqlName("SE1")+" "
	cQry += "set E1_CLVLCR = '"+SC5->C5_PROJETO+"' "
	cQry += "where E1_NUM = '"+SC5->C5_NOTA+"' and E1_PREFIXO = '"+SC5->C5_SERIE+"' and E1_CLIENTE = '"+SC5->C5_CLIENTE+"' and E1_LOJA = '"+SC5->C5_LOJACLI+"' and D_E_L_E_T_ <> '*'"
	nRet := TCSqlExec(cQry)
	
	DbSelectArea(cAlias)
return