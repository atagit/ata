/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 05/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. acrescenta campo na Posicao Tit. Pag.            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function FC050CAMPOS()
	aCampos	:= {{"OK","N",1,0},;
				{"DATAX     ","D",08,0},;
				{"JUROS     ","N",16,2},;
				{"MULTA     ","N",16,2},;
				{"CORRECAO  ","N",16,2},;
				{"DESCONTOS ","N",16,2},;
				{"PIS       ","N",16,2},;
				{"COFINS    ","N",16,2},;
				{"CSLL      ","N",16,2},;
				{"VALORPAGO ","N",16,2},;
				{"MOTIVO    ","C",03,0},;
				{"HISTORICO ","C",40,0},;
				{"DATACONT  ","D",08,0},;
				{"DATADISP  ","D",08,0},;
				{"LOTE      ","C",08,0},;
				{"BANCO     ","C",03,0},;
				{"AGENCIA   ","C",05,0},;
				{"CONTA     ","C",10,0},;
				{"NROCHEQUE ","C",15,0},;
				{"E5_NUMTED ","C",06,0},;
				{"DOCUMENTO ","C",50,0},;
				{"FILIAL    ","C",02,0},;
				{"RECONC    ","C",01,0}}
return aCampos