/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 11/08/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Adiciona botão na tela de documento de entrada        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "vkey.ch"

user function MA103BUT()
	public _cMenP := ""
	public _cMen2 := ""
	public _cMen3 := ""
//	public _cChvNfe := ""
	
	aButtons := {}
	
	SetKEY(VK_F10,{|| ObservacaoNF(CNFISCAL,CSERIE,CA100FOR,CLOJA,CTIPO)})
//	SetKEY(VK_F11,{|| ChaveNFe(CNFISCAL,CSERIE,CA100FOR,CLOJA,CTIPO,CESPECIE)})
	SetKEY(VK_F11,{|| ProcuraCR(CNFISCAL,CSERIE,CA100FOR,CLOJA)})
	
	AAdd(aButtons,{"NOTE",{|| ObservacaoNF(CNFISCAL,CSERIE,CA100FOR,CLOJA,CTIPO)},"Observacao da NF Entrada <F10>","Obs NF"})
//	AAdd(aButtons,{"EDITABLE",{|| ChaveNFe(CNFISCAL,CSERIE,CA100FOR,CLOJA,CTIPO,CESPECIE)},"Chave de acesso da NFe <F11>","Chave NFe"})
	AAdd(aButtons,{"EDITABLE",{|| ProcuraCR(CNFISCAL,CSERIE,CA100FOR,CLOJA)},"Procurar C.R. <F11>","Procura CR"})
return (aButtons)

static function ObservacaoNF(cDoc,cSer,cFor,cLoj,cTip)
	local oButton1
	local oButton2
	local oGet1
	local cGet1 := "Define variable value"
	local oGet2
	local cGet2 := "Define variable value"
	local oGet3
	local cGet3 := "Define variable value"
	local oGroup1
	local oGroup2
	local oSay1
	local lCabecalho := .T.
	local lVisualiza := If(INCLUI,.T.,.F.)
	
	private cMenP := If(INCLUI,Space(200),SF1->F1_MENNOTA)
	private cMen2 := If(INCLUI,Space(200),SF1->F1_MENNOT2)
	private cMen3 := If(INCLUI,Space(200),SF1->F1_MENNOT3)
	
	static oDlg
	
	cTip := If(Empty(cTip),"N",cTip)
	
	if Empty(cDoc+cSer+cFor+cLoj)
		Alert("Precisa preencher informacoes no cabecalho para visualizacao da OBSERVACAO DA NF!")
		lCabecalho := .F.
	elseif Empty(cDoc)
		Alert("O numero da NOTA FISCAL nao pode esta em branco!")
		lCabecalho := .F.
	elseif Empty(cSer)
		Alert("O numero da SERIE nao pode esta em branco!")
		lCabecalho := .F.
	elseif Empty(cFor)
		Alert("O codigo do FORNECEDOR nao pode esta em branco!")
		lCabecalho := .F.
	elseif Empty(cLoj)
		Alert("O codigo da LOJA nao pode esta em branco!")
		lCabecalho := .F.
	endif
	
	if lCabecalho
		define msdialog oDlg title "OBSERVACAO DA NF ENTRADA" from 000,000 to 190,500 colors 0,16777215 pixel
			@004,003 group oGroup1 to 026,246 prompt " Fornecedor/Cliente " of oDlg color 0,16777215 pixel
			
			if !cTip $ "B/D"
				@013,006 say oSay1 prompt cDoc+"/"+AllTrim(cSer)+" - "+cFor+" "+If(SA2->(DbSeek(xFilial("SA2")+cFor+cLoj,.F.)),AllTrim(SA2->A2_NOME),"") size 234,007 of oDlg colors 0,16777215 pixel
			else
				@013,006 say oSay1 prompt cDoc+"/"+AllTrim(cSer)+" - "+cFor+" "+If(SA1->(DbSeek(xFilial("SA1")+cFor+cLoj,.F.)),AllTrim(SA1->A1_NOME),"") size 234,007 of oDlg colors 0,16777215 pixel
			endif
			
			@027,003 group oGroup2 to 074,246 prompt " Mensagem da NF " of oDlg color 0,16777215 pixel
			@036,006 msget oGet1 var cMenP size 234,010 of oDlg picture "@!" when lVisualiza colors 0,16777215 pixel
			@047,006 msget oGet2 var cMen2 size 234,010 of oDlg picture "@!" when lVisualiza colors 0,16777215 pixel
			@060,006 msget oGet3 var cMen3 size 234,010 of oDlg picture "@!" when lVisualiza colors 0,16777215 pixel
			@078,208 button oButton1 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
			
			if INCLUI
				@078,167 button oButton2 prompt "OK" size 037,012 of oDlg action GravarOBS() pixel
			endif
		activate msdialog oDlg centered
	endif
return

static function GravarOBS()
	_cMenP := cMenp
	_cMen2 := cMen2
	_cMen3 := cMen3
	
	Close(oDlg)
return

