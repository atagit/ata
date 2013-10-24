/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/12/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar baixa de materia prima da API                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define _ENTER Chr(13)+Chr(10)
#define _EMPRE {"ATA","ATF"}
#define _ERRPROD {"Produto nao encontrado!","Produto bloqueado!"}
#define _ERRPROJ {"Projeto nao encontrado!"}

user function IMPORAPI()
	private L240 := .T.
	private cFiltra := ""
	private aIndex := {}
	private aRotina := {{"Pesquisa","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Importar","U_GIMPORAPI()",0,2}}
	private cCadastro := OemToAnsi("Importar API")
	private bFiltraBrw := {|| nil}
	private aArea := GetArea()
	
	cFiltra := "D3_CODAPI <> '' "
	bFiltraBrw := {|| FilBrowse("SD3",@aIndex,@cFiltra)}
	
	Eval(bFiltraBrw)
	DbSelectArea("SD3")
	MBrowse(006,001,022,075,"SD3")
	EndFilBrw("SD3",aIndex)
	//   mBrowse(6,1,22,75,"SC1",,,,,,aCores,,,,,,,,cFiltraSC1)
return

user function GIMPORAPI()
	local ExpA1 := {}
	local ExpN2 := 3
	local cTPMovimento := ""
	local nQtd := 0
	local cCod := ""
	local cCr := ""
	local cCC := "9999"
	local cProd := ""
	local cProj := ""
	local nId := 0
	local cUnidade := ""
	local cArmazem := ""
	local cEmissao := ""
	local cNumSeq := ""
	local nValProd := 0
	local nValProj := 0
	local aErro := {}
	local lRodou := .F.
//	local lValProd := .F.
//	local nValProj := .F.
	
	private lMsErroAuto := .F.
//	private lMsHelpAuto := .T.
	
	private cBaixaDe := CToD("")
	private cBaixaAte := CToD("")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Baixa de                                          ³
	//³ mv_par02 - BAixa ate                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("IMPAPI",.T.)
	
	cBaixaDe := DToS(mv_par01)
	cBaixaAte := DToS(mv_par02)
	
	cQry := "select * "
	cQry += "from [DADOSATF].dbo.TBLAPI "
	cQry += "where empresa = '"+cEmpAnt+"' and (baixa between '"+cBaixaDe+"' and '"+cBaixaAte+"') and numseq = '' and erro = 'N' "
	cQry += "order by id"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		nId := TEMP->id
		cTPMovimento := TEMP->tipo
		cProd := TEMP->produto
		nQtd := TEMP->quantd
		cEmissao := TEMP->baixa
		cCod := TEMP->codigo
		cProj := TEMP->projeto
		cCr := TEMP->numcr
		cNumSeq := TEMP->numseq
		
		if SB1->(DbSeek(xFilial("SB1")+cProd,.F.))
			cUnidade := SB1->B1_UM
			cArmazem := SB1->B1_LOCPAD
//			cArmazem := IIf(SB1->B1_LOCPAD == "05","10",SB1->B1_LOCPAD)
			
//			lValProd := .T.
			nValProd := IIf(SB1->B1_MSBLQL == "1",2,0)
		else
//			lValProd := .F.
			nValProd := 1
		endif
		
//		lValProj := IIf(CTH->(DbSeek(xFilial("CTH")+cProj,.F.)),.T.,.F.)
		nValProj := IIf(CTH->(DbSeek(xFilial("CTH")+cProj,.F.)),0,1)
	
//		if lValProd .and. lValProj
		if Empty(nValProd) .and. Empty(nValProj)
			begin transaction
				ExpA1 := {}
				
				ExpA1 := {{"D3_FILAL",xFilial("SD3"),nil},;
							{"D3_TM",cTPMovimento,nil},;
							{"D3_COD",cProd,nil},;
							{"D3_UM",cUnidade,nil},;
							{"D3_LOCAL",cArmazem,nil},;
							{"D3_QUANT",nQtd,nil},;
							{"D3_EMISSAO",SToD(cEmissao),nil},;
							{"D3_CC",cCC,nil},;
							{"D3_CLVL",cProj,nil},;
							{"D3_CR",cCr,nil},;
							{"D3_CODAPI",cCod,nil}}
				
				if cTPMovimento == "501"
					ExpN2 := 3
				else
					ExpN2 := 5
					
					AAdd(ExpA1,{"D3_NUMSEQ",cNumSeq,nil})
					AAdd(ExpA1,{"INDEX",3,nil})
				endif
				
				MsExecAuto({|x,y| MATA240(x,y)},ExpA1,ExpN2)
				
				if !lMsErroAuto
