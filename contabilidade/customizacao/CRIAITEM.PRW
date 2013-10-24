/*
+----------+----------+-------+---------------------+-----+-----------------+
|Programa  |CRIAITEM  |Autor  |EVERSON SOUZA        |Data |  14/09/09       |
+----------+----------+-------+---------------------+-----+-----------------+
|Desc.     |Programa para criar de forma automatica os itens contabies a    |
|          |a partir do cadastro de clientes e fornecedores.                |
+----------+----------------------------------------------------------------+
|            ALTERACOES REALIZADAS DESDE A CRIACAO                          |
+----------+-------------+--------------------------------------------------+
| DATA     | PROGRAMADOR | DESCRICAO                                        |
+----------+-------------+--------------------------------------------------+
|          |             |                                                  |
+----------+-------------+--------------------------------------------------+
*/


#include "rwmake.ch"
#include "topconn.ch"

User Function CRIAITEM()


cCabecalho := OemToAnsi("Atualização do Item Contabil - Fornecedores")
cMsgRegua  := "Processando..."

Processa( {|| PrcCtb01()} ,cCabecalho,cMsgRegua )

cCabecalho := OemToAnsi("Atualização do Item Contabil - Contratos Clientes")
cMsgRegua  := "Processando..."

Processa( {|| PrcCtb02()} ,cCabecalho,cMsgRegua )


Return

Static Function PrcCtb01()
*****************************************************************************************************
*
*
****

Local cItemCont := ""

dbSelectArea("SA2")
dbGoTop()

While !Eof()
	
	dbSelectArea("CTD")
	dbSetOrder(1)
	If !dbSeek(xFilial("CTD")+"F"+SA2->(A2_COD+A2_LOJA))
		cItemCont := "F"+ALLTRIM(SA2->(A2_COD+A2_LOJA))
		If RecLock("CTD",.T.)
			Replace CTD_FILIAL With xFilial("CTD") 
			Replace CTD_ITEM   With cItemcont      
			Replace CTD_DESC01 With SA2->A2_NOME   
			Replace CTD_CLASSE With "2"            
			Replace CTD_DTEXIS With CTOD("01/01/2000") 
			Replace CTD_BLOQ   With '2'
	
		    MsUnlock("CTD")
		EndIf

		If RecLock("SA2",.f.)
            Replace SA2->A2_ITEMC   With cItemcont               
			MsUnlock("SA2")
		EndIF

	EndIf	
	dbSelectArea("SA2")
	dbSkip()
End

Return


Static Function PrcCtb02()
*****************************************************************************************************
* Criacao do Item Contabil para Contratos - Clientes
*
****

Local cItemCont := ""

dbSelectArea("SA1")
dbGoTop()

While !Eof()
	
	dbSelectArea("CTD")
	dbSetOrder(1)
	If !dbSeek(xFilial("CTD")+"C"+SA1->(A1_COD+A1_LOJA))
	
		cItemCont := "C"+ALLTRIM(SA1->(A1_COD+A1_LOJA))
		If RecLock("CTD",.T.)
			Replace CTD_FILIAL With xFilial("CTD") 
			Replace CTD_ITEM   With cItemcont      
			Replace CTD_DESC01 With SA1->A1_NOME   
			Replace CTD_CLASSE With "2"            
			Replace CTD_DTEXIS With CTOD("01/01/2000") 
			Replace CTD_BLOQ   With '2'
		
			MsUnlock("CTD")
		EndIF                  
		If RecLock("SA1",.f.)
            Replace SA1->A1_ITEMC   With cItemcont               
			MsUnlock("SA1")
		EndIF
	EndIf
	dbSelectArea("SA1")
	dbSkip()
End

Return
