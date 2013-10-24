#include "protheus.ch"

user function COMPACT()
	local oButton1, oButton2, oButton3, oButton4
	local oFolder1
	local oGet1, oGet2, oGet3
	local cGet1, cGet2, cGet3
	local oGroup1, oGroup2
	local oSay1, oSay2, oSay3
	
	static oDlg
	
	cGet1 := Space(150) ; cGet2 := Space(150) ; cGet3 := Space(150)
	
	define msdialog oDlg title "Compactar/Descompactar" from 000,000 to 280,440 colors 0,16777215 pixel
		@003,003 folder oFolder1 size 213,133 of oDlg items "Compactar","Descompactar" colors 0,16777215 pixel
//		@002,003 group oGroup2 to 100,206 of oFolder1:aDialogs[1] color 0,16777215 pixel
//		@002,003 group oGroup1 to 100,206 of oFolder1:aDialogs[2] color 0,16777215 pixel
		@011,007 say oSay1 prompt "Arquivo MZP" size 035,007 of oFolder1:aDialogs[2] colors 0,16777215 pixel
		@026,007 say oSay2 prompt "Destino" size 035,007 of oFolder1:aDialogs[2] colors 0,16777215 pixel
		@041,007 say oSay3 prompt "Senha" size 035,007 of oFolder1:aDialogs[2] colors 0,16777215 pixel
		@009,045 msget oGet1 var cGet1 size 142,010 of oFolder1:aDialogs[2] picture "@!" colors 0,16777215 pixel
		@024,045 msget oGet2 var cGet2 size 142,010 of oFolder1:aDialogs[2] colors 0,16777215 pixel
		@039,045 msget oGet3 var cGet3 size 142,010 of oFolder1:aDialogs[2] colors 0,16777215 password pixel
		@104,129 button oButton1 prompt "OK" size 037,012 of oFolder1:aDialogs[2] action Compactar(oDlg,cGet1,cGet2,cGet3) pixel
		@104,169 button oButton2 prompt "Cancelar" size 037,012 of oFolder1:aDialogs[2] action oDlg:End() pixel
		@009,189 button oButton3 prompt "..." size 011,010 of oFolder1:aDialogs[2] pixel
		@024,189 button oButton4 prompt "..." size 011,010 of oFolder1:aDialogs[2] pixel
	activate msdialog oDlg centered
return

static function Compactar(oDlg,cArquivo,cDestino,cSenhaZP)
	local cArquivo := "D:\teste\sgi.mzp"
	local cDestino := "D:\teste\desc"
	local cSenhaZP := ""
	
	MsDeComp(cArquivo,cDestino,cSenhaZP)
	
	/*
	1º Exemplo:
	Compacta apenas um arquivo
	
	lRes := MsCompress("APXSRV.EXE","APXSRV.MZP")
	
	2º Exemplo:
	Compacta um diretório com senha
	aNome := {}
	ADir("*.DBF",aNome)
	lRes := MsCompress(aNome,"ArqComp.MZP","SENHA")
	*/
return