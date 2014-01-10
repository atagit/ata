#INCLUDE "Rwmake.ch"
#INCLUDE "TbiConn.ch"
#include "protheus.ch"
#INCLUDE "AP5MAIL.CH"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lMenu      (L): Rotina acessada via menu                                                                         //
// lMostra    (L): Mostra as mensagens geradas pela rotina                                                          //
// cServer    (C): Servidor SMPT para envio                                                                         //
// cAccount   (C): Conta para envio do email                                                                        //
// cPassword  (C): Senha da conta                                                                                   //
// cTo        (C): Destinatários                                                                                    //
// aFiles     (A): Vetor de [x] contendo os arquivos a serem anexados no mail (colocar caminho - abaixo do \system\)//
// cSubject   (C): Assunto do mail                                                                                  //
// cMensagem  (C): Corpo da mensagem                                                                                //
// lConfirma  (L): Confirmação de leitura                                                                           //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*User Function EnvEmail(lMenu,lMostra,cServer,cAccount,cPassword,cTo,aFiles,cSubject,cMensagem,lConfirma)
	       
	Local lOk     := .F.               
	Local cErro   := Space(0)
	Local aArea   := GetArea()                                                    
	Local cAnexos := MontaAnexo(aFiles)
	Local cServer := ""
	Local cAccount := ""                                                    
	Local cPassword := ""
	
	default cServer := GetMV("MV_RELSERV")
	default cAccount := GetMV("MV_RELPSW")
	default cPassword := GetMV("MV_RELACNT")
	
	lMenu   		:= Iif(lMenu == Nil 	,.T.,lMenu)
	lMostra 		:= Iif(lMostra == Nil  	,.T.,lMostra)  
	lConfirma 		:= Iif(lConfirma == Nil  	,.F.,lConfirma)  
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
	
	If lOk 
		ConfirmMailRead(lConfirma)
		
		SEND MAIL FROM cAccount TO cTo SUBJECT cSubject BODY cMensagem ATTACHMENT cAnexos RESULT lOk
		
		If !(lOk)
			GET MAIL ERROR cErro  
			
			If lMostra
				If lMenu    
					MsgAlert(cErro, "Erro durante o envio")
		  		Else
					ConOut("Erro durante o envio: "+cErro)
				EndIf
			EndIf
		EndIf
		
		DISCONNECT SMTP SERVER RESULT lOK
		
		If !(lOk)
			GET MAIL ERROR cErro     
			
			If lMostra
				If lMenu 
					MsgAlert(cErro, "Erro durante a desconexao")                     
				Else
					ConOut("Erro durante a desconexao: "+cErro)
				EndIf
			EndIf
		Else     
			If lMostra
				If lMenu 
					MsgBox("Email Enviado com sucesso","Email","INFO")
				Else                     
					ConOut("Email Enviado com sucesso!")
					ConOut("")
				EndIf
			EndIf
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return(lOk)

Static Function MontaAnexo(aFiles)
	
	Local cAnexo := "" 
	
	aFiles  := Iif(aFiles = Nil .Or. Empty(aFiles)	,{} ,aFiles)
	
	For nX := 1 To Len(aFiles)       
		If nX = Len(aFiles)
			cAnexo += aFiles[nX]
		Else                 
			cAnexo += aFiles[nX]+","
		EndIf
	Next nX
	
Return(cAnexo)*/


