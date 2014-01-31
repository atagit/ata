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

//COMPRADO	select sum(C7_TOTAL + C7_VALIPI) from SC7010 where (C7_EMISSAO between '20140102' and '20140102') and D_E_L_E_T_ <> '*'
//VENDIDO	select sum(F2_VALMERC) from SF2010 where (F2_EMISSAO between '20140131' and '20140131') and F2_TIPO <> 'B' and D_E_L_E_T_ <> '*'

user function CRY004()
	local cArqDBF := GetMV("MV_DBFCRY")+_RELCRY+".DBF"
	local cArqCDX := GetMV("MV_DBFCRY")+"I"+_RELCRY+".CDX"
	local cAno := ""
	local cMes := ""
	
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
	
	DbUseArea(.T.,"DBFCDX",cArqDBF,"TRB",.F.,.F.)
	FErase(cArqCDX)
	
	index on DIA to &(cArqCDX)
	ZAP
	
	DbSelectArea("SZS")
	ProcRegua(SZS->(RecCount()))
	SZS->(DbGoTop())
	
	if SZS->(DbSeek(xFilial("SZS")+cAno+cMes,.F.))
		while !SZS->(Eof()) .and. SZS->(ZS_ANO+ZS_MES) == cAno+cMes
			RecLock("TRB",.T.)
				TRB->EMPRESA := cEmpAnt
				TRB->DIA := SZS->ZS_DIA
				TRB->MES := _MES[Val(cMes)]
				TRB->ANO := cAno
				TRB->RECFIN := SZS->ZS_RECFIN
				TRB->PAGFIN := SZS->ZS_PAGFIN
				TRB->SLDFIN := SZS->ZS_SLDFIN
				TRB->RECFAT := SZS->ZS_RECFAT
				TRB->PAGFAT := SZS->ZS_PAGFAT
				TRB->SLDFAT := SZS->ZS_SLDFAT
			MsUnLock()
			IncProc()
			SZS->(DbSkip())
		enddo
		
		for i := 1 to Last_Day(SToD(cAno+cMes+"01"))
			TRB->(DbGoTop())
			
			if !TRB->(DbSeek(StrZero(i,2),.F.))
				RecLock("TRB",.T.)
					TRB->EMPRESA := cEmpAnt
					TRB->DIA := StrZero(i,2)
					TRB->MES := _MES[Val(cMes)]
					TRB->ANO := cAno
					TRB->RECFIN := 0
					TRB->PAGFIN := 0
					TRB->SLDFIN := 0
					TRB->RECFAT := 0
					TRB->PAGFAT := 0
					TRB->SLDFAT := 0
				MsUnLock()
			endif
		next
		
		CallCrys(cReport,cParam,cOpcoes)
	else
		MsgAlert("O ANO e MES de referencia informado nao existe.")
	endif
	
	TRB->(DbCloseArea())
return