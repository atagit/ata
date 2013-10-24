/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 18/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse cadastro do saldo bancario                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function C_SZP()
	private cCadastro := "Sald Bancario"
/*	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Cancelar","U_SZUCanc()",0,6}}*/
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Excluir","AxDeleta",0,5}}
	
	DbSelectArea("SZP")
	DbSetOrder(1)
	MBrowse(06,01,22,75,"SZP")
return