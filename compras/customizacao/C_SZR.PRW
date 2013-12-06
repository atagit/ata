/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/12/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse cadastro de tabelas Nao Conformidade           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function C_SZR()
	private cCadastro := "Notificacao de NC"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5},;
						{"Legenda","U_LEGSZR()",0,6},;
						{"Imprimir","U_IMPRNC()",0,6}}
	
	aColors := {{"ZR_ACDEV == '1'","BR_VERDE"},;
				{"ZR_ACDEV == '2'","BR_AMARELO"}}
	
	DbSelectArea("SZR")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZR",,,,,,aColors)
return

user function LEGSZR()
	local aLegenda := {}
	
	AAdd(aLegenda,{"BR_VERDE","Notificacao de aceito com restricao"})
	AAdd(aLegenda,{"BR_AMARELO","Notificacao de devolucao"})
	
	BrwLegenda(cCadastro,"Legenda",aLegenda)
return(.T.)

user function IMPRNC()
	local cArqDBF := GetMV("MV_DBFCRY")+"CRY003.DBF"
	
	private cReport := "CRY003"
	private cOpcoes := "1;0;1;Notificacao de Nao Conformidade"
	private cParam  := AllTrim(cEmpAnt)+";"+AllTrim(cFilAnt)+";"
	
	if Select("TMP") <> 0
		TMP->(DbCloseArea())
	endif
	
	DbUseArea(.T.,"DBFCDX",cArqDBF,"TMP",.F.,.F.)
	
	ZAP
	
	TMP->(DbAppend())
	
	TMP->NUMPC := SZR->ZR_NUMPC
	TMP->DATPC := U_ConvData(DToS(SZR->ZR_EMISSAO))
	TMP->FORNEC := IIf(SC7->(DbSeek(xFilial("SC7")+SZR->ZR_NUMPC,.F.)),AllTrim(SC7->C7_NOMFORN),"")
	TMP->VENDED := AllTrim(SZR->ZR_VEND)
	TMP->EMAIL := AllTrim(Lower(SZR->ZR_EMAIL))
	TMP->NOTFIS := AllTrim(SZR->ZR_NFISCAL)+IIf(Empty(SZR->ZR_SERIE),"","-"+AllTrim(SZR->ZR_SERIE))
	TMP->DATNF := U_ConvData(DToS(SZR->ZR_DTNF))
	
	if SZR->ZR_ACDEV == "1"
		TMP->ACREST := "X"
		TMP->DEVOLV := ""
	else
		TMP->ACREST := ""
		TMP->DEVOLV := "X"
	endif
	
//	TMP->PRODUT :=
	TMP->PRAZO := IIf(SZR->ZR_PRAZO,"X","")
	TMP->QUANT := IIf(SZR->ZR_QUANT,"X","")
	TMP->ESPEC := IIf(SZR->ZR_ESPEC,"X","")
	TMP->IDENT := IIf(SZR->ZR_IDENTI,"X","")
	TMP->CERTI := IIf(SZR->ZR_CERTI,"X","")
	
	for i := 1 to MLCount(AllTrim(SZR->ZR_OBS),100)
//		TMP->&("OBS"+StrZero(i,2)) := OemToAnsi(MemoLine(AllTrim(SZR->ZR_OBS),100,i))
		TMP->&("OBS"+StrZero(i,2)) := OemToAnsi(MemoLine(AllTrim(SZR->ZR_OBS),100,i))
	next
	
	TMP->(DbCommit())
	TMP->(DbCloseArea())
	
	CallCrys(cReport,cParam,cOpcoes)
/*	local cPathDot := GetMV("MV_ARQDOT")+"RG009.DOT"		//P:\Microsiga\MODELO\
	
	private	hWord
	
	//Conecta ao word
	hWord := OLE_CreateLink()
	
	OLE_NewFile(hWord,cPathDot)
	
	//Montagem das variaveis do cabecalho
	OLE_SetDocumentVar(hWord,"wNumPC",SZR->ZR_NUMPC)
	OLE_SetDocumentVar(hWord,"wEmissaoNC",U_ConvData(DToS(SZR->ZR_EMISSAO)))
	OLE_SetDocumentVar(hWord,"wNomForn",IIf(SC7->(DbSeek(xFilial("SC7")+SZR->ZR_NUMPC,.F.)),AllTrim(SC7->C7_NOMFORN),""))
	OLE_SetDocumentVar(hWord,"wNomVend",AllTrim(SZR->ZR_VEND))
	OLE_SetDocumentVar(hWord,"wEmail",AllTrim(Lower(SZR->ZR_EMAIL)))
	OLE_SetDocumentVar(hWord,"wNFiscal",AllTrim(SZR->ZR_NFISCAL)+IIf(Empty(SZR->ZR_SERIE),"","-"+AllTrim(SZR->ZR_SERIE)))
	OLE_SetDocumentVar(hWord,"wEmissaoNF",U_ConvData(DToS(SZR->ZR_DTNF)))
	
	if SZR->ZR_ACDEV == "1"
		OLE_SetDocumentVar(hWord,"wAceiRest","X")
		OLE_SetDocumentVar(hWord,"wDevol","")
	else
		OLE_SetDocumentVar(hWord,"wAceiRest","")
		OLE_SetDocumentVar(hWord,"wDevol","X")
	endif
	
	OLE_SetDocumentVar(hWord,"wPEntrega",IIf(SZR->ZR_PRAZO,"X",""))
	OLE_SetDocumentVar(hWord,"wQuanti",IIf(SZR->ZR_QUANT,"X",""))
	OLE_SetDocumentVar(hWord,"wEspecif",IIf(SZR->ZR_ESPEC,"X",""))
	OLE_SetDocumentVar(hWord,"wIdentif",IIf(SZR->ZR_IDENTI,"X",""))
	OLE_SetDocumentVar(hWord,"wCertif",IIf(SZR->ZR_CERTI,"X",""))
	OLE_SetDocumentVar(hWord,"wObs",AllTrim(SZR->ZR_OBS))
	
	//Atualizando as variaveis do documento do Word
	OLE_UpdateFields(hWord)
	
	if MsgYesNo("Imprime o Documento?")
		OLE_PrintFile(hWord,"ALL",,,1)
	endif
	
	if MsgYesNo("Fecha o Word e Corta o Link?")
		OLE_CloseFile(hWord)
		OLE_CloseLink(hWord)
	endif*/
return