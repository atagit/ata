/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 24/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse para cadastro de setor                         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function C_SZ6()
	private cCadastro := "Setor"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5}}
	
	DbSelectArea("SZ6")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZ6")
return