static function ChaveNFe(cDoc,cSer,cFor,cLoj,cTip,cEsp)
	local lVisualiza := If(INCLUI,.T.,.F.)
	local lEspecie := If(AllTrim(cEsp) $ "SPED/CTE",.T.,.F.)
	local nLinini := 10
	
	private cChvNfe := If(INCLUI,Space(55),SF1->F1_CHVNFE)
	
	cTip := If(Empty(cTip),"N",cTip)
	
	if lEspecie
		@010,010 to 130,500 dialog oDlg title "CHAVE DE ACESSO DA NF-E"
			@005,010 to 020,240
			
			if !cTip $ "B/D"
				@nLinini,015 say cDoc+"/"+AllTrim(cSer)+" - "+cFor+" "+If(SA2->(DbSeek(xFilial("SA2")+cFor+cLoj,.F.)),AllTrim(SA2->A2_NOME),"")
			else
				@nLinini,015 say cDoc+"/"+AllTrim(cSer)+" - "+cFor+" "+If(SA1->(DbSeek(xFilial("SA1")+cFor+cLoj,.F.)),AllTrim(SA1->A1_NOME),"")
			endif
			
			nLinini += 17
			@nLinini,010 say "Chv Acesso"
			@nLinini-2,040 get cChvNfe picture "9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 " when lVisualiza size 200,007
			
			nLinini += 17
			
			if INCLUI
				@nLinini,181 bmpbutton type 01 action GravarCHV()
			endif
			
			@nLinini,211 bmpbutton type 02 action Close(oDlg)
		activate dialog oDlg center
	else
		MsgInfo("Essa nota não tem chave de acesso, só as notas do tipo SPED ou CTE.")
	endif
return

static function GravarCHV()
	_cChvNfe := StrTran(cChvNfe," ","",1,11)
	
	Close(oDlg)
return

static function ProcuraCR(cNFiscal,cSerie,cFornec,cLoja)
	local nI
	local oDlg
	local oGetDB
	local nUsado := 0
	local cAlias := "SZU"
	local aButtons := {}
	local lCabecalho := .T.
	
	private lRefresh := .T.
	private aHeader := {}
	private aCols := {}
	private aRotina := {{"Visualizar", "AxVisual", 0, 1}}
	
	if Empty(cNFiscal+cSerie+cFornec+cLoja)
		Alert("Precisa preencher informacoes no cabecalho para visualizacao do C.R.!")
		lCabecalho := .F.
	elseif Empty(cNFiscal)
		Alert("O numero da NOTA FISCAL nao pode esta em branco!")
		lCabecalho := .F.
	elseif Empty(cSerie)
		Alert("O numero da SERIE nao pode esta em branco!")
		lCabecalho := .F.
	elseif Empty(cFornec)
		Alert("O codigo do FORNECEDOR nao pode esta em branco!")
		lCabecalho := .F.
	elseif Empty(cLoja)
		Alert("O codigo da LOJA nao pode esta em branco!")
		lCabecalho := .F.
	endif
	
	if AllTrim(ReadVar()) == "M->D1_CR" .and. lCabecalho
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek(cAlias)
		
		while !Eof() .and. SX3->X3_ARQUIVO == cAlias
			if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. AllTrim(SX3->X3_CAMPO) $ "ZU_PEDIDO/ZU_PRODUTO/ZU_NUMCR"
				nUsado++
				AAdd(aHeader,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,"",SX3->X3_TIPO,"",""})
			endif
			
			DbSkip()
		enddo
		
		bCondicao := {|| ZU_NFISCAL = cNFiscal .and. ZU_SERIE = cSerie .and. ZU_FORNECE = cFornec .and. ZU_LOJA = cLoja .and. ZU_USADO = "N"}
		cCondicao := "ZU_NFISCAL = '"+cNFiscal+"' .and. ZU_SERIE = '"+cSerie+"' .and. ZU_FORNECE = '"+cFornec+"' .and. ZU_LOJA = '"+cLoja+"' .and. ZU_USADO = 'N'"
		
		DbSelectArea(cAlias)
		(cAlias)->(DbSetOrder(1))
		(cAlias)->(DbSetFilter(bCondicao,cCondicao))
		(cAlias)->(DbGoTop())
		
		define msdialog oDlg title "Codigo de Rastreabilidade" from 000,000 to 300,400 pixel
			oGetDB := MsGetDB():New(015,005,145,195,1,"AllwaysTrue","AllwaysTrue",,.F.,{},,.F.,,cAlias,"AllwaysTrue",,.F.,oDlg,.T.,,"AllwaysTrue","AllwaysTrue")
			oDlg:bInit := {|| EnchoiceBar(oDlg, {||GravarCR(oDlg)}, {||oDlg:End()},,aButtons)}
			oDlg:lCentered := .T.
//			oDlg:Activate()
		activate msdialog oDlg centered
		
		DbSelectArea(cAlias)
		(cAlias)->(DbCloseArea())
		DbSelectArea("SF1")
		DbSelectArea("SD1")
	endif
return

static function GravarCR(oDlg)
	M->D1_CR := SZU->ZU_NUMCR
	oDlg:End()
return