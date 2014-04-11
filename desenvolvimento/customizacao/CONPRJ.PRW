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
	private aRotina := {{"Visualizar","AxVisual",0,1},;
						{"Pesquisar","AxPesqui",0,2},;
						{"Legenda","U_LEGCONPRJ()",0,4},;
						{"Consultar","U_CONPRJ1()",0,6}}
	private aColors := {{"CTH_BLOQ <> '1'","BR_VERDE"},;
						{"CTH_BLOQ == '1'","BR_VERMELHO"}}
	
	DbSelectArea("CTH")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"CTH",,,,,,aColors)
	TEMP->(DbCloseArea())
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
	static oTFolder
	static aTFolder := {}
	static oButton1
	static oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oSay7,oSay8,oSay9,oSay10,oSay11,oSay12,oSay13,oSay14,oSay15
	static oGet1,oGet2,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9,oGet10,oGet11,oGet12,oGet13,oGet14,oGet15
	static cGet1,cGet2,cGet3,cGet4,cGet5,cGet6,cGet7,cGet8,cGet9,cGet10,cGet11,cGet12,cGet13,cGet14,cGet15
	
	private oTSay1
	private oWBrowse1
	
	private nAbaSelect
	private nAba
	private cFiltrar := ""
	private aAreaAnt := GetArea()
	
	private cEmiIni	:= ""
	private cEmiFin	:= ""
	private cVenIni	:= ""
	private cVenFin	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Vencimento de                                     ³
	//³ mv_par04 - Vencimento ate                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("CONPRJ",.T.)
	
	cEmiIni := DToS(mv_par01)
	cEmiFin := DToS(mv_par02)
	cVenIni	:= DToS(mv_par03)
	cVenFin := DToS(mv_par04)
	
	cGet1 := CTH->CTH_CLVL
	cGet2 := CTH->CTH_DESC01
	cGet3 := CTH->CTH_COLETA
	cGet4 := CTH->CTH_AF
	cGet5 := IIf(SA1->(MsSeek(xFilial("SA1")+CTH->(CTH_CLIENT+CTH_LOJACL),.F.)),CTH->(CTH_CLIENT+CTH_LOJACL)+" - "+SA1->A1_NREDUZ," ")
	cGet6 := IIf(CTH->CTH_BLOQ == "1","SIM","NAO")
	cGet7 := U_ConvData(DToS(CTH->CTH_DTEXIS))
	cGet8 := U_ConvData(DToS(CTH->CTH_DTREAL))
	cGet9 := CTH->CTH_PESPRJ
	cGet10 := CTH->CTH_VLPROJ
	cGet11 := CTH->CTH_PESAF
	cGet12 := CTH->CTH_VLAF
	cGet13 := IIf(SX5->(MsSeek(xFilial("SX5")+"Z1"+CTH->CTH_TPPRJ,.F.)),AllTrim(SX5->X5_DESCRI)," ")
	cGet14 := CTH->CTH_GESTOR
	cGet15 := U_ConvData(DToS(CTH->CTH_CADCOL))
	
	define msdialog oDlg title "PROJETO - CONSULTA" from 000,000 to 510,1100 colors 0,16777215 pixel
		aButtons := {}
		aTFolder := {"Orçamento","Pedidos de Compra","N.F. de Compra","N.F. de Venda","C.P. Aberto","C.P. Pago","C.R. Aberto","C.R. Recebido","Produtos Usados","Projetos Relacionado"}
		
		AAdd(aButtons,{"Filtrar",{|| Filtrar()},"Filtrar...","Filtrar",{|| .T.}})
		
		EnchoiceBar(oDlg,{|| oDlg:End()},{|| Fechar(oDlg)},,@aButtons)
		
		@016,003 group oGroup1 to 061,550 of oDlg color 0,16777215 pixel
		@018,006 say oSay1 prompt "Projeto" size 025,007 of oDlg colors 0,16777215 pixel
		@025,006 msget oGet1 var cGet1 size 033,010 when .F. of oDlg colors 0,16777215 pixel
		@018,045 say oSay2 prompt "Descrição" size 048,007 of oDlg colors 0,16777215 pixel
		@025,045 msget oGet2 var cGet2 size 194,010 when .F. of oDlg colors 0,16777215 pixel
		@018,240 say oSay3 prompt "Coleta" size 025,007 of oDlg colors 0,16777215 pixel
		@025,240 msget oGet3 var cGet3 size 060,010 when .F. of oDlg colors 0,16777215 pixel
		@018,301 say oSay4 prompt "Ordem de Compra (AF)" size 063,007 of oDlg colors 0,16777215 pixel
		@025,301 msget oGet4 var cGet4 size 079,010 when .F. of oDlg colors 0,16777215 pixel
		@018,381 say oSay5 prompt "Cliente" size 025,007 of oDlg colors 0,16777215 pixel
		@025,381 msget oGet5 var cGet5 size 127,010 when .F. of oDlg colors 0,16777215 pixel
		@018,519 say oSay6 prompt "Bloqueado" size 027,007 of oDlg colors 0,16777215 pixel
		@025,519 msget oGet6 var cGet6 size 023,010 when .F. of oDlg colors 0,16777215 pixel
		@039,006 say oSay7 prompt "Data Inicio" size 033,007 of oDlg colors 0,16777215 pixel
		@046,006 msget oGet7 var cGet7 size 038,010 when .F. of oDlg colors 0,16777215 pixel
		@039,045 say oSay8 prompt "Data Entrega" size 035,007 of oDlg colors 0,16777215 pixel
		@046,045 msget oGet8 var cGet8 size 038,010 when .F. of oDlg colors 0,16777215 pixel
		@039,084 say oSay9 prompt "Peso Projeto" size 041,007 of oDlg colors 0,16777215 pixel
		@046,084 msget oGet9 var cGet9 size 060,010 picture "@E 999,999,999.999" when .F. of oDlg colors 0,16777215 pixel
		@039,146 say oSay10 prompt "Preco p/ KG" size 039,007 of oDlg colors 0,16777215 pixel
		@046,146 msget oGet10 var cGet10 size 060,010 picture "@E 999,999,999,999.9999" when .F. of oDlg colors 0,16777215 pixel
		@039,208 say oSay11 prompt "Peso AF" size 025,007 of oDlg colors 0,16777215 pixel
		@046,208 msget oGet11 var cGet11 size 060,010 picture "@E 999,999,999.999" when .F. of oDlg colors 0,16777215 pixel
		@039,270 say oSay12 prompt "Preco p/ KG AF" size 044,007 of oDlg colors 0,16777215 pixel
		@046,270 msget oGet12 var cGet12 size 060,010 picture "@E 999,999,999,999.9999" when .F. of oDlg colors 0,16777215 pixel
		@039,332 say oSay13 prompt "Tipo Projeto" size 045,007 of oDlg colors 0,16777215 pixel
		@046,332 msget oGet13 var cGet13 size 077,010 when .F. of oDlg colors 0,16777215 pixel
		@039,410 say oSay14 prompt "Gestor" size 025,007 of oDlg colors 0,16777215 pixel
		@046,410 msget oGet14 var cGet14 size 078,010 when .F. of oDlg colors 0,16777215 pixel
		@039,504 say oSay15 prompt "Cad. Coleta" size 038,007 of oDlg colors 0,16777215 pixel
		@046,504 msget oGet15 var cGet15 size 038,010 when .F. of oDlg colors 0,16777215 pixel
		
        oTFolder := TFolder():New(063,003,aTFolder,,oDlg,,,,.T.,,547,190)
        oTFolder:bSetOption := {|nAbaSelect| SelecionarAba(nAbaSelect)}
		
		fOrcamento(1) ; fPedCompra(2) ; fNFEntrada(3) ; fNFSaida(4) ; fCPAberto(5)
		fCPPago(6) ; fCRAberto(7) ; fCRPago(8) ; fProdUsado(9) ; fProjRelacionado(10)
	activate msdialog oDlg
