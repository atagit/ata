
USER FUNCTION INIF1FOR()

IF SF1->F1_TIPO $ 'D,B'
	Posicione("SA1",1,xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA,"A1_NOME")
	Else
	Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_NOME")	
End If

RETURN