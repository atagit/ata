/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/04/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório Posicao de Estoque                          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function POSEST()
	private aOrd    := {"Codigo Produto","Descricao Produto"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "GERALM"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "RELATORIO DE ESTOQUE"
	private ContFun := 0
	private cString := "SB9"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private nTamanho := IIf(Tamanho == "G",220,132)
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
	
	private cDataRef := ""
	private nListZero := 0
	private cProdIni := ""
	private cProdFin := ""
	private cArmaIni := ""
	private cArmaFin := ""
	private nTipoRel := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Data Referencia                                   ³
	//³ mv_par02 - Listar Qtd Zerado (1-Sim/2-Nao)                   ³
	//³ mv_par03 - Produto de                                        ³
	//³ mv_par04 - Produto ate                                       ³
	//³ mv_par05 - Armazem de                                        ³
	//³ mv_par06 - Armazem ate                                       ³
	//³ mv_par07 - Tipo (1-Movimento/2-Atual)                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDataRef := DToS(mv_par01)
	nListZero := mv_par02
	cProdIni := mv_par03
	cProdFin := mv_par04
	cArmaIni := mv_par05
	cArmaFin := mv_par06
	nTipoRel := mv_par07
	
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
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	Ms_Flush()
return

static function Impr()
	local cArmazem := ""
	local nTotQuant := 0
	local nTotValor := 0
	local nCont := 0
	
	private cUltMes := DToS(GetMV("MV_ULMES"))
	private cPriMes := DToS(GetMV("MV_ULMES") + 1)
	private aAlmox := {}
	
	if nTipoRel == 1
		GravarMov()
		
		Cabec1 := PadC("Periodo: "+U_ConvData(cPriMes)+" a "+U_ConvData(cDataRef),nTamanho)
//		Cabec2 := "CODIGO  AM  TP  GRUP  DESCRICAO                                           UN  UL ENTRADA                 QUANT               VALOR"
		Cabec2 := "CODIGO  AM  TP  RET  GRUP  DESCRICAO                                           UN  ULT ENTRAD             QUANT           VALOR"
	else
		GravarAtu()
		
		Cabec1 := "CODIGO  AM  TP  RET  GRUP  DESCRICAO                                           UN  ULT ENTRAD             QUANT           VALOR"
		Cabec2 := ""
	endif
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	cArmazem := aAlmox[1][4]
	
	U_SaltaFolha()
	
	@nLin,000 psay "DEPOSITO: "+cArmazem+" "+IIf(SX5->(DbSeek(xFilial("SX5")+"AM"+cArmazem,.F.)),AllTrim(SX5->X5_DESCRI),"")
	
	nLin += 2
	
	U_SaltaFolha()
	
	for i := 1 to Len(aAlmox)
/*		if nListZero == 2 .and. Empty(aAlmox[i][2])
			loop
		endif*/
		
		if aAlmox[i][4] <> cArmazem
			cArmazem := aAlmox[i][4]
			
			nLin += 2
			
			U_SaltaFolha()
			
			@nLin,000 psay "DEPOSITO: "+cArmazem+" "+IIf(SX5->(DbSeek(xFilial("SX5")+"AM"+cArmazem,.F.)),AllTrim(SX5->X5_DESCRI),"")
			
			nLin++
			
			U_SaltaFolha()
		endif
		
//		CODIGO  AM  TP  RET  GRUP  DESCRICAO                                           UN  ULT ENTRAD             QUANT           VALOR
//		AAA999  99  AA  AAA  9999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  AA  99/99/9999  999,999,999.9999  999,999,999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		if SB1->(MsSeek(xFilial("SB1")+aAlmox[i][1]+aAlmox[i][4]))
			@nLin,000 psay Left(AllTrim(aAlmox[i][1]),60)
			@nLin,008 psay aAlmox[i][4]
			
			@nLin,012 psay AllTrim(SB1->B1_TIPO)
			@nLin,016 psay IIf(SB1->B1_MATRET == "1","RET","   ")
			@nLin,021 psay AllTrim(SB1->B1_GRUPO)
			@nLin,027 psay AllTrim(SB1->B1_DESC)
			@nLin,079 psay AllTrim(SB1->B1_UM)
			@nLin,083 psay U_ConvData(DToS(SB1->B1_UCOM))
			
			@nLin,095 psay Transf(aAlmox[i][2],"@E 999,999,999.9999")
			@nLin,113 psay Transf(aAlmox[i][3],"@E 999,999,999.99")
			
			nTotQuant += aAlmox[i][2]
			nTotValor += aAlmox[i][3]
			nCont++
			nLin++
			
			U_SaltaFolha()
		endif
	next
	
	@nLin,083 psay "TOTAL"
	@nLin,095 psay Transf(nTotQuant,"@E 999,999,999.9999")
	@nLin,113 psay Transf(nTotValor,"@E 999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return

static function GravarMov()
	cQry := "select 0 as NUMSEQ, 'SB9' as TM, B9_COD as COD, B9_LOCAL as LOCAL, B1_UM as UM, B9_QINI as QUANT, B9_VINI1 as CUSTO "
	cQry += "from "+RetSqlName("SB9")+" SB9 inner join "+RetSqlName("SB1")+" SB1 on (B9_COD = B1_COD) "
	cQry += "where B9_DATA = '"+cUltMes+"' and (B9_COD between '"+cProdIni+"' and '"+cProdFin+"') and (B9_LOCAL between '"+cArmaIni+"' and '"+cArmaFin+"') and SB9.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	cQry += "order by B9_LOCAL, B9_COD"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		AAdd(aAlmox,{TEMP->COD,TEMP->QUANT,TEMP->CUSTO,TEMP->LOCAL})
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	
	cQry := "select D1_DTDIGIT as EMISSAO, D1_NUMSEQ as NUMSEQ, 'SD1' as TM, D1_COD as COD, D1_LOCAL as LOCAL, D1_UM as UM, D1_QUANT as QUANT, D1_CUSTO as CUSTO "
	cQry += "from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SF4")+" SF4 on (D1_TES = F4_CODIGO) "
	cQry += "where (D1_DTDIGIT between '"+cPriMes+"' and '"+cDataRef+"') and (D1_COD between '"+cProdIni+"' and '"+cProdFin+"') and (D1_LOCAL between '"+cArmaIni+"' and '"+cArmaFin+"') and F4_ESTOQUE <> 'N' and SD1.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
	cQry += "union all "
	cQry += "select D2_EMISSAO as EMISSAO, D2_NUMSEQ as NUMSEQ, 'SD2' as TM, D2_COD as COD, D2_LOCAL as LOCAL, D2_UM as UM, D2_QUANT as QUANT, D2_CUSTO1 as CUSTO "
	cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SF4")+" SF4 on (D2_TES = F4_CODIGO) "
	cQry += "where (D2_EMISSAO between '"+cPriMes+"' and '"+cDataRef+"') and (D2_COD between '"+cProdIni+"' and '"+cProdFin+"') and (D2_LOCAL between '"+cArmaIni+"' and '"+cArmaFin+"') and F4_ESTOQUE <> 'N' and SD2.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
	cQry += "union all "
	cQry += "select D3_EMISSAO as EMISSAO, D3_NUMSEQ as NUMSEQ, D3_TM as TM, D3_COD as COD, D3_LOCAL as LOCAL, D3_UM as UM, D3_QUANT as QUANT, D3_CUSTO1 as CUSTO "
	cQry += "from "+RetSqlName("SD3")+" "
	cQry += "where (D3_EMISSAO between '"+cPriMes+"' and '"+cDataRef+"') and (D3_COD between '"+cProdIni+"' and '"+cProdFin+"') and (D3_LOCAL between '"+cArmaIni+"' and '"+cArmaFin+"') and D3_ESTORNO <> 'S' and D_E_L_E_T_ <> '*' "
	cQry += "order by EMISSAO, COD, LOCAL, NUMSEQ"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if (nInd := AScan(aAlmox,{|x| x[1] = TEMP->COD .and. x[4] = TEMP->LOCAL})) == 0
			if TEMP->TM $ "SD1/002/009/499"
				AAdd(aAlmox,{TEMP->COD,TEMP->QUANT,TEMP->CUSTO,TEMP->LOCAL})
			else
				AAdd(aAlmox,{TEMP->COD,TEMP->QUANT * -1,TEMP->CUSTO,TEMP->LOCAL})
			endif
		else
			if TEMP->TM $ "SD1/002/009/499"
				aAlmox[nInd][2] += TEMP->QUANT
				aAlmox[nInd][3] += TEMP->CUSTO
			else
				aAlmox[nInd][2] -= TEMP->QUANT
				aAlmox[nInd][3] -= TEMP->CUSTO
			endif
		endif
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	ASort(aAlmox,,,{|x,y| x[4]+x[1] < y[4]+y[1]})
return

static function GravarAtu()
	local cCondic := IIf(nListZero == 2," and B2_QATU <> 0","")
	
//	cQry := "select 0 as NUMSEQ, 'SB2' as TM, B2_COD as COD, B2_LOCAL as LOCAL, B1_UM as UM, B2_QATU as QUANT, B2_CM1 as CUSTO "
	cQry := "select 0 as NUMSEQ, 'SB2' as TM, B2_COD as COD, B2_LOCAL as LOCAL, B1_UM as UM, B2_QATU as QUANT, (B2_QATU * B1_ULTPRC) as CUSTO, B1_DESC as DESC "
	cQry += "from "+RetSqlName("SB2")+" SB2 inner join "+RetSqlName("SB1")+" SB1 on (B2_COD = B1_COD) "
	cQry += "where (B2_COD between '"+cProdIni+"' and '"+cProdFin+"') and (B2_LOCAL between '"+cArmaIni+"' and '"+cArmaFin+"')"+cCondic+" and B1_MSBLQL <> '1' and SB2.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	cQry += "order by B2_LOCAL, B2_COD"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		AAdd(aAlmox,{TEMP->COD,TEMP->QUANT,TEMP->CUSTO,TEMP->LOCAL,TEMP->DESC})
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	do case
		case nOrdem == 1
			ASort(aAlmox,,,{|x,y| x[4]+x[1] < y[4]+y[1]})
		case nOrdem == 2
			ASort(aAlmox,,,{|x,y| x[4]+x[5] < y[4]+y[5]})
	endcase
	
//	ASort(aAlmox,,,{|x,y| x[4]+x[1] < y[4]+y[1]})
return