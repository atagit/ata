/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar funções do MFOLHA                            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function IMP001()
	local oDlg, oFont
	
	private aAreaAnt := GetArea()
	
	define font oFont name "Arial" size 000,-12
	define msdialog oDlg title "IMPORTACAO MFOLHA" from 000,000 to 250,500 pixel
		@005,010 to 100,242 pixel
		@010,015 say "Esta rotina tem como objetivo importar a(s) funcao(oes) cadastrado" pixel font oFont of oDlg
		@020,015 say "no sistema MFOLHA da Mastermaq." pixel font oFont of oDlg
		@105,147 bmpbutton type 05 action Pergunte("MFCOE",.T.)
		@105,179 bmpbutton type 01 action ImportarFuncao(oDlg)
		@105,211 bmpbutton type 02 action Close(oDlg)
	activate msdialog oDlg centered
return

static function ImportarFuncao(oDlg)
	local cFunIni := ""
	local cFunFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Funcao de                                         ³
	//³ mv_par02 - Funcao ate                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if Empty(mv_par01) .and. Empty(mv_par02)
		MsgBox("Favor entrar nos parametros e configura-lo.","Alerta","ALERT")
		
		return
	endif
	
	cFunIni := mv_par01
	cFunFin := mv_par02
	
	Processa({|| U_IncluirFuncao(cFunIni,cFunFin,.T.)},"","Aguarde processando...",.T.)
	RestArea(aAreaAnt)
return

user function IncluirFuncao(cFunIni,cFunFin,lMsg)
	local cTblFCOES := "\\ATFSRV001\mastermaq$\MFOLHA\FCOES.DBF"
	local cIndFCOES := "\\ATFSRV001\mastermaq$\MFOLHA\FCOES.IDX"
	local cCodFuncao := ""
	local nContReg := 0
	local cRet := ""
	
	DbUseArea(.T.,"DBFCDX",cTblFCOES,"FCO",.T.,.F.)
	DbSetIndex(cIndFCOES)
	FCO->(DbGoTop())
	FCO->(DbSeek(cFunIni,.T.))
	
	while !FCO->(Eof()) .and. FCO->FUNCAO >= cFunIni .and. FCO->FUNCAO <= cFunFin
		nContReg++
		
		FCO->(DbSkip())
	enddo
	
	DbSelectArea("SRJ")
	SRJ->(DbSetOrder(5))
	
	ProcRegua(nContReg)
	
	FCO->(DbGoTop())
	FCO->(DbSeek(cFunIni,.T.))
	
	while !FCO->(Eof()) .and. FCO->FUNCAO >= cFunIni .and. FCO->FUNCAO <= cFunFin
		SRJ->(DbGoTop())
		
		if !(SRJ->(DbSeek(xFilial("SRJ")+FCO->FUNCAO,.F.)))
			cCodFuncao := GetSXENum("SRJ","RJ_FUNCAO")
			
			RecLock("SRJ",.T.)
				SRJ->RJ_FILIAL := xFilial()
				SRJ->RJ_FUNCAO := cCodFuncao
				SRJ->RJ_DESC := FCO->NOME
				SRJ->RJ_NREDUZ := FCO->ABREV
				SRJ->RJ_CODCBO := FCO->CBO
				SRJ->RJ_CBO := "00000"
				SRJ->RJ_MFOLHA := FCO->FUNCAO
			MsUnLock()
			ConfirmSX8()
		else
			if !lMsg
				cRet := SRJ->RJ_FUNCAO
			endif
		endif
		
		IncProc()
		FCO->(DbSkip())
	enddo
	
	if lMsg
		MsgInfo("Funcao(oes) importado com sucesso!")
	endif
	
	FCO->(DbCloseArea())
return cRet