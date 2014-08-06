/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 05/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. acrescenta campo na Posicao Tit. Pag.            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function FC050BROWSE()
	aCampos	:= {{"  ","OK"},;
				{"Data","DATAX"},;
				{"Juros","JUROS"},;
				{"Multa","MULTA"},;
				{"Correção","CORRECAO"},;
				{"Descontos","DESCONTOS"},;
				{"PIS","PIS"},;
				{"Cofins","COFINS"},;
				{"CSLL","CSLL"},;
				{"Valor Pago","VALORPAGO"},;
				{"Motivo","MOTIVO"},;
				{"Histórico","HISTORICO"},;
				{"Data Contabilização","DATACONT"},;
				{"Data Disponibilidade","DATADISP"},;
				{"Lote","LOTE"},;
				{"Banco","BANCO"},;
				{"Agência","AGENCIA"},;
				{"Conta","CONTA"},;
				{"N.Cheque","NROCHEQUE"},;
				{"N. TED","E5_NUMTED"},;
				{"Documento","DOCUMENTO"},;
				{"Filial Movto.","FILIAL"},;
				{"Reconciliado","RECONC"}}
return aCampos