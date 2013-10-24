/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 13/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cadastro de  Despesas Realizadas x CC                 ¦
   ¦          : - Atualiza Quadro de Custos                           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#INCLUDE "rwmake.ch"

User Function C_SZG

// filtra COD.DEPESAS diferentes de Titulo, para Consulta Padrão 
dbSelectArea("SZB")
dbSetOrder(1)    
SET FILTER TO SZB->ZB_TITULO='2'


Private cCadastro := "Despesas realizadas x CC"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             		{"Visualizar","AxVisual",0,2} ,;
             		{"Incluir","AxInclui",0,3} ,;
             		{"Alterar","AxAltera",0,4} ,;
             		{"Excluir","AxDeleta",0,5} ,;
             		{"Atualizar Quad Custo","U_P_SZG()",0,6} }
             		

Private cDelFunc := ".T." 


Private cString := "SZG"

dbSelectArea("SZG")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

dbSelectArea("SZB")
dbSetOrder(1)    
SET FILTER TO 

Return
