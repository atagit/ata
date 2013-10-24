/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 16/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Acertar tamanho do campo no SX3 ou SX1 (migracao)     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

#define _TXT {"O tamanho no SX3 do campo","O tamanho da pergunta"}

user function SX3SX1T()
	local oButton1, oButton2
	local oSay1, oSay2
	local oGroup1
	local oComboBo1
	local cComboBo1 := "1- SX3"
	
	private oDlg
	private lAborta := .T.
	
	define msdialog oDlg title "ACERTAR TAMANHO (SX3/SX1)" from 000,000 to 110,430 colors 0,16777215 pixel
		@003,004 group oGroup1 to 035,211 of oDlg color 0,16777215 pixel
		@010,008 say oSay1 prompt "Esta rotina tem como objetivo retirar os campos/perguntas com tamanho diferente" size 199,007 of oDlg colors 0,16777215 pixel
		@019,008 say oSay2 prompt "entre as tabelas SX3/SX1 com a tabela SXG." size 199,007 of oDlg colors 0,16777215 pixel
		@038,133 button oButton1 prompt "OK" size 037,012 of oDlg action Processa({|| Retirar(oDlg,cComboBo1)},"Aguarde...","Acertando tamanho do campo/pergunta...",.F.) pixel
		@038,173 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
		@039,004 mscombobox oComboBo1 var cComboBo1 items {"1- SX3","2- SX1"} size 105,010 of oDlg colors 0,16777215 pixel
	activate msdialog oDlg centered
return

static function Retirar(oDlg,cComboBo1)
	local nHandle := 0
	local nLast := 0
	local nTexto := Val(Left(cComboBo1,1))
	local nTam := Len(_TXT[nTexto])
	local aCampo := {}
	local nInd := 0
	
	private cArq := "D:\Protheus11\Protheus_Data"+AllTrim(GetSrvProfString("Startpath",""))+"mpupdlog.log"
	
	Close(oDlg)
	
	if !File(cArq)
		MsgAlert("Arquivo de log da migracao nao foi gerado.")
		
		return
	else
		nHandle := FT_FUse(AllTrim(cArq))
	endif
	
	if nHandle == -1
		MsgStop("Erro de abertura do arquivo "+AllTrim(cArq)+": FERROR "+Str(FError(),4))
		
		return
	endif
	
	ProcRegua(FT_FLastRec())
	FT_FGoTop()
	
	while !FT_FEof()
		cLine := FT_FReadLn()
		nRecno := FT_FRecno()
		
		if (nInd := At(_TXT[nTexto],cLine)) > 0
			aLinha := StrTokArr(AllTrim(SubStr(cLine,nInd,Len(cLine)))," ")
			
			if nTexto == 1
				if (nInd := AScan(aCampo,{|x| x[1] = AllTrim(aLinha[7])})) == 0
					AAdd(aCampo,{AllTrim(aLinha[7])})
				endif
			else
				if (nInd := AScan(aCampo,{|x| x[1] = AllTrim(aLinha[8]) .and. x[2] = AllTrim(aLinha[5])})) == 0
					AAdd(aCampo,{AllTrim(aLinha[8]),AllTrim(aLinha[5])})
				endif
			endif
		endif
		
		IncProc()
		FT_FSkip()
	enddo
	
	FT_FUse()
	
	if nTexto == 1
		DbSelectArea("SX3")
		DbSetOrder(2)
		ProcRegua(Len(aCampo))
		
		for i := 1 to Len(aCampo)
			SX3->(DbGoTop())
			
			if SX3->(DbSeek(AllTrim(aCampo[i][1]),.F.))
				RecLock("SX3",.F.)
					SX3->X3_GRPSXG := "   "
				MsUnLock()
				
//				Alert("2) "+aCampo[i][1]+" == "+SX3->X3_GRPSXG)
				IncProc()
			endif
		next
	else
		DbSelectArea("SX1")
		DbSetOrder(1)
		ProcRegua(Len(aCampo))
		
		for i := 1 to Len(aCampo)
			SX1->(DbGoTop())
			
			if SX1->(DbSeek(aCampo[i][1]+AllTrim(aCampo[i][2]),.F.))
				RecLock("SX1",.F.)
					SX1->X1_GRPSXG := "   "
				MsUnLock()
				
				IncProc()
			endif
		next
	endif
	
	MsgInfo("Processo finalizado com sucesso.")
return