User Function EnvMail(_cPara, _cCc, _cBCC, _cTitulo, _aAnexo, _cMsg, _lAudit)
	Local oMail
	Local oMessage
	Local nRet
	Local nTimeout := GetMV("MV_RELTIME")	//Timeout no Envio de E-Mail;
	Local cServer  := GetMV("MV_RELSERV")	//Nome do Servidor de Envio de E-Mail utilizado nos relatorios;
	Local cEmail   := GetMV("MV_RELACNT")	//Conta a ser utilizada no envio de E-Mail para os relatorios;
	Local cEmailA  := GetMV("MV_RELAUSR")	//Usuario para Autenticacao no Servidor de E-Mail;
	Local cEmailFr := GetMV("MV_RELFROM")	//E-Mail utilizado no campo FROM no envio de relatorios por E-Mail;
	Local cPass    := GetMV("MV_RELPSW")	//Senha da Conta de E-Mail para envio de relatorios;
	Local lAuth    := GetMv("MV_RELAUTH")	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
	Local cMailAud := GetMv("MV_MAILADT")	//Conta oculta de auditoria utilizada no envio de E-Mail para os relatorios;
	Local lUseSSL  := GetMv("MV_RELSSL")	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
	Local lUseTLS  := GetMv("MV_RELTLS")	//Informe se o servidor de SMTP possui conexao do tipo segura (SSL/TLS);
	Local _nPorta  := 25			//Porta Default;
	
	DEFAULT _cPara := ""
	DEFAULT _cCc   := ""
	DEFAULT _cBCC  := ""
	DEFAULT _cMsg  := ""
	DEFAULT _aAnexo  := {}
	DEFAULT _cTitulo := ""
	DEFAULT _lAudit  := ""

	ProcRegua(15)

	//---------------------------------------------------------------------------------------------------------------------
	//VALIDANDO OS PARAMETROS INFORMADOS
	If Empty(cServer) .OR. Empty(cEmail) .OR. Empty(cEmailA) .OR. Empty(cPass)
		MsgBox("Verifique os parametros: MV_RELSERV, MV_RELACNT, MV_RELAUSR ou MV_RELPSW!!!","Funcao EnvMail","STOP") 
		Return(.F.)
	EndIf

	If Empty(_cPara)
		MsgBox("Parametro 'Para' tem preenchimento obrigatorio!!!","Funcao EnvMail","STOP") 
		Return(.F.)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CASO O ENDERECO DO SERVER TENHA A PORTA INFORMADA, SEPARA OS CAMPOS
	If(At(":",cServer) > 0)
		_nPorta := Val(Substr(cServer,At(":",cServer)+1,Len(cServer)))
		cServer := Substr(cServer,0,At(":",cServer)-1)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	oMail := TMailManager():New()
	If(lUseSSL)
		oMail:SetUseSSL(lUseSSL)
	EndIf
	If(lUseTLS)
		oMail:SetUseTLS(lUseTLS)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE AS CONFIGURACOES, DA CLASSE TMAILMANAGER, PARA REALIZAR UMA CONEXAO COM O SERVIDOR DE E-MAIL
	oMail:Init("",cServer,cEmail,cPass,0,_nPorta)

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE O TEMPO DE ESPERA PARA UMA CONEXAO ESTABELECIDA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	If (nTimeout <= 0)
		ConOut("[TIMEOUT] DISABLE")
	Else
		IncProc("[TIMEOUT] ENABLE()")
		ConOut("[TIMEOUT] ENABLE()")
		nRet := oMail:SetSmtpTimeOut(nTimeout)

		If nRet != 0
			ConOut("[TIMEOUT] Fail to set")
			ConOut("[TIMEOUT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			MsgBox("[TIMEOUT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
			oMail:SMTPDisconnect()
			Return(.F.)
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CONECTA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	IncProc("[SMTPCONNECT] connecting ...")
	ConOut("[SMTPCONNECT] connecting ...")
	nRet := oMail:SmtpConnect()
	If nRet <> 0
		ConOut("[SMTPCONNECT] Falha ao conectar")
		ConOut("[SMTPCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[SMTPCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		ConOut("[SMTPCONNECT] Sucesso ao conectar")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//REALIZA A AUTENTICACAO NO SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL) PARA ENVIO DE MENSAGENS
	If lAuth
		IncProc("[AUTH] ENABLE")
		ConOut("[AUTH] ENABLE")
		ConOut("[AUTH] TRY with ACCOUNT() and PASS()")

		nRet := oMail:SMTPAuth(cEmailA,cPass)
		If nRet != 0
			IncProc("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			ConOut("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			ConOut("[AUTH] TRY with USER() and PASS()")
			MsgBox("[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
			nRet := oMail:SMTPAuth(cEmailA,cPass)

			If nRet != 0
				ConOut("[AUTH] FAIL TRY with USER() and PASS()")
				ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
				MsgBox("[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
				oMail:SMTPDisconnect()
				Return(.F.)
			Else
				IncProc("[AUTH] SUCEEDED TRY with USER() and PASS()")
				ConOut("[AUTH] SUCEEDED TRY with USER() and PASS()")
			EndIf
		Else
			IncProc("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
			ConOut("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
		EndIf
	Else
		IncProc("[AUTH] DISABLE")
		ConOut("[AUTH] DISABLE")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	IncProc("[MESSAGE] Criando mail message")
	ConOut("[MESSAGE] Criando mail message")
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cEmailFr
	oMessage:cTo      := _cPara
	oMessage:cCc      := _cCc
	oMessage:cBCC     := IIF(_lAudit, cMailAud, "") + IIF(!Empty(_cBCC), (";" + _cBCC),"")
	oMessage:cSubject := _cTitulo
	oMessage:cBody    := _cMsg

	For _nX := 1 to Len(_aAnexo)
		oMessage:AddAttHTag("Content-ID: <" + _aAnexo[_nX][01] + ">")	//Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
//		oMessage:AddAttHTag("Content-Disposition: attachment; filename=" + _aAnexo[_nX][01])	//Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		oMessage:AttachFile(_aAnexo[_nX][02])							//Adiciona um anexo, nesse caso a imagem esta no root
	Next _nX
	oMessage:MsgBodyType("text/html")

	//---------------------------------------------------------------------------------------------------------------------
	//ENVIA E-MAIL ATRAVÉS DO PROTOCOLO SMTP
	IncProc("[SEND] Sending ...")
	ConOut("[SEND] Sending ...")
	nRet := oMessage:Send(oMail)
	If nRet <> 0
		ConOut("[SEND] Fail to send message")
		ConOut("[SEND][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[SEND][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		IncProc("[SEND] Success to send message")
		ConOut("[SEND] Success to send message")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//FINALIZA A CONEXAO ENTRE A APLICACAO E O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	IncProc("[DISCONNECT] smtp disconnecting ... ")
	ConOut("[DISCONNECT] smtp disconnecting ... ")
	oMail:SMTPDisconnect()
	If nRet != 0
		IncProc("[DISCONNECT] Fail smtp disconnecting ... ")
		ConOut("[DISCONNECT] Fail smtp disconnecting ... ")
		ConOut("[DISCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[DISCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
	Else
		IncProc("[DISCONNECT] Success smtp disconnecting ... ")
		ConOut("[DISCONNECT] Success smtp disconnecting ... ")
	EndIf

Return(.T.)