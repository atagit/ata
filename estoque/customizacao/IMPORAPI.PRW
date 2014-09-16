/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/12/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar baixa de materia prima da API                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function IMPORAPI()
	private L240 := .T.
	private cFiltra := ""
	private aIndex := {}
	private aRotina2 := {{"De Baixas","U_RELBAIAPI()",0,1},;
						 {"De Erros","U_RELERRAPI()",0,2}}
	private aRotina3 := {{"Corrigir","U_CORRIGIRAPI()",0,1},;
						 {"Importar","RptStatus({|| U_GIMPORAPI()},'Aguarde o processo de importacao...')",0,2}}
	private aRotina := {{"Pesquisa","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Corrigir Erros","AxVisual",0,6},;
						{"Importar API",aRotina3,0,6},;
						{"Relatorios",aRotina2,0,6}}
	
	private cCadastro := OemToAnsi("Importar API (ATF22)")
	private bFiltraBrw := {|| nil}
	private aArea := GetArea()
	
	cFiltra := "D3_CODAPI <> '' "
	bFiltraBrw := {|| FilBrowse("SD3",@aIndex,@cFiltra)}
	
	Eval(bFiltraBrw)
	DbSelectArea("SD3")
	MBrowse(006,001,022,075,"SD3")
	EndFilBrw("SD3",aIndex)
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
	local lRodou := .F.
	local nError := 0
	local aError := {}
	local nTotReg := 0
	
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
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select * "
	cQry += "from [DADOSATF].dbo.TBLAPI "
	cQry += "where empresa = '"+cEmpAnt+"' and (baixa between '"+cBaixaDe+"' and '"+cBaixaAte+"') and numseq = '' and erro = 'N' "
	cQry += "order by id"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	count to nTotReg
	
	SetRegua(nTotReg)
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		nId := TEMP->id
		cTPMovimento := TEMP->tipo
		cProd := TEMP->produto
		nQtd := TEMP->quantd
		cEmissao := TEMP->baixa
		cCod := TEMP->codigo
		cProj := IIf(TEMP->projeto == "000000","000000000",TEMP->projeto)
		cCr := TEMP->numcr
		cNumSeq := TEMP->numseq
		cArmazem := ""
		
		if SB1->(DbSeek(xFilial("SB1")+cProd,.F.))
			cUnidade := SB1->B1_UM
			cArmazem := SB1->B1_LOCPAD
//			cArmazem := IIf(SB1->B1_LOCPAD == "05","10",SB1->B1_LOCPAD)
			
			if SB1->B1_LOCPAD <> "05"
				nError := 6																		//6 - Armazem do produto diferene do 05
				
				AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
			elseif SB1->B1_MSBLQL == "1"
				nError := 2																		//2 - Produto bloqueado para uso
				
				AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
			else
				if SB2->(DbSeek(xFilial("SB2")+cProd+'         '+cArmazem,.F.))
					if (SB2->B2_QATU - SB2->B2_RESERVA) < nQtd
						if Upper(AllTrim(GetMV("MV_ESTNEG"))) <> "S"
							nError := 3															//3 - Quantidade em estoque insuficiente
							
							AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
						endif
					endif
				else
					nError := 4																	//4 - Saldo Em Estoque não encontrado
					
					AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
				endif
			endif
		else
			nError := 1																			//1 - Produto não encontrado
			
			AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
		endif
		
		if !CTH->(DbSeek(xFilial("CTH")+cProj,.F.))
			nError := 5																			//5 - Projeto não encontrado
			
			AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
		endif
		
		if Empty(nError)
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
					cQry := "select max(D3_NUMSEQ) as D3_NUMSEQ "
					cQry += "from "+RetSqlName("SD3")+" "
					cQry += "where D3_COD = '"+cProd+"' and D3_EMISSAO = '"+cEmissao+"' and D3_QUANT = "+AllTrim(Str(nQtd))+" and D_E_L_E_T_ <> '*'"
					
					tcquery cQry new alias "TEMP1"
					
					DbSelectArea("TEMP1")
					
					cQry := "update [DADOSATF].dbo.TBLAPI set numseq = '"+TEMP1->D3_NUMSEQ+"', erro = 'N' where empresa = '"+cEmpAnt+"' and id = "+AllTrim(Str(nId))
					nRet := TCSqlExec(cQry)
					
					if nRet <> 0
						nError := 99															//99 - Error ao atualizar o campo NUMSEQ na tabela TBLAPI
						
						AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
					endif
					
					TEMP1->(DbCloseArea())
				else
					nError := 98																//98 - Error do sistema (ExecAuto)
					
					AAdd(aError,{nError,cTPMovimento,cProd,cArmazem,cCr,nQtd,cEmissao,cProj,nId,cEmpAnt,cNumSeq,cCod})
					
					cQry := "update [DADOSATF].dbo.TBLAPI set error = "+AllTrim(Str(nError))+", erro = 'S' where empresa = '"+cEmpAnt+"' and id = "+AllTrim(Str(nId))
					nRet := TCSqlExec(cQry)
				endif
			end transaction
		else
			cQry := "update [DADOSATF].dbo.TBLAPI set error = "+AllTrim(Str(nError))+", erro = 'S' where empresa = '"+cEmpAnt+"' and id = "+AllTrim(Str(nId))
			nRet := TCSqlExec(cQry)
		endif
		
		lMsErroAuto := .F. ; nError := 0
		
		IncRegua()
		TEMP->(DbSkip())
	enddo
	
	if Empty(aError)
		MsgInfo("A importacao foi realizada com sucesso.")
	else
		if MsgYesNo("A importacao teve erro em alguns registros, deseja gerar o relatorio dos erros?","ERROR")
			U_RELERRAPI()
		endif
	endif
	
	TEMP->(DbCloseArea())
