/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 09/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. Rodapé do pedido de venda                        ¦
   ¦          ¦ Pegar o valor total do pedido de venda                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MT410ROD()
	public nValPed
	
	Eval(PARAMIXB[1],PARAMIXB[2],PARAMIXB[3],PARAMIXB[4],PARAMIXB[5])
	nValPed := PARAMIXB[3]
return