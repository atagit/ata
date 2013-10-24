/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cadastro de Direcionador de Custos - DC               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#INCLUDE "rwmake.ch"

User Function C_SZA

Private cCadastro := "Cadastro de Direciondor de Custos"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             		{"Visualizar","AxVisual",0,2} ,;
             		{"Incluir","AxInclui",0,3} ,;
             		{"Alterar","AxAltera",0,4} ,;
             		{"Excluir","AxDeleta",0,5} ,;
             		{"Imprimir","U_RELSZA()",0,6} }

Private cDelFunc := ".T." 

Private cString := "SZA"

dbSelectArea("SZA")
dbSetOrder(1)


dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return