return

static function fOrcamento(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4
	local nCont,nTotOrc,nTotEmp,nTotRea
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select Z4_DTORCAM, Z4_ITEM, Z4_GGRUPO, Z4_DESCGGR, sum(Z4_VLORCAM) as Z4_VLORCAM, sum(Z4_EMPENHA) as Z4_EMPENHA, sum(Z4_VLREALI) as Z4_VLREALI, sum(Z4_SALDO) as Z4_SALDO "
	cQry += "from "+RetSqlName("SZ4")+" "
	cQry += "where Z4_PROJETO = '"+CTH->CTH_CLVL+"' and D_E_L_E_T_ <> '*' "
	cQry += "group by Z4_DTORCAM, Z4_ITEM, Z4_GGRUPO, Z4_DESCGGR "
	cQry += "order by Z4_ITEM"
	cQry := ChangeQuery(cQry)
	
//	tcquery cQry new alias "TEMP"
	
//	DbSelectArea("TEMP")
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TEMP",.T.,.T.)
	
	nCont := 0 ; nTotOrc := 0 ; nTotEmp := 0 ; nTotRea := 0
	
	while !TEMP->(Eof())
		AAdd(aWBrowse1,{TEMP->Z4_ITEM,TEMP->Z4_GGRUPO,TEMP->Z4_DESCGGR,U_ConvData(TEMP->Z4_DTORCAM),Transform(TEMP->Z4_VLORCAM,PesqPict("SZ4","Z4_VLORCAM")),TEMP->Z4_EMPENHA,TEMP->Z4_VLREALI,TEMP->Z4_SALDO})
		
		nCont++
		nTotOrc += TEMP->Z4_VLORCAM
		nTotEmp += TEMP->Z4_EMPENHA
		nTotRea += TEMP->Z4_VLREALI
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","",0,0,0,0})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "ITEM","GRUPO","DESCRICAO","DT ORCAMENTO","VL ORCAMENTO","VL EMPENHADO","VL REALIZADO","SALDO" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8]}}
		
	    @165,001 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,038 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,330 say oSay3 prompt "ORCADO" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,330 msget oGet1 var nTotOrc size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,402 say oSay4 prompt "EMPENHADO" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,402 msget oGet2 var nTotEmp size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay5 prompt "REALIZADO" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet3 var nTotRea size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fPedCompra(nDialog)
//	local oWBrowse1
	local aWBrowse1 := {}
//	local oSay1,oSay2,oSay3,oSay4
	local nCont,nTotal,nIpi
//	private oTSay1,oTSay2,oTSay3,oTSay4
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SY1")
	SY1->(DbSetOrder(3))
	
	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	
	cQry := "select C7_NUM, C7_EMISSAO, C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER, C7_RESIDUO, sum(C7_QUANT) as C7_QUANT, sum(C7_QUJE) as C7_QUJE, sum(C7_TOTAL) as C7_TOTAL, sum(C7_VALIPI) as C7_VALIPI "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (C7_FORNECE = A2_COD and C7_LOJA = A2_LOJA) "
	cQry += "where C7_CLVL = '"+CTH->CTH_CLVL+"' and (C7_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and C7_RESIDUO = '' "+cFiltrar+"and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by C7_NUM, C7_EMISSAO, C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER, C7_RESIDUO "
	cQry += "order by C7_NUM"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0 ; nIpi := 0
	
	while !TEMP->(Eof())
/*		nTamTot := 14 - Len(AllTrim(Transf(TEMP->C7_TOTAL,"@E 999,999,999.99")))
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
		
		PesqPict("SE2","E2_SALDO")*/
		
		SY1->(DbGoTop())
		SE4->(DbGoTop())
		
		cComprador := IIf(SY1->(MsSeek(xFilial("SY1")+TEMP->C7_USER,.F.)),AllTrim(SY1->Y1_NOME)," ")
		cCondicao := IIf(SE4->(MsSeek(xFilial("SE4")+TEMP->C7_COND,.F.)),AllTrim(SE4->E4_DESCRI)," ")
		
//		AAdd(aWBrowse1,{TEMP->C7_NUM,TEMP->A2_NREDUZ,U_ConvData(TEMP->C7_EMISSAO),U_ConvData(TEMP->C7_DATPRF),TEMP->C7_NUMSC,TEMP->C7_NUMCOT,cCondicao,Space(nTamTot)+Transf(TEMP->C7_TOTAL,"@E 999,999,999.99"),Space(nTamIpi)+Transf(TEMP->C7_VALIPI,"@E 999,999.99"),cComprador})
		AAdd(aWBrowse1,{TEMP->C7_NUM,TEMP->C7_FORNECE+"-"+TEMP->C7_LOJA+" "+TEMP->A2_NREDUZ,U_ConvData(TEMP->C7_EMISSAO),U_ConvData(TEMP->C7_DATPRF),TEMP->C7_NUMSC,TEMP->C7_NUMCOT,cCondicao,TEMP->C7_TOTAL,TEMP->C7_VALIPI,(TEMP->C7_QUANT - TEMP->C7_QUJE),cComprador})
		
		nCont++
		nTotal += TEMP->C7_TOTAL
		nIpi += TEMP->C7_VALIPI
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","",0,0,0,""})
		
//		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		oTSay1 := TSay():New(001,001,{|| "Nenhum registro encontrado para esse projeto."},oTFolder:aDialogs[nDialog],,,,,,.T.,,,150,007)
	else
		@001,001 listbox oWBrowse1 fields header "PEDIDO","FORNECEDOR","EMISSAO","ENTREGA","SOLICITACAO","COTACAO","COND. PAGTO","TOTAL","IPI","A ENTREGAR","COMPRADOR" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10],aWBrowse1[oWBrowse1:nAt,11]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SC7",aWBrowse1[oWBrowse1:nAt,1]) pixel
