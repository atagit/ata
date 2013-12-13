/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/12/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse cadastro de tabelas Nao Conformidade           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function C_SZR()
	private lRetInc := .T.
	private cCadastro := "Notificacao de NC"
	private aAcho := {"ZR_NUMPC","ZR_NUMIT","ZR_EMISSAO","ZR_VEND","ZR_QUANT","ZR_ESPEC","ZR_IDENTI","ZR_CERTI","ZR_NUMNC","ZR_NOTIF","ZR_EMAIL","ZR_NFISCAL","ZR_SERIE","ZR_DTNF","ZR_ACDEV","ZR_PRAZO","ZR_TIPO","ZR_ENCERR","ZR_OBS"}
	private aCpos := {"ZR_NUMPC","ZR_NUMIT","ZR_EMISSAO","ZR_VEND","ZR_QUANT","ZR_ESPEC","ZR_IDENTI","ZR_CERTI","ZR_NUMNC","ZR_NOTIF","ZR_EMAIL","ZR_NFISCAL","ZR_SERIE","ZR_DTNF","ZR_ACDEV","ZR_PRAZO","ZR_TIPO","ZR_ENCERR","ZR_OBS"}
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui('SZR',SZR->(Recno()),3,aAcho,,aCpos,'(U_GravarSZR(),lRetInc)',.F.,,,,,,.T.,,,,,)",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5},;
						{"Legenda","U_LEGSZR()",0,6},;
						{"Imprimir","U_IMPRNC()",0,6}}
	
	aColors := {{"ZR_ENCERR == '1'","BR_VERMELHO"},;
				{"ZR_ENCERR == '2'","BR_VERDE"},;
				{"ZR_ENCERR == '3'","BR_CINZA"}}
	
	DbSelectArea("SZR")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZR",,,,,,aColors)
return

user function LEGSZR()
	local aLegenda := {}
	
	AAdd(aLegenda,{"BR_VERDE","Notificacao de N.C. em aberto"})
	AAdd(aLegenda,{"BR_VERMELHO","Notificacao de N.C. em encerrado"})
	AAdd(aLegenda,{"BR_CINZA","Notificacao de N.C. faltando ser completada"})
	
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

user function GravarSZR()
	local aAreaAnt := GetArea()
	local cCondItem := IIf(Empty(M->ZR_NUMIT),""," and C7_ITEM = '"+M->ZR_NUMIT+"'")
	
	if Empty(M->ZR_NUMNC)
		Help("O campo NAO CONFORM nao pode esta vazio.",1,"NCVAZIO")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
	if Empty(M->ZR_OBS)
		Help("O campo OBSERVACAO nao pode esta vazio.",1,"OBSVAZIO")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
/*	cQry := "update "+RetSqlName("SC7")+" set C7_NUMNOTF = '"+M->ZR_NOTIF+"' "
	cQry += "where C7_NUM = '"+M->ZR_NUMPC+"'"+cCondItem+" and D_E_L_E_T_ <> '*'"
	
	nRet := TCSqlExec(cQry)
	
	if M->ZR_TIPO == "2"
		cQry := "update "+RetSqlName("SF1")+" "
		cQry += "set F1_AVIQF = "+IIf(M->ZV_ACDEV == "1","3","2")+" "
		cQry += "where F1_DOC = '"++"' and F1_SERIE = '"++"' and F1_FORNECE = '"++"' and F1_LOJA = '"++"' and D_E_L_E_T_ <> '*'"
		
		nRet := TCSqlExec(cQry)
	endif*/
	
	RestArea(aAreaAnt)
return

user function VISSZR()
	local cNumNotf := SC7->C7_NUMNOTF
	local cNumPC := SC7->C7_NUM
	local cItemPC := SC7->C7_ITEM
	
	if !Empty(cNumNotf)
		if SZR->(DbSeek(xFilial("SZR")+cNumNotf,.F.))
			AxVisual("SZR",SZR->(Recno()),2)
		else
			Alert("Notificacao de NC nao cadastrado!")
		endif
	else
		Alert("Nao tem NOTIFICACAO DE N.C. para esse pedido de compra.")
	endif
return