/*
+----------+----------+-------+---------------------+-----+-----------------+
|Programa  |A020DELE  |Autor  |EVERSON SOUZA        |Data |  14/09/09       |
+----------+----------+-------+---------------------+-----+-----------------+
|Desc.     |Ponto de Entrada na exclusão do fornecedor para excluir automa- |
|          |ticamente o item contabil a partir do código e loja do mesmo.   |
+----------+----------------------------------------------------------------+
|            ALTERACOES REALIZADAS DESDE A CRIACAO                          |
+----------+-------------+--------------------------------------------------+
| DATA     | PROGRAMADOR | DESCRICAO                                        |
+----------+-------------+--------------------------------------------------+
|          |             |                                                  |
+----------+-------------+--------------------------------------------------+
*/

#include "rwmake.ch"

User Function A020DELE()


dbSelectArea("CTD")
dbSetOrder(1)
If dbseek(xFilial("CTD")+"F"+ALLTRIM(SA2->(A2_COD+A2_LOJA)))
	If Reclock("CTD",.F.)
		dbDelete()
		MsUnlock("CTD")
	EndIf
EndIf

Return(.T.)
