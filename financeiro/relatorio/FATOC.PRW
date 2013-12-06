/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/11/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de faturas por ordem de compra              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function FATOC()
	private aOrd    := {"Projeto","Emissao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "FATOC"
	private Cabec1  := ""
	private Cabec2  := "EMISSAO    | PROJETO | NOTA FISCAL   | NATUREZA                  |           QUANT |              TOTAL"
	private cDesc1  := "FATURA POR O.C."
	private cString := "SE1"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
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
	
	private nNuPor := 0
	private cPrjIni := ""
	private cPrjFin := ""
	private cOcIni := ""
	private cOcIFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Por (1-Projeto/2-O.C.)                            ³
	//³ mv_par02 - Projeto de                                        ³
	//³ mv_par03 - Projeto ate                                       ³
	//³ mv_par04 - O.C. de                                           ³
	//³ mv_par05 - O.C. ate                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	nNuPor := mv_par01
	cPrjIni := mv_par02
	cPrjFin := mv_par03
	cOcIni := mv_par04
	cOcFin := mv_par05
	
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
	local nTotReg := 0
	local nTotal := 0
	local nQuant := 0
	local nTgQuant := 0
	local nTgTotal := 0
	
	private nQuantOC := 0
	private nValorOC := 0
	private nQuantPJ := 0
	private nValorPJ := 0
	private cCliente := ""
	private cDtVenc := ""
	
	cQry := "select E1_EMISSAO, E1_VENCREA, E1_CLVLCR, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_NATUREZ, E1_VALOR, E1_CLIENTE, E1_LOJA, A1_NREDUZ, CTH_AF, CTH_DTREAL "
	cQry += "from "+RetSqlName("SE1")+" SE1 inner join "+RetSqlName("CTH")+" CTH on (E1_CLVLCR = CTH_CLVL) "
	cQry += "	inner join "+RetSqlName("SA1")+" SA1 on (CTH_CLIENT = A1_COD and CTH_LOJACL = A1_LOJA) "
	cQry += "where (CTH_AF between '"+cOcIni+"' and '"+cOcFin+"') and SE1.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' "
	cQry += "order by E1_NUM, E1_PREFIXO"
	
	tcquery cQry new alias "TEMP"
	count to nTotReg
	
	DbSelectArea("TEMP")
	ProcRegua(nTotReg)
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cAF := TEMP->CTH_AF
		Cabec1 := PadC("O.C.: "+cAF+"          CLIENTE: "+AllTrim(TEMP->A1_NREDUZ)+"          VENC.: "+U_ConvData(CTH_DTREAL,"yy"),132)
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
		while !TEMP->(Eof()) .and. TEMP->CTH_AF == cAF
//			EMISSAO  | NOTA FISCAL | NATUREZA        |            PESO |              TOTAL | VENCTO
//			99/99/99   999999999     AAAAAAAAAAAAAAA   999,999,999.999   999,999,999,999.99   99/99/99
//			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12
			
			if TEMP->E1_PARCELA == "001"
				lNF := .T.
			else
				lNF := .F.
			endif
			
			@nLin,000 psay U_ConvData(TEMP->E1_EMISSAO,"yy")
			@nLin,011 psay TEMP->E1_NUM
			
			do case
				case AllTrim(TEMP->E1_NATUREZ) $ "10101/10108"
					@nLin,025 psay "FATURAMENTO"
				case AllTrim(TEMP->E1_NATUREZ) $ "10504"
					@nLin,025 psay "ADIANTAMENTO"
			endcase
			
			@nLin,043 psay Transf(CON->C5_PESOL,"@E 999,999,999.999")
			@nLin,061 psay Transf(TEMP->E1_VALOR,"@E 999,999,999,999.99")
			@nLin,082 psay U_ConvData(TEMP->E1_VENCREA,"yy")
			
			nLin++
			
			U_SaltaFolha()
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		TotalOC(cAF)
		
		nLin += 2
		
		@nLin,014 psay "REALIZADO..:"
		@nLin,067 psay Transf(nQuant,"@E 999,999,999.999")
		@nLin,085 psay Transf(nTotal,"@E 999,999,999,999.99")
		
		nTgQuant += nQuant
		nTgTotal += nTotal
		
		nLin++
		
		@nLin,014 psay "ORCADO.....:"
		@nLin,067 psay Transf(nQuantPJ,"@E 999,999,999.999")
		@nLin,085 psay Transf(nValorPJ,"@E 999,999,999,999.99")
		
		nLin++
		
		@nLin,014 psay "PENDENTE...:"
		@nLin,067 psay Transf(nQuantPJ - nQuant,"@E 999,999,999.999")
		@nLin,085 psay Transf(nValorPJ - nTotal,"@E 999,999,999,999.99")
		
		nQuant := 0 ; nTotal := 0 ; nQuantPJ := 0 ; nTotalPJ := 0 ; nTgQuant := 0 ; nTgTotal := 0
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	DbSelectArea("TEMP")
return

static function TotalOC(cOC)
	nQuantOC := 0
	nValorOC := 0
	
	cCon := "select sum(CTH_PESAF) as PESO, sum(CTH_VLAF) as VALOR, sum(CTH_PESAF * CTH_VLAF) as TOTAL from CTH010 where CTH_AF = '"+cOC+"' and D_E_L_E_T_ <> '*'"
	
	tcquery cCon new alias "CON"
	DbSelectArea("CON")
	
	nQuantOC := CON->PESO
	nValorOC := CON->TOTAL
	
	CON->(DbCloseArea())
return