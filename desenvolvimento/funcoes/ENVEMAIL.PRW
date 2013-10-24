#INCLUDE "Rwmake.ch"
#INCLUDE "TbiConn.ch"

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

User Function EnvEmail(lMenu,lMostra,cServer,cAccount,cPassword,cTo,aFiles,cSubject,cMensagem,lConfirma)
	       
	Local lOk     := .F.               
	Local cErro   := Space(0)
	Local aArea   := GetArea()                                                    
	Local cAnexos := MontaAnexo(aFiles)    
	
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
	
	Local cAnexo := Space(0) 
	
	aFiles  := Iif(aFiles = Nil .Or. Empty(aFiles)	,{} ,aFiles)
	
	For nX := 1 To Len(aFiles)       
		If nX = Len(aFiles)
			cAnexo += aFiles[nX]
		Else                 
			cAnexo += aFiles[nX]+","
		EndIf
	Next nX
	
Return(cAnexo)