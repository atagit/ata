/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 19/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cadastro de Euipamentos                               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#INCLUDE "rwmake.ch"

User Function C_SZJ

Private cCadastro := "Equipamentos"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             		{"Visualizar","AxVisual",0,2} ,;
             		{"Incluir","AxInclui",0,3} ,;
             		{"Alterar","AxAltera",0,4} ,;
             		{"Excluir","AxDeleta",0,5} ,;
             		{"Imprimir","U_RELSZJ",0,6} ,;
             		{"Rateios/Provisao","U_P_SZJ()",0,7} }

Private cDelFunc := ".T." 

Private cString := "SZJ"

dbSelectArea("SZJ")
dbSetOrder(1)


dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return
