/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 21/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Selecionar os cheques a serem entregues p/ autorizar  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function SELCHQ()
	local cTitulo := "Cheques entregues para autorizar"
	local aCamposBrw := {}
	local aCamposTbl := {}
	local aRelatorio := {}
	local aOrdemRel := {}
	
	aCamposBrw := {{"EF_OK1",,""},;
					{"EF_BANCO",,"Banco"},;
					{"EF_AGENCIA",,"Agencia"},;
					{"EF_CONTA",,"Conta"},;
					{"EF_NUM",,"Cheque"},;
					{"EF_DATA",,"Emissao"},;
					{"EF_VALOR",,"Valor (R$)","@E 999,999,999.99"}}
	
	/* -- Referência dos parâmetros da variável aCamposTbl com a tabela SZ2 --
		Param01 = Z2_OK
		Param02 = Z2_SEQUENC
		Param03 = Z2_ITEM
		Param04 = Z2_BANCO
		Param05 = Z2_AGENCIA
		Param06 = Z2_CONTA
	*/
	
	aCamposTbl := {"EF_OK1","EF_SZ2","EF_NUM","EF_BANCO","EF_AGENCIA","EF_CONTA","","",""}
	
	/* -- Confirugação do Relatório --
		Param01 = Ordem
		Param02 = Cabec1
		Param03 = cDesc1
		Param04 = Z2_BANCO
		Param05 = Z2_AGENCIA
		Param06 = Z2_CONTA
	*/
	
	aRelatorio := {"N. LIB. | CHEQUE          | EMISSAO    | BANCO - AGENCIA/CONTA  |              VALOR",;
					"CHEQUES ENTREGUE PARA LIBERACAO"}
	aOrdemRel := {"Cheque"}
	
	DbSelectArea("SEF")
	
	U_SelItm(Alias(),cTitulo,aCamposBrw,aCamposTbl,aRelatorio,aOrdemRel)
return