//	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		oTSay1 := TSay():New(165,043,{|| "REGISTROS:"},oTFolder:aDialogs[nDialog],,,,,,.T.,,,037,007)
//	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		oTSay2 := TSay():New(165,080,{|| Transf(nCont,"999999")},oTFolder:aDialogs[nDialog],,,,,,.T.,,,025,007)
//		@157,402 say oSay3 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		oTSay3 := TSay():New(157,402,{|| "TOTAL"},oTFolder:aDialogs[nDialog],,,,,,.T.,,,060,007)
		@164,402 msget oGet1 var nTotal size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
//		@157,474 say oSay4 prompt "IPI" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		oTSay4 := TSay():New(157,474,{|| "IPI"},oTFolder:aDialogs[nDialog],,,,,,.T.,,,060,007)
		@164,474 msget oGet2 var nIpi size 070,010 picture "@E 999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fNFEntrada(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4,oSay5
	local oGet1,oGet2,oGet3
	local nCont,nTotal,nIcms,nIpi
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	DbSelectArea("CTT")
	CTT->(DbSetOrder(1))
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	
	cQry := "select D1_TIPO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_UM, D1_TES, D1_CF, D1_CC, F1_CR, sum(D1_QUANT) as D1_QUANT, sum(D1_TOTAL) as D1_TOTAL, sum(D1_VALICM) as D1_VALICM, sum(D1_VALIPI) as D1_VALIPI "
	cQry += "from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SF1")+" SF1 on (D1_DOC = F1_DOC and D1_SERIE = F1_SERIE and D1_FORNECE = F1_FORNECE and D1_LOJA = F1_LOJA) "
	cQry += "where D1_CLVL = '"+CTH->CTH_CLVL+"' and (D1_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and SD1.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' "
	cQry += "group by D1_TIPO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_UM, D1_TES, D1_CF, D1_CC, F1_CR "
	cQry += "order by D1_EMISSAO, D1_TIPO, D1_DOC, D1_SERIE"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0 ; nIcms := 0 ; nIpi := 0
	
	while !TEMP->(Eof())
		SF4->(DbGoTop())
		CTT->(DbGoTop())
		
		if TEMP->D1_TIPO $ "B/D"
			SA1->(DbGoTop())
			
			cFornec := IIf(SA1->(MsSeek(xFilial("SA1")+TEMP->(D1_FORNECE+D1_LOJA),.F.)),TEMP->D1_FORNECE+"-"+TEMP->D1_LOJA+" "+AllTrim(SA1->A1_NREDUZ)," ")
		else
			SA2->(DbGoTop())
			
			cFornec := IIf(SA2->(MsSeek(xFilial("SA2")+TEMP->(D1_FORNECE+D1_LOJA),.F.)),TEMP->D1_FORNECE+"-"+TEMP->D1_LOJA+" "+AllTrim(SA2->A2_NREDUZ)," ")
		endif
		
		cTxtCfop := IIf(SF4->(MsSeek(xFilial("SF4")+TEMP->D1_TES,.F.)),AllTrim(SF4->F4_TEXTO)," ")
		cCCusto := IIf(CTT->(MsSeek(xFilial("CTT")+TEMP->D1_CC,.F.)),AllTrim(CTT->CTT_DESC01)," ")
		
		AAdd(aWBrowse1,{U_ConvData(TEMP->D1_EMISSAO),TEMP->D1_TIPO,TEMP->D1_DOC,TEMP->D1_SERIE,cFornec,TEMP->F1_CR,TEMP->D1_CF,cTxtCfop,cCCusto,TEMP->D1_UM,TEMP->D1_QUANT,TEMP->D1_TOTAL,TEMP->D1_VALICM,TEMP->D1_VALIPI})
		
		nCont++
		
		if TEMP->D1_TIPO $ "N/C"
			nTotal += TEMP->D1_TOTAL
			nIcms += TEMP->D1_VALICM
			nIpi += TEMP->D1_VALIPI
		endif
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","","","","",0,0,0,0})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "EMISSAO","TIPO","NOTA","SERIE","FORNECEDOR","C.R.","CFOP","NATUREZA","C. CUSTO","UN","QUANT","TOTAL","ICMS","IPI" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10],aWBrowse1[oWBrowse1:nAt,11],aWBrowse1[oWBrowse1:nAt,12],aWBrowse1[oWBrowse1:nAt,13],aWBrowse1[oWBrowse1:nAt,14]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SF1",aWBrowse1[oWBrowse1:nAt,3]+aWBrowse1[oWBrowse1:nAt,4]+Left(aWBrowse1[oWBrowse1:nAt,5],6)+SubStr(aWBrowse1[oWBrowse1:nAt,5],8,2)) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,330 say oSay3 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,330 msget oGet1 var nTotal size 070,010 picture "@E 99,999,999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,402 say oSay4 prompt "ICMS" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,402 msget oGet2 var nIcms size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay5 prompt "IPI" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet3 var nIpi size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fNFSaida(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4,oSay5
	local oGet1,oGet2,oGet3
	local nCont,nTotal,nIcms,nIpi,cCliente
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	
	cQry := "select D2_TIPO, D2_DOC, D2_SERIE, D2_EMISSAO, D2_UM, D2_TES, D2_CF, D2_CLIENTE, D2_LOJA, sum(D2_QUANT) as D2_QUANT, sum(D2_TOTAL) as D2_TOTAL, sum(D2_VALICM) as D2_VALICM, sum(D2_VALIPI) as D2_VALIPI "
	cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SF2")+" SF2 on (D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_CLIENTE = F2_CLIENTE and D2_LOJA = F2_LOJA) "
	cQry += "	inner join "+RetSqlName("SC6")+" SC6 on (D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM) "
	cQry += "where C6_CLVL = '"+CTH->CTH_CLVL+"' and (D2_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and SD2.D_E_L_E_T_ <> '*' and SF2.D_E_L_E_T_ <> '*' "
	cQry += "group by D2_TIPO, D2_DOC, D2_SERIE, D2_EMISSAO, D2_UM, D2_TES, D2_CF, D2_CLIENTE, D2_LOJA "
	cQry += "order by D2_EMISSAO, D2_TIPO, D2_DOC, D2_SERIE"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0 ; nIcms := 0 ; nIpi := 0 ; cCliente := ""
	
	while !TEMP->(Eof())
		SF4->(DbGoTop())
		
		cTxtCfop := IIf(SF4->(MsSeek(xFilial("SF4")+TEMP->D2_TES,.F.)),AllTrim(SF4->F4_TEXTO)," ")
		
		AAdd(aWBrowse1,{U_ConvData(TEMP->D2_EMISSAO),TEMP->D2_TIPO,TEMP->D2_DOC,TEMP->D2_SERIE,TEMP->D2_CF,cTxtCfop,TEMP->D2_UM,TEMP->D2_QUANT,TEMP->D2_TOTAL,TEMP->D2_VALICM,TEMP->D2_VALIPI})
		
		nCont++
		cCliente := TEMP->(D2_CLIENTE+D2_LOJA)
		
		if TEMP->D2_TIPO == "N"
			nTotal += TEMP->D2_TOTAL
			nIcms += TEMP->D2_VALICM
			nIpi += TEMP->D2_VALIPI
		endif
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","",0,0,0,0})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "EMISSAO","TIPO","NOTA","SERIE","CFOP","NATUREZA","UN","QUANT","TOTAL","ICMS","IPI" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10],aWBrowse1[oWBrowse1:nAt,11]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SF2",aWBrowse1[oWBrowse1:nAt,3]+aWBrowse1[oWBrowse1:nAt,4]+cCliente) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,330 say oSay3 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,330 msget oGet1 var nTotal size 070,010 picture "@E 99,999,999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,402 say oSay4 prompt "ICMS" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,402 msget oGet2 var nIcms size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay5 prompt "IPI" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet3 var nIpi size 070,010 picture "@E 999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fCPAberto(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4
	local oGet1,oGet2
	local nCont,nTotal
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SED")
	SED->(DbSetOrder(1))
	
	cQry := "select E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_SALDO, datediff(day,GETDATE(),E2_VENCREA) as DIFF "
	cQry += "from "+RetSqlName("SE2")+" SE2 inner join "+RetSqlName("SD1")+" SD1 on (E2_NUM = D1_DOC and E2_PREFIXO = D1_SERIE and E2_FORNECE = D1_FORNECE and E2_LOJA = D1_LOJA) "
	cQry += "where D1_CLVL = '"+CTH->CTH_CLVL+"' and (E2_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E2_BAIXA = '' or (E2_BAIXA <> '' and E2_SALDO > 0)) and SE2.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' "
	cQry += "order by E2_VENCREA, E2_NUM, E2_PREFIXO"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0
	
	while !TEMP->(Eof())
		SED->(DbGoTop())
		
		cNatureza := IIf(SED->(MsSeek(xFilial("SED")+TEMP->E2_NATUREZ,.F.)),AllTrim(SED->ED_DESCRIC)," ")
		nAtraso := IIf(TEMP->DIFF >= 0,0,TEMP->DIFF)
		
		AAdd(aWBrowse1,{TEMP->E2_PREFIXO,TEMP->E2_NUM,TEMP->E2_PARCELA,TEMP->E2_TIPO,TEMP->E2_FORNECE+"-"+TEMP->E2_LOJA+" "+TEMP->E2_NOMFOR,U_ConvData(TEMP->E2_EMISSAO),U_ConvData(TEMP->E2_VENCREA),cNatureza,TEMP->E2_SALDO,nAtraso})
		
		nCont++
		nTotal += TEMP->E2_SALDO
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","","",0,0})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "PREFIXO","NUMERO","PARCELA","TIPO","FORNECEDOR","EMISSAO","VENCIMENTO","NATUREZA","VALOR","ATRASO" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SE2",aWBrowse1[oWBrowse1:nAt,1]+aWBrowse1[oWBrowse1:nAt,2]+aWBrowse1[oWBrowse1:nAt,3]+aWBrowse1[oWBrowse1:nAt,4]+Left(aWBrowse1[oWBrowse1:nAt,5],6)+SubStr(aWBrowse1[oWBrowse1:nAt,5],8,2)) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay4 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet2 var nTotal size 070,010 picture "@E 999,999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fCPPago(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3
	local oGet1
	local nCont,nTotal
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SED")
	SED->(DbSetOrder(1))
	
	cQry := "select distinct E5_DATA, E2_BAIXA, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_EMISSAO, E2_CR, E2_SALDO, E2_FATPREF, E2_FATURA, E5_VALOR, E5_NUMTED, E5_NUMCHEQ, E5_TIPODOC, E5_DOCUMEN,E5_BANCO, E5_AGENCIA, E5_CONTA "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SE2")+" SE2 on (E5_NUMERO = E2_NUM and E5_PREFIXO = E2_PREFIXO and E5_PARCELA = E2_PARCELA and E5_FORNECE = E2_FORNECE and E5_LOJA = E2_LOJA) "
	cQry += "	inner join "+RetSqlName("SD1")+" SD1 on (E2_NUM = D1_DOC and E2_PREFIXO = D1_SERIE and E2_FORNECE = D1_FORNECE and E2_LOJA = D1_LOJA) "
	cQry += "where D1_CLVL = '"+CTH->CTH_CLVL+"' and (E2_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and (E2_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and E5_TIPODOC in ('BA','VL','CP') and E5_TIPO not in ('','PA') and E2_FATFOR = '' and SE5.D_E_L_E_T_ <> '*' and SE2.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' "
	cQry += "order by E2_NUM, E2_PREFIXO, E2_PARCELA, E2_FORNECE, E2_LOJA"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0
	
	while !TEMP->(Eof())
		SED->(DbGoTop())
		
		cNatureza := IIf(SED->(MsSeek(xFilial("SED")+TEMP->E2_NATUREZ,.F.)),AllTrim(SED->ED_DESCRIC)," ")
		
		AAdd(aWBrowse1,{TEMP->E2_NUM,TEMP->E2_PREFIXO,TEMP->E2_PARCELA,TEMP->E2_TIPO,TEMP->E2_NOMFOR,U_ConvData(TEMP->E2_EMISSAO),U_ConvData(TEMP->E2_VENCREA),U_ConvData(TEMP->E5_DATA),cNatureza,TEMP->E2_CR,TEMP->E5_VALOR,TEMP->E5_NUMTED,TEMP->E5_NUMCHEQ,TEMP->E5_BANCO,TEMP->E5_AGENCIA,TEMP->E5_CONTA,TEMP->E5_DOCUMEN,TEMP->E2_FATURA,TEMP->E2_FATPREF})
		
		nCont++
		
		if TEMP->E2_TIPO <> "NDF"
			nTotal += TEMP->E5_VALOR
		endif
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","","","","",0,"","","","","","","",""})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "NUMERO","PREFIXO","PARCELA","TIPO","FORNECEDOR","EMISSAO","VENCIMENTO","BAIXA","NATUREZA","C.R.","VALOR","TED","CHEQUE","BANCO","AGENCIA","CONTA","DOCUMENTO","FATURA","PREF. FAT." size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10],aWBrowse1[oWBrowse1:nAt,11],aWBrowse1[oWBrowse1:nAt,12],aWBrowse1[oWBrowse1:nAt,13],aWBrowse1[oWBrowse1:nAt,14],aWBrowse1[oWBrowse1:nAt,15],aWBrowse1[oWBrowse1:nAt,16],aWBrowse1[oWBrowse1:nAt,17],aWBrowse1[oWBrowse1:nAt,18],aWBrowse1[oWBrowse1:nAt,19]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SE5",aWBrowse1[oWBrowse1:nAt,14]+aWBrowse1[oWBrowse1:nAt,15]+aWBrowse1[oWBrowse1:nAt,16]+aWBrowse1[oWBrowse1:nAt,2]+aWBrowse1[oWBrowse1:nAt,1]+aWBrowse1[oWBrowse1:nAt,3]) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay3 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet1 var nTotal size 070,010 picture "@E 999,999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fCRAberto(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4
	local oGet1,oGet2
	local nCont,nTotal
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SED")
	SED->(DbSetOrder(1))
	
	cQry := "select E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO, E1_NATUREZ, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_SALDO, datediff(day,GETDATE(),E1_VENCREA) as DIFF "
	cQry += "from "+RetSqlName("SE1")+" SE1 inner join "+RetSqlName("SD2")+" SD2 on (E1_NUM = D2_DOC and E1_PREFIXO = D2_SERIE and E1_CLIENTE = D2_CLIENTE and E1_LOJA = D2_LOJA) "
	cQry += "	inner join "+RetSqlName("SC6")+" SC6 on (D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM) "
	cQry += "where C6_CLVL = '"+CTH->CTH_CLVL+"' and (E1_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and (E1_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and (E1_BAIXA = '' or (E1_BAIXA <> '' and E1_SALDO > 0)) and SE1.D_E_L_E_T_ <> '*' and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' "
	cQry += "order by E1_VENCREA, E1_NUM, E1_PREFIXO"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0
	
	while !TEMP->(Eof())
		SED->(DbGoTop())
		
		cNatureza := IIf(SED->(MsSeek(xFilial("SED")+TEMP->E1_NATUREZ,.F.)),AllTrim(SED->ED_DESCRIC)," ")
		nAtraso := IIf(TEMP->DIFF >= 0,0,TEMP->DIFF)
		
		AAdd(aWBrowse1,{TEMP->E1_PREFIXO,TEMP->E1_NUM,TEMP->E1_PARCELA,TEMP->E1_TIPO,TEMP->E1_CLIENTE+"-"+TEMP->E1_LOJA+" "+TEMP->E1_NOMCLI,U_ConvData(TEMP->E1_EMISSAO),U_ConvData(TEMP->E1_VENCREA),cNatureza,TEMP->E1_SALDO,nAtraso})
		
		nCont++
		nTotal += TEMP->E1_SALDO
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","","",0,0})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "PREFIXO","NUMERO","PARCELA","TIPO","CLIENTE","EMISSAO","VENCIMENTO","NATUREZA","VALOR","ATRASO" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SE1",Left(+aWBrowse1[oWBrowse1:nAt,5],6)+SubStr(+aWBrowse1[oWBrowse1:nAt,5],8,2)+aWBrowse1[oWBrowse1:nAt,1]+aWBrowse1[oWBrowse1:nAt,2]+aWBrowse1[oWBrowse1:nAt,3]+aWBrowse1[oWBrowse1:nAt,4]) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay4 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet2 var nTotal size 070,010 picture "@E 999,999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fCRPago(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3
	local oGet1
	local nCont,nTotal
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SED")
	SED->(DbSetOrder(1))
	
	cQry := "select distinct E5_DATA, E1_BAIXA, E1_VENCREA, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_NATUREZ, E1_EMISSAO, E1_SALDO, E1_FATPREF, E1_FATURA, E5_VALOR, E5_NUMTED, E5_NUMCHEQ, E5_TIPODOC, E5_DOCUMEN,E5_BANCO, E5_AGENCIA, E5_CONTA "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SE1")+" SE1 on (E5_NUMERO = E1_NUM and E5_PREFIXO = E1_PREFIXO and E5_PARCELA = E1_PARCELA and E5_CLIENTE = E1_CLIENTE and E5_LOJA = E1_LOJA) "
	cQry += "	inner join "+RetSqlName("SD2")+" SD2 on (E1_NUM = D2_DOC and E1_PREFIXO = D2_SERIE and E1_CLIENTE = D2_CLIENTE and E1_LOJA = D2_LOJA) "
	cQry += "	inner join "+RetSqlName("SC6")+" SC6 on (D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM) "
	cQry += "where C6_CLVL = '"+CTH->CTH_CLVL+"' and (E1_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and (E1_VENCREA between '"+cVenIni+"' and '"+cVenFin+"') and E5_TIPODOC in ('BA','VL','CP') and E5_TIPO not in ('','RA') and SE5.D_E_L_E_T_ <> '*' and SE1.D_E_L_E_T_ <> '*' and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' "
	cQry += "order by E1_NUM, E1_PREFIXO, E1_PARCELA, E1_CLIENTE, E1_LOJA"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0
	
	while !TEMP->(Eof())
		SED->(DbGoTop())
		
		cNatureza := IIf(SED->(MsSeek(xFilial("SED")+TEMP->E1_NATUREZ,.F.)),AllTrim(SED->ED_DESCRIC)," ")
		
		AAdd(aWBrowse1,{TEMP->E1_NUM,TEMP->E1_PREFIXO,TEMP->E1_PARCELA,TEMP->E1_TIPO,TEMP->E1_CLIENTE+"-"+TEMP->E1_LOJA+" "+TEMP->E1_NOMCLI,U_ConvData(TEMP->E1_EMISSAO),U_ConvData(TEMP->E1_VENCREA),U_ConvData(TEMP->E5_DATA),cNatureza,TEMP->E5_VALOR,TEMP->E5_BANCO,TEMP->E5_AGENCIA,TEMP->E5_CONTA,TEMP->E5_DOCUMEN})
		
		nCont++
		
		if TEMP->E1_TIPO <> "NDF"
			nTotal += TEMP->E5_VALOR
		endif
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","","","","","","",0,"","","",""})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "NUMERO","PREFIXO","PARCELA","TIPO","CLIENTE","EMISSAO","VENCIMENTO","BAIXA","NATUREZA","VALOR","BANCO","AGENCIA","CONTA","DOCUMENTO" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8],aWBrowse1[oWBrowse1:nAt,9],aWBrowse1[oWBrowse1:nAt,10],aWBrowse1[oWBrowse1:nAt,11],aWBrowse1[oWBrowse1:nAt,12],aWBrowse1[oWBrowse1:nAt,13],aWBrowse1[oWBrowse1:nAt,14]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SE5",aWBrowse1[oWBrowse1:nAt,11]+aWBrowse1[oWBrowse1:nAt,12]+aWBrowse1[oWBrowse1:nAt,13]+aWBrowse1[oWBrowse1:nAt,2]+aWBrowse1[oWBrowse1:nAt,1]+aWBrowse1[oWBrowse1:nAt,3]) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay3 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet1 var nTotal size 070,010 picture "@E 999,999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fProdUsado(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4
	local oGet1,oGet2
	local nCont
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	
	cQry := "select distinct C7_PRODUTO as PRODUTO, C7_LOCAL as ARMAZEM, 'PEDIDO DE COMPRA' as TABELA from "+RetSqlName("SC7")+" where C7_CLVL = '"+CTH->CTH_CLVL+"' and (C7_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "union all "
	cQry += "select distinct D1_COD as PRODUTO, D1_LOCAL as ARMAZEM, 'NOTA DE ENTRADA' as TABELA from "+RetSqlName("SD1")+" where D1_CLVL = '"+CTH->CTH_CLVL+"' and (D1_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "union all "
	cQry += "select distinct D2_COD as PRODUTO, D2_LOCAL as ARMAZEM, 'NOTA DE SAIDA' as TABELA from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SC6")+" SC6 on (D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM) where C6_CLVL = '"+CTH->CTH_CLVL+"' and (D2_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' "
	cQry += "order by PRODUTO, ARMAZEM, TABELA"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0
	
	while !TEMP->(Eof())
		SB1->(DbGoTop())
		
		cDescricao := IIf(SB1->(MsSeek(xFilial("SB1")+TEMP->(PRODUTO+ARMAZEM),.F.)),SB1->B1_DESC," ")
		
		AAdd(aWBrowse1,{TEMP->PRODUTO,TEMP->ARMAZEM,cDescricao,TEMP->TABELA})
		
		nCont++
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","",""})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "PRODUTO","ARMAZEM","DESCRICAO","UTILIZADO" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"SB1",aWBrowse1[oWBrowse1:nAt,1]+aWBrowse1[oWBrowse1:nAt,2]) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function fProjRelacionado(nDialog)
	local oWBrowse1
	local aWBrowse1 := {}
	local oSay1,oSay2,oSay3,oSay4
	local oGet1,oGet2
	local nCont,nTotal,nPeso
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
//	cQry := "select CTH_CLVL, CTH_DESC01, CTH_DTEXIS, CTH_DTENTR, CTH_PESAF, CTH_VLAF, CTH_GESTOR, dbo.ConverteMoedaReal(CTH_PESAF) as PESAF, dbo.ConverteMoedaReal(CTH_VLAF) as VLAF, dbo.ConverteMoedaReal(CTH_PESAF * CTH_VLAF) as TOTKG "
	cQry := "select CTH_CLVL, CTH_DESC01, CTH_DTEXIS, CTH_DTENTR, CTH_PESAF, CTH_VLAF, CTH_GESTOR "
	cQry += "from "+RetSqlName("CTH")+" "
	cQry += "where CTH_AF = '"+CTH->CTH_AF+"' and CTH_CLVL <> '"+CTH->CTH_CLVL+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by CTH_CLVL"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	nCont := 0 ; nTotal := 0 ; nPeso := 0
	
	while !TEMP->(Eof())
