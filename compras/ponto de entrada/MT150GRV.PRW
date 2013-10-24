/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Lançamento do frete, após gravação da cotacao no SC8  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MT150GRV()
	U_FRETE("COTACAO",CA150NUM,CA150FORN,CA150LOJ,"SC8")
return