/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse para visualizacao do Frete da Cotacao          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function V_SZ1()
	dbselectarea("SZ1")
	dbgotop()
	
	cCadastro := "Frete por Cotacao"
	aRotina := {{"Pesquisa","AxPesqui",0,1},;
				{"Visualizar","AxVisual",0,2}}
	
	mbrowse(6,1,22,75,"SZ1")
return