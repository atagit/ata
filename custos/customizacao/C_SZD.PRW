/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 13/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição : Cadastro de Organograma                               ¦
   ¦          : Atualiza Organograma via SRA-Funcionários             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#INCLUDE "rwmake.ch"

User Function C_SZD

Private cCadastro := "Cadastro de Organograma"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             		{"Visualizar","AxVisual",0,2} ,;
             		{"Incluir","AxInclui",0,3} ,;
             		{"Alterar","AxAltera",0,4} ,;
             		{"Excluir","AxDeleta",0,5} ,;
             		{"Verif.Cad.Func.","U_P_SRA",0,5} ,;
             		{"Imprimir","U_RELSZD()",0,6} }             		

Private cDelFunc := ".T." 

Private cString := "SZD"

dbSelectArea("SZD")
dbSetOrder(1)


dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return