//		AAdd(aWBrowse1,{TEMP->CTH_CLVL,TEMP->CTH_DESC01,U_ConvData(TEMP->CTH_DTEXIS),U_ConvData(TEMP->CTH_DTENTR),Transf(TEMP->CTH_PESAF,"@E 999,999,999.999"),Transf(TEMP->CTH_VLAF,"@E 999,999,999,999.99"),Transf(TEMP->CTH_PESAF * TEMP->CTH_VLAF,"@E 999,999,999,999.99"),TEMP->CTH_GESTOR})
		AAdd(aWBrowse1,{TEMP->CTH_CLVL,TEMP->CTH_DESC01,U_ConvData(TEMP->CTH_DTEXIS),U_ConvData(TEMP->CTH_DTENTR),TEMP->CTH_PESAF,TEMP->CTH_VLAF,(TEMP->CTH_PESAF * TEMP->CTH_VLAF),TEMP->CTH_GESTOR})
		
		nCont++
		nPeso += TEMP->CTH_PESAF
		nTotal += TEMP->CTH_PESAF * TEMP->CTH_VLAF
		
		TEMP->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"","","","",0,0,0,""})
		
		@001,001 say oSay1 prompt "Nenhum registro encontrado para esse projeto." size 150,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	else
		@001,001 listbox oWBrowse1 fields header "PROJETO","DESCRICAO","EMISSAO","ENTREGA","PESO","VL. PESO","VL. TOTAL","GESTOR" size 544,156 of oTFolder:aDialogs[nDialog] pixel
			oWBrowse1:SetArray(aWBrowse1)
			oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7],aWBrowse1[oWBrowse1:nAt,8]}}
		@161,001 button oButton1 prompt "Visualizar" size 037,012 when !Empty(nCont) of oTFolder:aDialogs[nDialog] action Abrir(nDialog,"CTH",aWBrowse1[oWBrowse1:nAt,1]) pixel
	    @165,043 say oSay1 prompt "REGISTROS:" size 037,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	    @165,080 say oSay2 prompt Transf(nCont,"999999") size 025,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,402 say oSay3 prompt "PESO" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,402 msget oGet1 var nPeso size 070,010 picture "@E 999,999,999.999" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@157,474 say oSay4 prompt "TOTAL" size 060,007 of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
		@164,474 msget oGet2 var nTotal size 070,010 picture "@E 999,999,999,999.99" when .F. of oTFolder:aDialogs[nDialog] colors 0,16777215 pixel
	endif
