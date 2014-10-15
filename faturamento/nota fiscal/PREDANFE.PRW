/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 06/05/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Impressao PRE-DANFE                                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rptdef.ch"
#include "fwprintsetup.ch"

#define ESPLIN		2
#define IMP_SPOOL	2
#define MAXMSG		80												// Máximo de dados adicionais por página
#define MAXITEM		22												// Máximo de produtos para a primeira página
#define MAXITEMP2	49												// Máximo de produtos para a pagina 2 em diante
#define MAXITEMC	38												// Máxima de caracteres por linha de produtos/serviços
#define _MAXIMP		62												// Máximo de impostos calculados pela função FIMPOSTOS

user function PREDANFE(cMod,cPV,cNF,cSE,cCLI)
	local aArea := GetArea()
	
	private nConsTex := 0.5											// Constante para concertar o cálculo retornado pelo GetTextWidth.
	private nFolha := 1
	private nFolhas := 1
	private lExistNfe := .T.
	
	private aEmpresa := {}
	private aDestinat := {}
	private aTotais := {}
	private aTransp := {}
	private aISSQN := {}
	private aNotaF := {}
	private aItens := {}
	private aFaturas := {}
	private aTabImposto := {}
	private cMensagem := {}
	private cResFisco := {}
	private aTot := {}
	private nModImp := IIf(Empty(cNF),1,0)
	
	private oPrinter := FWMSPrinter():New(IIf(nModImp <> 1,"PREDANFE","PRENOTA"),IMP_PDF,.F.,,.T.)
	private oFont07 := TFontEx():New(oPrinter,"Times New Roman",06,06,.F.,.T.,.F.)
	private oFont07N := TFontEx():New(oPrinter,"Times New Roman",06,06,.T.,.T.,.F.)
	private oFont08 := TFontEx():New(oPrinter,"Times New Roman",07,07,.F.,.T.,.F.)
	private oFont08N := TFontEx():New(oPrinter,"Times New Roman",06,06,.T.,.T.,.F.)
	private oFont09 := TFontEx():New(oPrinter,"Times New Roman",08,08,.F.,.T.,.F.)
	private oFont09N := TFontEx():New(oPrinter,"Times New Roman",08,08,.T.,.T.,.F.)
	private oFont10 := TFontEx():New(oPrinter,"Times New Roman",09,09,.F.,.T.,.F.)
	private oFont10N := TFontEx():New(oPrinter,"Times New Roman",08,08,.T.,.T.,.F.)
	private oFont11 := TFontEx():New(oPrinter,"Times New Roman",10,10,.F.,.T.,.F.)
	private oFont11N := TFontEx():New(oPrinter,"Times New Roman",10,10,.T.,.T.,.F.)
	private oFont12 := TFontEx():New(oPrinter,"Times New Roman",11,11,.F.,.T.,.F.)
	private oFont12N := TFontEx():New(oPrinter,"Times New Roman",11,11,.T.,.T.,.F.)
	private oFont18N := TFontEx():New(oPrinter,"Times New Roman",17,17,.T.,.T.,.F.)
	private oFont19N := TFontEx():New(oPrinter,"Times New Roman",07,07,.T.,.T.,.F.)
	
	oPrinter:cPathPDF := "c:\temp\"
	
	oPrinter:SetResolution(78)										//Tamanho estipulado para a Danfe
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60)
	
	if !Empty(cNF)
		RptStatus({|| DPreDanfeNF(IIf(cMod == "S","1","0"),cNF,cSE,cCLI)},"Gravando o dados da "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+" de saida...")
	else
		RptStatus({|| DPreDanfePV(IIf(cMod == "S","1","0"),cPV,cCLI)},"Gravando o dados da "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+" de saida...")
	endif
	
	if lExistNfe
		RptStatus({|| PreDanfeProc(cMod)},"Imprimindo "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+"...")
		
		oPrinter:Preview()												//Visualiza antes de imprimir
	endif
	
	FreeObj(oPrinter)
	
	oPrinter := nil
	
	RestArea(aArea)
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GERANDO DADOS DA PRE-DANFE PELA NOTA FISCAL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function DPreDanfeNF(cModNF,cNota,cSerie,cCliFor)
	local aCampo := {}
	local aTes := {}
	local nTotServico := 0
	
	//--------------------------------------------------------------------------
	// Dados da empresa emitente
	//--------------------------------------------------------------------------
	
	DbSelectArea("SM0")
	SM0->(DbSeek(cEmpAnt+cFilAnt,.F.))
	
	AAdd(aEmpresa,AllTrim(SM0->M0_NOMECOM))															// 01 Razão Social
	AAdd(aEmpresa,AllTrim(SM0->M0_ENDCOB))															// 02 Endereço/Número
	AAdd(aEmpresa,AllTrim(SM0->M0_BAIRCOB)+" - CEP: "+Transf(SM0->M0_CEPCOB,"@R 99999-999"))		// 03 Bairro/CEP
	AAdd(aEmpresa,AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB)										// 04 Município/Estado
	AAdd(aEmpresa,"Fone: 31 "+Transf(Right(AllTrim(SM0->M0_TEL),8),"@R 9999-9999"))					// 05 Telefone
	AAdd(aEmpresa,GetSrvProfString("Startpath","")+"DANFE"+cEmpAnt+cFilAnt+".BMP")					// 06 Logomarca
	AAdd(aEmpresa,AllTrim(SM0->M0_CGC))																// 07 CNPJ
	AAdd(aEmpresa,AllTrim(SM0->M0_INSC))															// 08 Inscrição Estadual
	AAdd(aEmpresa,AllTrim(SM0->M0_INSCM))															// 09 Inscrição Municipal
	
	//--------------------------------------------------------------------------
	// Dados da nota fiscal
	//--------------------------------------------------------------------------
	
	if cModNF == "1"
		cAliasNF := "SF2"
		nIndice := 2
	else
		cAliasNF := "SF1"
		nIndice := 1
	endif
	
	aCampo := {{"F1_TIPO","F1_EMISSAO","F1_HORA","F1_SAIDA","F1_TRANSP"},;
				{"F2_TIPO","F2_EMISSAO","F2_HORA","F2_SAIDA","F2_TRANSP"}}
	
	DbSelectArea(cAliasNF)
	(cAliasNF)->(DbSeek(xFilial(cAliasNF)+cNota+cSerie+cCliFor,.F.))
	
	AAdd(aNotaF,cModNF)																// 01 Módulo (0-entrada/1-saída)
	AAdd(aNotaF,cNota)																// 02 Nota Fiscal
	AAdd(aNotaF,cSerie)																// 03 Série
	AAdd(aNotaF,cCliFor)															// 04 Cliente/Fornecedor
	AAdd(aNotaF,(cAliasNF)->&(aCampo[nIndice][1]))									// 05 Tipo
	AAdd(aNotaF,DToS((cAliasNF)->&(aCampo[nIndice][2])))							// 06 Data Emissão
	
	if Empty((cAliasNF)->&(aCampo[nIndice][4]))										// 07 Data Saída
		AAdd(aNotaF,DToS((cAliasNF)->&(aCampo[nIndice][2])))
	else
		AAdd(aNotaF,DToS((cAliasNF)->&(aCampo[nIndice][4])))
	endif
	
	AAdd(aNotaF,(cAliasNF)->&(aCampo[nIndice][3])+":00")							// 08 Hora
	AAdd(aNotaF,(cAliasNF)->&(aCampo[nIndice][5]))									// 09 Transportadora
	AAdd(aNotaF,"")																	// 10 Natureza Operação (está sendo atribuido valor na parte dos itens)
	
	//--------------------------------------------------------------------------
	// Dados do cliente/fornecedor
	//--------------------------------------------------------------------------
	
	if cModNF == "1"
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA2"
			nIndice1 := 2
		else
			cAliasCF := "SA1"
			nIndice1 := 1
		endif
	else
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA1"
			nIndice1 := 1
		else
			cAliasCF := "SA2"
			nIndice1 := 2
		endif
	endif
	
	aCampo := {{"A1_PESSOA","A1_NOME","A1_CGC","A1_END","A1_NR_END","A1_BAIRRO","A1_CEP","A1_MUN","A1_DDD","A1_TEL","A1_EST","A1_INSCR","A1_INSCRM"},;
				{"A2_TIPO","A2_NOME","A2_CGC","A2_END","A2_NR_END","A2_BAIRRO","A2_CEP","A2_MUN","A2_DDD","A2_TEL","A2_EST","A2_INSCR","A2_INSCRM"}}
	
	DbSelectArea(cAliasCF)
	(cAliasCF)->(DbSeek(xFilial(cAliasCF)+cCliFor,.F.))
	
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][1]))																// 01 Pessoa Física/Pessoa Jurídica
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][2])))														// 02 Razão Social
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][3]))																// 03 CNPJ/CPF
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][4])))														// 04 Endereço
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][6])))														// 05 Bairro
	AAdd(aDestinat,Transf((cAliasCF)->&(aCampo[nIndice1][7]),"@R 99999-999"))										// 06 CEP
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][8])))														// 07 Município
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][9]))+AllTrim((cAliasCF)->&(aCampo[nIndice1][10])))		// 08 Telefone ou Fax
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][11]))																// 09 Estado
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][12])))													// 10 Inscrição Estadual
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][13])))													// 11 Inscrição Municipal
	
	//--------------------------------------------------------------------------
	// Dados da fatura
	//--------------------------------------------------------------------------
	
	if cModNF == "1"
		cAliasFT := "SE1"
		nIndice := 2
		nIndOrd := 2
	else
		cAliasFT := "SE2"
		nIndice := 1
		nIndOrd := 6
	endif
	
	aCampo := {{"E2_NUM","E2_PREFIXO","E2_VALOR","E2_VENCTO","E2_FORNECE","E2_LOJA"},;
				{"E1_NUM","E1_PREFIXO","E1_VALOR","E1_VENCTO","E1_CLIENTE","E1_LOJA"}}
	
	DbSelectArea(cAliasFT)
	(cAliasFT)->(DbSetOrder(nIndOrd))
	
	if (cAliasFT)->(DbSeek(xFilial(cAliasFT)+aNotaF[4]+aNotaF[3]+aNotaF[2],.F.))
		while !(cAliasFT)->(Eof()) .and. (cAliasFT)->&(aCampo[nIndice][2])+(cAliasFT)->&(aCampo[nIndice][1]) == aNotaF[3]+aNotaF[2] .and. (cAliasFT)->&(aCampo[nIndice][5])+(cAliasFT)->&(aCampo[nIndice][6]) == aNotaF[4]
			AAdd(aFaturas,{(cAliasFT)->&(aCampo[nIndice][2]),;														// 01 Prefixo 
							(cAliasFT)->&(aCampo[nIndice][1]),;														// 02 Número
							U_ConvData(DToS((cAliasFT)->&(aCampo[nIndice][4]))),;									// 03 Data Vencimento
							AllTrim(Transf((cAliasFT)->&(aCampo[nIndice][3]),"@E 9,999,999,999,999.99"))})			// 04 Valor
		
			(cAliasFT)->(DbSkip())
		enddo
	endif
	
	//--------------------------------------------------------------------------
	// Dados dos impostos
	//--------------------------------------------------------------------------
	
	aCampo := {{"F1_BASEICM","F1_VALICM","F1_VALMERC","F1_FRETE","F1_SEGURO","F1_DESCONT","F1_DESPESA","F1_VALIPI","F1_VALBRUT","F1_BRICMS","F1_ICMSRET"},;
				{"F2_BASEICM","F2_VALICM","F2_VALMERC","F2_FRETE","F2_SEGURO","F2_DESCONT","F2_DESPESA","F2_VALIPI","F2_VALBRUT","F2_BRICMS","F2_ICMSRET"}}
	
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][1]),"@E 9,999,999,999,999.99"))			// 01 Base Cálculo ICMS
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][2]),"@E 9,999,999,999,999.99"))			// 02 Valor ICMS
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][10]),"@E 9,999,999,999,999.99"))			// 03 Base Cálculo ICMS ST
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][11]),"@E 9,999,999,999,999.99"))			// 04 Valor ICMS ST
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][3]),"@E 9,999,999,999,999.99"))			// 05 Valor Total Produto
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][4]),"@E 9,999,999,999,999.99"))			// 06 Valor Frete
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][5]),"@E 9,999,999,999,999.99"))			// 07 Valor Seguro
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][6]),"@E 9,999,999,999,999.99"))			// 08 Valor Desconto
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][7]),"@E 9,999,999,999,999.99"))			// 09 Outras Despesas
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][8]),"@E 9,999,999,999,999.99"))			// 10 Valor IPI
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][9]),"@E 9,999,999,999,999.99"))			// 11 Valor Total Nota
	
	//--------------------------------------------------------------------------
	// Dados da transportadora
	//--------------------------------------------------------------------------
	
	DbSelectArea("SA4")
	
	if SA4->(DbSeek(xFilial("SA4")+aNotaF[9],.F.))
		AAdd(aTransp,AllTrim(SA4->A4_NOME))															// 01 Razão Social
		
		if Len(AllTrim(SA4->A4_CGC)) == 14
			cAux := Transf(SA4->A4_CGC,"@R 99.999.999/9999-99")
		else
			cAux := Transf(SA4->A4_CGC,"@R 999.999.999-99")
		endif
		
		AAdd(aTransp,cAux)																			// 02 CNPJ/CPF
		AAdd(aTransp,AllTrim(SA4->A4_END))															// 03 Endereço
		AAdd(aTransp,AllTrim(SA4->A4_MUN))															// 04 Município
		AAdd(aTransp,SA4->A4_EST)																	// 05 UF
		AAdd(aTransp,IIf(Empty(SA4->A4_INSEST),"ISENTO",AllTrim(SA4->A4_INSEST)))					// 06 Inscrição Estadual
	else
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
	endif
	
	DbSelectArea("SC5")
	DbSetOrder(8)
	DbSeek(xFilial("SC5")+aNotaF[2]+aNotaF[3]+aNotaF[4],.F.)
	
	do case																							// 07 Frete por Conta
		case SC5->C5_TPFRETE == "C"
			AAdd(aTransp,"0")
		case SC5->C5_TPFRETE == "F"
			AAdd(aTransp,"1")
		case SC5->C5_TPFRETE == "T"
			AAdd(aTransp,"2")
		case SC5->C5_TPFRETE == "S"
			AAdd(aTransp,"9")
		otherwise
			AAdd(aTransp,"1")
	endcase
	
	AAdd(aTransp,"")						// 08 Código ANTT
	AAdd(aTransp,SC5->C5_PLACA)																		// 09 Placa do Veículo
	AAdd(aTransp,SC5->C5_UFPLACA)																	// 10 UF
	
	if !Empty(SC5->C5_VOLUME1)
		AAdd(aTransp,AllTrim(Str(Round(SC5->C5_VOLUME1,0))))										// 11 Quantidade
	else
		AAdd(aTransp,"")
	endif
	
	AAdd(aTransp,AllTrim(SC5->C5_ESPECI1))															// 12 Espécie
	AAdd(aTransp,"")						// 13 Marca
	AAdd(aTransp,"")						// 14 Numeração
	
	if !Empty(SC5->C5_PBRUTO)
		AAdd(aTransp,Transf(SC5->C5_PBRUTO,"@E 999999.999"))										// 15 Peso Bruto
	else
		AAdd(aTransp,"")
	endif
	
	if !Empty(SC5->C5_PESOL)
		AAdd(aTransp,Transf(SC5->C5_PESOL,"@E 999999.999"))											// 16 Peso Líquido
	else
		AAdd(aTransp,"")
	endif
	
	if !Empty(aTransp[1])
		if Empty(aTransp[9]) .or. Empty(aTransp[10])
			MsgAlert("Esta faltando preencher a PLACA ou a UF do veiculo.")
			
			lExistNfe := .F.
		endif
	endif
	
	//--------------------------------------------------------------------------
	// Dados do ISSQN
	//--------------------------------------------------------------------------
	
	aCampo := {{"F1_VALMERC","F1_ISS"},;
				{"F2_BASEISS","F2_VALISS"}}
	
	if !Empty((cAliasNF)->&(aCampo[nIndice][2]))
		AAdd(aISSQN,aEmpresa[09])																//01 Inscrição Municipal
		AAdd(aISSQN,"")																			//02 Valor Total Serviços (está sendo atribuido valor na parte dos itens)
		AAdd(aISSQN,Transf((cAliasNF)->&(aCampo[nIndice][1]),"@E 99,999,999,999.99"))			//03 Base Cálculo ISSQN
		AAdd(aISSQN,Transf((cAliasNF)->&(aCampo[nIndice][2]),"@E 99,999,999,999.99"))			//04 Valor ISSQN
	else
		AAdd(aISSQN,"")
		AAdd(aISSQN,"")
		AAdd(aISSQN,"")
		AAdd(aISSQN,"")
	endif
	
	//--------------------------------------------------------------------------
	// Dados do produto/servico
	//--------------------------------------------------------------------------
	
	if cModNF == "1"
		cAliasIT := "SD2"
		nIndice := 2
		nIndOrd := 3
	else
		cAliasIT := "SD1"
		nIndice := 1
		nIndOrd := 1
	endif
	
	aCampo := {{"D1_DOC","D1_SERIE","D1_FORNECE","D1_LOJA","D1_DESCPRO","D1_COD","D1_TES","D1_CF","D1_CLASFIS","D1_UM","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_BASEICM","D1_VALICM","D1_VALIPI","D1_PICM","D1_IPI","D1_VALISS"},;
				{"D2_DOC","D2_SERIE","D2_CLIENTE","D2_LOJA","C6_DESCRI","D2_COD","D2_TES","D2_CF","D2_CLASFIS","D2_UM","D2_QUANT","D2_PRCVEN","D2_TOTAL","D2_BASEICM","D2_VALICM","D2_VALIPI","D2_PICM","D2_IPI","D2_VALISS"}}
	
	DbSelectArea(cAliasIT)
	(cAliasIT)->(DbSetOrder(nIndOrd))
	(cAliasIT)->(DbSeek(xFilial(cAliasIT)+aNotaF[2]+aNotaF[3]+aNotaF[4],.F.))
	
	nItem := 0
	
	while !(cAliasIT)->(Eof()) .and. (cAliasIT)->&(aCampo[nIndice][1]) == aNotaF[2] .and. (cAliasIT)->&(aCampo[nIndice][2]) == aNotaF[3] .and. (cAliasIT)->&(aCampo[nIndice][3])+(cAliasIT)->&(aCampo[nIndice][4]) == aNotaF[4]
		if cAliasIT == "SD2"
			DbSelectArea("SC6")
			DbSetOrder(12)
			DbSeek(xFilial("SC6")+aNotaF[2]+aNotaF[3]+SD2->D2_ITEMPV,.F.)
		endif
		
		cDescri := AllTrim(&(aCampo[nIndice][5]))
		
		DbSelectArea(cAliasIT)
		
		cNcm := IIf(SB1->(DbSeek(xFilial("SB1")+(cAliasIT)->&(aCampo[nIndice][6]),.F.)),AllTrim(SB1->B1_POSIPI),"")
		cTes := (cAliasIT)->&(aCampo[nIndice][7])
		
		if (nInd := AScan(aTes,{|x| x[1] == cTes})) == 0
			AAdd(aTes,{cTes,IIf(SF4->(DbSeek(xFilial("SF4")+cTes,.F.)),AllTrim(SF4->F4_TEXTO),""),AllTrim((cAliasIT)->&(aCampo[nIndice][8]))})
			
			aNotaF[10] := AllTrim(SF4->F4_TEXTO)+"/"
		endif
		
		AAdd(aItens,{Left(&(aCampo[nIndice][6]),6),;																	// 01 Código Produto
						MemoLine(cDescri,MAXITEMC,1),;																	// 02 Descrição do Produto
						cNcm,;																							// 03 NCM
						&(aCampo[nIndice][9]),;																			// 04 CST
						&(aCampo[nIndice][8]),;																			// 05 CFOP
						&(aCampo[nIndice][10]),;																		// 06 Unidade
						AllTrim(Transf(&(aCampo[nIndice][11]),PesqPict(cAliasIT,aCampo[nIndice][11]))),;				// 07 Quantidade
						AllTrim(Transf(&(aCampo[nIndice][12]),PesqPict(cAliasIT,aCampo[nIndice][12]))),;				// 08 Valor Unitário
						AllTrim(Transf(&(aCampo[nIndice][13]),PesqPict(cAliasIT,aCampo[nIndice][13]))),;				// 09 Valor Total
						AllTrim(Transf(&(aCampo[nIndice][14]),PesqPict(cAliasIT,aCampo[nIndice][14]))),;				// 10 Base Cálculo ICMS
						AllTrim(Transf(&(aCampo[nIndice][15]),PesqPict(cAliasIT,aCampo[nIndice][15]))),;				// 11 Valor ICMS
						AllTrim(Transf(&(aCampo[nIndice][16]),PesqPict(cAliasIT,aCampo[nIndice][16]))),;				// 12 Valor IPI
						AllTrim(Transf(&(aCampo[nIndice][17]),"@E 99.99%")),;											// 13 Alíquota ICMS
						AllTrim(Transf(&(aCampo[nIndice][18]),"@E 99.99%"))})											// 14 Alíquota IPI
		
		nItem++
		
		if MLCount(cDescri,MAXITEMC) > 1
			for k := 2 to MLCount(cDescri,MAXITEMC)
				AAdd(aItens,{"",MemoLine(cDescri,MAXITEMC,k),"","","","","","","","","","","",""})
				
				nItem++
			next
		endif
		
		if !Empty((cAliasIT)->&(aCampo[nIndice][19]))
			nTotServico += (cAliasIT)->&(aCampo[nIndice][13])
		endif
		
		(cAliasIT)->(DbSkip())
	enddo
	
	if !Empty(nTotServico)
		aISSQN[2] := Transf(nTotServico,"@E 99,999,999,999.99")
	endif
	
	nItem -= MAXITEM
	lFlag := .T.
	
	while lFlag
		if nItem > 0
			nFolhas++
			
			nItem -= MAXITEMP2
		else
			lFlag := .F.
		endif
	enddo
	
	//--------------------------------------------------------------------------
	// Dados dos dados adicionais
	//--------------------------------------------------------------------------
	
	cProjetos := "Projeto(s): "+Projetos(aNotaF[2],aNotaF[3],Left(aNotaF[4],6),Right(aNotaF[4],2),cAliasNF)
	cMensagem := AllTrim(SC5->C5_MENNOTA)+" "+AllTrim(SC5->C5_MENNOT2)+" "+AllTrim(SC5->C5_MENNOT3)+Chr(13)+Chr(10)+cProjetos
	cResFisco := ""
	
	//--------------------------------------------------------------------------
	// Dados folha da tabela de impostos
	//--------------------------------------------------------------------------
	
	TabImpostos(cModNF)
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GERANDO DADOS DA PRE-DANFE PELO PEDIDO DE VENDA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function DPreDanfePV(cModNF,cPedVen,cCliFor)
	local aCampo := {}
	local aTes := {}
	local nTotNota := 0
	local nTotServico := 0
	
	//--------------------------------------------------------------------------
	// Dados da empresa emitente
	//--------------------------------------------------------------------------
	
	DbSelectArea("SM0")
	SM0->(DbSeek(cEmpAnt+cFilAnt,.F.))
	
	AAdd(aEmpresa,AllTrim(SM0->M0_NOMECOM))															// 01 Razão Social
	AAdd(aEmpresa,AllTrim(SM0->M0_ENDCOB))															// 02 Endereço/Número
	AAdd(aEmpresa,AllTrim(SM0->M0_BAIRCOB)+" - CEP: "+Transf(SM0->M0_CEPCOB,"@R 99999-999"))		// 03 Bairro/CEP
	AAdd(aEmpresa,AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB)										// 04 Município/Estado
	AAdd(aEmpresa,"Fone: 31 "+Transf(Right(AllTrim(SM0->M0_TEL),8),"@R 9999-9999"))					// 05 Telefone
	AAdd(aEmpresa,GetSrvProfString("Startpath","")+"DANFE"+cEmpAnt+cFilAnt+".BMP")					// 06 Logomarca
	AAdd(aEmpresa,AllTrim(SM0->M0_CGC))																// 07 CNPJ
	AAdd(aEmpresa,AllTrim(SM0->M0_INSC))															// 08 Inscrição Estadual
	AAdd(aEmpresa,AllTrim(SM0->M0_INSCM))															// 09 Inscrição Municipal
	
	//--------------------------------------------------------------------------
	// Dados do pedido de venda
	//--------------------------------------------------------------------------
	
	DbSelectArea("SC5")
	SC5->(DbSeek(xFilial("SC5")+cPedVen,.F.))
	
	AAdd(aNotaF,cModNF)																// 01 Módulo (0-entrada/1-saída)
	AAdd(aNotaF,cPedVen)															// 02 Nota Fiscal
	AAdd(aNotaF,"")																	// 03 Série
	AAdd(aNotaF,cCliFor)															// 04 Cliente/Fornecedor
	AAdd(aNotaF,SC5->C5_TIPO)														// 05 Tipo
	AAdd(aNotaF,DToS(SC5->C5_EMISSAO))												// 06 Data Emissão
	AAdd(aNotaF,"")																	// 07 Data Saída
	AAdd(aNotaF,"")																	// 08 Hora
	AAdd(aNotaF,SC5->C5_TRANSP)														// 09 Transportadora
	AAdd(aNotaF,"")																	// 10 Natureza Operação (está sendo atribuido valor na parte dos itens)
	AAdd(aNotaF,AllTrim(SC5->C5_TPFRETE))											// 11 Tipo do Frete
	AAdd(aNotaF,SC5->C5_PLACA)														// 12 Placa do Veículo
	AAdd(aNotaF,SC5->C5_UFPLACA)													// 13 UF
	AAdd(aNotaF,SC5->C5_VOLUME1)													// 14 Quantidade
	AAdd(aNotaF,AllTrim(SC5->C5_ESPECI1))											// 15 Espécie
	AAdd(aNotaF,SC5->C5_PBRUTO)														// 16 Peso Bruto
	AAdd(aNotaF,SC5->C5_PESOL)														// 17 Peso Líquido
	AAdd(aNotaF,AllTrim(SC5->C5_MENNOTA))											// 18 Mensagem
	AAdd(aNotaF,AllTrim(SC5->C5_MENNOT2))											// 19 Mensagem 1
	AAdd(aNotaF,AllTrim(SC5->C5_MENNOT3))											// 20 Mensagem 2
	
	//--------------------------------------------------------------------------
	// Dados do cliente/fornecedor
	//--------------------------------------------------------------------------
	
	if cModNF == "1"
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA2"
			nIndice1 := 2
		else
			cAliasCF := "SA1"
			nIndice1 := 1
		endif
	else
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA1"
			nIndice1 := 1
		else
			cAliasCF := "SA2"
			nIndice1 := 2
		endif
	endif
	
	aCampo := {{"A1_PESSOA","A1_NOME","A1_CGC","A1_END","A1_NR_END","A1_BAIRRO","A1_CEP","A1_MUN","A1_DDD","A1_TEL","A1_EST","A1_INSCR","A1_INSCRM"},;
				{"A2_TIPO","A2_NOME","A2_CGC","A2_END","A2_NR_END","A2_BAIRRO","A2_CEP","A2_MUN","A2_DDD","A2_TEL","A2_EST","A2_INSCR","A2_INSCRM"}}
	
	DbSelectArea(cAliasCF)
	(cAliasCF)->(DbSeek(xFilial(cAliasCF)+cCliFor,.F.))
	
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][1]))																// 01 Pessoa Física/Pessoa Jurídica
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][2])))														// 02 Razão Social
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][3]))																// 03 CNPJ/CPF
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][4])))														// 04 Endereço
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][6])))														// 05 Bairro
	AAdd(aDestinat,Transf((cAliasCF)->&(aCampo[nIndice1][7]),"@R 99999-999"))										// 06 CEP
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][8])))														// 07 Município
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][9]))+AllTrim((cAliasCF)->&(aCampo[nIndice1][10])))		// 08 Telefone ou Fax
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][11]))																// 09 Estado
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][12])))													// 10 Inscrição Estadual
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][13])))													// 11 Inscrição Municipal
	
	//--------------------------------------------------------------------------
	// Dados dos impostos
	//--------------------------------------------------------------------------
	
	AAdd(aTotais,"")			// 01 Base Cálculo ICMS
	AAdd(aTotais,"")			// 02 Valor ICMS
	AAdd(aTotais,"")			// 03 Base Cálculo ICMS ST
	AAdd(aTotais,"")			// 04 Valor ICMS ST
	AAdd(aTotais,"")			// 05 Valor Total Produto
	AAdd(aTotais,"")			// 06 Valor Frete
	AAdd(aTotais,"")			// 07 Valor Seguro
	AAdd(aTotais,"")			// 08 Valor Desconto
	AAdd(aTotais,"")			// 09 Outras Despesas
	AAdd(aTotais,"")			// 10 Valor IPI
	AAdd(aTotais,"")			// 11 Valor Total Nota
	
	for m := 1 to _MAXIMP
		AAdd(aTot,0)
	next
	
	//--------------------------------------------------------------------------
	// Dados da transportadora
	//--------------------------------------------------------------------------
	
	DbSelectArea("SA4")
	
	if SA4->(DbSeek(xFilial("SA4")+aNotaF[9],.F.))
		AAdd(aTransp,AllTrim(SA4->A4_NOME))															// 01 Razão Social
		
		if Len(AllTrim(SA4->A4_CGC)) == 14
			cAux := Transf(SA4->A4_CGC,"@R 99.999.999/9999-99")
		else
			cAux := Transf(SA4->A4_CGC,"@R 999.999.999-99")
		endif
		
		AAdd(aTransp,cAux)																			// 02 CNPJ/CPF
		AAdd(aTransp,AllTrim(SA4->A4_END))															// 03 Endereço
		AAdd(aTransp,AllTrim(SA4->A4_MUN))															// 04 Município
		AAdd(aTransp,SA4->A4_EST)																	// 05 UF
		AAdd(aTransp,IIf(Empty(SA4->A4_INSEST),"ISENTO",AllTrim(SA4->A4_INSEST)))					// 06 Inscrição Estadual
	else
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
	endif
	
	do case																							// 07 Frete por Conta
		case aNotaF[11] == "F"
			AAdd(aTransp,"0")
		case aNotaF[11] == "C"
			AAdd(aTransp,"1")
		case aNotaF[11] == "T"
			AAdd(aTransp,"2")
		case aNotaF[11] == "S"
			AAdd(aTransp,"9")
		otherwise
			AAdd(aTransp,"1")
	endcase
	
	AAdd(aTransp,"")						// 08 Código ANTT
	AAdd(aTransp,aNotaF[12])																		// 09 Placa do Veículo
	AAdd(aTransp,aNotaF[13])																		// 10 UF
	
	if !Empty(aNotaF[14])
		AAdd(aTransp,AllTrim(Str(Round(aNotaF[14],0))))												// 11 Quantidade
	else
		AAdd(aTransp,"")
	endif
	
	AAdd(aTransp,aNotaF[15])																		// 12 Espécie
	AAdd(aTransp,"")						// 13 Marca
	AAdd(aTransp,"")						// 14 Numeração
	
	if !Empty(aNotaF[16])
		AAdd(aTransp,Transf(aNotaF[16],"@E 999999.999"))											// 15 Peso Bruto
	else
		AAdd(aTransp,"")
	endif
	
	if !Empty(aNotaF[17])
		AAdd(aTransp,Transf(aNotaF[17],"@E 999999.999"))											// 16 Peso Líquido
	else
		AAdd(aTransp,"")
	endif
	
	if !Empty(aTransp[1])
		if Empty(aTransp[9]) .or. Empty(aTransp[10])
			MsgAlert("Esta faltando preencher a PLACA ou a UF do veiculo.")
			
			lExistNfe := .F.
		endif
	endif
	
	//--------------------------------------------------------------------------
	// Dados do ISSQN
	//--------------------------------------------------------------------------
	
	AAdd(aISSQN,"")																//01 Inscrição Municipal
	AAdd(aISSQN,"")																//02 Valor Total Serviços
	AAdd(aISSQN,"")																//03 Base Cálculo ISSQN
	AAdd(aISSQN,"")																//04 Valor ISSQN
	
	//--------------------------------------------------------------------------
	// Dados do produto/servico
	//--------------------------------------------------------------------------
	
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6")+aNotaF[2],.F.))
	
	nItem := 0
	
	while !SC6->(Eof()) .and. SC6->C6_NUM == aNotaF[2]
		cDescri := AllTrim(SC6->C6_DESCRI)
		cNcm := IIf(SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.)),AllTrim(SB1->B1_POSIPI),"")
		cTes := SC6->C6_TES
		
		if (nInd := AScan(aTes,{|x| x[1] == cTes})) == 0
			AAdd(aTes,{cTes,IIf(SF4->(DbSeek(xFilial("SF4")+cTes,.F.)),AllTrim(SF4->F4_TEXTO),""),AllTrim(SC6->C6_CF)})
			
			aNotaF[10] := AllTrim(SF4->F4_TEXTO)+"/"
		endif
		
		aImpostos := U_FIMPOSTOS(Left(aNotaF[4],6),Right(aNotaF[4],2),aNotaF[5],SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR)
		nTotIpi := 0
		
		SF4->(DbGoTop())
		
		if SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
			if SF4->F4_INCIDE == "S"
				nTotIpi := aImpostos[10]
			endif
		endif
		
		AAdd(aItens,{Left(SC6->C6_PRODUTO,6),;																			// 01 Código Produto
						MemoLine(cDescri,MAXITEMC,1),;																	// 02 Descrição do Produto
						cNcm,;																							// 03 NCM
						SC6->C6_CLASFIS,;																				// 04 CST
						SC6->C6_CF,;																					// 05 CFOP
						SC6->C6_UM,;																					// 06 Unidade
						AllTrim(Transf(SC6->C6_QTDVEN,PesqPict("SD2","D2_QUANT"))),;									// 07 Quantidade
						AllTrim(Transf(SC6->C6_PRCVEN,PesqPict("SD2","D2_PRCVEN"))),;									// 08 Valor Unitário
						AllTrim(Transf(SC6->C6_VALOR,PesqPict("SD2","D2_TOTAL"))),;										// 09 Valor Total
						AllTrim(Transf(aImpostos[4],PesqPict("SD2","D2_BASEICM"))),;									// 10 Base Cálculo ICMS
						AllTrim(Transf(aImpostos[6],PesqPict("SD2","D2_VALICM"))),;										// 11 Valor ICMS
						AllTrim(Transf(aImpostos[10],PesqPict("SD2","D2_VALIPI"))),;									// 12 Valor IPI
						AllTrim(Transf(aImpostos[5],"@E 99.99%")),;														// 13 Alíquota ICMS
						AllTrim(Transf(aImpostos[9],"@E 99.99%"))})														// 14 Alíquota IPI
		
		nItem++
		
		if MLCount(cDescri,MAXITEMC) > 1
			for k := 2 to MLCount(cDescri,MAXITEMC)
				AAdd(aItens,{"",MemoLine(cDescri,MAXITEMC,k),"","","","","","","","","","","",""})
				
				nItem++
			next
		endif
		
		aTot[1] := aImpostos[1]
		aTot[2] := aImpostos[2]
		
		for m := 3 to _MAXIMP
			if !(StrZero(m,2) $ "03/07/11/15/19/23/27/31/35/39/43/47/51")
				aTot[m] += aImpostos[m]
			endif
		next
		
		for m := 3 to _MAXIMP step 4
			if m <= 51
				if aImpostos[m + 3] > 0
					cAlqImposto := Transf(aImpostos[m + 2],"@E 99.99")+"%"
					
					if (nInd := AScan(aTabImposto,{|x| x[1] = aImpostos[m] .and. x[2] = cAlqImposto})) == 0
						AAdd(aTabImposto,{aImpostos[m],cAlqImposto,Transf(aImpostos[m + 1],"@E 999,999,999,999.99"),Transf(aImpostos[m + 3],"@E 999,999,999,999.99"),aImpostos[m + 3],aImpostos[m + 1]})
					else
						aTabImposto[nInd][5] += aImpostos[m + 3]
						aTabImposto[nInd][6] += aImpostos[m + 1]
						aTabImposto[nInd][3] := Transf(aTabImposto[nInd][6],"@E 999,999,999,999.99")
						aTabImposto[nInd][4] := Transf(aTabImposto[nInd][5],"@E 999,999,999,999.99")
					endif
				endif
			endif
		next
		
		nTotNota += (SC6->C6_VALOR + nTotIpi)
		
		if !Empty(aImpostos[22])
			nTotServico += SC6->C6_VALOR
		endif
		
		aImpostos := {}
		
		SC6->(DbSkip())
	enddo
	
	aTotais[1] := Transf(aTot[4],"@E 9,999,999,999,999.99")							// 01 Base Cálculo ICMS
	aTotais[2] := Transf(aTot[6],"@E 9,999,999,999,999.99")							// 02 Valor ICMS
	aTotais[3] := Transf(aTot[55],"@E 9,999,999,999,999.99")						// 03 Base Cálculo ICMS ST
	aTotais[4] := Transf(aTot[57],"@E 9,999,999,999,999.99")						// 04 Valor ICMS ST
	aTotais[5] := Transf(aTot[62],"@E 9,999,999,999,999.99")						// 05 Valor Total Produto
	aTotais[6] := Transf(aTot[59],"@E 9,999,999,999,999.99")						// 06 Valor Frete
	aTotais[7] := Transf(aTot[60],"@E 9,999,999,999,999.99")						// 07 Valor Seguro
	aTotais[8] := Transf(aTot[58],"@E 9,999,999,999,999.99")						// 08 Valor Desconto
	aTotais[9] := Transf(aTot[61],"@E 9,999,999,999,999.99")						// 09 Outras Despesas
	aTotais[10] := Transf(aTot[10],"@E 9,999,999,999,999.99")						// 10 Valor IPI
	aTotais[11] := Transf(nTotNota,"@E 9,999,999,999,999.99")						// 11 Valor Total Nota
	
	if !Empty(aTot[22])
		aISSQN[1] := aEmpresa[09]													//01 Inscrição Municipal
		aISSQN[2] := Transf(nTotServico,"@E 99,999,999,999.99")						//02 Valor Total Serviços
		aISSQN[3] := Transf(aTot[20],"@E 99,999,999,999.99")						//03 Base Cálculo ISSQN
		aISSQN[4] := Transf(aTot[22],"@E 99,999,999,999.99")						//04 Valor ISSQN
	endif
	
	nItem -= MAXITEM
	lFlag := .T.
	
	while lFlag
		if nItem > 0
			nFolhas++
			
			nItem -= MAXITEMP2
		else
			lFlag := .F.
		endif
	enddo
	
	//--------------------------------------------------------------------------
	// Dados dos dados adicionais
	//--------------------------------------------------------------------------
	
	cProjetos := "Projeto(s): "+Projetos(aNotaF[2],"",Left(aNotaF[4],6),Right(aNotaF[4],2),"SC6")
	cMensagem := aNotaF[18]+" "+aNotaF[19]+" "+aNotaF[20]+Chr(13)+Chr(10)+cProjetos
	cResFisco := ""
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRESSAO DA PRE-DANFE                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function PreDanfeProc(cModNF)
	local lConverte := GetNewPar("MV_CONVERT",.F.)
	
	private nLinCalc := 0
	private nFolImp := IIf(!Empty(aTabImpostos),1,0)
	
	oPrinter:StartPage()
	Cabecalho(42,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DESTINATARIO/REMETENTE                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
	oPrinter:Line(197,000,197,500,ESPLIN)
	oPrinter:Line(197,000,257,000,ESPLIN)
	oPrinter:Line(197,500,257,500,ESPLIN)
	oPrinter:Line(257,000,257,500,ESPLIN)
	oPrinter:Say(205,002,"NOME/RAZÃO SOCIAL",oFont08N:oFont)
	oPrinter:Say(215,002,aDestinat[2],oFont08:oFont)
	oPrinter:Line(197,280,217,280,ESPLIN)
	
	do case
		case aDestinat[1] == "J"
			cAux := Transf(aDestinat[3],"@R 99.999.999/9999-99")
		case aDestinat[1] == "F"
			cAux := Transf(aDestinat[3],"@R 999.999.999-99")
		otherwise
			cAux := Space(14)
	endcase
	
	oPrinter:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
	oPrinter:Say(215,283,cAux,oFont08:oFont)
	oPrinter:Line(217,000,217,500,ESPLIN)
	oPrinter:Say(224,002,"ENDEREÇO",oFont08N:oFont)
	oPrinter:Say(234,002,aDestinat[4],oFont08:oFont)
	oPrinter:Line(217,230,237,230,ESPLIN)
	oPrinter:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
	oPrinter:Say(234,232,aDestinat[5],oFont08:oFont)
	oPrinter:Line(217,380,237,380,ESPLIN)
	oPrinter:Say(224,382,"CEP",oFont08N:oFont)
	oPrinter:Say(234,382,aDestinat[6],oFont08:oFont)
	oPrinter:Line(237,000,237,500,ESPLIN)
	oPrinter:Say(245,002,"MUNICIPIO",oFont08N:oFont)
	oPrinter:Say(255,002,aDestinat[7],oFont08:oFont)
	oPrinter:Line(237,150,257,150,ESPLIN)
	oPrinter:Say(245,152,"FONE/FAX",oFont08N:oFont)
	oPrinter:Say(255,152,aDestinat[8],oFont08:oFont)
	oPrinter:Line(237,255,257,255,ESPLIN)
	oPrinter:Say(245,257,"UF",oFont08N:oFont)
	oPrinter:Say(255,257,aDestinat[9],oFont08:oFont)
	oPrinter:Line(237,340,257,340,ESPLIN)
	oPrinter:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oPrinter:Say(255,342,aDestinat[10],oFont08:oFont)
	
	oPrinter:Line(197,502,197,603,ESPLIN)
	oPrinter:Line(197,502,257,502,ESPLIN)
	oPrinter:Line(197,603,257,603,ESPLIN)
	oPrinter:Line(257,502,257,603,ESPLIN)
	oPrinter:Say(205,504,"DATA DE EMISSÃO",oFont08N:oFont)
	oPrinter:Say(215,504,U_ConvData(aNotaF[6]),oFont08:oFont)
	oPrinter:Line(217,502,217,603,ESPLIN)
	oPrinter:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
	oPrinter:Say(233,504,U_ConvData(aNotaF[7]),oFont08:oFont)
	oPrinter:Line(237,502,237,603,ESPLIN)
	oPrinter:Say(245,505,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
	oPrinter:Say(255,505,aNotaF[8],oFont08:oFont)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ FATURA                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:Say(263,002,"FATURA",oFont08N:oFont)
	oPrinter:Line(265,000,265,603,ESPLIN)
	oPrinter:Line(265,000,296,000,ESPLIN)
	
	nCol := 067
	
	for i := 1 to 8
		oPrinter:Line(265,nCol,296,nCol,ESPLIN)
		
		nCol += 67
	next i
	
	oPrinter:Line(265,603,296,603,ESPLIN)
	oPrinter:Line(296,000,296,603,ESPLIN)
	
	nColuna := 002
	
	if Len(aFaturas) > 0
		for n := 1 to Len(aFaturas)
			oPrinter:Say(273,nColuna,aFaturas[n][1]+" "+aFaturas[n][2],oFont08:oFont)
			oPrinter:Say(281,nColuna,aFaturas[n][3],oFont08:oFont)
			oPrinter:Say(289,nColuna,aFaturas[n][4],oFont08:oFont)
			
			nColuna += 67
		next n
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CALCULO DO IMPOSTO                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
	oPrinter:Line(307,000,307,603,ESPLIN)
	oPrinter:Line(307,000,353,000,ESPLIN)
	oPrinter:Line(307,603,353,603,ESPLIN)
	oPrinter:Line(353,000,353,603,ESPLIN)
	oPrinter:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
	oPrinter:Say(326,002,aTotais[1],oFont08:oFont)
	oPrinter:Line(307,120,330,120,ESPLIN)
	oPrinter:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
	oPrinter:Say(326,125,aTotais[2],oFont08:oFont)
	oPrinter:Line(307,199,330,199,ESPLIN)
	oPrinter:Say(316,201,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oPrinter:Say(326,202,aTotais[3],oFont08:oFont)
	oPrinter:Line(307,360,330,360,ESPLIN)
	oPrinter:Say(316,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oPrinter:Say(326,363,aTotais[4],oFont08:oFont)
	oPrinter:Line(307,490,330,490,ESPLIN)
	oPrinter:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
	oPrinter:Say(327,491,aTotais[5],oFont08:oFont)
	oPrinter:Line(330,000,330,603,ESPLIN)
	oPrinter:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
	oPrinter:Say(349,002,aTotais[6],oFont08:oFont)
	oPrinter:Line(330,100,353,100,ESPLIN)
	oPrinter:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
	oPrinter:Say(349,102,aTotais[7],oFont08:oFont)
	oPrinter:Line(330,190,353,190,ESPLIN)
	oPrinter:Say(339,194,"DESCONTO",oFont08N:oFont)
	oPrinter:Say(349,194,aTotais[8],oFont08:oFont)
	oPrinter:Line(330,290,353,290,ESPLIN)
	oPrinter:Say(339,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
	oPrinter:Say(349,295,aTotais[9],oFont08:oFont)
	oPrinter:Line(330,414,353,414,ESPLIN)
	oPrinter:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
	oPrinter:Say(349,420,aTotais[10],oFont08:oFont)
	oPrinter:Line(330,500,353,500,ESPLIN)
	oPrinter:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
	oPrinter:Say(349,506,aTotais[11],oFont08:oFont)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TRANSPORTADOR/VOLUMES TRANSPORTADOS                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
	oPrinter:Line(363,000,363,603,ESPLIN)
	oPrinter:Line(363,000,432,000,ESPLIN)
	oPrinter:Line(363,603,432,603,ESPLIN)
	oPrinter:Line(432,000,432,603,ESPLIN)
	oPrinter:Say(372,002,"RAZÃO SOCIAL",oFont08N:oFont)
	oPrinter:Say(382,002,aTransp[1],oFont08:oFont)
	oPrinter:Line(363,245,385,245,ESPLIN)
	oPrinter:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)
	
	if aTransp[7] == "0"
		oPrinter:Say(382,247,"0-EMITENTE",oFont08:oFont)
	elseif aTransp[7] == "1"
		oPrinter:Say(382,247,"1-DESTINATARIO",oFont08:oFont)
	elseif aTransp[7] == "2"
		oPrinter:Say(382,247,"2-TERCEIROS",oFont08:oFont)
	elseif aTransp[7] == "9"
		oPrinter:Say(382,247,"9-SEM FRETE",oFont08:oFont)
	else
		oPrinter:Say(382,247,"",oFont08:oFont)
	endif
	
	oPrinter:Line(363,315,385,315,ESPLIN)
	oPrinter:Say(372,317,"CÓDIGO ANTT",oFont08N:oFont)
	oPrinter:Say(382,319,aTransp[8],oFont08:oFont)
	oPrinter:Line(363,370,385,370,ESPLIN)
	oPrinter:Say(372,375,"PLACA DO VEÍCULO",oFont08N:oFont)
	oPrinter:Say(382,375,aTransp[9],oFont08:oFont)
	oPrinter:Line(363,450,385,450,ESPLIN)
	oPrinter:Say(372,452,"UF",oFont08N:oFont)
	oPrinter:Say(382,452,aTransp[10],oFont08:oFont)
	oPrinter:Line(363,510,385,510,ESPLIN)
	oPrinter:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
	oPrinter:Say(382,512,aTransp[2],oFont08:oFont)
	oPrinter:Line(385,000,385,603,ESPLIN)
	oPrinter:Say(393,002,"ENDEREÇO",oFont08N:oFont)
	oPrinter:Say(404,002,aTransp[3],oFont08:oFont)
	oPrinter:Line(385,240,408,240,ESPLIN)
	oPrinter:Say(393,242,"MUNICIPIO",oFont08N:oFont)
	oPrinter:Say(404,242,aTransp[4],oFont08:oFont)
	oPrinter:Line(385,340,408,340,ESPLIN)
	oPrinter:Say(393,342,"UF",oFont08N:oFont)
	oPrinter:Say(404,342,aTransp[5],oFont08:oFont)
	oPrinter:Line(385,440,408,440,ESPLIN)
	oPrinter:Say(393,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oPrinter:Say(404,442,aTransp[6],oFont08:oFont)
	oPrinter:Line(408,000,408,603,ESPLIN)
	oPrinter:Say(418,002,"QUANTIDADE",oFont08N:oFont)
	oPrinter:Say(428,002,aTransp[11],oFont08:oFont)
	oPrinter:Line(408,100,432,100,ESPLIN)
	oPrinter:Say(418,102,"ESPECIE",oFont08N:oFont)
	oPrinter:Say(428,102,aTransp[12],oFont08:oFont)
	oPrinter:Line(408,200,432,200,ESPLIN)
	oPrinter:Say(418,202,"MARCA",oFont08N:oFont)
	oPrinter:Say(428,202,aTransp[13],oFont08:oFont)
	oPrinter:Line(408,300,432,300,ESPLIN)
	oPrinter:Say(418,302,"NUMERAÇÃO",oFont08N:oFont)
	oPrinter:Say(428,302,aTransp[14],oFont08:oFont)
	oPrinter:Line(408,400,432,400,ESPLIN)
	oPrinter:Say(418,402,"PESO BRUTO",oFont08N:oFont)
	oPrinter:Say(428,402,aTransp[15],oFont08:oFont)
	oPrinter:Line(408,500,432,500,ESPLIN)
	oPrinter:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
	oPrinter:Say(428,502,aTransp[16],oFont08:oFont)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DADOS DO PRODUTO/SERVICO                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
	oPrinter:Line(442,000,442,603,ESPLIN)
	oPrinter:Line(442,000,678,000,ESPLIN)
	oPrinter:Line(442,603,678,603,ESPLIN)
	oPrinter:Line(678,000,678,603,ESPLIN)
	
	aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
	nY := 0
	nLenItens := Len(aItens)
	
	for nX := 1 to nLenItens
		AAdd(ATail(aAux)[01],aItens[nX][01])
		AAdd(ATail(aAux)[02],NoChar(aItens[nX][02],lConverte))
		AAdd(ATail(aAux)[03],aItens[nX][03])
		AAdd(ATail(aAux)[04],aItens[nX][04])
		AAdd(ATail(aAux)[05],aItens[nX][05])
		AAdd(ATail(aAux)[06],aItens[nX][06])
		AAdd(ATail(aAux)[07],aItens[nX][07])
		AAdd(ATail(aAux)[08],aItens[nX][08])
		AAdd(ATail(aAux)[09],aItens[nX][09])
		AAdd(ATail(aAux)[10],aItens[nX][10])
		AAdd(ATail(aAux)[11],aItens[nX][11])
		AAdd(ATail(aAux)[12],aItens[nX][12])
		AAdd(ATail(aAux)[13],aItens[nX][13])
		AAdd(ATail(aAux)[14],aItens[nX][14])
	next nX
	
	for nK := 1 to nLenItens
		AAdd(ATail(aAux)[01],"")
		AAdd(ATail(aAux)[02],"")
		AAdd(ATail(aAux)[03],"")
		AAdd(ATail(aAux)[04],"")
		AAdd(ATail(aAux)[05],"")
		AAdd(ATail(aAux)[06],"")
		AAdd(ATail(aAux)[07],"")
		AAdd(ATail(aAux)[08],"")
		AAdd(ATail(aAux)[09],"")
		AAdd(ATail(aAux)[10],"")
		AAdd(ATail(aAux)[11],"")
		AAdd(ATail(aAux)[12],"")
		AAdd(ATail(aAux)[13],"")
		AAdd(ATail(aAux)[14],"")
	next nK
	
	aAuxCabec := {"COD. PROD","DESCRIÇÃO DO PROD./SERV.","NCM/SH","CST","CFOP","UN","QUANT.","V.UNITARIO","V.TOTAL","BC.ICMS","V.ICMS","V.IPI","A.ICMS","A.IPI"}
	aTamCol := RetTamCol(aAuxCabec,aAux,oPrinter,oFont08:oFont,oFont08N:oFont)
	
	nAuxH := 0
	
	for nK := 1 to Len(aAuxCabec)
		oPrinter:Line(442,nAuxH,678,nAuxH,2)
		oPrinter:Say(450,nAuxH + 2,aAuxCabec[nK],oFont08N:oFont)
		
		nAuxH += aTamCol[nK]
	next nK
	
	nLinha := 460
	nK := 1
	
	while nK <= Len(aItens) .and. nK <= MAXITEM
		nAuxH := 0
		
		for nJ := 1 to 14
			oPrinter:Say(nLinha,nAuxH + 2,aItens[nK][nJ],oFont08:oFont)
			
			nAuxH += aTamCol[nJ]
		next nJ
		
		nLinha += 10
		nK++
	enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CALCULO DO ISSQN                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
	oPrinter:Line(688,000,688,603,ESPLIN)
	oPrinter:Line(688,000,711,000,ESPLIN)
	oPrinter:Line(688,603,711,603,ESPLIN)
	oPrinter:Line(711,000,711,603,ESPLIN)
	oPrinter:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
	oPrinter:Say(706,002,aISSQN[1],oFont08:oFont)
	oPrinter:Line(688,150,711,150,ESPLIN)
	oPrinter:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
	oPrinter:Say(706,152,aISSQN[2],oFont08:oFont)
	oPrinter:Line(688,300,711,300,ESPLIN)
	oPrinter:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
	oPrinter:Say(706,302,aISSQN[3],oFont08:oFont)
	oPrinter:Line(688,450,711,450,ESPLIN)
	oPrinter:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
	oPrinter:Say(706,452,aISSQN[4],oFont08:oFont)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DADOS ADICIONAIS                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oPrinter:Line(721,000,721,603,ESPLIN)
	oPrinter:Line(721,000,865,000,ESPLIN)
	oPrinter:Line(721,603,865,603,ESPLIN)
	oPrinter:Line(865,000,865,603,ESPLIN)
	oPrinter:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
	
	nLin := 741
	
	oPrinter:Say(nLin,002,MemoLine(cMensagem,MAXMSG,1),oFont08:oFont)
	
	nLin := nLin + 10
	
	if MLCount(cMensagem,MAXMSG) > 1
		for k := 2 to MLCount(cMensagem,MAXMSG)
			oPrinter:Say(nLin,002,MemoLine(cMensagem,MAXMSG,k),oFont08:oFont)
			
			nLin := nLin + 10
		next
	endif
	
	oPrinter:Line(721,350,865,350,ESPLIN)
	oPrinter:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)
	
	nLin := 741
	
	oPrinter:Say(nLin,351,MemoLine(cResFisco,MAXMSG,1),oFont08:oFont)
	
	nLin := nLin + 10
	
	if MLCount(cResFisco,MAXMSG) > 1
		for k := 2 to MLCount(cResFisco,MAXMSG)
			oPrinter:Say(nLin,351,MemoLine(cResFisco,MAXMSG,k),oFont08:oFont)
			
			nLin := nLin + 10
		next
	endif
	
	oPrinter:EndPage()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//--------------------------------------------------------------------------
	//³ IMPRESSAO DA SEGUNDA PAGINA EM DIANTE                                  ³
	//--------------------------------------------------------------------------
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nFolha := 2
	nItens := MAXITEM + 1
	
	while nFolha <= nFolhas
		oPrinter:StartPage()
		Cabecalho(0,.F.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ DADOS DO PRODUTO/SERVICO                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oPrinter:Say(161,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
		oPrinter:Line(163,000,163,603,ESPLIN)
		oPrinter:Line(163,000,865,000,ESPLIN)
		oPrinter:Line(163,603,865,603,ESPLIN)
		oPrinter:Line(865,000,865,603,ESPLIN)
		
		nAuxH := 0
		
		for nK := 1 to Len(aAuxCabec)
//			oPrinter:Box(163,nAuxH,865,nAuxH + aTamCol[nK])
			oPrinter:Line(163,nAuxH,865,nAuxH,2)
			oPrinter:Say(171,nAuxH + 2,aAuxCabec[nK],oFont08N:oFont)
			
			nAuxH += aTamCol[nK]
		next nK
		
		nLinha := 181
		
		while nItens <= Len(aItens) .and. nItens <= MAXITEMP2
			nAuxH := 0
			
			for nJ := 1 to 14
				oPrinter:Say(nLinha,nAuxH + 2,aItens[nItens][nJ],oFont08:oFont)
				
				nAuxH += aTamCol[nJ]
			next nJ
			
			nLinha += 10
			nItens++
		enddo
		
		nFolha++
		
		oPrinter:EndPage()
	enddo
	
	ASort(aTabImposto,,,{|x,y| x[1] < y[1]})
	
	if Len(aTabImposto) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//--------------------------------------------------------------------------
		//³ IMPRESSAO DA TABELA DE IMPOSTOS                                        ³
		//--------------------------------------------------------------------------
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oPrinter:StartPage()
		Cabecalho(0,.F.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ DADOS DA TABELA DE IMPOSTO                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oPrinter:Say(161,002,"TABELA DE IMPOSTOS",oFont08N:oFont)
		oPrinter:Line(163,000,163,603,ESPLIN)
		oPrinter:Line(163,000,865,000,ESPLIN)
		oPrinter:Line(163,603,865,603,ESPLIN)
		oPrinter:Line(865,000,865,603,ESPLIN)
		oPrinter:Say(171,002,"IMPOSTO",oFont08N:oFont)
		oPrinter:Say(171,160,"ALIQUOTA",oFont08N:oFont)
		oPrinter:Say(171,270,"BASE CALCULO",oFont08N:oFont)
		oPrinter:Say(171,380,"VALOR IMPOSTO",oFont08N:oFont)
		
		nLinha := 181
		nTotal := 0
		
		for nI := 1 to Len(aTabImposto)
			oPrinter:Say(nLinha,002,aTabImposto[nI][1],oFont08:oFont)
			oPrinter:Say(nLinha,025,U_MPREDANF(Left(aTabImposto[nI][1],3)),oFont08:oFont)
			oPrinter:Say(nLinha,160,AllTrim(aTabImposto[nI][2]),oFont08:oFont)
			oPrinter:Say(nLinha,270,AllTrim(aTabImposto[nI][3]),oFont08:oFont)
			oPrinter:Say(nLinha,380,AllTrim(aTabImposto[nI][4]),oFont08:oFont)
			
			nTotal += aTabImposto[nI][5]
			nLinha += 10
		next nI
		
		oPrinter:Line(nLinha,370,nLinha,450,2)
		oPrinter:Say(nLinha + 10,380,AllTrim(Transf(nTotal,"@E 999,999,999,999.99")),oFont19N:oFont)
	endif
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RETORNA OS PROJETOS UTILIZADO                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function Projetos(cNota,cSerie,cCliFor,cLoja,cTab)
	local cQry := ""
	local cProj := ""
	local cCampo := ""
	
	do case
		case cTab == "SF2"
			cQry := "select distinct C6_CLVL from "+RetSqlName("SC6")+" where C6_NOTA = '"+cNota+"' and C6_SERIE = '"+cSerie+"' and C6_CLI = '"+cCliFor+"' and C6_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*'"
			cCampo := "C6_CLVL"
		case cTab == "SF1"
			cQry := "select distinct D1_CLVL from "+RetSqlName("SD1")+" where D1_DOC = '"+cNota+"' and D1_SERIE = '"+cSerie+"' and D1_FORNECE = '"+cCliFor+"' and D1_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*'"
			cCampo := "D1_CLVL"
		case cTab == "SC6"
			cQry := "select distinct C6_CLVL from "+RetSqlName("SC6")+" where C6_NUM = '"+cNota+"' and D_E_L_E_T_ <> '*'"
			cCampo := "C6_CLVL"
	endcase
	
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RETORNA OS IMPOSTOS UTILIZADO                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function TabImpostos(cModNF)
	if cModNF == "1"
		cCondicao := "and CD2_CODCLI = '"+Left(aNotaF[4],6)+"' and CD2_LOJCLI = '"+Right(aNotaF[4],2)+"' "
	else
		cCondicao := "and CD2_CODFOR = '"+Left(aNotaF[4],6)+"' and CD2_LOJFOR = '"+Right(aNotaF[4],2)+"' "
	endif
	
	if Select("QRY") <> 0
		QRY->(DbCloseArea())
	endif
	
	cQry := "select CD2_IMP, CD2_ALIQ, sum(CD2_BC) as CD2_BC, sum(CD2_VLTRIB) as CD2_VLTRIB "
	cQry += "from "+RetSqlName("CD2")+" "
	cQry += "where CD2_TPMOV = '"+IIf(cModNF == "1","S","E")+"' and CD2_DOC = '"+aNotaF[2]+"' and CD2_SERIE = '"+aNotaF[3]+"' "+cCondicao+"and D_E_L_E_T_ <> '*' "
	cQry += "group by CD2_IMP, CD2_ALIQ "
	cQry += "order by CD2_IMP, CD2_ALIQ"
	
	tcquery cQry new alias "QRY"
	
	DbSelectArea("QRY")
	QRY->(DbGoTop())
	
	while !QRY->(Eof())
		AAdd(aTabImposto,{QRY->CD2_IMP,Transf(QRY->CD2_ALIQ,"@E 99.99")+"%",Transf(QRY->CD2_BC,"@E 999,999,999,999.99"),Transf(QRY->CD2_VLTRIB,"@E 999,999,999,999.99"),QRY->CD2_VLTRIB,QRY->CD2_BC})
		
		QRY->(DbSkip())
	enddo
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONVERTER CARACTERES ESPECIAIS                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function NoChar(cString,lConverte)
	default lConverte := .F.
	
	if lConverte
		cString := (StrTran(cString,"&lt;","<"))
		cString := (StrTran(cString,"&gt;",">"))
		cString := (StrTran(cString,"&amp;","&"))
		cString := (StrTran(cString,"&quot;",'"'))
		cString := (StrTran(cString,"&#39;","'"))
	endif
return cString

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ QUEBRAR TEXTO EM LINHAS                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function QbraTexto(cStrAux,nTam,oFont)
	nForTo := Len(cStrAux) / nTam
	nForTo += IIf(nForTo > Round(nForTo,0),Round(nForTo,0) + 1 - nForTo,nForTo)
	
	for nX := 1 to nForTo
		oPrinter:Say(nLinCalc,098,SubStr(cStrAux,IIf(nX == 1,1,((nX - 1) * nTam) + 1),nTam),oFont)
		
		nLinCalc += 10
	next nX
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CALCULA TAMANHO DE CADA COLUNA DOS ITENS                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function RetTamCol(aCabec,aValores,oPrinter,oFontCabec,oFont)
	local aTamCol := {}
	local nAux := 0
	local nX := 0
	local nY := 0
	local oFontSize := FWFontSize():New()
	
	for nX := 1 to Len(aCabec)
		AAdd(aTamCol,{})
		
		aTamCol[nX] := oFontSize:GetTextWidth(AllTrim(aCabec[nX]),oFontCabec:Name,oFontCabec:nWidth,oFontCabec:Bold,oFontCabec:Italic)
	next nX
	
	for nX := 1 to Len(aValores[1])
		nAux := 0
		
		for nY := 1 to Len(aValores[1][nX])
			if (oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex) > nAux
				nAux := oFontSize:GetTextWidth(AllTrim(aValores[1][nX][nY]),oFontCabec:Name,oFontCabec:nWidth,oFontCabec:Bold,oFontCabec:Italic)
			endif
		next nY
		
		if aTamCol[nX] < nAux
			aTamCol[nX] := nAux
		endif
	next nX
	
	// Checa se os campos completam a página, senão joga o resto na coluna da
	// descrição de produtos/serviços
	nAux := 0
	
	for nX := 1 to Len(aTamCol)
		nAux += aTamCol[nX]
	next nX
	
	if nAux < 603
		aTamCol[2] += 603 - nAux
	endif
	                       
	if nAux > 603
		aTamCol[2] -= nAux - 603
	endif
return aTamCol

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRIMIR CABECALHO                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function Cabecalho(nLinha,lPrincipal)
	oPrinter:SayBitmap(150,030,GetSrvProfString("Startpath","")+IIf(nModImp <> 1,"mdpredanfe.bmp","mdprenota.bmp"),495,496)			//mdagua.bmp
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CABECALHO DA PRE-DANFE                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if lPrincipal
		oPrinter:Line(000,000,000,603,ESPLIN)
		oPrinter:Line(000,000,037,000,ESPLIN)
		oPrinter:Line(000,603,037,603,ESPLIN)
		oPrinter:Line(037,000,037,603,ESPLIN)
		oPrinter:Say(008,003,"A "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+" É UM DOCUMENTO NÃO FISCAL, COM O INTUITO DE FACILITAR A VISUALIZAÇÃO DA DANFE ANTES QUE A MESMA SEJA TRANSMITIDA, EVITANDO ASSIM",oFont07:oFont)
		oPrinter:Say(017,003,"O SEU CANCELAMENTO. MESMO COM ESSA PRATICIDADE, É DE EXTREMA IMPORTÂNCIA A VERIFICAÇÃO DA DANFE ORIGINAL IMPRESSA.",oFont07:oFont)
		oPrinter:Line(000,500,037,500,ESPLIN)
		
		if nModImp <> 1
			oPrinter:Say(007,542,"NF-e",oFont08N:oFont)
		else
			oPrinter:Say(007,538,"Pre-Nota",oFont08N:oFont)
		endif
		
		oPrinter:Say(017,510,"N. "+aNotaF[2],oFont08:oFont)
		
		if nModImp <> 1
			oPrinter:Say(027,510,"SÉRIE "+IIf(AllTrim(aNotaF[3]) == "U","0",aNotaF[3]),oFont08:oFont)
		endif
	endif
	
//	oPrinter:SayBitmap(nLinha,000,aEmpresa[6],095,096)
	oPrinter:Line(nLinha,000,nLinha,603,ESPLIN)
	oPrinter:Line(nLinha,000,nLinha + 95,000,ESPLIN)
	oPrinter:Line(nLinha,603,nLinha + 95,603,ESPLIN)
	oPrinter:Line(nLinha + 95,000,nLinha + 95,603,ESPLIN)
	oPrinter:SayBitmap(nLinha,000,aEmpresa[6],095,096)
	oPrinter:Say(nLinha + 10,098,"Identificação do emitente",oFont12N:oFont)
	
	nLinCalc := nLinha + 23
	
	QbraTexto(aEmpresa[1],25,oFont12N:oFont)
	oPrinter:Say(nLinCalc,098,aEmpresa[2],oFont08N:oFont)
	
	nLinCalc += 10
	
	oPrinter:Say(nLinCalc,098,aEmpresa[3],oFont08N:oFont)
	
	nLinCalc += 10
	
	oPrinter:Say(nLinCalc,098,aEmpresa[4],oFont08N:oFont)
	
	nLinCalc += 10
	
	oPrinter:Say(nLinCalc,098,aEmpresa[5],oFont08N:oFont)
	oPrinter:Line(nLinha,248,nLinha + 95,248,ESPLIN)
	
	if nModImp <> 1
		oPrinter:Say(nLinha + 13,258,"PRE-DANFE",oFont18N:oFont)
		oPrinter:Say(nLinha + 23,261,"DOCUMENTO AUXILIAR DA",oFont07:oFont)
	else
		oPrinter:Say(nLinha + 13,261,"PRE-NOTA",oFont18N:oFont)
		oPrinter:Say(nLinha + 23,262,"DOCUMENTO MODELO DA",oFont07:oFont)
	endif
	
	oPrinter:Say(nLinha + 33,261,"NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oPrinter:Say(nLinha + 43,266,"0-ENTRADA",oFont08:oFont)
	oPrinter:Say(nLinha + 53,266,"1-SAÍDA",oFont08:oFont)
	oPrinter:Say(nLinha + 47,318,aNotaF[1],oFont08N:oFont)
	oPrinter:Line(nLinha + 36,315,nLinha + 36,325,ESPLIN)
	oPrinter:Line(nLinha + 36,315,nLinha + 53,315,ESPLIN)
	oPrinter:Line(nLinha + 36,325,nLinha + 53,325,ESPLIN)
	oPrinter:Line(nLinha + 53,315,nLinha + 53,325,ESPLIN)
	oPrinter:Say(nLinha + 68,255,"N. "+aNotaF[2],oFont10N:oFont)
	
	if nModImp <> 1
		oPrinter:Say(nLinha + 78,255,"SÉRIE "+IIf(AllTrim(aNotaF[3]) == "U","0",aNotaF[3]),oFont10N:oFont)
	endif
	
	oPrinter:Say(nLinha + 88,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas + nFolImp,2),oFont10N:oFont)
	oPrinter:Line(nLinha,351,nLinha + 95,351,ESPLIN)
	oPrinter:Line(nLinha + 33,351,nLinha + 33,603,ESPLIN)
	oPrinter:Say(nLinha + 43,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	oPrinter:Line(nLinha + 63,351,nLinha + 63,603,ESPLIN)
	oPrinter:Say(nLinha + 75,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
	oPrinter:Say(nLinha + 85,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	
	nTamNatureza := Len(AllTrim(aNotaF[10])) - 1
	
	oPrinter:Line(nLinha + 97,000,nLinha + 97,603,ESPLIN)
	oPrinter:Line(nLinha + 97,000,nLinha + 120,000,ESPLIN)
	oPrinter:Line(nLinha + 97,603,nLinha + 120,603,ESPLIN)
	oPrinter:Line(nLinha + 120,000,nLinha + 120,603,ESPLIN)
	oPrinter:Say(nLinha + 106,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
	oPrinter:Say(nLinha + 116,002,Left(aNotaF[10],nTamNatureza),oFont08:oFont)
	oPrinter:Line(nLinha + 97,350,nLinha + 120,350,ESPLIN)
	oPrinter:Say(nLinha + 106,352,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
	
	oPrinter:Line(nLinha + 122,000,nLinha + 122,603,ESPLIN)
	oPrinter:Line(nLinha + 122,000,nLinha + 145,000,ESPLIN)
	oPrinter:Line(nLinha + 122,603,nLinha + 145,603,ESPLIN)
	oPrinter:Line(nLinha + 145,000,nLinha + 145,603,ESPLIN)
	oPrinter:Say(nLinha + 130,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oPrinter:Say(nLinha + 138,002,aEmpresa[8],oFont08:oFont)
	oPrinter:Line(nLinha + 122,200,nLinha + 145,200,ESPLIN)
	oPrinter:Say(nLinha + 130,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oPrinter:Line(nLinha + 122,400,nLinha + 145,400,ESPLIN)
	oPrinter:Say(nLinha + 130,405,"CNPJ",oFont08N:oFont)
	oPrinter:Say(nLinha + 138,405,Transf(aEmpresa[7],IIf(Len(aEmpresa[7]) <> 14,"@R 999.999-99","@R 99.999.999/9999-99")),oFont08:oFont)
return