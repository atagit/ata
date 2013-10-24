/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/03/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Adiciona botão na tela de geração cheques             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function F190BROW()
	AAdd(aRotina,{"Impr. Cheque","FINR480",0,3})
	AAdd(aRotina,{"Bom Para","U_BOMPARA()",0,8})
return