return

user function CORRIGIRAPI()
	local oButton1
	local oButton2
	
	private oDlg
	private oListBox1
	private lCheckBo1 := .F.
	private oOk := LoadBitmap(GetResources(),"LBOK")
	private oNo := LoadBitmap(GetResources(),"LBNO")
	
	private aArqList := {}
	
	define msdialog oDlg title "Corrigir API" from 000,000 to 330,1000 colors 0,16777215 pixel
		FGetList()
		
		@151,004 checkbox oCheckBo1 var lCheckBo1 prompt "Marcar Todos" size 048,008 of oDlg colors 0,16777215 on change MarcaTodos() pixel
		@149,458 button oButton1 prompt "Cancelar" size 037,012 of oDlg action oDlg:End() pixel
		@149,419 button oButton2 prompt "Corrigir" size 037,012 of oDlg action Corrigir() pixel
	activate msdialog oDlg centered
return

static function FGetList()
	ASize(aArqList,0)
	
	if Select("TMP") <> 0
		TMP->(DbCloseArea())
	endif
	
	cQry := "select tipo, produto, numcr, quantd, baixa, projeto, id, empresa, codigo, error "
	cQry += "from [DADOSATF].dbo.TBLAPI "
	cQry += "where (baixa between '20140801' and '20140831') and erro = 'S'"
	cQry += "order by baixa"
	
	tcquery cQry new alias "TMP"
	
	DbSelectArea("TMP")
	TMP->(DbGoTop())	
	
	while !TMP->(Eof())
		AAdd(aArqList,{.F.,TMP->empresa,TMP->codigo,TMP->tipo,TMP->produto,U_ConvData(TMP->baixa),Transf(TMP->quantd,"@E 999,999,999.9999"),TMP->projeto,TMP->numcr,TMP->id,U_MERRORAPI(TMP->error)})
		
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
	
	if Len(aArqList) <= 0
		AAdd(aArqList,{.F.,"","","","","",0,"","",0,""})
	endif
											//1  2     3        4      5         6       7        8         9        10   11
	@002,004 listbox oListBox1 fields, header "","EMP","CODIGO","TIPO","PRODUTO","BAIXA","QUANTD","PROJETO","NUM CR","ID","ERROR" size 492,142 of oDlg pixel colsizes 050,030 /*Largura*//*Altura*/
		oListBox1:SetArray(aArqList)
		oListBox1:bLine := {|| {IIf(aArqList[oListBox1:nAt][1],oOk,oNo),aArqList[oListBox1:nAt][2],aArqList[oListBox1:nAt][3],aArqList[oListBox1:nAt][4],aArqList[oListBox1:nAt][5],aArqList[oListBox1:nAt][6],aArqList[oListBox1:nAt][7],aArqList[oListBox1:nAt][8],aArqList[oListBox1:nAt][9],aArqList[oListBox1:nAt][10],aArqList[oListBox1:nAt][11]}}
		oListBox1:bLDblClick := {|| Selecionados()}
		oListBox1:Refresh()
return

static function Selecionados()
	local lMark := IIf(aArqList[oListBox1:nAt][1],.F.,.T.)
	
	aArqList[oListBox1:nAt][1] := lMark
	
	oListBox1:Refresh()
return

static function MarcaTodos()
	local lMark := IIf(lCheckBo1,.T.,.F.)
	
	for i := 1 to Len(aArqList)
		aArqList[i][1] := lMark
	next
	
	oListBox1:Refresh()
return

static function Corrigir()
	local lError := .F.
	
	for i := 1 to Len(aArqList)
		if aArqList[i][1]
			cQry := "update [DADOSATF].dbo.TBLAPI set erro = 'N', error = 0 where id = "+AllTrim(Str(aArqList[i][10]))+" and erro = 'S'"
			nRet := TCSqlExec(cQry)
			
			if nRet <> 0
				MsgAlert("Erro ao tentar corrigir o registro de ID "+AllTrim(Str(aArqList[i][10])))
				
				lError := .T.
			endif
		endif
	next
	
	if !lError
		MsgInfo("Correcao concluida com sucesso. Refaca a importacao destes registros.")
	else
		MsgAlert("Contacte o responsavel de T.I. para analisar.")
	endif
	
	oDlg:End()
return