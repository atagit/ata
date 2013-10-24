/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 31/07/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse cadastro de tabelas Controle de IQF            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function C_SZV()
	private aArea := GetArea()
	private cCadastro := "Controle IQF"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5},;
						{"Legenda","U_LEGORCA()",0,6}}
	
	aColors := {{"ZV_QTPEDID > ZV_MAXPED","BR_VERMELHO"},;
				{"ZV_QTPEDID < ZV_MAXPED","BR_VERDE"},;
				{"ZV_QTPEDID == ZV_MAXPED","BR_AMARELO"}}
	
	DbSelectArea("SZV")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZV",,,,,,aColors)
	RestArea(aArea)
return

user function LEGSZV()
	local aLegenda := {}
	
	AAdd(aLegenda,{"BR_VERDE","Qtd de Pedido menor que a quantidade máxima"})
	AAdd(aLegenda,{"BR_VERMELHO","Qtd de Pedido maior que a quantidade máxima"})
	AAdd(aLegenda,{"BR_AMARELO","Qtd de Pedido igual a quantidade máxima"})
	
	BrwLegenda(cCadastro,"Legenda",aLegenda)
return(.T.)