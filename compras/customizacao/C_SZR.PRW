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
	private aCposI := {"ZR_NUMPC","ZR_NUMIT","ZR_EMISSAO","ZR_VEND","ZR_QUANT","ZR_ESPEC","ZR_IDENTI","ZR_CERTI","ZR_NUMNC","ZR_NOTIF","ZR_EMAIL","ZR_NFISCAL","ZR_SERIE","ZR_DTNF","ZR_ACDEV","ZR_PRAZO","ZR_TIPO","ZR_ENCERR","ZR_OBS"}
	private aCposA := {"ZR_VEND","ZR_QUANT","ZR_ESPEC","ZR_IDENTI","ZR_CERTI","ZR_NOTIF","ZR_EMAIL","ZR_NFISCAL","ZR_SERIE","ZR_DTNF","ZR_PRAZO","ZR_NUMNC","ZR_OBS"}
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui('SZR',SZR->(Recno()),3,aAcho,,aCposI,'(U_IncluirSZR(),lRetInc)',.F.,,,,,,.T.,,,,,)",0,3},;
						{"Alterar","AxAltera('SZR',SZR->(Recno()),4,aAcho,aCposA,,,'(U_AlterarSZR(),lRetInc)',,,,,,.T.)",0,4},;
						{"Excluir","AxDeleta",0,5},;
						{"Legenda","U_LEGSZR()",0,6},;
						{"Imprimir","U_IMPRNC()",0,6}}
	
	aColors := {{"ZR_ENCERR == '1'","BR_VERMELHO"},;
				{"ZR_ENCERR == '2'","BR_VERDE"},;
				{"ZR_ENCERR == '3'","BR_BRANCO"}}
	
	DbSelectArea("SZR")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZR",,,,,,aColors)
return

user function LEGSZR()
	local aLegenda := {}
	
	AAdd(aLegenda,{"BR_VERDE","Notificacao de N.C. em aberto"})
	AAdd(aLegenda,{"BR_VERMELHO","Notificacao de N.C. em encerrado"})
	AAdd(aLegenda,{"BR_BRANCO","Notificacao de N.C. faltando ser completada"})
	
	BrwLegenda(cCadastro,"Legenda",aLegenda)
return(.T.)

user function IMPRNC()
	local cArqDBF := GetMV("MV_DBFCRY")+"CRY003.DBF"
	
	private cReport := "CRY003"
	private cOpcoes := "1;0;1;Notificacao de Nao Conformidade"
//	private cOpcoes := "6;0;1;C:\temp\000002"		//PDF
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
//	TMP->OBS := OemToAnsi(SZR->ZR_OBS)
	TMP->OBS := AnsiToOem(SZR->ZR_OBS)
	
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
	
/*	for i := 1 to MLCount(AllTrim(SZR->ZR_OBS),100)
		TMP->&("OBS"+StrZero(i,2)) := OemToAnsi(MemoLine(AllTrim(SZR->ZR_OBS),100,i))
	next*/
	
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

user function IncluirSZR()
	local aAreaAnt := GetArea()
	local cCondItem := IIf(Empty(M->ZR_NUMIT),""," and C7_ITEM = '"+M->ZR_NUMIT+"'")
	
	if M->ZR_ENCERR <> "2"
		MsgAlert("O campo ENCERRADO na inclusao so pode ser em aberto (2-Nao).")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
	if Empty(M->ZR_NUMNC)
		MsgAlert("O campo NAO CONFORM nao pode esta vazio.")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
	if Empty(M->ZR_OBS)
		MsgAlert("O campo OBSERVACAO nao pode esta vazio.")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
	cQry := "update "+RetSqlName("SC7")+" set C7_NUMNOTF = '"+M->ZR_NOTIF+"' "
	cQry += "where C7_NUM = '"+M->ZR_NUMPC+"'"+cCondItem+" and D_E_L_E_T_ <> '*'"
	
	nRet := TCSqlExec(cQry)
	
