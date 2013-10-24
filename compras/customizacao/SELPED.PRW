/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 06/11/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Selecionar pedidos de compra a serem entregues p/     ¦
   ¦          ¦ autorizar                                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function SELPED()
	local cTitulo := "Pedido de Compra entregues para autorizar"
	local aCamposBrw := {}
	local aCamposTbl := {}
	local aRelatorio := {}
	local aOrdemRel := {}
	
	aCamposBrw := {{"C7_OK1",,""},;
					{"C7_NUM",,"Pedido"},;
					{"C7_CLVL",,"Projeto"},;
					{"C7_NUMSC",,"Sol. Compra"},;
					{"C7_TOTAL",,"Total","@E 999,999,999.99"}}
	
	/* -- Referência dos parâmetros da variável aCamposTbl com a tabela SZ2 --
		Param01 = Z2_OK
		Param02 = Z2_SEQUENC
		Param03 = Z2_ITEM
		Param04 = Z2_BANCO
		Param05 = Z2_AGENCIA
		Param06 = Z2_CONTA
	*/
	
	aCamposTbl := {"C7_OK1","C7_SZ2","C7_NUM","","","","","",""}
	
	/* -- Confirugação do Relatório --
		Param01 = Ordem
		Param02 = Cabec1
		Param03 = cDesc1
		Param04 = Z2_BANCO
		Param05 = Z2_AGENCIA
		Param06 = Z2_CONTA
	*/
	
	aRelatorio := {"N. LIB. | PEDIDO | PROJETO   | EMISSAO    | FORNECEDOR                         | PREC TOTAL |     ICMS |       IPI",;
					"PEDIDOS ENTREGUE PARA LIBERACAO"}
	aOrdemRel := {"Pedido de Compra","Cod. Fornecedor","Nom. Fornecedor","Projeto"}
	
	DbSelectArea("SC7")
	
	U_SelItm(Alias(),cTitulo,aCamposBrw,aCamposTbl,aRelatorio,aOrdemRel)
return