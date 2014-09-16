#INCLUDE "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "XMLXFUN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CFGMI003  º Autor ³ Paulo Bindo        º Data ³  15/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Baixa Mensagens De NFE                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CFGMI003()
Local lWeb := .F.
Local aFileAtch := {}
Local cServer
Local lOk := .T.
Local lRelauth
Local lRet	   := .F.
Local cFrom
Local cConta
Local cSenhaa
Local cIniFile 		:= GetADV97()
Local cStartPath 	:= GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\ENTRADA\'
Local nMessages		:= 0
Local aContas		:={{"nf@ata.ind.br"},{"fiscal@ata.ind.br"},{"ti@ata.ind.br"}}
//Local aContas		:={{'suaconta@seudominio'},{suaconta@seudominio'},;
//{'suaconta@seudominio'},{'suaconta@seudominio'},{'suaconta@seudominio'}}

//VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE
If Select("SX6") == 0
	lWeb := .T.
	RpcSetType(3)
	RpcSetEnv("01","01")
EndIf

cServer	 := 'mail.ata.ind.br'
lRelauth := GetNewPar("MV_RELAUTH",.F.)		// Parametro que indica se existe autenticacao no e-mail
cSenhaa  := GetMV("MV_RELPSW")


//CRIA DIRETORIOS
MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\')
MakeDir(Trim(cStartPath)) //CRIA DIRETOTIO ENTRADA


For zX:=1 To Len(aContas)
	cFrom	 := aContas[zX][1]
	cConta   := aContas[zX][1] //SubStr(aContas[zX][1],1,At('@',aContas[zX][1])-1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Conta quantas mensagens existem                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	CONNECT POP SERVER cServer ;
	ACCOUNT cConta ;
	PASSWORD cSenhaa ;
	TIMEOUT 30 ;
	RESULT lRet
	
	POP MESSAGE COUNT nMessages
	
	If nMessages > 0 .And. lRet
		
		conout(" ")
		conout(Replicate("=",80))
		conout(OemtoAnsi("A conta NFE contem "+StrZero(nMessages,8)+" mensagem(s)") ) //###
		conout(Replicate("=",80))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recebe as mensagens e grava os arquivos XML           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nXml := 0
		For nX := 1 to nMessages
			aFileAtch := {}
			
			MailReceive(nX,,,,,,,aFileAtch,cStartPath,.T.)
			
			For nY := 1 to Len(aFileAtch)
				If ".XML" $ Upper(aFileAtch[nY][1])
					nXml++
					ConOut(" ")
					ConOut(Replicate("=",80))
					ConOut("Recebido o arquivo " + aFileAtch[nY][1]) //
					ConOut(Replicate("=",80))
					
					cStrAtch := Memoread(aFileAtch[nY][1])
					
					CREATE oXML XMLSTRING cStrAtch
					//QUANDO TIVER 500 XML SAI DA ROTINA, SENAO ESTOURA O ARRAY DO XML
					If nXml == 500
						Return
					EndIf
					
					
				Else
					Ferase(aFileAtch[nY][1])
				Endif
				
			Next nY
			
		Next nX
		
	Else
		Conout(Replicate("=",80))
		ConOut( Time()+" - Nao existem arquivos a serem recebidos" )
		Conout(Replicate("=",80))
	Endif
	
	DISCONNECT POP SERVER
Next

If lWeb
	RpcClearEnv()
EndIf
Return