//	if M->ZR_TIPO == "1"
		cQry := "select F1_AVIQF, C7_EMISSAO, C7_FORNECE, C7_LOJA "
		cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SD1")+" SD1 on (F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA) "
		cQry += "	inner join "+RetSqlName("SC7")+" SC7 on (D1_PEDIDO = C7_NUM) "
		cQry += "where C7_NUM = '"+M->ZR_NUMPC+"' and SF1.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*'"
		
		tcquery cQry new alias "NF"
		DbSelectArea("NF")
		
		DbSelectArea("SZV")
		SZV->(DbSetOrder(2))
		SZV->(DbGoTop())
		
		if SZV->(DbSeek(xFilial("SZV")+NF->(C7_FORNECE+C7_LOJA),.F.))
			while !SZV->(Eof()) .and. SZV->ZV_FORNECE == NF->C7_FORNECE .and. SZV->ZV_LOJA == NF->C7_LOJA
				if SZV->ZV_STATUS == "F"
					if NF->C7_EMISSAO >= DToS(SZV->ZV_INIAVAL) .and. NF->C7_EMISSAO <= DToS(SZV->ZV_FINAVAL)
						RecLock("SZV",.F.)
							do case
								case NF->F1_AVIQF == "3"
									if M->ZR_TIPO == "1"					//No Recebimento
										SZV->ZV_NCA := SZV->ZV_NCA + 1
									elseif M->ZR_TIPO == "2"				//Apos Recebimento
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RC := SZV->ZV_RC + 1
										SZV->ZV_NCA := SZV->ZV_NCA + 1
									endif
								case NF->F1_AVIQF == "2"
									if M->ZR_TIPO == "1"					//No Recebimento
										SZV->ZV_NCD := SZV->ZV_NCD + 1
									elseif M->ZR_TIPO == "2"				//Apos Recebimento
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RR := SZV->ZV_RR + 1
										SZV->ZV_NCD := SZV->ZV_NCD + 1
									endif
								case NF->F1_AVIQF == "1"
									if M->ZR_ACDEV == "1"
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RC := SZV->ZV_RC + 1
										SZV->ZV_NCA := SZV->ZV_NCA + 1
									elseif M->ZR_ACDEV == "2"
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RR := SZV->ZV_RR + 1
										SZV->ZV_NCD := SZV->ZV_NCD + 1
									endif
									
									aArea1 := GetArea()
									
									aCalcIQF := U_CalcIQF(SZV->ZV_RA,SZV->ZV_RC,SZV->ZV_RR)
									SZV->ZV_VALIQF := aCalcIQF[1][1]
									
									RestArea(aArea1)
									
									cQry := "update "+RetSqlName("SF1")+" "
									cQry += "set F1_AVIQF = "+IIf(M->ZV_ACDEV == "1","3","2")+" "
									cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SD1")+" SD1 on (F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA) "
									cQry += "	inner join "+RetSqlName("SC7")+" SC7 on (D1_PEDIDO = C7_NUM) "
									cQry += "where C7_NUM = '"+M->ZR_NUMPC+"' and SF1.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*'"
									
									nRet := TCSqlExec(cQry)
							endcase
						MsUnLock()
						
						exit
					endif
				elseif SZV->ZV_STATUS == "A"
					if NF->C7_EMISSAO >= DToS(SZV->ZV_INIAVAL)
						RecLock("SZV",.F.)
							do case
								case NF->F1_AVIQF == "3"
									if M->ZR_TIPO == "1"					//No Recebimento
										SZV->ZV_NCA := SZV->ZV_NCA + 1
									elseif M->ZR_TIPO == "2"				//Apos Recebimento
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RC := SZV->ZV_RC + 1
										SZV->ZV_NCA := SZV->ZV_NCA + 1
									endif
								case NF->F1_AVIQF == "2"
									if M->ZR_TIPO == "1"					//No Recebimento
										SZV->ZV_NCD := SZV->ZV_NCD + 1
									elseif M->ZR_TIPO == "2"				//Apos Recebimento
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RR := SZV->ZV_RR + 1
										SZV->ZV_NCD := SZV->ZV_NCD + 1
									endif
								case NF->F1_AVIQF == "1"
									if M->ZR_ACDEV == "1"
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RC := SZV->ZV_RC + 1
										SZV->ZV_NCA := SZV->ZV_NCA + 1
									elseif M->ZR_ACDEV == "2"
										SZV->ZV_RA := SZV->ZV_RA - 1
										SZV->ZV_RR := SZV->ZV_RR + 1
										SZV->ZV_NCD := SZV->ZV_NCD + 1
									endif
									
									aArea1 := GetArea()
									
									aCalcIQF := U_CalcIQF(SZV->ZV_RA,SZV->ZV_RC,SZV->ZV_RR)
									SZV->ZV_VALIQF := aCalcIQF[1][1]
									
									RestArea(aArea1)
									
									cQry := "update "+RetSqlName("SF1")+" "
									cQry += "set F1_AVIQF = '"+IIf(M->ZR_ACDEV == "1","3","2")+"' "
									cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SD1")+" SD1 on (F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA) "
									cQry += "	inner join "+RetSqlName("SC7")+" SC7 on (D1_PEDIDO = C7_NUM) "
									cQry += "where C7_NUM = '"+M->ZR_NUMPC+"' and SF1.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*'"
									
									nRet := TCSqlExec(cQry)
							endcase
						MsUnLock()
						
						exit
					endif
				endif
				
				SZV->(DbSkip())
			enddo
		endif
		
		SZV->(DbCloseArea())
		NF->(DbCloseArea())
//	endif
	
