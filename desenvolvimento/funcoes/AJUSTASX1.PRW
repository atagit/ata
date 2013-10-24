User Function AjustaSX1(cPerg, aPergs)
	Local _sAlias	:= Alias()
	Local aCposSX1	:= {}
	Local nX 		:= 0
	Local lAltera	:= .F.
	Local nCondicao
	Local cKey		:= ""
	Local nJ			:= 0
	
	aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
				"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
				"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
				"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
				"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
				"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
				"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
				"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }
	
	dbSelectArea("SX1")
	dbSetOrder(1)        
	
	For nX :=1 to Len(aPergs)
		lAltera := .F.   		
		If msseek(cPerg+Right(aPergs[nX][11],2),.F.)
			If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
				 Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
				aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
				lAltera := .T.
			Endif
		Endif
		
		If !lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]	
	 		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	 	Endif	
		
		If !Found() .Or. lAltera
			RecLock("SX1",If(lAltera, .F., .T.))
			Replace X1_GRUPO with cPerg
			Replace X1_ORDEM with Right(aPergs[nX][11], 2)
			For nj:=1 to Len(aCposSX1)
				If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
					FieldPos(AllTrim(aCposSX1[nJ])) > 0
					Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
				Endif
			Next nj
			MsUnlock()
			cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
	
			If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
				aHelpSpa := aPergs[nx][Len(aPergs[nx])]
			Else
				aHelpSpa := {}
			Endif
			
			If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
				aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
			Else
				aHelpEng := {}
			Endif
	
			If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
				aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
			Else
				aHelpPor := {}
			Endif
	
			PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		Endif
	Next
Return