//					ConOut("Incluido com sucesso o ID "+AllTrim(Str(nId))+"!")
					
					cQry := "select max(D3_NUMSEQ) as D3_NUMSEQ "
					cQry += "from "+RetSqlName("SD3")+" "
					cQry += "where D3_COD = '"+cProd+"' and D3_EMISSAO = '"+cEmissao+"' and D3_QUANT = "+AllTrim(Str(nQtd))+" and D_E_L_E_T_ <> '*'"
					
					tcquery cQry new alias "TEMP1"
					DbSelectArea("TEMP1")
					
					cQry := "update [DADOSATF].dbo.TBLAPI set numseq = '"+TEMP1->D3_NUMSEQ+"', erro = 'N' where empresa = '"+cEmpAnt+"' and id = "+AllTrim(Str(nId))
					nRet := TCSqlExec(cQry)
					
					if nRet > 0
//						ConOut("O campo NUMSEQ do ID "+AllTrim(Str(nId))+" nao foi gravado!")
					
						cQry := "update [DADOSATF].dbo.TBLAPI set erro = 'S' where empresa = '"+cEmpAnt+"' and id = "+AllTrim(Str(nId))
						nRet := TCSqlExec(cQry)
					endif
					
					TEMP1->(DbCloseArea())
				else
					AAdd(aErro,{cProd,cProj,nId,cEmpAnt})
//					MErro(lMsErroAuto,lValProd,lValProj,aErro,"E")
					MErro(lMsErroAuto,nValProd,nValProj,aErro,"E")
				endif
			end transaction
		else
			AAdd(aErro,{cProd,cProj,nId,cEmpAnt})
//			MErro(lMsErroAuto,lValProd,lValProj,aErro,"E")
			MErro(lMsErroAuto,nValProd,nValProj,aErro,"E")
		endif
		
		lMsErroAuto := .F. ; aErro := {} ; nValProd := 0 ; nValProd := 0 ; lRodou := .T.
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	if lRodou
		MsgInfo("A importacao foi concluida. Verificar na rotina de Erros se ocorreu algum caso.")
	endif
	
	TEMP->(DbCloseArea())
return

//static function MErro(lMsErroAuto,lValProd,lValProj,aErro,cRetorno)
static function MErro(lMsErroAuto,nValProd,nValProj,aErro,cRetorno)
	local cMsgErro := ""
	local cMensagem := ""
	local cQry := ""
	local nRet := 0
	local cServer := GetMV("MV_RELSERV")
	local cPassword := GetMV("MV_RELPSW")
	local cAccount := GetMV("MV_RELACNT")
	local cSubject := "Erro na importacao da baixa pela API"
	local cTo := "informatica@ata.ind.br"
	
	cMsgErro := "Erro na inclusao do ID "+AllTrim(Str(aErro[1][3]))+"! Empresa: "+aErro[1][4]
	
/*	if !lValProd
		cMsgErro += _ENTER+"- Codigo do produto "+aErro[1][1]+" nao existe! Empresa: "+aErro[1][4]
	endif*/
	
	if !Empty(nValProd)
		cMsgErro += _ENTER+"- Error ("+Str(nValProd,1)+"): "+_ERRPROD[nValProd]
	endif
	
/*	if !lValProj
		cMsgErro += _ENTER+"- Codigo do projeto "+aErro[1][2]+" nao existe!"
	endif*/
	
	if !Empty(nValProj)
		cMsgErro += _ENTER+"- Error ("+Str(nValProj,1)+"): "+_ERRPROJ[nValProj]
	endif
	
	if !lMsErroAuto
		cMsgErro += _ENTER+MostraErro()
	endif
	
	cQry := "update [DADOSATF].dbo.TBLAPI set erro = 'S' where empresa = '"+aErro[1][4]+"' and id = "+AllTrim(Str(aErro[1][3]))
	nRet := TCSqlExec(cQry)
	
	if nRet > 0
		cMsgErro += _ENTER+"O campo ERRO do ID "+AllTrim(Str(aErro[1][3]))+" nao foi gravado! Empresa: "+aErro[1][4]
	endif
	
	cMensagem := "<html> "+cMsgErro+" </html>"
	
//	ConOut(cMsgErro)
	
	if cRetorno == "E"			//via e-mail
		U_EnvEmail(.T.,.F.,cServer,cAccount,cPassword,cTo,,cSubject,cMensagem)
	elseif cRetorno == "D"		//em disco
		//
	elseif cRetorno == "A"		//ambos
		//
	endif
return