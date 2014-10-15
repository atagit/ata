/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Acertar o codigo da funcao conforme Mastermaq         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function IMP004()
	local oDlg, oFont
	
	private aAreaAnt := GetArea()
	
	define font oFont name "Arial" size 000,-12
	define msdialog oDlg title "ACERTAR FUNCAO" from 000,000 to 250,500 pixel
		@005,010 to 100,242 pixel
		@010,015 say "Esta rotina tem como objetivo acertar a(s) funcao(oes) dos funcionarios" pixel font oFont of oDlg
		@020,015 say "cadastrado no Microsiga, conforme cadastro no sistema MFOLHA da Mastermaq." pixel font oFont of oDlg
		@105,147 bmpbutton type 05 action Pergunte("MFUNC",.T.)
		@105,179 bmpbutton type 01 action AcertarFuncao(oDlg)
		@105,211 bmpbutton type 02 action Close(oDlg)
	activate msdialog oDlg centered
return

static function AcertarFuncao(oDlg)
	local cMatIni := ""
	local cMatFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Matricula de                                      ³
	//³ mv_par02 - Matricula ate                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if Empty(mv_par01) .and. Empty(mv_par02)
		MsgBox("Favor entrar nos parametros e configura-lo.","Alerta","ALERT")
		
		return
	endif
	
	cMatIni := mv_par01
	cMatFin := mv_par02
	
	Processa({|| AlterarFuncao(cMatIni,cMatFin)},"","Aguarde processando...",.T.)
	RestArea(aAreaAnt)
return

static function AlterarFuncao(cMatIni,cMatFin)
	local cTblFUN := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\FUNCS016.DBF","\DADOS1\FUNCS003.DBF")
	local cIndFUN := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\FUNCS016.IDX","\DADOS1\FUNCS003.IDX")
	local cCodFuncao := ""
	local nContReg := 0
	local cRet := ""
	
	DbUseArea(.T.,"DBFCDX",cTblFUN,"FUN",.T.,.F.)
	DbSetIndex(cIndFUN)
	FUN->(DbGoTop())
	FUN->(DbSeek(cMatIni,.F.))
	
	while !FUN->(Eof()) .and. FUN->FUNCC >= cMatIni .and. FUN->FUNCC <= cMatFin
		nContReg++
		
		FUN->(DbSkip())
	enddo
	
	DbSelectArea("SRA")
	ProcRegua(nContReg)
	FUN->(DbGoTop())
	FUN->(DbSeek(cMatIni,.F.))
	
	while !FUN->(Eof()) .and. FUN->FUNCC >= cMatIni .and. FUN->FUNCC <= cMatFin
		SRA->(DbGoTop())
		
		if SRA->(DbSeek(xFilial("SRA")+FUN->FUNCC,.F.))
			SRJ->(DbSetOrder(5))
			SRJ->(DbGoTop())
			
			cCodFuncao := IIf(SRJ->(DbSeek(xFilial("SRJ")+FUN->FUNCAO,.F.)),SRJ->RJ_FUNCAO,"")
			
			if !Empty(cCodFuncao)
				RecLock("SRA",.F.)
					SRA->RA_CODFUNC := cCodFuncao
				MsUnLock()
			endif
		endif
		
		IncProc()
		FUN->(DbSkip())
	enddo
	
	MsgInfo("A(s) funcao(oes) do(s) funcionario(s) foi(ram) acertado(s)!")
	FUN->(DbCloseArea())
return