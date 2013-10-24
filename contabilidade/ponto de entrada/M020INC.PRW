/*
+----------+----------+-------+----------------------+-----+----------------+
|Programa  |M020INC   |Autor  |EVERSON SOUZA         |Data |  14/09/09      |
+----------+----------+-------+----------------------+-----+----------------+
|Desc.     |Ponto de Entrada na inclusão do fornecedor para gerar de forma  |
|          |automatica o item contabil a partir do código e loja do         |
|          |fornecedor                                                      |
+----------+----------------------------------------------------------------+
|            ALTERACOES REALIZADAS DESDE A CRIACAO                          |
+----------+-------------+--------------------------------------------------+
| DATA     | PROGRAMADOR | DESCRICAO                                        |
+----------+-------------+--------------------------------------------------+
|          |             |                                                  |
+----------+-------------+--------------------------------------------------+
*/

#include "rwmake.ch"

User Function M020INC()


dbSelectArea("CTD")
dbSetOrder(1)
If !dbseek(xFilial("CTD")+"F"+ALLTRIM(SA2->(A2_COD+A2_LOJA)))
	cItemcont:="F"+ALLTRIM(SA2->(A2_COD+A2_LOJA))
   	dbSelectArea("CTD")
   	If Reclock("CTD",.T.)
   		Replace CTD_FILIAL With xFilial("CTD") 
        Replace CTD_ITEM   With cItemcont       
        Replace CTD_DESC01 With SA2->A2_NOME   
        Replace CTD_CLASSE With "2"            
        Replace CTD_DTEXIS With CTOD("01/01/2000") 
        Replace CTD_BLOQ   With '2'
   		MsUnlock("CTD") 
	EndIf	
EndIf
 
Return