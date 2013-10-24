User Function Cbc(cEmp,cNum,cTit,cCab1,cCab2,cDesc,cTam,cNome)
	if aReturn[5] == 1
		Cabec(cTit,cCab1,cCab2,cNome,cTam,15)
		
		nLin := If(Empty(cCab2),7,8)
		
		if !Empty(cCbcRef) ; nLin++ ; endif
	elseif aReturn[5] == 3
		@000,000 PSay U_TamPag(66)+U_Reduz(0)
		
		Do Case
			Case cEmp == "01"
				@001,000 PSay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T A"+U_Expande(0)+U_AltCar(12)
			Case cEmp == "02"
				@001,000 PSay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T F"+U_Expande(0)+U_AltCar(12)
			Otherwise
				@001,000 PSay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"TESTE"+U_Expande(0)+U_AltCar(12)
		EndCase
		
		@001,014 PSay U_Expande(5)+Padc(AllTrim(MemoLine(cTit,22,1)),22)
		
		If !Empty(cNum)
			@001,031 PSay "N§ "+cNum+U_Expande(0)
		Else
			@001,031 PSay " "+U_Expande(0)
		EndIf
		
		Do Case
			Case cEmp == "01"
				@002,000 PSay U_Reduz(5)+"INDUSTRIA   MECANICA"+U_Reduz(0)
			Case cEmp == "02"
				@002,000 PSay U_Reduz(5)+"ESTRUTURAS METALICAS"+U_Reduz(0)
			Otherwise
				@002,000 PSay U_Reduz(5)+"TESTE DESENVOLVIMENT"+U_Reduz(0)
		EndCase
		
		if Len(cTit) > 22
			@002,014 PSay U_Expande(5)+Padc(AllTrim(MemoLine(cTit,22,2)),22)+U_Expande(0)
			@002,051 PSay U_Reduz(5)+"Emissao: "+U_ConvData(DToS(Date()))+U_Reduz(0)
		else
			@002,081 PSay U_Reduz(5)+"Emissao: "+U_ConvData(DToS(Date()))+U_Reduz(0)
		endif
		
		@003,000 PSay U_15Cpi(.T.)
		
		nLin := 003
		
		if !Empty(cDesc)
			@++nLin,000 psay cDesc
			@++nLin,000 psay Replicate("=",136)
		endif
		
		@++nLin,000 psay If(!Empty(cCab1),cCab1,"")
		
		if !Empty(cCab2)
			@++nLin,000 psay cCab2
		endif
		
		@++nLin,000 psay Replicate("-",136)
		
		nLin++
	endif
Return

User Function Rdp(nPag,cLeg,cTam)
	local nCntImpr := nPag
	local cRodaTxt := OemToAnsi("Rodape de TESTE")
	
	if aReturn[5] == 1
//		Roda(nPag,cRodaTxt,cTam)
	elseif aReturn[5] == 3
		@059,000 PSay U_15Cpi(.T.)
		@059,000 PSay cLeg
		@060,000 PSay Replicate("=",136)
		@061,000 PSay "Fonte: ..\"+FunName()+".PRW"
		@061,128 PSay "Pag. "+StrZero(nPag,3)
	endif
Return

User Function SaltaFolha(nSalto,cCbc1,cCbc2)
	local lRet := .F.
//	local nQtdPag := If(aReturn[5] == 1,65,55)
//	nSalto := IIf(Empty(nSalto),55,nSalto)
	
/*	if Empty(nSalto)
		nSalto := IIf(aReturn[5] == 1,60,55)
	endif*/
	
/*	if nLin >= nSalto
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nRdpPag++
	endif*/
	
	if aReturn[5] == 1
		nSalto := IIf(Empty(nSalto),65,nSalto)
		
		if nLin >= nSalto
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			nRdpPag++
			lRet := .T.
		endif
	else
		nSalto := IIf(Empty(nSalto),55,nSalto)
		
		if nLin >= nSalto
			U_Rdp(nRdpPag,cRdpLeg,Tamanho)
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			nRdpPag++
			lRet := .T.
		endif
	endif
Return lRet

User Function Orienta()
	Return (Chr(027)+Chr(038)+Chr(108)+Chr(049)+Chr(079))
Return Nil

User Function TamPap(PAPEL)
	Do Case
		Case PAPEL = "CARTA"
			Return (Chr(027)+"C")+Ltrim(Str(66,3,0))
		Case PAPEL = "OFICIO"
			Return (Chr(027)+"C")+Ltrim(Str(84,3,0))
		Case PAPEL = "A4"
			Return (Chr(027)+"C")+Ltrim(Str(70,3,0))
		Case PAPEL = "ENVELOPE"
			Return (Chr(027)+"C")+Ltrim(Str(16,3,0))
	EndCase
Return Nil

User Function TamPag(QuantLin)
	Return (Chr(27)+"C"+Chr(QuantLin))
Return Nil

User Function QuantLin(QuantL)
	Return (Chr(27)+Ltrim(Str(8-QuantL,2,0)))
Return Nil

User Function AltCar(Altura)
	If Altura=24
		Return (Chr(27)+"w"+Chr(1))
	Else
		Return (Chr(27)+"w"+Chr(0))
	EndIf
Return Nil

User Function Expande(nNum)
	Do Case
		Case nNum = 5
			Return (Chr(27)+Chr(87)+Chr(49))
		Case nNum = 6
			Return (Chr(27)+"!"+Chr(33))
		Case nNum = 8
			Return (Chr(27)+"!"+Chr(36))
		Case nNum = 10
			Return (Chr(27)+"!"+Chr(37))
		Otherwise
			Return (Chr(27)+"!"+Chr(0))
	EndCase
Return Nil

User Function Reduz(nReduz)
	Return (Chr(27)+"!"+Chr(nReduz))
Return Nil

User Function Negrito(lNeg)
	If lNeg == .T.
		Return (Chr(27)+Chr(69))
	Else
		Return (Chr(27)+Chr(70))
	EndIf
Return Nil

User Function 15Cpi(lCpi)
	If lCpi == .T.
		Return Chr(15)
	Else
		Return Chr(18)
	EndIf
Return Nil

User Function L8PolOn(lPol)
	If lPol == .T.
		Return Chr(27)+Chr(48)
//		Return Chr(27)+"0"
	Else
		Return Chr(27)+"2"
	EndIf
Return Nil

User Function DoubleStroke()
	Return Chr(27)+"G"
Return Nil

User Function Super()
	Return Chr(15)+Chr(27)+'M'
Return Nil