return

static function Fechar(oDlg)
	RestArea(aAreaAnt)
	oDlg:End()
return

static function Abrir(nOpcao,cAliasBrw,cRegistro)
	local nOrder := 0
	
//	Alert(cRegistro)
	
	do case
		case cAliasBrw == "SE1"
			nOrder := 2
		case cAliasBrw == "SE5"
			nOrder := 3
		otherwise
			nOrder := 1
	endcase
	
	MaFisEnd()
	DbSelectArea(cAliasBrw)
	DbSetOrder(nOrder)
	DbSeek(xFilial(cAliasBrw)+cRegistro)
	
	do case
		case cAliasBrw $ "CTH/SB1/SE1/SE2/SE5"
			AxVisual(cAliasBrw,Recno(),4)
		case cAliasBrw $ "SC7"
			private l120Auto := .F.
			private nTipoPed := 1
			
			A120Pedido(cAliasBrw,Recno(),2)
		case cAliasBrw $ "SF1"
			MATA103(,,2)
		case cAliasBrw $ "SF2"
			Mc090Visual(cAliasBrw,Recno(),2)
	endcase
return

static function Filtrar()
	do case
		case nAba == 2		//fPedCompra(2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Parametros utilizados pelo programa                          ³
			//³ mv_par01 - Fornecedor de                                     ³
			//³ mv_par02 - Fornecedor ate                                    ³
			//³ mv_par03 - Comprador de                                      ³
			//³ mv_par04 - Comprador ate                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			Pergunte("CONPRJ02",.T.)
			
			cFiltrar := "and (C7_FORNECE between '"+mv_par01+"' and '"+mv_par02+"') and (C7_USER between '"+mv_par03+"' and '"+mv_par04+"') "
			Set Filter to &("(C7_FORNECE between '"+mv_par01+"' and '"+mv_par02+"') and (C7_USER between '"+mv_par03+"' and '"+mv_par04+"')")
			
			oWBrowse1:Refresh()
