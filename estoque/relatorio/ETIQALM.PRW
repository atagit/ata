#include "totvs.ch"

user function ETIQALM()
	private cAcesso := Repl(" ",10)
	
	oPrint := TMSPrinter():New("ETIQUETAS")
	
	oPrint:SetPortrait()
	oPrint:Setup()
	oPrint:StartPage()
	
	oFont1 := TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	oFont1n := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	
//	oPrint:Say(010,010,"Texto para visualização",oFont1)
//	oPrint:Say(100,010,"Texto para visualização",oFont1n)
	oPrint:Say(150,010,"Texto para visualização Texto para visualiza",oFont1)
	oPrint:Say(150,1280,"Texto para visualização Texto para visualiza",oFont1)
	
	oPrint:EndPage()
	oPrint:Preview()
return