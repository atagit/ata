/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 12/04/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório Gerencial dos Almoxarifados                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _TAMCOL 82

user function GERALM()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "GERALM"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "REL. GERENCIAL DOS ALMOXARIFADOS"
	private ContFun := 0
	private cString := "SD1"
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
	
	TEMP->(DbCloseArea())
	Ms_Flush()
return

static function Impr()
	private cUltMes := DToS(GetMV("MV_ULMES"))
	private cPriMes := DToS(GetMV("MV_ULMES") + 1)
	private aAlmox := {}
	private aArmazem := {}
	
	if nTipoRel == 1
		GravarMov()
		
		Cabec1 := PadC("Periodo: "+U_ConvData(cPriMes)+" a "+U_ConvData(cDataRef),nTamanho)
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin += 2
		
		@nLin,000 psay "ESTOQUE"
		@++nLin,000 psay "Ultimo Fechamento: "+U_ConvData(cUltMes)
		
		nLin++
	else
		GravarAtu()
		
		Cabec1 := ""
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin += 2
	endif
	
	U_SaltaFolha()
	
	@nLin,000 psay Replicate("=",_TAMCOL)
	@++nLin,000 psay "COD DESCRICAO                                           QUANT                TOTAL"
	@++nLin,000 psay Replicate("=",_TAMCOL)
	
	nLin++
	
	U_SaltaFolha()
	
	DbSelectArea("SX5")
	SX5->(DbSeek(xFilial("SX5")+"AM",.F.))
	
	nTotQuant := 0 ; nTotCusto := 0
	
	while !SX5->(Eof()) .and. SX5->X5_TABELA == "AM"
//		COD DESCRICAO                                           QUANT                TOTAL
//		99  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA         999,999,999,999.99   999,999,999,999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		cArmazem := AllTrim(SX5->X5_CHAVE)
		nInd := AScan(aArmazem,{|x| x[1] = cArmazem})
		
		if !Empty(nInd)
			nQuant := aArmazem[nInd][2]
			nCusto := aArmazem[nInd][3]
		else
			nQuant := 0
			nCusto := 0
		endif
		
		if nListZero == 2 .and. Empty(nQuant) ; SX5->(DbSkip()) ; loop ; endif
		
		@nLin,000 psay cArmazem
		@nLin,004 psay Left(AllTrim(SX5->X5_DESCRI),30)
		@nLin,043 psay Transf(nQuant,"@E 999,999,999,999.99")
		@nLin,064 psay Transf(nCusto,"@E 999,999,999,999.99")
		
		nTotQuant += nQuant
		nTotCusto += nCusto
		nLin++
		
		U_SaltaFolha()
		SX5->(DbSkip())
		
		if !SX5->(Eof()) .and. SX5->X5_TABELA == "AM"
			@nLin,000 psay Replicate("-",_TAMCOL)
			
			nLin++
			
			U_SaltaFolha()
		endif
	enddo
	
	@nLin,000 psay Replicate("=",_TAMCOL)
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,004 psay "TOTAL GERAL"
	@nLin,043 psay Transf(nTotQuant,"@E 999,999,999,999.99")
	@nLin,064 psay Transf(nTotCusto,"@E 999,999,999,999.99")
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay Replicate("=",_TAMCOL)
	
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
		AAdd(aAlmox,{AllTrim(TEMP->COD),TEMP->QUANT,TEMP->CUSTO,TEMP->LOCAL})
		
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
		if (nInd := AScan(aAlmox,{|x| x[1] = AllTrim(TEMP->COD) .and. x[4] = TEMP->LOCAL})) == 0
			if TEMP->TM $ "SD1/002/009/499"
				AAdd(aAlmox,{AllTrim(TEMP->COD),TEMP->QUANT,TEMP->CUSTO,TEMP->LOCAL})
			else
				AAdd(aAlmox,{AllTrim(TEMP->COD),TEMP->QUANT * -1,TEMP->CUSTO,TEMP->LOCAL})
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
	ProcRegua(Len(aAlmox))
	
	for j := 1 to Len(aAlmox)
		if (nInd := AScan(aArmazem,{|x| x[1] = aAlmox[j][4]})) == 0
			AAdd(aArmazem,{aAlmox[j][4],aAlmox[j][2],aAlmox[j][3]})
		else
			aArmazem[nInd][2] += aAlmox[j][2]
			aArmazem[nInd][3] += aAlmox[j][3]
		endif
		
		IncProc()
	next
return

static function GravarAtu()
	cQry := "select 0 as NUMSEQ, 'SB2' as TM, B2_COD as COD, B2_LOCAL as LOCAL, B1_UM as UM, B2_QATU as QUANT, B2_CM1 as CUSTO "
	cQry += "from "+RetSqlName("SB2")+" SB2 inner join "+RetSqlName("SB1")+" SB1 on (B2_COD = B1_COD) "
	cQry += "where (B2_COD between '"+cProdIni+"' and '"+cProdFin+"') and (B2_LOCAL between '"+cArmaIni+"' and '"+cArmaFin+"') and SB2.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	cQry += "order by B2_LOCAL, B2_COD"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		AAdd(aAlmox,{AllTrim(TEMP->COD),TEMP->QUANT,TEMP->CUSTO,TEMP->LOCAL})
		
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	ASort(aAlmox,,,{|x,y| x[4]+x[1] < y[4]+y[1]})
	ProcRegua(Len(aAlmox))
	
	for j := 1 to Len(aAlmox)
		if (nInd := AScan(aArmazem,{|x| x[1] = aAlmox[j][4]})) == 0
			AAdd(aArmazem,{aAlmox[j][4],aAlmox[j][2],aAlmox[j][3]})
		else
			aArmazem[nInd][2] += aAlmox[j][2]
			aArmazem[nInd][3] += aAlmox[j][3]
		endif
		
		IncProc()
	next
return