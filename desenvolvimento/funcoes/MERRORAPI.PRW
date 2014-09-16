/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 19/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Retornar a mensagem de error na importacao da API     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MERRORAPI(nE)
	local cRet := ""
	
	do case
		case nE == 1
			cRet := "Produto não encontrado"
		case nE == 2
			cRet := "Produto bloqueado para uso"
		case nE == 3
			cRet := "Quantidade em estoque insuficiente"
		case nE == 4
			cRet := "Saldo Em Estoque não encontrado"
		case nE == 5
			cRet := "Projeto não encontrado"
		case nE == 6
			cRet := "Armazem do produto diferene do 05"
		case nE == 98
			cRet := "Error do sistema (ExecAuto)"
		case nE == 99
			cRet := "Error ao atualizar o campo NUMSEQ na tabela TBLAPI"
		otherwise
			cRet := "Error não identificado"
	endcase
return cRet