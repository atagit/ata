/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cadastro de Códigos de Despesas                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#INCLUDE "rwmake.ch" 

User Function C_SZB

Private cCadastro := "Cadastro de Códigos de Despesas"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             		{"Visualizar","AxVisual",0,2} ,;
             		{"Incluir","AxInclui",0,3} ,;
             		{"Alterar","AxAltera",0,4} ,;
             		{"Excluir","AxDeleta",0,5} ,;
             		{"Imprimir","U_RELSZB()",0,6} ,;
             		{"Verifica Requisiçoes","U_RELSD3()",0,7} ,;
             		{"Verifica N.Fiscal   ","U_RELSD1()",0,8} ,;
             		{"Atualiza Req./NF_ent","U_PASD3()",0,9} }
             		
Private cDelFunc := ".T." 

Private cString := "SZB"

dbSelectArea("SZB")
dbSetOrder(1)


dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return
