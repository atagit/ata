/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 15/01/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de itens de notas fiscais                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function ITENSNF()
	private aOrd    := {}
	private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   := "ITENSNF"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "ITENS DE NOTAS FISCAIS"
	private ContFun := 0
	private cString := "SD1"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "G"
	private Titulo  := cDesc1
	private wnrel   := cPerg
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cProdIni := ""
	private cProdFin := ""
	private cArmzIni := ""
	private cArmzFin := ""
	private cDataIni := ""
	private cDataFin := ""
	private cFornIni := ""
	private cFornFin := ""
	private cProjIni := ""
	private cProjFin := ""
	private cPediIni := ""
	private cPediFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Produto de                                        ³
	//³ mv_par02 - Produto ate                                       ³
	//³ mv_par03 - Armazem de                                        ³
	//³ mv_par04 - Armazem ate                                       ³
	//³ mv_par05 - Emissao de                                        ³
	//³ mv_par06 - Emissao ate                                       ³
	//³ mv_par07 - Fornecedor de                                     ³
	//³ mv_par08 - Fornecedor ate                                    ³
	//³ mv_par09 - Projeto de                                        ³
	//³ mv_par10 - Projeto ate                                       ³
	//³ mv_par11 - Pedido de                                         ³
	//³ mv_par12 - Pedido ate                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cProdIni := mv_par01
	cProdFin := mv_par02
	cArmzIni := mv_par03
	cArmzFin := mv_par04
	cDataIni := DToS(mv_par05)
	cDataFin := DToS(mv_par06)
	cFornIni := mv_par07
	cFornFin := mv_par08
	cProjIni := mv_par09
	cProjFin := mv_par10
	cPediIni := mv_par11
	cPediFin := mv_par12
	
	RptStatus({|| Impr()},"","Aguarde processando...",lAborta)
	
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
	cQry := "select D1_DTDIGIT as D1_EMISSAO, D1_DOC, D1_SERIE, D1_COD, D1_LOCAL, D1_DESCPRO, D1_QUANT, D1_UM, D1_VUNIT, D1_VALIPI, D1_TOTAL, D1_VALICM, D1_FORNECE, D1_LOJA, NREDUZ = case when A2_NREDUZ is not null then A2_NREDUZ else A1_NREDUZ end, D1_TIPO, D1_PEDIDO, D1_CLVL "
	cQry += "from SD1010 SD1 "
	cQry += "	left join SA2010 SA2 on (D1_FORNECE = A2_COD and D1_LOJA = A2_LOJA) and D1_TIPO not in ('B','D') "
	cQry += "	left join SA1010 SA1 on (D1_FORNECE = A1_COD and D1_LOJA = A1_LOJA) and D1_TIPO in ('B','D') "
	cQry += "where (D1_DTDIGIT between '"+cDataIni+"' and '"+cDataFin+"') and (D1_COD between '"+cProdIni+"' and '"+cProdFin+"') and (D1_LOCAL between '"+cArmzIni+"' and '"+cArmzFin+"') and (D1_FORNECE between '"+cFornIni+"' and '"+cFornFin+"') and (D1_PEDIDO between '"+cPediIni+"' and '"+cPediFin+"') and (D1_CLVL between '"+cProjIni+"' and '"+cProjFin+"') and D1_TIPO in ('N','C') and SD1.D_E_L_E_T_ <> '*' "
	cQry += "order by D1_FORNECE, D1_LOJA, D1_DTDIGIT, D1_DOC, D1_SERIE"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	SetRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Referencia: "+U_ConvData(cDataIni)+" a "+U_ConvData(cDataFin),220)
	Cabec2 := "EMISSAO  NOTA FISCAL   PRODUTO                                             QUANT UN        P.UNIT.        IPI          VALOR       ICMS FORNECEDOR                    TP PEDIDO PROJETO"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	EMISSAO  NOTA FISCAL   PRODUTO                                             QUANT UN        P.UNIT.        IPI          VALOR       ICMS FORNECEDOR                    TP PEDIDO PROJETO
//	99/99/99 999999999-999 AAA999 99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 999,999,999.99 AA 999,999,999.99 999,999.99 999,999,999.99 999,999.99 999999 AAAAAAAAAAAAAAAAAAAA   A  999999 999999 
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18
	
	nLin++
	nTotGeral1 := 0
	nTotGeral2 := 0
	
	while !TEMP->(Eof())
		nTotForn1 := 0
		nTotForn2 := 0
		cFornecedor := TEMP->(D1_FORNECE+D1_LOJA)
		
		while !TEMP->(Eof()) .and. TEMP->(D1_FORNECE+D1_LOJA) == cFornecedor
			nTotNota1 := 0
			nTotNota2 := 0
			cNotaFiscal := TEMP->(D1_DOC+D1_SERIE)
			
			while !TEMP->(Eof()) .and. TEMP->(D1_FORNECE+D1_LOJA) == cFornecedor .and. TEMP->(D1_DOC+D1_SERIE) == cNotaFiscal
				@nLin,000 psay U_ConvData(TEMP->D1_EMISSAO,"yy")
				@nLin,009 psay TEMP->D1_DOC+"-"+TEMP->D1_SERIE
				@nLin,023 psay Left(TEMP->D1_COD,6)
				@nLin,030 psay TEMP->D1_LOCAL
				@nLin,035 psay TEMP->D1_DESCPRO
				@nLin,066 psay Transf(TEMP->D1_QUANT,"@E 999,999,999.99")
				@nLin,081 psay TEMP->D1_UM
				@nLin,084 psay Transf(TEMP->D1_VUNIT,"@E 999,999,999.99")
				@nLin,099 psay Transf(TEMP->D1_VALIPI,"@E 999,999.99")
				@nLin,110 psay Transf(TEMP->D1_TOTAL,"@E 999,999,999.99")
				@nLin,125 psay Transf(TEMP->D1_VALICM,"@E 999,999.99")
				@nLin,136 psay TEMP->D1_FORNECE
				@nLin,143 psay TEMP->NREDUZ
				@nLin,166 psay TEMP->D1_TIPO
				@nLin,169 psay TEMP->D1_PEDIDO
				@nLin,176 psay Left(TEMP->D1_CLVL,6)
				
				nLin++
				nTotNota1 += TEMP->D1_QUANT
				nTotNota2 += TEMP->D1_TOTAL
				nTotForn1 += TEMP->D1_QUANT
				nTotForn2 += TEMP->D1_TOTAL
				nTotGeral1 += TEMP->D1_QUANT
				nTotGeral2 += TEMP->D1_TOTAL
				
				U_SaltaFolha()
				TEMP->(DbSkip())
			enddo
			
			@nLin,000 psay "TOTAL NOTA FISCAL -->"
			@nLin,066 psay Transf(nTotNota1,"@E 999,999,999.99")
			@nLin,110 psay Transf(nTotNota2,"@E 999,999,999.99")
			
			nLin++
			
			U_SaltaFolha()
		enddo
		
		@nLin,000 psay "TOTAL FORNECEDOR  -->"
		@nLin,066 psay Transf(nTotForn1,"@E 999,999,999.99")
		@nLin,110 psay Transf(nTotForn2,"@E 999,999,999.99")
		
		nLin += 2
		
		U_SaltaFolha()
	enddo
	
	@nLin,000 psay "TOTAL GERAL       -->"
	@nLin,066 psay Transf(nTotGeral1,"@E 999,999,999.99")
	@nLin,110 psay Transf(nTotGeral2,"@E 999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	DbSelectArea("TEMP")
return