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
		@063,003 folder oFolder1 size 547,190 of oDlg items "Orçamento","Pedidos de Compra","N.F. de Compra","N.F. de Fatura","Titulos Abertos","Titulos Pagos","Produtos Usados","Projetos Relacionado" colors 0,16777215 pixel
		
		fPedCompra(2)
		fProjRelacionado(8)
	activate msdialog oDlg
return

static function fPedCompra(nDialog)
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
	
	cQry := "select C7_NUM, C7_EMISSAO, C7_DATPRF, A2_NREDUZ, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER, sum(C7_TOTAL) as C7_TOTAL, sum(C7_VALIPI) as C7_VALIPI "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (C7_FORNECE = A2_COD and C7_LOJA = A2_LOJA) "
	cQry += "where C7_CLVL = '"+CTH->CTH_CLVL+"' and C7_RESIDUO = '' and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by C7_NUM, C7_EMISSAO, C7_DATPRF, A2_NREDUZ, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER "
	cQry += "order by C7_NUM"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0; nTotal := 0 ; nIpi := 0
	
	while !TEMP->(Eof())
		nTamTot := 14 - Len(AllTrim(Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")))
		nTamIpi := 10 - Len(AllTrim(Transf(TEMP->C7_VALIPI,"@E 999,999.99")))
		
		do case
			case TEMP->C7_TOTAL > 10000
				nTamTot++
			case TEMP->C7_TOTAL > 1000
				nTamTot++
		endcase
		
		do case
			case TEMP->C7_VALIPI > 1000
				nTamIpi++
		endcase
		
		SY1->(DbGoTop())
		SE4->(DbGoTop())
		
		cComprador := IIf(SY1->(DbSeek(xFilial("SY1")+TEMP->C7_USER,.F.)),AllTrim(SY1->Y1_NOME)," ")
		cCondicao := IIf(SE4->(DbSeek(xFilial("SE4")+TEMP->C7_COND,.F.)),AllTrim(SE4->E4_DESCRI)," ")
		
		AAdd(aWBrowse1,{TEMP->C7_NUM,TEMP->A2_NREDUZ,U_ConvData(TEMP->C7_EMISSAO),U_ConvData(TEMP->C7_DATPRF),TEMP->C7_NUMSC,TEMP->C7_NUMCOT,cCondicao,Space(nTamTot)+Transf(TEMP->C7_TOTAL,"@E 999,999,999.99"),Space(nTamIpi)+Transf(TEMP->C7_VALIPI,"@E 999,999.99"),cComprador})
		
		nCont++
		nTotal += TEMP->C7_TOTAL
		nIpi += TEMP->C7_VALIPI
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","","","",""})
	endif
	
	@001,001 listbox oWBrowse1 fields header "PEDIDO","FORNECEDOR","EMISSAO","ENTREGA","SOLICITACAO","COTACAO","COND. PAGTO","TOTAL","IPI","COMPRADOR" size 544,156 of oFolder1:aDialogs[nDialog] pixel
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10]}}
//		DoubleClick event
//		oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],oWBrowse1:DrawSelect()}
	@161,001 button oButton1 prompt "Visualizar" size 037,012 of oFolder1:aDialogs[nDialog] action Abrir(nDialog) pixel
    @165,083 say oSay1 prompt "REGISTROS:" size 037,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,121 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,212 say oSay3 prompt "VALOR TOTAL:" size 044,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,277 say oSay4 prompt Transf(nTotal,"@E 999,999,999.99") size 080,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,371 say oSay5 prompt "VALOR IPI:" size 044,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,413 say oSay6 prompt Transf(nIpi,"@E 999,999.99") size 080,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
return

static function fProjRelacionado(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4
	local nCont,nTotal,nPeso
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select CTH_CLVL, CTH_DESC01, CTH_DTEXIS, CTH_DTENTR, CTH_PESAF, CTH_VLAF, CTH_GESTOR "
	cQry += "from "+RetSqlName("CTH")+" "
	cQry += "where CTH_AF = '"+CTH->CTH_AF+"' and CTH_CLVL <> '"+CTH->CTH_CLVL+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by CTH_CLVL"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0; nTotal := 0 ; nPeso := 0
	
	while !TEMP->(Eof())
		AAdd(aWBrowse1,{TEMP->CTH_CLVL,TEMP->CTH_DESC01,U_ConvData(TEMP->CTH_DTEXIS),U_ConvData(TEMP->CTH_DTENTR),Transf(TEMP->CTH_PESAF,"@E 999,999,999.999"),Transf(TEMP->CTH_VLAF,"@E 999,999,999,999.9999"),Transf(TEMP->CTH_PESAF * TEMP->CTH_VLAF,"@E 999,999,999,999.9999"),TEMP->CTH_GESTOR})
		
		nCont++
		nPeso += TEMP->CTH_PESAF
		nTotal += TEMP->CTH_PESAF * TEMP->CTH_VLAF
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","",""})
	endif
	
	@001,001 listbox oWBrowse1 fields header "PROJETO","DESCRICAO","EMISSAO","ENTREGA","PESO","VL. PESO","VL. TOTAL","GESTOR" size 544,156 of oFolder1:aDialogs[nDialog] pixel
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8]}}
//		DoubleClick event
//		oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],oWBrowse1:DrawSelect()}
	@161,001 button oButton1 prompt "Visualizar" size 037,012 of oFolder1:aDialogs[nDialog] action Abrir(nDialog) pixel
    @165,083 say oSay1 prompt "REGISTROS:" size 037,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,121 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,212 say oSay3 prompt "PESO TOTAL:" size 044,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,277 say oSay4 prompt Transf(nPeso,"@E 999,999,999.999") size 080,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,371 say oSay5 prompt "VALOR TOTAL:" size 044,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
    @165,443 say oSay6 prompt Transf(nTotal,"@E 999,999,999,999.9999") size 080,007 of oFolder1:aDialogs[nDialog] colors 0,16777215 pixel
return

static function Abrir(nOpcao)
	do case
		case nOpcao == 1		//
		case nOpcao == 2		// Pedidos de Compra
		case nOpcao == 3		//
		case nOpcao == 4		//
		case nOpcao == 5		//
		case nOpcao == 6		//
		case nOpcao == 7		//
		case nOpcao == 8		// Projetos Relacionado
	endcase
return