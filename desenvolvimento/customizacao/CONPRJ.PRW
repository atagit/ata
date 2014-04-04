/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 04/04/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Consulta informacoes do projeto                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function CONPRJ()
	private cCadastro := "Consulta Projeto"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Consultar","U_CONPRJ1()",0,2},;
						{"Legenda","U_LEGCONPRJ()",0,3}}
	
	aColors := {{"CTH_BLOQ <> '1'","BR_VERDE"},;
				{"CTH_BLOQ == '1'","BR_VERMELHO"}}
	
	DbSelectArea("CTH")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"CTH",,,,,,aColors)
return

user function LEGCONPRJ()
	local aLegenda := {}
	
	AAdd(aLegenda,{"BR_VERDE","Sem Restricao"})
	AAdd(aLegenda,{"BR_VERMELHO","Bloqueado"})
	
	BrwLegenda(cCadastro,"Legenda",aLegenda)
return .T.

user function CONPRJ1()
	static oDlg
	static oGroup1
	static oFolder1
	static oFolderPage1,oFolderPage2,oFolderPage3,oFolderPage4,oFolderPage5,oFolderPage6,oFolderPage7,oFolderPage8
	
	define msdialog oDlg title "PROJETO - CONSULTA" from 000,000 to 510,1100 colors 0,16777215 pixel
		aButtons := {}
		EnchoiceBar(oDlg,{||Close(oDlg)},{||Close(oDlg)},,aButtons)
		
		@016,003 group oGroup1 to 061,550 of oDlg color 0,16777215 pixel
		@063,003 folder oFolder1 size 547,190 of oDlg items "Orçamento","Pedidos de Compra","N.F. de Compra","N.F. de Fatura","Titulos Abertos","Titulos Pagos","Produtos Usados","Projetos Relacionados" colors 0,16777215 pixel
		
		fPedCompras(2)
	activate msdialog oDlg
return

static function fPedCompras(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4
	local nCont,nTotal,nIpi
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SY1")
	SY1->(DbSetOrder(3))
	
	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	
	cQry := "select C7_NUM, C7_EMISSAO, C7_DATPRF, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER, sum(C7_TOTAL) as C7_TOTAL, sum(C7_VALIPI) as C7_VALIPI "
	cQry += "from "+RetSqlName("SC7")+" "
	cQry += "where C7_CLVL = '"+CTH->CTH_CLVL+"' and C7_RESIDUO = '' and D_E_L_E_T_ <> '*' "
	cQry += "group by C7_NUM, C7_EMISSAO, C7_DATPRF, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER "
	cQry += "order by C7_NUM"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0; nTotal := 0 ; nIpi := 0
	
	while !TEMP->(Eof())
		nTamTot := 14 - Len(AllTrim(Transf(C7_TOTAL,"@E 999,999,999.99")))
		nTamIpi := 14 - Len(AllTrim(Transf(C7_VALIPI,"@E 999,999,999.99")))
		
		SY1->(DbGoTop())
		SE4->(DbGoTop())
		
		cComprador := IIf(SY1->(DbSeek(xFilial("SY1")+TEMP->C7_USER,.F.)),AllTrim(SY1->Y1_NOME)," ")
		cCondicao := IIf(SE4->(DbSeek(xFilial("SE4")+TEMP->C7_COND,.F.)),AllTrim(SE4->E4_DESCRI)," ")
		
		AAdd(aWBrowse1,{C7_NUM,U_ConvData(C7_EMISSAO),U_ConvData(C7_DATPRF),C7_NUMSC,C7_NUMCOT,cCondicao,Space(nTamTot)+Transf(C7_TOTAL,"@E 999,999,999.99"),Space(nTamIpi)+Transf(C7_VALIPI,"@E 999,999,999.99"),cComprador})
		
		nCont++
		nTotal += TEMP->C7_TOTAL
		nIpi += TEMP->C7_VALIPI
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","","",""})
	endif
	
	@001,001 listbox oWBrowse1 fields header "PEDIDO","EMISSAO","ENTREGA","SOLICITACAO","COTACAO","COND. PAGTO","TOTAL","IPI","COMPRADOR" size 544,156 of oFolder1:aDialogs[nDialog] pixel colsizes 050,030
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9]}}
//		DoubleClick event
//		oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],oWBrowse1:DrawSelect()}
	@161,001 button oButton1 prompt "Visualizar" size 037,012 of oFolder1:aDialogs[nDialog] action Abrir() pixel
    @165,083 say oSay1 prompt "REGISTROS:" size 037,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,121 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,212 say oSay3 prompt "VALOR TOTAL:" size 044,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,277 say oSay4 prompt Transf(nTotal,"@E 999,999,999.99") size 080,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,371 say oSay5 prompt "VALOR IPI:" size 044,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,403 say oSay6 prompt Transf(nIpi,"@E 999,999,999.99") size 080,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
return