/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 19/01/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de Acompanhamento Financeiro x Faturamento  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

#define _DIASEM {"DOM","SEG","TER","QUA","QUI","SEX","SAB"}
#define _MES {"JANEIRO","FEVEREIRO","MARCO","ABRRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
#define _RELCRY "CRY004"

/*user function CRY004()
	private cCadastro := "Saldo Acompanhamento"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5}}
	
	DbSelectArea("SZS")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZS")
return*/

user function CRY004()
	local cArqDBF := GetMV("MV_DBFCRY")+_RELCRY+".DBF"
	local cAno := ""
	local cMes := ""
	local aTabela := {}
	
	private cReport := _RELCRY
	private cOpcoes := "1;0;1;Relatorio de Acompanhamento"
	private cParam  := AllTrim(cEmpAnt)+";"+AllTrim(cFilAnt)+";"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Ano                                               ³
	//³ mv_par02 - Mes                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("CRY004",.T.)
	
	cAno := mv_par01
	cMes := mv_par02
	
	DbSelectArea("SZS")
	ProcRegua(SZS->(RecCount()))
	SZS->(DbGoTop())
	
	if SZS->(DbSeek(xFilial("SZS")+cAno+cMes,.F.))
		while !SZS->(Eof()) .and. SZS->(ZS_ANO+ZS_MES) == cAno+cMes
			AAdd(aTabela,{SZS->ZS_DIA,SZS->ZS_RECFIN,SZS->ZS_PAGFIN,SZS->ZS_SLDFIN,SZS->ZS_RECFAT,SZS->ZS_PAGFAT,SZS->ZS_SLDFAT})
			
			SZS->(DbSkip())
		enddo
		
		for i := 1 to Last_Day(SToD(cAno+cMes+"01"))
			if (nInd := AScan(aTabela,{|x| x[1] = StrZero(i,2)})) == 0
				AAdd(aTabela,{StrZero(i,2),0,0,0,0,0,0})
			endif
		next
		
		ASort(aTabela,,,{|x,y| x[1] < y[1]})
		DbUseArea(.T.,"DBFCDX",cArqDBF,"TRB",.F.,.F.)
		
		ZAP
		
		for i := 1 to Len(aTabela)
			RecLock("TRB",.T.)
				TRB->EMPRESA := cEmpAnt
				TRB->DIA := aTabela[i][1]
				TRB->MES := _MES[Val(cMes)]
				TRB->ANO := cAno
				TRB->RECFIN := aTabela[i][2]
				TRB->PAGFIN := aTabela[i][3]
				TRB->SLDFIN := aTabela[i][4]
				TRB->RECFAT := aTabela[i][5]
				TRB->PAGFAT := aTabela[i][6]
				TRB->SLDFAT := aTabela[i][7]
			MsUnLock()
			IncProc()
		next
		
		TRB->(DbCloseArea())
		CallCrys(cReport,cParam,cOpcoes)
	else
		MsgAlert("O ANO e MES de referencia informado nao existe.")
	endif
return