/*______________________________________________________________________
   �Autor     � Breno Ferreira                      � Data � 05/08/14 �
   +----------+-------------------------------------------------------�
   �Descri��o � P.E. acrescenta campo na Posicao Tit. Pag.            �
  ����������������������������������������������������������������������*/
#include "rwmake.ch"
#include "protheus.ch"

user function FC050BROWSE()
	aCampos	:= {{"  ","OK"},;
				{"Data","DATAX"},;
				{"Juros","JUROS"},;
				{"Multa","MULTA"},;
				{"Corre��o","CORRECAO"},;
				{"Descontos","DESCONTOS"},;
				{"PIS","PIS"},;
				{"Cofins","COFINS"},;
				{"CSLL","CSLL"},;
				{"Valor Pago","VALORPAGO"},;
				{"Motivo","MOTIVO"},;
				{"Hist�rico","HISTORICO"},;
				{"Data Contabiliza��o","DATACONT"},;
				{"Data Disponibilidade","DATADISP"},;
				{"Lote","LOTE"},;
				{"Banco","BANCO"},;
				{"Ag�ncia","AGENCIA"},;
				{"Conta","CONTA"},;
				{"N.Cheque","NROCHEQUE"},;
				{"N. TED","E5_NUMTED"},;
				{"Documento","DOCUMENTO"},;
				{"Filial Movto.","FILIAL"},;
				{"Reconciliado","RECONC"}}
return aCampos