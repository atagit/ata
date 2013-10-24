/*
+----------+----------+-------+----------------------+-----+----------------+
|Programa  |M030INC   |Autor  |EVERSON SOUZA         |Data |  14/09/09      |
+----------+----------+-------+----------------------+-----+----------------+
|Desc.     |Ponto de Entrada na inclusão do cliente para gerar automatica-  |
|          |mente o item contabil a partir do código e loja do cliente.     |
+----------+----------------------------------------------------------------+
|            ALTERACOES REALIZADAS DESDE A CRIACAO                          |
+----------+-------------+--------------------------------------------------+
| DATA     | PROGRAMADOR | DESCRICAO                                        |
+----------+-------------+--------------------------------------------------+
|          |             |                                                  |
+----------+-------------+--------------------------------------------------+
*/

#include "rwmake.ch"

User Function M030INC()


dbSelectArea("CTD")
dbSetOrder(1)
If !dbseek(xFilial("CTD")+"C"+ALLTRIM(SA1->(A1_COD+A1_LOJA)))
	cItemcont:="C"+ALLTRIM(SA1->(A1_COD+A1_LOJA))
   	dbSelectArea("CTD")
   	If Reclock("CTD",.T.)
   		Replace CTD_FILIAL With xFilial("CTD") 
        Replace CTD_ITEM   With cItemcont       
        Replace CTD_DESC01 With SA1->A1_NOME   
        Replace CTD_CLASSE With "2"            
        Replace CTD_DTEXIS With CTOD("01/01/2000") 
        Replace CTD_BLOQ   With '2'
   		MsUnlock("CTD") 
	EndIf	
EndIf
 
Return