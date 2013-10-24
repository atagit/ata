/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/12/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cópia de Cheque                                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "topconn.ch"

user function IMPCHQ()
	private aOrd    := {"Cheque"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "CPCHQ"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "COPIA DE CHEQUE"
	private ContFun := 0
	private cString := "SEF"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cBancoDe := ""
	private cAgenciaDe := ""
	private cContaDe := ""
	private cChqIni := ""
	private cChqFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco                                             ³
	//³ mv_par02 - Agencia                                           ³
	//³ mv_par03 - Conta                                             ³
	//³ mv_par04 - Cheque de                                         ³
	//³ mv_par05 - Cheqie ate                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cBancoDe := mv_par01
	cAgenciaDe := mv_par02
	cContaDe := mv_par03
	cChqIni := AllTrim(mv_par04)
	cChqFin := AllTrim(mv_par05)
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
	
	set device to screen
	
	if aReturn[5] == 1
		set printer to
		DbCommitAll()
		DbCloseArea()
		OurSpool(wnrel)
	else
		DbCloseArea()
	endif
	
	Ms_Flush()
return

static function Impr()
	private lFirst := .T.
	
	cQry := "select * "
	cQry += "from "+RetSqlName("SEF")+" "
	cQry += "where (EF_NUM between '"+cChqIni+"' and '"+cChqFin+"') and EF_BANCO = '"+cBancoDe+"' and EF_AGENCIA = '"+cAgenciaDe+"' and EF_CONTA = '"+cContaDe+"' and EF_TIPO = '' and D_E_L_E_T_ <> '*' "
	cQry += "order by EF_NUM"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
//	@000,000 psay Chr(27)+Chr(48)
//	@000,000 psay Chr(27)+"C"+Chr(24)
	@000,000 psay Chr(27)+"C"+Chr(24)
	
	while !TEMP->(Eof())
		SE5->(DbSetOrder(11))
		SE5->(DbGoTop())
		
		if SE5->(DbSeek(xFilial("SE5")+cBancoDe+cAgenciaDe+cContaDe+TEMP->EF_NUM,.F.)) .and. TEMP->EF_PREDATA == "T"
			while !SE5->(Eof()) .and. SE5->E5_BANCO == cBancoDe .and. SE5->E5_AGENCIA == cAgenciaDe .and. SE5->E5_CONTA == cContaDe .and. SE5->E5_NUMCHEQ == TEMP->EF_NUM
				if SE5->E5_TIPODOC == "CH"
					dData := SE5->E5_DTDIGIT
				endif
				
				SE5->(DbSkip())
			enddo
		else
			dData := SToD(TEMP->EF_DATA)
		endif
		
		U_Cheque(cBancoDe,cAgenciaDe,cContaDe,TEMP->EF_NUM,TEMP->EF_VALOR,TEMP->EF_BENEF,dData)
		
		@PRow() + 9,000 psay ""
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
return

/*static function Cheque()
	local lRet := .F.
	local lFirst := .T.
	local aMes := {"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
	local lFa480Dat := ExistBlock("FA480DAT")
	local cAlias := Alias()
	local cExt1
	local cExt2
	local nTamanho
	local nLoop
	local nRepete
	local nLinLoc
	local nColLoc
	local nColDat
	local nColBco
	local nColCta
	local cValor
	local Munic
	
	local nTotChq := 1780.5
	local cBenef := "ATA INDUSTRIA MECANICA LTDA"
	local dData := SToD("20131003")
	local cExtenso := Extenso(nTotChq,.F.,1)
	
	DbSelectArea("SA6")
	DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe+cChqIni,.F.)
	
	if !Empty(SA6->A6_LAYOUT)
		nTamChq := Val(SubStr(SA6->A6_LAYOUT,1,2))
		nSalto  := Val(SubStr(SA6->A6_LAYOUT,3,1))
		nLinVlr := Val(SubStr(SA6->A6_LAYOUT,4,1))
		nColVlr := Val(SubStr(SA6->A6_LAYOUT,25,3))
		nColVlr := IIf(nColVlr == 0,93,nColVlr)
		nLin1Ext:= Val(SubStr(SA6->A6_LAYOUT,5,1)) - nLinVlr
		nCol1Ext:= Val(SubStr(SA6->A6_LAYOUT,6,2))
		nLin2Ext:= Val(SubStr(SA6->A6_LAYOUT,8,1)) - Val(SubStr(SA6->A6_LAYOUT,5,1))
		nCol2Ext:= Val(SubStr(SA6->A6_LAYOUT,9,2))
		nTamExt := Val(SubStr(SA6->A6_LAYOUT,23,2))
		nTamExt := IIf(nTamExt == 0,95,nTamExt)
		nLinFav := Val(SubStr(SA6->A6_LAYOUT,11,2)) - Val(SubStr(SA6->A6_LAYOUT,8,1))
		nColFav := Val(SubStr(SA6->A6_LAYOUT,13,2))
		nLinDat := Val(SubStr(SA6->A6_LAYOUT,15,2)) - Val(SubStr(SA6->A6_LAYOUT,11,2))
		nColVir := Val(SubStr(SA6->A6_LAYOUT,17,2))
		nCasas  := Val(SubStr(SA6->A6_LAYOUT,19,1))
		nCasas  := IIf(nCasas == 0,2,nCasas)
		nColAno := Val(SubStr(SA6->A6_LAYOUT,20,3))
		lComp   := (SubStr(SA6->A6_LAYOUT,28,1) == "S" .or. SubStr(SA6->A6_LAYOUT,28,1) == " ")
		cMunic  := SA6->A6_MUN
		
		DbCloseArea()
		DbSelectArea(cAlias)
		
		cExt1 := SubStr(cExtenso,1,nTamExt)
		nLoop := Len(cExt1)
		
		while .T.
			if Len(cExtenso) == Len(cExt1) .and. Len(cExt1) + nCol1Ext <= nTamExt
				Exit
			endif
			
			if SubStr(cExtenso,Len(cExt1),1) == " " .and. Len(cExt1) + nCol1Ext <= nTamExt
				Exit
			endif
			
			cExt1 := SubStr(cExtenso,1,nLoop)
			nLoop--
			
			if nLoop <= 0
				MsgAlert("Erro na configuracao do cheque."+Chr(13)+"Verifique o tamanho das linhas de extenso.")
				
				return .F.
			endif
		enddo
		
		cExt2 := SubStr(cExtenso,Len(cExt1) + 1,nTamExt)
		
		if Empty(cExt2)
			cExt1 += Replicate("*",nTamExt - Len(cExt1) - nCol1Ext)
		else
			cExt1 := StrTran(cExt1," ","  ",,nTamExt - Len(cExt1) - nCol1Ext + 1)
		endif
		
		cExt2 += Replicate("*",nTamExt - Len(cExt2) - nCol2Ext)
		nComp := GetMv("MV_COMP")
		cSimb := GetMv("MV_SIMB1")
		cValor := AllTrim(Transf(nTotChq,"@E 99,999,999,999.99"))
		
		if lFirst
			@nLinVlr,0 psay Chr(27)+Chr(64)
			
			if nSalto = 8
				@nLinVlr,0 psay Chr(27)+Chr(48)
			endif
			
			if lComp .and. !Empty(nComp)
				@nLinVlr,0 psay Chr(nComp)
			endif
		endif
		
		__LogPages()
		
		if lFirst
			if lComp
				SetPrc(nLinVlr,0)
				
				@nLinVlr,nColVlr + 1 psay cSimb
			else
				SetPrc(nLinVlr,0)
				
				@nLinVlr,nColVlr + 2 psay cSimb
			endif
			
			lFirst := .F.
		else
			@nLinVlr,nColVlr psay cSimb
		endif
		
		nRepete := PCol() + Len(cValor) + 17 - Len(cValor) - nTamExt
		
		if nRepete > 0
			cValor += Replicate("*",17 - Len(cValor) - nRepete)
		else
			cValor += Replicate("*",17 - Len(cValor))
		endif
		
		@nLinVlr,PCol() psay cValor
		@PRow() + nLin1Ext,nCol1Ext psay cExt1
		@PRow() + nLin2Ext,nCol2Ext psay cExt2
		@PRow() + nLinFav ,nColFav psay cBenef
		
		nTamanho := 1 + Len(Trim(cMunic))
		
		@PRow() + nLinDat,nColVir - nTamanho psay IIf(!Empty(cMunic),Trim(cMunic)," ")
		@PRow(),nColVir + 1 psay Day(dData) picture "99"
		@PRow(),PCol() + 6 psay aMes[Month(dData)]
		
		if nCasas == 1
			@PRow(),nColAno psay SubStr(Str(Year(dData),4),4,1)
		elseif nCasas == 2
			@PRow(),nColAno psay SubStr(Str(Year(dData),4),3,2)
		elseif nCasas == 3
			@PRow(),nColAno psay SubStr(Str(Year(dData),4),2,3)
		else
			@PRow(),nColAno psay Str(Year(dData),4)
		endif
		
		@@PRow() + 6,000 PSay U_TamPag(66)+U_Reduz(0)
	else
		DbCloseArea()
		DbSelectArea(cAlias)
	endif
return*/