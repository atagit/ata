/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/08/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Selecionar notas fiscais a serem entregues            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function SELPRT()
	local cTitulo := "Notas Fiscais entregues"
	local aCamposBrw := {}
	local aCamposTbl := {}
	local aRelatorio := {}
	local aOrdemRel := {}
	
	aCamposBrw := {{"F1_OK1",,""},;
					{"F1_CR",,"Protocolo"},;
					{"F1_DOC",,"NF"},;
					{"F1_SERIE",,"Serie"},;
					{"F1_EMISSAO",,"Emissao"},;
					{"F1_FORNECE",,"Fornecedor"},;
					{"F1_LOJA",,"Loja"},;
					{"F1_VALBRUT",,"Total","@E 999,999,999.99"}}
	
	/* -- Referência dos parâmetros da variável aCamposTbl com a tabela SZ2 --
		Param01 = Z2_OK
		Param02 = Z2_SEQUENC
		Param03 = Z2_ITEM
		Param04 = Z2_BANCO
		Param05 = Z2_AGENCIA
		Param06 = Z2_CONTA
	*/
	
	aCamposTbl := {"F1_OK1","F1_SZ2","F1_DOC","","","","F1_FORNECE","F1_LOJA","F1_SERIE"}
	
	/* -- Confirugação do Relatório --
		Param01 = Ordem
		Param02 = Cabec1
		Param03 = cDesc1
		Param04 = Z2_BANCO
		Param05 = Z2_AGENCIA
		Param06 = Z2_CONTA
	*/
	
	aRelatorio := {"               PROTOC. | FORNECEDOR                               | N.F.          | EMISSAO    |          TOTAL | PEDIDO | PROJETO",;
					"PROTOCOLO"}
	aOrdemRel := {"Protocolo","Nota Fiscal"}
	
	DbSelectArea("SF1")
	DbSetOrder(7)
	
	U_SelItm(Alias(),cTitulo,aCamposBrw,aCamposTbl,aRelatorio,aOrdemRel)
return