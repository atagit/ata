/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 19/11/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Alterar a quantidade na cotação e na solicitação      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function C8QUANT(cNum,cSC,cForn,cLoj,cItm,cProd,nQtd)
	local cAlias := Alias()
	local nLinini := 010
	local nQuantidade := 0.00
	local oGet, oButton
	
	private oDlg
	private cItmSC := ""
	
	DbSelectArea("SC8")
	DbSeek(xFilial("SC8")+cNum+cForn+cLoj+cItm,.F.)
	
	cItmSC := SC8->C8_ITEMSC
	nQuantidade := SC8->C8_QUANT
	
	if nQuantidade <> nQtd .and. !Empty(nQtd)
		if APMsgNoYes("Deseja realmente trocar a quantidade na Cotação e na Solicitação?","Atenção")
			nQuantidade := nQtd
			
			define msdialog oDlg from 000,000 to 140,470 pixel title "DADOS DO PRODUTO"
				@010,005 say "Quantidade" of oDlg pixel
				oGet := TGet():New(007,035,{|u| If(PCount() > 0,nQuantidade := u,nQuantidade)},oDlg,100,010,"@E 999,999,999.99",,,,,,,.T.,,,,,,,,,,"nQuantidade")
				
				@050,080 button oButton prompt "Atualizar" of oDlg pixel action Atualizar(cNum,cSC,cForn,cLoj,cItm,cProd,nQuantidade,cItmSC)
				@050,160 button oButton prompt "Cancelar" of oDlg pixel action Fechar(cNum,cForn,cLoj,cItm)
			activate msdialog oDlg centered
		endif
	endif
	
	DbSelectArea(cAlias)
return (nQuantidade)

static function Fechar(cNum,cForn,cLoj,cItm)
	DbSelectArea("SC8")
	DbSeek(xFilial("SC8")+cNum+cForn+cLoj+cItm,.F.)
	
	nQuantidade := SC8->C8_QUANT
	
	oDlg:End()
return

static function Atualizar(cNum,cSC,cForn,cLoj,cItm,cProd,nQuantidade,cItmSC)
	local cQry := ""
	local cRet := 0
	local cRet1 := 0
	
	cQry := "update "+RetSqlName("SC1")+" set C1_QUANT = "+str(nQuantidade)+" "
	cQry += "where C1_NUM = '"+cSC+"' and C1_ITEM = '"+cItmSC+"' and D_E_L_E_T_ <> '*'"
	
	cRet := TCSqlExec(cQry)
	TCRefresh(RetSqlName("SC1"))
	
	cQry := "update "+RetSqlName("SC8")+" set C8_QUANT = "+str(nQuantidade)+" "
	cQry += "where C8_NUM = '"+cNum+"' and C8_NUMSC = '"+cSC+"' and C8_ITEMSC = '"+cItmSC+"' and D_E_L_E_T_ <> '*'"
	
	cRet1 := TCSqlExec(cQry)
	TCRefresh(RetSqlName("SC8"))
	
	if cRet == 0 .and. cRet1 == 0
		MsgBox("Solicitacao de Compra e Cotação atualizados com sucesso!","Informação","INFO")
	elseif cRet > 0
		MsgBox("Solicitacao de Compra NÃO foi atualizado!","Error","STOP")
	elseif cRet1 > 0
		MsgBox("Cotação NÃO foi atualizado!","Error","STOP")
	endif
	
	oDlg:End()
return