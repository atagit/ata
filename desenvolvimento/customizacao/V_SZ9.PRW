/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 12/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse para visualizacao de CEP do Correio            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function V_SZ9()
	dbselectarea("SZ9")
	dbgotop()
	
	cCadastro := "Correio - CEP"
	aRotina := {{"Pesquisa","AxPesqui",0,1},;
				{"Visualizar","AxVisual",0,2}}
	
	mbrowse(6,1,22,75,"SZ9")
return