//			fPedCompra(2)
//			oTSay1:SetText("DEUUUUU")
		case nAba == 3		//fNFEntrada(3)
//			fornecedor
//			tipo
//			cr
//			cfop
//			c. custo
		case nAba == 4		//fNFSaida(4)
//			tipo
//			cfop
		case nAba == 5		//fCPAberto(5)
//			fornecedor
		case nAba == 6		//fCPPago(6)
//			fornecedor
//			cr
//			banco
		case nAba == 8		//fCRPago(8)
//			banco
	endcase
return

static function SelecionarAba(nAbaSelect)
	nAba := nAbaSelect
	
/*	do case
		case nAbaSelect == 2
			Alert("ra")
	endcase*/
return

/*static Function Teste(nDest030,nAtual,lProc030a,lProc030b,lProc030c,lProc030d,oLbx,oLbx1,oLbx2,oLbx3,oLbx4,oLbx5)
If nDest030 != nAtual
	// Carregar dados de Titulos em aberto
	If (nDest030 == 2 .or. nDest030 == 7)
		If !lProc030a
			lProc030a := .T.
			Processa( { |lEnd| Fc030Gera(1) } )
		EndIf
		oLbx:Refresh()
		oLbx:SetFocus()
		If nDest030 == 7
			oLbx5:Gotop()
			oLbx5:Refresh()
		Endif
	Endif
	
	// Carregar dados de Titulos Pagos
	If nDest030 == 3  
		If !lProc030b
			lProc030b := .T.
			Processa( { |lEnd| Fc030Gera(2) } )
		EndIf
		oLbx1:Refresh()
		oLbx1:SetFocus()
	Endif
	
	// Carregar dados de Faturamento
	If (nDest030 == 4 .or. nDest030 == 6) .and. !lProc030c
		lProc030c := .T.
		Processa( { |lEnd| Fc030Gera(3) } )
		oLbx2:Gotop()
		oLbx2:Refresh()
		oLbx4:Refresh()
		oLbx4:SetFocus()
	Endif
	
	// Carregar dados de Pedidos e Produtos
	If nDest030 == 5 .and. !lProc030d
		lProc030d := .T.
		Processa( { |lEnd| Fc030Gera(4) } )
		oLbx3:Refresh()
		oLbx3:SetFocus()
	Endif
Endif	
Return    */

