#INCLUDE "PROTHEUS.CH"  				
#INCLUDE "COLORS.CH"	
#INCLUDE "TBICONN.CH"  

//** BRENO **//
#include "topconn.ch"
//**********//

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³XmlNFeSef ³ Autor ³ Eduardo Riera         ³ Data ³13.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para geracao da Nota Fiscal Eletronica do ³±±
±±³          ³SEFAZ - Versao T01.00 / 2.00                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³String da Nota Fiscal Eletronica                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo da NF                                           ³±±
±±³          ³       [0] Entrada                                          ³±±
±±³          ³       [1] Saida                                            ³±±
±±³          ³ExpC2: Serie da NF                                          ³±±
±±³          ³ExpC3: Numero da nota fiscal                                ³±±
±±³          ³ExpC4: Codigo do cliente ou fornecedor                      ³±±
±±³          ³ExpC5: Loja do cliente ou fornecedor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function XmlNfeSef(cTipo,cSerie,cNota,cClieFor,cLoja,cNotaOri,cSerieOri)

Local aNota     	:= {}
Local aDupl     	:= {}
Local aDest     	:= {}
Local aEntrega  	:= {}
Local aProd     	:= {}
Local aICMS     	:= {}
Local aICMSST   	:= {}
Local aICMSZFM		:= {}
Local aIPI      	:= {}
Local aPIS      	:= {}                         
Local aCOFINS   	:= {}
Local aPISST    	:= {}
Local aCOFINSST 	:= {}
Local aISSQN   		:= {}
Local aISS      	:= {}
Local aCST      	:= {}
Local aRetido   	:= {}
Local aTransp   	:= {}
Local aImp      	:= {}
Local aVeiculo  	:= {}
Local aReboque  	:= {}
Local aReboqu2  	:= {}
Local aEspVol   	:= {}
Local aNfVinc   	:= {}
Local aPedido   	:= {}
Local aOldReg   	:= {}
Local aOldReg2  	:= {}
Local aMed			:= {}
Local aArma			:= {}
Local aComb			:= {}
Local aveicProd		:= {}
Local aIEST			:= {}
Local aDI			:= {}
Local aAdi			:= {}
Local aExp			:= {}
Local aDados		:= {}
Local aPisAlqZ		:= {}
Local aCofAlqZ		:= {}
Local aCsosn		:= {}
Local aIPIDev		:= {}
Local aIPIAux		:= {}
Local aNotaServ 	:= {}
Local aAnfC	   		:= {}
Local aAnfI	   		:= {} 
Local aPedCom   	:= {} 
Local aInfoItem		:= {}
Local aNfVincRur	:= {}
Local aRefECF		:= {}
Local aAreaSD2  	:= {}    			// Area do SD2
Local aAreaSF2  	:= {}    			// Area do SF2
Local aAreaSF3  	:= {}
Local aRetServ 		:= {}
Local aRetirada		:= {}
Local aMotivoCont 	:= {}
Local aTotal    	:= {0,0}
Local aIPICST		:= {}
Local aFCI			:= {}
Local aDocDat		:= {}

Local cString    	:= ""
Local cNatOper   	:= ""
Local cModFrete  	:= ""
Local cScan      	:= ""
Local cEspecie   	:= ""
Local cMensCli   	:= ""
Local cMensONU   	:= ""
Local cMensFis   	:= ""
Local cNFe       	:= ""
Local cMVSUBTRIB 	:= ""
Local cLJTPNFE		:= ""
Local cWhere		:= ""
Local cMunISS		:= ""
Local cCodIss		:= ""
Local cValIPI    	:= ""
Local cNCM	     	:= "" 
Local cField		:= ""
Local cRetISS   	:= ""
Local cTipoNF   	:= ""
Local cDocEnt  		:= ""
Local cSerEnt  		:= ""
Local cFornece  	:= ""
Local cLojaEnt  	:= ""
Local cTipoNFEnt	:= ""
Local cPedido   	:= ""
Local cItemPC   	:= ""
Local cNFOri    	:= ""
Local cSerOri   	:= ""
Local cItemOri  	:= ""
Local cProd     	:= ""
Local cTribMun  	:= ""
Local cModXML   	:= ""
Local cItem			:= ""
Local cAnfavea		:= ""
Local cSerNfCup 	:= ""  		   		// Serie da NF sobre Cupom
Local cNumNfCup 	:= ""  	 			// Numero do Documento da NF sobre Cupom
Local cD2Cfop  		:= ""    			// CFOP da nota 
Local cD2Tes  		:= ""    			// TES do SD2
Local cSitTrib		:= ""
Local cValST  		:= ""
Local cBsST    		:= ""
Local cChave 		:= ""
Local cTPNota		:= "" 
Local cItemOr		:= ""
Local cCST      	:= ""
Local cInfAdic		:= ""
Local cServ     	:= ""
Local cMunPres  	:= ""
Local cAliasSE1  	:= "SE1"
Local cAliasSE2  	:= "SE2"
Local cAliasSD1  	:= "SD1"
Local cAliasSD2  	:= "SD2" 
local cAliasDY3   :="DY3"
local cAliasSB5   :="SB5"
Local cAmbiente		:= {}
Local cVerAmb     	:= {}
Local cAnttRntrc	:= iif(!Empty(SM0->M0_RNTRC),AllTrim(SM0->M0_RNTRC), AllTrim(SuperGetMV("MV_TMSANTT",,"")))  //Parametro do TMS que informa o codigo ANTT do transpotador
Local cMVNFEMSA1	:= AllTrim(GetNewPar("MV_NFEMSA1",""))
Local cMVNFEMSF4	:= AllTrim(GetNewPar("MV_NFEMSF4",""))
Local cMVCFOPREM	:= AllTrim(GetNewPar("MV_CFOPREM",""))     // Parâmetro que informa as CFOPs de Remessa para entrega Futura que terão tratamento para que o valor de IPI seja considerado como Outras Despesas Acessórias (tag vOutros).
Local cConjug   	:= AllTrim(SuperGetMv("MV_NFECONJ",,""))
Local cMV_LJTPNFE	:= SuperGetMV("MV_LJTPNFE", ," ")
Local cMVCODREG		:= SuperGetMV("MV_CODREG", ," ")
Local cValLiqB		:= SuperGetMv("MV_BX10925", ,"2")
Local cDescServ 	:= SuperGetMV("MV_NFESERV", ,"2")
Local cCfop			:= SuperGetMV("MV_SIMPREM", ," ")         // Parametro do cadastro das CFOPs para Simples Remessa e cliente optante pelo Simples Nacional
local cMVREFNFE		:= SuperGetMV("MV_REFNFE", ," ") 			// Parametro para informe quais CFOPs são de simples Remessa para levar informação 
Local cMVCfopTran	:= SuperGetMV("MV_CFOPTRA", ," ")   		// Parametro que define as CFOP´s pra transferência de Crédito/Débito
Local cCliLoja		:= "" 
Local cCliNota		:= ""
Local cInfAdPr      := SuperGetMV("MV_INFADPR", .F.,"2")      // Parametro que define de onde sera impressa as informacoes adicionais do produto
Local cInfAdPed  	:= ""
Local cCodProd      := "" 
Local cDescProd     := ""
Local cMsSeek       := ""
Local cTpPessoa		:= ""
Local cSeekD1		:= ""  
Local cIpiCst		:= ""
Local cNfRefcup		:= ""
Local cSerRefcup	:= ""
Local cOrigem		:= ""
Local cCSTrib		:= ""
Local cMsgFci		:= "" 
Local cChaveD2		:= ""
Local cChaveD1		:= ""
Local aMensAux		:= {}
Local cMVAEHC 		:= AllTrim(GetNewPar("MV_AEHC",""))     // Informar o código de classificação AEHC
Local nA         	:= 0
Local cIndPres		:= ""
Local cIndIss		:= ""
Local nX         	:= 0
Local nY		 	:= 0
Local nCon       	:= 1  
Local nCstIpi 		:= 1
Local nLenaIpi		:= 0
Local nPosI			:= 0
Local nPosF	     	:= 0
Local nBaseIrrf  	:= 0
Local nValIrrf   	:= 0
Local nValIPI    	:= 0
Local nValAux    	:= 0
Local nValPisZF  	:= 0
Local nValCofZF  	:= 0
Local nPisRet   	:= 0
Local nCofRet   	:= 0
Local nInssRet  	:= 0
Local nIrRet    	:= 0
Local nCsllRet  	:= 0
Local nDedu     	:= 0
Local nIssRet   	:= 0
Local nTotRet   	:= 0
Local nRedBC    	:= 0
Local nValST    	:= 0
Local nValSTAux 	:= 0
Local nBsCalcST 	:= 0
Local nMargem		:= 0
Local nDesconto 	:= 0   			// Desconto no total da NF sobre cupom
Local nDescRed  	:= 0   			// Valores dos descontos dos itens referente ao Decreto nº 43.080/2002 RICMS-MG (SFT)
Local nDesTotal  	:= 0   			// Valor total dos descontos referente ao Decreto nº 43.080/2002 RICMS-MG
Local nDescIcm  	:= 0   			// Valor do desconto do ICMS-Quando TES configurada com AGREGA Valor = D
Local nDescZF	  	:= 0   			// Valores dos descontos Zona Franca
Local nPercLeite	:= 0  			//Percentual da redução do Leite	
Local nValLeite		:= 0   			//Valor da reduçao do Leite
Local nPrTotal		:= 0   
Local nCont	 		:= 0
Local nValBse		:= 0
Local nValIss		:= 0
Local nIcmsST		:= 0
Local cNumitem      := 0
Local nOrderSF1		:= 0
Local nRecnoSF1		:= 0  
Local nValIcm		:= 0
Local nBaseIcm		:= 0
Local nValParImp	:= 0
Local nContImp		:= 0
Local nSF3Index		:= 0
Local nSF3Recno		:= 0
local nValIPIDestac	:= 0
Local nValIcmDev	:= 0
Local nValIcmDif	:= 0
Local nIPIConsig	:= 0
Local nSTConsig		:= 0
Local nValICMParc := 0
Local nBasICMParc := 0
Local nValSTParc 	:= 0
Local nBasSTParc 	:= 0
Local nVicmsDeson	:= 0
Local nDeducao		:= 0
Local nVIcmDif		:= 0
Local nValISSRet	:= 0

Local lQuery    	:= .F.
Local lCalSol		:= .F.
Local lOk			:= .T.
Local lBrinde		:= .F.							// Flag que define se é uma operação de Brinde
Local lContinua	:= .T.
Local lCabAnf		:= .T.
Local lConsig   	:= .F. 								// Flag que diz se a operação é de consignação mercantil
Local lNfCup		:= .F.								// Define se eh Nf sobre cupom
Local lComplDev		:= .F.	   	  					//Utilizado para identificar quando for uma nota de complemento de IPI de uma devulução.
Local lIpiDev   	:= GetNewPar("MV_IPIDEV",.F.)   //Apenas para devolução de compra de IPI (nota de saída). T-Séra gerado na tag vIPI e destacado no campo
														//VALOR IPI do cabeçalho do danfe. F-Será gerado na tag vOutro e destacado nas informações complementares do danfe
														//e no campo OUTRAS DESPESAS ACESSORIAS
Local lIcmSTDev 	:= GetNewPar("MV_ICSTDEV",.T.)  //Indica se sera gravado no XML o valor e base de ICMS ST para nf de devolucao.(Padrao T - leva)
Local lIcmDevol	:= GetNewPar("MV_ICMDEVO",.T.)	//Define se sera gravado no XML o valor e base de ICMS para nf de devolucao. (Padrao T - leva)
Local lNatOper   	:= GetNewPar("MV_SPEDNAT",.F.)
Local lInfAdZF   	:= GetNewPar("MV_INFADZF",.F.)
Local lEndFis 		:= GetNewPar("MV_SPEDEND",.F.)
Local lCapProd  	:= GetNewPar("MV_CAPPROD",.F.)
Local lEECFAT		:= SuperGetMv("MV_EECFAT")
Local lMVCOMPET		:= SuperGetMV("MV_COMBPET", ,.F.)
Local lEasy			:= SuperGetMV("MV_EASY") == "S"
Local lSimpNac   	:= SuperGetMV("MV_CODREG")== "1" .or. SuperGetMV("MV_CODREG")== "2"
Local lCD2PARTIC	:=  CD2->(FieldPos("CD2_PARTIC")) > 0
Local lC6_CODINF	:= SC6->(FieldPos("C6_CODINF")) > 0 
Local lCpoAlqSB1 	:= SB1->(FieldPos("B1_IMPNCM")) > 0        	// Verifica a existencia do campo de Aliq. de Imposto NCM/NBS
Local lCpoAlqSBZ	:= SBZ->(FieldPos("BZ_IMPNCM")) > 0     	   	// Verifica a existencia do campo de Aliq. de Imposto NCM/NBS na tabela SBZ
Local lCpoMsgLT		:= SF4->(FieldPos("F4_MSGLT")) > 0 
Local lCpoLoteFor	:= SB8->(FieldPos("B8_LOTEFOR")) > 0  
Local lValFecp		:= SF3->(FieldPos("F3_VALFECP")) >0 
Local lVfecpst		:= SF3->(FieldPos("F3_VFECPST")) >0 
Local lSb1CT		:= SB1->(FieldPos("B1_X_CT")) >0 
Local lIpiBenef   	:= GetNewPar("MV_IPIBENE",.F.) 				//Nota de saída de retorno com tipo = Beneficiamento. .T.- Será gerado na tag vOutro e destacado nas informações
																		//complementares do danfe e no campo OUTRAS DESPESAS ACESESSORIAS. .F. - Séra gerado na tag vIPI e destacado no campo
																		//VALOR IPI do cabeçalho do danfe (procedimento padrão)
Local lMvImpFecp    := GetNewPar("MV_IMPFECP",.F.)	                // Imprime FECP
Local lOrgaoPub	  := GetNewPar("MV_NFORGPU",.F.)				//NF-e de remessa nas operações de aquisição de órgão público, com entrega em outro órgão público (RICMS SP)
																		//AJUSTE SINIEF 13, DE 26 DE JULHO DE 2013 

Local oWSNfe
Local lNfCupZero	:= .F.
Local lRural		:= .F.
Local lSeekOk   	:= .F.
Local lNotaBenef	:= .F.
Local lDifParc		:= .F.
Local lFCI			:= GetNewPar("MV_FCIDANF",.F.) // Imprime ou não os dados da FCI no Xml/Danfe (De acordo com as configurações necessárias)
Local aSb1			:= {}
Local lGE			:= FindFunction("LjUP104OK") .AND. LjUP104OK() .AND. SuperGetMV("MV_LJIMPGF",,.F.)	// Indica se usa garantia
Local cTpGar		:= SuperGetMV("MV_LJTPGAR",,"GE")
Local cFieldMsg		:= ""
Local lLjDescIt		:= .F.	// Inicializa as variaveis que serao utilizadas para desconto 
Local lFirstItem 	:= .T.
Local nTDescIt		:= 0
Local nCount		:= 0

Private aUF     	:= {}
Private aCSTIPI 	:= {}
Private lAnfavea	:= If(AliasIndic("CDR") .And. AliasIndic("CDS"),.T.,.F.) 
Private cFntCtrb	:= ""
Private cMvMsgTrib	:= SuperGetMV("MV_MSGTRIB",,"1")
Private cMvFntCtrb	:= SuperGetMV("MV_FNTCTRB",," ")
Private cMvFisCTrb	:= SuperGetMV("MV_FISCTRB",,"1")
Private lMvEnteTrb	:= SuperGetMV("MV_ENTETRB",,.F.)	// Valor dos tributos por Ente Tributante: Federal, Estadual e Municipal

Private nTotalCrg	:= 0
Private nTotFedCrg	:= 0	// Ente Tributante Federal
Private nTotEstCrg	:= 0	// Ente Tributante Estadual
Private nTotMunCrg	:= 0	// Ente Tributante Municipal

Private cTpCliente	:= ""
Private nTotNota	:= 0
Private cIdRecopi	:= ""
Private cNumRecopi	:= ""

//** BRENO **//
private cProjetos := ""
private dDataSai := ""
//**********//

If FunName() == "SPEDNFSE"
	DEFAULT cTipo   := PARAMIXB[1]
	DEFAULT cSerie  := PARAMIXB[3]
	DEFAULT cNota   := PARAMIXB[4]
	DEFAULT cClieFor:= PARAMIXB[5]
	DEFAULT cLoja   := PARAMIXB[6]     
	
	
Else
	Default cTipo     := PARAMIXB[1,1] // PARAMIXB[1]
	Default cSerie    := PARAMIXB[1,3] // PARAMIXB[3]
	Default cNota     := PARAMIXB[1,4] // PARAMIXB[4]
	Default cClieFor  := PARAMIXB[1,5] // PARAMIXB[5]
	Default cLoja     := PARAMIXB[1,6] // PARAMIXB[6]    
	aMotivoCont 	  := PARAMIXB[1,7]
	cVerAmb     	  := PARAMIXB[2]
	cAmbiente		  := PARAMIXB[3]                  
	DEFAULT cNotaOri  := PARAMIXB[4,1]                  
	DEFAULT cSerieOri := PARAMIXB[4,2]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

DbSelectArea ("SX6")
SX6->(DbSetOrder (1))
If (SX6->(DbSeek (cFilant+"MV_SUBTRI")))
	Do While !SX6->(Eof ()) .And. cFilant==SX6->X6_FIL .And. "MV_SUBTRI"$SX6->X6_VAR
		If !Empty(SX6->X6_CONTEUD)
			cMVSUBTRIB += "/"+AllTrim (SX6->X6_CONTEUD)
		EndIf
		SX6->(DbSkip ())
	EndDo
ElseIf (SX6->(DbSeek (SPACE(LEN(SX6->X6_FIL))+"MV_SUBTRI")))
	Do While !SX6->(Eof ()) .And. "MV_SUBTRI"$SX6->X6_VAR
		If !Empty(SX6->X6_CONTEUD)
			cMVSUBTRIB += "/"+AllTrim (SX6->X6_CONTEUD)
		EndIf
		SX6->(DbSkip ())
	EndDo
EndIf

If Empty(cMVSUBTRIB) .And. FindFunction("GETSUBTRIB") 
	cMVSUBTRIB := GetSubTrib()
Endif

If cTipo == "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona NF                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF2")
	dbSetOrder(1)
	If MsSeek(xFilial("SF2")+cNota+cSerie+cClieFor+cLoja)
		//** BRENO **//
		cProjetos := "Projeto(s): "+Projetos(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,"SF2")
		//**********//
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca dados do ISS                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF3")
		dbSetOrder(4)
		If MsSeek(xFilial("SF3")+cClieFor+cLoja+cNota+cSerie)
			While !SF3->(Eof()) .And. cClieFor+cLoja+cNota+cSerie == SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
				
				nCont++
				dbSelectArea("SFT")
				dbSetOrder(3)
				//FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3
				MsSeek(xFilial("SFT")+"S"+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_IDENTFT)
				
				dbSelectArea("SD2")
				dbSetOrder(3)
				MsSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO)
				dbSelectArea("SF4")
				dbSetOrder(1)
				MsSeek(xFilial("SF4")+SD2->D2_TES)
				If SF3->F3_TIPO =="S"
					If SF3->F3_RECISS =="1"
						cSitTrib := "R"
					Elseif SF3->F3_RECISS =="2" 
						cSitTrib:= "N"
					Elseif SF4->F4_LFISS =="I"
						cSitTrib:= "I"
					Else
						cSitTrib:= "N"
					Endif
				Endif
				
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+SD2->D2_COD)
				If SB1->(FieldPos("B1_TRIBMUN"))>0
					cTribMun:= SB1->B1_TRIBMUN
				EndIf
				
				
				dbSelectArea("SD2")
				dbSetOrder(3)
				MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
				
				dbSelectArea("SA1")
				dbSetOrder(1) 
				MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
				
				cTpPessoa	:= SA1->A1_TPESSOA
					
				If nCont == 1
					Do While !SD2->(Eof ()) .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
							SF2->F2_DOC == (cAliasSD2)->D2_DOC . And. SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
							SF2->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And. SF2->F2_LOJA == (cAliasSD2)->D2_LOJA .And.;
							SF3->F3_TIPO == "S"
							nPrTotal += (cAliasSD2)->D2_PRCVEN
							SD2->(DbSkip ())
	   				EndDo
	   				
	   				dbSelectArea("SD2")
					dbSetOrder(3)
			   		MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			   		
	   				dbSelectArea("CD2")
					dbSetOrder(1)
					If DbSeek(xFilial("CD2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+cClieFor+cLoja+PadR(SD2->D2_ITEM,4)+(cAliasSD2)->D2_COD)
						Do While !CD2->(Eof ()) .And. CD2->CD2_DOC == (cAliasSD2)->D2_DOC  
		                    If Alltrim(CD2->CD2_IMP) == "ISS" 
		                    	nValIss	+= CD2->CD2_VLTRIB 
							EndIf
							CD2->(DbSkip ())
						EndDo 
					EndIf 
	   			EndIf		
				
				If FunName() == "SPEDNFSE" //.Or. FunName() == "SPEDCTE"
								
					If SF3->F3_TIPO =="S"
						aadd(aISSQN,;
									{AllTrim(SF3->F3_CODISS),;
									nPrTotal+SF3->F3_VALOBSE,;
									SF3->F3_CNAE,;
									SF3->F3_ALIQICM,;
									IIf((SM0->M0_CODMUN == "3106200" .And. cTpPessoa == "EP"),nValIss,SF3->F3_VALICM),;
									SF3->F3_VALOBSE,;
									cTribMun,;
									SF3->F3_BASEICM,;
									cSitTrib})
					Else
						aadd(aISSQN,;
									{"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									""})
					Endif
				EndIf				
				
				SF3->(dbSkip())
			End
			
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento temporario do CTe                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FunName() == "SPEDCTE" .Or. AModNot(SF2->F2_ESPECIE)=="57"
			cNFe := "CTe35080944990901000143570000000000200000168648"
			cString := '<infNFe versao="T02.00" modelo="57" >'
			cString += '<CTe xmlns="http://www.portalfiscal.inf.br/cte">'
			cString += '<infCte Id="CTe35080944990901000143570000000000200000168648" versao="1.02"><ide><cUF>35</cUF><cCT>000016864</cCT><CFOP>6353</CFOP>'
			cString += '<natOp>ENTREGA NORMAL</natOp><forPag>1</forPag><mod>57</mod><serie>0</serie><nCT>20</nCT><dhEmi>2008-09-12T10:49:00</dhEmi>'
			cString += '<tpImp>2</tpImp><tpEmis>2</tpEmis><cDV>8</cDV><tpAmb>2</tpAmb><tpCTe>0</tpCTe><procEmi>0</procEmi><verProc>1.12a</verProc>'
			cString += '<cMunEmi>3550308</cMunEmi><xMunEmi>Sao Paulo</xMunEmi><UFEmi>SP</UFEmi><modal>01</modal><tpServ>0</tpServ><cMunIni>3550308</cMunIni>'
			cString += '<xMunIni>Sao Paulo</xMunIni><UFIni>SP</UFIni><cMunFim>3550308</cMunFim><xMunFim>Sao Paulo</xMunFim><UFFim>SP</UFFim><retira>1</retira>'
			cString += '<xDetRetira>TESTE</xDetRetira><toma03><toma>0</toma></toma03></ide><emit><CNPJ>44990901000143</CNPJ><IE>00000000000</IE>'
			cString += '<xNome>FILIAL SAO PAULO</xNome><xFant>Teste</xFant><enderEmit><xLgr>Av. Teste, S/N</xLgr><nro>0</nro><xBairro>Teste</xBairro><cMun>3550308</cMun>'
			cString += '<xMun>Sao Paulo</xMun><CEP>00000000</CEP><UF>SP</UF></enderEmit></emit><rem><CNPJ>58506155000184</CNPJ><IE>115237740114</IE><xNome>CLIENTE SP</xNome>'
			cString += '<xFant>CLIENTE SP</xFant><enderReme><xLgr>R</xLgr><nro>0</nro><xBairro>BAIRRO NAO CADASTRADO</xBairro><cMun>3550308</cMun><xMun>SAO PAULO</xMun>'
			cString += '<CEP>77777777</CEP><UF>SP</UF></enderReme><infOutros><tpDoc>00</tpDoc><dEmi>2008-09-17</dEmi></infOutros></rem><dest><CNPJ></CNPJ><IE></IE>'
			cString += '<xNome>CLIENTE RJ</xNome><enderDest><xLgr>R</xLgr><nro>0</nro><xBairro>BAIRRO NAO CADASTRADO</xBairro><cMun>3550308</cMun><xMun>RIO DE JANEIRO</xMun>'
			cString += '<CEP>44444444</CEP><UF>RJ</UF></enderDest></dest><vPrest><vTPrest>1.93</vTPrest><vRec>1.93</vRec></vPrest><imp><ICMS><CST00><CST>00</CST><vBC>250.00</vBC>'
			cString += '<pICMS>18.00</pICMS><vICMS>450.00</vICMS></CST00></ICMS></imp><infCteComp><chave>35080944990901000143570000000000200000168648</chave><vPresComp>'
			cString += '<vTPrest>10.00</vTPrest></vPresComp><impComp><ICMSComp><CST00Comp><CST>00</CST><vBC>10.00</vBC><pICMS>10.00</pICMS><vICMS>10.00</vICMS></CST00Comp>'
			cString += '</ICMSComp></impComp></infCteComp></infCte></CTe>'
			cString += '</infNFe>'
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento Nota de Servico  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf FunName() == "SPEDNFSE"
			
			//Modelo do XML ISSNET ou BH
			cModXML:= mv_par04
			
			aadd(aNotaServ,SF2->F2_SERIE)
			aadd(aNotaServ,SF2->F2_DOC)
			aadd(aNotaServ,SF2->F2_EMISSAO)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona cliente  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			aadd(aDest,AllTrim(SA1->A1_CGC))
			aadd(aDest,SA1->A1_NOME)
			aadd(aDest,FisGetEnd(SA1->A1_END,SA1->A1_EST)[1])
			If "/" $ FisGetEnd(SA1->A1_END,SA1->A1_EST)[3]
				aadd(aDest,IIF(FisGetEnd(SA1->A1_END,SA1->A1_EST)[3]<>"",FisGetEnd(SA1->A1_END,SA1->A1_EST)[3],"SN"))
			Else
 				aadd(aDest,IIF(FisGetEnd(SA1->A1_END,SA1->A1_EST)[2]<>0,FisGetEnd(SA1->A1_END,SA1->A1_EST)[2],"SN"))			
			EndIf
			aadd(aDest,FisGetEnd(SA1->A1_END,SA1->A1_EST)[4])
			aadd(aDest,SA1->A1_BAIRRO)
			
			If !Upper(SA1->A1_EST) == "EX"
				aadd(aDest,SA1->A1_COD_MUN)
			Else
				aadd(aDest,"99999")
			EndIf
			aadd(aDest,Upper(SA1->A1_EST))
			aadd(aDest,SA1->A1_CEP)
			aadd(aDest,SA1->A1_DDD+SA1->A1_TEL)
			aadd(aDest,SA1->A1_INSCRM)
			aadd(aDest,SA1->A1_EMAIL)
			
			If !Upper(SA1->A1_EST) == "EX"
				SC6->(dbSetOrder(4))
				SC5->(dbSetOrder(1))
				If (SC6->(MsSeek(xFilial("SC6")+SF2->F2_DOC+SF2->F2_SERIE)))
					SC5->(MsSeek(xFilial("SC5")+SC6->C6_NUM))
					
					If Empty (SC5->C5_FORNISS)
						aadd(aDest,SA1->A1_COD_MUN)
						aadd(aDest,Upper(SA1->A1_EST))
					Else
						SA2->(dbSetOrder(1))
						SA2->(MsSeek(xFilial("SA2")+SC5->C5_FORNISS+"00"))
						aadd(aDest,SA2->A2_COD_MUN)
						aadd(aDest,Upper(SA2->A2_EST))
					Endif
					
				Else
					aadd(aDest,SA1->A1_COD_MUN)
					aadd(aDest,Upper(SA1->A1_EST))
				EndIf
			Else
				aadd(aDest,"99999")
				aadd(aDest,Upper(SA1->A1_EST))
				
			EndIf
			
			dbSelectArea("SF3")
			dbSetOrder(4)
			MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
			
			While !Eof() .And. xFilial("SF3") == SF3->F3_FILIAL .And.;
				SF2->F2_SERIE == SF3->F3_SERIE .And.;
				SF2->F2_DOC == SF3->F3_NFISCAL .And. !Empty(SF3->F3_CODISS) .And. SF3->F3_TIPO=="S"
				
				//Natureza da Operação
				If SF3->(FieldPos("F3_ISSST"))>0
					cNatOper:= SF3->F3_ISSST
				EndIf
				
				//Tipo de RPS - O sistema de BH ainda não está recebendo Notas Conjugadas
				//If SF2->F2_ESPECIE $ cConjug
				//cTipoRps:="2" //RPS - Conjugada (Mista)
				If !Empty(SF2->F2_PDV)
					cTipoRps:="3" //Cupom
				Else
					cTipoRps:="1" //RPS
				EndIf
				
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega os impostos de retencao somente quando houver a retenção, ³
				//³ou seja, os titulos de retenção que existirem                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE1")
				SE1->(dbSetOrder(2))
				If SE1->(dbSeek(xFilial("SE1")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL))
					While !SE1->(Eof()) .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
							SF3->F3_CLIEFOR == SE1->E1_CLIENTE .And. SF3->F3_LOJA == SE1->E1_LOJA .And.;
							SF3->F3_SERIE == SE1->E1_PREFIXO .And. SF3->F3_NFISCAL == SE1->E1_NUM
						If 'NF' $ SE1->E1_TIPO
							nTotRet+=SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_BAIXA,,@nIrRet,@nCsllRet,@nPisRet,@nCofRet,@nInssRet)
						EndIf
						SE1->(DbSkip ())
					EndDo
				EndIf
				
				aadd(aRetServ,{nIrRet,nCsllRet,nPisRet,nCofRet,nInssRet,nTotRet})
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega as deduções ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF3->(FieldPos("F3_ISSSUB"))>0
					nDedu+= SF3->F3_ISSSUB
				EndIf
				
				If SF3->(FieldPos("F3_ISSMAT"))>0
					nDedu+= SF3->F3_ISSMAT
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtem os dados do Serviço ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SX5->(dbSeek(xFilial("SX5")+"60"+SF3->F3_CODISS))
					//Verifico se a Descrição é composta do pedido de Venda ou SX5
					If cDescServ$"1"
						SC6->(dbSetOrder(4))
						SC5->(dbSetOrder(1))
						MsSeek(xFilial("SC6")+SF3->F3_NFISCAL+SF3->F3_SERIE)
						MsSeek(xFilial("SC5")+SC6->C6_NUM)
						
		           		cFieldMsg := GetNewPar("MV_CMPUSR","")
					
						If !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
							cServ := &("SC5->"+cFieldMsg) 
						Else
							//cServ := SC5->C5_MENNOTA

							//** BRENO **//
							cServ := AllTrim(AllTrim(SC5->C5_MENNOTA)+" "+AllTrim(SC5->C5_MENNOT2)+" "+AllTrim(SC5->C5_MENNOT3))
							//**********//
						EndIf

						//** BRENO **//
						cServ += Chr(13)+Chr(10)+cProjetos
						//**********//

						If Empty(cServ)
							cServ := SX5->X5_DESCRI
						EndIf
					Else
						cServ := SX5->X5_DESCRI
					EndIf
				EndIf
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se recolhe ISS Retido ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF3->(FieldPos("F3_RECISS"))>0
					If SF3->F3_RECISS $"1S"
						cRetIss :="1"
						nIssRet := SF3->F3_VALICM
					Else
						cRetIss :="2"
						nIssRet := 0
					Endif
				ElseIf SA1->A1_RECISS $"1S"
					cRetIss :="1"
					nIssRet := SF3->F3_VALICM
				Else
					cRetIss :="2"
					nIssRet := 0
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se municipio de prestação foi informado no pedido ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
				If SC5->(FieldPos("C5_MUNPRES")) > 0 .And. !Empty(SC5->C5_MUNPRES)
					cMunPres  := SC5->C5_MUNPRES
					cMunPres:= ConvType(aUF[aScan(aUF,{|x| x[1] == aDest[14]})][02]+cMunPres)
					cDescMunP := SC5->C5_DESCMUN
				Else
					cMunPres:= aDest[13]
					cMunPres:= ConvType(aUF[aScan(aUF,{|x| x[1] == aDest[14]})][02]+cMunPres)
					cDescMunP := aDest[08]
				EndIf
				
				
				dbSelectArea("SD2")
				dbSetOrder(3)
				MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
				
				
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+SD2->D2_COD)
				If SB1->(FieldPos("B1_TRIBMUN"))>0
					cTribMun:= SB1->B1_TRIBMUN
				EndIf
				
				
				cString := ""
				cString += NFSeIde(aNotaServ,cNatOper,cTipoRPS,cModXML)
				cString += NFSeServ(aISSQN[1],aRetServ[1],nDedu,nIssRet,cRetIss,cServ,cMunPres,cModXML,cTpPessoa)
				cString += NFSePrest(cModXML)
				cString += NFSeTom(aDest,cModXML,cMunPres)
				
				Exit
			EndDo
			
		Else
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para o caso de Nota sobre Cupom Fiscal, busca os dados da Nota  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  	
		  	If ("CF" $ SF2->F2_ESPECIE .OR. (LjAnalisaLeg(18)[1] .AND. "ECF" $ SF2->F2_ESPECIE )) .AND. ("S" $ SF2->F2_ECF) .AND. !Empty(SF2->F2_NFCUPOM) 
				cSerNfCup 	:= SubStr(SF2->F2_NFCUPOM,1,TamSx3("F2_SERIE")[1])
				cNumNfCup 	:= SubStr(SF2->F2_NFCUPOM,4,TamSx3("F2_DOC")[1]) 
				
				If !Empty(cNotaOri) .And. cNotaOri <> cNumNfCup				                                                            
					cSerNfCup 	:= cSerieOri
					cNumNfCup 	:= cNotaOri
				EndIf
				
				aAreaSF2  	:= SF2->(GetArea())
				
				
				
				
				DbSelectArea( "SF2" )
				DbSetOrder(1)  // F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
				If DbSeek( xFilial("SF2") + cNumNfCup + cSerNfCup)
					aadd(aNota,SF2->F2_SERIE)
					aadd(aNota,IIf(Len(SF2->F2_DOC)==6,"000","")+SF2->F2_DOC)
					aadd(aNota,SF2->F2_EMISSAO)
					lNfCup	:= .T.
					cCliNota	:= SF2->F2_CLIENTE
					cCliLoja	:= SF2->F2_LOJA
				EndIf
				RestArea(aAreaSF2)
 			EndIf       
            
			If !lNfCup .OR. Len(aNota) == 0
				aadd(aNota,SF2->F2_SERIE)
				aadd(aNota,IIF(Len(SF2->F2_DOC)==6,"000","")+SF2->F2_DOC)
				aadd(aNota,SF2->F2_EMISSAO)
			EndIf    
			
			aadd(aNota,cTipo)
			aadd(aNota,SF2->F2_TIPO)
			aadd(aNota,SF2->F2_HORA)

			//** BRENO **//
			if !Empty(SF2->F2_SAIDA)
				dDataSai := SF2->F2_SAIDA
 			endif
			//**********//

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona cliente ou fornecedor                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If !SF2->F2_TIPO $ "DB" 
			    dbSelectArea("SA1")
				dbSetOrder(1)
					
				If SF2->(FieldPos("F2_CLIENT"))<>0 .And. !Empty(SF2->F2_CLIENT+SF2->F2_LOJENT) .And. SF2->F2_CLIENT+SF2->F2_LOJENT<>SF2->F2_CLIENTE+SF2->F2_LOJA
				    dbSelectArea("SA1")
					dbSetOrder(1)
					MsSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)
					
					aadd(aEntrega,SA1->A1_CGC)
					aadd(aEntrega,MyGetEnd(SA1->A1_END,"SA1")[1])
					aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_END,"SA1")[2]<>0,MyGetEnd(SA1->A1_END,"SA1")[2],"SN")))
					aadd(aEntrega,MyGetEnd(SA1->A1_END,"SA1")[4])
					aadd(aEntrega,SA1->A1_BAIRRO)
					aadd(aEntrega,SA1->A1_COD_MUN)
					aadd(aEntrega,SA1->A1_MUN)
					aadd(aEntrega,Upper(SA1->A1_EST))
					aadd(aEntrega,SA1->A1_NOME)
					aadd(aEntrega,SA1->A1_INSCR)
				EndIf
						
				// Tratamento para quando existir um cliente de entrega, utilizá-lo ao invés do cliente de venda
				If !Empty(AllTrim(SF2->F2_CLIENT)) .And. !Empty(AllTrim(SF2->F2_LOJENT))
					MsSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)
					/*If Len(aEntrega) > 0
						MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)						
						//Se a UF da entrega for diferente da UF do Cliente, tenho que buscar os dados do cliente para nao ocorrer rejeicao 523
						If  aEntrega[08] <> Upper(SA1->A1_EST)
							MsSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)		
						EndIf
					Endif */
				Else
					If !Empty(cCliNota+cCliLoja)
						MsSeek(xFilial("SA1")+cCliNota+cCliLoja)   //Busca os dados do cliente da Nota sobre Cupom para montar os dados do destinatário do XML
					Else
						MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
					EndIf
				EndIf
				If cMVNFEMSA1=="C" .And. !Empty(SA1->A1_MENSAGE)
					cMensCli	:=	SA1->(Formula(A1_MENSAGE))
				ElseIf cMVNFEMSA1=="F" .And. !Empty(SA1->A1_MENSAGE)
					cMensFis	:=	SA1->(Formula(A1_MENSAGE))
				EndIf
				aadd(aDest,AllTrim(SA1->A1_CGC))
				aadd(aDest,SA1->A1_NOME)
				aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[1])
			   
				If MyGetEnd(SA1->A1_END,"SA1")[2]<>0
					aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[3]) 
				Else 
					aadd(aDest,"SN") 
				EndIf

				aadd(aDest,IIF(SA1->(FieldPos("A1_COMPLEM")) > 0 .And. !Empty(SA1->A1_COMPLEM),SA1->A1_COMPLEM,MyGetEnd(SA1->A1_END,"SA1")[4]))
				aadd(aDest,SA1->A1_BAIRRO)
				If !Upper(SA1->A1_EST) == "EX"
					aadd(aDest,SA1->A1_COD_MUN)
					aadd(aDest,SA1->A1_MUN)				
				Else
					aadd(aDest,"99999")			
					aadd(aDest,"EXTERIOR")
				EndIf
				aadd(aDest,Upper(SA1->A1_EST))
				aadd(aDest,SA1->A1_CEP)
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
				aadd(aDest,SA1->A1_DDD+SA1->A1_TEL)                                                 				
				If !Upper(SA1->A1_EST) == "EX"                                                      				
					If !Empty(SA1->A1_INSCRUR) .And. SA1->A1_PESSOA == "F" .And. IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT)) == "PR"  .And. SA1->A1_EST == "PR"
						aadd(aDest,SA1->A1_INSCRUR)
					Else
						aadd(aDest,VldIE(SA1->A1_INSCR))
											
					EndIF	
				Else
					aadd(aDest,"")							
				EndIf
				aadd(aDest,SA1->A1_SUFRAMA)
				aadd(aDest,SA1->A1_EMAIL)
				aAdd(aDest,SA1->A1_CONTRIB) // Posição 17
				aadd(aDest,Iif(SA1->(FieldPos("A1_IENCONT")) > 0 ,SA1->A1_IENCONT,""))
				aadd(aDest,SA1->A1_INSCRM)
				aadd(aDest,SA1->A1_TIPO)
				aadd(aDest,SA1->A1_PFISICA)//21-Identificação estrangeiro
										
			Else
			    dbSelectArea("SA2")
				dbSetOrder(1)
				// Tratamento para quando existir um cliente de entrega, utilizá-lo ao invés do fornecedor (apenas por garantia)
				If !Empty(AllTrim(SF2->F2_CLIENT)) .And. !Empty(AllTrim(SF2->F2_LOJENT))
					MsSeek(xFilial("SA2")+SF2->F2_CLIENT+SF2->F2_LOJENT)
				Else
					MsSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
				EndIf
		
				aadd(aDest,AllTrim(SA2->A2_CGC))
				aadd(aDest,SA2->A2_NOME)
				aadd(aDest,MyGetEnd(SA2->A2_END,"SA2")[1])
                
				If MyGetEnd(SA2->A2_END,"SA2")[2]<>0
					aadd(aDest,MyGetEnd(SA2->A2_END,"SA2")[3]) 
				Else 
					aadd(aDest,"SN") 
				EndIf

				aadd(aDest,IIF(SA2->(FieldPos("A2_COMPLEM")) > 0 .And. !Empty(SA2->A2_COMPLEM),SA2->A2_COMPLEM,MyGetEnd(SA2->A2_END,"SA2")[4]))				
				aadd(aDest,SA2->A2_BAIRRO)
				If !Upper(SA2->A2_EST) == "EX"
					aadd(aDest,SA2->A2_COD_MUN)
					aadd(aDest,SA2->A2_MUN)				
				Else
					aadd(aDest,"99999")			
					aadd(aDest,"EXTERIOR")
				EndIf			
				aadd(aDest,Upper(SA2->A2_EST))
				aadd(aDest,SA2->A2_CEP)
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_SISEXP")))
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR")))
				aadd(aDest,SA2->A2_DDD+SA2->A2_TEL)
				If !Upper(SA2->A2_EST) == "EX"				
					aadd(aDest,VldIE(SA2->A2_INSCR))
				Else
					aadd(aDest,"")							
				EndIf					
				aadd(aDest,"")//SA2->A2_SUFRAMA
				aadd(aDest,SA2->A2_EMAIL)					
				aAdd(aDest, "") // Posição 17 (referente a A1_CONTRIB, sendo passado como vazio já que não existe A2_CONTRIB)
				aadd(aDest,"")// Posição 18 (referente a A1_IENCONT, sendo passado como vazio já que não existe A2_IENCONT)
				aadd(aDest,SA2->A2_INSCRM)
				aadd(aDest,"")//Posição 20
				aadd(aDest,SA2->A2_PFISICA)//21-Identificação estrangeiro
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona transportador                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SF2->F2_TRANSP)
				dbSelectArea("SA4")
				dbSetOrder(1)
				MsSeek(xFilial("SA4")+SF2->F2_TRANSP)
				
				aadd(aTransp,AllTrim(SA4->A4_CGC))
				aadd(aTransp,SA4->A4_NOME)
				If (SA4->A4_TPTRANS <> "3")
				aadd(aTransp,VldIE(SA4->A4_INSEST))
				Else
                    aadd(aTransp,"")				
                EndIf    
				aadd(aTransp,SA4->A4_END)
				aadd(aTransp,SA4->A4_MUN)
				aadd(aTransp,Upper(SA4->A4_EST)	)
				aadd(aTransp,SA4->A4_EMAIL	)
						
				/*If !Empty(SF2->F2_VEICUL1)
					dbSelectArea("DA3")
					dbSetOrder(1)
					MsSeek(xFilial("DA3")+SF2->F2_VEICUL1)
					
					aadd(aVeiculo,DA3->DA3_PLACA)
					aadd(aVeiculo,DA3->DA3_ESTPLA)
					aadd(aVeiculo,Iif(DA3->(FieldPos("DA3_RNTC")) > 0 ,DA3->DA3_RNTC,iif(!Empty(cAnttRntrc),cAnttRntrc,"")))//RNTC
					
					If !Empty(SF2->F2_VEICUL2)
					
						dbSelectArea("DA3")
						dbSetOrder(1)
						MsSeek(xFilial("DA3")+SF2->F2_VEICUL2)
					
						aadd(aReboque,DA3->DA3_PLACA)
						aadd(aReboque,DA3->DA3_ESTPLA)
						aadd(aReboque,Iif(DA3->(FieldPos("DA3_RNTC")) > 0 ,DA3->DA3_RNTC,"")) //RNTC
						
						If !Empty(SF2->F2_VEICUL3)
							
							dbSelectArea("DA3")
							dbSetOrder(1)
							MsSeek(xFilial("DA3")+SF2->F2_VEICUL3)
							
							aadd(aReboqu2,DA3->DA3_PLACA)
							aadd(aReboqu2,DA3->DA3_ESTPLA)
							aadd(aReboqu2,Iif(DA3->(FieldPos("DA3_RNTC")) > 0 ,DA3->DA3_RNTC,"")) //RNTC
							
						EndIf
					EndIf					
				ElseIf lNfCup   
					SL1->(dbSetOrder(2))
					SL1->(MsSeek(xFilial("SL1")+SF2->F2_SERIE+SF2->F2_DOC))
			
					aadd(aVeiculo,SL1->L1_PLACA)
					aadd(aVeiculo,SL1->L1_UFPLACA)
					aadd(aVeiculo,iif(!Empty(cAnttRntrc),cAnttRntrc,""))  
									
				EndIf*/

				//** BRENO **//
				DbSelectArea("SC5")
				DbSetOrder(8)
				MsSeek(xFilial("SC5")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
				
				aadd(aVeiculo,SC5->C5_PLACA)
				aadd(aVeiculo,SC5->C5_UFPLACA)
				aadd(aVeiculo,"")//RNTC
				//**********//
			EndIf
						
			// Procura registro nos livros fiscais para tratamentos
			dbSelectArea("SF3")
			dbSetOrder(4)
			If MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
				// Verifica se o CFOP é de venda por consignação mercantil (CFOP 5111 ou 6111)
				If AllTrim(SF3->F3_CFO) == "5111" .Or. AllTrim(SF3->F3_CFO) == "6111"
					lConsig  := .T.
				elseif ( AllTrim(SF3->F3_CFO) == "5949" .or. AllTrim(SF3->F3_CFO) == "5910" ) .and. SM0->M0_ESTENT == 'SP' /*termos do inciso II do art. 456 do RICMS/ SP  chamado THPXGS*/ 
					//lBrinde := .T. //Retirado tratamento de brinde pois foi constatado pela consultoria tributária que nao e' possivel amarrar por CFOP.
				EndIf
												
				
				// Msg Simples Nacional
				If lSimpNac
					If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
						cMensFis += " "
					EndIf
					If SF2->F2_TIPO == "D"
						cMensFis += "Documento emitido por ME ou EPP optante pelo Simples Nacional. "
						cMensFis += "Base de cálculo do ICMS: R$ " + Str(SF2->F2_BASEICM, 14, 2) + ". "
						cMensFis += "Valor do ICMS: R$ " + Str(SF2->F2_VALICM, 14, 2) + ". "
					Else
						If SF2->F2_VALICM > 0 .And. !Alltrim(SF3->F3_CFO) $ cCfop  // Novo Tratamento
							cMensFis += "Documento emitido por ME ou EPP optante pelo Simples Nacional."
							cMensFis += "Permite o aproveitamento do credito de ICMS no valor de R$ " + Str(SF2->F2_VALICM, 14, 2) + " corresponde a aliquota de "+str(SD2->D2_PICM,5,2)+ "% , nos termos do art. 23 da LC 123/2006."
						Else 
							cMensFis += "Documento emitido por ME ou EPP optante pelo Simples Nacional. Nao gera direito a credito fiscal de IPI."
						EndIf
					EndIf
				EndIf
			EndIf		
			dbSelectArea("SF2")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volumes / Especie Nota de Saida                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cScan := "1"
			While ( !Empty(cScan) )
				cEspecie := Upper(FieldGet(FieldPos("F2_ESPECI"+cScan)))
				If !Empty(cEspecie)
					nScan := aScan(aEspVol,{|x| x[1] == cEspecie})
					If ( nScan==0 )
						aadd(aEspVol,{ cEspecie, FieldGet(FieldPos("F2_VOLUME"+cScan)) , SF2->F2_PLIQUI , SF2->F2_PBRUTO})
					Else
						aEspVol[nScan][2] += FieldGet(FieldPos("F2_VOLUME"+cScan))
					EndIf
				EndIf
				cScan := Soma1(cScan,1)
				If ( FieldPos("F2_ESPECI"+cScan) == 0 )
					cScan := ""
				EndIf
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura duplicatas                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If !Empty(SF2->F2_DUPL)	
				cLJTPNFE := (StrTran(cMV_LJTPNFE,","," ','"))+" "
				cWhere := cLJTPNFE
				dbSelectArea("SE1")
				dbSetOrder(1)	
				#IFDEF TOP
					lQuery  := .T.
					cAliasSE1 := GetNextAlias()
					BeginSql Alias cAliasSE1
						COLUMN E1_VENCORI AS DATE
						SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCORI,E1_VALOR,E1_VLCRUZ,E1_ORIGEM,E1_PIS,E1_COFINS,E1_CSLL,E1_INSS,E1_VLRREAL,E1_IRRF
						FROM %Table:SE1% SE1
						WHERE
						SE1.E1_FILIAL = %xFilial:SE1% AND
						SE1.E1_PREFIXO = %Exp:SF2->F2_PREFIXO% AND 
						SE1.E1_NUM = %Exp:SF2->F2_DUPL% AND 
						((SE1.E1_TIPO = %Exp:MVNOTAFIS%) OR
						 ((SE1.E1_ORIGEM IN ('LOJA701','FATA701','LOJA010')) AND SE1.E1_TIPO IN (%Exp:cWhere%))) AND
						SE1.%NotDel%
						ORDER BY %Order:SE1%
					EndSql
					
				#ELSE
					MsSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC)
				#ENDIF
				While !Eof() .And. xFilial("SE1") == (cAliasSE1)->E1_FILIAL .And.;
					SF2->F2_PREFIXO == (cAliasSE1)->E1_PREFIXO .And.;
					SF2->F2_DOC == (cAliasSE1)->E1_NUM     
						If (cAliasSE1)->E1_TIPO = MVNOTAFIS .OR. ((Alltrim((cAliasSE1)->E1_ORIGEM) $ 'LOJA701|FATA701|LOJA010') .AND. (cAliasSE1)->E1_TIPO $ cWhere)
							//Aletrado a busca do valor da Fatura do campo E1_VLCURZ para E1_VLRREAL, 
							//devido a titulos com desconto da TAXA do Cartão de Créito que não devem
							//ser repassados para o XML e DANFE.                                                                                    
							nValDupl := IIF((cAliasSE1)->E1_VLRREAL > 0,(cAliasSE1)->E1_VLRREAL,(cAliasSE1)->E1_VLCRUZ)
							If cValLiqB == "1"
								aadd(aDupl,{(cAliasSE1)->E1_PREFIXO+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_VENCORI;
								,(nValDupl-(cAliasSE1)->E1_PIS-(cAliasSE1)->E1_COFINS-(cAliasSE1)->E1_CSLL-(cAliasSE1)->E1_INSS)-(cAliasSE1)->E1_IRRF})					
							Else
								aadd(aDupl,{(cAliasSE1)->E1_PREFIXO+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_VENCORI,nValDupl})	
							EndIf
						EndIf
					dbSelectArea(cAliasSE1)
					dbSkip()
			    EndDo
			    If lQuery
			    	dbSelectArea(cAliasSE1)
			    	dbCloseArea()
			    	dbSelectArea("SE1")
			    EndIf
			Else
				aDupl := {}
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analisa os impostos de retencao                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Tratamento para notas sobre cupom(Incluir demais estados conforme conforme legislacao).
			//A Nota Fiscal  deve ser toda preenchida, sendo a sua escrituração feita com valores zerados, já que o débito será feito pelo cupom
			//Assim, no livro Registro de Saídas deve ser registrado para esta nota apenas a coluna "Observações", onde serão indicados o seu número e a sua série.
			//Fundamento: artigo 135, § 2º, do RICMS/2000.		  	
		  	If lNfCup .And. SM0->M0_ESTCOB $ "SP" 
				lNfCupZero:=.T.
				aAreaSF2  	:= SF2->(GetArea())
				DbSelectArea( "SF2" )
				DbSetOrder(1)  // F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
				DbSeek( xFilial("SF2") + cNumNfCup + cSerNfCup)
			EndIf

			If SF2->(FieldPos("F2_VALPIS"))<>0 .and. SF2->F2_VALPIS>0
				aadd(aRetido,{"PIS",0,SF2->F2_VALPIS})
			EndIf
			If SF2->(FieldPos("F2_VALCOFI"))<>0 .and. SF2->F2_VALCOFI>0
				aadd(aRetido,{"COFINS",0,SF2->F2_VALCOFI})
			EndIf
			If SF2->(FieldPos("F2_VALCSLL"))<>0 .and. SF2->F2_VALCSLL>0
				aadd(aRetido,{"CSLL",0,SF2->F2_VALCSLL})
			EndIf
			If SF2->(FieldPos("F2_VALIRRF"))<>0 .and. SF2->F2_VALIRRF>0
				aadd(aRetido,{"IRRF",SF2->F2_BASEIRR,SF2->F2_VALIRRF})
			EndIf	
			If SF2->(FieldPos("F2_BASEINS"))<>0 .and. SF2->F2_BASEINS>0
				aadd(aRetido,{"INSS",SF2->F2_BASEINS,SF2->F2_VALINSS})
			EndIf  
				
			// Total Carga Tributária 
			If SF2->(FieldPos("F2_TOTIMP"))<>0 .and. SF2->F2_TOTIMP>0
				nTotalCrg := SF2->F2_TOTIMP
			EndIf

			//----------------------------------------------
			// Total Carga Tributária por Ente Tributante
			//----------------------------------------------
			
			// Ente Federal
			If SF2->(FieldPos("F2_TOTFED"))<>0 .and. SF2->F2_TOTFED>0
				nTotFedCrg := SF2->F2_TOTFED
			EndIf

			// Ente Estadual
			If SF2->(FieldPos("F2_TOTEST"))<>0 .and. SF2->F2_TOTEST>0
				nTotEstCrg := SF2->F2_TOTEST
			EndIf
			
			// Ente Municipal
			If SF2->(FieldPos("F2_TOTMUN"))<>0 .and. SF2->F2_TOTMUN>0
				nTotMunCrg := SF2->F2_TOTMUN
			EndIf						
			
			//RECOPI
			If SF2->(FieldPos("F2_IDRECOP")) > 0 .and. !Empty(SF2->F2_IDRECOP)
				cIdRecopi := SF2->F2_IDRECOP
			EndIf
			
			If !Empty(cIdRecopi)
				If AliasIndic("CE3")
					CE3->(DbSetOrder(1))
					If CE3->(DbSeek(xFilial("CE3")+Alltrim(cIdRecopi)))
						cNumRecopi:= IIf(CE3->(FieldPos("CE3_RECOPI")) > 0, Alltrim(CE3->CE3_RECOPI), "")
					EndIf
				EndIf
			EndIf
			
			
			//////INCLUSAO DE CAMPOS NA QUERY////////////
			
			cField := "%"
			
			If SD2->(FieldPos("D2_DESCZFC"))<>0 .AND. SD2->(FieldPos("D2_DESCZFP"))<>0
				cField += ",D2_DESCZFC,D2_DESCZFP" 						
			EndIf     
			
			if SD2->(FieldPos("D2_NFCUP"))<>0
			   cField  +=",D2_NFCUP"
			EndIF   
			
			if SD2->(FieldPos("D2_DESCICM"))<>0
			   cField  +=",D2_DESCICM"						    
			EndIF
						
			if SD2->(FieldPos("D2_FCICOD"))<>0
			   cField  +=",D2_FCICOD"						    
			EndIF
			
			if SD2->(FieldPos("D2_VLIMPOR"))<>0
			   cField  +=",D2_VLIMPOR"				    
			EndIF
			
			If SD2->(FieldPos("D2_TOTIMP"))<>0
			   cField  +=",D2_TOTIMP"				    
			EndIf			 

			If SD2->(FieldPos("D2_TOTFED"))<>0	// Ente Tributante Federal
			   cField  +=",D2_TOTFED"				    
			EndIf

			If SD2->(FieldPos("D2_TOTEST"))<>0	// Ente Tributante Estadual
			   cField  +=",D2_TOTEST"				    
			EndIf

			If SD2->(FieldPos("D2_TOTMUN"))<>0	// Ente Tributante Municipal
			   cField  +=",D2_TOTMUN"				    
			EndIf
			
			cField += "%"
			
			//////////////////////////////////////////////
									
			If lNfCupZero
				RestArea(aAreaSF2)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa itens de nota                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD2")
			dbSetOrder(3)
			#IFDEF TOP
				lQuery  := .T.
				cAliasSD2 := GetNextAlias()
				BeginSql Alias cAliasSD2
						SELECT D2_FILIAL,D2_SERIE,D2_DOC,D2_CLIENTE,D2_LOJA,D2_COD,D2_TES,D2_NFORI,D2_SERIORI,D2_ITEMORI,D2_TIPO,D2_ITEM,D2_CF,
						D2_QUANT,D2_TOTAL,D2_DESCON,D2_VALFRE,D2_SEGURO,D2_PEDIDO,D2_ITEMPV,D2_DESPESA,D2_VALBRUT,D2_VALISS,D2_PRUNIT,
						D2_CLASFIS,D2_PRCVEN,D2_IDENTB6,D2_CODISS,D2_DESCZFR,D2_PREEMB,D2_DESCZFC,D2_DESCZFP,D2_LOTECTL,D2_NUMLOTE,D2_ICMSRET,D2_VALPS3,
						D2_ORIGLAN,D2_VALCF3,D2_VALIPI,D2_VALACRS,D2_PICM,D2_PDV %Exp:cField% 
						FROM %Table:SD2% SD2
						WHERE
						SD2.D2_FILIAL  = %xFilial:SD2% AND
						SD2.D2_SERIE   = %Exp:SF2->F2_SERIE% AND
						SD2.D2_DOC     = %Exp:SF2->F2_DOC% AND
						SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND
						SD2.D2_LOJA    = %Exp:SF2->F2_LOJA% AND
						SD2.%NotDel%
						ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM,D2_COD
				EndSql

			#ELSE
				MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			#ENDIF
			
			lLjDescIt	:= .F.	// Inicializa as variaveis que serao utilizadas para desconto 
			lFirstItem 	:= .T.
			nCount		:= 0
			While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
				SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
				SF2->F2_DOC == (cAliasSD2)->D2_DOC
				
				lContinua 	:= .T.
				nCount++
				//Se for nota sobre cupom, pega somente os itens do cupom que estão na nota sobre cupom.				
				If SD2->(FieldPos("D2_NFCUP")) <> 0 .And. !Empty( (cAliasSD2)->D2_NFCUP )
					If lNfCup .And. !( cSerNfCup + cNumNfCup  == SubStr((cAliasSD2)->D2_SERIORI,1,TamSx3("F2_SERIE")[1]) + SubStr((cAliasSD2)->D2_NFCUP,1,TamSx3("F2_DOC")[1]) )									
						lContinua := .F.																		
					endIf
				Endif
				
				/* Tratamento para com base na legislação do Estado do Paraná Decreto n 6.080/2012 - DOE PR Suplemento  
					de 28.09.2012. Conforme chamado THPNSB */
				if !lIcmDevol .and. (cAliasSD2)->D2_TIPO == "D"
					lIcmDevol := .F.
				else
					lIcmDevol := .T.
				endif
				
				If lGE
					aSb1 := GetArea("SB1")
					DbSelectArea("SB1")
					DbSetOrder(1) // B1_FILIAL+B1_COD
					If DbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)
						If SB1->B1_TIPO == cTpGar 	
							lContinua := .F.																		
						EndIf				
					EndIf
					RestArea(aSb1)
				EndIf	
				
				If lContinua
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica a natureza da operacao                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lNfCup
						aAreaSD2  	:= SD2->(GetArea())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa itens de nota                                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
						If Val((cAliasSD2)->D2_ITEMORI)== 0
						   cNumitem := (cAliasSD2)->D2_ITEM
						Else 
						   cNumitem := (cAliasSD2)->D2_ITEMORI
						End
						
						DbSelectArea("SD2")
						DbSetOrder(3)
						If DbSeek(xFilial("SD2")+cNumNfCup+cSerNfCup+cCliNota+cCliLoja+(cAliasSD2)->D2_COD+cNumitem)
							cD2Cfop := SD2->D2_CF
							cD2Tes	:= SD2->D2_TES
						EndIf
						RestArea(aAreaSD2)
						// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
						//³       Informacoes do cupom fiscal referenciado              |
				    	//|                                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
						
						aadd(aRefECF,{SD2->D2_DOC,SF2->F2_ESPECIE,SF2->F2_PDV})
						
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Quando nao for cupom fiscal,							³
						//³	o CFOP deve ser atualizado com o CFOP de cada ITEM, |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
						cD2Cfop := (cAliasSD2)->D2_CF
						cD2Tes	:= (cAliasSD2)->D2_TES
					EndIf
					
					cChaveD2 := "S" + ( cAliasSD2 )->( D2_SERIE + D2_DOC + D2_CLIENTE + D2_LOJA + D2_ITEM )
					
					dbSelectArea("SF4")
					dbSetOrder(1)
					MsSeek(xFilial("SF4")+cD2Tes)
					
					
					SFT->( dbSetOrder( 1 ) )
					//utiliza a funcao SpedNatOper ( SPEDXFUN ) que possui o tratamento para a natureza da operacao/prestacao
					if FindFunction( "SpedNatOper" ) .And. SFT->( MsSeek( xFilial( "SFT" ) + cChaveD2 ) )
						If !Alltrim(SpedNatOper( nil , lNatOper , "SFT" , "SF4" , .T. )[ 2 ])$cNatOper
					  		If	Empty(cNatOper)
					     		cNatOper := SpedNatOper( nil , lNatOper , "SFT" , "SF4" , .T. )[ 2 ]
					  		Else
					      		cNatOper := cNatOper + "/ " +SpedNatOper( nil , lNatOper , "SFT" , "SF4" , .T. )[ 2 ]
					  		Endif
					   Endif	 
					else
						If !lNatOper
							If Empty(cNatOper)
								cNatOper := Alltrim(SF4->F4_TEXTO)
							Else
								cNatOper += Iif(!Alltrim(SF4->F4_TEXTO)$cNatOper,"/ " + SF4->F4_TEXTO,"")
							Endif 
						Else	
							dbSelectArea("SX5")
							dbSetOrder(1)
							dbSeek(xFilial("SX5")+"13"+SF4->F4_CF)
							If Empty(cNatOper)
								cNatOper := AllTrim(SubStr(SX5->X5_DESCRI,1,55))
							Else
								cNatOper += Iif(!AllTrim(SubStr(SX5->X5_DESCRI,1,55)) $ cNatOper, "/ " + AllTrim(SubStr(SX5->X5_DESCRI,1,55)), "")
			    			EndIf
			    		EndIf
			    	endif
		    		
		    		If SF4->(FieldPos("F4_BASEICM"))>0
		    			nRedBC := IiF(SF4->F4_BASEICM>0,IiF(SF4->F4_BASEICM == 100,SF4->F4_BASEICM,IiF(SF4->F4_BASEICM > 100,0,100-SF4->F4_BASEICM)),SF4->F4_BASEICM)
		    			cCST   := SF4->F4_SITTRIB 
		    		Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica as notas vinculadas                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty((cAliasSD2)->D2_NFORI)
						If (cAliasSD2)->D2_TIPO $ "DBN"
							dbSelectArea("SD1")
							dbSetOrder(1)
							If ( MsSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI) ) .OR. ;
								( MsSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI) .And. Empty(cMVREFNFE) ) 
								dbSelectArea("SF1")
								dbSetOrder(1)
								MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
								If SD1->D1_TIPO $ "DB"
									dbSelectArea("SA1")
									dbSetOrder(1)
									MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
								Else
									dbSelectArea("SA2")
									dbSetOrder(1)
									MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Obtem os dados de nota fiscal de produtor rural referenciada                                  ³
								//³Temos duas situacoes:                                                                         ³
								//³A NF de saída é uma devolucao, onde a NF original pode ser ou nao uma devolução.              ³
								//³1) Quando a NF original for uma devolucao, devemos utilizar o remetente do documento fiscal,  ³
								//³    podendo ser o sigamat.emp no caso de formulario proprio ou o proprio SA1 no caso de nf de ³
								//³    entrada com formulario proprio igual a NAO.                                               ³
								//³2) Quando a NF original NAO for uma devolucao, neste caso tambem pode variar conforme o       ³
								//³    formulario proprio igual a SIM ou NAO. No caso do NAO, os dados a serem obtidos retornara ³
								//³    da tabela SA2.                                                                            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If AllTrim(SF1->F1_ESPECIE)=="NFP"
									//para nota de entrada tipo devolucao o emitente eh o cliente ou o sigamat no caso de formulario proprio=sim
									If SD1->D1_TIPO$"DB"
										aadd(aNfVincRur,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,SF1->F1_ESPECIE,;
											IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA1->A1_CGC),; 
											IIF(SD1->D1_FORMUL=="S",SM0->M0_ESTENT,SA1->A1_EST),; 
											IIF(SD1->D1_FORMUL=="S",SM0->M0_INSC,SA1->A1_INSCR)})
									
									//para nota de entrada normal o emitente eh o fornecedor ou o sigamat no caso de formulario proprio=sim
									Else
										aadd(aNfVincRur,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,SF1->F1_ESPECIE,;
											IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA2->A2_CGC),; 
											IIF(SD1->D1_FORMUL=="S",SM0->M0_ESTENT,SA2->A2_EST),; 
											IIF(SD1->D1_FORMUL=="S",SM0->M0_INSC,SA2->A2_INSCR)})
									EndIf
								Endif
								// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
								//³       Informacoes do cupom fiscal referenciado              |
						    	//|                                                             ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
								If AllTrim(SF1->F1_ESPECIE)=="CF"
									aadd(aRefECF,{SD1->D1_DOC,SF1->F1_ESPECIE,""})
								Endif  
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Outros documentos referenciados³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								if AllTrim(SF1->F1_ESPECIE)<>"NFP"
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Documento de Estorno - Tipo Devolucao e F4_AJUSTE="S"    ³
									//³identifica que se trata de nf de estorno.                ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If ( ( cAliasSD2 )->D2_COD == SD1->D1_COD .AND. SF4->F4_AJUSTE == "S" )	
																		
										aAdd( aNfVinc, { SD1->D1_EMISSAO, SD1->D1_SERIE, SD1->D1_DOC, iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ), SM0->M0_ESTCOB, SF1->F1_ESPECIE, SF1->F1_CHVNFE,SD1->D1_TOTAL-SD1->D1_DESC} )
										cChave	:= dToS( SD1->D1_EMISSAO ) + SD1->D1_SERIE + SD1->D1_DOC + iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ) + SM0->M0_ESTCOB + SF1->F1_ESPECIE + SF1->F1_CHVNFE
												
									Elseif cChave <> dToS( SD1->D1_EMISSAO ) + SD1->D1_SERIE + SD1->D1_DOC + iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ) + SM0->M0_ESTCOB + SF1->F1_ESPECIE + SF1->F1_CHVNFE;
										.or. ( cAliasSD2 )->D2_ITEM <> cItemOr

										aAdd( aNfVinc, { SD1->D1_EMISSAO, SD1->D1_SERIE, SD1->D1_DOC, iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ), SM0->M0_ESTCOB, SF1->F1_ESPECIE, SF1->F1_CHVNFE,SD1->D1_TOTAL-SD1->D1_DESC} )
										cChave	:= dToS( SD1->D1_EMISSAO ) + SD1->D1_SERIE + SD1->D1_DOC + iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ) + SM0->M0_ESTCOB + SF1->F1_ESPECIE + SF1->F1_CHVNFE
									
									endIf	
									cItemOr	:= ( cAliasSD2 )->D2_ITEM
								endIf	
							ElseIf (cAliasSD2)->D2_TIPO == "N"                                                     						
								dbSelectArea("SFT")
						   		dbSetOrder(6)
						   		If MsSeek(xFilial("SFT")+"S"+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI)
						   			If !Empty(SFT->FT_DTCANC)
							   			dbSelectArea("SF3")
								   		dbSetOrder(4) 
								   		MsSeek(xFilial("SF3")+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_NFISCAL+SFT->FT_SERIE)
								   		If Empty(SF3->F3_CODRSEF) .Or. SF3->F3_CODRSEF == "101"
							   				if cChave <> dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA1->A1_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE;
							   					.or. (cAliasSD2)->D2_ITEM <> cItemOr
							   					
												aAdd( aNfVinc, { SF3->F3_EMISSAO, SF3->F3_SERIE, SF3->F3_NFISCAL, SA1->A1_CGC, SM0->M0_ESTCOB, SF3->F3_ESPECIE, SF3->F3_CHVNFE } )
												cChave	:= dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA1->A1_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE
												
											endIf 
											cItemOr	:= ( cAliasSD2 )->D2_ITEM
										endIf
									ElseIf SFT->FT_ESTADO == "EX" .or. ((SubStr(SM0->M0_CODMUN,1,2) == "35" .Or. SubStr(SM0->M0_CODMUN,1,2) == "29") .and. "REMESSA POR CONTA E ORDEM DE TERCEIROS" $ Upper(cNatOper) .and. lOrgaoPub )//(Venda para orgao publico - SP/BA/CFOP Remessa por conta e ordem de terceiros (cfop 5923/6923)- ch:TIDWCY   
										//Se venda para orgao publico, vincula NFe do tipo Normal de faturamento
										dbSelectArea("SF3")
								   		dbSetOrder(4) 
								   		MsSeek(xFilial("SF3")+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_NFISCAL+SFT->FT_SERIE) 
										if cChave <> dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA1->A1_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE;
											.or. ( cAliasSD2 )->D2_ITEM <> cItemOr
											
											aAdd( aNfVinc, { SF3->F3_EMISSAO, SF3->F3_SERIE, SF3->F3_NFISCAL, SA1->A1_CGC, SM0->M0_ESTCOB, SF3->F3_ESPECIE, SF3->F3_CHVNFE } )
											cChave	:= dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA1->A1_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE											

										endIf
										cItemOr	:= ( cAliasSD2 )->D2_ITEM										
									ElseIf Alltrim(SFT->FT_CFOP) $ cMVREFNFE
										//Tratamento para que leve na TAG <refNFe> as notas referenciadas que contém o CFOP no parâmetro MV_REFNFE
										dbSelectArea("SF3")
								   		dbSetOrder(4) 
								   		If (MsSeek(xFilial("SF3")+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_NFISCAL+SFT->FT_SERIE))
									   		If cChave <> dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA1->A1_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE;
												.or. ( cAliasSD2 )->D2_ITEM <> cItemOr
											
												aAdd( aNfVinc, { SF3->F3_EMISSAO, SF3->F3_SERIE, SF3->F3_NFISCAL, SA1->A1_CGC, SM0->M0_ESTCOB, SF3->F3_ESPECIE, SF3->F3_CHVNFE } )
												cChave	:= dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA1->A1_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE											

											endIf
											cItemOr	:= ( cAliasSD2 )->D2_ITEM
									   	Endif			
									EndIf
								EndIf																
							EndIf
						Else
							aOldReg  := SD2->(GetArea())
							aOldReg2 := SF2->(GetArea())
							dbSelectArea("SD2")
							dbSetOrder(3)
	//						Alterado a chave de busca completa devido ao procedimento de complemento de notas de devolucao de compras. FNC -> 00000008125/2011.						
	//						If MsSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
							If MsSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI)//+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
								dbSelectArea("SF2")
								dbSetOrder(1)
								MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
								If !SD2->D2_TIPO $ "DB"
									dbSelectArea("SA1")
									dbSetOrder(1)
									MsSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
								Else
									dbSelectArea("SA2")
									dbSetOrder(1)
									MsSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
									lComplDev := .T.
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Obtem os dados de nota fiscal de produtor rural referenciada                                  ³
								//³A NF de saída NAO EH uma devolucao, portanto eh uma nota de saida complementar. Para este tipo³
								//³ de nota, o emitente eh sempre o sigamat.emp                                                  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If AllTrim(SF2->F2_ESPECIE)=="NFP"
									//para nota de saida normal o emitente eh o sigamat
									aadd(aNfVincRur,{SD2->D2_EMISSAO,SD2->D2_SERIE,SD2->D2_DOC,SF2->F2_ESPECIE,;
										SM0->M0_CGC,SM0->M0_ESTENT,SM0->M0_INSC})
								Endif							
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Outros documentos referenciados³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If cChave <> Dtos(SF2->F2_EMISSAO)+SD2->D2_SERIE+SD2->D2_DOC+SM0->M0_CGC+SM0->M0_ESTCOB+SF2->F2_ESPECIE+SF2->F2_CHVNFE							
									aadd(aNfVinc,{SF2->F2_EMISSAO,SD2->D2_SERIE,SD2->D2_DOC,SM0->M0_CGC,SM0->M0_ESTCOB,SF2->F2_ESPECIE,SF2->F2_CHVNFE})                         
									cChave := Dtos(SF2->F2_EMISSAO)+SD2->D2_SERIE+SD2->D2_DOC+SM0->M0_CGC+SM0->M0_ESTCOB+SF2->F2_ESPECIE+SF2->F2_CHVNFE							
								EndIf
							EndIf
							RestArea(aOldReg)
							RestArea(aOldReg2)
						EndIf
					EndIf
								
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem os dados do produto                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					dbSelectArea("SB1")
					dbSetOrder(1)
					MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)
					
	   				dbSelectArea("SB5")
					dbSetOrder(1)
					If MsSeek(xFilial("SB5")+(cAliasSD2)->D2_COD)
						If SB5->(FieldPos("B5_DESCNFE")) > 0 .And. !Empty(SB5->B5_DESCNFE)
							cInfAdic	:= Alltrim(SB5->B5_DESCNFE)
						Else	
							cInfAdic	:= ""				
						EndIF
					Else
						cInfAdic	:= ""		
					EndIF
					
					If DY3->(FieldPos("DY3_INFCPL"))>0	 					
						dbSelectArea("DY3")
			   			dbSetOrder(1)
			   			If MsSeek(xFilial("DY3")+ (cAliasSB5)->B5_ONU)
							If DY3->(FieldPos("DY3_DESCRI")) > 0 .And. !Empty(DY3->DY3_DESCRI) .and. DY3->DY3_INFCPL =="S"
						   		If !cMensONU $ DY3->DY3_ONU
				     	   			cMensONU	:= cMensONU +'  ONU '+Alltrim(DY3->DY3_ONU)+' '+Alltrim(DY3->DY3_DESCRI)+'   '   
				    			EndIF
			   				EndIF  		
					   EndIF 
					 EndIF 
					//------------------------------------------------------------------------
					//Obtem dados adicionais ou do produto, ou do item do pedido de venda
					//------------------------------------------------------------------------
					If lC6_CODINF .And. cInfAdPr <> "2" .And. !Empty(cInfAdPr)
						SC6->(dbSetOrder(2))
						If SC6->(MsSeek(xFilial("SD2")+(cAliasSD2)->(D2_COD+D2_PEDIDO+D2_ITEMPV))) 
							cInfAdPed := Alltrim(MSMM(SC6->C6_CODINF,80))
							If !Empty(cInfAdPed)
								//--Obtem informacoes do item do pedido de venda
				          	If cInfAdPr == "1"     
				           		cInfAdic := cInfAdPed
				           	//--Obtem informacoes do item do pedido de venda e do produto
				           	ElseIf cInfAdPr == "3" 
				           	   cInfAdPed := SubStr(AllTrim(cInfAdPed),1,250)
				           	   cInfAdic  := SubStr(AllTrim(cInfAdic),1,249)
				           	   cInfAdic  += " " + cInfAdPed
				           	EndIf 
				      	EndIf
						EndIf                                                  	
					EndIf
					
					//Veiculos Novos
					If AliasIndic("CD9")			
						dbSelectArea("CD9")
						dbSetOrder(1)
						MsSeek(xFilial("CD9") + cChaveD2 )
					EndIf
					//Combustivel
					If AliasIndic("CD6")
						dbSelectArea("CD6")
						dbSetOrder(1)
						MsSeek(xFilial("CD6")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+Padr((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD)
					EndIf
					//Medicamentos
					If AliasIndic("CD7")			
						dbSelectArea("CD7")
						dbSetOrder(1)
						MsSeek(xFilial("CD7") + cChaveD2 )
					EndIf
					// Armas de Fogo
					If AliasIndic("CD8")						
						dbSelectArea("CD8")
						dbSetOrder(1) 
						MsSeek(xFilial("CD8") + cChaveD2 )
					EndIf
							
					//Anfavea
					If lAnfavea
						dbSelectArea("CDR")
						dbSetOrder(1) 
						DbSeek(xFilial("CDR")+"S"+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)

						dbSelectArea("CDS")
						dbSetOrder(1) 
						cItem := PADR((cAliasSD2)->D2_ITEM,TAMSX3("CDS_ITEM")[1])
						DbSeek(xFilial("CDS")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+cItem+(cAliasSD2)->D2_COD)
					EndIf   		                    					
					//Desconto Zona Franca PIS e COFINS 
					If	SD2->(FieldPos("D2_DESCZFC"))<>0 .AND. SD2->(FieldPos("D2_DESCZFP"))<>0
						If (cAliasSD2)->D2_DESCZFC > 0	
							nValCofZF += (cAliasSD2)->D2_DESCZFC
						EndIf
						If (cAliasSD2)->D2_DESCZFP > 0	
							nValPisZF += (cAliasSD2)->D2_DESCZFP
						EndIf
					EndIf 
								
					dbSelectArea("SC5")
					dbSetOrder(1)
					MsSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO)
					
					dbSelectArea("SC6")
					dbSetOrder(1)
					MsSeek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD)
					
					cTpCliente:= Alltrim(SF2->F2_TIPOCLI)
					//Para nota sobre cupom deve ser 
					//impresso os valores da lei da transparência.					
					if lNfCup
						cTpCliente := "F"
					EndIf
					
					If !AllTrim(SC5->C5_MENNOTA) $ cMensCli
						If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
							cMensCli += " "
						EndIf
						
						//-- Tratamento para a integração entre WMS Logix X ERP Protheus 
						If SC5->( FieldPos("C5_ORIGEM") ) > 0 .And. 'LOGIX' $ Upper(SC5->C5_ORIGEM) 
							LgxMsgNfs()
						EndIf     
						
						cFieldMsg := GetNewPar("MV_CMPUSR","")  //Alterado por Alex Rodrigues - 19/05/2014                         
						If !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
							cMensCli := alltrim(&("SC5->"+cFieldMsg))
						Else
							//cMensCli += AllTrim(SC5->C5_MENNOTA)

							//** BRENO **//
							cMensCli += AllTrim(AllTrim(SC5->C5_MENNOTA)+" "+AllTrim(SC5->C5_MENNOT2)+" "+AllTrim(SC5->C5_MENNOT3))
							//**********//
						EndIf

						//** BRENO **//
						cMensCli += Chr(13)+Chr(10)+cProjetos
						//**********//
					EndIf
					If !Empty(SC5->C5_MENPAD) .And. !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis
						If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
							cMensFis += " "
						EndIf
						cMensFis += AllTrim(FORMULA(SC5->C5_MENPAD))
					EndIf
					If !Empty( cNumNfCup )
						//Tratamento para nota sobre Cupom 
						aAreaSF2  	:= SF2->(GetArea())
						DbSelectArea("SFT")
					    DbSetOrder(1)
					    If SFT->(DbSeek((xFilial("SD2")+"S"+ cSerNfCup + cNumNfCup )))
							IF  AllTrim(SFT->FT_OBSERV) <> " " .AND.(cAliasSD2)->D2_ORIGLAN=="LO"
								IF !Alltrim(SFT->FT_OBSERV) $ Alltrim(cMensCli) 
									if upper( "F - simples faturamento" ) $  upper( Alltrim(SFT->FT_OBSERV) )
										cMensCli +=" CF/SERIE: " + AllTrim((cAliasSD2)->D2_DOC) + " " + Alltrim((cAliasSD2)->D2_SERIE) +" ECF:" + Alltrim((cAliasSD2)->D2_PDV)
									else
										If "DEVOLUCAO N.F." $ Upper(SFT->FT_OBSERV) 
											cMensCli +=" " + StrTran(AllTrim(SFT->FT_OBSERV),"N.F.","C.F.")
										Else
											cMensCli +=" " + AllTrim(SFT->FT_OBSERV)
										EndIf
									endif		
								EndIf       
			           		EndIf
			        	EndIF
						RestArea(aAreaSF2)	        	
					EndIf	
					if !lIcmDevol
						if Len( cMensCli ) > 0
							cMensCli += ' '
						endif
						if SM0->M0_ESTENT == "PR"
							cMensCli += " Nota fiscal emitida sem destaque do ICMS conforme artigo 9. do Anexo X do RICMS-PR/2012."
						else
							cMensCli += " Nota fiscal emitida sem destaque do ICMS."
						endif
					endif 				
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Obtem os dados do veiculo informado no pedido de venda                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
					If Empty(aVeiculo)
						DbSelectArea("DA3")
						DbSetOrder(1)
						If DbSeek(xFilial("DA3")+Iif(SC5->(FieldPos("C5_VEICULO")) > 0 ,SC5->C5_VEICULO,""))
							aadd(aVeiculo,DA3->DA3_PLACA)
							aadd(aVeiculo,DA3->DA3_ESTPLA)
							aadd(aVeiculo,Iif(DA3->(FieldPos("DA3_RNTC")) > 0 ,DA3->DA3_RNTC,iif(!Empty(cAnttRntrc),cAnttRntrc,"")))//RNTC				
						EndIf
					EndIf				
					//Tratamento para o campo F4_FORMULA,onde atraves do parametro MV_NFEMSF4 se determina se o conteudo da formula devera compor a mensagem do cliente(="C") ou do fisco(="F").
					If !Empty(SF4->F4_FORMULA) .And. Formula(SF4->F4_FORMULA) <> NIL .And. ( ( cMVNFEMSF4=="C" .And. !AllTrim(Formula(SF4->F4_FORMULA)) $ cMensCli ) .Or. (cMVNFEMSF4=="F" .And. !AllTrim(Formula(SF4->F4_FORMULA))$cMensFis) )

						If cMVNFEMSF4=="C"
							If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
								cMensCli += " "
							EndIf
							cMensCli	+=	SF4->(Formula(F4_FORMULA))
						ElseIf cMVNFEMSF4=="F"
							If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
								cMensFis += " "
							EndIf
							cMensFis	+=	SF4->(Formula(F4_FORMULA))
						EndIf
					EndIf
				
					If lSb1CT
						If lMvImpFecp  .And. SB1->B1_X_CT$cMVAEHC
							If (lValFecp .Or. lVfecpst) 
								DbSelectArea("SFT")
							    DbSetOrder(1)
								If SFT->(DbSeek((xFilial("SFT") + cChaveD2 )))								
									If SFT->FT_VFECPST > 0
							   			cMensFis += " Cod.Prod: " + Alltrim((cAliasSD2)->D2_COD) + IIF(SB1->B1_X_CT$cMVAEHC," AEHC ","") + " BC R$: " + Alltrim(Transform(SFT->FT_BASERET,"@E 999,999,999.99"))  + " o adicional de " + Alltrim(Str(SFT->FT_ALQFECP, 14, 2))+"%" + " valor FECP R$ " + Alltrim(Transform(SFT->FT_VFECPST,"@E 999,999,999.99")) 
								    Endif
								Endif
							Endif
						Endif 
					Endif
					//Verifica se existe Template DCL
      				IF (ExistTemplate("PROCMSG"))
      					aMens := ExecTemplate("PROCMSG",.f.,.f.,{cAliasSD2})      										 		      					
							For nA:=1 to len(aMens)
							    If aMens[nA][1] == "V" .Or. (aMens[nA][1] == "T" .And. Ascan(aMensAux,aMens[nA][2])==0)
									AADD(aMensAux,aMens[nA][2])
								Endif	
							Next    					
     				Endif 
     				
			 		If SF2->F2_TPFRETE=="C"
						cModFrete := "0"
					ElseIf SF2->F2_TPFRETE=="F"
					 	cModFrete := "1"
					ElseIf SF2->F2_TPFRETE=="T"
					 	cModFrete := "2"
					ElseIf SF2->F2_TPFRETE=="S"
					 	cModFrete := "9"
				 	ElseIf Empty(cModFrete)
				 		If SC5->C5_TPFRETE=="C"
							cModFrete := "0"
						ElseIf SC5->C5_TPFRETE=="F"
						 	cModFrete := "1"
						ElseIf SC5->C5_TPFRETE=="T"
						 	cModFrete := "2"
						ElseIf SC5->C5_TPFRETE=="S"
						 	cModFrete := "9" 
					 	Else
					 		cModFrete := "1" 			 	 	
						EndIf   			 
					EndIf               
					
					If Empty(aPedido)
						aPedido := {Iif(SC5->(FieldPos("C5_NTEMPEN")) > 0,Alltrim(SC5->C5_NTEMPEN),""),AllTrim(SC6->C6_PEDCLI),""}
					EndIf
					
					//Indicador de presença do comprador no estabelecimento comercial no momento da operação - VERSÃO 3.10
					If SC5->(FieldPos("C5_INDPRES")) > 0
						 If lNfCup .Or. (cAliasSD2)->D2_ORIGLAN $ "VD|LO"
						 	cIndPres := "1" //1=Operação presencial
						 Else
						 	cIndPres:= Alltrim(SC5->C5_INDPRES)
						 EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se municipio de prestação foi informado no pedido ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
					If SC5->(FieldPos("C5_MUNPRES")) > 0 .And. !Empty(SC5->C5_MUNPRES)
						if len(AllTrim(SC5->C5_MUNPRES)) == 7 
							cMunPres  := SC5->C5_MUNPRES
						elseif SC5->(FieldPos("C5_ESTPRES")) > 0 .and. !Empty(SC5->C5_ESTPRES)															
							cMunPres  := ConvType(aUF[aScan(aUF,{|x| x[1] == SC5->C5_ESTPRES})][02]+SC5->C5_MUNPRES)
						endif
					Else
						cMunPres := ConvType(aUF[aScan(aUF,{|x| x[1] == aDest[09]})][02]+aDest[07])
					EndIf
					// Tags xPed e nItemPed (controle de B2B) para nota de saída
					If SC6->(FieldPos("C6_NUMPCOM")) > 0 .And. SC6->(FieldPos("C6_ITEMPC")) > 0
						If !Empty(SC6->C6_NUMPCOM) .And. !Empty(SC6->C6_ITEMPC) 
							aadd(aPedCom,{SC6->C6_NUMPCOM,SC6->C6_ITEMPC})
						Else
							aadd(aPedCom,{})
						EndIf
					Else
						aadd(aPedCom,{})
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Conforme Decreto RICM, N 43.080/2002 valido somente em MG deduzir o 	³ 
					//³	imposto dispensado na operação				  			                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDescRed := 0
					dbSelectArea("SFT")
					dbSetOrder(1)
					//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
					MsSeek(xFilial("SFT") + cChaveD2 + "  " + (cAliasSD2)->D2_COD) 
					If SFT->(FieldPos("FT_DS43080")) <> 0 .And. SFT->FT_DS43080 > 0 .And. IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT)) == "MG"
						nDescRed := SFT->FT_DS43080 
						nDesTotal+= nDescRed
					EndIF	  				
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Incluido o tratamento pelo fato do SIGALOJA e o VENDA DIRETA nao gravar ³ 
					//³	o campo D2_DESCON, quando e' dado desconto no total da venda.           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lNfCup .Or. (cAliasSD2)->D2_ORIGLAN == "VD"
						
						nDesconto := 0
						// Caso possua desconto vai fazer essa logica abaixo para se adequar a mesma logica do faturamento , 
						// Pq ao contrario do faturamento o LOJA nao grava o D2_DESCON quando o desconto eh no total 
						If SF2->F2_DESCONT > 0
							If lFirstItem	// Somente faz o looping nos itens na primeira vez
								While !(cAliasSD2)->(Eof()) .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
																  SF2->F2_SERIE  == (cAliasSD2)->D2_SERIE  .And.;
																  SF2->F2_DOC    == (cAliasSD2)->D2_DOC
													
									nTDescIt += (cAliasSD2)->D2_DESCON 	// Soma de todos os descontos nos itens
									(cAliasSD2)->(DbSkip())
								End
								lFirstItem := .F.
								(cAliasSD2)->(DbGoTop())
								nX := 1
								// Como nao temos RestArea para alias temp , da um gotop e depois certifica que esta no recno correto
								While nCount <> (cAliasSD2)->(Recno()) .AND. nX < 50 // Protecao para nao ficar loop infinito
									(cAliasSD2)->(DbSkip())
									nX++
								End 
								// Se o valor do desconto for igual significa que soemente teve desconto no item 
								// Nesse caso pode seguir a mesma regra do faturamente e pegar direto do D2_DESCON	
								If nTDescIt = SF2->F2_DESCONT
									lLjDescIt	:= .T.		
								Endif
							EndIf
							
							If lLjDescIt	// Se so teve desconto no item pega direto do D2_DESCON
								nDesconto := (cAliasSD2)->D2_DESCON
							Else			// Faz o rateio do desconto no total + o desconto no item
								nDesconto := ((((cAliasSD2)->D2_QUANT*(cAliasSD2)->D2_PRUNIT)/SF2->F2_VALMERC) * (SF2->F2_DESCONT- nTDescIt))+(cAliasSD2)->D2_DESCON 
							EndIf
						EndIf
		            Else 
						nDesconto := (cAliasSD2)->D2_DESCON            	
						
						If	SD2->(FieldPos("D2_DESCICM"))<>0
						    
							nDescIcm := ( IIF(SF4->F4_AGREG == "D",(cAliasSD2)->D2_DESCICM,0) )
							If cVerAmb >= "3.10" .and. SF4->F4_AGREG == "D" .and.  !Empty(SF4->F4_MOTICMS) .and. Empty(SF4->F4_CSOSN)
								nDescIcm:=0
							EndIF						
						EndIF
		            EndIf
		            
			        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tratamento para verificar se o produto e controlado por terceiros (IDENTB6)³
					//³  e a partir do tipo do pedido (Cliente ou Fornecedor) verifica  se existe  ³
					//³  amarracao entre Produto X Cliente(SA7) ou Produto X Fornecedor(SA5)       ³  
					//³Caso haja a amarraca, o codigo e descricao do produto, assumem o conteudo   ³
					//³	da SA7 ou SA5															   ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	
					cCodProd  := (cAliasSD2)->D2_COD	            
					//cDescProd := IIF(Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI) 
					 
					//** BRENO **//
					cDescProd := IIF(Empty(SC6->C6_DESCRI),SB1->B1_DESC,IIF(AllTrim((cAliasSD2)->D2_COD) == "PFA595",IIF(SB5->(DbSeek(xFilial("SB5")+AllTrim((cAliasSD2)->D2_COD),.F.)),AllTrim(SB5->(B5_CEME+B5_CEME1+B5_CEME2+B5_CEME3+B5_CEME4+B5_CEME5)),SC6->C6_DESCRI),SC6->C6_DESCRI))
					//**********//

					If !Empty((cAliasSD2)->D2_IDENTB6) 
			         	If SC5->C5_TIPO == "N" 
					         //--A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_PRODUTO
					         SA7->(dbSetOrder(1)) 	         
					         If SA7->(MsSeek( xFilial("SA7") + (cAliasSD2)->(D2_CLIENTE+D2_LOJA+D2_COD) )) .and. !empty(SA7->A7_CODCLI) .and. !empty(SA7->A7_DESCCLI) 
					         	cCodProd  := SA7->A7_CODCLI 
					            cDescProd := SA7->A7_DESCCLI	            						
					         EndIf 
						ElseIf SC5->C5_TIPO == "B"
					      	//--A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO
					         SA5->(dbSetOrder(1)) 	         
					         If SA5->(MsSeek( xFilial("SA5") + (cAliasSD2)->(D2_CLIENTE+D2_LOJA+D2_COD) )) .and. !empty(SA5->A5_CODPRF) .and. !empty(SA5->A5_DESREF)
					         	cCodProd  := SA5->A5_CODPRF 
					            cDescProd := SA5->A5_DESREF 	            
					         EndIf 	
				      	EndIf  
		         	EndIf 
		         
		            nDescZF := (cAliasSD2)->D2_DESCZFR 
		            
		            // Faz o destaque do IPI nos dados complementares caso seja uma venda por consignação mercantil e possuir IPI
					If (lConsig .Or. Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM) .And. (cAliasSD2)->D2_VALIPI > 0
						nIPIConsig += (cAliasSD2)->D2_VALIPI
					EndIf
						
					// Faz o destaque do ICMS ST nos dados complementares caso seja uma venda por consignação mercantil e possuir ICMS ST
					If Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM .And. (cAliasSD2)->D2_ICMSRET > 0   
						nSTConsig += (cAliasSD2)->D2_ICMSRET 
					EndIf  	
		            
		            //Tratamento para que o valor de ICMS ST venha a compor o valor da tag vOutros quando for uma nota de Devolução, impedindo que seja gerada a rejeição 610.
		            nIcmsST := 0
		            If (!lIcmSTDev .And. (cAliasSD2)->D2_TIPO == "D" .And. SubStr((cAliasSD2)->D2_CLASFIS,2,2) $ '10#30#70#90') .Or. (Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM) .Or. (!lIcmSTDev .And. lComplDev .And. (cAliasSD2)->D2_TIPO == "I" )
		            	nIcmsST := (cAliasSD2)->D2_ICMSRET
		            EndIf   
		            cOrigem:= IIF(!Empty((cAliasSD2)->D2_CLASFIS),SubStr((cAliasSD2)->D2_CLASFIS,1,1),'0')
		            cCSTrib:= IIF(!Empty((cAliasSD2)->D2_CLASFIS),SubStr((cAliasSD2)->D2_CLASFIS,2,2),'50')
		            
					//-----------------------------------------------------------------------------------------
					//			FCI - Ficha de Conteúdo de Importação
					//-----------------------------------------------------------------------------------------
					//**Operação INTERNA:
					//1) Emitente da NF (vendedor) NÃO realizou processo de industrialização com a mercadoria:
					// - Informar o valor da importação      (Revenda)
					//2) Emitente da NF (vendedor) REALIZOU processo de industrialização com a mercadoria:
					// - Informar o valor da importação      (Industrialização)
					//
					//**Operação INTERESTADUAL:
					//1) Emitente da NF (vendedor) NÃO realizou processo de industrialização com a mercadoria:
					// - Informar o valor da importação      (Revenda)
					//2) Emitente da NF (vendedor) REALIZOU processo de industrialização com a mercadoria:
					// - Informar o valor da parcela importada do exterior, o número da FCI e o Conteúdo de
					//   Importação expresso percentualmente (Industrialização)
					//----------------------------------------------------------------------------------------- 
					
					If (SF4->(FieldPos("F4_CONSUMO")) > 0 .And. SF4->F4_CONSUMO == "N") .And. (cOrigem $"1-2-3-4-5-6-8" .And. cCSTrib $ "00-10-20-40-60-70-90")    /*Inserido o código 060 conforme consulta do chamado TIDWAX */
						If (cAliasSD2)->(FieldPos("D2_FCICOD")) > 0 .And. !Empty((cAliasSD2)->D2_FCICOD)
							aadd(aFCI,{(cAliasSD2)->D2_FCICOD}) 
							
							If lFCI
								cMsgFci	:= "Resolucao do Senado Federal nº 13/12"
								cInfAdic  += cMsgFci + ", Numero da FCI " + Alltrim((cAliasSD2)->D2_FCICOD) + "."
							EndIf
							
						Else
							aadd(aFCI,{})
						EndIf
					Else 
						aadd(aFCI,{})
					EndIf
						    // Retirada a validação devido a criação da tag nFCI (NT 2013/006)
						    //--------------------------------------------------------------------------------
							//Campo SD2->D2_FCICOD só é preenchido nos casos de Industrialização Interestadual
							//Executar UPDSIGAFIS para criação do campo na D2 e tabela CFD.
							//Obs.: O campo D2_FCICOD é alimentado com o conteúdo do campo CFD_FCICOD após
							//faturar os Documentos de Saída (MATA461).
							//--------------------------------------------------------------------------------
							//If AliasIndic("CFD")
								//CFD->(DbSetOrder(3))   //Tabela de Ficha de Conteudo de Importação
								//If CFD->(DbSeek(xFilial("CFD")+(cAliasSD2)->D2_FCICOD))
									//-----------------------------------------------------------------------------------
									//Obs.: Retirado o valor da parcela importada devido ao Convênio 38/2013  CH: THHDRV
									//nValParImp	:= IIf(CFD->(FieldPos("CFD_VPARIM")) > 0,CFD->CFD_VPARIM, 0)         
									//-----------------------------------------------------------------------------------
									//nContImp	:= IIf(CFD->(FieldPos("CFD_CONIMP")) > 0,CFD->CFD_CONIMP, 0)
																	
									//cInfAdic  += cMsgFci + ", Valor da Parcela Importada R$ "+ ConvType(nValParImp, 11,2)+ ", Conteudo de Importacao " + ConvType(nContImp, 11,2) + "% , Numero da FCI " + Alltrim((cAliasSD2)->D2_FCICOD)
									//cInfAdic  += cMsgFci + ", Conteudo de Importacao " + ConvType(nContImp, 11,2) + "% , Numero da FCI " + Alltrim((cAliasSD2)->D2_FCICOD)
								//EndIf
							//EndIf
							//--------------------------------------------------------------------------------
							//Preencher o campo C6_VLIMPOR com o valor da Importação para popular o D2_VLIMPOR
							//Obs.: Somente preencher nos casos em que não utilize RASTRO, caso utilize será
							//      populado automaticamente.
							//--------------------------------------------------------------------------------	
							//ElseIf (cAliasSD2)->(FieldPos("D2_VLIMPOR")) > 0 .And. !Empty((cAliasSD2)->D2_VLIMPOR)
								//cInfAdic  += cMsgFci + ", Valor da Importacao R$ " + ConvType((cAliasSD2)->D2_VLIMPOR, 11,2)
							//EndIf
	            

					//Adequação NT2013/003 - Verifica se o valor será composto da tabela SBZ ou SB1
					nAliqNcm := 0
					If lCpoAlqSBZ .And. lCpoAlqSB1   
						nAliqNcm := RetFldProd(cCodProd,"B1_IMPNCM","SB1")
					EndIf 
					
					If !empty(nAliqNcm) .and. nAliqNcm == 0 .And. lCpoAlqSB1   	 
						nAliqNcm:=  SB1->B1_IMPNCM
					EndIf	
		            		            
		            If lCpoMsgLT .And. lCpoLoteFor .And. SF4->F4_MSGLT $ "1" 
						cNumLotForn := Alltrim(Posicione("SB8",2,xFilial("SB8")+(cAliasSD2)->D2_NUMLOTE+(cAliasSD2)->D2_LOTECTL+cCodProd,"B8_LOTEFOR"))
						if !Empty(cNumLotForn)
							cInfAdic := "LOTE:"+cNumLotForn+" "+cInfAdic
						EndIf			            	            		             
		            endif  
		            
		            //Verifica fonte carga tributária
		            	            
		            If cMvMsgTrib $ "1-3"
		            	If cMvFisCTrb =="1"
			            	If FindFunction("AlqLeiTran")		            		
			            		cFntCtrb := AlqLeiTran("SB1","SBZ" )[2]			            		
			            	EndIf
			            	If Empty(cFntCtrb) .And. !Empty(cMvFntCtrb).And. !cFntCtrb $ "IBPT"
				             	cFntCtrb := cMvFntCtrb
				            EndIf 
		            	Else
		            		If Empty(cFntCtrb) .And. !Empty(cMvFntCtrb)
				             	cFntCtrb := cMvFntCtrb
				            EndIf 
		            	EndIf
		            EndIf
		            		            		
					aAdd(aInfoItem,{(cAliasSD2)->D2_PEDIDO,(cAliasSD2)->D2_ITEMPV,(cAliasSD2)->D2_TES,(cAliasSD2)->D2_ITEM})

					aadd(aProd,	{Len(aProd)+1,;
						cCodProd,;
						IIf(Val(SB1->B1_CODBAR)==0,"",StrZero(Val(SB1->B1_CODBAR),Len(Alltrim(SB1->B1_CODBAR)),0)),;
						cDescProd,;
						SB1->B1_POSIPI,;//Retirada validação do parametro MV_CAPPROD, de acordo com a NT2014/004 não é mais possível informar o capítulo do NCM
						SB1->B1_EX_NCM,;
						cD2Cfop,;
						SB1->B1_UM,;
						(cAliasSD2)->D2_QUANT,;
						IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_TOTAL+nDesconto+(cAliasSD2)->D2_DESCZFR,IIF(((cAliasSD2)->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. SubStr(SM0->M0_CODMUN,1,2) == "31") .Or. ((cAliasSD2)->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. "RESSARCIMENTO" $ Upper(cNatOper) .And. "RESSARCIMENTO" $ Upper(cDescProd)),(cAliasSD2)->D2_TOTAL,0)),;
						IIF(Empty(SB5->B5_UMDIPI),SB1->B1_UM,SB5->B5_UMDIPI),;
						IIF(Empty(SB5->B5_CONVDIP),(cAliasSD2)->D2_QUANT,SB5->B5_CONVDIP*(cAliasSD2)->D2_QUANT),;
						(cAliasSD2)->D2_VALFRE,;
						(cAliasSD2)->D2_SEGURO,;
						(nDesconto+nDescIcm+nDescRed),;
						RetPrvUnit(cAliasSD2,nDesconto),;
						IIF(SB1->(FieldPos("B1_CODSIMP"))<>0,SB1->B1_CODSIMP,""),; //codigo ANP do combustivel
						IIF(SB1->(FieldPos("B1_CODIF"))<>0,SB1->B1_CODIF,""),; //CODIF
						(cAliasSD2)->D2_LOTECTL,;//Controle de Lote
						(cAliasSD2)->D2_NUMLOTE,;//Numero do Lote
					   	IIF(((cAliasSD2)->D2_TIPO == "D" .And. !lIpiDev) .Or. lConsig .Or. (Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM ) .or. ((cAliasSD2)->D2_TIPO == "B" .and. lIpiBenef) .or. ((cAliasSD2)->D2_TIPO=="P" .And. lComplDev .And. !lIpiDev) ,(cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3 + (cAliasSD2)->D2_VALIPI + nIcmsST, (cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3 + nIcmsST),;//Outras despesas + PISST + COFINSST  (Inclusão do valor de PIS ST e COFINS ST na tag vOutros - NT 2011/004).E devolução com IPI. (Nota de compl.Ipi de uma devolução de compra(MV_IPIDEV=F) leva o IPI em voutros)
						nRedBC,;//% Redução da Base de Cálculo
						cCST,;//Cód. Situação Tributária
						IIF((SF4->F4_AGREG='N' .And. !AllTrim(SF4->F4_CF) $ cMVCfopTran) .Or. (SF4->F4_ISS='S' .And. SF4->F4_ICM='N'),"0","1"),;// Tipo de agregação de valor ao total do documento
						cInfAdic,;//Informacoes adicionais do produto(B5_DESCNFE)
						nDescZF,;
						(cAliasSD2)->D2_TES,;
						IIF(SB5->(FieldPos("B5_PROTCON"))<>0,SB5->B5_PROTCON,""),; //Campo criado para informar protocolo ou convenio ICMS 
						IIf(SubStr(SM0->M0_CODMUN,1,2) == "35" .And. cTpPessoa == "EP" .And. nDescIcm > 0, nDescIcm,0),;   
						IIF((cAliasSD2)->(FieldPos("D2_TOTIMP"))<>0,(cAliasSD2)->D2_TOTIMP,0),;   //aProd[30] - Total imposto carga tributária. 
						(cAliasSD2)->D2_DESCZFP,;			//aProd[31] - Desconto Zona Franca PIS
						(cAliasSD2)->D2_DESCZFC,;			//aProd[32] - Desconto Zona Franca CONFINS
						(cAliasSD2)->D2_PICM,;		//aProd[33] - Percentual de ICMS
						IIF(SB1->(FieldPos("B1_TRIBMUN"))<>0,RetFldProd(SB1->B1_COD,"B1_TRIBMUN"),""),;  //aProd[34]
						IIF((cAliasSD2)->(FieldPos("D2_TOTFED"))<>0,(cAliasSD2)->D2_TOTFED,0),;   //aProd[35] - Total carga tributária Federal
						IIF((cAliasSD2)->(FieldPos("D2_TOTEST"))<>0,(cAliasSD2)->D2_TOTEST,0),;   //aProd[36] - Total carga tributária Estadual
						IIF((cAliasSD2)->(FieldPos("D2_TOTMUN"))<>0,(cAliasSD2)->D2_TOTMUN,0),;   //aProd[37] - Total carga tributária Municipal
						})

					aadd(aCST,{cCSTrib,cOrigem})
					aadd(aICMS,{})
					aadd(aIPI,{})
					aadd(aICMSST,{})
					aadd(aPIS,{})
					aadd(aPISST,{})
					aadd(aCOFINS,{})
					aadd(aCOFINSST,{})
					aadd(aISSQN,{})
					aadd(aAdi,{})
					aadd(aDi,{})

					//aadd(aPedCom,{})
					aadd(aPisAlqZ,{})
					aadd(aCofAlqZ,{})
					aadd(aCsosn,{})
					
					cNCM := SB1->B1_POSIPI
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para TAG Exportação quando existe a integração com a EEC     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lEECFAT
						/*Alterações TQXWO2
						Na chamada da função, foram criados dois novos parâmetros: 
						o 3º referente ao código do produto e o 4º referente ao número da nota fiscal + série (chave).
						GetNfeExp(pProcesso, pPedido, cProduto, cChave)
						No retorno da função serão devolvidas as informações do legado, conforme leiaute anterior à versão 3.10 , 
						e as informações dos grupos “I03 - Produtos e Serviços / Grupo de Exportação” e “ZA - Informações de Comércio Exterior”, conforme estrutura da NT20013.005_v1.21.
						As posições 1 e 2 mantém o retorno das informações ZA02 e ZA03, mantendo o legado para os cliente que utilizam versão 2.00
						Na posição 3 passa a ser enviado o agrupamento do ID I50, tendo como filhos os IDs I51 e I52.
						Na posição 4 passa a ser enviado o agrupamento do ZA01, tendo como filhos os IDs ZA02, ZA03 e ZA04.
						
						O array de retorno será multimensional, trazendo na primeira posição o identificador (ID), 
						na segunda posição a tag (o campo) e na terceira posição o conteúdo retornado do processo, 
						podendo ser um outro array com a mesma estrutura caso o ID possua abaixo de sua estrutura outros IDs.						 				
						*/
						If !Empty((cAliasSD2)->D2_PREEMB)
							aadd(aExp,(GETNFEEXP((cAliasSD2)->D2_PREEMB,,cCodProd,(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE)))
						ElseIf !Empty(SC5->C5_PEDEXP)
							aADD(aExp,(GETNFEEXP(,SC5->C5_PEDEXP,cCodProd,(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE)))
						Else
							aadd(aExp,{})
						EndIf
					ElseiF AliasIndic("CDL")
						aadd(aExp,{})
						DbSelectArea("CDL")
						DbSetOrder(1)
						DbSeek(xFilial("CDL")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
						While !CDL->(Eof()) .And. CDL->CDL_FILIAL+CDL->CDL_DOC+CDL->CDL_SERIE+CDL->CDL_CLIENT+CDL->CDL_LOJA == xFilial("CDL")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA
					    	If CDL->(FieldPos("CDL_PRODNF")) <> 0 .And. CDL->(FieldPos("CDL_ITEMNF")) <> 0 .And. AllTrim(CDL->CDL_PRODNF)+AllTrim(CDL->CDL_ITEMNF) == AllTrim((cAliasSD2)->D2_COD)+AllTrim((cAliasSD2)->D2_ITEM)
						    	aDados := {}
						    	aAdd(aDados,{"ZA02","ufEmbarq"  , IIF(CDL->(FieldPos("CDL_UFEMB"))<>0 , CDL->CDL_UFEMB  ,"") })
						    	aAdd(aDados,{"ZA03","xLocEmbarq", IIF(CDL->(FieldPos("CDL_LOCEMB"))<>0, CDL->CDL_LOCEMB ,"") })					
						    	aAdd(aDados,{"I51","nDraw", IIF(CDL->(FieldPos("CDL_ACDRAW"))<>0, CDL->CDL_ACDRAW ,"") })
						    	aAdd(aDados,{"I53","nRE", IIF(CDL->(FieldPos("CDL_NRREG"))<>0, CDL->CDL_NRREG ,"") })
						    	aAdd(aDados,{"I54","chNFe", IIF(CDL->(FieldPos("CDL_CHVEXP"))<>0, CDL->CDL_CHVEXP ,"") })
						    	aAdd(aDados,{"I55","qExport", IIF(CDL->(FieldPos("CDL_QTDEXP"))<>0, CDL->CDL_QTDEXP ,"") })
						    	aAdd(aDados,{"ZA04","xLocDespacho", IIF(CDL->(FieldPos("CDL_LOCDES"))<>0, CDL->CDL_LOCDES ,"") })	
					    	
						    	aAdd(aExp[Len(aExp)],aDados)
							EndIf

					    	CDL->(DbSkip())
						EndDo
					Else
						aadd(aExp,{})
					EndIf
					If AliasIndic("CD6")  .And. CD6->(FieldPos("CD6_QTAMB")) > 0 .And. CD6->(FieldPos("CD6_UFCONS")) > 0  .And. CD6->(FieldPos("CD6_BCCIDE")) > 0 .And. CD6->(FieldPos("CD6_VALIQ")) > 0 .And. CD6->(FieldPos("CD6_VCIDE")) > 0
						aadd(aComb,{CD6->CD6_CODANP,CD6->CD6_SEFAZ,CD6->CD6_QTAMB,CD6->CD6_UFCONS,CD6->CD6_BCCIDE,CD6->CD6_VALIQ, CD6->CD6_VCIDE, IIf(CD6->(FieldPos("CD6_MIXGN")) > 0,CD6->CD6_MIXGN,"") })
				    Elseif AliasIndic("CD6")  .And. CD6->(FieldPos("CD6_QTAMB")) > 0 .And. CD6->(FieldPos("CD6_UFCONS")) > 0 
				    	aadd(aComb,{CD6->CD6_CODANP,CD6->CD6_SEFAZ,CD6->CD6_QTAMB,CD6->CD6_UFCONS})
					Else
						aadd(aComb,{})
					EndIf
					If AliasIndic("CD7")
						aadd(aMed,{CD7->CD7_LOTE,CD7->CD7_QTDLOT,CD7->CD7_FABRIC,CD7->CD7_VALID,CD7->CD7_PRECO})
					Else
						aadd(aMed,{})
		   			EndIf
		   			If AliasIndic("CD8")
						aadd(aArma,{CD8->CD8_TPARMA,CD8->CD8_NUMARMA,CD8->CD8_DESCR})                       
					Else
						aadd(aArma,{})
					EndIf			
					If AliasIndic("CD9")    	
						aadd(aveicProd,{IIF(CD9->CD9_TPOPER$"03",1,IIF(CD9->CD9_TPOPER$"1",2,IIF(CD9->CD9_TPOPER$"2",3,IIF(CD9->CD9_TPOPER$"9",0,"")))),;
										CD9->CD9_CHASSI,CD9->CD9_CODCOR,CD9->CD9_DSCCOR,CD9->CD9_POTENC,CD9->CD9_CM3POT,CD9->CD9_PESOLI,;
						                CD9->CD9_PESOBR,CD9->CD9_SERIAL,CD9->CD9_TPCOMB,CD9->CD9_NMOTOR,CD9->CD9_CMKG,CD9->CD9_DISTEI,CD9->CD9_RENAVA,;
						                CD9->CD9_ANOMOD,CD9->CD9_ANOFAB,CD9->CD9_TPPINT,CD9->CD9_TPVEIC,CD9->CD9_ESPVEI,CD9->CD9_CONVIN,CD9->CD9_CONVEI,;
						                CD9->CD9_CODMOD,;
						                CD9->(Iif(FieldPos("CD9_CILIND")>0,CD9_CILIND,"")),;
						                CD9->(Iif(FieldPos("CD9_TRACAO")>0,CD9_TRACAO,"")),;
						                CD9->(Iif(FieldPos("CD9_LOTAC")>0,CD9_LOTAC,"")),;
						                CD9->(Iif(FieldPos("CD9_CORDE")>0,CD9_CORDE,"")),;
						                CD9->(Iif(FieldPos("CD9_RESTR")>0,CD9_RESTR,""))})
					Else
					    aadd(aveicProd,{})
					EndIf			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para Anfavea - Cabecalho e Itens                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					If lAnfavea
						//Cabecalho
						aAnfC := {}
						aadd(aAnfC,{CDR->CDR_VERSAO,CDR->CDR_CDTRAN,CDR->CDR_NMTRAN,CDR->CDR_CDRECP,CDR->CDR_NMRECP,;
							AModNot(CDR->CDR_ESPEC),CDR->CDR_CDENT,CDR->CDR_DTENT,CDR->CDR_NUMINV}) 
						//Itens
						aadd(aAnfI,{CDS->CDS_PRODUT,CDS->CDS_PEDCOM,CDS->CDS_SGLPED,CDS->CDS_SEPPEN,CDS->CDS_TPFORN,;
							CDS->CDS_UM,CDS->CDS_DTVALI,CDS->CDS_PEDREV,CDS->CDS_CDPAIS,CDS->CDS_PBRUTO,CDS->CDS_PLIQUI,;
							CDS->CDS_TPCHAM,CDS->CDS_NUMCHA,CDS->CDS_DTCHAM,CDS->CDS_QTDEMB,CDS->CDS_QTDIT,CDS->CDS_LOCENT,;
							CDS->CDS_PTUSO,CDS->CDS_TPTRAN,CDS->CDS_LOTE,CDS->CDS_CPI,CDS->CDS_NFEMB,CDS->CDS_SEREMB,;
							CDS->CDS_CDEMB,CDS->CDS_AUTFAT,CDS->CDS_CDITEM})
					Else
						aadd(aAnfC,{})
						aadd(aAnfI,{})
		   			EndIf				

					//Anfavea Cabecalho
					If Len(cAnfavea) > 0
						cAnfavea += cAnfavea
					Else
						cAnfavea := ""
					EndIf
					
					If lAnfavea
						If !Empty(aAnfC) .And. !Empty(aAnfC[01,01]) .And. lCabAnf
							lCabAnf := .F.
							cAnfavea := '<![CDATA[[' 
							If !Empty(aAnfC[01,01])
								cAnfavea += 	' <versao>' + aAnfC[01,01] + '</versao>'
							Endif
							cAnfavea += 	'<transmissor'
							If !Empty(aAnfC[01,02])
								cAnfavea += 	' codigo="' + aAnfC[01,02] + '"'
							Endif
							If !Empty(aAnfC[01,03])
								cAnfavea += 	' nome="' + aAnfC[01,03] + '"'
							Endif
						    cAnfavea += '/><receptor'
							If !Empty(aAnfC[01,04])
								cAnfavea += 	' codigo="' + aAnfC[01,04] + '"'
							Endif
							If !Empty(aAnfC[01,05])
								cAnfavea += 	' nome="' + aAnfC[01,05] + '"'
							Endif
						    cAnfavea += '/>'	
							If !Empty(aAnfC[01,06])
								cAnfavea += 	'<especieNF>' + aAnfC[01,06] + '</especieNF>'
							Endif
							If !Empty(aAnfC[01,07])
								cAnfavea += 	'<fabEntrega>' + aAnfC[01,07] + '</fabEntrega>'
							Endif
							If !Empty(aAnfC[01,08])
								cAnfavea += 	'<prevEntrega>' + Dtos(aAnfC[01,08]) + '</prevEntrega>'
							Endif
							If !Empty(aAnfC[01,09])
								cAnfavea += 	'<Invoice>' + aAnfC[01,09] + '</Invoice>'
							Endif
							cAnfavea +=	']]>'
						Endif  
					Endif

					DbSelectArea("SF2")
					DbSetOrder(1)
					MsSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
					dbSelectArea("CD2")
					If !(cAliasSD2)->D2_TIPO $ "DB"
						dbSetOrder(1)
					Else
						dbSetOrder(2)
					EndIf
				    
				    DbSelectArea("SFT")
				    DbSetOrder(1)
				    If SFT->(DbSeek(xFilial("SFT")+"S"+(cAliasSD2)->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+PadR(D2_ITEM,TamSx3("FT_ITEM")[1])+D2_COD)))
					   If !Empty( SFT->FT_CTIPI )
					   		aadd(aCSTIPI,{SFT->FT_CTIPI})
					   EndIf
					   //TRATAMENTO DA AQUISIÇÃO DE LEITE DO PRODUTOR RURAL CONFORME ARTIGO 207-B, INCISO II RICMS/MG
					   //PEGA OS VALORES E PERCENTUAL DO INNCENTIVO NOS ITENS NA SFT.
					   If SFT->(FieldPos("FT_PRINCMG")) > 0 .And. SFT->(FieldPos("FT_VLINCMG")) > 0
							If SFT->FT_VLINCMG > 0
								nValLeite += SFT->FT_VLINCMG
							EndIf
							If nPercLeite == 0 .And. SFT->FT_PRINCMG > 0 
								nPercLeite := SFT->FT_PRINCMG
							EndIf	
						EndIf
					EndIf 
					If Substr(SFT->FT_CLASFIS,2,2) == "40" .And. SFT->FT_DESCZFR>0 
							aadd(aICMSZFM,{If(SFT->(FieldPos("FT_DESCZFR")) > 0,FT_DESCZFR,""),;
										   If(SFT->(FieldPos("FT_MOTICMS")) > 0,SFT->FT_MOTICMS,"")})
					Else
							aadd(aICMSZFM,{})
					EndIf
									     
					CD2->(dbSeek(xFilial("CD2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA+PadR((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD))
		
					While CD2->(!Eof()) .And. xFilial("CD2") == CD2->CD2_FILIAL .And.;
						"S" == CD2->CD2_TPMOV .And.;
						SF2->F2_SERIE == CD2->CD2_SERIE .And.;
						SF2->F2_DOC == CD2->CD2_DOC .And.;
						SF2->F2_CLIENTE == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_CODCLI,CD2->CD2_CODFOR) .And.;
						SF2->F2_LOJA == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_LOJCLI,CD2->CD2_LOJFOR) .And.;
						(cAliasSD2)->D2_ITEM == SubStr(CD2->CD2_ITEM,1,Len((cAliasSD2)->D2_ITEM)) .And.;
						Alltrim((cAliasSD2)->D2_COD) == Alltrim(CD2->CD2_CODPRO)
					
					    nMargem :=  IiF(CD2->CD2_PREDBC>0,IiF(CD2->CD2_PREDBC == 100,CD2->CD2_PREDBC,IF(CD2->CD2_PREDBC > 100,0,100-CD2->CD2_PREDBC)),CD2->CD2_PREDBC)              		 					

						/*DbSelectArea("SF7")				
						DbSetOrder(1)											
							If DbSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA1->A1_GRPTRIB)														
								If SF7->F7_BASEICM > 0
									nMargem := SF7->F7_BASEICM
								EndIf										
							EndIf*/									
						// Verifica se existe percentual de reducao na SFT referête ao RICMS 43080/2002 MG.
						If SFT->(FieldPos("FT_PR43080")) <> 0 .And. SFT->FT_PR43080 <> 0 .And. IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT)) == "MG"
							nMargem := SFT->FT_PR43080
						EndIf										
						Do Case
							Case AllTrim(CD2->CD2_IMP) == "ICM"
								aTail(aICMS) := {CD2->CD2_ORIGEM,;
												   If(lNfCupZero,POSICIONE("SF4",1,xFilial("SF4")+cD2Tes,"F4_SITTRIB"),CD2->CD2_CST),;
												   CD2->CD2_MODBC,;
								                   If(lNfCupZero,0,nMargem),;
												   If(lNfCupZero,0,CD2->CD2_BC),;
								If(lNfCupZero,0,Iif(CD2->CD2_BC>0,CD2->CD2_ALIQ,0)),;
								If(lNfCupZero,0,CD2->CD2_VLTRIB),;
								0,;
								CD2->CD2_QTRIB,;
								CD2->CD2_PAUTA,;
								If(SFT->(FieldPos("FT_MOTICMS")) > 0,SFT->FT_MOTICMS,""),;
								SFT->FT_ICMSDIF,;
								Iif(lCD2PARTIC,CD2->CD2_PARTIC,""),;
								POSICIONE("SF4",1,xFilial("SF4")+cD2Tes,"F4_ICMSDIF")}
			
								
								If lCD2PARTIC .And. CD2->CD2_PARTIC == "2"
									nValICMParc += CD2->CD2_VLTRIB 
									nBasICMParc += CD2->CD2_BC
								EndIf
								
							Case AllTrim(CD2->CD2_IMP) == "SOL"
																
								aTail(aICMSST) := {CD2->CD2_ORIGEM,;
								If(lNfCupZero,POSICIONE("SF4",1,xFilial("SF4")+cD2Tes,"F4_SITTRIB"),CD2->CD2_CST),;
								CD2->CD2_MODBC,;
								If(lNfCupZero,0,IiF(CD2->CD2_PREDBC>0,IiF(CD2->CD2_PREDBC > 100,0,100-CD2->CD2_PREDBC),CD2->CD2_PREDBC)),;
								If(lNfCupZero,0,CD2->CD2_BC),;
								If(lNfCupZero,0,CD2->CD2_ALIQ),;
								If(lNfCupZero,0,CD2->CD2_VLTRIB),;
								CD2->CD2_MVA,;
								CD2->CD2_QTRIB,;
								CD2->CD2_PAUTA,;
								Iif(lCD2PARTIC,CD2->CD2_PARTIC,"")}
								If (Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM)  .And. CD2->CD2_VLTRIB > 0 
									aTail(aICMSST):= {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,0,0,0,0,CD2->CD2_MVA,0,CD2->CD2_PAUTA,Iif(lCD2PARTIC,CD2->CD2_PARTIC,"")}
								EndIf
								lCalSol := .T.
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Tratamento CAT04 de 26/02/2010                       ³
								//³Verifica de deve ser garavado no xml o valor e base  ³
								//³de calculo do ICMS ST para notas fiscais de devolucao³
								//³Verifica o parametro MV_ICSTDEV                      ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		                        nValST 	:= CD2->CD2_VLTRIB  
								If !lIcmSTDev
									If ( (cAliasSD2)->D2_TIPO=="D" .Or. ( (cAliasSD2)->D2_TIPO=="I" .And. lComplDev)) .And. !Empty(nValST) 
										nValSTAux := nValSTAux + nValST
										nBsCalcST := nBsCalcST + CD2->CD2_BC
										nValST 	  := 0
										aTail(aICMSST):= {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,0,0,0,0,CD2->CD2_MVA,	CD2->CD2_QTRIB,CD2->CD2_PAUTA,Iif(lCD2PARTIC,CD2->CD2_PARTIC,"")}  
									EndIf
								EndIf
								
								If lCD2PARTIC .And. CD2->CD2_PARTIC == "2"
									nValSTParc += CD2->CD2_VLTRIB 
									nBasSTParc += CD2->CD2_BC
								EndIf								
								
							Case AllTrim(CD2->CD2_IMP) == "IPI"
								If !lConsig
									aTail(aIPI) := {SB1->B1_SELOEN,;
									SB1->B1_CLASSE,;
									0,;
									"999",;
									CD2->CD2_CST,;
									CD2->CD2_BC,;
									CD2->CD2_QTRIB,;
									CD2->CD2_PAUTA,;
									CD2->CD2_ALIQ,;
									CD2->CD2_VLTRIB,;
									CD2->CD2_MODBC,;
									IiF(CD2->CD2_PREDBC>0,IiF(CD2->CD2_PREDBC > 100,0,100-CD2->CD2_PREDBC),CD2->CD2_PREDBC)}
									nValIPI := CD2->CD2_VLTRIB
									If (Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM) .And. !Empty(nValIPI) 
										aTail(aIPI) := {SB1->B1_SELOEN,SB1->B1_CLASSE,0,"999",CD2->CD2_CST,0,0,CD2->CD2_PAUTA,0,0,CD2->CD2_MODBC,0}
									EndIf
									If !lIpiDev .And. !(Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM) .OR. ((cAliasSD2)->D2_TIPO=="B" .And. lIpiBenef)
										If ( (cAliasSD2)->D2_TIPO=="D" .And. !Empty(nValIPI) ).OR. ( (cAliasSD2)->D2_TIPO=="P" .And. lComplDev .And. !Empty(nValIPI) ) .OR. ( (cAliasSD2)->D2_TIPO=="B" .And. lIpiBenef .and. !Empty(nValIPI) )
											aAdd(aIPIDev, {nValIPI,cNCM})
											nValIPI := 0
											cNCM	:= ""
											aTail(aIPI) := {SB1->B1_SELOEN,SB1->B1_CLASSE,0,"999",CD2->CD2_CST,0,0,CD2->CD2_PAUTA,0,0,CD2->CD2_MODBC,0}
										EndIf 
									EndIf
								EndIf
							Case AllTrim(CD2->CD2_IMP) == "PS2"
								If !lNfCupZero
									aTail(aPIS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
								Else
									aTail(aPIS) := {POSICIONE("SF4",1,xFilial("SF4")+cD2Tes,"F4_CSTPIS"),0,0,0,CD2->CD2_QTRIB,CD2->CD2_PAUTA}								
								EndIf
							Case AllTrim(CD2->CD2_IMP) == "CF2"
								If !lNfCupZero
									aTail(aCOFINS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
								Else
									aTail(aCOFINS) := {POSICIONE("SF4",1,xFilial("SF4")+cD2Tes,"F4_CSTCOF"),0,0,0,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
								EndIf
							Case AllTrim(CD2->CD2_IMP) == "PS3" .And. (cAliasSD2)->D2_VALISS==0
								If !lNfCupZero
									aTail(aPISST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
								Else
									aTail(aPISST) := {POSICIONE("SF4",1,xFilial("SF4")+cD2Tes,"F4_CSTPIS"),0,0,0,CD2->CD2_QTRIB,CD2->CD2_PAUTA}	
								EndIf
							Case AllTrim(CD2->CD2_IMP) == "CF3" .And. (cAliasSD2)->D2_VALISS==0
									If !lNfCupZero
										aTail(aCOFINSST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
									Else
										aTail(aCOFINSST) := {POSICIONE("SF4",1,xFilial("SF4")+cD2Tes,"F4_CSTCOF"),0,0,0,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
									EndIf
							Case AllTrim(CD2->CD2_IMP) == "ISS" 
									
							
								If Empty(aISS)
									aISS := {0,0,0,0,0}
								EndIf
								aISS[01] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
								aISS[02] += CD2->CD2_BC
								aISS[03] += CD2->CD2_VLTRIB	
								cMunISS := ConvType(aUF[aScan(aUF,{|x| x[1] == aDest[09]})][02]+aDest[07])
								cCodIss := AllTrim((cAliasSD2)->D2_CODISS)
								If AliasIndic("CDN") .And. CDN->(dbSeek(xFilial("CDN")+cCodIss))
									cCodIss := AllTrim(CDN->CDN_CODLST)
								EndIf
								If SF3->F3_TIPO =="S"
									If SF3->F3_RECISS =="1" 
										cSitTrib := "R"
									Elseif SF3->F3_RECISS =="2" //.and. ( !SF4->F4_LFISS == "I" .and. !SM0->M0_ESTENT == "" )
										cSitTrib:= "N"
									Elseif SF4->F4_LFISS =="I"
										cSitTrib:= "I"
									Else
										cSitTrib:= "N"
									Endif
								Endif
								
								IF SF4->F4_ISSST == "1" .or. Empty(SF4->F4_ISSST)
									cIndIss := "1" //1-Exigível;
								ElseIf SF4->F4_ISSST == "2"
									cIndIss := "2"	//2-Não incidência
								ElseIf SF4->F4_ISSST == "3"
									cIndIss := "3" //3-Isenção
								ElseIf	SF4->F4_ISSST == "4"
									cIndIss := "5"	 //5-Imunidade
								ElseIf	SF4->F4_ISSST == "5"
									cIndIss := "6"	 //6-Exigibilidade Suspensa por Decisão Judicial
								ElseIf SF4->F4_ISSST == "6"
									cIndIss := "7"	 //7-Exigibilidade Suspensa por Processo Administrativo
								Else
									cIndIss := "4"//4-Exportação
								EndIf
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Pega as deduções ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If SF3->(FieldPos("F3_ISSSUB")) > 0
									nDeducao+= SF3->F3_ISSSUB
								EndIf
								
								If SF3->(FieldPos("F3_ISSMAT")) > 0
									nDeducao+= SF3->F3_ISSMAT
								EndIf
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se recolhe ISS Retido ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If SF3->(FieldPos("F3_RECISS"))>0
									If SF3->F3_RECISS $"1S"       
										If SF3->(dbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
											While !SF3->(EOF()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE==SF2->F2_FILIAL+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE
												If SF3->F3_TIPO=="S" //Serviço
													nValISSRet+= SF3->F3_VALICM
												EndIf
												SF3->(dbSkip())
											EndDo
										EndIf										
							   		Endif
								EndIf
								
								aTail(aISSQN) := {CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,cMunISS,cCodIss,cSitTrib,nDeducao,cIndIss,nValISSRet}
						EndCase
						dbSelectArea("CD2")
						dbSkip()
					EndDo
					
					//Tratamento para que o valor de PIS ST e COFINS ST venha a compor o valor total da tag vOutros  (NT 2011/004). E devolução de compra com IPI não tributado
					If ((cAliasSD2)->D2_TIPO == "D" .and. !lIpiDev)  .Or. lConsig .Or. (Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM ) .OR. ((cAliasSD2)->D2_TIPO == "B" .and. lIpiBenef) .OR. ((cAliasSD2)->D2_TIPO=="P" .And. lComplDev .And. !lIpiDev)
						aTotal[01] += (cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3 + (cAliasSD2)->D2_VALIPI + nIcmsST
					Else 
						aTotal[01] += (cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3 + nIcmsST
					EndIf
				   
					If (cAliasSD2)->D2_TIPO == "I"
						If (cAliasSD2)->D2_ICMSRET > 0
							aTotal[02] += (cAliasSD2)->D2_VALBRUT
						ElseIf (SubStr(SM0->M0_CODMUN,1,2) == "31" .And. SF4->F4_AJUSTE == "S") .Or. ( (SF4->F4_AGREG == "S" .And. SF4->F4_AJUSTE == "S") .And. ("RESSARCIMENTO" $ Upper(cNatOper) .And. "RESSARCIMENTO" $ Upper(cDescProd)))
							aTotal[02] += (cAliasSD2)->D2_TOTAL
						Else
							aTotal[02] += 0
						Endif
					ElseIf (cAliasSD2)->D2_TIPO == "N" .And. AllTrim(SF4->F4_CF) $ cMVCfopTran
						aTotal[02] += (cAliasSD2)->D2_TOTAL
					Else
	                    aTotal[02] += (cAliasSD2)->D2_VALBRUT
	                EndIf							
					If lCalSol .OR.  lMVCOMPET
						dbSelectArea("SF3")
						dbSetOrder(4)
						If MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
							If At (SF3->F3_ESTADO, cMVSUBTRIB)>0
								nPosI	:=	At (SF3->F3_ESTADO, cMVSUBTRIB)+2
								nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
								nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
								aAdd (aIEST, SubStr (cMVSUBTRIB, nPosI, nPosF))	//01 - IE_ST
							EndIf
						EndIf
				    Endif
					
					
					
					If SFT->(FieldPos("FT_CSTPIS")) > 0 .And. SFT->(FieldPos("FT_CSTCOF")) > 0
						
						dbSelectArea("SFT") //Livro Fiscal Por Item da NF
						dbSetOrder(1) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
						If MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA+PadR((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD)
							
							IF Empty(aPis[Len(aPis)]) .And. !empty(SFT->FT_CSTPIS)
								aTail(aPisAlqZ):= {SFT->FT_CSTPIS}
							EndIf
							IF Empty(aCOFINS[Len(aCOFINS)]) .And. !empty(SFT->FT_CSTCOF)
								aTail(aCofAlqZ) := {SFT->FT_CSTCOF}
							EndIf
							
						EndIf
						
					Else
						
						IF Empty(aPis[Len(aPis)]) .And. !empty(SF4->F4_CSTPIS)
							aTail(aPisAlqZ):= {SF4->F4_CSTPIS}		
						EndIf
						IF Empty(aCOFINS[Len(aCOFINS)]) .And. !empty(SF4->F4_CSTCOF)
							aTail(aCofAlqZ):= {SF4->F4_CSTCOF}
						EndIf
						
					EndIf
					
					If !len(aCofAlqZ)>0 .or. !len(aPisAlqZ)>0
						aadd(aCofAlqZ,{})  
				   		aadd(aPisAlqZ,{})					
					Endif
					If SF4->(FieldPos("F4_CSOSN"))>0
						aTail(aCsosn):= SF4->F4_CSOSN
					Else
						aTail(aCsosn):= ""
					EndIf
									
				   		
					If !len(aCsosn)>0 
						aadd(aCsosn,"")  
				   	Endif
				endif	
				If (cAliasSD2)->D2_TIPO == "B"
					lNotaBenef := .T.
				EndIf

				dbSelectArea(cAliasSD2)
				dbSkip()
		    EndDo 

			//Tratamento para incluir a mensagem em informacoes adicionais do Suframa
			If !Empty(aDest[15])
			// Msg Zona Franca de Manaus / ALC
				dbSelectArea("SF3")
				dbSetOrder(4)
				dbSeek (xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
				Do While !SF3->(Eof()) .AND. xFilial("SF3") == SF3->F3_FILIAL .And.;
					SF2->F2_CLIENTE == SF3->F3_CLIEFOR .And. SF2->F2_LOJA == SF3->F3_LOJA .And.;
					SF2->F2_DOC == SF3->F3_NFISCAL .And. SF2->F2_SERIE == SF3->F3_SERIE
					
						nValBse += SF3->F3_VALOBSE
						SF3->(DbSkip ())
   				EndDo		
				If MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)			
					If !SF3->F3_DESCZFR == 0 .or. ( lInfAdZF .and. nValBse > 0 )
						If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
						   cMensFis += " "
						EndIf					
						If lInfAdZF .And. (nValPisZF > 0 .Or. nValCofZF > 0)
							cMensFis += "Descontos Ref. a Zona Franca de Manaus / ALC. ICMS - R$ "+str(nValBse-SF2->F2_DESCONT-nValPisZF-nValCofZF,13,2)+", PIS - R$ "+ str(nValPisZF,13,2) +"e COFINS - R$ " +str(nValCofZF,13,2) 											
						ElseIF !lInfAdZF .And. (nValPisZF > 0 .Or. nValCofZF > 0) 
							cMensFis += "Desconto Ref. ao ICMS - Zona Franca de Manaus / ALC. R$ "+str(nValBse-SF2->F2_DESCONT-nValPisZF-nValCofZF,13,2)
					    Else
					    	cMensFis += "Total do desconto Ref. a Zona Franca de Manaus / ALC. R$ "+str(nValBse-SF2->F2_DESCONT,13,2)
					    EndIF
					EndIf 			
				EndIf	
			EndIF

			//TRATAMENTO DA AQUISIÇÃO DE LEITE DO PRODUTOR RURAL CONFORME ARTIGO 207-B, INCISO II RICMS/MG
			//INSERE MSG EM INFADFISCO E SOMA NO TOTAL DA NOTA.
			If nValLeite > 0 .And. nPercLeite > 0
				cMensFis += Alltrim(Str(nPercLeite,10,2))+'% Incentivo à produção e à industrialização do leite = R$ '+ Alltrim(Str(nValLeite,10,2))
				aTotal[02] += nValLeite
			EndIf

			If Len(aIPIDev)>0
		    	nX := 1
				Do While lOk
	
				   nValAux := aIPIDev[nX][1]               
				   cNCMAux := aIPIDev[nX][2]
				   
				   npos := aScan( aIPIAux,{|x| x[2]==cNCMAux})
				   IF npos >0			
						aIPIAux[npos][1]+=nValAux
			       Else
						AaDd(aIPIAux,{nValAux,cNCMAux})		       
			       EndIf
				
					nX += 1
					If nX > Len(aIPIDev)
						lOk := .F.
					EndIf
				EndDo
	
				If !lNotaBenef
					For nX := 1 To Len(aIPIAux)
						cValIPI  := AllTrim(Str(aIPIAux[nX][1],15,2))
						cMensCli += " "
						cMensCli += "(Valor do IPI: R$ "+cValIPI+" - "+"Classificação fiscal: "+aIPIAux[nX][2]+") "
						cValIPI  := ""
						cNCMAux  := ""
					Next nX
				Else
					For nX := 1 To Len(aIPIAux)
						cValIPI  := AllTrim(Str(aIPIAux[nX][1],15,2))
						cMensCli += " "
						cMensCli += "(Valor do IPI: R$ "+cValIPI+") "
						cValIPI  := ""
						cNCMAux  := ""
					Next nX
				EndIf
			EndIf
			If nValSTAux > 0 
				cValST  := AllTrim(Str(nValSTAux,15,2))
				cBsST   := AllTrim(Str(nBsCalcST,15,2))
				cMensCli += " "
				If lComplDev .And.  nBsCalcST == 0
					cMensCli += "(Valor do ICMS ST: R$ "+cValST+") " 					
				Else
					cMensCli += "(Base de Calculo do ICMS ST: R$ "+cBsST+ " - "+"Valor do ICMS ST: R$ "+cValST+") "
				EndIF	
				cValST	  := ""  
				cBsST 	  := ""   
				nBsCalcST := 0
				nValSTAux := 0				
			EndIf
			
			//Tratamento legislacao do Rio Grande do Sul, quando existir intes com ICMS-ST e intens somente com ICMS  próprio
			If SM0->M0_ESTCOB $ "RS" .And. Len(aICMS) > 0 .And. Len(aICMSSt) > 0 
				cMensCli += MsgCliRsIcm(aICMS,aICMSSt)
			Endif
		    
		    //Mensgaem para ICMS Particionado - Convênio ICMS Nº 51/00,
		    if nValICMParc > 0 .And. nBasICMParc > 0 .And. nValSTParc > 0 .And. nBasSTParc > 0
								
				If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
				   cMensFis += " "
				EndIf
				
				cMensFis += "Faturamento Direto ao Consumidor - Convenio ICMS Nº 51/00, de 15 de setembro de 2000. "
				cMensFis += "Base de calculo ICMS R$"+ AllTrim(Str(nBasICMParc,15,2))+" e "
				cMensFis += "Valor do ICMS R$"+ AllTrim(Str(nValICMParc,15,2))+". "
				cMensFis += "Base do ICMS-ST R$"+ AllTrim(Str(nBasSTParc,15,2))+" e "
				cMensFis += "Valor do ICMS-ST R$"+ AllTrim(Str(nValSTParc,15,2))+". "
				
				If !Empty(aEntrega) 
					cMensFis += "Concessionaria que ira entregar o veiculo ao adquirente "+ConvType(aEntrega[09],115)+". "
					cMensFis += "CNPJ: "+AllTrim(aEntrega[01])+" e IE: "+AllTrim(aEntrega[10])+". "
					cMensFis += "Endereço: "+ConvType(aEntrega[02],125)+", "+ConvType(aEntrega[03],10)+" "+ConvType(aEntrega[04],60)+". " //Rua,Num,Complemento
					cMensFis += ConvType(aEntrega[05],60)+" - "+ ConvType(aEntrega[07],50) +"-"+ConvType(aEntrega[08],2)+". "//Bairro, Cidade, UF
				Else
					cMensFis += "Concessionaria que ira entregar o veiculo ao adquirente "+ConvType(aDest[02],115)+". "
					cMensFis += "CNPJ "+AllTrim(aDest[01])+" e IE: "+AllTrim(aDest[14])+". "
					cMensFis += "Endereço: "+ConvType(aDest[03],125)+" "+ConvType(aDest[04],10)+" "+ConvType(aDest[05],60)+", " //Rua,Num,Complemento
					cMensFis += ConvType(aDest[06],60)+ ", "+ ConvType(aDest[08],50) +" - "+ConvType(aDest[09],2)+". "//Bairro, Cidade, UF 
				EndIF	
								
			endif
			
			If ((SubStr(SM0->M0_CODMUN,1,2) == "35" ) .and. "REMESSA POR CONTA E ORDEM DE TERCEIROS" $ Upper(cNatOper) .and. lOrgaoPub )
				cMensFis += "NF-e emitida nos termos do artigo 129-A do RICMS."
				cMensFis += "(Redacao dada ao artigo pelo Decreto n60.060 , de 14.01.2014, DOE SP de 15.01.2014)"				
			EndIf
		    
		    If lQuery
		    	dbSelectArea(cAliasSD2)
		    	dbCloseArea()
		    	dbSelectArea("SD2")
		    
		    	dbSelectArea("SC5")
		    	dbCloseArea()
		    EndIf
		    /*Tratamento para buscar a Nota Original e a Data referente inciso II do art. 456 do RICMS / SP, chamado THPXGS*/
		    if lBrinde
		    	aDocDat := DocDatOrig(SD2->D2_NUMLOTE,SD2->D2_LOTECTL,SD2->D2_COD)
		    	if len (cMensCli) > 0
		    		cMensCli += ' '
		    	endif
		    	cMensCli += "Nota Fiscal emitida nos termos do inciso II do art. 456 do RICMS - Nota Fiscal de Aquisição nº "+aDocDat[2]+", de "+aDocDat[1]+"."
		    endif 
		EndIf
	EndIf
Else
	dbSelectArea("SF1")
	dbSetOrder(1)
	If MsSeek(xFilial("SF1")+cNota+cSerie+cClieFor+cLoja)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento temporario do CTe                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If FunName() == "SPEDCTE" .Or. AModNot(SF1->F1_ESPECIE)=="57"
			cNFe := "CTe35080944990901000143570000000000200000168648"
			cString := '<infNFe versao="T02.00" modelo="57" >'
			cString += '<CTe xmlns="http://www.portalfiscal.inf.br/cte"><infCte Id="CTe35080944990901000143570000000000200000168648" versao="1.02"><ide><cUF>35</cUF>'
			cString += '<cCT>000016864</cCT><CFOP>6353</CFOP><natOp>ENTREGA NORMAL</natOp><forPag>1</forPag><mod>57</mod><serie>0</serie><nCT>20</nCT>'
			cString += '<dhEmi>2008-09-12T10:49:00</dhEmi><tpImp>2</tpImp><tpEmis>2</tpEmis><cDV>8</cDV><tpAmb>2</tpAmb><tpCTe>0</tpCTe><procEmi>0</procEmi>'
			cString += '<verProc>1.12a</verProc><cMunEmi>3550308</cMunEmi><xMunEmi>Sao Paulo</xMunEmi><UFEmi>SP</UFEmi><modal>01</modal><tpServ>0</tpServ>'
			cString += '<cMunIni>3550308</cMunIni><xMunIni>Sao Paulo</xMunIni><UFIni>SP</UFIni><cMunFim>3550308</cMunFim><xMunFim>Sao Paulo</xMunFim>'
			cString += '<UFFim>SP</UFFim><retira>1</retira><xDetRetira>TESTE</xDetRetira><toma03><toma>0</toma></toma03></ide><emit><CNPJ>44990901000143</CNPJ>'
			cString += '<IE>00000000000</IE><xNome>FILIAL SAO PAULO</xNome><xFant>Teste</xFant><enderEmit><xLgr>Av. Teste, S/N</xLgr><nro>0</nro><xBairro>Teste</xBairro>'
			cString += '<cMun>3550308</cMun><xMun>Sao Paulo</xMun><CEP>00000000</CEP><UF>SP</UF></enderEmit></emit><rem><CNPJ>58506155000184</CNPJ><IE>115237740114</IE>'
			cString += '<xNome>CLIENTE SP</xNome><xFant>CLIENTE SP</xFant><enderReme><xLgr>R</xLgr><nro>0</nro><xBairro>BAIRRO NAO CADASTRADO</xBairro><cMun>3550308</cMun>'
			cString += '<xMun>SAO PAULO</xMun><CEP>77777777</CEP><UF>SP</UF></enderReme><infOutros><tpDoc>00</tpDoc><dEmi>2008-09-17</dEmi></infOutros></rem><dest><CNPJ>'
			cString += '</CNPJ><IE></IE><xNome>CLIENTE RJ</xNome><enderDest><xLgr>R</xLgr><nro>0</nro><xBairro>BAIRRO NAO CADASTRADO</xBairro><cMun>3550308</cMun><xMun>RIO DE JANEIRO</xMun>'
			cString += '<CEP>44444444</CEP><UF>RJ</UF></enderDest></dest><vPrest><vTPrest>1.93</vTPrest><vRec>1.93</vRec></vPrest><imp><ICMS><CST00><CST>00</CST><vBC>250.00</vBC><pICMS>18.00</pICMS><vICMS>450.00</vICMS>'
			cString += '</CST00></ICMS></imp><infCteComp><chave>35080944990901000143570000000000200000168648</chave><vPresComp><vTPrest>10.00</vTPrest>'
			cString += '</vPresComp><impComp><ICMSComp><CST00Comp><CST>00</CST><vBC>10.00</vBC><pICMS>10.00</pICMS><vICMS>10.00</vICMS></CST00Comp></ICMSComp></impComp>'
			cString += '</infCteComp></infCte></CTe>'
			cString += '</infNFe>'
		Else				
			aadd(aNota,SF1->F1_SERIE)
			aadd(aNota,IIF(Len(SF1->F1_DOC)==6,"000","")+SF1->F1_DOC)
			aadd(aNota,SF1->F1_EMISSAO)
			aadd(aNota,cTipo)
			aadd(aNota,SF1->F1_TIPO)
			aadd(aNota,SF1->F1_HORA)			
			If SF1->F1_TIPO $ "DB" 
			    dbSelectArea("SA1")
				dbSetOrder(1)
				MsSeek(xFilial("SA1")+cClieFor+cLoja)

				If cMVNFEMSA1=="C" .And. !Empty(SA1->A1_MENSAGE)
					cMensCli	:=	SA1->(Formula(A1_MENSAGE))
				ElseIf cMVNFEMSA1=="F" .And. !Empty(SA1->A1_MENSAGE)
					cMensFis	:=	SA1->(Formula(A1_MENSAGE))
				EndIf				

				aadd(aDest,AllTrim(SA1->A1_CGC))
				aadd(aDest,SA1->A1_NOME)
				aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[1])

		   		If MyGetEnd(SA1->A1_END,"SA1")[2]<>0
					aadd(aDest,MyGetEnd(SA1->A1_END,"SA1")[3]) 
				Else 
					aadd(aDest,"SN") 
				EndIf

				aadd(aDest,IIF(SA1->(FieldPos("A1_COMPLEM")) > 0 .And. !Empty(SA1->A1_COMPLEM),SA1->A1_COMPLEM,MyGetEnd(SA1->A1_END,"SA1")[4]))

				aadd(aDest,SA1->A1_BAIRRO)
				If !Upper(SA1->A1_EST) == "EX"
					aadd(aDest,SA1->A1_COD_MUN)
					aadd(aDest,SA1->A1_MUN)				
				Else
					aadd(aDest,"99999")			
					aadd(aDest,"EXTERIOR")
				EndIf
				aadd(aDest,Upper(SA1->A1_EST))
				aadd(aDest,SA1->A1_CEP)
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
				aadd(aDest,SA1->A1_DDD+SA1->A1_TEL)
				If !Upper(SA1->A1_EST) == "EX"
					aadd(aDest,VldIE(SA1->A1_INSCR))
				Else
					aadd(aDest,"")							
				EndIf
				aadd(aDest,SA1->A1_SUFRAMA)
				aadd(aDest,SA1->A1_EMAIL)
				aAdd(aDest, SA1->A1_CONTRIB) // Posição 17
				aadd(aDest,Iif(SA1->(FieldPos("A1_IENCONT")) > 0 ,SA1->A1_IENCONT,""))
				aadd(aDest,SA1->A1_INSCRM)
				aadd(aDest,SA1->A1_TIPO)
				aadd(aDest,SA1->A1_PFISICA)//21-Identificação estrangeiro
									
			Else
			    dbSelectArea("SA2")
				dbSetOrder(1)  				
				MsSeek(xFilial("SA2")+cClieFor+cLoja)
		
				aadd(aDest,AllTrim(SA2->A2_CGC))
				aadd(aDest,SA2->A2_NOME)
				aadd(aDest,MyGetEnd(SA2->A2_END,"SA2")[1])

				If MyGetEnd(SA2->A2_END,"SA2")[2]<>0
					aadd(aDest,MyGetEnd(SA2->A2_END,"SA2")[3]) 
				Else 
					aadd(aDest,"SN") 
				EndIf

				aadd(aDest,MyGetEnd(SA2->A2_END,"SA2")[4])
				aadd(aDest,SA2->A2_BAIRRO)
				If !Upper(SA2->A2_EST) == "EX"
					aadd(aDest,SA2->A2_COD_MUN)
					aadd(aDest,SA2->A2_MUN)				
				Else
					aadd(aDest,"99999")			
					aadd(aDest,"EXTERIOR")
				EndIf			
				aadd(aDest,Upper(SA2->A2_EST))
				aadd(aDest,SA2->A2_CEP)
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_SISEXP")))
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR")))
				aadd(aDest,SA2->A2_DDD+SA2->A2_TEL)
				If !Upper(SA2->A2_EST) == "EX"				
					aadd(aDest,VldIE(SA2->A2_INSCR))
				Else
					aadd(aDest,"")							
				EndIf
				aadd(aDest,"")//SA2->A2_SUFRAMA
				aadd(aDest,SA2->A2_EMAIL)
				aAdd(aDest, "") // Posição 17 (referente a A1_CONTRIB, sendo passado como vazio já que não existe A2_CONTRIB)
				aAdd(aDest, "")// Posição 18 (referente a A1_IENCONT, sendo passado como vazio já que não existe A2_IENCONT)
				aadd(aDest,SA2->A2_INSCRM)
				aadd(aDest,"")//Posição 20
				aadd(aDest,SA2->A2_PFISICA)//21-Identificação estrangeiro
		        
				If SF1->(FieldPos("F1_FORRET"))<>0 .And. !Empty(SF1->F1_FORRET+SF1->F1_LOJARET) .And. SF1->F1_FORRET+SF1->F1_LOJARET<>SF1->F1_FORNECE+SF1->F1_LOJA
				    dbSelectArea("SA2")
					dbSetOrder(1)
					MsSeek(xFilial("SA2")+SF1->F1_FORRET)
					
					aadd(aRetirada,SA2->A2_CGC)
					aadd(aRetirada,MyGetEnd(SA2->A2_END,"SA2")[1])
					aadd(aRetirada,ConvType(IIF(MyGetEnd(SA2->A2_END,"SA2")[2]<>0,MyGetEnd(SA2->A2_END,"SA2")[2],"SN")))
					aadd(aRetirada,MyGetEnd(SA2->A2_END,"SA2")[4])
					aadd(aRetirada,SA2->A2_BAIRRO)
					aadd(aRetirada,SA2->A2_COD_MUN)
					aadd(aRetirada,SA2->A2_MUN)
					aadd(aRetirada,Upper(SA2->A2_EST))
				EndIf
				If SF1->(FieldPos("F1_FORENT")) <> 0 .And. !Empty(SF1->F1_FORENT+SF1->F1_LOJAENT) .And. SF1->F1_FORENT+SF1->F1_LOJAENT <> SF1->F1_FORNECE+SF1->F1_LOJA
				    dbSelectArea("SA2")
					dbSetOrder(1)
					MsSeek(xFilial("SA2")+SF1->F1_FORENT+SF1->F1_LOJAENT)
					
					aadd(aEntrega,SA2->A2_CGC)
					aadd(aEntrega,MyGetEnd(SA2->A2_END,"SA2")[1])
					aadd(aEntrega,ConvType(IIF(MyGetEnd(SA2->A2_END,"SA2")[2]<>0,MyGetEnd(SA2->A2_END,"SA2")[2],"SN")))
					aadd(aEntrega,MyGetEnd(SA2->A2_END,"SA2")[4])
					aadd(aEntrega,SA2->A2_BAIRRO)
					aadd(aEntrega,SA2->A2_COD_MUN)
					aadd(aEntrega,SA2->A2_MUN)
					aadd(aEntrega,Upper(SA2->A2_EST))
					aadd(aEntrega,SA2->A2_NOME)
					aadd(aEntrega,SA2->A2_INSC)
				EndIf			
			EndIf
					
			If SF1->F1_TIPO $ "DB" 
			    dbSelectArea("SA1")
				dbSetOrder(1)
				MsSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)	
			Else
			    dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)	
			EndIf

			// Faz o destaque do IPI nos dados complementares caso seja uma venda que possuir IPI
			nSF3Recno:= SF3->(RECNO())
			nSF3Index:= SF3->(IndexOrd()) 			
			SF3->(dbSetOrder(5))
			if ( SF3->(dbSeek(xFilial("SF3")+cSerie+cNota)) ) 
				while SF3->F3_SERIE == cSerie .and. SF3->F3_NFISCAL == cNota
					If SF3->F3_VALIPI > 0 .And. SF3->F3_TIPO == "D"
						nValIPIDestac += SF3->F3_VALIPI						
					EndIf			
					SF3->(dbSkip())
				end								

				if nValIPIDestac > 0
					If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
						cMensFis += " "
					EndIf
					cMensFis += "Valor do IPI: R$ " + AllTrim(Transform(nValIPIDestac, "@ze 9,999,999,999,999.99")) + " "
				endif  
				
			EndIf	
			
	  
			SF3->(DBSETORDER(nSF3Index))
			SF3->(DBGOTO(nSF3Recno))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica Duplicatas da nota de entrada                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If !Empty(SF1->F1_DUPL)	
				dbSelectArea("SE2")
				dbSetOrder(1)	
				#IFDEF TOP
					lQuery  := .T.
					cAliasSE2 := GetNextAlias()
					BeginSql Alias cAliasSE2
						COLUMN E2_VENCORI AS DATE
						SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_VENCORI,E2_VALOR,E2_VLCRUZ,E2_ORIGEM
						FROM %Table:SE2% SE2
						WHERE
						SE2.E2_FILIAL = %xFilial:SE2% AND
						SE2.E2_PREFIXO = %Exp:SF1->F1_PREFIXO% AND
						SE2.E2_NUM = %Exp:SF1->F1_DUPL% AND
						SE2.E2_FORNECE = %Exp:SF1->F1_FORNECE% AND
						SE2.E2_LOJA = %Exp:SF1->F1_LOJA% AND
						SE2.E2_TIPO = %Exp:MVNOTAFIS% AND
						SE2.%NotDel%
						ORDER BY %Order:SE2%
					EndSql
					
				#ELSE
					MsSeek(xFilial("SE2")+SF1->F1_PREFIXO+SF1->F1_DOC)
				#ENDIF
				While !Eof() .And. xFilial("SE2") == (cAliasSE2)->E2_FILIAL .And.;
					SF1->F1_PREFIXO == (cAliasSE2)->E2_PREFIXO .And.;
					SF1->F1_DOC == (cAliasSE2)->E2_NUM
						If 	(cAliasSE2)->E2_TIPO==MVNOTAFIS .And. (cAliasSE2)->E2_FORNECE==SF1->F1_FORNECE .And. (cAliasSE2)->E2_LOJA==SF1->F1_LOJA
						aadd(aDupl,{(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_VENCORI,(cAliasSE2)->E2_VLCRUZ})				
						EndIf
					dbSelectArea(cAliasSE2)
					dbSkip()
			    EndDo
			    If lQuery
			    	dbSelectArea(cAliasSE2)
			    	dbCloseArea()
			    	dbSelectArea("SE2")
			    EndIf
			Else
				aDupl := {}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analisa os impostos de retencao                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF1->(FieldPos("F1_VALPIS"))<>0 .And. SF1->F1_VALPIS>0
				aadd(aRetido,{"PIS",0,SF1->F1_VALPIS})
			EndIf
			If SF1->(FieldPos("F1_VALCOFI"))<>0 .And. SF1->F1_VALCOFI>0
				aadd(aRetido,{"COFINS",0,SF1->F1_VALCOFI})
			EndIf
			If SF1->(FieldPos("F1_VALCSLL"))<>0 .And. SF1->F1_VALCSLL>0
				aadd(aRetido,{"CSLL",0,SF1->F1_VALCSLL})
			EndIf
			If SF1->(FieldPos("F1_INSS"))<>0 .and. SF1->F1_INSS>0
				aadd(aRetido,{"INSS",SF1->F1_BASEINS,SF1->F1_INSS})
			EndIf
			
			//RECOPI
			If SF1->(FieldPos("F1_IDRECOP")) > 0 .and. !Empty(SF1->F1_IDRECOP)
				cIdRecopi := SF1->F1_IDRECOP
			EndIf

			If !Empty(cIdRecopi)
				If AliasIndic("CE3")
					CE3->(DbSetOrder(1))
					If CE3->(DbSeek(xFilial("CE3")+Alltrim(cIdRecopi)))
						cNumRecopi:= IIf(CE3->(FieldPos("CE3_RECOPI")) > 0, Alltrim(CE3->CE3_RECOPI), "")
					EndIf
				EndIf
			EndIf
						
			dbSelectArea("SF1")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volumes / Especie Nota de Entrada                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cScan := "1"
			If (FieldPos("F1_ESPECI"+cScan))>0
				While ( !Empty(cScan) )
					cEspecie := Upper(FieldGet(FieldPos("F1_ESPECI"+cScan)))
					If !Empty(cEspecie)
						nScan := aScan(aEspVol,{|x| x[1] == cEspecie})
						If ( nScan==0 )
							aadd(aEspVol,{ cEspecie, FieldGet(FieldPos("F1_VOLUME"+cScan)) , SF1->F1_PLIQUI , SF1->F1_PBRUTO})
						Else
							aEspVol[nScan][2] += FieldGet(FieldPos("F1_VOLUME"+cScan))
						EndIf
					EndIf
					cScan := Soma1(cScan,1)
					If ( FieldPos("F1_ESPECI"+cScan) == 0 )
						cScan := ""
					EndIf
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona transportador                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FieldPos("F1_TRANSP") > 0 .And. !Empty(SF1->F1_TRANSP)
				dbSelectArea("SA4")
				dbSetOrder(1)
				MsSeek(xFilial("SA4")+SF1->F1_TRANSP)
				
				aadd(aTransp,AllTrim(SA4->A4_CGC))
				aadd(aTransp,SA4->A4_NOME)
				aadd(aTransp,VldIE(SA4->A4_INSEST))
				aadd(aTransp,SA4->A4_END)
				aadd(aTransp,SA4->A4_MUN)
				aadd(aTransp,Upper(SA4->A4_EST)	)
				aadd(aTransp,SA4->A4_EMAIL	)
					If !Empty(SF1->F1_PLACA)
						aadd(aVeiculo,SF1->F1_PLACA)
						aadd(aVeiculo,SA4->A4_EST)
						aadd(aVeiculo,"")//RNTC
					EndIf		
			EndIf
                   
			If SD1->(FieldPos("D1_TESACLA")) > 0
				cField := "%,D1_TESACLA%" 
			Else
				cField := "%%"
			EndIf
			
			If SD1->(FieldPos("D1_ICMSDIF")) > 0
				cField := "%,D1_ICMSDIF%"
			Else
				cField := "%%"
			EndIf
			
			dbSelectArea("SD1")
			dbSetOrder(1)	
			#IFDEF TOP
				lQuery  := .T.
				cAliasSD1 := GetNextAlias()
				BeginSql Alias cAliasSD1			
						SELECT D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM,D1_TES,D1_TIPO,D1_NFORI,D1_SERIORI,D1_ITEMORI,
						D1_CF,D1_QUANT,D1_TOTAL,D1_VALDESC,D1_VALFRE,D1_SEGURO,D1_DESPESA,D1_CODISS,D1_VALISS,D1_VALIPI,D1_ICMSRET,
						D1_VUNIT,D1_CLASFIS,D1_VALICM,D1_TIPO_NF,D1_PEDIDO,D1_ITEMPC,D1_VALIMP5,D1_VALIMP6,D1_BASEIRR,D1_VALIRR,D1_LOTECTL,
						D1_NUMLOTE,D1_CUSTO,D1_ORIGLAN,D1_DESCICM,D1_II,D1_FORMUL,D1_VALPS3,D1_ORIGLAN,D1_VALCF3,D1_TESACLA  %Exp:cField%
						FROM %Table:SD1% SD1
						WHERE
						SD1.D1_FILIAL  = %xFilial:SD1% AND
						SD1.D1_SERIE   = %Exp:SF1->F1_SERIE% AND
						SD1.D1_DOC     = %Exp:SF1->F1_DOC% AND
						SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE% AND
						SD1.D1_LOJA    = %Exp:SF1->F1_LOJA% AND
						SD1.D1_FORMUL  = 'S' AND
						SD1.%NotDel%
						ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM,D1_COD
				EndSql

			#ELSE
				MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			#ENDIF
			While !Eof() .And. xFilial("SD1") == (cAliasSD1)->D1_FILIAL .And.;
				SF1->F1_SERIE == (cAliasSD1)->D1_SERIE .And.;
				SF1->F1_DOC == (cAliasSD1)->D1_DOC .And.;
				SF1->F1_FORNECE == (cAliasSD1)->D1_FORNECE .And.;
				SF1->F1_LOJA ==  (cAliasSD1)->D1_LOJA
				
				If SF1->(FieldPos("F1_MENNOTA"))>0
					If !AllTrim(SF1->F1_MENNOTA) $ cMensCli
						If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
							cMensCli += " "
						EndIf
						//cMensCli += AllTrim(SF1->F1_MENNOTA)

						//** BRENO **//
						cMensCli += AllTrim(SF1->F1_MENNOTA)+" "+AllTrim(SF1->F1_MENNOT2)+" "+AllTrim(SF1->F1_MENNOT3)+Chr(13)+Chr(10)+cProjetos
						//**********//
					EndIf
				EndIf
				
				If SF1->(FieldPos("F1_MENPAD"))>0
					If !Empty(SF1->F1_MENPAD) .And. !AllTrim(FORMULA(SF1->F1_MENPAD)) $ cMensFis
						If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
							cMensFis += " "
						EndIf
						cMensFis += AllTrim(FORMULA(SF1->F1_MENPAD))
					EndIf
				EndIf	
						
				//Tratamento para nota sobre Cupom 
				DbSelectArea("SFT")
			    DbSetOrder(1)
			    IF SFT->(DbSeek(xFilial("SFT")+"E"+(cAliasSD1)->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA)))
					IF AllTrim(SFT->FT_OBSERV) <> " " .AND.(cAliasSD1)->D1_ORIGLAN=="LO"
						If !Alltrim(SFT->FT_OBSERV) $ Alltrim(cMensCli) 
							If "DEVOLUCAO N.F." $ Upper(SFT->FT_OBSERV) 
								cMensCli +=" " + StrTran(AllTrim(SFT->FT_OBSERV),"N.F.","C.F.")
							Else
								cMensCli +=" " + AllTrim(SFT->FT_OBSERV)
							EndIf
						EndIf       
           			EndIf
	        	EndIF			
	
				dbSelectArea("SF4")
				dbSetOrder(1)
				If SF1->(FieldPos("F1_STATUS"))>0 .And.SD1->(FieldPos("D1_TESACLA"))>0 .And. SF1->F1_STATUS='C' 
					MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TESACLA)
				Else 
					MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES)
				EndIf
				
				cChaveD1 := "E" + ( cAliasSD1 )->( D1_SERIE + D1_DOC + D1_FORNECE + D1_LOJA + D1_ITEM )
				SFT->( dbSetOrder( 1 ) )
				//utiliza a funcao SpedNatOper ( SPEDXFUN ) que possui o tratamento para a natureza da operacao/prestacao
				if FindFunction( "SpedNatOper" ) .And. SFT->( MsSeek( xFilial( "SFT" ) + cChaveD1 ) )
				
					cNatOper := SpedNatOper( nil , lNatOper , "SFT" , "SF4" , .T. )[ 2 ]
				
				else
					If !lNatOper
						If Empty(cNatOper)
							cNatOper := Alltrim(SF4->F4_TEXTO)
						Else
							cNatOper += Iif(!Alltrim(SF4->F4_TEXTO)$cNatOper,"/ " + SF4->F4_TEXTO,"")
						Endif 
					Else
						dbSelectArea("SX5")
						dbSetOrder(1)
						dbSeek(xFilial("SX5")+"13"+SF4->F4_CF)
						If Empty(cNatOper)
							cNatOper := AllTrim(SubStr(SX5->X5_DESCRI,1,55))
						Else
							cNatOper += Iif(!AllTrim(SubStr(SX5->X5_DESCRI,1,55)) $ cNatOper, "/ " + AllTrim(SubStr(SX5->X5_DESCRI,1,55)), "")
		    			EndIf
		    		EndIf
		    	endif
	    		
	    		If SF4->(FieldPos("F4_BASEICM"))>0
	    			nRedBC := IiF(SF4->F4_BASEICM>0,IiF(SF4->F4_BASEICM == 100,SF4->F4_BASEICM,IiF(SF4->F4_BASEICM > 100,0,100-SF4->F4_BASEICM)),SF4->F4_BASEICM)
	    			cCST   := SF4->F4_SITTRIB 
	    		Endif
	    		
	    		//Operação com diferimento parcial de 66,66% do RICMS/PR para importação
	    		lDifParc := .F.
	    		If (SF4->(FieldPos("F4_PICMDIF"))>0 .And. "66.66" $ Alltrim(Str(SF4->F4_PICMDIF)) ) ;
	    			.And. (SF4->(FieldPos("F4_ICMSDIF"))>0 .And. SF4->F4_ICMSDIF <> "2") ;
	    			.And. (SubStr(SM0->M0_CODMUN,1,2)=='41' .And. SubStr((cAliasSD1)->D1_CF,1,1) == '3')
	    			lDifParc := .T.
	    		EndIf
	    		
	    		If ((cAliasSD1)->D1_VALICM > 0 .And. (cAliasSD1)->D1_ICMSDIF > 0 ) .And. lDifParc
	    			nValIcmDev += (cAliasSD1)->D1_VALICM   //Valor total do ICMS devido
	    			nValIcmDif += (cAliasSD1)->D1_ICMSDIF  //Valor total do ICMS diferido 
	    		EndIf
	    		
	    		//Tratamento para o campo F4_FORMULA,onde atraves do parametro MV_NFEMSF4 se determina se o conteudo da formula devera compor a mensagem do cliente(="C") ou do fisco(="F").
				If (cAliasSD1)->D1_FORMUL=="S"
					If !Empty(SF4->F4_FORMULA) .And. Formula(SF4->F4_FORMULA) <> NIL .And. ( ( cMVNFEMSF4=="C" .And. !AllTrim(Formula(SF4->F4_FORMULA)) $ cMensCli ) .Or. (cMVNFEMSF4=="F" .And. !AllTrim(Formula(SF4->F4_FORMULA))$cMensFis) )
	
						If cMVNFEMSF4=="C"
							If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
								cMensCli += " "
							EndIf
							cMensCli	+=	SF4->(Formula(F4_FORMULA))
						ElseIf cMVNFEMSF4=="F"
							If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
								cMensFis += " "
							EndIf
							cMensFis	+=	SF4->(Formula(F4_FORMULA))
						EndIf
					EndIf
				EndIf
	   			
				//Verifica se existe Template DCL
      			IF (ExistTemplate("PROCMSG"))
      				aMens := ExecTemplate("PROCMSG",.f.,.f.,{cAliasSD1})      										 		      					
						For nA:=1 to len(aMens)
						    If aMens[nA][1] == "V" .Or. (aMens[nA][1] == "T" .And. Ascan(aMensAux,aMens[nA][2])==0)
								AADD(aMensAux,aMens[nA][2])
							Endif	
						Next    					
     			Endif 
				/*Tratamento para NF DE AJUSTE chamado THYZ13 -  PORTARIA N° 163/2007 Artigo 18-B-2 item 4a da SEFAZ-MT */
				
				if SF4->F4_AJUSTE =="S" .and. aDest[1] == SM0->M0_CGC .and. (cAliasSD1)->(D1_TIPO) == "D" .and. (cAliasSD1)->D1_FORMUL == "S"
				
					aAreaSF2  	:= SF2->(GetArea())
					aAreaSA1	:= SA1->(GetArea())			
					aAreaSAY	:= SAY->(GetArea())
									
					dbSelectArea("SF2")
					dbSetOrder(1)
					if SF2->(DbSeek(xFilial("SF2")+(cAliasSD1)->(D1_NFORI)+(cAliasSD1)->(D1_SERIORI))) 
						dbSelectArea("SA1")
						dbSetOrder(1)						
						if SA1->(DbSeek(xFilial("SA1")+(SF2->F2_CLIENTE)+(SF2->F2_LOJA)))
							cMensCli += iIf(!Empty(SA1->A1_CGC),'CNPJ: '+Rtrim(SA1->A1_CGC) ,'')
							cMensCli += iIf (!Empty(SA1->A1_NOME),' NOME: '+Rtrim(SA1->A1_NOME) ,'')
							cMensCli += iIf (!Empty(SA1->A1_END),' ENDEREÇO: '+Rtrim(SA1->A1_END) ,'')
							cMensCli += iIf (!Empty(SA1->A1_BAIRRO),' BAIRRO: '+Rtrim(SA1->A1_BAIRRO) ,'')
							cMensCli += iIf (!Empty(SA1->A1_EST),' UF: '+Rtrim(SA1->A1_EST) ,'')
							if !Empty(SA1->A1_PAIS)
								dbSelectArea("SAY")
								dbSetOrder(1)									
								if SYA->(DbSeek(xFilial("SYA")+(SA1->A1_PAIS)))
									cMensCli += iIf (!Empty(SYA->YA_DESCR),' PAIS: '+Rtrim(SYA->YA_DESCR),'')
								endif
							endif
							
						endif
					aAdd( aNfVinc, { SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC,SA1->A1_CGC,SF2->F2_EST,SF2->F2_ESPECIE, SF2->F2_CHVNFE  } )
															
					endif				
					RestArea(aAreaSF2)
					RestArea(aAreaSA1)				
					RestArea(aAreaSAY)				
				endif     			
     			
     			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica as notas vinculadas                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If !Empty((cAliasSD1)->D1_NFORI)
					
					aOldReg  := SD1->(GetArea())
					
					// Realiza o backup do order e recno da SF1
					nOrderSF1	:= SF1->( indexOrd() )
					nRecnoSF1	:= SF1->( recno() )
					
					dbSelectArea("SD1")
					dbSetOrder(1)
					If ((cAliasSD1)->D1_TIPO) $ "NCI" // Tratamento para notas de entrada normais e complementares buscar o fornecedor original corretamente
						cSeekD1 := (cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEMORI
					Else
						cSeekD1 := (cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI
					EndIf
					//Alterado a chave de busca completa devido ao procedimento de complemento de notas de devolucao de VENDA.						
					//If MsSeek(xFilial("SD1")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI)+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEMORI)
					If MsSeek(xFilial("SD1")+cSeekD1)
						
						SF1->( dbSetOrder( 1 ) )
						SF1->( msSeek( xFilial( "SF1" ) + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_TIPO ) )
						lSeekOk := .T.
						If SD1->D1_TIPO $ "DB"
							dbSelectArea("SA1")
							dbSetOrder(1)
							MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
						Else
							dbSelectArea("SA2")
							dbSetOrder(1)
							MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
						EndIf
				        lRural := ( AllTrim(SF1->F1_ESPECIE) == "NFP" .Or. AllTrim(SF1->F1_ESPECIE) == "NFA" )
						
					Else
						lSeekOk := .F.
					EndIf

					If !(cAliasSD1)->D1_TIPO $ "DBN" .Or. lRural
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Obtem os dados de nota fiscal de produtor rural referenciada                                  ³
						//³Temos duas situacoes:                                                                         ³
						//³A NF de saída é uma devolucao, onde a NF original pode ser ou nao uma devolução.              ³
						//³1) Quando a NF original for uma devolucao, devemos utilizar o remetente do documento fiscal,  ³
						//³    podendo ser o sigamat.emp no caso de formulario proprio ou o proprio SA1 no caso de nf de ³
						//³    entrada com formulario proprio igual a NAO.                                               ³
						//³2) Quando a NF original NAO for uma devolucao, neste caso tambem pode variar conforme o       ³
						//³    formulario proprio igual a SIM ou NAO. No caso do NAO, os dados a serem obtidos retornara ³
						//³    da tabela SA2.                                                                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( AllTrim(SF1->F1_ESPECIE)== "NFP" .Or. AllTrim(SF1->F1_ESPECIE)== "NFA" ) .and. lSeekOk
							//para nota de entrada tipo devolucao o emitente eh o cliente ou o sigamat no caso de formulario proprio=sim
							If SD1->D1_TIPO$"DB"
								aadd(aNfVincRur,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,SF1->F1_ESPECIE,;
									IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA1->A1_CGC),; 
									IIF(SD1->D1_FORMUL=="S",SM0->M0_ESTENT,SA1->A1_EST),; 
									IIF(SD1->D1_FORMUL=="S",SM0->M0_INSC,SA1->A1_INSCR)})
							
							//para nota de entrada normal o emitente eh o fornecedor ou o sigamat no caso de formulario proprio=sim
							Else
								aadd(aNfVincRur,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,SF1->F1_ESPECIE,;
									IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA2->A2_CGC),; 
									IIF(SD1->D1_FORMUL=="S",SM0->M0_ESTENT,SA2->A2_EST),; 
									IIF(SD1->D1_FORMUL=="S",SM0->M0_INSC,SA2->A2_INSCR)})
							EndIf
						Endif
						// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
						//³       Informacoes do cupom fiscal referenciado              |
				    	//|                                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
						If AllTrim(SF1->F1_ESPECIE)=="CF" .and. lSeekOk
							aadd(aRefECF,{SD1->D1_DOC,SF1->F1_ESPECIE})
						Endif
						
						// Outros documentos referenciados
						if !lRural .and. lSeekOk
							
							if cChave <> dToS( SD1->D1_EMISSAO ) + SD1->D1_SERIE + SD1->D1_DOC + iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ) + SM0->M0_ESTCOB + SF1->F1_ESPECIE + SF1->F1_CHVNFE;
								.or. ( cAliasSD2 )->D2_ITEM <> cItemOr
								
								aAdd( aNfVinc, { SD1->D1_EMISSAO, SD1->D1_SERIE, SD1->D1_DOC, iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ), SM0->M0_ESTCOB, SF1->F1_ESPECIE, SF1->F1_CHVNFE,SD1->D1_TOTAL } )
								cChave	:= dToS( SD1->D1_EMISSAO ) + SD1->D1_SERIE + SD1->D1_DOC + iIf( SD1->D1_TIPO $ "DB", iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA1->A1_CGC ), iIf( SD1->D1_FORMUL == "S", SM0->M0_CGC, SA2->A2_CGC ) ) + SM0->M0_ESTCOB + SF1->F1_ESPECIE + SF1->F1_CHVNFE
						
								//Busca NFP vinculada, da nota Original.
								aNfVincRur :=	RetNfpVinc(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA)
						
						    endIf
						    
					    	cItemOr	:= ( cAliasSD1 )->D1_ITEM
					    	
					    endIf
					
					Else
						dbSelectArea("SD2")
						dbSetOrder(3)
						IF (cAliasSD1)->D1_ORIGLAN =="LO"
						    cMsSeek	:=(xFilial("SD2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI)
						ELSE 
							if !(SF4->F4_AJUSTE=='S' .and. ((cAliasSD1)->D1_TIPO == "D"))
					   			cMsSeek	:=(xFilial("SD2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEMORI)
					   		else  /* Quando for uma devolução de Ajuste não tem necessidade de informar os outros campo para posicionar na SD2. chamado TIANDL*/
					   			cMsSeek	:=(xFilial("SD2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI)
					   		endif       
						EndIF                                                                          
						    
						IF MsSeek (cMsSeek)
							dbSelectArea("SF2")
							dbSetOrder(1)
							MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
							If !SD2->D2_TIPO $ "DB"
								dbSelectArea("SA1")
								dbSetOrder(1)
								MsSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
								
								//Tratamento para os campos do Loja(cNfRefcup = Numero da Nota de complemento sobre cupom /cSerRefcup = Serie da Nota de complemento sobre cupom)
								if SD2->(FieldPos("D2_NFCUP")) <> 0
									cNfRefcup := SD2->D2_NFCUP
								else
									cNfRefcup := ""
								endif
								cSerRefcup := SD2->D2_SERIORI
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								MsSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
							EndIf
							// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
							//³       Informacoes do cupom fiscal referenciado              |
					    	//|                                                             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
							If Alltrim(SF2->F2_ESPECIE)=="CF" .OR. (LjAnalisaLeg(18)[1] .AND. "ECF"$SF2->F2_ESPECIE)
								aadd( aRefECF,{ SD2->D2_DOC,SF2->F2_ESPECIE,SF2->F2_PDV } )
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Outros documentos referenciados³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
							If cChave <> Dtos(SF2->F2_EMISSAO)+SD2->D2_SERIE+SD2->D2_DOC+SM0->M0_CGC+SM0->M0_ESTCOB+SF2->F2_ESPECIE+SF2->F2_CHVNFE							
								aadd(aNfVinc,{SD2->D2_EMISSAO,SD2->D2_SERIE,SD2->D2_DOC,SM0->M0_CGC,SM0->M0_ESTCOB,SF2->F2_ESPECIE,SF2->F2_CHVNFE})  
								
								cChave := Dtos(SF2->F2_EMISSAO)+SD2->D2_SERIE+SD2->D2_DOC+SM0->M0_CGC+SM0->M0_ESTCOB+SF2->F2_ESPECIE+SF2->F2_CHVNFE							
							EndIf							
						ElseIf (cAliasSD1)->D1_TIPO == "N" .And. (cAliasSD1)->D1_FORMUL = "S"                                                  						
							dbSelectArea("SFT")
					   		dbSetOrder(6)
					   		If MsSeek(xFilial("SFT")+"E"+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI)
					   			If !Empty(SFT->FT_DTCANC)
						   			dbSelectArea("SF3")
							   		dbSetOrder(4) 
							   		MsSeek(xFilial("SF3")+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_NFISCAL+SFT->FT_SERIE)
							   		If Empty(SF3->F3_CODRSEF) .Or. SF3->F3_CODRSEF == "101"
						   				If cChave <> dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA2->A2_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE;
						   					.or. ( cAliasSD1 )->D1_ITEM <> cItemOr
						   					
											aAdd( aNfVinc, { SF3->F3_EMISSAO, SF3->F3_SERIE, SF3->F3_NFISCAL, SA2->A2_CGC, SM0->M0_ESTCOB, SF3->F3_ESPECIE, SF3->F3_CHVNFE } )
											cChave	:= dToS( SF3->F3_EMISSAO ) + SF3->F3_SERIE + SF3->F3_NFISCAL + SA2->A2_CGC + SM0->M0_ESTCOB + SF3->F3_ESPECIE + SF3->F3_CHVNFE
											
										endIf
										cItemOr	:= ( cAliasSD1 )->D1_ITEM
									EndIf
								EndIf
							EndIf				
						EndIf
					EndIf
					
					RestArea(aOldReg)
					
					// Restaura a ordem e recno da SF1
					SF1->( dbSetOrder( nOrderSF1 ) )
					SF1->( dbGoTo( nRecnoSF1 ) )
					
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica as notas vinculadas na tabela SF8 - Amarracao NF Orig x NF Imp/Fre     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					If Alltrim( (cAliasSD1)->D1_ORIGLAN ) $ "D-DP-FR" .And. Alltrim( (cAliasSD1)->D1_TIPO ) == "C"
						dbSelectArea("SF8")
						dbSetOrder(3)
						If dbSeek(cChavesf8:=xFilial("SF8")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
							aAreaSD1 := SD1->(GetArea())
							aAreaSF1 := SF1->(GetArea())
							Do While cChavesf8 == SF8->(F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN)
								dbSelectArea("SD1")
								dbSetOrder(1)  
								If dbSeek(xFilial("SD1")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA)
									dbSelectArea("SF1")
									dbSetOrder(1)
									If dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
										AADD(aNfVinc,{SF1->F1_EMISSAO,SF1->F1_SERIE,SF1->F1_DOC,SM0->M0_CGC,SM0->M0_ESTCOB,SF1->F1_ESPECIE,SF1->F1_CHVNFE})
									Endif
								Endif
								SF8->(DbSkip())
							EndDo
							RestArea(aAreaSD1)
							RestArea(aAreaSF1)
						Endif
					Endif
				EndIf    
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtem os dados do produto                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD)
				//Veiculos Novos
				If AliasIndic("CD9")			
					dbSelectArea("CD9")
					dbSetOrder(1)
					MsSeek(xFilial("CD9")+cChaveD1)
				EndIf			
				//Combustivel
				If AliasIndic("CD6")
					dbSelectArea("CD6")
					dbSetOrder(1)
					MsSeek(xFilial("CD6")+cChaveD1)
				EndIf
				//Medicamentos
				If AliasIndic("CD7")
					dbSelectArea("CD7")
					dbSetOrder(1)
					MsSeek(xFilial("CD7")+cChaveD1)
				EndIf
	            // Armas de Fogo
	            If AliasIndic("CD8")
					dbSelectArea("CD8")
					dbSetOrder(1)
					MsSeek(xFilial("CD8")+cChaveD1)
				EndIf
				//Anfavea
				If lAnfavea
					dbSelectArea("CDR")
					dbSetOrder(1) 
					MsSeek(xFilial("CDR")+"S"+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)

					dbSelectArea("CDS")
					dbSetOrder(1) 
					MsSeek(xFilial("CDS")+"S"+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM+(cAliasSD1)->D1_COD)
				EndIf   
				
				dbSelectArea("SB5")
				dbSetOrder(1)
				If MsSeek(xFilial("SB5")+(cAliasSD1)->D1_COD)
					If SB5->(FieldPos("B5_DESCNFE")) > 0 .And. !Empty(SB5->B5_DESCNFE)
						cInfAdic	:= Alltrim(SB5->B5_DESCNFE)
					Else	
						cInfAdic	:= ""				
					EndIF
				Else
					cInfAdic	:= ""		
				EndIF 
				
			 	If DY3->(FieldPos("DY3_INFCPL"))>0	 					
					dbSelectArea("DY3")
			   		dbSetOrder(1)
			   		If MsSeek(xFilial("DY3")+ (cAliasSB5)->B5_ONU)
						If DY3->(FieldPos("DY3_DESCRI")) > 0 .And. !Empty(DY3->DY3_DESCRI) .and. DY3->DY3_INFCPL =="S"
							If !cMensONU $ DY3->DY3_ONU
				     	   		cMensONU	:= cMensONU +'  ONU '+Alltrim(DY3->DY3_ONU)+' '+Alltrim(DY3->DY3_DESCRI)+'   '   
				    		EndIF
			   			EndIF  		
					EndIF 
				EndIF 
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Conforme Decreto RICM, N 43.080/2002 valido somente em MG deduzir o 	³ 
				//³	imposto dispensado na operação				  			                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SFT")
				dbSetOrder(3)
				MsSeek(xFilial("SFT")+"E"+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC) 
				If SFT->(FieldPos("FT_DS43080")) <> 0 .And. SFT->FT_DS43080 > 0 .And. IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT)) == "MG"
					nDescRed := SFT->FT_DS43080 
					nDesTotal+= nDescRed
				EndIF	  
				
				If	SD1->(FieldPos("D1_DESCICM"))<>0
					nDescIcm := ( IIF(SF4->F4_AGREG == "D",(cAliasSD1)->D1_DESCICM,0) )
					If cVerAmb >= "3.10" .and. SF4->F4_AGREG == "D" .and.  !Empty(SF4->F4_MOTICMS) .and. Empty(SF4->F4_CSOSN)
						nDescIcm:=0
					EndIF						
			   EndIF
									
				
				//Tratamento para o Tipo de Frete no documento de entrada
				If SF1->(FieldPos("F1_TPFRETE")) > 0 .And. !Empty( SF1->F1_TPFRETE )					
					If SF1->F1_TPFRETE=="C"
						cModFrete := "0"
					ElseIf SF1->F1_TPFRETE=="F"
					 	cModFrete := "1"
					ElseIf SF1->F1_TPFRETE=="T"
					 	cModFrete := "2"
					ElseIf SF1->F1_TPFRETE=="S"
					 	cModFrete := "9"
					EndIf								
				Else
					cModFrete := IIF(SF1->F1_FRETE>0,"0","1")
				EndIf
				aAdd(aInfoItem,{(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,(cAliasSD1)->D1_TES,(cAliasSD1)->D1_ITEM})
						
						
				//Tratamento para que o valor de ICMS ST venha a compor o valor da tag vOutros quando for uma nota de Devolução, impedindo que seja gerada a rejeição 610.
		       nIcmsST := 0
		       If (!lIcmSTDev .And. (cAliasSD1)->D1_TIPO == "D" .And. SubStr((cAliasSD1)->D1_CLASFIS,2,2) $ '10#30#70#90') .Or. (Alltrim((cAliasSD1)->D1_CF) $ cMVCFOPREM) .Or. (!lIcmSTDev .And. lComplDev .And. (cAliasSD1)->D1_TIPO == "I" )
		       nIcmsST := (cAliasSD1)->D1_ICMSRET
		       EndIf   		
						
						
							
				aadd(aProd,	{Len(aProd)+1,;  
					(cAliasSD1)->D1_COD,;
					IIf(Val(SB1->B1_CODBAR)==0,"",StrZero(Val(SB1->B1_CODBAR),Len(Alltrim(SB1->B1_CODBAR)),0)),;
					SB1->B1_DESC,;
					SB1->B1_POSIPI,;
					SB1->B1_EX_NCM,;
					(cAliasSD1)->D1_CF,;
					SB1->B1_UM,;
					(cAliasSD1)->D1_QUANT,;
					IIF(!(cAliasSD1)->D1_TIPO$"IP",IIF(!(SubStr((cAliasSD1)->D1_CF,1,1) $ "3"),(cAliasSD1)->D1_TOTAL,(cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_II),0),;
					IIF(Empty(SB5->B5_UMDIPI),SB1->B1_UM,SB5->B5_UMDIPI),;
					IIF(Empty(SB5->B5_CONVDIP),(cAliasSD1)->D1_QUANT,SB5->B5_CONVDIP*(cAliasSD1)->D1_QUANT),;
					(cAliasSD1)->D1_VALFRE,;
					(cAliasSD1)->D1_SEGURO,;
					((cAliasSD1)->D1_VALDESC + nDescRed + nDescIcm),;
				   	IIF(!(cAliasSD1)->D1_TIPO$"IP",IIF(!(SubStr((cAliasSD1)->D1_CF,1,1) $ "3"),(cAliasSD1)->D1_VUNIT,((cAliasSD1)->D1_VUNIT)-((cAliasSD1)->D1_II/(cAliasSD1)->D1_QUANT)),0),;
				   	IIF(SB1->(FieldPos("B1_CODSIMP"))<>0,SB1->B1_CODSIMP,""),; //codigo ANP do combustivel
					IIF(SB1->(FieldPos("B1_CODIF"))<>0,SB1->B1_CODIF,""),; //CODIF  
					(cAliasSD1)->D1_LOTECTL,;//Controle de Lote
					(cAliasSD1)->D1_NUMLOTE,;//Numero do Lote 
					IIF(((cAliasSD1)->D1_TIPO == "D" .And. !lIpiDev .And. cTipo == "1") .Or. lConsig .Or. (Alltrim((cAliasSD1)->D1_CF) $ cMVCFOPREM ) .or. ((cAliasSD1)->D1_TIPO == "B" .and. lIpiBenef) .or. ((cAliasSD1)->D1_TIPO=="P" .And. lComplDev .And. !lIpiDev) ,(cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_VALPS3 + (cAliasSD1)->D1_VALCF3 + (cAliasSD1)->D1_VALIPI + nIcmsST, (cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_VALPS3 + (cAliasSD2)->D2_VALCF3 + nIcmsST),;//Outras despesas + PISST + COFINSST  (Inclusão do valor de PIS ST e COFINS ST na tag vOutros - NT 2011/004).E devolução com IPI. (Nota de compl.Ipi de uma devolução de compra(MV_IPIDEV=F) leva o IPI em voutros
					nRedBC,;//% Redução da Base de Cálculo
					cCST,;//Cód. Situação Tributária
					IIF(SF4->F4_AGREG='N' .Or. (SF4->F4_ISS='S' .And. SF4->F4_ICM='N'),"0","1"),;// Tipo de agregação de valor ao total do documento
					cInfAdic,;//Informacoes adicionais do produto(B5_DESCNFE)
					0,;
					(cAliasSD1)->D1_TES,;
					"",;
					0,;
					0,;  	// [30] Da posição 28 a 30 tratamento realizado apenas para documento de saída por este motivo campos estão zerados e vazios.
					0,;		// [31] Desconto Zona Franca PIS
					0,;		// [32] Desconto Zona Franca CONFINS
					0,;		// [33] Percentual de ICMS
					IIF(SB1->(FieldPos("B1_TRIBMUN"))<>0,RetFldProd(SB1->B1_COD,"B1_TRIBMUN"),""),;		// [34]
					0,;		// [35]
					0,;		// [36]
					0,;		// [37]
					})
					        
				aadd(aCST,{IIF(!Empty((cAliasSD1)->D1_CLASFIS),SubStr((cAliasSD1)->D1_CLASFIS,2,2),'50'),;
					IIF(!Empty((cAliasSD1)->D1_CLASFIS),SubStr((cAliasSD1)->D1_CLASFIS,1,1),'0')})
				aadd(aICMS,{})
				aadd(aIPI,{})
				aadd(aICMSST,{})
				aadd(aPIS,{})
				aadd(aPISST,{})
				aadd(aCOFINS,{})
				aadd(aCOFINSST,{})
				aadd(aISSQN,{})
				aadd(aExp,{})		
				aadd(aPisAlqZ,{})
				aadd(aCofAlqZ,{})
				aadd(aCsosn,{})
				aadd(aICMSZFM,{})
				aadd(aFCI,{})
				DbSelectArea("SC7")
				DbSetOrder(1)
				If MsSeek(xFilial("SC7")+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEM)
					aadd(aPedCom,{SC7->C7_NUM,SC7->C7_ITEM})
				Else
					aadd(aPedCom,{})
				Endif

				// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
				//³       Informacoes do cupom fiscal referenciado              |
		    	//|                                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
				DbSelectArea("SF2")
				DbSetOrder(1)
				If MsSeek(xFilial("SF2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI)
					If AllTrim(SF2->F2_ESPECIE)=="CF"
						aadd(aRefECF,{SF2->F2_DOC,SF2->F2_ESPECIE,""})
					Endif
				EndIf

				If lEasy  .And. !Empty((cAliasSD1)->D1_TIPO_NF)

					cTipoNF 	:= (cAliasSD1)->D1_TIPO
					cDocEnt 	:= (cAliasSD1)->D1_DOC
					cSerEnt 	:= (cAliasSD1)->D1_SERIE
					cFornece	:= (cAliasSD1)->D1_FORNECE
					cLojaEnt	:= (cAliasSD1)->D1_LOJA
					cTipoNFEnt	:= (cAliasSD1)->D1_TIPO_NF
					cPedido 	:= (cAliasSD1)->D1_PEDIDO
					cItemPC 	:= (cAliasSD1)->D1_ITEMPC
					cNFOri  	:= (cAliasSD1)->D1_NFORI
					cSerOri 	:= (cAliasSD1)->D1_SERIORI
					cItemOri	:= (cAliasSD1)->D1_ITEMORI
					cProd   	:= (cAliasSD1)->D1_COD

					If !cTipoNF$"IPC" .And. cTipoNFEnt <> "6"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tratamento para TAG Importação quando existe a integração com a EIC  (Se a nota for primeira ou unica)|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aadd(aDI,(GetNFEIMP(.F.,cDocEnt,cSerEnt,cFornece,cLojaEnt,cTipoNFEnt,cPedido,cItemPC)))
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tratamento para TAG Importação quando existe a integração com a EIC  (Se a nota for complementar)     |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aadd(aDI,(GetNFEIMP(.F.,cNFOri,cSerOri,cFornece,cLojaEnt,cTipoNFEnt, ,cItemOri)))
					EndIf
					aAdi := aDI
				// Se não o parâmetro de integração entre o SIGAEIC e o SIGAFAT estiver desabilitado,
				//   procura as informações da importação da tabela CD5 (complemento de importação).
				ElseIf !lEasy
					DbSelectArea("CD5")
					DbSetOrder(4)
					// Procura algum registro na CD5 referente a nota que foi complementada
					If MsSeek(xFilial("CD5")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM)
							aAdd(aDI,{;
								{"I04","NCM",SB1->B1_POSIPI},;				//1
								{"I15","vFrete",0},;							//2
								{"I16","vSeg",0},;							//3
								{"I19","nDI",CD5->CD5_NDI},;				//4
								{"I20","dDI",CD5->CD5_DTDI},;				//5
								{"I21","xLocDesemb",CD5->CD5_LOCDES},;		//6
								{"I22","UFDesemb",CD5->CD5_UFDES},;		//7
								{"I23","dDesemb",CD5->CD5_DTDES},;			//8
								{"I24","cExportador",CD5->CD5_CODEXP},;	//9
								{"I26","nAdicao",Val(CD5->CD5_NADIC)},;	//10
								{"I27","nSeqAdi",Val(CD5->CD5_SQADIC)},;	//11
								{"I28","cFabricante",CD5->CD5_CODFAB},;	//12
								{"I29","vDescDI",0},;						//13
								{"N14","pRedBC",0},;							//14
								{"O11","qUnid",0},;							//15
								{"O12","vUnid",0},;							//16
								{"P02","vBC",CD5->CD5_BCIMP},;				//17
								{"P03","vDespAdu",CD5->CD5_DSPAD},;			//18
								{"P04","vII",(cAliasSD1)->D1_II},;			//19
								{"P05","vIOF",CD5->CD5_VLRIOF},;			//20
								{"Q10","qBCProd",0},;						//21
								{"Q11","vAliqProd",0},;						//22
								{"S09","qBCProd",0},;						//23
								{"S10","vAliqProd",0},;						//24								
								{"X04","CNPJ",0},;							//25
								{"X06","xNome",0},;							//26
								{"X07","IE",0},;								//27
								{"X08","xEnder",0},;							//28
								{"X09","xMun",0},;							//29
								{"X10","UF",0},;								//30
								{"XXX","Emaildesp",0},;						//31								
								{"HOU","house",0},;							//32
								{"DES","cDesp",0},;							//33
								{"129A","nDraw",IIf(CD5->(FieldPos("CD5_ACDRAW")) > 0,CD5->CD5_ACDRAW,"")},;			//34
								{"105a","NVE",0},;							//35
								{"I23a","tpViaTransp",IIf(CD5->(FieldPos("CD5_VTRANS")) > 0,CD5->CD5_VTRANS,"")},;	//36
								{"I23b","vAFRMM",IIf(CD5->(FieldPos("CD5_VAFRMM")) > 0,CD5->CD5_VAFRMM,"")},;			//37
								{"I23c","tpIntermedio",IIf(CD5->(FieldPos("CD5_INTERM")) > 0,CD5->CD5_INTERM,"")},;	//38
								{"I23d","CNPJ",IIf(CD5->(FieldPos("CD5_CNPJAE")) > 0,CD5->CD5_CNPJAE,"")},;			//39
								{"I23e","UFTerceiro",IIf(CD5->(FieldPos("CD5_UFTERC")) > 0,CD5->CD5_UFTERC,"")}})	//40
						// O array aAdi deve ser identico ao aDI para futuro tratamento neste fonte
						aAdi := aDI
					// Caso nenhum registro de complemento de importação para essa nota exista, coloca os arrays em branco
					Else
						aadd(aAdi,{})
						aadd(aDi,{})											
					EndIf
				Else
					aadd(aAdi,{})
					aadd(aDi,{})
				EndIf

				If (cAliasSD1)->D1_BASEIRR > 0  .And. (cAliasSD1)->D1_VALIRR > 0 
					nBaseIrrf += (cAliasSD1)->D1_BASEIRR
					nValIrrf  += (cAliasSD1)->D1_VALIRR 
				EndIf	

				If AliasIndic("CD6")  .And. CD6->(FieldPos("CD6_QTAMB")) > 0 .And. CD6->(FieldPos("CD6_UFCONS")) > 0  .And. CD6->(FieldPos("CD6_BCCIDE")) > 0 .And. CD6->(FieldPos("CD6_VALIQ")) > 0 .And. CD6->(FieldPos("CD6_VCIDE")) > 0
					aadd(aComb,{CD6->CD6_CODANP,CD6->CD6_SEFAZ,CD6->CD6_QTAMB,CD6->CD6_UFCONS,CD6->CD6_BCCIDE,CD6->CD6_VALIQ, CD6->CD6_VCIDE, IIf(CD6->(FieldPos("CD6_MIXGN")) > 0,CD6->CD6_MIXGN,"") })
			    Elseif AliasIndic("CD6")  .And. CD6->(FieldPos("CD6_QTAMB")) > 0 .And. CD6->(FieldPos("CD6_UFCONS")) > 0 
			    	aadd(aComb,{CD6->CD6_CODANP,CD6->CD6_SEFAZ,CD6->CD6_QTAMB,CD6->CD6_UFCONS})
				Else
					aadd(aComb,{})
				EndIf
				If AliasIndic("CD7")
					aadd(aMed,{CD7->CD7_LOTE,CD7->CD7_QTDLOT,CD7->CD7_FABRIC,CD7->CD7_VALID,CD7->CD7_PRECO})
				Else
					aadd(aMed,{})
				EndIf
				If AliasIndic("CD8")
					aadd(aArma,{CD8->CD8_TPARMA,CD8->CD8_NUMARMA,CD8->CD8_DESCR})
				Else
					aadd(aArma,{})
				EndIf
				If AliasIndic("CD9")
					aadd(aveicProd,{CD9->CD9_TPOPER,CD9->CD9_CHASSI,CD9->CD9_CODCOR,CD9->CD9_DSCCOR,CD9->CD9_POTENC,CD9->CD9_CM3POT,CD9->CD9_PESOLI,;
					                CD9->CD9_PESOBR,CD9->CD9_SERIAL,CD9->CD9_TPCOMB,CD9->CD9_NMOTOR,CD9->CD9_CMKG,CD9->CD9_DISTEI,CD9->CD9_RENAVA,;
					                CD9->CD9_ANOMOD,CD9->CD9_ANOFAB,CD9->CD9_TPPINT,CD9->CD9_TPVEIC,CD9->CD9_ESPVEI,CD9->CD9_CONVIN,CD9->CD9_CONVEI,;
					                CD9->CD9_CODMOD,;
					                CD9->(Iif(FieldPos("CD9_CILIND")>0,CD9_CILIND,"")),;
					                CD9->(Iif(FieldPos("CD9_TRACAO")>0,CD9_TRACAO,"")),;
					                CD9->(Iif(FieldPos("CD9_LOTAC")>0,CD9_LOTAC,"")),;
					                CD9->(Iif(FieldPos("CD9_CORDE")>0,CD9_CORDE,"")),;
					                CD9->(Iif(FieldPos("CD9_RESTR")>0,CD9_RESTR,""))})
				Else
				    aadd(aveicProd,{})
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para Anfavea - Cabecalho e Itens                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				If lAnfavea
					//Cabecalho
					aadd(aAnfC,{CDR->CDR_VERSAO,CDR->CDR_CDTRAN,CDR->CDR_NMTRAN,CDR->CDR_CDRECP,CDR->CDR_NMRECP,;
						AModNot(CDR->CDR_ESPEC),CDR->CDR_CDENT,CDR->CDR_DTENT,CDR->CDR_NUMINV}) 
					//Itens
					aadd(aAnfI,{CDS->CDS_PRODUT,CDS->CDS_PEDCOM,CDS->CDS_SGLPED,CDS->CDS_SEPPEN,CDS->CDS_TPFORN,;
						CDS->CDS_UM,CDS->CDS_DTVALI,CDS->CDS_PEDREV,CDS->CDS_CDPAIS,CDS->CDS_PBRUTO,CDS->CDS_PLIQUI,;
						CDS->CDS_TPCHAM,CDS->CDS_NUMCHA,CDS->CDS_DTCHAM,CDS->CDS_QTDEMB,CDS->CDS_QTDIT,CDS->CDS_LOCENT,;
						CDS->CDS_PTUSO,CDS->CDS_TPTRAN,CDS->CDS_LOTE,CDS->CDS_CPI,CDS->CDS_NFEMB,CDS->CDS_SEREMB,;
						CDS->CDS_CDEMB,CDS->CDS_AUTFAT,CDS->CDS_CDITEM})
				Else
					aadd(aAnfC,{})
					aadd(aAnfI,{})
	   			EndIf

				dbSelectArea("CD2")
				If !(cAliasSD1)->D1_TIPO $ "DB"			
					dbSetOrder(2)
				Else
					dbSetOrder(1)
				EndIf
				
				DbSelectArea("SFT")
				DbSetOrder(1)
								
				If SFT->(DbSeek(xFilial("SFT")+"E"+(cAliasSD1)->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD)))
				   aadd(aCSTIPI,{SFT->FT_CTIPI})
				   //TRATAMENTO DA AQUISIÇÃO DE LEITE DO PRODUTOR RURAL CONFORME ARTIGO 207-B, INCISO II RICMS/MG
				   //PEGA OS VALORES E PERCENTUAL DO INNCENTIVO NOS ITENS NA SFT.
				   If SFT->(FieldPos("FT_PRINCMG")) > 0 .And. SFT->(FieldPos("FT_VLINCMG")) > 0
						If SFT->FT_VLINCMG > 0
							nValLeite += SFT->FT_VLINCMG
						EndIf
						If nPercLeite == 0 .And. SFT->FT_PRINCMG > 0 
							nPercLeite := SFT->FT_PRINCMG
						EndIF	
					EndIF
				ElseIf substr((cAliasSD1)->D1_CF,1,1) =="3"
					aadd(aCSTIPI,{SF4->F4_CTIPI})								
				EndIf  																				
				//Posiciona novente na SF1 do documento que esta sendo processado				
				SF1->(MsSeek(xFilial("SF1")+(cAliasSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO)))
				CD2->(MsSeek(xFilial("CD2")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA+PadR((cAliasSD1)->D1_ITEM,4)+(cAliasSD1)->D1_COD))
				While !CD2->(Eof()) .And. xFilial("CD2") == CD2->CD2_FILIAL .And.;
					"E" == CD2->CD2_TPMOV .And.;
					SF1->F1_SERIE == CD2->CD2_SERIE .And.;
					SF1->F1_DOC == CD2->CD2_DOC .And.;
					SF1->F1_FORNECE == IIF(!(cAliasSD1)->D1_TIPO $ "DB",CD2->CD2_CODFOR,CD2->CD2_CODCLI) .And.;
					SF1->F1_LOJA == IIF(!(cAliasSD1)->D1_TIPO $ "DB",CD2->CD2_LOJFOR,CD2->CD2_LOJCLI) .And.;				
					(cAliasSD1)->D1_ITEM == SubStr(CD2->CD2_ITEM,1,Len((cAliasSD1)->D1_ITEM)) .And.;
					(cAliasSD1)->D1_COD == CD2->CD2_CODPRO
					
//					nMargem := IiF(CD2->CD2_PREDBC>0,IiF(CD2->CD2_PREDBC > 100,0,100-CD2->CD2_PREDBC),IiF(Len(aAdI[1])>0 .And. ConvType(aAdI[1][04][01]) == "I19",IiF((aAdi[1][14][03]) > 100,0,aAdi[1][14][03]),CD2->CD2_PREDBC))
					nMargem :=  IiF(CD2->CD2_PREDBC>0,IiF(CD2->CD2_PREDBC == 100,CD2->CD2_PREDBC,IF(CD2->CD2_PREDBC > 100,0,100-CD2->CD2_PREDBC)),IiF(Len(aAdI[1])>0 .And. ConvType(aAdI[1][04][01]) == "I19",IiF((aAdi[1][14][03]) > 100,0,aAdi[1][14][03]),CD2->CD2_PREDBC))
					
					SF7->(DbSetOrder(1))											
					SA2->(DbSetOrder(1))
					SA1->(DbSetOrder(1))

					IF !(cAliasSD1)->D1_TIPO $ "DB"
						If SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE))
							If SF7->(DbSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA2->A2_GRPTRIB))														
								If  SF7->F7_BASEICM > 0 .And. SF7->F7_BASEICM < 100
									nMargem :=  100 - SF7->F7_BASEICM
								EndIf										
							EndIf					
            	        EndIf
                    Else
						If SA1->(DbSeek(xFilial("SA1")+SF1->F1_FORNECE))
							If SF7->(DbSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA1->A1_GRPTRIB))														
								If  SF7->F7_BASEICM > 0 .And. SF7->F7_BASEICM < 100
									nMargem :=  100 - SF7->F7_BASEICM
								EndIf										
							EndIf					
            	        EndIf                    
                    EndIf 
                    // Verifica se existe percentual de reducao na SFT referente ao RICMS 43080/2002 MG.
					If SFT->(FieldPos("FT_PR43080")) <> 0 .And. SFT->FT_PR43080 <> 0 .And. IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT)) == "MG"
						nMargem := SFT->FT_PR43080
					EndIf
					Do Case
						Case AllTrim(CD2->CD2_IMP) == "ICM"
							aTail(aICMS) := {CD2->CD2_ORIGEM,;
											  CD2->CD2_CST,;
											  CD2->CD2_MODBC,; 
							                  nMargem,;// Tratamento para obter o percentual da redução de base do icms nota interna e importacao(integracao com EIC)							                  
							CD2->CD2_BC,;
							Iif(CD2->CD2_BC>0,CD2->CD2_ALIQ,0),;
							CD2->CD2_VLTRIB,;
							0,;
							CD2->CD2_QTRIB,;
							CD2->CD2_PAUTA,;
							If(SFT->(FieldPos("FT_MOTICMS")) > 0,SFT->FT_MOTICMS,""),;			
							SFT->FT_ICMSDIF,;
							Iif(lCD2PARTIC,CD2->CD2_PARTIC,""),;
							POSICIONE("SF4",1,xFilial("SF4")+(cAliasSD1)->D1_TES,"F4_ICMSDIF")}
							nCon++
							
							If lCD2PARTIC .And. CD2->CD2_PARTIC == "2"
								nValICMParc += CD2->CD2_VLTRIB 
								nBasICMParc += CD2->CD2_BC
							EndIf	
						
						Case AllTrim(CD2->CD2_IMP) == "SOL"						
							aTail(aICMSST) := {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,CD2->CD2_PREDBC,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_MVA,CD2->CD2_QTRIB,CD2->CD2_PAUTA,Iif(lCD2PARTIC,CD2->CD2_PARTIC,"")}
							
							If lCD2PARTIC .And. CD2->CD2_PARTIC == "2"
								nValSTParc += CD2->CD2_VLTRIB 
								nBasSTParc += CD2->CD2_BC
							EndIf
						
						   lCalSol := .T.
						   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						   //³Tratamento CAT04 de 26/02/2010                       ³
						   //³Verifica de deve ser garavado no xml o valor e base  ³
						   //³de calculo do ICMS ST para notas fiscais de devolucao³
						   //³Verifica o parametro MV_ICSTDEV                      ³
						   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		                 nValST 	:= CD2->CD2_VLTRIB  
						   If !lIcmSTDev
								If ( (cAliasSD1)->D1_TIPO=="D" .Or. ( (cAliasSD1)->D1_TIPO=="I" .And. lComplDev)) .And. !Empty(nValST) 
									nValSTAux := nValSTAux + nValST
									nBsCalcST := nBsCalcST + CD2->CD2_BC
									nValST 	  := 0
									aTail(aICMSST):= {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,0,0,0,0,CD2->CD2_MVA,	CD2->CD2_QTRIB,CD2->CD2_PAUTA,Iif(lCD2PARTIC,CD2->CD2_PARTIC,"")}  
								EndIf
							EndIf

							
						Case AllTrim(CD2->CD2_IMP) == "IPI"
							aTail(aIPI) := {SB1->B1_SELOEN,SB1->B1_CLASSE,0,"999",CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_QTRIB,CD2->CD2_PAUTA,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_MODBC,CD2->CD2_PREDBC}
						Case AllTrim(CD2->CD2_IMP) == "ISS"
							If Empty(aISS)
								aISS := {0,0,0,0,0}
							EndIf
							aISS[01] += (cAliasSD1)->D1_TOTAL
							aISS[02] += CD2->CD2_BC
							aISS[03] += CD2->CD2_VLTRIB					
						Case AllTrim(CD2->CD2_IMP) == "PS2"
							If (cAliasSD1)->D1_VALISS==0
								aTail(aPIS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
							Else
								If Empty(aISS)
									aISS := {0,0,0,0,0}
								EndIf
								aISS[04]          += CD2->CD2_VLTRIB	
							EndIf
						Case AllTrim(CD2->CD2_IMP) == "CF2"
							If (cAliasSD1)->D1_VALISS==0
								aTail(aCOFINS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
							Else
								If Empty(aISS)
									aISS := {0,0,0,0,0}
								EndIf
								aISS[05] += CD2->CD2_VLTRIB	
							EndIf
						Case AllTrim(CD2->CD2_IMP) == "PS3" .And. (cAliasSD1)->D1_VALISS==0
							aTail(aPISST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "CF3" .And. (cAliasSD1)->D1_VALISS==0
							aTail(aCOFINSST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "ISS"
							If Empty(aISS)
								aISS := {0,0,0,0,0}
							EndIf
							aISS[01] += (cAliasSD1)->D1_TOTAL
							aISS[02] += CD2->CD2_BC
							aISS[03] += CD2->CD2_VLTRIB	
							If SF3->F3_TIPO =="S"
								If SF3->F3_RECISS =="1"
									cSitTrib := "R"
								Elseif SF3->F3_RECISS =="2"
									cSitTrib:= "N"
								Elseif SF4->F4_LFISS =="I"
									cSitTrib:= "I"
								Else
									cSitTrib:= "N"
								Endif
							Endif
							
							
							IF SF4->F4_ISSST == "1" .or. Empty(SF4->F4_ISSST)
								cIndIss := "1" //1-Exigível;
							ElseIf SF4->F4_ISSST == "2"
								cIndIss := "2"	//2-Não incidência
							ElseIf SF4->F4_ISSST == "3"
								cIndIss := "3" //3-Isenção
							ElseIf	SF4->F4_ISSST == "4"
								cIndIss := "5"	 //5-Imunidade
							ElseIf	SF4->F4_ISSST == "5"
								cIndIss := "6"	 //6-Exigibilidade Suspensa por Decisão Judicial
							ElseIf SF4->F4_ISSST == "6"
								cIndIss := "7"	 //7-Exigibilidade Suspensa por Processo Administrativo
							Else
								cIndIss := "4"//4-Exportação
							EndIf							
							
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Pega as deduções ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SF3->(FieldPos("F3_ISSSUB"))>0
								nDeducao+= SF3->F3_ISSSUB
							EndIf
							
							If SF3->(FieldPos("F3_ISSMAT"))>0
								nDeducao+= SF3->F3_ISSMAT
							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se recolhe ISS Retido ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

							If SF3->(FieldPos("F3_RECISS"))>0
								If SF3->F3_RECISS $"1S"       
									If SF3->(dbSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
										While !SF3->(EOF()) .And. xFilial("SF3")+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE==SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
											If SF3->F3_TIPO=="S" //Serviço
												nValISSRet+= SF3->F3_VALICM
											EndIf
											SF3->(dbSkip())
										EndDo
									EndIf										
						   		Endif
							EndIf

							
							aTail(aISSQN) := {CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,"",AllTrim((cAliasSD1)->D1_CODISS),cSitTrib,nDeducao,cIndIss,nValISSRet}
					EndCase
					
					dbSelectArea("CD2")
					dbSkip()
				EndDo
				
				dbSelectArea("SFT") //Livro Fiscal Por Item da NF
				dbSetOrder(1) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
				If MsSeek(xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA+PadR((cAliasSD1)->D1_ITEM,4)+(cAliasSD1)->D1_COD) .And. ;
					SFT->(FieldPos("FT_CSTPIS")) > 0 .And. SFT->(FieldPos("FT_CSTCOF")) > 0
					
					IF Empty(aPis[Len(aPis)]) .And. !empty(SFT->FT_CSTPIS)
						aTail(aPisAlqZ):= {SF4->F4_CSTPIS}						
					EndIf
					IF Empty(aCOFINS[Len(aCOFINS)]) .And. !empty(SFT->FT_CSTCOF)
						aTail(aCofAlqZ):= {SF4->F4_CSTCOF}					
					EndIf

				Else

					IF Empty(aPis[Len(aPis)]) .And. !empty(SF4->F4_CSTPIS)
						aTail(aPisAlqZ):= {SF4->F4_CSTPIS}	
					EndIf
					IF Empty(aCOFINS[Len(aCOFINS)]) .And. !empty(SF4->F4_CSTCOF) 
						aTail(aCofAlqZ):= {SF4->F4_CSTCOF}	
					EndIf

				EndIf
									
				If !Len(aCofAlqZ)>0 .Or. !Len(aPisAlqZ)>0
					aadd(aCofAlqZ,{})
					aadd(aPisAlqZ,{})
				Endif
				
				If SF4->(FieldPos("F4_CSOSN"))>0
					aTail(aCsosn):= SF4->F4_CSOSN
				Else
					aTail(aCsosn):= ""
				EndIf
												
				If !Len(aCsosn)>0 
					aTail(aCsosn):= ""
				EndIf                

				//Tratamento para que o valor de PIS ST e COFINS ST venha a compor o valor total da tag vOutros  (NT 2011/004).
				//aTotal[01] += (cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_VALPS3 + (cAliasSD1)->D1_VALCF3

	             //Tratamento para que o valor de PIS ST e COFINS ST venha a compor o valor total da tag vOutros  (NT 2011/004). E devolução de compra com IPI não tributado apenas para saida
				If ((cAliasSD1)->D1_TIPO == "D" .and. !lIpiDev .and. cTipo == "1")  .Or. lConsig .Or. (Alltrim((cAliasSD1)->D1_CF) $ cMVCFOPREM ) .OR. ((cAliasSD1)->D1_TIPO == "B" .and. lIpiBenef) .OR. ((cAliasSD1)->D1_TIPO=="P" .And. lComplDev .And. !lIpiDev)
					aTotal[01] += (cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_VALPS3 + (cAliasSD1)->D1_VALCF3 + (cAliasSD1)->D1_VALIPI + nIcmsST
				Else 
					aTotal[01] += (cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_VALPS3 + (cAliasSD1)->D1_VALCF3 + nIcmsST
				EndIf
						
				If (cAliasSD1)->D1_TIPO $ "I"
					If (cAliasSD1)->D1_ICMSRET > 0
						aTotal[02] += (cAliasSD1)->D1_ICMSRET
					Else
						aTotal[02] += 0
					EndIf
				Else
					aTotal[02] += ((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA;
					+IIF((cAliasSD1)->D1_TIPO $ "IP",0,(cAliasSD1)->D1_VALIPI)+(cAliasSD1)->D1_ICMSRET + (cAliasSD1)->D1_VALPS3 + (cAliasSD1)->D1_VALCF3;    
					+IIF(SF4->F4_AGREG   $ "IB",(cAliasSD1)->D1_VALICM,0	);
					+IIF(SF4->F4_AGRPIS  $ "1P",(cAliasSD1)->D1_VALIMP6,0	);
					+IIF(SF4->F4_AGRCOF  $ "1C",(cAliasSD1)->D1_VALIMP5,0	));
					-(IIF(SF4->F4_AGREG  $ "D",(cAliasSD1)->D1_DESCICM,0	));
					-(IIF(SF4->F4_AGREG  $ "N",(cAliasSD1)->D1_TOTAL,0		));
					-(IIF(SF4->F4_INCSOL $ "N",(cAliasSD1)->D1_ICMSRET,0	));
					-(IIF(Alltrim(SF4->F4_AGRPIS)  $ "D",(cAliasSD1)->D1_VALIMP6,0	));
					-(IIF(Alltrim(SF4->F4_AGRCOF)  $ "D",(cAliasSD1)->D1_VALIMP5,0	))
				EndIf
				dbSelectArea(cAliasSD1)
				dbSkip()
		    EndDo	

				   	
		    //Retira o desconto referente ao RICMS 43080/2002
		    If nDesTotal > 0
		    	aTotal[2] -= nDesTotal
		    EndIf
		    
			If nBaseIrrf > 0 .And. nValIrrf > 0
				aadd(aRetido,{"IRRF",nBaseIrrf,nValIrrf})
			EndIf
			//TRATAMENTO DA AQUISIÇÃO DE LEITE DO PRODUTOR RURAL CONFORME ARTIGO 207-B, INCISO II RICMS/MG
			//INSERE MSG EM INFADFISCO E SOMA NO TOTAL DA NOTA.
			If nValLeite > 0 .And. nPercLeite > 0
				cMensFis += Alltrim(Str(nPercLeite,10,2))+'% Incentivo à produção e à industrialização do leite = R$ '+ Alltrim(Str(nValLeite,10,2))
				aTotal[02] += nValLeite
			EndIf
			
			//Operação com diferimento parcial de 66,66% do RICMS/PR
			If nValIcmDev > 0 .And. nValIcmDif > 0
				cMensFis +=	"Operacao com diferimento parcial de 66,66% do imposto no valor de R$ " + Alltrim(Str(nValIcmDif,10,2)) + " - "
				cMensFis += "ICMS devido de R$ " + Alltrim(Str(nValIcmDev,10,2)) + ", "
				cMensFis += "nos termos do art. 617-A do Decreto n. 6.080/2012 do RICMS/PR"
			Endif
			
			If nValSTAux > 0 
				cValST  := AllTrim(Str(nValSTAux,15,2))
				cBsST   := AllTrim(Str(nBsCalcST,15,2))
				cMensCli += " "
				If lComplDev .And.  nBsCalcST == 0
					cMensCli += "(Valor do ICMS ST: R$ "+cValST+") " 					
				Else
					cMensCli += "(Base de Calculo do ICMS ST: R$ "+cBsST+ " - "+"Valor do ICMS ST: R$ "+cValST+") "
				EndIF	
				cValST	  := ""  
				cBsST 	  := ""   
				nBsCalcST := 0
				nValSTAux := 0				
			EndIf
			
			
			
			
		    If lQuery
		    	dbSelectArea(cAliasSD1)
		    	dbCloseArea()
		    	dbSelectArea("SD1")
		    EndIf
		EndIf
	EndIf
EndIf
IF ExistBlock("PE01NFESEFAZ")                   

	aParam := {aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque}

	aParam := ExecBlock("PE01NFESEFAZ",.F.,.F.,aParam)
	
	If ( Len(aParam) >= 5 )
		aProd		:= aParam[1]
		cMensCli	:= aParam[2]
		cMensFis	:= aParam[3]
		aDest 		:= aParam[4]
		aNota 		:= aParam[5]
		aInfoItem	:= aParam[6]  
		aDupl		:= aParam[7]
		aTransp		:= aParam[8]
		aEntrega	:= aParam[9]
		aRetirada	:= aParam[10]
		aVeiculo	:= aParam[11]
		aReboque	:= aParam[12]
	EndIf
	
Endif 

nLenaIpi := Len(aCstIpi) // Tratamento para CST IPI.

//Geracao do arquivo XML
If !Empty(aNota)
	cString := ""
	cString += NfeIde(@cNFe,aNota,cNatOper,aDupl,aNfVinc,cVerAmb,aNfVincRur,aRefECF,cIndPres,aDest,aProd,aExp)
	cString += NfeEmit(aIEST,cVerAmb,aDest)
	cString += NfeDest(aDest,cVerAmb,aTransp,aCST,lBrinde)
	cString += NfeLocalRetirada(aRetirada)
	cString += NfeLocalEntrega(aEntrega)
	For nX := 1 To Len(aProd)
		If nLenaIpi > 0
			If  nCstIpi <= nLenaIpi
				cIpiCst := aCSTIPI[nX][1]
				nCstIpi += 1
			Else
				cIpiCst := ""
			EndIf
		EndIf
		cString += 	NfeItem(aProd[nX],aICMS[nX],aICMSST[nX],aIPI[nX],aPIS[nX],aPISST[nX],aCOFINS[nX],aCOFINSST[nX],aISSQN[nX],aCST[nX],;
					aMed[nX],aArma[nX],aveicProd[nX],aDI[nX],aAdi[nX],aExp[nX],aPisAlqZ[nX],aCofAlqZ[nX],aAnfI[nX],cTipo,cVerAmb, aComb[Nx],;
					@cMensFis,aCsosn[Nx],aPedCom[nX],aNota[5],aICMSZFM[nX],aDest,cIpiCst,aFCI[nX],lIcmDevol,@nVicmsDeson,@nVIcmDif,cMunPres)
	Next nX
  	cString += NfeTotal(aTotal,aRetido,aICMS,aICMSST,lIcmDevol,cVerAmb,aISSQN,nVicmsDeson,aNota,nVIcmDif)
	cString += NfeTransp(cModFrete,aTransp,aImp,aVeiculo,aReboque,aEspVol,cVerAmb,aReboqu2)
	cString += NfeCob(aDupl)
	nA := 0
	For nA:=1 to Len(aMensAux)
		cMensFis += " " + aMensAux[nA] + CRLF
	Next
	
	If cMensONU <> ""
	 cMensCli:= cMensCli+" "+ Alltrim(cMensONU)
	EndIf
	
	
	cString += NfeInfAd(cMensCli,cMensFis,aPedido,aExp,cAnfavea,aMotivoCont,aNota,aNfVinc,aProd,aDI,aNfVincRur,aRetido,cNfRefcup,cSerRefcupc,cTipo,nIPIConsig,nSTConsig,lBrinde,cVerAmb)
	cString += "</infNFe>"
EndIf
Return({cNfe,EncodeUTF8(cString),cNotaOri,cSerieOri})

Static Function NfeIde(cChave,aNota,cNatOper,aDupl,aNfVinc,cVerAmb,aNfVincRur,aRefECF,cIndPres,aDest,aProd,aExp)

Local cString    := ""
Local cNFVinc    := ""
Local cModNot    := ""
Local cTPNota    := ""
Local cMVCfopTran	:= SuperGetMV("MV_CFOPTRA", ," ")   		// Parametro que define as CFOP´s pra transferência de Crédito/Débito
Local cOper		:= ""
Local cCFOP		:= ""
Local cMVDevCfop	:=  AllTrim(GetNewPar("MV_DEVCFOP",""))
Local cChaveRef	:= ""

Local lAvista		:= Len(aDupl)==1 .And. aDupl[01][02]<=DataValida(aNota[03]+1,.T.)
Local lDSaiEnt	:= GetNewPar("MV_DSAIENT", .T.)
Local lNfVincRur	:= .F.
Local lNfVinc		:= .F.
Local lEECFAT		:= SuperGetMv("MV_EECFAT")
Local lRefEcf		:= .F.

Local nX 			:= 0
Local nY			:= 0
Local nPos			:= 0
 

cVerAmb     := PARAMIXB[2]

cChave := aUF[aScan(aUF,{|x| x[1] == SM0->M0_ESTCOB})][02]+FsDateConv(aNota[03],"YYMM")+SM0->M0_CGC+"55"+StrZero(Val(aNota[01]),3)+StrZero(Val(aNota[02]),9)
cChave+=Inverte(StrZero(Val(aNota[02]),8))

cString += '<infNFe versao="T01.00">'
cString += '<ide>'
cString += '<cUF>'+ConvType(aUF[aScan(aUF,{|x| x[1] == SM0->M0_ESTCOB})][02],02)+'</cUF>'
cString += '<cNF>'+ConvType(Inverte(StrZero(Val(aNota[02]),Len(aNota[02]))),08)+'</cNF>'
cString += '<natOp>'+ConvType(cNatOper)+'</natOp>'
cString += '<indPag>'+IIF(lAVista,"0",IIf(Len(aDupl)==0,"2","1"))+'</indPag>'
If Empty(aNota[01])
	cString += '<serie>'+"000"+'</serie>'
Else
	cString += '<serie>'+ConvType(Val(aNota[01]),3)+'</serie>'
Endif
cString += '<nNF>'+ConvType(Val(aNota[02]),9)+'</nNF>'
//Nota Técnica 2013/005 - Data e Hora no formato UTC
If cVeramb >= "3.10"
	cString += '<dhEmi>'+ConvType(aNota[03])+"T"+Iif(Len(aNota[06]) > 5,ConvType(aNota[06]),ConvType(aNota[06])+":00")+'</dhEmi>'
	//cString += NfeTag('<dhSaiEnt>',Iif(lDSaiEnt,"",ConvType(aNota[03])+"T"+Iif(Len(aNota[06]) > 5,ConvType(aNota[06]),ConvType(aNota[06])+":00")))
	//** BRENO **//
	cString += NfeTag('<dhSaiEnt>',Iif(lDSaiEnt,"",If(Empty(dDataSai),ConvType(aNota[03]),ConvType(dDataSai))+"T"+Iif(Len(aNota[06]) > 5,ConvType(aNota[06]),ConvType(aNota[06])+":00")))
	//**********//
Else	
	cString += '<dEmi>'+ConvType(aNota[03])+'</dEmi>'
	//cString += NfeTag('<dSaiEnt>',Iif(lDSaiEnt, "", ConvType(aNota[03])))

	//** BRENO **//
	cString += NfeTag('<dSaiEnt>',Iif(lDSaiEnt,"",If(Empty(dDataSai),ConvType(aNota[03]),ConvType(dDataSai))))
	//**********//

	If !lDSaiEnt .And. !Empty(aNota[06])
		if len(aNota[06]) > 5
			cString += '<hSaiEnt>'+ConvType(aNota[06])+'</hSaiEnt>'
		else
			cString += '<hSaiEnt>'+ConvType(aNota[06])+":00"+'</hSaiEnt>'	
		endif
	Endif
EndIf
cString += '<tpNF>'+aNota[04]+'</tpNF>'
If cVeramb >= "3.10"
	
	cCFOP:= AllTrim(aProd[1][7]) //Considera somente o CFOP da primeira nota
	
	If SubStr(cCFOP,1,1) == "2" .Or. SubStr(cCFOP,1,1) == "6" 
		 cOper:= "2" //Operação Interestadual
	ElseIf SubStr(cCFOP,1,1) == "3" .Or. SubStr(cCFOP,1,1) == "7" 
		cOper:= "3" //Operação com Exterior
	Else
		cOper:= "1" //Operação Interna CFOP 1 e 5
	EndIf
	
	//Identificador de Local de Destino da Operação
	cString += '<idDest>'+cOper+'</idDest>'	
EndIf

If !Empty(aNfVinc)
	
	cModNot := AModNot(aNfVinc[1][06])
	
	If cModNot == '02'
		aNfVinc   := {}
	EndIf
EndIf

If !Empty(aNfVinc)	
	cString += '<NFRef>'
	For nX := 1 To Len(aNfVinc)
		lNfVincRur := aScan(aNfVincRur,{|aX| aX[4]==aNfVinc[nX][6] .And. aX[2]==aNfVinc[nX][2] .And. aX[3]==aNfVinc[nX][3] .And. aX[5]==aNfVinc[nX][4]}) == 0
		// Verifica se ja foi gerada a tag para a mesma nota anteriormente, para não ser gerada novamente
		//   ocasionando em rejeição pela SEFAZ
		nPos       := aScan(aNfVinc, {|aX| aX[2] == aNfVinc[nX][2] .And. aX[3] == aNfVinc[nX][3]})
		lNfVinc    := (nPos > 0 .And. nPos <> nX)
		
		If cVerAmb >= "2.00" .And. lNfVincRur .And. !lNfVinc
			If !Empty(aNfVinc[Nx][7]) // Contem chave de NF-e ou Ct-e
				if !Empty(aNfVinc[Nx][6]) .and. "CTE" == UPPER(Alltrim(aNfVinc[Nx][6]))
					cString += '<refCTe>'+aNfVinc[Nx][7]+'</refCTe>'				
				else				
					cString += '<refNFe>'+aNfVinc[Nx][7]+'</refNFe>'   
				endif
	
			ElseIf !(ConvType(aUF[aScan(aUF,{|x| x[1] == aNfVinc[nX][05]})][02],02)+;
				FsDateConv(aNfVinc[nX][01],"YYMM")+;
				aNfVinc[nX][04]+;
				AModNot(aNfVinc[nX][06])+;
				ConvType(Val(aNfVinc[nX][02]),3)+;
				ConvType(Val(aNfVinc[nX][03]),9) $ cNFVinc );
				.and. AModNot(aNfVinc[nX][06]) <> "02" 
				cString += '<RefNF>'
				cString += '<cUF>'+ConvType(aUF[aScan(aUF,{|x| x[1] == aNfVinc[nX][05]})][02],02)+'</cUF>'
				cString += '<AAMM>'+FsDateConv(aNfVinc[nX][01],"YYMM")+'</AAMM>'
				If Len(AllTrim(aNfVinc[nX][04]))==14
					cString += '<CNPJ>'+aNfVinc[nX][04]+'</CNPJ>'
				ElseIf Len(AllTrim(aNfVinc[nX][04]))>0
					cString += '<CNPJ>'+Replicate("0",14)+'</CNPJ>'
					cString += '<CPF>'+aNfVinc[nX][04]+'</CPF>'
				Else
					cString += '<CNPJ></CNPJ>'
				EndIf
				cString += '<mod>'+AModNot(aNfVinc[nX][06])+'</mod>'
				cString += '<serie>'+ConvType(Val(aNfVinc[nX][02]),3)+'</serie>'
				cString += '<nNF>'+ConvType(Val(aNfVinc[nX][03]),9)+'</nNF>'
				cString += '<cNF>' + strZero( val( convType( inverte( strZero( val( aNfVinc[nX][03] ), len( aNfVinc[nX][03] ) ) ), 8 ) ), 9 ) + '</cNF>'
				cString += '</RefNF>'
		
				cNFVinc += ConvType(aUF[aScan(aUF,{|x| x[1] == aNfVinc[nX][05]})][02],02)+;
					FsDateConv(aNfVinc[nX][01],"YYMM")+;
					aNfVinc[nX][04]+;
					AModNot(aNfVinc[nX][06])+;
					ConvType(Val(aNfVinc[nX][02]),3)+;
					ConvType(Val(aNfVinc[nX][03]),9)
			EndIf						
		EndIf                		
	Next nX                  
	cString += '</NFRef>'
EndIf

If !Empty(aNfVincRur)	
	If len(aNfVincRur)>0 .and. cVerAmb >= "2.00"       
		cString += '<NFRef>'
		For nX := 1 To Len(aNfVincRur)
			cString +='<refNFP>' 
			cString += '<cUF>'+ConvType(aUF[aScan(aUF,{|x| x[1] == aNfVincRur[nX][06]})][02],02)+'</cUF>'
			cString += '<AAMM>'+FsDateConv(aNfVincRur[nX][01],"YYMM")+'</AAMM>'
			If Len(AllTrim(aNfVincRur[nX][05]))==14
				cString += '<CNPJ>'+AllTrim(aNfVincRur[nX][05])+'</CNPJ>'
			ElseIf Len(AllTrim(aNfVincRur[nX][05]))<>0
				cString += '<CPF>' +AllTrim(aNfVincRur[nX][05])+'</CPF>'
			Else
				cString += '<CNPJ></CNPJ>'         
			EndIf	               
			cString += '<IE>'+ConvType(aNfVincRur[nX][07])+'</IE>'
			cString += '<mod>'+IIf(Alltrim(aNfVincRur[nX][04]) == "NFA","01",AModNot(aNfVincRur[nX][04]))+'</mod>'	
			cString += '<serie>'+ConvType(Val(aNfVincRur[nX][02]),3)+'</serie>'
			cString += '<nNf>'+ConvType(Val(aNfVincRur[nX][03]),9)+'</nNf>'
 			cString +='</refNFP>'
		Exit 	
  		Next nX          
  		cString += '</NFRef>'
	Endif
EndIF

If !Empty(aRefECF)
	If len(aRefECF) > 0 .and. cVerAmb >= "2.00"        
		cString += '<NFRef>'	

		For nX := 1 To Len(aRefECF)
			// Verifica se ja foi gerada a tag para o mesmo ECF / CF, para não ser gerada novamente
			// ocasionando em rejeição pela SEFAZ
			nPos		:= aScan(aRefECF, {|aX| aX[1] == aRefECF[nX][1] .And. aX[3] == aRefECF[nX][3]})
			lRefEcf	:= (nPos > 0 .And. nPos <> nX)
			
			if !lRefEcf
				cString +='<refECF>'

				if Alltrim(aRefECF[nX][02]) == "ECF" .Or. Alltrim(aRefECF[nX][02])=="CF" 
		  			cString += '<Mod>'+"2C"+'</Mod>'
	  			else
	  				cString += '<Mod>'+"2B"+'</Mod>'
	  			endif
				cString += '<nECF>'+ConvType(Val(aRefECF[nX][03]),3)+'</nECF>'
				cString += '<nCOO>'+ConvType(Val(aRefECF[nX][01]),6)+'</nCOO>'
								
				cString +='</refECF>'
			endif
			
			if !Empty(aRefECF[nX][01]) .And.  !Empty(aRefECF[nX][02]) .And.  !Empty(aRefECF[nX][03])  
				Exit
			endif			
  		Next nX 
		cString += '</NFRef>'	
	
	Endif	
EndIf 

/*Quando há exportação indireta(I52), deve-se informar as chaves(I54) na tag refNFe.
EEC não consegue preencher campo D2_NFORI pois pode existir mais de um documento de entrada para referenciar em um mesmo item,
por este motivo, as chaves recebidas na tag chNFe do grupo exportInd serão geradas automaticamente na refNFe.
*/

If !Empty(aExp[1]) .and. lEECFAT .and. cVerAmb >= "3.10"
	If Len(aExp) > 0 .and. aNota[04] == "1" //Somente se nota de saída
		For nX := 1 To Len(aExp)
			If Len(aExp[nX][3][3]) > 0
				For nY := 1 To Len(aExp[nX][3][3][2])
					//Quando não há exportInd, a posição 3 é retornada vazia
					If !Empty(aExp[nX][3][3][2][nY][3])
						cChaveRef += '<refNFe>'+aExp[nX][3][3][2][nY][3][2][3]+'</refNFe>'
					EndIf
				Next nY
			EndIf 
		Next Nx
		
		If !Empty(cChaveRef)
			cString += '<NFRef>'
			cString += cChaveRef
			cString += '</NFRef>'
		EndIf
				
	EndIf	
EndIf
Do Case
	Case (!Empty(aNfVinc) .And. !(aNota[5]$"NDB") .And. SF4->F4_AJUSTE <> "S")
  		cTPNota:= "2" 
 	Case (SubStr(SM0->M0_CODMUN,1,2)=='31' .And. SF4->F4_AJUSTE == "S" .And. (aNota[5]) $ "N" )
 		cTPNota:= "3"
	Case ((aNota[5]) $ "I-D-C" .And. SF4->F4_AJUSTE == "S")
   		cTPNota:= "3"
	/* Referente ao chamado TIDMJV que contempla, nota de transferência de crédito / débito */	   		
   	Case ( ( AllTrim( SF4->F4_CF ) $ cMVCfopTran ) .and. ( SF4->F4_SITTRIB == "90" ) .and.  ( SF4->F4_AJUSTE == "S" ) ) 
		cTPNota:= "3"
	Case (cVeramb >= "3.10" .and. (!Empty(aNfVinc) .Or. !Empty(aRefECF))) .and. ( (aNota[5] $ "D|B" .And. SF4->F4_AJUSTE <> "S") .or. (aNota[5] $ "N" .And. SF4->F4_PODER3 == "D") )
   		
   		//Retorna um array, de acordo com os dados passados no parametro MV_DEVCFOP
   		aMVDevCfop	:= StrTokArr( cMVDevCfop , ";" )	
   		
   		// Verifica a CFOP da NF de Devolucao consta no parametro MV_DEVCFOP 
   		nPos := Ascan( aMVDevCfop , Alltrim(SFT->FT_CFOP) ) 
   		
   		// Se achou o conteudo, o Tipo de Nota fica igual a 1 conforme NT 2013.005.v1.03 (Chamado TQMCY6) 
   		If nPos > 0 
   			cTPNota:= "1" 
   		Else
   			cTPNota:= "4" //Devolução de Mercadoria
   		EndIf
   		
	OtherWise 
  		cTPNota:= "1"
	
	EndCase
cString += '<tpNFe>'+cTPNota+'</tpNFe>'
If cVeramb >= "3.10"
	If !Empty(aDest[20]) .and. aDest[20] == "F"
		cString += '<indFinal>1</indFinal>' //1-Operação com consumidor final
	Else
		cString += '<indFinal>0</indFinal>'//0-Não
	EndIf
	If Empty(cIndPres)
		If aNota[04] == "0" .And. aNota[5] $ "N" .And. SF4->F4_PODER3 == "R" // Tratamento para retorno de Beneficiamento
			cIndPres := "9" //Operação não presencial 
		Else
			cIndPres := "0" //0-Não se Aplica	
		EndIf
	EndIf
	cString += '<indPres>'+cIndPres+'</indPres>' // Presenção do comprador no momento da Operação
EndIf
cString += '</ide>'

//** BRENO **//
//U_GravarXML(cString,"xmlteste")
//cString := ""
//**********//

Return( cString )

Static Function NfeEmit(aIEST, cVerAmb, aDest)

Local aTelDest 		:= {} 

Local cFoneDest		:= ""
Local cMVCODREG		:= SuperGetMV("MV_CODREG", ," ")  
Local cMVEstado		:= SuperGetMV("MV_ESTADO", ," ")
Local cSTIeUf		:= SuperGetMV("MV_STNIEUF",.F.,"")
Local cString 		:= ""
Local cUfDest		:= ""

Local lEndFis 		:= GetNewPar("MV_SPEDEND",.F.)
Local lUsaGesEmp	:= IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)

DEFAULT aIEST	 := {}

cVerAmb     := PARAMIXB[2] 
cUfDest		:= ConvType(aDest[09])


cString := '<emit>'
cString += '<CNPJ>'+SM0->M0_CGC+'</CNPJ>'             
cString += '<Nome>'+ConvType(SM0->M0_NOMECOM)+'</Nome>'

/*
Quando utilizar Gestao de empresas o M0_NOME guarda o nome do Grupo e não da Filial.
FWFilialName - Pega o nome da Filial Atual,só usar funcao se estiver habilitado 
gestao de empresa (FWSizeFilial() > 2)
*/

If lUsaGesEmp
	cString += NfeTag('<Fant>',ConvType(FWFilialName()))
Else
	cString += NfeTag('<Fant>',ConvType(SM0->M0_NOME))
EndIf	     

cString += '<enderEmit>'
cString += '<Lgr>'+IIF(!lEndFis,ConvType(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[1]),ConvType(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[1]))+'</Lgr>'

If !lEndFis
	If FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[2]<>0
		cString += '<nro>'+FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[3]+'</nro>'  
	Else
		cString += '<nro>'+"SN"+'</nro>' 
	EndIf
Else
	If FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[2]<>0
		cString += '<nro>'+FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[3]+'</nro>' 
	Else
		cString += '<nro>'+"SN"+'</nro>'
	EndIf
EndIf	
	
cEndEmit :=  IIF(!lEndFis,Iif(!Empty(SM0->M0_COMPCOB),SM0->M0_COMPCOB,ConvType(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[4]) ) ,;
						  Iif(!Empty(SM0->M0_COMPENT),SM0->M0_COMPENT,ConvType(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[4]) ) )
cString += NfeTag('<Cpl>',cEndEmit)
cString += '<Bairro>'+IIF(!lEndFis,ConvType(SM0->M0_BAIRCOB),ConvType(SM0->M0_BAIRENT))+'</Bairro>'
cString += '<cMun>'+ConvType(SM0->M0_CODMUN)+'</cMun>'
cString += '<Mun>'+IIF(!lEndFis,ConvType(SM0->M0_CIDCOB),ConvType(SM0->M0_CIDENT))+'</Mun>'
cString += '<UF>'+IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT))+'</UF>'
cString += NfeTag('<CEP>',IIF(!lEndFis,ConvType(SM0->M0_CEPCOB),ConvType(SM0->M0_CEPENT)))
cString += NfeTag('<cPais>',"1058")
cString += NfeTag('<Pais>',"BRASIL")
aTelDest:= FisGetTel(SM0->M0_TEL)
cFoneDest := IIF(aTelDest[1] > 0,ConvType(aTelDest[1],3),"") // Código do Pais
cFoneDest += IIF(aTelDest[2] > 0,ConvType(aTelDest[2],3),"") // Código da Área
cFoneDest += IIF(aTelDest[3] > 0,ConvType(aTelDest[3],9),"") // Código do Telefone
cString += NfeTag('<fone>',cFoneDest)
cString += '</enderEmit>'
cString += '<IE>'+ConvType(VldIE(SM0->M0_INSC))+'</IE>'
If !Empty(aIEST) 
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Tratamento para acordo entre os estados preenchidos no parametro MV_STNIEUF, quando em      ³
	  ³ um movimento com ICMS-ST nao e' necessario ter insccricao estadual, assim esse tratamento   ³
	  ³ retorna a inscricao " " para gerar a guia de recolhimento para o estado destino             ³ 
	  ³ Este tratamento foi feito a partir da necessidade das UF de MG p/ PR,onde existe esse 	    ³
	  ³ acordo PROTOCOLO ICMS CONSELHO NACIONAL DE POLÍTICA FAZENDÁRIA - CONFAZ Nº 191 DE 11.12.2009³ 
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If !(cMVEstado+cUfDest) $ cSTIeUf
		cString += NfeTag('<IEST>',aIEST[01]) 
	EndIf
EndIf
cString += NfeTag('<IM>',SM0->M0_INSCM)
cString += NfeTag('<CNAE>',ConvType(SM0->M0_CNAE))
cString += '<CRT>'+cMVCODREG+'</CRT>' 
cString += '</emit>'
Return(cString)

Static Function NfeDest(aDest,cVerAmb,aTransp,aCST,lBrinde)
	
	Local aTelDest		:= {}
	Local cString		:= ""
	Local cMailTrans 	:= ""
	Local cFoneDest	:= ""
	Local cIndicador	:= ""
	Local nX	        := 0
		
	cVerAmb     := PARAMIXB[2] 
	
	cString := '<dest>'
	If cVerAmb >= '3.10'
		If Len(AllTrim(aDest[01]))==14
			cString += '<CNPJ>'+iIf(!lBrinde,AllTrim(aDest[01]),SM0->M0_CGC)+'</CNPJ>'
		ElseIf Len(AllTrim(aDest[01]))<>0
			cString += '<CPF>' +iIf(!lBrinde,AllTrim(aDest[01]),SM0->M0_CGC)+'</CPF>'
		Else
			If !Empty(aDest[21])
				cString += '<idEstrangeiro>'+aDest[21]+'</idEstrangeiro>'
			Else
				cString += '<idEstrangeiro></idEstrangeiro>'
			EndIf
		EndIf
	Else
		If Len(AllTrim(aDest[01]))==14
			cString += '<CNPJ>'+iIf(!lBrinde,AllTrim(aDest[01]),SM0->M0_CGC)+'</CNPJ>'
		ElseIf Len(AllTrim(aDest[01]))<>0
			cString += '<CPF>' +iIf(!lBrinde,AllTrim(aDest[01]),SM0->M0_CGC)+'</CPF>'
		Else
			cString += '<CNPJ></CNPJ>'
		EndIf
	EndIf
	cString += '<Nome>'+ConvType(iIf(!lBrinde,aDest[02],"Diversos - Brindes"))+'</Nome>'
	cString += '<enderDest>'
	cString += '<Lgr>'+ConvType(iIf(!lBrinde,aDest[03],(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[1])))+'</Lgr>'
	if lBrinde
		
		if FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[2]<>0
			cString += '<nro>'+FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[3]+'</nro>' 
		else
			cString += '<nro>'+"SN"+'</nro>'
		endif
	
	else 
		
		If  ValType(aDest[04]) == "N" .and. AT(".",Alltrim(Str(aDest[04]))) > 0
			cString += '<nro>'+Alltrim(Str(aDest[04]))+'</nro>'
		Else
			cString += '<nro>'+ConvType(aDest[04])+'</nro>'
		EndIf
	endif
	cString += NfeTag('<Cpl>',ConvType(iIf(!lBrinde,aDest[05],SM0->M0_COMPENT)))
	cString += '<Bairro>'+ConvType(iIf(!lBrinde,aDest[06],SM0->M0_BAIRENT))+'</Bairro>'
	cString += '<cMun>'+ConvType(iIf(!lBrinde,aUF[aScan(aUF,{|x| x[1] == aDest[09]})][02]+aDest[07],SM0->M0_CODMUN))+'</cMun>'
	cString += '<Mun>'+ConvType(iIf(!lBrinde,aDest[08],SM0->M0_CIDENT))+'</Mun>'
	cString += '<UF>'+ConvType(iIf(!lBrinde,aDest[09],SM0->M0_ESTENT))+'</UF>'
	cString += NfeTag('<CEP>',iIf(!lBrinde,aDest[10],SM0->M0_CEPENT))
	cString += NfeTag('<cPais>',aDest[11])
	cString += NfeTag('<Pais>',ConvType(aDest[12]))
	if lBrinde
		aTelDest	:= FisGetTel(SM0->M0_TEL)
	    cFoneDest	:= IIF(aTelDest[1] > 0,ConvType(aTelDest[1],3),"") // Código do Pais
	    cFoneDest	+= IIF(aTelDest[2] > 0,ConvType(aTelDest[2],3),"") // Código da Área
	    cFoneDest	+= IIF(aTelDest[3] > 0,ConvType(aTelDest[3],9),"") // Código do Telefone
		cString	+= NfeTag('<fone>',cFoneDest)			
	else
		cString += NfeTag('<fone>', ConvType( FisGetTel(aDest[13])[2], 3) + ConvType( FisGetTel(aDest[13])[3], 11)  )
	endif
	cString += '</enderDest>'
	
	If cVerAmb >= "3.10"
		If ConvType(aDest[17]) <> "2" .and. !Empty(aDest[14])
			If "ISENT" $ Upper(Alltrim(aDest[14]))
				cIndicador := "2"
			Else
				cIndicador := "1"
				cString += '<IE>'+ConvType(iIf(!lBrinde,aDest[14],SM0->M0_INSC))+'</IE>'
			EndIf
		Else
				cIndicador := "9" //9-Não Contribuinte: a IE do destinatário pode ser informada ou não, já que algumas UF concedem inscrição estadual para não contribuintes.
				//No caso de operação com o Exterior informar indIEDest=9 e não informar a tag IE do destinatário;
				If  !"EX" $ aDest[08] .And. ConvType(aDest[14]) <> "ISENTO"
					cString += '<IE>'+ConvType(iIf(!lBrinde,aDest[14],SM0->M0_INSC))+'</IE>'
				EndIf
		EndIf
		
		cString += '<indIEDest>'+cIndicador+'</indIEDest>'
		
		/*	indIEDest - Indicador da IE do destinatário
			1=Contribuinte ICMS (informar a IE do destinatário);
			2=Contribuinte isento de Inscrição no cadastro de Contribuintes do ICMS;
			9=Não Contribuinte, que pode ou não possuir Inscrição Estadual no Cadastro de Contribuintes do ICMS;	
		*/
	Else
		// Conforme legislação, não contribuinte em SP, deve levar a IE se preenchida.
		If ConvType(aDest[18]) == "1" .And. ConvType(aDest[17]) == "2"
			cString += '<IE>'+ConvType(iIf(!lBrinde,aDest[14],SM0->M0_INSC))+'</IE>'
		ElseIf ConvType(aDest[17]) == "2" .And. ConvType(aDest[14]) <> "ISENTO" .And. SuperGetMV("MV_ESTADO") <> "SP"  
			cString += '<IE>'+""+'</IE>'
			
		/*---------------------------------------------
		 Tratamento realizado Produtor Rural - RS
		 
		 1. Cliente     		= Produtor Rural
		 2. Documento tipo	= Devolucao
		 3. Origem Rotina		= Loja
		 4. Parametro	estado	= RS (Rio G. Sul)
		 
		 Obs.: Chamado Consultoria Tributaria: TQCMPM
		---------------------------------------------*/	
		ElseIf Alltrim(SA1->A1_TIPO) == "L" .And. Alltrim(SF1->F1_TIPO) == "D" .And. Alltrim(SF1->F1_ORIGLAN) == "LO" .And. SuperGetMV("MV_ESTADO") == "RS" 
			cString += '<IE>'+""+'</IE>'			
		
		Else
			cString += '<IE>'+ConvType(iIf(!lBrinde,aDest[14],SM0->M0_INSC))+'</IE>'
		Endif
	EndIf
	
	//Tratamento para atender Manual de Orientação do Contribuinte versão 5.00 onde é Obrigatório, nas operações que se beneficiam de incentivos fiscais existentes nas áreas sob controle da SUFRAMA.
	cString += NfeTag('<IESUF>',aDest[15])	
	
	If cVerAmb >= "3.10"
		cString += NfeTag('<IM>',aDest[19])
	EndIf
	//Considera o e-mail do cadastro da transportadora
	If Len(aTransp) > 0 .and. !Empty(AllTrim(aTransp[07]))
		If !Empty(aDest[16])
			cMailTrans := ";"+AllTrim(aTransp[07])
		Else 
			cMailTrans := AllTrim(aTransp[07])
		EndIf 	
	Else
		cMailTrans := ""
	EndIf
	if !lBrinde
		cString += NfeTag('<EMAIL>',AllTrim(aDest[16])+cMailTrans)
	endif
	
	cString += '</dest>'
Return(cString)

Static Function NfeLocalEntrega(aEntrega)

Local cString:= ""

If !Empty(aEntrega) .And. (Len(AllTrim(aEntrega[01]))==14 .Or. Len(AllTrim(aEntrega[01]))==11)
	cString := '<entrega>'
	If Len(AllTrim(aEntrega[01]))==14	
		cString += '<CNPJ>'+AllTrim(aEntrega[01])+'</CNPJ>' 
	Elseif Len(AllTrim(aEntrega[01]))<>0
	cString += '<cpf>' +AllTrim(aEntrega[01])+'</cpf>'	
Else
	cString += '<CNPJ></CNPJ>'
Endif
//* esse novo tratamento ainda não está sendo validado corretamente na versão 4.0.1
//If !Empty(aEntrega) .And. Len(AllTrim(aEntrega[01]))==14
//	cString := '<entrega>'
//	cString += '<CNPJ>'+AllTrim(aEntrega[01])+'</CNPJ>'
	cString += '<Lgr>'+ConvType(aEntrega[02])+'</Lgr>'
	cString += '<nro>'+ConvType(aEntrega[03])+'</nro>'
	cString += NfeTag('<Cpl>',ConvType(aEntrega[04]))
	cString += '<Bairro>'+ConvType(aEntrega[05])+'</Bairro>'
	cString += '<cMun>'+ConvType(aUF[aScan(aUF,{|x| x[1] == aEntrega[08]})][02]+aEntrega[06])+'</cMun>'
	cString += '<Mun>'+ConvType(aEntrega[07])+'</Mun>'
	cString += '<UF>'+ConvType(aEntrega[08])+'</UF>'
	cString += '</entrega>'
EndIf
Return(cString)

Static Function NfeLocalRetirada(aRetirada)

Local cString:= ""

If !Empty(aRetirada)
	cString := '<retirada>'
If Len(AllTrim(aRetirada[01]))==14	
	cString += '<CNPJ>'+AllTrim(aRetirada[01])+'</CNPJ>' 
Elseif Len(AllTrim(aRetirada[01]))<>0
cString += '<cpf>' +AllTrim(aRetirada[01])+'</cpf>'	
Else
cString += '<CNPJ></CNPJ>'
Endif
	cString += '<Lgr>'+ConvType(aRetirada[02])+'</Lgr>'
	cString += '<nro>'+ConvType(aRetirada[03])+'</nro>'
	cString += NfeTag('<Cpl>',ConvType(aRetirada[04]))
	cString += '<Bairro>'+ConvType(aRetirada[05])+'</Bairro>'
	cString += '<cMun>'+ConvType(aUF[aScan(aUF,{|x| x[1] == aRetirada[08]})][02]+aRetirada[06])+'</cMun>'
	cString += '<Mun>'+ConvType(aRetirada[07])+'</Mun>'
	cString += '<UF>'+ConvType(aRetirada[08])+'</UF>'
	cString += '</retirada>'
EndIf
Return(cString)

Static Function NfeItem(aProd,aICMS,aICMSST,aIPI,aPIS,aPISST,aCOFINS,aCOFINSST,aISSQN,aCST,aMed,aArma,aveicProd,aDI,aAdi,aExp,aPisAlqZ,aCofAlqZ,aAnfI,cTipo,cVerAmb,aComb,cMensFis,cCsosn,aPedCom,cF2Tipo,aICMSZFM,aDest,cIpiCst,aFCI,lIcmDevol,nVicmsDeson,nVIcmDif,cMunPres)

Local cString 		:= ""
Local cMVCODREG		:= SuperGetMV("MV_CODREG", ," ")  
Local cVunCom		:= ""
Local cVunTrib		:= ""  
Local cMotDesICMS	:= ""
Local cMensDeson	:= ""
Local cDedIcm		:= ""
Local cCrgTrib		:= ""
Local cPercTrib	:= ""
Local cMVINCEFIS	:= AllTrim(GetNewPar("MV_INCEFIS","2"))
Local cMVNumProc	:= AllTrim(GetNewPar("MV_NUMPROC"," "))

Local lAnfProd		:= SuperGetMV("MV_ANFPROD",,.T.)
Local lArt186	    := SuperGetMV("MV_ART186",,.F.)
Local lIssQn     	:= .F.
Local lMvPisCofD 	:= GetNewPar("MV_DPISCOF",.F.)   // Parâmetro para informar os valores de Cofins e Pis nas Informações complementares do Danfe 
//Local lSimpNac   	:= SuperGetMV("MV_CODREG")== "1" .Or. SuperGetMV("MV_CODREG")== "2" 
Local lUnTribCom	:= GetNewPar("MV_VTRICOM",.F.) //Parâmetro para informar o valor unitário comercial e valor unitário tributável nas informações complementares do DANFE (quando vuncom e vuntrib forem diferentes)
Local lNContrICM	:= .F.  //Define se o cliente não é contribuinte do ICMS no estado.
Local lPesFisica	:= .F.
Local lDInoDanfe	:= GetNewPar("MV_DIDANFE",.F.) //Parâmetro para informar os dados da DI nas informações complementares do Xml/Danfe
Local lCalcMed 	:= GetNewPar("MV_STMEDIA",.F.) //Define se irá calcular a média do ICMS ST e da BASE do ICMS ST. 
Local lSuframa		:= GetNewPar("MV_SUFRAMA",.F.) // Parâmetro referente a Suframa
Local lProdItem	:= .F.	//Define se esta configurado para gerar a mensagem da Lei da Transparencia por Produto ou somente nas informacoes Complementares.
Local lEECFAT		:= SuperGetMv("MV_EECFAT")

Local nX			:= 0
Local nBaseIcm   	:= 0
Local nValCof 		:= 0
Local nValICM	 	:= 0
Local nValPis		:= 0
Local nDesonICM	:= 0
Local nValIcmDif	:= 0
Local nA			:= 0

Local anDraw		:= {}
Local aExportInd	:= {}

DEFAULT aICMS    	:= {}
DEFAULT aICMSST  	:= {}
DEFAULT aICMSZFM 	:= {}
DEFAULT aIPI     	:= {}
DEFAULT aPIS    	:= {}
DEFAULT aPISST   	:= {}
DEFAULT aCOFINS  	:= {}
DEFAULT aCOFINSST	:= {}
DEFAULT aISSQN   	:= {}
DEFAULT aMed     	:= {}
DEFAULT aArma    	:= {}
DEFAULT aveicProd	:= {}
DEFAULT aDI		 	:= {}
DEFAULT aAdi	 	:= {}
DEFAULT aExp	 	:= {}
DEFAULT aAnfI	 	:= {}
DEFAULT aPedCom  	:= {}
DEFAULT aFCI		:= {}
DEFAULT cMensFis 	:= ""
DEFAULT cCsosn    	:= ""
DEFAULT cF2Tipo  	:= "N"
DEFAULT nVicmsDeson	:= 0
DEFAULT nVIcmDif	:= 0 

cVerAmb     := PARAMIXB[2]

cString += '<det nItem="'+ConvType(aProd[01])+'">'
cString += '<prod>'
cString += '<cProd>'+ConvType(aProd[02])+'</cProd>'
cString += '<ean>'+ConvType(aProd[03])+'</ean>'
cString += '<Prod>'+ConvType(aProd[04],120)+'</Prod>'
If len(aDI)> 0
	cString +='<NCM>'+ConvType(aDI[01][03])+'</NCM>'
	If cVerAmb >= "3.10" .and. ConvType(aDI[04][1]) == "I19"
		cString += NfeTag('<NVE>',ConvType(aDI[35][03]))
	ElseIf cVerAmb >= "3.10" .and. ConvType(aDI[02][1]) == "I19" //Nota Complementar EEC/EIC
		cString += NfeTag('<NVE>',ConvType(aDI[17][03]))	
	EndIf
Else
	cString +='<NCM>'+ConvType(aProd[05])+'</NCM>'
EndIf
cString += NfeTag('<EXTIPI>',ConvType(aProd[06]))
cString += '<CFOP>'+ConvType(aProd[07])+'</CFOP>'
cString += '<uCom>'+ConvType(aProd[08])+'</uCom>'
cString += '<qCom>'+ConvType(aProd[09],15,4)+'</qCom>'
cString += '<vUnCom>'+ConvType(aProd[16],21,8)+'</vUnCom>'	
cString += '<vProd>' +ConvType(aProd[10],15,2)+'</vProd>' 
cString += '<eantrib>'+ConvType(aProd[03])+'</eantrib>'
cString += '<uTrib>'+ConvType(aProd[11])+'</uTrib>'
cString += '<qTrib>' + ConvType(aProd[12], 15, Min(IIf(cTipo == "0", TamSX3("D1_QUANT")[2], TamSX3("D2_QUANT")[2]), 4)) + '</qTrib>'
cString += '<vUnTrib>'+ConvType(aProd[10]/aProd[12],21,8)+'</vUnTrib>'		
cString += NfeTag('<vFrete>',ConvType(aProd[13],15,2))
cString += NfeTag('<vSeg>'  ,ConvType(aProd[14],15,2))

//Tag <vDesc>
//Quando eh Zona Franca de Manaus
If cVerAmb >= "3.10" .and. Len(aICMSZFM) > 0 .And. Len(aCST) > 0 .And. !Empty(aICMSZFM[1]) .And. (aCST[1] $ '40,41,50')   
	cString += NfeTag('<vDesc>' ,ConvType((aProd[31]+aProd[32])+aProd[15],15,2))	
Else
	//Versao 2.00
	cString += NfeTag('<vDesc>' ,ConvType((aProd[15]),15,2))
EndIf

cString += NfeTag('<vOutro>' ,ConvType(aProd[21],15,2))
// Define se o valor do produto <vProd> será agregado ao valor total
//   dos produtos do documento <vProd> dentro de <total>
cString += '<indTot>'+aProd[24]+'</indTot>'

/* Adequação Nota Técnica 2013/003 (Obs. Tratamento apenas para documento de saída pois refere-se a venda ao consumidor) */
If cTipo == "1" .And. cTpCliente == "F"
	cString += NfeTag('<vTotTrib>' ,ConvType(aProd[30],15,2))
EndIf


/*Nas situações em que o valor unitário comercial (vUnCom) for diferente do valor unitário tributável (vUnTrib), 
ambas as informações deverão estar expressas e identificadas no DANFE - CH:TGCOQA*/

cVunCom := ConvType(aProd[16],21,8)
cVunTrib:= ConvType(aProd[10]/aProd[12],21,8)

If (cVunCom <> cVunTrib) .and. lUnTribCom
	cMensFis += " "
	cMensFis += "(Valor unitario comercial: "+cVunCom+ ", "
	cMensFis += "Valor unitario tributavel: "+cVunTrib+ ") "	
EndIf
//Ver II - Average - Tag da Declaração de Importação aDI
If Len(aDI)>0 .And. ConvType(aDI[04][1]) == "I19"
	cString += '<DI>'
	cString += '<nDI>'+ConvType(aDI[04][03])+'</nDI>'
	cString += '<dtDi>'+ConvType(aDI[05][03])+ '</dtDi>'      
	cString += '<LocDesemb>'+ConvType(aDI[06][03])+ '</LocDesemb>'
	cString += '<UFDesemb>'+ConvType(aDI[07][03])+ '</UFDesemb>'
	cString += '<dtDesemb>'+ConvType(aDI[08][03])+ '</dtDesemb>'
	If cVerAmb >= "3.10"
		cString += '<viaTransp>'+ConvType(aDI[36][03],2)+ '</viaTransp>'
		cString += NfeTag('<AFRMM>',ConvType(aDI[37][3],15,2))
		cString += '<intermedio>'+ConvType(aDI[38][03],1)+ '</intermedio>'
		cString += NfeTag('<CNPJ>',ConvType(aDI[39][3],14))
		cString += NfeTag('<UfTerceiro>',ConvType(aDI[40][3],2))		
	EndIf
	cString += '<Exportador>'+ConvType(aDI[09][03])+ '</Exportador>'
	If Len(aAdi)>0
		cString += '<adicao>'
		cString += '<Adicao>'+ConvType(aAdi[10][03])+ '</Adicao>'
		cString += '<SeqAdic>'+ConvType(aAdi[11][03])+ '</SeqAdic>'
		cString += '<Fabricante>'+ConvType(aAdi[12][03])+ '</Fabricante>'
		cString += '<vDescDI>'+ConvType(aAdi[13][03])+ '</vDescDI>'
		If cVerAmb >= "3.10"
			cString += NfeTag('<draw>',ConvType(aAdi[34][3],11))
		EndIf
		cString += '</adicao>'
	EndIf
	cString += '</DI>'
	/*Impressão dos dados da DI nas informações complementares do Danfe - CH:TELKDV*/
	If lDInoDanfe
		cMensFis += " "
		cMensFis += "(Numero DI: "+ConvType(aDI[04][03])+ ", "
		cMensFis += "Local do Desembaraco: "+ConvType(aDI[06][03])+ ", "
		cMensFis += "UF do Desembaraco: "+ConvType(aDI[07][03])+", "
		cMensFis += "Data do Desembaraco: "+ConvType(aDI[08][03])+ ") "	
	EndIf
Elseif Len(aDI)>0
	//Nota Complementar - SIGAEIC estrutura 23X3
	cString += '<DI>'
	cString += '<nDI>'+ConvType(aDI[02][03])+'</nDI>'
	cString += '<dtDi>'+ConvType(aDI[03][03])+ '</dtDi>'      
	cString += '<LocDesemb>'+ConvType(aDI[04][03])+ '</LocDesemb>'
	cString += '<UFDesemb>'+ConvType(aDI[05][03])+ '</UFDesemb>'
	cString += '<dtDesemb>'+ConvType(aDI[06][03])+ '</dtDesemb>'
	
	If cVerAmb >= "3.10"
		cString += '<viaTransp>'+ConvType(aDI[18][03],2)+ '</viaTransp>'
		cString += NfeTag('<AFRMM>',ConvType(aDI[19][3],15,2))
		cString += '<intermedio>'+ConvType(aDI[20][03],1)+ '</intermedio>'
		cString += NfeTag('<CNPJ>',ConvType(aDI[21][3],14))
		cString += NfeTag('<UfTerceiro>',ConvType(aDI[22][3],2))		
	EndIf
	cString += '<Exportador>'+ConvType(aDI[07][03])+ '</Exportador>'
	If Len(aAdi)>0
		cString += '<adicao>'
		cString += '<Adicao>'+ConvType(aAdi[08][03])+ '</Adicao>'
		cString += '<SeqAdic>'+ConvType(aAdi[09][03])+ '</SeqAdic>'
		cString += '<Fabricante>'+ConvType(aAdi[10][03])+ '</Fabricante>'
	 //	cString += '<vDescDI>'+ConvType(aAdi[13][03])+ '</vDescDI>'
	 	If cVerAmb >= "3.10"
			cString += NfeTag('<draw>',ConvType(aAdi[23][3],11))
		EndIf
		cString += '</adicao>'
	EndIf
	cString += '</DI>'
	/*Impressão dos dados da DI nas informações complementares do Danfe - CH:TELKDV*/
	If lDInoDanfe
		cMensFis += " "
		cMensFis += "(Numero DI: "+ConvType(aDI[02][03])+ ", "
		cMensFis += "Local do Desembaraco: "+ConvType(aDI[04][03])+ ", "
		cMensFis += "UF do Desembaraco: "+ConvType(aDI[05][03])+", "
		cMensFis += "Data do Desembaraco: "+ConvType(aDI[06][03])+ ") "	
	EndIf
EndIf

/*Grupo de informações de exportação para o item - versão 3.10*/
If cVerAmb >= "3.10" .and. Len(aExp)>0
	If lEECFAT
		/*Quando a terceira posição do array estiver vazia ou possuir tamanho 0 é porque a informação não existe no processo.
		  Quando não houver dados de retorno referente ao ato concessório e a exportação indireta, a posição [3][3] terá tamanho 0.
		  Quando houver ato concessório, a informação será retornada na posição [3][3][1]. O tamanho dessa dimensão corresponde à quantidade de atos concessórios encontrados para o item.
		  Quando houver exportação indireta, a informação será retornada na posição [3][3][2]. O tamanho dessa dimensão corresponde à quantidade de notas fiscais de remessa com fim específico de exportação encontrada para o item.
		*/
		If ConvType(aExp[03][1]) == "I50" .and. Len(aExp[03][3]) > 0
			
				For nA:= 1 to Len(aExp[03][3][1])
					anDraw:= aExp[03][3][1][nA] //Array (tag nDraw - I51)
					aExportInd:= aExp[03][3][2][nA]//Array I52(Grupo - I52)
					
					cString += '<detExport>'
					
					If !Empty(anDraw[3])
						cString += '<Draw>'+ConvType(anDraw[3],11)+ '</Draw>'
					EndIf
					
					//Caso não tenha I52, posição 3 é retornada vazia
					If !Empty(aExportInd[3])
						cString += '<exportInd>'
						cString += '<nre>'+ConvType(aExportInd[03][1][3],12)+ '</nre>'
						cString += '<chnfe>'+ConvType(aExportInd[03][2][3],44)+ '</chnfe>'
						cString += '<qExport>'+ConvType(aExportInd[03][3][3],15,4)+ '</qExport>'
						cString += '</exportInd>'
					EndIf
										
					cString += '</detExport>'
				Next
			
		EndIf
	Else
		For nX := 1 To Len(aExp)
			If ConvType(aExp[1][03][1]) == "I51"  
				cString += '<detExport>'
				cString += '<Draw>'+ConvType(aExp[nX][03][03],11)+ '</Draw>'
				If !Empty(aExp[nX][04][03])
					cString += '<exportInd>'
					cString += '<nre>'+ConvType(aExp[nX][04][03],12)+ '</nre>'
					cString += '<chnfe>'+ConvType(aExp[nX][05][03],44)+ '</chnfe>'
					cString += '<qExport>'+ConvType(aExp[nX][06][03],15,4)+ '</qExport>'
					cString += '</exportInd>'
				EndIf	
				cString += '</detExport>'
			EndIf
		Next
	EndIf
Endif

//Combustiveis
If Len(aComb) > 0  .And. !Empty(aComb[01])
	cString += '<comb>'
	cString += '<cprodanp>'+ConvType(aComb[01])+'</cprodanp>'
	If cVeramb >= "3.10" .and. Len(aComb) > 4
		cString += NfeTag('<mixGN>',ConvType(aComb[08],6,4))
	EndIf
	cString += NfeTag('<codif>',ConvType(aComb[02]))

	cString += NfeTag('<qTemp>',ConvType(aComb[03],12,4))
	cString += '<ICMSCONS>'
	cString += '<UFCons>'+aComb[04]+'</UFCons>'
    cString += '</ICMSCONS>'	
    If Len(aComb) > 4 .and. !Empty(aComb[05])
	    cString += '<CIDE>'
		cString += NfeTag('<qBCProd>',ConvType(aComb[05],16,2))
		cString += NfeTag('<vAliqProd>',ConvType(aComb[06],15,4))
		cString += NfeTag('<vCIDE>',ConvType(aComb[07],15,2))
		cString += '</CIDE>'
	Endif	
	cString += '</comb>'

ElseIf !Empty(aProd[17])
	cString += '<comb>'
	cString += '<cprodanp>'+ConvType(aProd[17])+'</cprodanp>'
	cString += NfeTag('<codif>',ConvType(aProd[18]))
	cString += '</comb>'
	//Tratamento da CIDE - Ver com a Average
	//Tratamento de ICMS-ST - Ver com fisco
EndIf

//Veiculos Novos
If !Empty(aveicProd) .And. !Empty(aveicProd[02])
	cString += '<veicProd>'
	cString += '<tpOp>'+ConvType(aveicProd[01])+'</tpOp>'
	cString += '<chassi>'+ConvType(aveicProd[02],17)+'</chassi>'
	cString += '<cCor>'+ConvType(aveicProd[03],4)+'</cCor>'
	cString += '<xCor>'+ConvType(aveicProd[04],40)+'</xCor>'
	cString += '<pot>'+ConvType(aveicProd[05],4)+'</pot>'
	cString += '<Cilin>'+ConvType(aveicProd[23],4)+'</Cilin>'
	cString += '<pesol>'+ConvType(aveicProd[07],9)+'</pesol>'
	cString += '<pesob>'+ConvType(aveicProd[08],9)+'</pesob>'
	cString += '<nserie>'+ConvType(aveicProd[09],9)+'</nserie>'
	cString += '<tpcomb>'+ConvType(aveicProd[10],2)+'</tpcomb>'
	cString += '<nmotor>'+ConvType(aveicProd[11],21)+'</nmotor>'
	cString += '<CMT>'+ConvType(aveicProd[24],9)+'</CMT>' 
	cString += '<dist>'+ConvType(aveicProd[13],4)+'</dist>'
	cString += '<anomod>'+ConvType(aveicProd[15],4)+'</anomod>'
	cString += '<anofab>'+ConvType(aveicProd[16],4)+'</anofab>'
	cString += '<tppint>'+ConvType(aveicProd[17],1)+'</tppint>'
	cString += '<tpveic>'+ConvType(aveicProd[18],2)+'</tpveic>'
	cString += '<espvei>'+SubStr(aveicProd[19],2,1)+'</espvei>'  // Considera apenas a segunda posição do campo CD9_ESPVEI
	cString += '<vin>'+ConvType(aveicProd[20],1)+'</vin>'
	cString += '<condvei>'+ConvType(aveicProd[21],1)+'</condvei>'
	cString += '<cmod>'+ConvType(aveicProd[22],6)+'</cmod>'
	cString += '<cCorDENATRAN>'+ConvType(aveicProd[26],2)+'</cCorDENATRAN>'
	cString += '<Lota>'+ConvType(aveicProd[25],3)+'</Lota>'
	cString += '<tpRest>'+ConvType(aveicProd[27],1)+ '</tpRest>'
	cString += '</veicProd>'                            
EndIf 


//Medicamentos
If !Empty(aMed) .And. !Empty(aMed[01])
	cString += '<med>'	
	cString += '<Lote>'+ConvType(aMed[01],20)+'</Lote>'
	cString += NfeTag('<qLote>',ConvType(aMed[02],11,3))
	cString += NfeTag('<dtFab>',ConvType(aMed[03]))
	cString += NfeTag('<dtVal>',ConvType(aMed[04]))
	cString += '<vPMC>'+ConvType(aMed[05],15,2)+'</vPMC>'
	cString += '</med>'                            
EndIf 

//Armas de Fogo
If !Empty(aArma) .And. !Empty(aArma[01])
	cString += '<arma>'	
	cString += '<tpArma>'+ConvType(aArma[01])+'</tpArma>'
	If cVeramb >= "3.10"
		cString += NfeTag('<nSerie>',ConvType(aArma[02],15))
		cString += NfeTag('<nCano>' ,ConvType(aArma[02],15))
	Else
		cString += NfeTag('<nSerie>',ConvType(aArma[02],9))
		cString += NfeTag('<nCano>' ,ConvType(aArma[02],9))
	EndIf
	cString += NfeTag('<descr>' ,ConvType(aArma[03],256))
	cString += '</arma>'                            
EndIf 

//RECOPI
If cVeramb >= "3.10" .and. !Empty(cNumRecopi)
	cString += '<Recopi>'
	cString += '<nRECOPI>'+cNumRecopi+'</nRECOPI>'
	cString += '</Recopi>'
EndIf

If Len(aPedCom) > 0 .And. !Empty(aPedCom[01])
	cString += '<xPed>'+ConvType(aPedCom[01])+'</xPed>'
	cString += '<nItemPed>'+ConvType(aPedCom[02])+'</nItemPed>'
Endif

//Nota Técnica 2013/006
If !Empty(aFCI)
	cString += '<nFCI>'+Alltrim(aFCI[01])+'</nFCI>'
EndIf
cString += '</prod>'
DbSelectArea("SF4")

lIssQn:=(Len(aISSQN)>0 .and. !Empty(aISSQN[01]))

If  !lIssQn    
	If cMVCODREG == "1" .and. SF4->(FieldPos("F4_CSOSN"))>0 .And. !Empty(SF4->F4_CSOSN)
	
		If Len(aIcms)>0			
			cString += '<imposto>'
			cString += '<codigo>ICMSSN</codigo>'
		 	cString += '<cpl>'
		   	cString += '<orig>'+ConvType(aICMS[01])+'</orig>'
		   	cString += '</cpl>' 
		   	cString += '<Tributo>'
			cString += '<CSOSN>'+cCsosn+'</CSOSN>'   
		Else
			cString += '<imposto>'
			cString += '<codigo>ICMSSN</codigo>'
		 	cString += '<cpl>'
		   	cString += '<orig>'+ConvType(aCST[02])+'</orig>'
		   	cString += '</cpl>' 
		   	cString += '<Tributo>'
			cString += '<CSOSN>'+cCsosn+'</CSOSN>' 	
		Endif	
		
		If cCsosn$"900" .And. Len(aIcms)>0	    
			cString += '<modBC>'+ConvType(aICMS[03])+'</modBC>'
			cString += '<vBC>'+ConvType(aICMS[05],15,2)+'</vBC>'
			If Len(aDI)>0 .And. ConvType(aDI[04][1]) == "I19" .And. !Empty(aAdi[14][03])			 
				If cVeramb >= "3.10"
					cString += '<pRedBC>'+ConvType(aAdi[14][03],7,4)+'</pRedBC>'
				Else
					cString += '<pRedBC>'+ConvType(aAdi[14][03],5,2)+'</pRedBC>'
				EndIf
		   	Else
		   		If cVeramb >= "3.10"
		   			cString += '<pRedBC>'+ConvType(aICMS[04],8,4)+'</pRedBC>'
				Else
					cString += '<pRedBC>'+ConvType(aICMS[04],6,2)+'</pRedBC>'
				EndIf		   	
			EndIf
			cString += '<pICMS>'+ConvType(aICMS[06],5,2)+'</pICMS>'
			cString += '<vICMS>'+ConvType(aICMS[07],15,2)+'</vICMS>'
			
		ElseIf cCsosn$"900" .And. Len(aIcms)<=0	  
			cString += '<modBC>'+ConvType(0)+'</modBC>'
			cString += '<vBC>'+ConvType(0,15,2)+'</vBC>'
			If Len(aDI)>0 .And. ConvType(aDI[04][1]) == "I19" .And. !Empty(aAdi[14][03])			 
				If cVeramb >= "3.10"
					cString += '<pRedBC>'+ConvType(aAdi[14][03],7,4)+'</pRedBC>'			 
				Else
					cString += '<pRedBC>'+ConvType(aAdi[14][03],5,2)+'</pRedBC>'
				EndIf
		   	Else
				cString += '<pRedBC>'+ConvType(0,5,2)+'</pRedBC>'		   	
			EndIf
			cString += '<pICMS>'+ConvType(0,5,2)+'</pICMS>'
			cString += '<vICMS>'+ConvType(0,15,2)+'</vICMS>'
			
	    Endif
		
		If cCsosn$"201,202,203,900" .AND. Len(aICMSST)>0	
			cString += '<modBCST>'+ConvType(aICMSST[03])+'</modBCST>'
			If cVeramb >= "3.10"
				cString += '<pmvast>'+ConvType(aICMSST[08],7,4)+'</pmvast>'
				cString += '<pRedBCST>'+ConvType(aICMSST[04],7,4)+'</pRedBCST>'
			Else
				cString += '<pmvast>'+ConvType(aICMSST[08],6,2)+'</pmvast>'
				cString += '<pRedBCST>'+ConvType(aICMSST[04],5,2)+'</pRedBCST>'
			EndIf			
			cString += '<vBCST>'+ConvType(aICMSST[05],15,2)+'</vBCST>'
			cString += '<pICMSST>'+ConvType(aICMSST[06],5,2)+'</pICMSST>'
			cString += '<vICMSST>'+ConvType(aICMSST[07],15,2)+'</vICMSST>'
	    Elseif cCsosn$"201,202,203,900"
	    	cString += '<modBCST>0</modBCST>'
			cString += '<vBCST>'+ConvType(0,15,2)+'</vBCST>'
			cString += '<pICMSST>'+ConvType(0,5,2)+'</pICMSST>'
			cString += '<vICMSST>'+ConvType(0,15,2)+'</vICMSST>'
		Endif
		
		If cCsosn$"500" 
			If aCST[01] = "60" .AND. cTipo=="1"	
				SPEDRastro2(aProd[20],aProd[19],aProd[02],@nBaseIcm,@nValICM)      
		 		If nBaseIcm > 0
		   			cString += '<vBCSTRet>'+ConvType(nBaseIcm,15,2)+'</vBCSTRet>' 
	   			Else
					cString += '<vBCSTRet>'+ConvType(0,15,2)+'</vBCSTRet>'
				Endif
		   		If nValICM > 0
			   		cString += '<vICMSSTRet>'+ConvType(nValICM,15,2)+'</vICMSSTRet>'
		   		Else
			  		cString += '<vICMSSTRet>'+ConvType(0,15,2)+'</vICMSSTRet>
		   		Endif 
		  
			Else 
				cString += '<vBCSTRet>'+ConvType(0,15,2)+'</vBCSTRet>'
				cString += '<vICMSSTRet>'+ConvType(0,15,2)+'</vICMSSTRet>' 
		    Endif	  	
		Endif
		If cCsosn$"101,201,900," .And. Len(aIcms)>0	    
			If cVeramb >= "3.10"
				cString += ' <pCredSN>'+ConvType(aICMS[06],7,4)+'</pCredSN>'    
			Else
				cString += ' <pCredSN>'+ConvType(aICMS[06],5,2)+'</pCredSN>'
			EndIf
			cString += '<vCredICMSSN>'+ConvType(aICMS[07],15,2)+'</vCredICMSSN>'
		ElseIf cCsosn$"101,201,900," .And. Len(aIcms)<=0	  
			cString += '<pCredSN>'+ConvType(0,5,2)+'</pCredSN>'
			cString += '<vCredICMSSN>'+ConvType(0,15,2)+'</vCredICMSSN>'
		Endif
		cString += '</Tributo>'
		cString += '</imposto>'
	
	ElseIf ( Len(aIcms) >0 .And. Len(aIcmsST)> 0 ).And. ( aICMSST[11] == "2" .And. aIcms[13] == "2" ) .And. aCST[01] $ "10-90"

		cString += '<imposto>'
		cString += '<codigo>ICMSPART</codigo>'
		cString += '<cpl>'
		cString += '<orig>'+ConvType(aCST[02])+'</orig>'		
		//cString += '<pmvast>'+ConvType(aICMSST[08],6,2)+'</pmvast>'
		cString += '</cpl>'				
		cString += '<Tributo>'
		cString += '<CST>'+ConvType(aCST[01])+'</CST>' 
		cString += '<modBC>'+ConvType(aICMS[03])+'</modBC>'		
		cString += '<vBC>'+ConvType(aICMS[05],15,2)+'</vBC>'
		//cString += '<pRedBC>'+ConvType(aICMS[04],5,2)+'</pRedBC>'		
		If cVeramb >= "3.10"
			cString += '<aliquota>'+ConvType(aICMS[06],7,4)+'</aliquota>'
		Else
			cString += '<aliquota>'+ConvType(aICMS[06],5,2)+'</aliquota>'
		EndIf
		cString += '<valor>'+ConvType(aICMS[07],15,2)+'</valor>'
		cString += '<modBCST>'+ConvType(aICMSST[03])+'</modBCST>'		
		//cString += '<pRedBCST>'+ConvType(aICMSST[04],5,2)+'</pRedBCST>'	
		cString += '<vBCST>'+ConvType(aICMSST[05],15,2)+'</vBCST>'	
		If cVeramb >= "3.10"	
			cString += '<aliquotaST>'+ConvType(aICMSST[06],7,4)+'</aliquotaST>'
		Else
			cString += '<aliquotaST>'+ConvType(aICMSST[06],5,2)+'</aliquotaST>'
		Endif
		cString += '<valorST>'+ConvType(aICMSST[07],15,2)+'</valorST>'		
		If cVeramb >= "3.10"
			cString += '<pBCOp>'+ConvType(aICMS[04],7,4)+'</pBCOp>'
		Else
			cString += '<pBCOp>'+ConvType(aICMS[04],5,2)+'</pBCOp>'
		EndIf
		cString += '<UFST>'+aDest[09]+'</UFST>'	
		cString += '</Tributo>'
		cString += '</imposto>'
	
	Else		
		cString += '<imposto>'
		cString += '<codigo>ICMS</codigo>'
		If Len(aIcms)>0
			cString += '<cpl>'
			cString += '<orig>'+ConvType(aICMS[01])+'</orig>'
			cString += '</cpl>'
			cString += '<Tributo>'
			
			// No caso de diferimento (CST 51) o cliente que deverá escolher a opção 90
			//   caso esteja utilizando a versão 2.00 da NF-e, enquanto não houver adequação.
			// o sistema não pode forçar o CST 90
			cString += '<CST>'+ConvType(aICMS[02])+'</CST>'
			
	   		If(aCST[1] $ '40,41,50') .Or. ((aCST[1] == '51') .And. lArt186)
	   			cString += '<vBC>'+'0'+'</vBC>'     
				If Len(aICMSZFM)>0 .And. aCST[1] $ '40'
					cString += '<motDesICMS>'+ConvType(aICMSZFM[02])+'</motDesICMS>'
					cMotDesICMS:= ConvType(aICMSZFM[02])   			
				Else
					cString += '<motDesICMS>'+ConvType(aICMS[11])+'</motDesICMS>' 
					cMotDesICMS:= ConvType(aICMS[11])
				EndIf		
			Else
				If aICMS[04] == 100 .And. aICMS[02] == "20"
					cString += '<vBC>'+ConvType(0,15,2)+'</vBC>'
				Else
		    		cString += '<vBC>'+ConvType(iIf(lIcmDevol,aICMS[05],0),15,2)+'</vBC>'
		    	EndIf			
	   		EndIf	
			cString += '<modBC>'+ConvType(aICMS[03])+'</modBC>'
			
			If Len(aDI)>0 .And. ConvType(aDI[04][1]) == "I19" .And. !Empty(aAdi[14][03])
				If cVerAmb >= "3.10"
					cString += '<pRedBC>'+ConvType(aAdi[14][03],7,4)+'</pRedBC>'					
				Else
					cString += '<pRedBC>'+ConvType(aAdi[14][03],5,2)+'</pRedBC>'
				EndIf
			Else
	    			If cVerAmb >= "3.10"
	    				cString += '<pRedBC>'+ConvType(aICMS[04],8,4)+'</pRedBC>'
				Else
					cString += '<pRedBC>'+ConvType(aICMS[04],6,2)+'</pRedBC>'
				EndIf
			EndIf
			
			If ( aCST[1] == '51' .And. lArt186 )
				cString += '<aliquota>0</aliquota>'		
			Else
				If cVerAmb >= "3.10"
					cString += '<aliquota>'+ConvType(iIf(lIcmDevol,aICMS[06],0),7,4)+'</aliquota>'
				Else
					cString += '<aliquota>'+ConvType(iIf(lIcmDevol,aICMS[06],0),5,2)+'</aliquota>'
				EndIf			
			EndIf				
		
			If aICMS[04] == 100 .And. aICMS[02] == "20"
				cString += '<valor>'+ConvType(0,15,2)+'</valor>'
			ElseIf ( aCST[1] == '51' .And. lArt186 )
				cString += '<valor>0</valor>'  
			ElseIf ( aCST[1] == '90' .And. (SubStr(SM0->M0_CODMUN,1,2) == "31" .And. SD2->D2_TIPO == "I" .And. SF4->F4_AJUSTE == "S"))
				cString += '<valor>0</valor>' 				
			Else
				If cVerAmb >= "3.10" .and. aCST[1] $ '51' .and. !Empty(aICMS[12]) .and. !lArt186
					If	aICMS[14] == "3"	
						cString += NfeTag('<vICMSOp>' ,ConvType(iIf(lIcmDevol,aICMS[07],0)+aICMS[12],15,2))
				  		cString += NfeTag('<pDif>' ,ConvType(aICMS[12]/( aICMS[12]+iIf(lIcmDevol,aICMS[07],0))*100,8,4))
				  		cString += NfeTag('<vICMSDif>' ,ConvType(aICMS[12],15,2))
				  		cString += '<valor>'+ConvType(iIf(lIcmDevol,(aICMS[07]+aICMS[12])-aICMS[12],0),15,2)+'</valor>'
					Else		  		
				  		cString += NfeTag('<vICMSOp>' ,ConvType(iIf(lIcmDevol,aICMS[07],0),15,2))
						cString += NfeTag('<pDif>' ,ConvType(aICMS[12]/iIf(lIcmDevol,aICMS[07],0)*100,8,4))
						cString += NfeTag('<vICMSDif>' ,ConvType(aICMS[12],15,2))
						cString += '<valor>'+ConvType(iIf(lIcmDevol,aICMS[07]-aICMS[12],0),15,2)+'</valor>' 		
				  	EndIf
				  			
					nVIcmDif += iIf(lIcmDevol,aICMS[07]-aICMS[12],0)
						/*Na versão 3.10, para CST=51, O Valor do ICMS(vICMS) deve ser a diferença do Valor do ICMS da Operação (vICMSOp) e o Valor do ICMS diferido (vICMSDif),
						para não apresentar a rejeição 353-Valor do ICMS no CST=51 não corresponde a diferença do ICMS operação e ICMS diferido*/
					  	
				ElseIf cVerAmb >= "3.10" .and. aCST[1] $ '51' .and. Empty(aICMS[12]) .and. Empty(aICMS[07])
					cString += '<vICMSOp>0</vICMSOp>'
					cString += '<pDif>100.00</pDif>'
					cString += '<vICMSDif>0</vICMSDif>'
					cString += '<valor>0</valor>'
					nVIcmDif += 0
				Else				
					cString += '<valor>'+ConvType(iIf(lIcmDevol,aICMS[07],0),15,2)+'</valor>'					
				EndIf
				if !empty(cMotDesICMS)
					nDesonICM := ConvType(aICMS[07],15,2)
					If cVerAmb >= "3.10"
						nVicmsDeson += iIf(lIcmDevol,aICMS[07],0)
					EndIf
				endif	
			EndIf
			
			If cVerAmb >= "3.10" .and. (aCST[1] $ '20,70,90') .and. !Empty(aICMS[11])
				cString += NfeTag('<motDesICMS>' ,ConvType(aICMS[11]))
				If aICMS[04] == 100 .And. aICMS[02] == "20"
					cString += NfeTag('<vICMSDeson>' ,ConvType(0,15,2))
					nVicmsDeson += 0
				Else
					cString += NfeTag('<vICMSDeson>' ,ConvType(iIf(lIcmDevol,aICMS[07],0),15,2))
					nVicmsDeson += iIf(lIcmDevol,aICMS[07],0)
				Endif							
			EndIf
			
			cString += '<qtrib>'+ConvType(aICMS[09],16,4)+'</qtrib>'
			cString += '<vltrib>'+ConvType(aICMS[10],15,4)+'</vltrib>'			
			cString += '</Tributo>'
		Else
			cString += '<cpl>'
			cString += '<orig>'+ConvType(aCST[02])+'</orig>'
			cString += '</cpl>'
			cString += '<Tributo>'
			cString += '<CST>'+ConvType(aCST[01])+'</CST>'	
			cString += '<modBC>'+ConvType(3)+'</modBC>'
			If Len(aDI)>0 .And. ConvType(aDI[04][1]) == "I19"
				If !Empty(aAdi[14][03])
					If cVerAmb >= "3.10"
						cString += '<pRedBC>'+ConvType(aAdi[14][03],7,4)+'</pRedBC>'
					Else
						cString += '<pRedBC>'+ConvType(aAdi[14][03],5,2)+'</pRedBC>'
					EndIf
			    Else
					cString += '<pRedBC>'+ConvType(0,5,2)+'</pRedBC>'
				EndIf
			Elseif aProd[23]=="20" .And. aProd[22]>0
				If cVerAmb >= "3.10"
					cString += '<pRedBC>'+ConvType(aProd[22],7,4)+'</pRedBC>'
				Else
					cString += '<pRedBC>'+ConvType(aProd[22],5,2)+'</pRedBC>'
				Endif
			Endif	
			cString += '<vBC>'+ConvType(0,15,2)+'</vBC>'
			cString += '<aliquota>'+ConvType(0,5,2)+'</aliquota>'
			If Len(aICMSZFM)>0 .And. aCST[1] $ '40'
				cString += '<motDesICMS>'+ConvType(aICMSZFM[02])+'</motDesICMS>'  			
			EndIf			
			If Len(aICMSZFM)>0 .And. aCST[1] $ '40'
				cString += '<valor>'+ConvType(aICMSZFM[01]-aProd[31]-aProd[32],15,4)+'</valor>'
			Else
				cString += '<valor>'+ConvType(0,15,2)+'</valor>'
			EndIf			
			cString += '<qtrib>'+ConvType(0,16,4)+'</qtrib>'
			cString += '<vltrib>'+ConvType(0,15,4)+'</vltrib>'
			cString += '</Tributo>'
		EndIf
		cString += '</imposto>'
	Endif
	If Len(aIcmsST)>0	
		Do Case
			Case aICMSST[03] == "0"
				aICMSST[03] := "4"
			Case aICMSST[03] == "1"
				aICMSST[03] := "5"
			OtherWise
				aICMSST[03] := "0"
		EndCase		
		cString += '<imposto>'
		cString += '<codigo>ICMSST</codigo>'
		cString += '<cpl>'
		If cVerAmb >= "3.10"
			cString += '<pmvast>'+ConvType(aICMSST[08],7,4)+'</pmvast>'
		Else
			cString += '<pmvast>'+ConvType(aICMSST[08],6,2)+'</pmvast>'
		EndIf
		cString += '</cpl>'
		cString += '<Tributo>'
		cString += '<CST>'+ConvType(aICMSST[02])+'</CST>'	
		cString += '<modBC>'+ConvType(aICMSST[03])+'</modBC>'
		If cVerAmb >= "3.10"
			cString += '<pRedBC>'+ConvType(aICMSST[04],7,4)+'</pRedBC>'
		Else
			cString += '<pRedBC>'+ConvType(aICMSST[04],5,2)+'</pRedBC>'
		EndIf
		cString += '<vBC>'+ConvType(aICMSST[05],15,2)+'</vBC>'
		If cVerAmb >= "3.10"
			cString += '<aliquota>'+ConvType(aICMSST[06],7,4)+'</aliquota>'
		Else
			cString += '<aliquota>'+ConvType(aICMSST[06],5,2)+'</aliquota>'
		EndIf
		If cVerAmb >= "3.10" .and. (aCST[1] $ '30') .and. !Empty(SFT->FT_MOTICMS)//!Empty(aICMS[11])
			cString += NfeTag('<motDesICMS>' ,ConvType(SFT->FT_MOTICMS))//ConvType(aICMS[11]))
			//cString += NfeTag('<vICMSDeson>' ,ConvType(aICMSST[07],15,2))
			cString += NfeTag('<vICMSDeson>' ,ConvType(aProd[26],15,2))
			nVicmsDeson += aProd[26]
		EndIf
		cString += '<valor>'+ConvType(aICMSST[07],15,2)+'</valor>'
		cString += '<qtrib>'+ConvType(aICMSST[09],16,4)+'</qtrib>'
		cString += '<vltrib>'+ConvType(aICMSST[10],15,4)+'</vltrib>'
		cString += '</Tributo>'
		cString += '</imposto>'		
	ELse
		cString += '<imposto>'
		cString += '<codigo>ICMSST</codigo>'
		cString += '<cpl>'
		cString += '<pmvast>0</pmvast>'
		cString += '</cpl>'
		cString += '<Tributo>'
		cString += '<CST>'+ConvType(aCST[01])+'</CST>'          
		If aCST[01] = "60" .AND. cTipo=="1"		
			SPEDRastro2(aProd[20],aProd[19],aProd[02],@nBaseIcm,@nValICM,,,lCalcMed)      
			If nBaseIcm > 0 .and. nValICM>0
		   		If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
					cMensFis += " "
				EndIf
			    If SF4->F4_ART274 == "1"  .And. Upper(SM0->M0_ESTCOB) == "SP"  
					nBaseIcm := aProd[09]*nBaseIcm
					nValICM  := aProd[09]*nValICM										
					cMensFis += "Imposto Recolhido por Substituição - Artigo 274 do RICMS (Lei 6.374/89, art.67,Paragrafo 1o., e Ajuste SINIEF-4/93',cláusa terceira, na redação do Ajuste SINIEF-1/94) 'Cod.Produto:  " +ConvType(aProd[02])+" ' Valor da Base de ST: R$ " +str(nBaseIcm,15,2)+" Valor de ICMS ST: R$ "+str(nValICM,15,2)+" "
			   
				ElseIF SF4->F4_ART274 == "1"  .And. Upper(SM0->M0_ESTCOB) == "PR"  
					nBaseIcm := aProd[09]*nBaseIcm
					nValICM  := aProd[09]*nValICM
					if SF4->F4_CODIGO > "500"  /* TES de Saída */  
						cMensFis += " Imposto Recolhido por Substituição - Artigo 2., II , Anexo X , do RICMS/PR Decreto 6080/2012, onde o 'Cod.Produto:  " +ConvType(aProd[02])+" '  Valor da Base de ST: R$ " +str(nBaseIcm,15,2)+" Valor de ICMS ST: R$ "+str(nValICM,15,2)+" "
					else //entrada
						cMensFis += " Imposto Recolhido por Substituição - Artigo 4., II , Anexo X , do RICMS/PR Decreto 6080/2012, onde o 'Cod.Produto:  " +ConvType(aProd[02])+" '  Valor da Base de ST: R$ " +str(nBaseIcm,15,2)+" Valor de ICMS ST: R$ "+str(nValICM,15,2)+" "
					endif
					/* Conforme consulta realizado no chamado TIBIKO
					cMensFis += "Imposto Recolhido por Substituição - Artigo 471 do RICMS (Parágrafo 1o, alínea B, inciso II, onde o 'Cod.Produto:  " +ConvType(aProd[02])+" ' Valor da Base de ST: R$ " +str(nBaseIcm,15,2)+" Valor de ICMS ST: R$ "+str(nValICM,15,2)+" "
					*/
				ElseIF SF4->F4_ART274 == "1"  .And. Upper(SM0->M0_ESTCOB) == "SC"  
					lPesFisica := IIF(SA1->A1_PESSOA=="F",.T.,.F.)
					lNContrICM := IIf(Empty(SA1->A1_INSCR) .Or. "ISENT"$SA1->A1_INSCR .Or. "RG"$SA1->A1_INSCR .Or. ( SA1->(FieldPos("A1_CONTRIB"))>0 .And. SA1->A1_CONTRIB == "2"),.T.,.F.)
					
					If !lPesFisica .And. !lNContrICM 
						nBaseIcm := aProd[09]*nBaseIcm
						nValICM  := aProd[09]*nValICM
						cMensFis += "Imposto Retido por Substituição Tributária - RICMS-SC/01 - Anexo 3. 'Cod.Produto: " +ConvType(aProd[02])+" '  Valor da Base de ST: R$ " +str(nBaseIcm,15,2)+"  Valor de ICMS ST: R$ "+str(nValICM,15,2)+" "
					EndIf	 	
				ElseIF SF4->F4_ART274 == "1"  .And. Upper(SM0->M0_ESTCOB) == "AM"
				 	lNContrICM := IIf(Empty(SA1->A1_INSCR) .Or. "ISENT"$SA1->A1_INSCR .Or. "RG"$SA1->A1_INSCR .Or. ( SA1->(FieldPos("A1_CONTRIB"))>0 .And. SA1->A1_CONTRIB == "2"),.T.,.F.)
				 	
				 	If (lNContrICM .And. SA1->A1_EST <> "AM") .Or. SA1->A1_EST == "AM"  //Conforme consulta (TGVUIP).
				 		cMensFis += "Mercadoria já tributada nas demais fases de comercialização - Convênio ou Protocolo ICMS nº "+Alltrim(aProd[28])+ ". Cod.Produto: " +ConvType(aProd[02])+"."
				 	EndIf
				
				ElseIF SF4->F4_ART274 == "1"  .And. Upper(SM0->M0_ESTCOB) == "RS"			 
				 	nBaseIcm := aProd[09]*nBaseIcm
					nValICM  := aProd[09]*nValICM
				 	if !Empty(aProd[28])				 	
				 		cMensFis += "Imposto recolhido por ST nos termos do (Convênio ou Protocolo ICMS nº "+ Alltrim(aProd[28]) +") RICMS-RS. Valor da Base de ICMS ST R$"+ cValToChar(nBaseIcm) +" e valor do ICMS ST R$ "+ cValToChar(nValICM) +". Cod.Produto: " +ConvType(aProd[02])+"." 
				 	else
				 		cMensFis += "Imposto recolhido por ST nos termos do RICMS-RS. Valor da Base de ICMS ST R$"+ cValToChar(nBaseIcm) +" e Valor do ICMS ST R$"+ cValToChar(nValICM) +". Cod.Produto: " +ConvType(aProd[02])+"."
				 	endIf					 	
				ElseIf SF4->F4_ART274 == "1"  .And. Upper(SM0->M0_ESTCOB) == "ES" .And. Len(aICMS) > 0 .And. ( nBaseIcm+nValICM > 0 )
					nBaseIcm := aProd[09]*nBaseIcm
					nValICM  := aProd[09]*nValICM
					
					nValIcmDif := ( (nBaseIcm *  17 )/ 100 ) -  aIcms[7]
								
					cMensFis += "Imposto Recolhido por Substituição RICMS. Cod.Produto:  " +ConvType(aProd[02])+" Base de cálculo da retenção - R$ " + Alltrim(str(nBaseIcm,15,2))+". " 
					cMensFis += "ICMS da operação própria do contribuínte substituto - R$ "+Alltrim(str(aIcms[7],15,2))+". "
					cMensFis += "ICMS retido pelo contribuinte substituto - R$ " +Alltrim(str(nValIcmDif,15,2))+". "
				ElseIf SF4->F4_ART274 == "1"  .And. Upper(SM0->M0_ESTCOB) == "MG" .And. Len(aICMS) > 0 .And. ( nBaseIcm+nValICM > 0 )  // Conforme Chamado TIABCS
					nBaseIcm := aProd[09]*nBaseIcm
					nValICM  := aProd[09]*nValICM
					
					nValIcmDif := ( (nBaseIcm *  18 )/ 100 ) -  aIcms[7]
					
					cMensFis += "Imposto Recolhido por Substituição - ICMS retido pelo cliente S.T. DECRETO 43708 19/12/2009."
					cMensFis += " Valor da Base de ST: R$ "+Alltrim(str(nBaseIcm,15,2))+"."
					cMensFis += " Valor de ICMS ST: R$ "+Alltrim(str(nValICM,15,2))+"."
					cMensFis += " Valor de ICMS: R$"+Alltrim(str(nValIcmDif,15,2))+"."
					
				Else
					If lCalcMed
						nBaseIcm := aProd[09]*nBaseIcm
						nValICM  := aProd[09]*nValICM
					EndIf

					cMensFis += "Imposto Recolhido por Substituição - Contempla os artigos 273, 313 do RICMS. Valor da Base de ST: R$ "+str(nBaseIcm,15,2)+" Valor de ICMS ST: R$ "+str(nValICM,15,2)+" "
				EndIf
	        EndIf
	   		cString += '<modBC>0</modBC>'
			cString += '<pRedBC>'+ConvType(0,5,2)+'</pRedBC>'
		Else
			cString += '<modBC>0</modBC>'
			cString += '<pRedBC>'+ConvType(0,5,2)+'</pRedBC>'	
		Endif
		If nBaseIcm > 0
			cString += '<vBC>'+ConvType(nBaseIcm,15,2)+'</vBC>' 
		Else
			cString += '<vBC>'+ConvType(0,15,2)+'</vBC>'
		Endif
		cString += '<aliquota>'+ConvType(0,5,2)+'</aliquota>'
		If nValICM > 0
			cString += '<valor>'+ConvType(nValICM,15,2)+'</valor>'
		Else
			cString += '<valor>'+ConvType(0,15,2)+'</valor>'
		Endif   
	
		cString += '<qtrib>'+ConvType(0,16,4)+'</qtrib>'
		cString += '<vltrib>'+ConvType(0,15,4)+'</vltrib>'
		cString += '</Tributo>'
		cString += '</imposto>'		
			
	EndIf
		
							
	If Len(aIPI)>0 
		cString += '<imposto>'
		cString += '<codigo>IPI</codigo>'
		cString += '<cpl>'
		cString += NfeTag('<clEnq>',ConvType(AIPI[01]))
		cString += NfeTag('<cSelo>',ConvType(AIPI[02]))
		cString += NfeTag('<qSelo>',ConvType(AIPI[03]))
		cString += NfeTag('<cEnq>' ,ConvType(AIPI[04]))
		cString += '</cpl>'
		cString += '<Tributo>'
		cString += '<CST>'+ConvType(AIPI[05])+'</CST>'
		cString += '<modBC>'+ConvType(AIPI[11])+'</modBC>'
		If cVerAmb >= "3.10"
			cString += '<pRedBC>'+ConvType(AIPI[12],7,4)+'</pRedBC>'
		Else
			cString += '<pRedBC>'+ConvType(AIPI[12],5,2)+'</pRedBC>'
		EndIf
		cString += '<vBC>'  +ConvType(AIPI[06],15,2)+'</vBC>'
		If cVerAmb >= "3.10"
			cString += '<aliquota>'+ConvType(AIPI[09],7,4)+'</aliquota>'
		Else
			cString += '<aliquota>'+ConvType(AIPI[09],5,2)+'</aliquota>'
		EndIf
		cString += '<vlTrib>'+ConvType(AIPI[08],15,4)+'</vlTrib>'
		cString += '<qTrib>'+ConvType(AIPI[07],16,4)+'</qTrib>'
		cString += '<valor>'+ConvType(AIPI[10],15,2)+'</valor>'
		cString += '</Tributo>'
		cString += '</imposto>'
	ElseIf Len(aCSTIPI) > 0  .And. !Empty(cIpiCst)
		cString += '<imposto>'
		cString += '<codigo>IPI</codigo>'
		cString += '<Tributo>'
		cString += '<cpl>'
		cString += NfeTag('<cEnq>' ,"999")
		cString += '</cpl>'
		cString += '<CST>'+ConvType(cIpiCst)+'</CST>'
		cString += '<modBC>'+ConvType(3)+'</modBC>'
		cString += '<pRedBC>'+ConvType(0,5,2)+'</pRedBC>'
		cString += '<vBC>'  +ConvType(0,15,2)+'</vBC>'
		cString += '<aliquota>'+ConvType(0,5,2)+'</aliquota>'
		cString += '<vlTrib>'+ConvType(0,15,4)+'</vlTrib>'
		cString += '<qTrib>'+ConvType(0,16,4)+'</qTrib>'
		cString += '<valor>'+ConvType(0,15,2)+'</valor>'
		cString += '</Tributo>'
		cString += '</imposto>'
	EndIf
Else
	If Len(aISSQN)>0 .and. !Empty(aISSQN[01])
		cString += '<imposto>'
		cString += '<codigo>ISS</codigo>'
		cString += '<Tributo>'
		cString += '<vBC>'+ConvType(aISSQN[01],15,2)+'</vBC>'
		If cVerAmb >= "3.10"
			cString += '<aliquota>'+ConvType(aISSQN[02],7,4)+'</aliquota>'
		Else
			cString += '<aliquota>'+ConvType(aISSQN[02],5,2)+'</aliquota>'
		EndIf
		cString += '<Valor>'+ConvType(aISSQN[03],15,4)+'</Valor>'
		If cVerAmb >= "3.10"
			cString += NfeTag('<deducao>',ConvType(aISSQN[07],15,2))//SF3->F3_ISSSUB + SF3->F3_ISSMAT
			cString += NfeTag('<outro>',ConvType(0,15,2))//atualmente nao existe valor de Outras retencoes 
			cString += NfeTag('<descIncond>',ConvType(0,15,2))//atualmente nao existe valor de Desconto Incondicionado
			cString += NfeTag('<descCond>',ConvType(0,15,2))//atualmente nao existe valor de Desconto condicionado
			cString += NfeTag('<Issret>',ConvType(aISSQN[09],15,2))				
		EndIf
		cString += '</Tributo>'
		cString += '<cpl>'
		cString += '<cmunfg>'+ConvType(SM0->M0_CODMUN)+'</cmunfg>'	
		cString += '<clistserv>'+aISSQN[05]+'</clistserv>'
		If cVerAmb >= "3.10"
			cString += '<Indiss>'+aISSQN[08]+'</Indiss>'
			cString += NfeTag('<codserv>',ConvType(aProd[34],20))//B1_TRIBMUN
			cString += NfeTag('<cmunInc>',ConvType(cMunPres),7)
			cString += NfeTag('<codpais>',aDest[11])
			cString += NfeTag('<processo>',ConvType(cMVNumProc,30))
			cString += '<incentivo>'+ConvType(cMVINCEFIS,1)+'</incentivo>'
		Else
			cString += '<cSitTrib>'+ConvType(aISSQN[06])+'</cSitTrib>'
		EndIf		 	
		cString += '</cpl>'		
		cString += '</imposto>'
	EndIf
	If cVerAmb >= "3.10"
		If Len(aIPI)>0 
			cString += '<imposto>'
			cString += '<codigo>IPI</codigo>'
			cString += '<cpl>'
			cString += NfeTag('<clEnq>',ConvType(AIPI[01]))
			cString += NfeTag('<cSelo>',ConvType(AIPI[02]))
			cString += NfeTag('<qSelo>',ConvType(AIPI[03]))
			cString += NfeTag('<cEnq>' ,ConvType(AIPI[04]))
			cString += '</cpl>'
			cString += '<Tributo>'
			cString += '<CST>'+ConvType(AIPI[05])+'</CST>'
			cString += '<modBC>'+ConvType(AIPI[11])+'</modBC>'
			If cVerAmb >= "3.10"
				cString += '<pRedBC>'+ConvType(AIPI[12],7,4)+'</pRedBC>'
			Else
				cString += '<pRedBC>'+ConvType(AIPI[12],5,2)+'</pRedBC>'
			EndIf
			cString += '<vBC>'  +ConvType(AIPI[06],15,2)+'</vBC>'
			If cVerAmb >= "3.10"
				cString += '<aliquota>'+ConvType(AIPI[09],7,4)+'</aliquota>'
			Else
				cString += '<aliquota>'+ConvType(AIPI[09],5,2)+'</aliquota>'
			EndIf
			cString += '<vlTrib>'+ConvType(AIPI[08],15,4)+'</vlTrib>'
			cString += '<qTrib>'+ConvType(AIPI[07],16,4)+'</qTrib>'
			cString += '<valor>'+ConvType(AIPI[10],15,2)+'</valor>'
			cString += '</Tributo>'
			cString += '</imposto>'
		ElseIf Len(aCSTIPI) > 0  .And. !Empty(cIpiCst)
			cString += '<imposto>'
			cString += '<codigo>IPI</codigo>'
			cString += '<Tributo>'
			cString += '<cpl>'
			cString += NfeTag('<cEnq>' ,"999")
			cString += '</cpl>'
			cString += '<CST>'+ConvType(cIpiCst)+'</CST>'
			cString += '<modBC>'+ConvType(3)+'</modBC>'
			cString += '<pRedBC>'+ConvType(0,5,2)+'</pRedBC>'
			cString += '<vBC>'  +ConvType(0,15,2)+'</vBC>'
			cString += '<aliquota>'+ConvType(0,5,2)+'</aliquota>'
			cString += '<vlTrib>'+ConvType(0,15,4)+'</vlTrib>'
			cString += '<qTrib>'+ConvType(0,16,4)+'</qTrib>'
			cString += '<valor>'+ConvType(0,15,2)+'</valor>'
			cString += '</Tributo>'
			cString += '</imposto>'
		EndIf
	EndIf
EndIf
cString += '<imposto>'
cString += '<codigo>PIS</codigo>'
If Len(aPIS)>0
	cString += '<Tributo>'
	cString += '<CST>'+ConvType(aPIS[01])+'</CST>'
	cString += '<modBC></modBC>'
	cString += '<pRedBC></pRedBC>'
	cString += '<vBC>'+ConvType(aPIS[02],15,2)+'</vBC>'
	If cVerAmb >= "3.10"
		cString += '<aliquota>'+ConvType(aPIS[03],7,4)+'</aliquota>'
	Else
		cString += '<aliquota>'+ConvType(aPIS[03],5,2)+'</aliquota>'
	Endif
	cString += '<vlTrib>'+ConvType(aPIS[06],15,4)+'</vlTrib>'
	cString += '<qTrib>'+ConvType(aPIS[05],16,4)+'</qTrib>'
	cString += '<valor>'+ConvType(aPIS[04],15,2)+'</valor>'
	cString += '</Tributo>'
	nValPis += aPIS[04]
Else
	cString += '<Tributo>'
	
	If len(aPisAlqZ) > 0 .and. !empty(aPisAlqZ[01])
		cString += '<CST>'+ConvType(aPisAlqZ[01])+'</CST>'
	Else
		cString += '<CST>08</CST>'
	EndIf
	cString += '<modBC></modBC>'
	cString += '<pRedBC></pRedBC>'
	cString += '<vBC>'+ConvType(0,15,2)+'</vBC>'
	cString += '<aliquota>'+ConvType(0,5,2)+'</aliquota>'
	cString += '<vlTrib>'+ConvType(0,15,4)+'</vlTrib>'
	cString += '<qTrib>'+ConvType(0,16,4)+'</qTrib>'
	cString += '<valor>'+ConvType(0,15,2)+'</valor>'
	cString += '</Tributo>'
EndIf
cString += '</imposto>'
If Len(aPISST)>0
	cString += '<imposto>'
	cString += '<codigo>PISST</codigo>'
	cString += '<Tributo>'
	cString += '<CST>'+ConvType(aPISST[01])+'</CST>'
	cString += '<modBC></modBC>'
	cString += '<pRedBC></pRedBC>'
	cString += '<vBC>'+ConvType(aPISST[02],15,2)+'</vBC>'
	If cVerAmb >= "3.10"
		cString += '<aliquota>'+ConvType(aPISST[03],7,4)+'</aliquota>'
	Else
		cString += '<aliquota>'+ConvType(aPISST[03],5,2)+'</aliquota>'
	EndIf
	cString += '<vlTrib>'+ConvType(aPISST[06],15,4)+'</vlTrib>'
	cString += '<qTrib>'+ConvType(aPISST[05],16,4)+'</qTrib>'
	cString += '<valor>'+ConvType(aPISST[04],15,2)+'</valor>'
	cString += '</Tributo>'
	cString += '</imposto>'
	nValPis += aPISST[04]
EndIf
cString += '<imposto>'
cString += '<codigo>COFINS</codigo>'
If Len(aCOFINS)>0
	cString += '<Tributo>'
	cString += '<CST>'+ConvType(aCOFINS[01])+'</CST>'
	cString += '<modBC></modBC>'
	cString += '<pRedBC></pRedBC>'
	cString += '<vBC>'+ConvType(aCOFINS[02],15,2)+'</vBC>'
	If cVerAmb >= "3.10"
		cString += '<aliquota>'+ConvType(aCOFINS[03],7,4)+'</aliquota>'
	Else
		cString += '<aliquota>'+ConvType(aCOFINS[03],5,2)+'</aliquota>'
	EndIf
	cString += '<vlTrib>'+ConvType(aCOFINS[06],15,4)+'</vlTrib>'
	cString += '<qTrib>'+ConvType(aCOFINS[05],16,4)+'</qTrib>'
	cString += '<valor>'+ConvType(aCOFINS[04],15,2)+'</valor>'
	cString += '</Tributo>'
	nValCof += aCOFINS[04]
Else
	cString += '<Tributo>'
	
	If len(aCofAlqZ) > 0 .and. !Empty(aCofAlqZ[01])
		cString += '<CST>'+ConvType(aCofAlqZ[01])+'</CST>'
	Else
		cString += '<CST>08</CST>'
	EndIf                       
	
	cString += '<modBC></modBC>'
	cString += '<pRedBC></pRedBC>'
	cString += '<vBC>'+ConvType(0,15,2)+'</vBC>'
	cString += '<aliquota>'+ConvType(0,5,2)+'</aliquota>'
	cString += '<vlTrib>'+ConvType(0,15,4)+'</vlTrib>'
	cString += '<qTrib>'+ConvType(0,16,4)+'</qTrib>'
	cString += '<valor>'+ConvType(0,15,2)+'</valor>'
	cString += '</Tributo>'
EndIf
cString += '</imposto>'

If Len(aCOFINSST)>0
	cString += '<imposto>'
	cString += '<codigo>COFINSST</codigo>'	
	cString += '<Tributo>'
	cString += '<CST>'+ConvType(aCOFINSST[01])+'</CST>'
	cString += '<modBC></modBC>'
	cString += '<pRedBC></pRedBC>'
	cString += '<vBC>'+ConvType(aCOFINSST[02],15,2)+'</vBC>'
	If cVerAmb >= "3.10"
		cString += '<aliquota>'+ConvType(aCOFINSST[03],7,4)+'</aliquota>'
	Else
		cString += '<aliquota>'+ConvType(aCOFINSST[03],5,2)+'</aliquota>'
	EndIf
	cString += '<vlTrib>'+ConvType(aCOFINSST[06],15,4)+'</vlTrib>'
	cString += '<qTrib>'+ConvType(aCOFINSST[05],16,4)+'</qTrib>'
	cString += '<valor>'+ConvType(aCOFINSST[04],15,2)+'</valor>'
	cString += '</Tributo>'
	cString += '</imposto>'
	nValCof += aCOFINSST[04]
EndIf 
 	If lMvPisCofD  .And. aDest[9] == 'PR'  // Lei Est. PR 17.127/12 informar todos os impostos na Danfe
		cMensFis += " Conforme Lei Estadual PR 17.127/12 segue o Valor Pis / Cofins:"
		cMensFis += " Valor Pis R$ " + ConvType(nValPis,15,2) 
		cMensFis += " Valor Cofins R$ " + ConvType(nValCof,15,2)
EndIf

If !lIssQn
	// Tratamento de imposto de importacao quando 
	If Len(aDI)>0 .And. ConvType(aDI[04][1]) == "I19"
		cString += '<imposto>'
		cString += '<codigo>II</codigo>'
		cString += '<Tributo>'
		cString += '<vBC>'      +ConvType(aDI[17][03],15,2)+'</vBC>'
		cString += '<Valor>'    +ConvType(aDI[19][03],15,2)+'</Valor>'
		cString += '</Tributo>'			
		cString += '<cpl>'
		cString += '<vDespAdu>' +ConvType(aDI[18][03],15,2)+'</vDespAdu>'
		cString += '<vIOF>'     +ConvType(aDI[20][03],15,2)+'</vIOF>'
		cString += '</cpl>'						
		cString += '</imposto>'
	ElseIf Len(aDI)>0
		cString += '<imposto>'
		cString += '<codigo>II</codigo>'
		cString += '<Tributo>'
		cString += '<vBC>'      +ConvType(aDI[15][03],15,2)+'</vBC>'
		cString += '<Valor>'    +ConvType(aDI[14][03],15,2)+'</Valor>'
		cString += '</Tributo>'			
		cString += '<cpl>'
		cString += '<vDespAdu>' +ConvType(aDI[13][03],15,2)+'</vDespAdu>'
		cString += '<vIOF>'     +ConvType(aDI[16][03],15,2)+'</vIOF>'
		cString += '</cpl>'						
		cString += '</imposto>'	
	EndIf
EndIf
	
//Anfavea Itens
If lAnfavea
	If !Empty(aAnfI) .And. !Empty(aAnfI[01])
		cString += '<AnfaveaProd>'
		cString += 	'<![CDATA[<id'
		If !Empty(aAnfI[01])
			cString += 	' item="' 		+ convType(Iif(lAnfProd,aAnfI[01],aAnfI[26])) + '"'
		Endif
		If !Empty(aAnfI[02])
			cString += 	' ped="'		+ convType(aAnfI[02]) + '"'
	    Endif
		If !Empty(aAnfI[03])
			cString += 	' sPed="'		+ convType(aAnfI[03]) + '"'
		Endif
		If !Empty(aAnfI[04])
			cString += 	' alt="'		+ convType(aAnfI[04]) + '"'
		Endif	
		If !Empty(aAnfI[05])
			cString += 	' tpF="'		+ convType(aAnfI[05]) + '"'
		Endif
		cString += 	'/><div'
		If !Empty(aAnfI[06])
			cString += 	' uM="'  		+ convType(aAnfI[06]) + '"'
		Endif
		If !Empty(aAnfI[07])
			cString += 	' dVD="'		+ convType(aAnfI[07]) + '"'
		Endif
		If !Empty(aAnfI[08])
			cString += 	' pedR="'		+ convType(aAnfI[08]) + '"'
		Endif
		If !Empty(aAnfI[09])
			cString += 	' pE="'			+ convType(aAnfI[09]) + '"'
		Endif
		If !Empty(aAnfI[10])
			cString += 	' psB="'		+ convType(Alltrim(Str(aAnfI[10],TAMSX3("B1_PESO")[1],TAMSX3("B1_PESO")[2]))) + '"'
		Endif
		If !Empty(aAnfI[11])
			cString += 	' psL="'		+ convType(Alltrim(Str(aAnfI[11],TAMSX3("B1_PESO")[1],TAMSX3("B1_PESO")[2]))) + '"'
		Endif
		cString += 	'/><entg'
		If !Empty(aAnfI[12])
			cString += 	' tCh="'		+ convType(Iif(aAnfI[12]=="PeA",'P&A',aAnfI[12])) + '"'
		Endif
		If !Empty(aAnfI[13])
			cString += 	' ch="'			+ convType(aAnfI[13]) + '"'
		Endif
		If !Empty(aAnfI[14])
			cString += 	' hCh="'		+ convType(aAnfI[14]) + '"'
		Endif
		If !Empty(aAnfI[15])
			cString += 	' qtEm="'		+ convType(Alltrim(Str(aAnfI[15],14,2))) + '"'
		Endif
		If !Empty(aAnfI[16])
			cString += 	' qtlt="'		+ convType(Alltrim(Str(aAnfI[16],14,2))) + '"'
		Endif
		cString += 	'/><dest'
		If !Empty(aAnfI[17])
			cString += 	' dca="'		+ convType(aAnfI[17]) + '"'
		Endif
		If !Empty(aAnfI[18])
			cString += 	' ptU="'		+ convType(aAnfI[18]) + '"'
		Endif
		If !Empty(aAnfI[19])
			cString += 	' trans="'		+ convType(aAnfI[19]) + '"'
		Endif
		cString += 	'/><ctl'
		If !Empty(aAnfI[20])
			cString += 	' ltP="'		+ convType(aAnfI[20]) + '"'
		Endif
		If !Empty(aAnfI[21])
			cString += 	' cPI="'		+ convType(aAnfI[21]) + '"'	
		Endif
		cString += 	'/><ref'
		If !Empty(aAnfI[22])
			cString += 	' nFE="'		+ convType(aAnfI[22]) + '"'	
		Endif
		If !Empty(aAnfI[23])
			cString += 	' sNE="'		+ convType(aAnfI[23]) + '"'	
		Endif
		If !Empty(aAnfI[24])
			cString += 	' cdEm="'		+ convType(aAnfI[24]) + '"'	
		Endif
		If !Empty(aAnfI[25])
			cString += 	' aF="'			+ convType(aAnfI[25]) + '"'	
		Endif
		cString += 	'/>]]>'
		cString += '</AnfaveaProd>'
	Endif
Endif

if !empty(aProd[15]) .And. !empty(cMotDesICMS) .or. ( !empty(cMotDesICMS).and. lIcmDevol .and. !Empty(nDesonICM) ) /*Conforme chamado TILXYR foi incluido o .OR. para incluir devolução na mensagem*/
	cMensDeson := 'Valor Dispensado R$ '+ cValtoChar(nDesonICM) + ', Motivo da Desoneracao do ICMS: '+cMotDesICMS+'.(Ajuste SINIEF 25/12, efeitos a partir de 20.12.12)'
endif


/*Nota Técnica 004 de 2011 conforme chamado - THCTB4 */

if lSuframa .and. Len(aICMSZFM)>0 .and. aCST[1] $ '40' 
	if aIcmsZFM[1] > 0 .and. empty(aProd[15])	
		cMensDeson := 'Valor do ICMS abatido: R$ '+ConvType(aIcmsZFM[1]-aProd[31]-aProd[32],15,2)+ ' ( '+Iif(aProd[33] > 0,AllTrim(Str(aProd[33])),'7')+'% sobre R$ ' +ConvType(aProd[16]*aProd[9],15,2)+ ' ).'
	else
		cMensDeson := 'Valor do ICMS abatido: R$ '+ConvType(aIcmsZFM[1]-aProd[31]-aProd[32],15,2)+ ' ( 7% sobre R$ ' +ConvType((aProd[16]-aProd[15]),15,2)+ ' ). Valor do desconto comercial: R$ '+ConvType(aProd[15],15,2)+'.'	
	endif
endif

If aProd[29] > 0
	cDedIcm := 'Valor do ICMS deduzido R$ '+ cValtoChar(aProd[29] ) + '. Conforme artigo 55 anexo I do RICMS-SP.'
EndIf 

// Valor dos Tributos por Ente Tributante: Federal, Estadual e Municipal
If lMvEnteTrb

	If cMvMsgTrib $ "2-3" .And. cTpCliente == "F" .And. ( ( aProd[35] + aProd[36] + aProd[37] ) > 0 )
	
		lProdItem	:= .T.	

		cCrgTrib	:= 'Valor aproximado do(s) Tributo(s): '

		// Federal
		If aProd[35] > 0
			cPercTrib	:= PercTrib( aProd, lProdItem, "1" )  
			cCrgTrib	+= 'R$ ' + ConvType( aProd[35], 15, 2 ) + " ("+cPercTrib+"%) Federal"
		EndIf

		// Estadual
		If aProd[36] > 0
			cPercTrib	:= PercTrib( aProd, lProdItem, "2" )
			If aProd[35] > 0
				cCrgTrib	+= " e "
			Endif
			cCrgTrib	+= "R$ " + ConvType( aProd[36], 15, 2 ) + " ("+cPercTrib+"%) Estadual"
		EndIf
	
		// Municipal
		If aProd[37] > 0
			cPercTrib	:= PercTrib( aProd, lProdItem, "3" )  
			If aProd[35] > 0 .Or. aProd[36] > 0
				cCrgTrib	+= " e "
			Endif
			cCrgTrib	+= "R$ " + ConvType( aProd[37], 15, 2 ) + " ("+cPercTrib+"%) Municipal."
		EndIf
		
	Endif
	
Else

	If aProd[30] > 0 .And. cMvMsgTrib $ "2-3" .And. cTpCliente == "F"
		lProdItem := .T.	
		cPercTrib := PercTrib(aProd, lProdItem)  
	
		cCrgTrib := 'Valor Aproximado dos Tributos: R$ '+ ConvType(aProd[30],15,2)+ " ("+cPercTrib+"%)."	
	EndIf

Endif

/* Grupo opcional 'impostoDevol' para informar o valor e percentual do IPI devolvido
If cVerAmb >= "3.10"
	cString += '<IPIDEV>'
	cString += '<pdevol>Percentual do IPI devolvido</pdevol>'
	cString += '<vipidevol>Valor do IPI devolvido</vipidevol>'
	cString += '</IPIDEV>'	
EndIf
*/

cString += '<infadprod>'+ConvType(aProd[25],500)+cMensDeson+cDedIcm+cCrgTrib+'</infadprod>'

cString += '</det>' 
Return(cString)

Static Function NfeTotal(aTotal,aRet,aICMS,aICMSST,lIcmDevol,cVerAmb,aISSQN,nVicmsDeson,aNota,nVIcmDif)

Local cString		:= ""
Local cMVREGIESP	:= AllTrim(GetNewPar("MV_REGIESP","2"))
/*1 – Microempresa Municipal; 2 – Estimativa; 3 – Sociedade de Profissionais; 
4 – Cooperativa; 5 – Microempresário Individual (MEI); 
6 – Microempresário e Empresa de Pequeno Porte (ME EPP)*/
Local nX     := 0
Local nBicm := 0
LOcal nVicm := 0
Local nBicmst := 0
LOcal nVicmst := 0
Default nVicmsDeson	:= 0
Default nVIcmDif		:= 0

cString += '<total>'
If Len(aICMS)>0 
	For nX := 1 To Len(aICMS)
		If Len(aICMS[NX]) >0
			nBicm += iIf(lIcmDevol,aICMS[NX][05],0)
			nVicm += iIf(lIcmDevol,aICMS[NX][07],0)
		Endif	
	Next nX
Endif

If Len(aICMSST)>0 
	For nX := 1 To Len(aICMSST)
		If Len(aICMSST[NX]) >0
			nBicmst += aICMSST[NX][05]
			nVicmst += aICMSST[NX][07]
		Endif	
	Next nX
Endif

cString += '<vBC>'+ConvType(nBicm, 15,2)+'</vBC>' 
If SubStr(SM0->M0_CODMUN,1,2) == "31" .And. SD2->D2_TIPO == "I" .And. SF4->F4_AJUSTE == "S"	
	cString += '<vICMS>0</vICMS>'
Else
	If cVerAmb >= "3.10" .and. nVIcmDif > 0
		cString += '<vICMS>'+ConvType(nVicm-nVIcmDif,15,2)+'</vICMS>'
	Else
		cString += '<vICMS>'+ConvType(nVicm,15,2)+'</vICMS>'
	EndIf
EndIf
cString += '<vBCST>'+ConvType(nBicmst,15,2)+'</vBCST>'
cString += '<vICMSST>'+ConvType(nVicmst,15,2)+'</vICMSST>'
cString += '<despesa>'+ConvType(aTotal[01],15,2)+'</despesa>'
cString += '<vNF>'+ConvType(aTotal[02],15,2)+'</vNF>'

If cVerAmb >= "3.10" .and. Len(aISSQN)>0
	cString += NfeTag('<cRegTrib>',ConvType(cMVREGIESP,1))
	cString += '<dCompet>'+Strtran(ConvType(aNota[03]),"-","")+'</dCompet>'
EndIf	
If Len(aRet)>0
	For nX := 1 To Len(aRet)
		cString += '<TributoRetido>'
		cString += NfeTag('<codigo>' ,ConvType(aRet[nX,01],15,2))
		cString += NfeTag('<BC>'     ,ConvType(aRet[nX,02],15,2))
		cString += NfeTag('<valor>',ConvType(aRet[nX,03],15,2))
		cString += '</TributoRetido>'
/*	    If aRet[nX,01] =='PIS'
	    	nValPis += ConvType(aRet[nX,03],15,2)
	    EndIf
	    If aRet[nX,01] =='COFINS'
	    	nValCof += ConvType(aRet[nX,03],15,2)
	    EndIf		*/
	Next nX
EndIf
cString += '</total>'

//Variavel para ter o valor total da nota para ser utilizado na Lei da Transparencia
nTotNota 	:= Val(ConvType(aTotal[02],15,2))

Return(cString)

Static Function NfeTransp(cModFrete,aTransp,aImp,aVeiculo,aReboque,aVol,cVerAmb,aReboqu2)
           
Local nX := 0
Local cString := ""

DEFAULT aTransp := {}
DEFAULT aImp    := {}
DEFAULT aVeiculo:= {}
DEFAULT aReboque:= {}
DEFAULT aReboqu2:= {}
DEFAULT aVol    := {}

cString += '<transp>'
If cVerAmb >= "2.00"
	If cModFrete == ""
		cString += '<modFrete>'+"1"+'</modFrete>' 
	Else 
		cString += '<modFrete>'+cModFrete+'</modFrete>'
	Endif
Endif

If Len(aTransp)>0
	cString += '<transporta>'
		If Len(aTransp[01])==14
			cString += NfeTag('<CNPJ>',aTransp[01])
		ElseIf Len(aTransp[01])<>0
			cString += NfeTag('<CPF>',aTransp[01])
		EndIf
		cString += NfeTag('<Nome>' ,ConvType(aTransp[02]))
		cString += NfeTag('<IE>'    ,aTransp[03])
		cString += NfeTag('<Ender>',ConvType(aTransp[04]))
		cString += NfeTag('<Mun>'  ,ConvType(aTransp[05]))
		cString += NfeTag('<UF>'    ,ConvType(aTransp[06]))
	cString += '</transporta>'
	If Len(aImp)>0 //Ver Fisco
		cString += '<retTransp>'
		cString += '<codigo>ICMS<codigo>'
		cString += '<Cpl>'
		cString += '<vServ>'+ConvType(aImp[01],15,2)+'</vServ>'
		cString += '<CFOP>'+ConvType(aImp[02])+'</CFOP>'
		cString += '<cMunFG>'+aImp[03]+'</cMunFG>'		
		cString += '</Cpl>'
		cString += '<CST>'+ConvType(aImp[04])+'</CST>'
		cString += '<MODBC>'+aImp[05]+'</MODBC>'
		If cVerAmb >= "3.10"
			cString += '<PREDBC>'+ConvType(aImp[06],7,2)+'</PREDBC>'
		Else
			cString += '<PREDBC>'+ConvType(aImp[06],5,2)+'</PREDBC>'
		EndIf
		cString += '<VBC>'+ConvType(aImp[07],15,2)+'</VBC>'
		If cVerAmb >= "3.10"
			cString += '<aliquota>'+ConvType(aImp[08],7,4)+'</aliquota>'
		Else
			cString += '<aliquota>'+ConvType(aImp[08],5,2)+'</aliquota>'
		EndIf
		cString += '<vltrib>'+ConvType(aImp[09],15,4)+'</vltrib>'
		cString += '<qtrib>'+ConvType(aImp[10],16,4)+'</qtrib>'
		cString += '<valor>'+ConvType(aImp[11],15,2)+'</valor>'
		cString += '</retTransp>'
	EndIf
	If Len(aVeiculo)>0
		cString += '<veicTransp>'
			cString += '<placa>'+ConvType(aVeiculo[01])+'</placa>'
			cString += '<UF>'   +ConvType(aVeiculo[02])+'</UF>'
			cString += NfeTag('<RNTC>',ConvType(aVeiculo[03]))
		cString += '</veicTransp>'
	EndIf
	If Len(aReboque)>0
		cString += '<reboque>'
			cString += '<placa>'+ConvType(aReboque[01])+'</placa>'
			cString += '<UF>'   +ConvType(aReboque[02])+'</UF>'
			cString += NfeTag('<RNTC>',ConvType(aReboque[03]))
		cString += '</reboque>'
		If Len(aReboqu2)>0
			cString += '<reboque>'
			cString += '<placa>'+ConvType(aReboqu2[01])+'</placa>'
			cString += '<UF>'   +ConvType(aReboqu2[02])+'</UF>'
			cString += NfeTag('<RNTC>',ConvType(aReboqu2[03]))
			cString += '</reboque>'
		EndIf
	EndIf	
ElseIf Len(aVeiculo)>0
		cString += '<veicTransp>'
			cString += '<placa>'+ConvType(aVeiculo[01])+'</placa>'
			cString += '<UF>'   +ConvType(aVeiculo[02])+'</UF>'
			cString += NfeTag('<RNTC>',ConvType(aVeiculo[03]))
		cString += '</veicTransp>'
EndIf
For nX := 1 To Len(aVol)		
	cString += '<vol>'
		cString += NfeTag('<qVol>',ConvType(aVol[nX][02]))
		cString += NfeTag('<esp>' ,ConvType(aVol[nX][01],15,0))
		//cString += '<marca>' +aVol[03]+'</marca>'
		//cString += '<nVol>'  +aVol[04]+'</nVol>'
		cString += NfeTag('<pesoL>' ,ConvType(aVol[nX][03],15,3))
		cString += NfeTag('<pesoB>' ,ConvType(aVol[nX][04],15,3))
		//cString += '<nLacre>'+aVol[07]+'</nLacre>'
	cString += '</vol>
Next nX
cString += '</transp>'
Return(cString)

Static Function NfeCob(aDupl)

Local cString := ""

Local nX := 0                  
If Len(aDupl)>0
	cString += '<cobr>'
	For nX := 1 To Len(aDupl)
		cString += '<dup>'
		cString += '<Dup>'+ConvType(aDupl[nX][01])+'</Dup>'
		cString += '<dtVenc>'+ConvType(aDupl[nX][02])+'</dtVenc>'
		cString += '<vDup>'+ConvType(aDupl[nX][03],15,2)+'</vDup>'
		cString += '</dup>'
	Next nX	
	cString += '</cobr>'
EndIf

Return(cString)

Static Function NfeInfAd(cMsgCli,cMsgFis,aPedido,aExp,cAnfavea,aMotivoCont,aNfSa,aNfVinc,aProd,aDI,aNfVincRur,aRet,cNfRefcup,cSerRefcup,cTipo,nIPIConsig,nSTConsig,lBrinde,cVerAmb)

Local aEEC		:= {} 
Local aNcm		:= {} 

Local cString	:= ""
Local cCfor	:= ""
Local cLojaEn	:= ""       
Local cCnpjen	:= ""       
Local cEmisEn	:= ""
Local cDocEn	:= "" 
Local cSerieEn	:= "" 
Local cNcm		:= ""                                                                        			
Local cUm		:= "" 
Local cChave1	:= ""
Local cValidCh	:= ""
Local cInfRem	:= ""
Local cNfVinc	:= ""
Local cChvNFe	:= ""
Local cNfVincRur	:= ""
Local cPercTrib	:= ""
Local cA		:= ""
Local cMD5Master	:= ""
Local cChvNFeI:= ""

Local nX	:= 0 
Local nY	:= 0
Local nZ	:= 0
Local nW	:= 0
Local nValII	:= 0
Local nI	:= 0
Local nNfVinc := 0

Local lEasy		:= SuperGetMV("MV_EASY") == "S"
Local lImpRet	:= GetNewPar("MV_IMPRET",.F.) 
Local lProdItem	:= .F.	//Define se esta configurado para gerar a mensagem da Lei da Transparencia por Produto ou somente nas informacoes Complementares.
Local lEECFAT	:= SuperGetMv("MV_EECFAT")

DEFAULT aPedido	:= {}
DEFAULT aExp		:= {}
DEFAULT aNfSa		:= {}
DEFAULT aNfVinc	:= {}
DEFAULT aProd		:= {}  
DEFAULT aDI		:= {}  
DEFAULT aNfVincRur	:= {}  
DEFAULT nIPIConsig	:= 0  
DEFAULT nSTConsig		:= 0

DEFAULT cAnfavea	:= ""

cString += '<infAdic>'

If AliasIndic("EYY") 
	aEEC:= AvGetNfRem(aNfSa[2],aNfSa[1]) 
Endif	
//array aEEC:= AvGetNfRem
//documento   1
//serie       2
//fornecedor  3
//loja        4

If len (aEEC)>0
	For nY := 1 To Len(aEEC)        
	   	dbSelectArea("SF1")
		dbSetOrder(1)
		If DbSeek(xFilial("SF1")+aEEC[ny][2][1]+aEEC[ny][2][2]+aEEC[ny][2][3]+aEEC[ny][2][4])
			If cValidCh <> (xFilial("SF1")+aEEC[ny][2][1]+aEEC[ny][2][2]+aEEC[ny][2][3]+aEEC[ny][2][4])
				cCfor      := SF1->F1_FORNECE
			    cLojaEn    := SF1->F1_LOJA
			    dEmisEn    := SF1->F1_EMISSAO  
				cDocEn	   := SF1->F1_DOC
				cSerieEn   := SF1->F1_SERIE
			    cValidCh   := (xFilial("SF1")+aEEC[ny][2][1]+aEEC[ny][2][2]+aEEC[ny][2][3]+aEEC[ny][2][4])
			    
			    dbSelectArea("SA2")
				dbSetOrder(1)
				If DbSeek(xFilial("SA2")+cCfor+cLojaEn)
					cCnpjen    := SA2->A2_CGC
				EndIf   
				
				dbSelectArea("SD1")
				dbSetOrder(1)
				If DbSeek(xFilial("SD1")+cDocEn+cSerieEn+cCfor+cLojaEn)
					dbSelectArea("SB1")
			   		dbSetOrder(1)              
					cChave1 := xFilial("SD1")+cDocEn+cSerieEn+cCfor+cLojaEn
					While !SD1->(Eof())
						If cChave1 == (xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) 
							If DbSeek(xFilial("SB1")+SD1->D1_COD) 
								nPos := Ascan(aNcm,{|x|x[2]==SB1->B1_POSIPI})
								If nPos > 0
									aNcm[nPos,03] += SD1->D1_QUANT 
								Else
									AADD(aNcm,{cChave1,SB1->B1_POSIPI,SD1->D1_QUANT,SB1->B1_UM}) 																
								EndIf
							EndIf 
						EndIf
					 SD1->(DbSkip())
					 Enddo
					 If nY > 1
					 	cInfRem += "CNPJ-CPF Rem."+": "+cCnpjen+"/"
					 Else
					 	cInfRem := "CNPJ-CPF Rem."+": "+cCnpjen+"/"
					 EndIf					 
					 cInfRem += "Numero NF"+": "+cDocEn+"/"+"Serie"+": "+cSerieEn+"/"+"Data Emissao"+": "+StrZero(Day(dEmisEn),2)+'-'+StrZero(Month(dEmisEn),2)+'-'+StrZero(Year(dEmisEn),4)
					 For nX := 1 To Len(aNcm)
					 	cInfRem += +"/"+"NCM-SH"+": "+aNcm[nx,02]+"/"+"UM"+": "+aNcm[nx,04]+"/"+"Quantidade"+": "+AllTrim(Str(aNcm[nx,03]))
					 Next nX
				EndIf
			Endif
		EndIf
	Next ny
EndIf 
//Ato Cotepe 09/2013 - PAF-ECF ER 02.01 - Requisito XXVIII - item 3
If LjNfPafEcf(SM0->M0_CGC) .AND. SuperGetMV("MV_LJPAFEC",,.F.) .AND. !( FindFunction("LjNfNoPaf") .AND. LjNfNoPaf(SM0->M0_CGC) )
    
	If FindFunction("STDRetagPDV")  .and.  STDRetagPDV(xFilial("SLG"))  .AND. Findfunction("STBVerPAFECF")
	
		cMD5Master := STBVerPAFECF("MD5MASTER")
	
	Else
	
		//Carrega dados da Versao Homologada
		If FindFunction("LjVerPAFECF")		
			cMd5Master	:= LjVerPAFECF("MD5MASTER")		
		Else	//Caso nao possua a function, traz como padrao dados da homologacao realizada em 2011 Laudo POL2002011
			cMd5Master	:= IIF(LJAnalisaLeg(57)[1],"EC28FFF525A8851AC2A3EAE572CCD26F",; 	//Versão especial Credenciada no RJ via Laudo POL2002011
													"B300947472D4C482B759DDE8BC07B828") 	//Versão padrão laudo POL2002011
		EndIf
    EndIf

	
	If Len(cMsgFis) > 0
		cMsgFis := "MD-5:" + Upper(cMd5Master) + " " + cMsgFis
	Else
		cMsgFis := "MD-5:" + Upper(cMd5Master)
	EndIf
EndIf
If Len(cMsgFis)>0    
	cString += '<Fisco>'+ConvType(cMsgFis,Len(cMsgFis))+'</Fisco>'
EndIf

cString += '<Cpl>[ContrTSS='+StrZero(Year(ddatabase),4)+'-'+StrZero(Month(ddatabase),2)+'-'+StrZero(Day(ddatabase),2)+'#'+AllTrim(Time())+'#'+AllTrim(SubStr(cUsuario,7,15))+']'

If Len(cInfRem)>0
	cString += ConvType(cInfRem,Len(cInfRem))+" "
EndIf

  
If Len(aMotivoCont)>0
	//cString += ConvType("DANFE emitida em contingencia devido a problemas técnicos - será necessária a substituição.",Len("DANFE emitida em contingencia devido a problemas técnicos - será necessária a substituição."))+" "
	cString += "Motivo da contingencia: "+ConvType(aMotivoCont[1],Len(aMotivoCont[1]))+", com "
	cString += ConvType("inicío em",Len("inicío em"))+" "+StrZero(Day(aMotivoCont[2]),2)+"/"+StrZero(Month(aMotivoCont[2]),2)+"/"+StrZero(Year(aMotivoCont[2]),4)+" "
	cString += ConvType("às",2)+" "+ConvType(aMotivoCont[3],Len(aMotivoCont[3]))+"."
EndIf 
If Len(cMsgCli)>0
	cString += ConvType(cMsgCli,Len(cMsgCli))+" "  
	//A Nota Fiscal de devolução deve ser preenchida com a nota e a data Original de acordo com a legislação:
	//Fundamento: Artigo 136 do RICMS-SP - O contribuinte,  excetuado o produtor,  emitirá Nota Fiscal (Lei nº 6374/89,  art. 67,  
	//Parágrafo 1º,  e Convênio de 15.12.70 - SINIEF, arts. 54 e 56, na redação do Ajuste SINlEF- 3/94, cláusula primeira, XII):.
	IF (SM0->M0_ESTENT) $ "SP" .AND. cTipo=='0' .And. !Empty(cSerRefcup + cNfRefcup)
		SFT->(dbSetOrder(6))
		If SFT->(dbSeek(xFilial("SFT")+"S"+cNfRefcup+cSerRefcup))
			cString += " Artigo 136 do RICMS-SP Emissao Original NF-e: "+cSerRefcup+" "+cNfRefcup+" "+Dtoc(SFT->FT_EMISSAO)+" " 
		EndIf		
	Endif
EndIf   

If Len( aNfVinc ) > 0		//Nota de espécie NFE e CTE vinculada  
	For nZ := 1  to Len( aNfVinc )
		If !( aNfVinc[nZ][2] + aNfVinc[nZ][3] ) $ cChvNFe
			if !Empty(aNfVinc[nZ][6]) .and. "CTE" == UPPER(Alltrim(aNfVinc[nZ][6]))
				cString += "Emissao Original CT-e: "
			else
				cString += "Emissao Original NF-e: "

				//** BRENO **//
				cString := AllTrim(cString)+"Emissao Original NF-e: "
				//**********//
			endif

			cChvNFe += aNfVinc[nZ][2] + aNfVinc[nZ][3] + "|"
			cNfVinc := ( aNfVinc[nZ][2] + " " + aNfVinc[nZ][3] + " " + StrZero( Day( aNfVinc[nZ][1] ), 2 ) + "-" + StrZero( Month( aNfVinc[nZ][1] ), 2 ) + "-" + StrZero( Year( aNfVinc[nZ][1] ), 4 ) + ", " )
			cString += ConvType( cNfVinc, Len( cNfVinc ) ) + " "
			if SM0->M0_ESTENT == 'SP'  // Conforme chamado TIGZGX feito com a Consultoria tributaria
				If Len (aNfVinc[nZ] ) >= 8 .and.  !Empty(aNfVinc[nZ][08])
					nNfVinc:=0
				   	cChvNFeI = aNfVinc[nZ][2] + aNfVinc[nZ][3]
				   	For nI := 1  to Len( aNfVinc )
				   		If ( aNfVinc[nI][2] + aNfVinc[nI][3] ) $ cChvNFeI
				           nNfVinc := nNfVinc + aNfVinc[nI][08]				       
				       endif
					Next nI
					cString += "Valor da Operacao do Documento de Origem: " + ConvType(nNfVinc,15,2) +"."
				endif			
			endif 
		EndIf
	Next nZ
ElseIf Len( aNfVincRur ) > 0 	//Nota de espécie NFP vinculada
	cString += "Emissao Original NFP: "
	For nX := 1  to Len( aNfVincRur )
		If !( aNfVincRur[nX][2] + aNfVincRur[nX][3] ) $ cChvNFe
			cChvNFe += aNfVincRur[nX][2] + aNfVincRur[nX][3] + "|"
			cNfVincRur := ( aNfVincRur[nX][2] + " " + aNfVincRur[nX][3] + " " + StrZero( Day( aNfVincRur[nx][1] ), 2 ) + "-" + StrZero( Month( aNfVincRur[Nx][1] ), 2 ) + "-" + StrZero( Year( aNfVincRur[Nx][1] ), 4 ) + ", " )
			cString += ConvType( cNfVincRur, Len( cNfVincRur ) ) + " "
		EndIf
	Next Nx
EndIf

nValII := 0
For nX := 1 To Len(aProd)
	If Substr(ConvType(aProd[nX,7]),1,1) $ "3" .And. !lEasy 
		If Len(aDI[nx]) > 0 
			nValII += aDI[nX][19][03]
		EndIf
	EndIf
Next
If nValII > 0
	cString += ("Valor total do Imposto de Importacao : R$ " + ConvType(nValII,15,2)+ " .O valor do Imposto de Importacao nao esta embutido no valor dos produtos, somente ao valor total da NF-e.")
Endif

If Len(aRet) > 0 .And. lImpRet
	cString += "Retencoes: "
	For nX :=1 to Len(aRet)
		Do Case
			Case aRet[nX,1] == "PIS"
				cString += "PIS: "+ConvType(aRet[nX,3],15,2)+ "  "
			Case aRet[nX,1] == "COFINS"
				cString += 	"COFINS: " + ConvType(aRet[nX,3],15,2) + "  "
			Case aRet[nX,1] == "CSLL"
				cString += "CSLL: " + ConvType(aRet[nX,3],15,2) + "  "
			Case aRet[nX,1] == "IRRF"
				cString += "IR: " + ConvType(aRet[nX,3],15,2) + "  "
			Case aRet[nX,1] == "INSS"
				cString += "INSS: " + ConvType(aRet[nX,3],15,2) 
		EndCase
	Next
EndIf 

If nIPIConsig > 0
	cString += "Valor do IPI: R$ " + AllTrim(Transform(nIPIConsig, "@ze 9,999,999,999,999.99")) + ". "
EndIf 
If nSTConsig > 0
	cString += "Valor do ICMS ST: R$ " + AllTrim(Transform(nSTConsig, "@ze 9,999,999,999,999.99")) + ". "
endIf	

// Valor dos tributos por Ente Tributante
If lMvEnteTrb

	If cMvMsgTrib $ "1-3" .And. cTpCliente == "F" .And. ( ( nTotFedCrg + nTotEstCrg + nTotMunCrg ) > 0 )

		cString		+= 'Valor Aproximado do(s) Tributo(s): '

		If nTotFedCrg > 0
			cPercTrib	:= PercTrib( Nil , .F., "1" )
			cString		+= 'R$ ' + ConvType( nTotFedCrg, 15, 2 ) + " ("+cPercTrib+"%) Federal"
		EndIf
	
		If nTotEstCrg > 0
			cPercTrib	:= PercTrib( Nil , .F., "2" )
			If nTotFedCrg > 0
				cString	+= ' e '
			Endif
			cString		+= 'R$ ' + ConvType( nTotEstCrg, 15, 2 ) + " ("+cPercTrib+"%) Estadual"
		EndIf
	
		If nTotMunCrg > 0
			cPercTrib	:= PercTrib( Nil , .F., "3" )
			If ( nTotFedCrg + nTotEstCrg ) > 0
				cString	+= ' e '
			Endif
			cString		+= 'R$ ' + ConvType( nTotMunCrg, 15, 2 ) + " ("+cPercTrib+"%) Municipal."
		EndIf
	                             
		If !Empty( cFntCtrb )
			If ( nTotFedCrg + nTotEstCrg + nTotMunCrg ) > 0
				cString += " "
			Endif
			cString += "Fonte: " + cFntCtrb + "."
		Endif

	Endif
		
Else

	If cMvMsgTrib $ "1-3" .And. nTotalCrg > 0 .And. cTpCliente == "F"
		lProdItem := .F.
		cPercTrib := PercTrib( nil , lProdItem)   
		
		If !Empty(cFntCtrb)
			cString += 'Valor Aproximado dos Tributos: R$ ' +ConvType(nTotalCrg,15,2)+ " ("+cPercTrib+"%). Fonte: "+cFntCtrb+"."
		Else
			cString += 'Valor Aproximado dos Tributos: R$ ' +ConvType(nTotalCrg,15,2)+ " ("+cPercTrib+"%)."
		EndIf 
	EndIf

Endif
	
cString:=If(Substr(cString,Len(cString)-1,1) $ ",",Substr(cString,1,Len(cString)-2),cString)
cString += '</Cpl>' 
If !Empty(AllTrim(cAnfavea))
	cString += "<AnfaveaCPL>" + cAnfavea + "</AnfaveaCPL>"
EndIf
cString += '</infAdic>'
       
// Tratamento TAG Exportação integração com EEC Average 
If Len(aExp)>0 .And. !Empty(aExp[01])
	If lEECFAT
	/*Se versão 2.00 considera o retorno das posições 1 e 2
		Se versão 3.10, considera array da posição 4 do primeiro item
	*/
		If cVerAmb == "2.00"
			cString += '<exporta>'
			cString += '<UFEmbarq>'+ConvType(aExp[01][01][03])+ '</UFEmbarq>'
			cString += '<locembarq>'+ConvType(aExp[01][02][03])+ '</locembarq>'
			cString += '</exporta>'	
		EndIf
		If cVerAmb >= "3.10"
			If !Empty(aExp[01][04][03])
				cString += '<exporta>'
				cString += '<UFEmbarq>'+ConvType(aExp[01][04][03][01][03])+ '</UFEmbarq>'
				cString += '<locembarq>'+ConvType(aExp[01][04][03][02][03])+ '</locembarq>'				
				cString += NfeTag('<locdespacho>' ,ConvType(aExp[01][04][03][03][03]))
				cString += '</exporta>'
			EndIf
		EndIf		
	Else
		cString += '<exporta>'
		cString += '<UFEmbarq>'+ConvType(aExp[01][01][01][03])+ '</UFEmbarq>'
		cString += '<locembarq>'+ConvType(aExp[01][01][02][03])+ '</locembarq>'
		If cVerAmb >= "3.10" .And. !Empty(aExp[01][01][07][03])
			cString += NfeTag('<locdespacho>' ,ConvType(aExp[01][01][07][03]))
		EndIf
		cString += '</exporta>'	
	EndIf
EndIf

If Len(aPedido)>0
	If cVerAmb >= "3.10"
		If !Empty(aPedido[01]) .or. !Empty(aPedido[02]) .or. !Empty(aPedido[03])
			cString += '<compra>'
			cString += NfeTag('<nEmp>',aPedido[01])
			cString += NfeTag('<Pedido>',aPedido[02])
			cString += NfeTag('<Contrato>',aPedido[03])
			cString += '</compra>'
		EndIf
	Else
		cString += '<compra>'
		cString += '<nEmp>'+aPedido[01]+'</nEmp>'
		cString += '<Pedido>'+aPedido[02]+'</Pedido>'
		cString += '<Contrato>'+aPedido[03]+'</Contrato>'
		cString += '</compra>'
	EndIf
EndIf	

Return(cString)

Static Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)

Static Function Inverte(uCpo, nDig)
Local cRet	:= ""
Default nDig := 9
/*
Local cCpo	:= uCpo
Local cByte	:= ""
Local nAsc	:= 0
Local nI		:= 0
Local aChar	:= {}
Local nDiv	:= 0
*/
cRet	:=	GCifra(Val(uCpo),nDig)
/*
Aadd(aChar,	{"0", "9"})
Aadd(aChar,	{"1", "8"})
Aadd(aChar,	{"2", "7"})
Aadd(aChar,	{"3", "6"})
Aadd(aChar,	{"4", "5"})
Aadd(aChar,	{"5", "4"})
Aadd(aChar,	{"6", "3"})
Aadd(aChar,	{"7", "2"})
Aadd(aChar,	{"8", "1"})
Aadd(aChar,	{"9", "0"})

For nI:= 1 to Len(cCpo)
   cByte := Upper(Subs(cCpo,nI,1))
   If (Asc(cByte) >= 48 .And. Asc(cByte) <= 57) .Or. ;	// 0 a 9
   		(Asc(cByte) >= 65 .And. Asc(cByte) <= 90) .Or. ;	// A a Z
   		Empty(cByte)	// " "
	   nAsc	:= Ascan(aChar,{|x| x[1] == cByte})
   	If nAsc > 0
   		cRet := cRet + aChar[nAsc,2]	// Funcao Inverte e chamada pelo rdmake de conversao
	   EndIf
	Else
		// Caracteres <> letras e numeros: mantem o caracter
		cRet := cRet + cByte
	EndIf
Next
*/
Return(cRet)

Static Function NfeTag(cTag,cConteudo)

Local cRetorno := ""
If (!Empty(AllTrim(cConteudo)) .And. IsAlpha(AllTrim(cConteudo))) .Or. Val(AllTrim(cConteudo))<>0
	cRetorno := cTag+AllTrim(cConteudo)+SubStr(cTag,1,1)+"/"+SubStr(cTag,2)
EndIf
Return(cRetorno)

Static Function VldIE(cInsc,lContr)

Local cRet	:=	""
Local nI	:=	1
DEFAULT lContr  :=      .T.
For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)
If "ISENT"$Upper(cRet)
	cRet := ""
EndIf
If lContr .And. Empty(cRet)
	cRet := "ISENTO"
EndIf
If !lContr
	cRet := ""
EndIf
Return(cRet)


static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyGetEnd  ³ Autor ³ Liber De Esteban             ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o participante e do DF, ou se tem um tipo de endereco ³±±
±±³          ³ que nao se enquadra na regra padrao de preenchimento de endereco  ³±±
±±³          ³ por exemplo: Enderecos de Area Rural (essa verificção e feita     ³±±
±±³          ³ atraves do campo ENDNOT).                                         ³±±
±±³          ³ Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo    ³±±
±±³          ³ Endereco (sem numero ou complemento). Caso contrario ira retornar ³±±
±±³          ³ o padrao do FisGetEnd                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs.     ³ Esta funcao so pode ser usada quando ha um posicionamento de      ³±±
±±³          ³ registro, pois será verificado o ENDNOT do registro corrente      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyGetEnd(cEndereco,cAlias)

Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
Local aRet		:= {"",0,"",""}

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
If (&(cAlias+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlias+"->"+cCmpEndN) == "1")
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco, (&(cAlias+"->"+cCmpEst)))
EndIf

Return aRet


Static Function NFSeIde(aNotaServ,cNatOper,cTipoRPS,cModXml)
Local cString  := ""
Local cRegTrib := ""
Local cOptSimp := ""
Local cIncCult := ""

If "1"$cModXml //BH - ABRASF
	cString += '<InfRps>'
	cString += '<IdentificacaoRps>'
	cString += '<Numero>'+ConvType(Val(aNotaServ[02]),15)+'</Numero>'
	cString += '<Serie>'+AllTrim(aNotaServ[01])+'</Serie>'             
	cString += '<Tipo>'+cTipoRPS+'</Tipo>'
	cString += '</IdentificacaoRps>' 
	cString += '<DataEmissao>'+ConvType(aNotaServ[03])+"T"+Time()+'</DataEmissao>
	cString += '<NaturezaOperacao>'+cNatOper+'</NaturezaOperacao>'
	cString += '<RegimeEspecialTributacao>'+cRegTrib+'</RegimeEspecialTributacao>'
	cString += '<OptanteSimplesNacional>'+cOptSimp+'</OptanteSimplesNacional>'
	cString += '<IncentivadorCultural>'+cIncCult+'</IncentivadorCultural>'
	cString += '<Status>'+"1"+'</Status>'
	//cString += '<RpsSubstituido>'
	//cString += '<Numero>'+ConvType(Val(aNotaServ[02]),15)+'</Numero>'
	//cString += '<Serie>'+AllTrim(aNotaServ[01])+'</Serie>'             
	//cString += '<Tipo>'+cTipoRPS+'</Tipo>'
	//cString += '</RpsSubstituido>' 
	
Else//ISSNET
	cString += '<tc:InfRps>'
	cString += '<tc:IdentificacaoRps>'
	cString += '<tc:Numero>'+ConvType(Val(aNotaServ[02]),15)+'</tc:Numero>'
	//cString += '<tc:Serie>'+'8'+'</tc:Serie>'             
	cString += '<tc:Serie>'+AllTrim(aNotaServ[01])+'</tc:Serie>'             
	cString += '<tc:Tipo>'+cTipoRPS+'</tc:Tipo>'
	cString += '</tc:IdentificacaoRps>' 
	cString += '<tc:DataEmissao>'+ConvType(aNotaServ[03])+"T"+Time()+'</tc:DataEmissao>
	cString += '<tc:NaturezaOperacao>'+cNatOper+'</tc:NaturezaOperacao>'
	cString += '<tc:RegimeEspecialTributacao>'+cRegTrib+'</tc:RegimeEspecialTributacao>'
	cString += '<tc:OptanteSimplesNacional>'+cOptSimp+'</tc:OptanteSimplesNacional>'
	cString += '<tc:IncentivadorCultural>'+cIncCult+'</tc:IncentivadorCultural>'
	cString += '<tc:Status>'+"1"+'</tc:Status>'
	//cString += '<tc:RpsSubstituido>'
	//cString += '<tc:Numero>'+ConvType(Val(aNotaServ[02]),15)+'</tc:Numero>'
	//cString += '<tc:Serie>'+AllTrim(aNotaServ[01])+'</tc:Serie>'             
	//cString += '<tc:Tipo>'+cTipoRPS+'</tc:Tipo>'
	//cString += '</tc:RpsSubstituido>' 
EndIf
Return( cString )

Static Function NFSeServ(aISSQN,aRet,nDed,nIssRet,cRetIss,cServ,cMunPres,cModXml,cTpPessoa)
Local cString    := ""
Local nBase      := 0
Local nValLiq    := 0
Local nOutRet    := 0

//Base de Cálculo 
nBase      := aISSQN[02]-nDed-aISSQN[06]
//Valor Líquido
If SM0->M0_CODMUN == "3106200" .And. cTpPessoa == "EP"  // Tratamento realizado para o municipio de Belo Horizonte- MG quando o Tomador for Órgão Público
	nValLiq    := aISSQN[02]-aRet[06]-aISSQN[06]-aISSQN[05]
Else
	nValLiq    := aISSQN[02]-aRet[06]-aISSQN[06]
EndIf
//Outras retenções
nOutRet    := aRet[06]-aRet[05]-aRet[04]-aRet[03]-aRet[02]-aRet[01]

If nOutRet > 0
	nOutRet:= nOutRet-nIssRet
EndIf


If "1"$cModXml //BH - ABRASF
	cString += '<Servico>'
	cString += '<Valores>'
	cString += '<ValorServicos>'+ConvType(aISSQN[02],15,2)+'</ValorServicos>'
	cString += NfeTag('<ValorDeducoes>',ConvType(nDed,15,2))
	cString += NfeTag('<ValorPis>',ConvType(aRet[03],15,2))
	cString += NfeTag('<ValorCofins>',ConvType(aRet[04],15,2))
	cString += NfeTag('<ValorInss>',ConvType(aRet[05],15,2))
	cString += NfeTag('<ValorIr>',ConvType(aRet[01],15,2))
	cString += NfeTag('<ValorCsll>',ConvType(aRet[02],15,2))
	cString += '<IssRetido>'+cRetIss+'</IssRetido>'
	If SM0->M0_CODMUN == "3106200" .And. cTpPessoa == "EP"
		cString += NfeTag('<ValorIss>0.00</ValorIss>') 
	Else
		cString += NfeTag('<ValorIss>',ConvType((aISSQN[05]),15,2)) 
	EndIf
	If SM0->M0_CODMUN == "3106200" .And. cTpPessoa == "EP" 
		cString += NfeTag('<ValorIssRetido>0.00</ValorIssRetido>') 
	Else
		cString += NfeTag('<ValorIssRetido>',ConvType(nIssRet,15,2)) 
	EndIf
	cString += NfeTag('<OutrasRetencoes>',ConvType(nOutRet,15,2))
	cString += '<BaseCalculo>'+ConvType(nBase,15,2)+'</BaseCalculo>'
	If SM0->M0_CODMUN == "3106200" .And. cTpPessoa == "EP" 
		cString += NfeTag('<Aliquota>0.00</Aliquota>')
	Else
		cString += NfeTag('<Aliquota>',ConvType(aISSQN[04],5,2))
	EndIf
	cString += NfeTag('<ValorLiquidoNfse>',ConvType(nValLiq,15,2))
	cString += NfeTag('<DescontoIncondicionado>',ConvType((aISSQN[06]),15,2))
	If SM0->M0_CODMUN == "3106200" .And. cTpPessoa == "EP" 
		cString += NfeTag('<DescontoCondicionado>',ConvType((aISSQN[05]),15,2))
	EndIf
	//cString += '<DescontoCondicionado>'++'</DescontoCondicionado>'
	cString += '</Valores>'
	//cString += '<ItemListaServico>'+ConvType(StrTran(aISSQN[01],".",""),4)+'</ItemListaServico>'
	cString += '<ItemListaServico>'+ConvType(aISSQN[01],5)+'</ItemListaServico>'
	cString += NfeTag('<CodigoCnae>',ConvType(aISSQN[03],7))
	//cString += '<CodigoTributacaoMunicipio>'+'710'+'</CodigoTributacaoMunicipio>'
	cString += '<CodigoTributacaoMunicipio>'+ConvType(aISSQN[07],20)+'</CodigoTributacaoMunicipio>'
	cString += '<Discriminacao>'+ConvType(cServ,2000)+'</Discriminacao>'
	cString += '<CodigoMunicipio>'+ConvType(cMunPres,7)+'</CodigoMunicipio>'
	cString += '</Servico>'
	
Else //ISSNET
	cString += '<tc:Servico>'
	cString += '<tc:Valores>'
	cString += '<tc:ValorServicos>'+ConvType(aISSQN[02],15,2)+'</tc:ValorServicos>'
	cString += NfeTag('<tc:ValorDeducoes>',ConvType(nDed,15,2))
	cString += NfeTag('<tc:ValorPis>',ConvType(aRet[03],15,2))
	cString += NfeTag('<tc:ValorCofins>',ConvType(aRet[04],15,2))
	cString += NfeTag('<tc:ValorInss>',ConvType(aRet[05],15,2))
	cString += NfeTag('<tc:ValorIr>',ConvType(aRet[01],15,2))
	cString += NfeTag('<tc:ValorCsll>',ConvType(aRet[02],15,2))
	cString += '<tc:IssRetido>'+cRetIss+'</tc:IssRetido>'
	If aISSQN[05] > 0
		cString += NfeTag('<tc:ValorIss>',ConvType((aISSQN[05]),15,2))
	Else
		cString += '<tc:ValorIss>0.00</tc:ValorIss>'
	EndIf		
	cString += NfeTag('<tc:ValorIssRetido>',ConvType(nIssRet,15,2))
	cString += NfeTag('<tc:OutrasRetencoes>',ConvType(nOutRet,15,2))
	cString += '<tc:BaseCalculo>'+ConvType(nBase,15,2)+'</tc:BaseCalculo>'
	If  aISSQN[04] > 0	
		cString += NfeTag('<tc:Aliquota>',ConvType(aISSQN[04],5,2))
	else
		cString += '<tc:Aliquota>0.00</tc:Aliquota>'
	endif		
	cString += NfeTag('<tc:ValorLiquidoNfse>',ConvType(nValLiq,15,2))
	cString += '<tc:DescontoIncondicionado>'+ConvType((aISSQN[06]),15,2)+'</tc:DescontoIncondicionado>'
	cString += '<tc:DescontoCondicionado>0</tc:DescontoCondicionado>'
	cString += '</tc:Valores>'
	//cString += '<tc:ItemListaServico>'+ConvType(StrTran(aISSQN[01],".",""),4)+'</tc:ItemListaServico>'
	cString += '<tc:ItemListaServico>'+ConvType(aISSQN[01],4)+'</tc:ItemListaServico>'
	cString += NfeTag('<tc:CodigoCnae>',ConvType(aISSQN[03],7))
	//cString += '<tc:CodigoTributacaoMunicipio>'+'710'+'</tc:CodigoTributacaoMunicipio>'
	cString += '<tc:CodigoTributacaoMunicipio>'+ConvType(aISSQN[07],20)+'</tc:CodigoTributacaoMunicipio>'
	cString += '<tc:Discriminacao>'+ConvType(cServ,2000)+'</tc:Discriminacao>'
	cString += '<tc:MunicipioPrestacaoServico>'+Iif(Len(cMunPres) == 9,substr(cMunPres,3,7),ConvType(cMunPres,7))+'</tc:MunicipioPrestacaoServico>'
	//cString += '<tc:MunicipioPrestacaoServico>999</tc:MunicipioPrestacaoServico>'
	cString += '</tc:Servico>'
EndIf
Return(cString)

Static Function NFSePrest(cModXml)
Local cString    := ""

If "1"$cModXml //BH - ABRASF
	cString +='<Prestador>'
	cString += '<Cnpj>'+SM0->M0_CGC+'</Cnpj>'
	cString += NfeTag('<InscricaoMunicipal>',ConvType(SM0->M0_INSCM))
	cString +='</Prestador>'
Else //ISSNET
	cString +='<tc:Prestador>'
	cString +='<tc:CpfCnpj>'
	cString += '<tc:Cnpj>'+SM0->M0_CGC+'</tc:Cnpj>'
	cString +='</tc:CpfCnpj>'
	cString += NfeTag('<tc:InscricaoMunicipal>',ConvType(SM0->M0_INSCM))
	cString +='</tc:Prestador>'
EndIf
Return(cString)

Static Function NFSeTom(aDest,cModXml,cMunPres)
Local cCPFCNPJ :=""
Local cInscMun :=""
Local cString  :=""

//Identifica Tipo
If RetPessoa(AllTrim(aDest[01]))=="J"
	cCPFCNPJ:="2"
Else
	cCPFCNPJ:="1"
EndIf
//Identifica Inscricao
If AllTrim(cMunPres)==AllTrim(SM0->M0_CODMUN)
	cInscMun:=aDest[11]
EndIf

If "1"$cModXml //BH - ABRASF
	cString +='<Tomador>'
	cString +='<IdentificacaoTomador>'
	//Estrangeiro não manda a tag de CPFCNPJ
	If !"EX"$aDest[08]
		cString +='<CpfCnpj>'
			If "2"$cCPFCNPJ
				cString += NfeTag('<Cnpj>',ConvType(aDest[01]))
			Else
				cString += NfeTag('<Cpf>',ConvType(aDest[01]))
			EndIf
		cString +='</CpfCnpj>'
	EndIf
	cString += NfeTag('<InscricaoMunicipal>',ConvType(cInscMun))
	cString +='</IdentificacaoTomador>'
	cString += NfeTag('<RazaoSocial>',ConvType(aDest[02],115))
	
	cString +='<Endereco>'
	cString += NfeTag('<Endereco>',ConvType(aDest[03],125))
	cString += NfeTag('<Numero>',ConvType(aDest[04],10))
	cString += NfeTag('<Complemento>',ConvType(aDest[05],60))
	cString += NfeTag('<Bairro>',ConvType(aDest[06],60))
	cString += NfeTag('<CodigoMunicipio>',ConvType(aUF[aScan(aUF,{|x| x[1] == aDest[08]})][02]+aDest[07]))
	cString += NfeTag('<Uf>',ConvType(aDest[08]))
	cString += NfeTag('<Cep>',ConvType(aDest[09]))
	cString +='</Endereco>'
	
	cString +='<Contato>'
	cString += NfeTag('<Telefone>',AllTrim(ConvType(FisGetTel(aDest[10])[3],11)))
	cString += NfeTag('<Email>',ConvType(aDest[12],80))
	cString +='</Contato>'
	cString +='</Tomador>'
	
	//cString +='<Intermediario>'
	//cString += '<RazaoSocial>'+'</RazaoSocial>'
	//cString +='<CpfCnpj>'
	//cString += '<Cpf>'+'</Cpf>'
	//cString += '<Cnpj>'+'</Cnpj>'
	//cString +='</CpfCnpj>'
	//cString += '<InscricaoMunicipal>'+'</InscricaoMunicipal>'
	//cString +='</Intermediario>'
	
	//cString +='<Construcao>'
	//cString += '<CodigoObra>'+'</CodigoObra>'
	//cString += '<Art>'+'</Art>'  
	//cString +='</Construcao>'
	cString +='</InfRps>'
	
Else //ISSNET
	cString +='<tc:Tomador>'
	cString +='<tc:IdentificacaoTomador>'
	cString +='<tc:CpfCnpj>'
	if "EX"$aDest[08]
	    cString += NfeTag('<tc:Cnpj>','99999999999999')
	Else
		If "2"$cCPFCNPJ
			cString += NfeTag('<tc:Cnpj>',ConvType(aDest[01]))
		Else
			cString += NfeTag('<tc:Cpf>',ConvType(aDest[01]))
		EndIf
	EndIf
	cString +='</tc:CpfCnpj>'
	cString += NfeTag('<tc:InscricaoMunicipal>',ConvType(cInscMun))
	cString +='</tc:IdentificacaoTomador>'
	cString += NfeTag('<tc:RazaoSocial>',ConvType(aDest[02],115))
	
	cString +='<tc:Endereco>'
	cString += NfeTag('<tc:Endereco>',ConvType(aDest[03],125))
	cString += NfeTag('<tc:Numero>',ConvType(aDest[04],10))
	cString += NfeTag('<tc:Complemento>',ConvType(aDest[05],60))
	cString += NfeTag('<tc:Bairro>',ConvType(aDest[06],60))
	If "EX"$aDest[08]
		cString += NfeTag('<tc:Cidade>','99999')
	Else
		cString += NfeTag('<tc:Cidade>',ConvType(aUF[aScan(aUF,{|x| x[1] == aDest[08]})][02]+aDest[07]))
	EndIf

	cString += NfeTag('<tc:Estado>',ConvType(aDest[08]))
	cString += NfeTag('<tc:Cep>',ConvType(aDest[09]))
	cString +='</tc:Endereco>'
	
	cString +='<tc:Contato>'
	cString += NfeTag('<tc:Telefone>',ConvType(aDest[10],11))
	cString += NfeTag('<tc:Email>',ConvType(aDest[12],80))
	cString +='</tc:Contato>'
	cString +='</tc:Tomador>'
	
	//cString +='<tc:Intermediario>'
	//cString += '<tc:RazaoSocial>'+'</tc:RazaoSocial>'
	//cString +='<tc:CpfCnpj>'
	//cString += '<tc:Cpf>'+'</tc:Cpf>'
	//cString += '<tc:Cnpj>'+'</tc:Cnpj>'
	//cString +='</tc:CpfCnpj>'
	//cString += '<tc:InscricaoMunicipal>'+'</tc:InscricaoMunicipal>'
	//cString +='</tc:Intermediario>'
	
	//cString +='<tc:Construcao>'
	//cString += '<tc:CodigoObra>'+'</tc:CodigoObra>'
	//cString += '<tc:Art>'+'</tc:Art>'  
	//cString +='</tc:Construcao>'
	cString +='</tc:InfRps>'
EndIf
Return(cString)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetPrvUnit
Funcao que retorna o preço unitario do produto

@author Sergio Sueo Fuzinaka
@since 31.07.2012
@version 1.0 
/*/
//-----------------------------------------------------------------------
Static Function RetPrvUnit(cAliasSD2,nDesconto)

Local nRetorno := 0

If (cAliasSD2)->D2_TIPO $ "IP"

	nRetorno := 0

Else

	If (cAliasSD2)->D2_QUANT < 1
	    
		if (cAliasSD2)->D2_PRUNIT == (cAliasSD2)->D2_PRCVEN
			nRetorno := ( ( ( (cAliasSD2)->D2_PRUNIT * (cAliasSD2)->D2_QUANT ) + nDesconto + (cAliasSD2)->D2_DESCZFR ) / (cAliasSD2)->D2_QUANT )	
		elseif (cAliasSD2)->D2_PRUNIT < (cAliasSD2)->D2_PRCVEN
			nRetorno := ( ( ( (cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT ) + (cAliasSD2)->D2_DESCZFR ) / (cAliasSD2)->D2_QUANT )		
		else
			nRetorno := ( ( ( (cAliasSD2)->D2_PRUNIT * (cAliasSD2)->D2_QUANT ) + (cAliasSD2)->D2_DESCZFR ) / (cAliasSD2)->D2_QUANT )
		endif
				
	Else
	
		nRetorno := ( ( (cAliasSD2)->D2_TOTAL + nDesconto + (cAliasSD2)->D2_DESCZFR ) / (cAliasSD2)->D2_QUANT )
	
	Endif

Endif

Return( NoRound( nRetorno, 8 ) )

//** BRENO **//
static function Projetos(cNota,cSerie,cCliFor,cLoja,cTab)
	local cQry := ""
	local cProj := ""
	local cCampo := ""
	
	if cTab == "SF2"
		cQry := "select distinct C6_CLVL from "+RetSqlName("SC6")+" where C6_NOTA = '"+cNota+"' and C6_SERIE = '"+cSerie+"' and C6_CLI = '"+cCliFor+"' and C6_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*'"
		cCampo := "C6_CLVL"
	elseif cTab == "SF1"
		cQry := "select distinct D1_CLVL from "+RetSqlName("SD1")+" where D1_DOC = '"+cNota+"' and D1_SERIE = '"+cSerie+"' and D1_FORNECE = '"+cCliFor+"' and D1_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*'"
		cCampo := "D1_CLVL"
	endif
	
	tcquery cQry new alias "TMP"
	DbSelectArea("TMP")
	
	while !TMP->(Eof())
		if AllTrim(TMP->&(cCampo)) <> "000000000"
			cProj += AllTrim(TMP->&(cCampo))+" / "
		endif
		
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
return (SubStr(cProj,1,Len(cProj) - 3))
//**********//

//-----------------------------------------------------------------------
/*/{Protheus.doc} LgxMsgNfs()
Funcao que verifica os vinculos entre pedidos de venda e realiza o 
tratamento do texto do C5_MENNOTA quando a origem do PV é igual a 'LOGIX'

@author Caio Murakami       
@since 12.12.2012
@version 1.0 
/*/
//-----------------------------------------------------------------------
Static Function LgxMsgNfs()
Local aAreaSC5	:= SC5->( GetArea() )
Local aAreaSC6 := SC6->( GetArea() )
Local aArea		:= GetArea()  
Local aPedVinc	:= {} 
Local bSeek		:= {} 
Local nX 		:= 0 
Local cPedVinc	:= ""  
Local cChave	:= ""  
Local lAtuSC5	:= .F. 
Local cMsgNfs  := SC5->C5_MENNOTA
Local cNumPed 	:= SC5->C5_NUM 

If SC6->( FieldPos("C6_PEDVINC") ) > 0 .And. !Empty(SC6->C6_PEDVINC)  
	
	cPedVinc := SC6->C6_PEDVINC 
		
   SC5->( dbSetOrder(1) ) 
	SC6->( dbSetOrder(1) )      
	
	If SC5->( MsSeek( cChave := xFilial("SC5") + cPedVinc ) )	
	   
	   If SC6->( MsSeek( cChave )  )
	   	//-- Percorre itens de pedido de venda relacionado o número do pedido com a NF , Série e Data
	   	While SC6->( C6_FILIAL+C6_NUM ) == cChave .And.  !SC6->( Eof() ) 
	   		
	   		If !Empty(SC6->C6_NOTA)    		
	   			If Ascan( aPedVinc, { | e | e[1]+e[2] == SC6->(C6_NOTA+C6_SERIE) } ) == 0
		   			Aadd( aPedVinc, { SC6->C6_NOTA , SC6->C6_SERIE , SC6->C6_DATFAT  }  ) 
		   		EndIf
		   	EndIf
		   		   		
	   		SC6->( dbSkip() )  
	   		
	   	EndDo
	   EndIf   
	EndIf 
	//-- Atualiza mensagem do pedido, @N ( Numero da NF ) ; @S ( Série da NF) ; @D ( Data emissao )
	For nX := 1 To Len(aPedVinc)
		
		cMsgNfs := StrTran( cMsgNfs , '@N' , aPedVinc[nX,1] 		 	,, 1 )
		cMsgNfs := StrTran( cMsgNfs , '@S' , aPedVinc[nX,2] 		 	,, 1 )
		cMsgNfs := StrTran( cMsgNfs , '@D' , dToC(aPedVinc[nX,3])	,, 1 )
		
		If At('@N' , cMsgNfs ) == 0
			lAtuSC5 := .T.	 
			Exit
		EndIf			
			   
	Next nX  
	
	//-- Atualiza C5_MENNOTA do pedido de venda posicionado inicialmente
	If lAtuSC5 .And. SC5->( MsSeek( xFilial("SC5") + cNumPed )   ) 
		If AllTrim(SC5->C5_MENNOTA) <> AllTrim(cMsgNfs)
			RecLock( "SC5" , .F. )
			SC5->C5_MENNOTA := cMsgNfs
			MsUnLock()	
		EndIf
	EndIf
  
EndIf    
 
RestArea( aAreaSC5 )
RestArea( aAreaSC6 )
RestArea( aArea    )

Return NIL  

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetNfpVinc()
Funcao que verifica se existe nota de NFP vinculada a Nota , e retorna o 
arrey com as informações da nota de NFP

@author Fernando Bastos       
@since 03.01.2013
@version 1.0 
/*/
//-----------------------------------------------------------------------
Static Function RetNfpVinc(cDocNFP,cSerieNFP,cForneceNFP,cLojaNFP)

local nOrderSF1	:= 0
local nRecnoSF1	:= 0	
local nOrderSD1	:= 0	
local nRecnoSD1	:= 0

Local aNfViRuNFP:={}

	// Realiza o backup do order e recno da SF1 e SD1
	nOrderSF1	:= SF1->( indexOrd() )
	nRecnoSF1	:= SF1->( recno() ) 
	
	nOrderSD1	:= SD1->( indexOrd() )
	nRecnoSD1	:= SD1->( recno() )
		
	SD1->(dbSetOrder(1))
		If SD1->(dbSeek(xFilial("SD1")+SD1->D1_NFORI+SD1->D1_SERIORI))//D1_NFORI,D1_SERIORI
   				SF1->(dbSetOrder(1))
   				If SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) .And. AllTrim(SF1->F1_ESPECIE)=="NFP")
	   			aadd(aNfViRuNFP,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,SF1->F1_ESPECIE,;
				IIF(SD1->D1_FORMUL=="S",SM0->M0_CGC,SA2->A2_CGC),; 
				IIF(SD1->D1_FORMUL=="S",SM0->M0_ESTENT,SA2->A2_EST),; 
				IIF(SD1->D1_FORMUL=="S",SM0->M0_INSC,SA2->A2_INSCR)})	
			Endif
		Endif
   	// Restaura a ordem e recno da SF1 e SD1
	SF1->( dbSetOrder( nOrderSF1 ) )
	SF1->( dbGoTo( nRecnoSF1 ) )
			        
	SD1->( dbSetOrder( nOrderSD1 ) )
	SD1->( dbGoTo( nRecnoSD1 ) )
								
Return (aNfViRuNFP) 

//------------------------------------------------------------------------
/*/{Protheus.doc} MsgCliRsIcm
Funcao que retorna a mensagem para ser colocada nos dados adicionais da NFe,
referente ao RICMS do RIO GRANDE do SUL:
Livro II , Art.29 , Inciso VII, Alinea "a" numero 1
Livro III, Art. 26 

@author Rafael Iaquinto    
@since 22.05.2013
@version 1.0  

@param		aICMS		Array com informações referente ao ICMS proprio
@param		aICMSST	Array com informações referente ao ICMS-ST
			
@return	cMsg		Retorna a Mensagem a ser utilizada.	

/*/
//------------------------------------------------------------------------                                                        
Static Function MsgCliRsIcm(aICMS, aICMSST)

Local cMsg 		:= ""

Local nX			:= ""
Local nValIcm		:= 0
Local nValST		:= 0 
Local nBaseIcm		:= 0
Local nBaseST		:= 0

Local lIcmsST		:= .F.
Local lIcms		:= .F.
Local lIcmsSemSt	:= .F.

For nX := 1 to Len( aICMS )
	
	lIcms := .F.
	
	If Len( aICMS[nX] ) > 0 .And. aICMS[nX][07] > 0
		
		nValIcm 	+= aICMS[nX][07] 
		nBaseIcm	+= aICMS[nX][05]
		
		if len( aICMSSt[nX] ) > 0 .and. aICMSSt[nX][07] > 0 
			nValST		+= aICMS[nX][07] 
			nBaseST	+= aICMS[nX][05]
		endif
		
		lIcms := .T.
				
	EndIf
	
	If Len( aICMSSt[nX] ) > 0 .And. aICMSSt[nX][07] > 0 		
		
		lIcmsST := .T.
						
	ElseIf lIcms .And. !lIcmsSemSt  
		lIcmsSemSt := .T.
	EndIF
	 	
Next nX

If lIcmsSemSt .And. lIcmsST

	cMsg += "Operações não sujeitas a Regime de ST, "
	cMsg += "Base de Cálculo do ICMS próprio: R$ " + Alltrim( Str(nBaseIcm-nBaseST, 14, 2) )+ ", "
	cMsg += "Valor do ICMS próprio: R$ " + Alltrim( Str(nValIcm-nValST, 14, 2) )+ ". "
	cMsg += "Operações sujeitas a Regime de ST, " 			
	cMsg += "Base de cálculo do ICMS próprio : R$ " + Alltrim( Str(nBaseST, 14, 2) )+ ", "
	cMsg += "Valor do ICMS próprio: R$ " + Alltrim( Str(nValST, 14, 2) )+ ". "
	
EndIf


return cMsg

//-----------------------------------------------------------------------
/*/{Protheus.doc} DocDatOrig
Funcao criada para retornar para a função XmlNfeSef os valores da Nota Original quando houver controle de SubLote

@param		cNumLote	Número do SubLote.
@param		cLoteClt	Número do lote.
@param 		cProduto   Codigo do produto

		
@return	nil

@author	Eduardo Silva
@since		22/01/2014
@version	11.8
/*/
//-----------------------------------------------------------------------

Static Function DocDatOrig(cNumLote,cLoteCtl,cProduto)

Local aArea		 := GetArea()

Local cAliasSFT	:= GetNextAlias()
Local cCliFor		:= ""
Local cData		:= ""
Local cLocCQ    	:= PADR(SuperGetMV("MV_CQ"),TAMSX3("D7_LOCAL")[1])  //adequo o conteudo padrão "98" para "98 "
Local cLoja		:= ""
Local cNfiscal		:= ""
Local cNumCQ		:= ""
Local cNfOrig		:= ""
Local cSeek		:= ""        
Local cSeek1		:= ""        
Local cSerie		:= ""
Local cSerieOri	:= ""
                     
dbSelectArea("SB8")
dbSetOrder(2)
if MsSeek(xFilial("SB8")+cNumLote+cLoteCtl+cProduto)      		
				
	dbSelectArea("SD7")
	SD7->(dbSetOrder(1))
	cNumCQ := PADR(SB8->B8_DOC,LEN(SD7->D7_NUMERO))					 		
	if SD7->(MsSeek(SB8->B8_FILIAL+cNumCQ+cProduto+cLocCQ))      					
		cNfiscal	:= SD7->D7_DOC
		cSerie 		:= SD7->D7_SERIE 
		cCliFor	:= SD7->D7_FORNECE
		cLoja 		:= SD7->D7_LOJA
	else			
		cNfiscal	:= SB8->B8_DOC
		cSerie		:= SB8->B8_SERIE
		cCliFor	:= SB8->B8_CLIFOR
		cLoja 		:= SB8->B8_LOJA 									
	endif				
	
	cSeek	:= cCliFor+cLoja+cSerie+cNfiscal		
	cSeek1	:= cNfiscal+cSerie+cCliFor+cLoja+cProduto+cLoteCtl+cNumLote
endif
		
if len (cSeek)>0 
			
	BeginSql Alias cAliasSFT
		SELECT FT_PRODUTO,FT_EMISSAO,FT_NFISCAL,FT_SERIE,FT_BASERET,FT_ICMSRET
			FROM %Table:SFT% SFT
			WHERE
			SFT.FT_FILIAL = %xFilial:SFT% AND
			SFT.%NotDel% AND 
			FT_NFISCAL	=%Exp:cNfiscal% AND
			FT_SERIE  	=%Exp:cSerie% AND
			FT_TIPOMOV	=%Exp:"E" % AND
			FT_CLIEFOR	=%Exp:cCliFor% AND
			FT_LOJA	=%Exp:cLoja% AND
			FT_ITEM	=%Exp:SD1->D1_ITEM% AND 						
			FT_PRODUTO	=%Exp:cProduto%
	EndSql
		
	if (cAliasSFT)->(!Eof()) 
		cData 		:= (cAliasSFT)->FT_EMISSAO
		cNfOrig	:= (cAliasSFT)->FT_NFISCAL
		cSerieOri	:= (cAliasSFT)->FT_SERIE	
	endif
		
	(cAliasSFT)->(DBCLOSEAREA())
	
endif

RestArea(aArea)
Return({dtoc(stod(cData)),cNfOrig,cSerieOri})

//-----------------------------------------------------------------------
/*/{Protheus.doc} PercTrib
Retorna a porcentagem a ser impresso no DANFE para a Lei Transparencia (Lei 12.741)


@param	aProd		Contendo as informacoes do(s) produto(s).
@param	lProdItem	Identifica se a mensagem da Lei da Transparencia sera gerado
					no Produto e/ou informacoes complementares.
@param	cEnte		Ente Tributante: 1-Federal / 2-Estadual / 3-Municipal

@return cPercTrib Porcentagem do Tributo

@author Douglas Parreja
@since 26/06/2014
@version 12
/*/
//-----------------------------------------------------------------------

Static Function PercTrib( aProd, lProdItem, cEnte ) 

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->( GetArea() )

Local nAliquota		:= 0
Local nTributo		:= 0
Local nTotTrib		:= 0
Local cPercTrib		:= ""
Local nPos			:= 30
Local nTotCargaTrib	:= nTotalCrg
Local nAliq			:= 0

Default aProd 		:= {}            
Default lProdItem 	:= .F.
Default cEnte		:= ""

If lMvEnteTrb .And. ( cEnte $ "1-2-3" )
	
	If cEnte == "1"	// FEDERAL

		nPos 			:= 35
		nTotCargaTrib	:= nTotFedCrg

	ElseIf cEnte == "2"	// ESTADUAL

		nPos			:= 36
		nTotCargaTrib	:= nTotEstCrg

	Else

		nPos 			:= 37
		nTotCargaTrib	:= nTotMunCrg

	Endif
	
Endif

If lProdItem

	dbSelectArea("SB1")
	dbSetOrder(1) // B1_FILIAL+B1_COD
	
	If dbSeek( xFilial("SB1") + AllTrim( aProd[2] ) )
	
		nAliq	:= LeiTransp(nPos) 
		cPercTrib := ConvType( nAliq * 100 , 15, 2 )
		
	 /*	
	xRetVal := AlqLei2741(aProd[5],aProd[6],SB1->B1_CODISS,SA1->A1_EST,SA1->A1_COD_MUN,aProd[2],aProd[1],SD2->D2_NUMLOTE,SD2->D2_LOTECTL,cMvFisCTrb,cMvFisAlCT,lMvFisFRas)	
	
		If ValType(xRetVal)== "A"
			cPercTrib := ConvType( xRetVal[1], 15, 2 )
		ElseIf ValType(xRetVal)== "N"
			cPercTrib := ConvType( xRetVal, 15, 2 )
		EndIf
		
		nAliquota	:= AlqLeiTran( "SB1", "SBZ" )[1]    
		nTributo	:= ConvType( ( aProd[nPos] * nAliquota ) / 100, 15, 2 )
		nTotTrib	:= Val( nTributo )
	
		cPercTrib	:= ConvType( ( nTotTrib / aProd[10] ) * 100, 15, 2 )*/
	
	Endif

Else

	cPercTrib	:= ConvType( ( nTotCargaTrib / nTotNota ) * 100, 15, 2 )

EndIf			

RestArea( aAreaSB1 )
RestArea( aArea )	

Return cPercTrib

//-----------------------------------------------------------------------
/*/{Protheus.doc} LeiTransp
Retorna a porcentagem a ser impresso no por documento gerado 
DANFE para a Lei Transparencia (Lei 12.741) 


@param	nPos 	Posição ref. Aliq. Tributante: 30 - Aliquota Total
							35-Federal / 36-Estadual / 37-Municipal

@return nAliq		Aliquota do Produto

@author Douglas Parreja
@since 19/12/2014
@version 11.80
/*/
//-----------------------------------------------------------------------

Static Function LeiTransp (nPos)

Local nAliq := 0

Default nPos	:= 30


	If nPos == 35			// FEDERAL
	
		nAliq := SD2->D2_TOTFED /  (SD2->D2_VALBRUT + SD2->D2_DESCON)
		
	ElseIf nPos == 36		// ESTADUAL
	
		nAliq := SD2->D2_TOTEST / (SD2->D2_VALBRUT + SD2->D2_DESCON)
	
	ElseIf nPos == 37		// MUNICIPAL
	
		nAliq := SD2->D2_TOTMUN / (SD2->D2_VALBRUT + SD2->D2_DESCON)
	Else
		
		nAliq := SD2->D2_TOTIMP / (SD2->D2_VALBRUT + SD2->D2_DESCON)
	EndIf

Return nAliq
