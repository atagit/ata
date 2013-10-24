user function C1PRODUTO()
	local cFlag := ""
	
	for i := 1 to Len(aCols) - 1
		if M->C1_PRODUTO == aCols[i][2]
			cFlag := IIf(Empty(aCols[i][29]),"001",StrZero(Val(aCols[i][29]) + 1,3))
		else
			cFlag := "001"
		endif
	next
return(cFlag)