static function GerarDBF(nProcesso)
if nProcesso == 2
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("C7_NUM")
	AAdd(aStru,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_EMISSAO")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_DATPRF")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_FORNECE")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_LOJA")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("A2_NREDUZ")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_NUMSC")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_NUMCOT")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_COND")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_USER")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_USER")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_RESIDUO")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_QUANT")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_QUJE")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_TOTAL")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	DbSeek("C7_VALIPI")
	AAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	
	cQry := "select C7_NUM, C7_EMISSAO, C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER, C7_RESIDUO, sum(C7_QUANT) as C7_QUANT, sum(C7_QUJE) as C7_QUJE, sum(C7_TOTAL) as C7_TOTAL, sum(C7_VALIPI) as C7_VALIPI "
	cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SA2")+" SA2 on (C7_FORNECE = A2_COD and C7_LOJA = A2_LOJA) "
	cQry += "where C7_CLVL = '"+CTH->CTH_CLVL+"' and (C7_EMISSAO between '"+cEmiIni+"' and '"+cEmiFin+"') and C7_RESIDUO = '' "+cFiltrar+"and SC7.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "group by C7_NUM, C7_EMISSAO, C7_DATPRF, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_NUMSC, C7_NUMCOT, C7_COND, C7_USER, C7_RESIDUO "
	cQry += "order by C7_NUM"
	cQry := ChangeQuery(cQry)
	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TEMP",.T.,.T.)
	
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		RecLock("cArq2",.T.)
			replace (cArq2)->C7_NUM with TEMP->C7_NUM
			replace (cArq2)->C7_EMISSAO with TEMP->C7_EMISSAO
			replace (cArq2)->C7_DATPRF with TEMP->C7_DATPRF
			replace (cArq2)->C7_FORNECE with TEMP->C7_FORNECE
			replace (cArq2)->C7_LOJA with TEMP->C7_LOJA
			replace (cArq2)->A2_NREDUZ with TEMP->A2_NREDUZ
			replace (cArq2)->C7_NUMSC with TEMP->C7_NUMSC
			replace (cArq2)->C7_NUMCOT with TEMP->C7_NUMCOT
			replace (cArq2)->C7_COND with TEMP->C7_COND
			replace (cArq2)->C7_RESIDUO with TEMP->C7_RESIDUO
			replace (cArq2)->C7_QUANT with TEMP->C7_QUANT
			replace (cArq2)->C7_QUJE with TEMP->C7_QUJE
			replace (cArq2)->C7_TOTAL with TEMP->C7_TOTAL
			replace (cArq2)->C7_VALIPI with TEMP->C7_VALIPI
		MsUnLock()
		
		TEMP->(DbSkip())
	enddo
endif
return