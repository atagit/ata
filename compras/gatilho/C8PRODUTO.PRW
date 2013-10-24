/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/11/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Alterar produto na cotação e na solicitação           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function C8PRODUTO(cNum,cSC,cForn,cLoj,cItm,cProd)
	local cAlias := Alias()
	local nLinini := 010
	local cDescricao := Space(30)
	local cObservacao := Space(100)
	local oGet, oButton
	
	private oDlg
	private cProduto := ""
	private cProdV := ""
	private cItmSC := ""
	
	DbSelectArea("SC8")
	DbSeek(xFilial("SC8")+cNum+cForn+cLoj+cItm,.F.)
	
	cProduto := SC8->C8_PRODUTO
	cProdV := SC8->C8_PRODUTO
	cItmSC := SC8->C8_ITEMSC
	
	if AllTrim(cProduto) <> AllTrim(cProd) .and. !Empty(cProd)
		if APMsgNoYes("Deseja realmente trocar o produto na Cotação e na Solicitação?","Atenção")
			cProduto := cProd
			
			if SB1->(DbSeek(xFilial("SB1")+cProduto,.F.)) .and. !Empty(cProduto)
				cDescricao := AllTrim(SB1->B1_DESC)
				
				define msdialog oDlg from 000,000 to 140,470 pixel title "DADOS DO PRODUTO"
					@010,005 say "Descricao" of oDlg pixel
					oGet := TGet():New(007,035,{|u| If(PCount() > 0,cDescricao := u,cDescricao)},oDlg,100,010,"@!",,,,,,,.T.,,,,,,,,,,"cDescricao")
					@028,005 say "Observacao" of oDlg pixel
					oGet := TGet():New(025,035,{|u| If(PCount() > 0,cObservacao := u,cObservacao)},oDlg,200,010,"@!",,,,,,,.T.,,,,,,,,,,"cObservacao")
					
					@050,080 button oButton prompt "Atualizar" of oDlg pixel action Atualizar(cNum,cSC,cForn,cLoj,cItm,cProduto,cDescricao,cObservacao,cProdV,cItmSC)
					@050,160 button oButton prompt "Cancelar" of oDlg pixel action Fechar(cNum,cForn,cLoj,cItm)
				activate msdialog oDlg centered
			else
				MsgStop("Produto nao existe!!!")
			endif
		endif
	endif
	
	DbSelectArea(cAlias)
return (cProduto)

static function Fechar(cNum,cForn,cLoj,cItm)
	DbSelectArea("SC8")
	DbSeek(xFilial("SC8")+cNum+cForn+cLoj+cItm,.F.)
	
	cProduto := SC8->C8_PRODUTO
	oDlg:End()
return

static function Atualizar(cNum,cSC,cForn,cLoj,cItm,cProduto,cDescricao,cObservacao,cProdV,cItmSC)
	local cQry := ""
	local cRet := 0
	local cRet1 := 0
	
	cQry := "update "+RetSqlName("SC1")+" set C1_PRODUTO = '"+cProduto+"', C1_OBS = '"+cObservacao+"', C1_DESCRI = '"+cDescricao+"' "
	cQry += "where C1_NUM = '"+cSC+"' and C1_ITEM = '"+cItmSC+"' and D_E_L_E_T_ <> '*'"
	
	cRet := TCSqlExec(cQry)
	TCRefresh(RetSqlName("SC1"))
	
	cQry := "update "+RetSqlName("SC8")+" set C8_PRODUTO = '"+cProduto+"', C8_OBS = '"+cObservacao+"' "
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