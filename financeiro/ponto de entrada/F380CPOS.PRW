/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/04/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. alterar ordem campos na selecao da conciliacao   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"

user function F380CPOS()
	aCampos := {{"E5_OK",,"Rec."},;
				{"E5_DTDISPO",,"DT Disponivel"},;
				{"E5_MOEDA",,"Numerario"},;
				{"E5_VALOR",,"Vlr. Movimen.",PesqPict("SE5","E5_VALOR",19)},;
				{"E5_NATUREZ",,"Natureza"},;
				{"E5_BANCO",,"Banco"},;
				{"E5_AGENCIA",,"Agencia"},;
				{"E5_CONTA",,"Conta"},;
				{"E5_NUMCHEQ",,"Num. Cheque"},;
				{"E5_NUMTED",,"Num. TED"},;
				{"E5_DOCUMEN",,"Documento"},;
				{"E5_VENCTO",,"Vencimento"},;
				{"E5_DATA",,"DT Movimento"},;
				{"E5_RECPAG",,"Rec/Pag"},;
				{"E5_BENEF",,"Beneficiario"},;
				{"E5_HISTOR",,"Historico"},;
				{"E5_CREDITO",,"Cta Credito"},;
				{"E5_PREFIXO",,"Prefixo"},;
				{"E5_NUMERO",,"Numero"},;
				{"E5_PARCELA",,"Parcela"},;
				{"E5_TIPO",,"Tipo"},;
				{"E5_CLIFOR",,"Cli/For"},;
				{"E5_LOJA",,"Loja"}}
return aCampos