/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 05/07/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relação de notas fiscais de saida                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELNFSAI()
	private aOrd    := {"Data Emissao","Nota Fiscal"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "NFSAID"
	private Cabec1  := "TIPO DO PROJETO"
	private Cabec2  := "EMISSAO     NF         CFOP                         CLIENTE                         QUANT               TOTAL         ICM         IPI"
	private cDesc1  := "NOTAS FISCAIS DE SAIDA POR TIPO"
	private ContFun := 0
	private cString := "SD2"
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
	
	private cDtIni := ""
	private cDtFin := ""
	private cCliIni := ""
	private cCliFin := ""
	private cTpPrjIni := ""
	private cTpPrjFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Cliente de                                        ³
	//³ mv_par04 - Cliente ate                                       ³
	//³ mv_par05 - Tipo Projeto de                                   ³
	//³ mv_par06 - Tipo Projeto ate                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cCliIni := mv_par03
	cCliFin := mv_par04
	cTpPrjIni := mv_par05
	cTpPrjFin := mv_par06
	
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
	local nTotItem := 0
	local cReferencia := ""
	local nTotProjeto := 0
	local nTotIcm := 0
	local nTotIpi := 0
	
	cRdpLeg := "Emitido por: "+cUserName+"                              Recebido por:"
	nTotGeral := 0
	nTotGerIcm := 0
	nTotGerIpi := 0
	
	cQry := "select D2_EMISSAO, D2_DOC, D2_CF, F4_TEXTO, D2_CLIENTE, A1_NREDUZ, D2_QUANT, D2_TOTAL, D2_VALICM, D2_VALIPI, CTH_TPPRJ "
	cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SC6")+" SC6 on (D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM) "
	cQry += "	inner join "+RetSqlName("CTH")+" CTH on (C6_CLVL = CTH_CLVL) "
	cQry += "	inner join "+RetSqlName("SF4")+" SF4 on (D2_TES = F4_CODIGO) "
	cQry += "	inner join "+RetSqlName("SA1")+" SA1 on (D2_CLIENTE = A1_COD and D2_LOJA = A1_LOJA) "
	cQry += "where (D2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (D2_CLIENTE between '"+cCliIni+"' and '"+cCliFin+"') and (C6_TPPROJE between '"+cTpPrjIni+"' and '"+cTpPrjFin+"') and (F4_DUPLIC = 'S' or F4_DUPLIC = 'N' and D2_VALIPI <> 0 or D2_VALICM <> 0) and left(F4_OPER,1) not in ('6','7','8','9') and SD2.D_E_L_E_T_ <> '*' and SA1.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 2
		cQry += "order by CTH_TPPRJ, D2_DOC, D2_EMISSAO"
	else
		cQry += "order by CTH_TPPRJ, D2_EMISSAO, D2_DOC"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	cCbcRef := "Periodo: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	EMISSAO     NF         CFOP                         CLIENTE                         QUANT               TOTAL         ICM         IPI
//  99/99/9999  999999999  99999 AAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAA  999,999,999.999  999,999,999,999.99  999,999.99  999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		cTpProjeto := TEMP->CTH_TPPRJ
		
		@nLin,000 psay U_Negrito(.T.)+cTpProjeto+" "+If(SX5->(DbSeek(xFilial("SX5")+"Z1"+cTpProjeto,.F.)),AllTrim(SX5->X5_DESCRI),"")+U_Negrito(.F.)
		
		nLin++
		
		while cTpProjeto == TEMP->CTH_TPPRJ .and. !TEMP->(Eof())
			@nLin,000 psay U_ConvData(TEMP->D2_EMISSAO)
			@nLin,012 psay TEMP->D2_DOC
			@nLin,023 psay TEMP->D2_CF+" "+TEMP->F4_TEXTO
			@nLin,052 psay TEMP->A1_NREDUZ
			@nLin,074 psay Transf(TEMP->D2_QUANT,"@E 999,999,999.999")
			@nLin,091 psay Transf(TEMP->D2_TOTAL,"@E 999,999,999,999.99")
			@nLin,111 psay Transf(TEMP->D2_VALICM,"@E 999,999.99")
			@nLin,123 psay Transf(TEMP->D2_VALIPI,"@E 999,999.99")
			
			IncProc()
			
			nTotItem++
			nLin++
			nTotProjeto += TEMP->D2_TOTAL
			nTotIcm += TEMP->D2_VALICM
			nTotIpi += TEMP->D2_VALIPI
			nTotGeral += TEMP->D2_TOTAL
			nTotGerIcm += TEMP->D2_VALICM
			nTotGerIpi += TEMP->D2_VALIPI
			
			U_SaltaFolha()
			
			TEMP->(DbSkip())
  		enddo
		
		nLin++
		
		@nLin,084 psay "TOTAL"
		@nLin,091 psay Transf(nTotProjeto,"@E 999,999,999,999.99")
		@nLin,111 psay Transf(nTotIcm,"@E 999,999.99")
		@nLin,123 psay Transf(nTotIpi,"@E 999,999.99")
		
		nLin++
		
		@nLin,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",136))
		
		nLin++
		
		nTotProjeto := 0 ; nTotIcm := 0 ; nTotIpi := 0
	enddo
	
	@nLin,078 psay "TOTAL GERAL"
	@nLin,091 psay Transf(nTotGeral,"@E 999,999,999,999.99")
	@nLin,111 psay Transf(nTotGerIcm,"@E 999,999.99")
	@nLin,123 psay Transf(nTotGerIpi,"@E 999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return