/*	if M->ZR_TIPO == "2"				//Apos o recebimento
		cQry := "update "+RetSqlName("SF1")+" "
		cQry += "set F1_AVIQF = "+IIf(M->ZV_ACDEV == "1","3","2")+" "
		cQry += "where F1_DOC = '"++"' and F1_SERIE = '"++"' and F1_FORNECE = '"++"' and F1_LOJA = '"++"' and D_E_L_E_T_ <> '*'"
		
		nRet := TCSqlExec(cQry)
	endif*/
	
	RestArea(aAreaAnt)
return

user function AlterarSZR()
	local aAreaAnt := GetArea()
	local cNumNC := SZR->ZR_NUMNC
	local cCondItem := IIf(Empty(M->ZR_NUMIT),""," and C7_ITEM = '"+M->ZR_NUMIT+"'")
	
	if Empty(M->ZR_NUMNC)
		MsgAlert("O campo NAO CONFORM nao pode esta vazio.")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
	if !Empty(M->ZR_NUMNC) .and. M->ZR_NUMNC == cNumNC
		MsgAlert("O campo NAO CONFORM nao pode ser alterado.")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
	if Empty(M->ZR_OBS)
		MsgAlert("O campo OBSERVACAO nao pode esta vazio.")
		
		lRetInc := .F.
		
		return
	else
		lRetInc := .T.
	endif
	
	if M->ZR_ENCERR == "3"
		cQry := "update "+RetSqlName("SC7")+" set C7_NUMNOTF = '"+M->ZR_NOTIF+"' "
		cQry += "where C7_NUM = '"+M->ZR_NUMPC+"'"+cCondItem+" and D_E_L_E_T_ <> '*'"
		
		nRet := TCSqlExec(cQry)
		
		RecLock("SZR",.F.)
			M->ZR_ENCERR := "2"
		MsUnLock()
		
		cQry := "select F1_AVIQF, C7_EMISSAO, C7_FORNECE, C7_LOJA "
		cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SD1")+" SD1 on (F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA) "
		cQry += "	inner join "+RetSqlName("SC7")+" SC7 on (D1_PEDIDO = C7_NUM) "
		cQry += "where C7_NUM = '"+M->ZR_NUMPC+"' and SF1.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*'"
		
		tcquery cQry new alias "NF"
		DbSelectArea("NF")
		
		DbSelectArea("SZV")
		SZV->(DbSetOrder(2))
		SZV->(DbGoTop())
		
		if SZV->(DbSeek(xFilial("SZV")+NF->(C7_FORNECE+C7_LOJA),.F.))
			while !SZV->(Eof()) .and. SZV->ZV_FORNECE == NF->C7_FORNECE .and. SZV->ZV_LOJA == NF->C7_LOJA
				if SZV->ZV_STATUS == "F"
					if NF->C7_EMISSAO >= DToS(SZV->ZV_INIAVAL) .and. NF->C7_EMISSAO <= DToS(SZV->ZV_FINAVAL)
						RecLock("SZV",.F.)
							do case
								case NF->F1_AVIQF == "3"
									SZV->ZV_NCA := SZV->ZV_NCA + 1
								case NF->F1_AVIQF == "2"
									SZV->ZV_NCD := SZV->ZV_NCD + 1
							endcase
						MsUnLock()
						
						exit
					endif
				elseif SZV->ZV_STATUS == "A"
					if NF->C7_EMISSAO >= DToS(SZV->ZV_INIAVAL)
						RecLock("SZV",.F.)
							do case
								case NF->F1_AVIQF == "3"
									SZV->ZV_NCA := SZV->ZV_NCA + 1
								case NF->F1_AVIQF == "2"
									SZV->ZV_NCD := SZV->ZV_NCD + 1
							endcase
						MsUnLock()
						
						exit
					endif
				endif
				
				SZV->(DbSkip())
			enddo
		endif
		
		SZV->(DbCloseArea())
		NF->(DbCloseArea())
	endif
	
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

//AxInclui( <cAlias>, <nReg>, <nOpc>, <aAcho>, <cFunc>, <aCpos>, <cTudoOk>, <lF3>, <cTransact>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
//AxAltera( <cAlias>, <nReg>, <nOpc>, <aAcho>, <aCpos>, <nColMens>, <cMensagem>, <cTudoOk>, <cTransact>, <cFunc>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
//AxDeleta( <cAlias>, <nReg>, <nOpc>, <cTransact>, <aCpos>, <aButtons>, <aParam>, <aAuto>, <lMaximized>)

//AxInclui('SZR',SZR->(Recno()),3,aAcho,,aCposI,'(U_IncluirSZR(),lRetInc)',.F.,,,,,,.T.,,,,,)
//AxAltera('SZR',SZR->(Recno()),4,aAcho,aCposA,,,'(U_AlterarSZR(),lRetInc)',,,,,,.T.)