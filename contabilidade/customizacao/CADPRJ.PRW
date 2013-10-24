/*______________________________________________________________________
   ¦Autor     ¦ Everson Flavio                      ¦ Data ¦ 21/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse para visualizacao dos projetos                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function CADPRJ()
	DbSelectArea("CTH")
	DbGoTop()
	
	cCadastro := "Cadastro de Projetos"
	aCores := {{"CTH_BLOQ == '1'","BR_VERMELHO"},;
				{"CTH_BLOQ == '2'","BR_VERDE"}}
	aRotina := {{"Pesquisa","AxPesqui",0,1},;
				{"Visualizar","AxVisual",0,2},;
				{"Incluir","AxInclui",0,3},;
				{"Alterar","AxALtera",0,4},;
				{"Excluir","AxExclui",0,5},;
				{"Legenda","U_Legenda()",0,6}}
	
	MBrowse(6,1,22,75,"CTH",,,,,6,aCores)
return

user function Legenda()
	aLegenda := {{"BR_VERDE","Sem Restrição"},;
					{"BR_VERMELHO","Bloqueado"}}
	
	BrwLegenda("Legenda","Projetos",aLegenda)
return (.T.)