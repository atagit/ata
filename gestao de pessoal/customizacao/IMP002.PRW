/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar departamentos do MFOLHA                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function IMP002()
	local oDlg, oFont
	
	private aAreaAnt := GetArea()
	
	define font oFont name "Arial" size 000,-12
	define msdialog oDlg title "IMPORTACAO MFOLHA" from 000,000 to 250,500 pixel
		@005,010 to 100,242 pixel
		@010,015 say "Esta rotina tem como objetivo importar o(s) departamento(s) cadastrado" pixel font oFont of oDlg
		@020,015 say "no sistema MFOLHA da Mastermaq." pixel font oFont of oDlg
		@105,147 bmpbutton type 05 action Pergunte("MDEPTO",.T.)
		@105,179 bmpbutton type 01 action ImportarDepto(oDlg)
		@105,211 bmpbutton type 02 action Close(oDlg)
	activate msdialog oDlg centered
return

static function ImportarDepto(oDlg)
	local cDeptoIni := ""
	local cDeptoFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Departamento de                                   ³
	//³ mv_par02 - Departamento ate                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if Empty(mv_par01) .and. Empty(mv_par02)
		MsgBox("Favor entrar nos parametros e configura-lo.","Alerta","ALERT")
		
		return
	endif
	
	cDeptoIni := mv_par01
	cDeptoFin := mv_par02
	
	Processa({|| U_IncluirDepto(cDeptoIni,cDeptoFin,.T.)},"","Aguarde processando...",.T.)
	
	RestArea(aAreaAnt)
return

user function IncluirDepto(cDeptoIni,cDeptoFin,lMsg)
	local cTblDEPTO := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\DEPTO016.DBF","\DADOS1\DEPTO003.DBF")
	local cIndDEPTO := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\DEPTO016.IDX","\DADOS1\DEPTO003.IDX")
	local cCodDepto := ""
	local nContReg := 0
	local cRet := ""
	
	DbUseArea(.T.,"DBFCDX",cTblDEPTO,"DEP",.T.,.F.)
	DbSetIndex(cIndDEPTO)
	DEP->(DbGoTop())
	DEP->(DbSeek(cDeptoIni,.F.))
	
	while !DEP->(Eof()) .and. DEP->DEPTO >= cDeptoIni .and. DEP->DEPTO <= cDeptoFin
		nContReg++
		
		DEP->(DbSkip())
	enddo
	
	DbSelectArea("SQB")
	SQB->(DbSetOrder(6))
	
	ProcRegua(nContReg)
	
	DEP->(DbGoTop())
	DEP->(DbSeek(cDeptoIni,.F.))
	
	while !DEP->(Eof()) .and. DEP->DEPTO >= cDeptoIni .and. DEP->DEPTO <= cDeptoFin
		SBQ->(DbGoTop())
		
		if !(SQB->(DbSeek(xFilial("SQB")+DEP->DEPTO,.F.)))
			cCodDepto := GetSXENum("SQB","QB_DEPTO")
			
			RecLock("SQB",.T.)
				SQB->QB_FILIAL := xFilial()
				SQB->QB_DEPTO := cCodDepto
				SQB->QB_DESCRIC := DEP->NOME
				SQB->QB_NREDUZ := DEP->ABREV
				SQB->QB_MFOLHA := DEP->DEPTO
			MsUnLock()
			ConfirmSX8()
		else
			if !lMsg
				cRet := SQB->QB_DEPTO
			endif
		endif
		
		IncProc()
		DEP->(DbSkip())
	enddo
	
	if lMsg
		MsgInfo("Departamento(s) importado com sucesso!")
	endif
	
	DEP->(DbCloseArea())
return cRet