/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/05/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de OC para faturamento                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _TAMCOL 132

user function RELOC(cOC)
	private aOrd := {"O.C."}
	private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg := IIf(!Empty(cOC),"","RELOC")
	private Cabec1 := ""
	private Cabec2 := ""
	private cDesc1 := "CADASTRO ORDEM DE COMPRA"
	private ContFun := 0
	private cString := "SZM"
	private m_pag := 1
	private nOrdem := 0
	private nTipo := 0
	private Tamanho := "M"
	private Titulo := cDesc1
	private wnrel := FunName()
	private lAborta := .T.
	
	private nLin := 014
	private cQry := ""
	private nRdpPag := 1
	private nInd := 0
	private cRdpLeg := ""
	private cCbcRef := ""
	private cCbcNum := ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cOCIni := ""
	private cOCFin := ""
	private cCodIni := ""
	private cCodFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Codigo OC de                                      ³
	//³ mv_par02 - Codigo OC ate                                     ³
	//³ mv_par03 - O.C. de                                           ³
	//³ mv_par04 - O.C. ate                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
//	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.F.,aOrd,.F.,Tamanho,,.F.)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	if !Empty(cOC)
		cCodIni := ""
		cCodFin := "ZZZZZZ"
		cOCIni := AllTrim(cOC)
		cOCFin := AllTrim(cOC)
	else
		cCodIni := mv_par01
		cCodFin := mv_par02
		cOCIni := mv_par03
		cOCFin := mv_par04
	endif
	
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
	local nContLin := 0
	
	cQry := "select convert(varchar(8000),convert(binary(8000),ZM_OBSREGI)) AS ZM_OBSREGI, * "
	cQry += "from "+RetSqlName("SZM")+" "
	cQry += "where (ZM_CODIGO between '"+cCodIni+"' and '"+cCodFin+"') and (ZM_OC between '"+cOCIni+"' and '"+cOCFin+"') and D_E_L_E_T_ <> '*'"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cOC := TEMP->ZM_OC
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin--
		
		@nLin,000 psay Replicate("=",_TAMCOL)
		
		nLin++
		
//		NUM O.C.: 999999999999999   VENC....: 99/99/9999   DESTINACAO: AAAAAAAAAAAAAAAAAAAA    NAT.OP.: AAAAAAAAAAAAAAAAAAAA    NAT.FAT: AA
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay "NUM O.C.: "+TEMP->ZM_OC
		@nLin,028 psay "VENC....: "+U_ConvData(TEMP->ZM_VENCOC)
		@nLin,050 psay "DESTINACAO: "+Left(TEMP->ZM_DESTINA,20)
		@nLin,087 psay "NAT.OP.: "+Left(TEMP->ZM_NATOPER,20)
		@nLin,120 psay "NAT.FAT: "+TEMP->ZM_NATFAT
		
		nLin++
		
		while !TEMP->(Eof()) .and. TEMP->ZM_OC == cOC
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC(" * * *  C L I E N T E  * * *",_TAMCOL)
			
			nLin++
			
//			CLIENTE: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                                       UF: AA
//			END....: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        CEP: 99999-999
//			CNPJ...: 99.999.999/9999-99    I.E.: 99999999999999999999
//			TELEF..: 99 9999-9999       CONTATO: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    ATT. NFe: AAAAAAAAAAAAAAAAAAAA
//			E-MAIL.: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA          E-MAIL NFe: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			if SA1->(DbSeek(xFilial("SA1")+TEMP->(ZM_CLIENTE+ZM_LOJA),.F.))
				@nLin,000 psay "CLIENTE: "+AllTrim(SA1->A1_NOME)
				@nLin,118 psay "UF: "+SA1->A1_EST
				@++nLin,000 psay "END....: "+AllTrim(SA1->A1_END)+' - '+AllTrim(SA1->A1_BAIRRO)+' - '+AllTrim(SA1->A1_MUN)
				@nLin,117 psay "CEP: "+Transf(SA1->A1_CEP,"@R 99999-999")
				@++nLin,000 psay "CNPJ...: "+Transf(SA1->A1_CGC,"@R 99.999.999/9999-99")
				@nLin,031 psay "I.E.: "+SA1->A1_INSCR
				@++nLin,000 psay "TELEF..: "+Left(AllTrim(SA1->A1_DDD),2)+" "+Transf(SA1->A1_TEL,"@R 9999-9999")
				@nLin,028 psay "CONTATO: "+AllTrim(TEMP->ZM_CONTATO)
				@nLin,071 psay "ATT. NFe: "+AllTrim(TEMP->ZM_ATT)
				@++nLin,000 psay "E-MAIL.: "+Left(AllTrim(TEMP->ZM_EMAIL),50)
				@nLin,069 psay "E-MAIL NFe: "+Left(AllTrim(TEMP->ZM_EMAILNF),50)
			endif
			
			nLin++
			
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC("* * *  QUANTIDADE E PRECO COM ICMS/PIS/COFINS/ISS - SEM IPI  * * *",_TAMCOL)
			
			nLin++
			
//			QUANT....: 999,999,999.99 AA                     PR.UNIT.: 999,999,999.99                     VL.TOTAL: 9,999,999,999,999.99
//			COND.PAG.: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			QUANT....: 999,999,999.99 AA   PR.UNIT.: 999,999,999.99  VL.TOTAL: 9,999,999,999,999.99   COND.PAG.: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay "QUANT....: "+AllTrim(Transf(TEMP->ZM_QUANT,"@E 999,999,999.99"))+" "+TEMP->ZM_UM
			@nLin,031 psay "PR.UNIT.: "+AllTrim(Transf(TEMP->ZM_PRCUNIT,"@E 999,999,999.99"))
			@nLin,057 psay "VL.TOTAL: "+AllTrim(Transf(TEMP->ZM_TOTAL,"@E 9,999,999,999,999.99"))
			@nLin,90 psay "COND.PAG.: "+TEMP->ZM_CONDPAG
			
			nLin++
			
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC("* * *  A D I A N T A M E N T O  * * *",_TAMCOL)
			
			nLin++
			
//			ALIQ.: 999.99%                                    BASE: 999,999,999,999.99         VALOR: 999,999,999.99          VENC.: 99/99/9999
//			GARANTIA: AAAAAAAAAAAAAAAAAAAA  DOC.: AAAAAAAAAAAAAAA  EMIT.: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  VALOR: 999,999,999.99  APLIC.: 999.99%
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay "ALIQ.: "+AllTrim(Transf(TEMP->ZM_ADIANTA,"@E 999.99")+"%")
			@nLin,050 psay "BASE: "+AllTrim(Transf(TEMP->ZM_BSADIAN,"@E 999,999,999,999.99"))
			@nLin,083 psay "VALOR: "+AllTrim(Transf(TEMP->ZM_VLADIAN,"@E 999,999,999.99"))
			@nLin,114 psay "VENC.: "+U_ConvData(TEMP->ZM_VENADIA)
			
			nTotGarantia := 0
			
			if !Empty(TEMP->ZM_GARANTI)
				@++nLin,000 psay "GARANTIA: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_GARANTI,.F.)),Left(SX5->X5_DESCRI,20)," ")
				@nLin,032 psay "DOC.: "+TEMP->ZM_GARDOC
				@nLin,055 psay "EMIT.: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_BCOEMIT,.F.)),Left(SX5->X5_DESCRI,30)," ")
				@nLin,094 psay "VALOR: "+AllTrim(Transf(TEMP->ZM_VLGARAN,"@E 999,999,999.99"))
				@nLin,117 psay "APLIC.: "+AllTrim(Transf(TEMP->ZM_GARAPLI,"@E 999.99")+"%")
				
				nTotGarantia += TEMP->ZM_VLGARAN
			endif
			
			if !Empty(TEMP->ZM_GARANT2)
				@++nLin,000 psay "GARANTIA: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_GARANT2,.F.)),Left(SX5->X5_DESCRI,20)," ")
				@nLin,032 psay "DOC.: "+TEMP->ZM_GARDOC2
				@nLin,055 psay "EMIT.: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_BCOEMI2,.F.)),Left(SX5->X5_DESCRI,30)," ")
				@nLin,094 psay "VALOR: "+AllTrim(Transf(TEMP->ZM_VLGARA2,"@E 999,999,999.99"))
				@nLin,117 psay "APLIC.: "+AllTrim(Transf(TEMP->ZM_GARAPL2,"@E 999.99")+"%")
				
				nTotGarantia += TEMP->ZM_VLGARA2
			endif
			
			if !Empty(TEMP->ZM_GARANT3)
				@++nLin,000 psay "GARANTIA: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_GARANT3,.F.)),Left(SX5->X5_DESCRI,20)," ")
				@nLin,032 psay "DOC.: "+TEMP->ZM_GARDOC3
				@nLin,055 psay "EMIT.: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_BCOEMI3,.F.)),Left(SX5->X5_DESCRI,30)," ")
				@nLin,094 psay "VALOR: "+AllTrim(Transf(TEMP->ZM_VLGARA3,"@E 999,999,999.99"))
				@nLin,117 psay "APLIC.: "+AllTrim(Transf(TEMP->ZM_GARAPL3,"@E 999.99")+"%")
				
				nTotGarantia += TEMP->ZM_VLGARA3
			endif
			
			if !Empty(TEMP->ZM_GARANT4)
				@++nLin,000 psay "GARANTIA: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_GARANT4,.F.)),Left(SX5->X5_DESCRI,20)," ")
				@nLin,032 psay "DOC.: "+TEMP->ZM_GARDOC4
				@nLin,055 psay "EMIT.: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_BCOEMI4,.F.)),Left(SX5->X5_DESCRI,30)," ")
				@nLin,094 psay "VALOR: "+AllTrim(Transf(TEMP->ZM_VLGARA4,"@E 999,999,999.99"))
				@nLin,117 psay "APLIC.: "+AllTrim(Transf(TEMP->ZM_GARAPL4,"@E 999.99")+"%")
				
				nTotGarantia += TEMP->ZM_VLGARA4
			endif
			
			if !Empty(TEMP->ZM_GARANT5)
				@++nLin,000 psay "GARANTIA: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_GARANT5,.F.)),Left(SX5->X5_DESCRI,20)," ")
				@nLin,032 psay "DOC.: "+TEMP->ZM_GARDOC5
				@nLin,055 psay "EMIT.: "+IIf(SX5->(DbSeek(xFilial("SX5")+"OC"+TEMP->ZM_BCOEMI5,.F.)),Left(SX5->X5_DESCRI,30)," ")
				@nLin,094 psay "VALOR: "+AllTrim(Transf(TEMP->ZM_VLGARA5,"@E 999,999,999.99"))
				@nLin,117 psay "APLIC.: "+AllTrim(Transf(TEMP->ZM_GARAPL5,"@E 999.99")+"%")
				
				nTotGarantia += TEMP->ZM_VLGARA5
			endif
			
			if !Empty(nTotGarantia)
				@++nLin,094 psay "TOTAL  "+AllTrim(Transf(nTotGarantia,"@E 999,999,999.99"))
			endif
			
			nLin++
			
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC("* * *  M U L T A  * * *",_TAMCOL)
			
			nLin++
			
//			ALIQ.: 999.99%                                    BASE: 999,999,999,999.99         VALOR: 999,999,999.99          VENC.: 99/99/9999
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay "ALIQ.: "+AllTrim(Transf(TEMP->ZM_MULTA,"@E 999.99")+"%")
			@nLin,050 psay "BASE: "+AllTrim(Transf(TEMP->ZM_BSMULTA,"@E 999,999,999,999.99"))
			@nLin,083 psay "VALOR: "+AllTrim(Transf(TEMP->ZM_VLMULTA,"@E 999,999,999.99"))
			@nLin,114 psay "VENC.: "+U_ConvData(TEMP->ZM_VENMULT)
			
			nLin++
			
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC("* * *  I M P O S T O S   I N C L U S O S  * * *",_TAMCOL)
			
			nLin++
			
//			                     ALIQUOTA                        VALOR   OBSERVACOES
//			ICMS                  999.99%               999,999,999.99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			PIS                   999.99%               999,999,999.99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			COFINS                999.99%               999,999,999.99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			ISS                   999.99%               999,999,999.99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			TOTAL DOS IMPOSTOS                       99,999,999,999.99
//			VALOR S/ ICMS/PIS/COFINS/ISS/IPI      9,999,999,999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay "                     ALIQUOTA                        VALOR   OBSERVACOES"
			@++nLin,000 psay "ICMS"
			@nLin,022 psay Transf(TEMP->ZM_ALQICMS,"@E 999.99")+"%"
			@nLin,044 psay Transf(TEMP->ZM_VALICMS,"@E 999,999,999.99")
			@nLin,061 psay TEMP->ZM_OBSICMS
			@++nLin,000 psay "PIS"
			@nLin,022 psay Transf(TEMP->ZM_ALQPIS,"@E 999.99")+"%"
			@nLin,044 psay Transf(TEMP->ZM_VALPIS,"@E 999,999,999.99")
			@nLin,061 psay TEMP->ZM_OBSPIS
			@++nLin,000 psay "COFINS"
			@nLin,022 psay Transf(TEMP->ZM_ALQCOF,"@E 999.99")+"%"
			@nLin,044 psay Transf(TEMP->ZM_VALCOF,"@E 999,999,999.99")
			@nLin,061 psay TEMP->ZM_OBSCOF
			@++nLin,000 psay "ISS"
			@nLin,022 psay Transf(TEMP->ZM_ALQISS,"@E 999.99")+"%"
			@nLin,044 psay Transf(TEMP->ZM_VALISS,"@E 999,999,999.99")
			@nLin,061 psay TEMP->ZM_OBSISS
			@++nLin,000 psay "TOTAL DOS IMPOSTOS"
			@nLin,041 psay Transf(TEMP->(ZM_VALICMS + ZM_VALPIS + ZM_VALCOF + ZM_VALISS),"@E 99,999,999,999.99")
			@++nLin,000 psay "VALOR S/ ICMS/PIS/COFINS/ISS/IPI"
			@nLin,038 psay Transf(TEMP->(ZM_TOTAL - ZM_VALICMS - ZM_VALPIS - ZM_VALCOF - ZM_VALISS),"@E 9,999,999,999,999.99")
			
			nLin++
			
//			@nLin,000 psay Replicate("-",_TAMCOL)
//			@++nLin,000 psay PadC("* * *  VALOR LIQUIDO S/ ICMS/PIS/COFINS/ISS/IPI  * * *",_TAMCOL)
			
//			nLin++
			
//			TOTAL....: 9,999,999,999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
//			@nLin,000 psay "TOTAL....: "+AllTrim(Transf(TEMP->(ZM_TOTAL - ZM_VALICMS - ZM_VALPIS - ZM_VALCOF - ZM_VALISS - ZM_VALIPI),"@E 9,999,999,999,999.99"))
			
//			nLin++
			
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC("* * *  I M P O S T O S   A   I N C L U I R  * * *",_TAMCOL)
			
			nLin++
			
//			                     ALIQUOTA                        VALOR   OBSERVACOES
//			IPI                   999.99%               999,999,999.99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//			N.C.M.: 9999.99.99
//			VALOR C/ ICMS/PIS/COFINS/ISS/IPI      9,999,999,999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay "                     ALIQUOTA                        VALOR   OBSERVACOES"
			@++nLin,000 psay "IPI"
			@nLin,022 psay Transf(TEMP->ZM_ALQIPI,"@E 999.99")+"%"
			@nLin,044 psay Transf(TEMP->ZM_VALIPI,"@E 999,999,999.99")
			@nLin,061 psay TEMP->ZM_OBSIPI
			@++nLin,000 psay "N.C.M.: "+Transf(TEMP->ZM_NCM,"@R 9999.99.99")
			@++nLin,000 psay "VALOR C/ ICMS/PIS/COFINS/ISS/IPI"
			@nLin,038 psay Transf(TEMP->ZM_TOTALG,"@E 9,999,999,999,999.99")
			
			nLin++
			
//			@nLin,000 psay Replicate("-",_TAMCOL)
//			@++nLin,000 psay PadC("* * *  VALOR TOTAL C/ ICMS/PIS/COFINS/ISS/IPI  * * *",_TAMCOL)
			
//			nLin++
			
//			TOTAL....: 9,999,999,999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
//			@nLin,000 psay "TOTAL....: "+AllTrim(Transf(TEMP->ZM_TOTALG,"@E 9,999,999,999,999.99"))
			
//			nLin++
			
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC("* * *  R E T E N C A O  * * *",_TAMCOL)
			
			nLin++
			
//			                     ALIQUOTA                       BASE                    VALOR             VENCIMENTO
//			ADIANTAMENTO          999.99%         999,999,999,999.99           999,999,999.99             99/99/9999
//			DATABOOK              999.99%         999,999,999,999.99           999,999,999.99             99/99/9999
//			GARANTIA EQUIP.       999.99%         999,999,999,999.99           999,999,999.99             99/99/9999
//			T O T A L                                                       99,999,999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay "                     ALIQUOTA                       BASE                    VALOR             VENCIMENTO"
			@++nLin,000 psay "ADIANTAMENTO"
			@nLin,022 psay Transf(TEMP->ZM_ADIANTA,"@E 999.99")+"%"
			@nLin,038 psay Transf(TEMP->ZM_BSADIAN,"@E 999,999,999,999.99")
			@nLin,067 psay Transf(TEMP->ZM_VLADIAN,"@E 999,999,999.99")
			@nLin,094 psay U_ConvData(TEMP->ZM_VENADIA)
			@++nLin,000 psay "DATABOOK"
			@nLin,022 psay Transf(TEMP->ZM_PERCDB,"@E 999.99")+"%"
			@nLin,038 psay Transf(TEMP->ZM_BSDATAB,"@E 999,999,999,999.99")
			@nLin,067 psay Transf(TEMP->ZM_VLDB,"@E 999,999,999.99")
			@nLin,094 psay U_ConvData(TEMP->ZM_VENDB)
/*			@++nLin,000 psay "GARANTIA EQUIP."
			@nLin,022 psay Transf(TEMP->ZM_PERCGAR,"@E 999.99")+"%"
			@nLin,038 psay Transf(TEMP->ZM_BSGARAN,"@E 999,999,999,999.99")
			@nLin,067 psay Transf(TEMP->ZM_VLGARAN,"@E 999,999,999.99")
			@nLin,094 psay U_ConvData(TEMP->ZM_VENGARA)*/
			@++nLin,000 psay "T O T A L"
			@nLin,067 psay Transf(TEMP->(ZM_VLADIAN + ZM_VLDB + ZM_VLGARAN),"@E 999,999,999.99")
			
			nLin++
			
			@nLin,000 psay Replicate("-",_TAMCOL)
			@++nLin,000 psay PadC("* * *  M O D E L O  D E  N F  * * *",_TAMCOL)
			
			nLin++
			
//			IT TES CFOP DESCRICAO              DESTINATARIO          CNPJ                ENDERECO
//			99 999 9999 AAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAA  99.999.999/9999-99  
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay "IT TES CFOP DESCRICAO              DESTINATARIO          CNPJ                ENDERECO"
			
			if !Empty(TEMP->ZM_TES1)
				@++nLin,000 psay "01 "+TEMP->ZM_TES1+" "+IIf(SF4->(DbSeek(xFilial("SF4")+TEMP->ZM_TES1,.F.)),AllTrim(SF4->F4_CF)+" "+SF4->F4_TEXTO," ")
				
				if SA1->(DbSeek(xFilial("SA1")+TEMP->(ZM_T1CLI+ZM_T1LOJ),.F.))
					@nLin,035 psay SA1->A1_NREDUZ
					@nLin,057 psay Transf(SA1->A1_CGC,"@R 99.999.999/999-99")
					@nLin,077 psay AllTrim(SA1->A1_MUN)+"/"+AllTrim(SA1->A1_EST)+" - "+Transf(SA1->A1_CEP,"@R 99999-999")
				endif
				
				U_SaltaFolha()
			endif
			
			if !Empty(TEMP->ZM_TES2)
				@++nLin,000 psay "02 "+TEMP->ZM_TES2+" "+IIf(SF4->(DbSeek(xFilial("SF4")+TEMP->ZM_TES2,.F.)),AllTrim(SF4->F4_CF)+" "+SF4->F4_TEXTO," ")
				
				if SA1->(DbSeek(xFilial("SA1")+TEMP->(ZM_T2CLI+ZM_T2LOJ),.F.))
					@nLin,035 psay SA1->A1_NREDUZ
					@nLin,057 psay Transf(SA1->A1_CGC,"@R 99.999.999/999-99")
					@nLin,077 psay AllTrim(SA1->A1_MUN)+"/"+AllTrim(SA1->A1_EST)+" - "+Transf(SA1->A1_CEP,"@R 99999-999")
				endif

				U_SaltaFolha()
			endif
			
			if !Empty(TEMP->ZM_TES3)
				@++nLin,000 psay "03 "+TEMP->ZM_TES3+" "+IIf(SF4->(DbSeek(xFilial("SF4")+TEMP->ZM_TES3,.F.)),AllTrim(SF4->F4_CF)+" "+SF4->F4_TEXTO," ")
				
				if SA1->(DbSeek(xFilial("SA1")+TEMP->(ZM_T3CLI+ZM_T3LOJ),.F.))
					@nLin,035 psay SA1->A1_NREDUZ
					@nLin,057 psay Transf(SA1->A1_CGC,"@R 99.999.999/999-99")
					@nLin,077 psay AllTrim(SA1->A1_MUN)+"/"+AllTrim(SA1->A1_EST)+" - "+Transf(SA1->A1_CEP,"@R 99999-999")
				endif

				U_SaltaFolha()
			endif
			
			if !Empty(TEMP->ZM_TES4)
				@++nLin,000 psay "04 "+TEMP->ZM_TES4+" "+IIf(SF4->(DbSeek(xFilial("SF4")+TEMP->ZM_TES4,.F.)),AllTrim(SF4->F4_CF)+" "+SF4->F4_TEXTO," ")
				
				if SA1->(DbSeek(xFilial("SA1")+TEMP->(ZM_T3CLI+ZM_T3LOJ),.F.))
					@nLin,035 psay SA1->A1_NREDUZ
					@nLin,057 psay Transf(SA1->A1_CGC,"@R 99.999.999/999-99")
					@nLin,077 psay AllTrim(SA1->A1_MUN)+"/"+AllTrim(SA1->A1_EST)+" - "+Transf(SA1->A1_CEP,"@R 99999-999")
				endif

				U_SaltaFolha()
			endif
			
			if SZN->(DbSeek(xFilial("SZN")+TEMP->ZM_CODIGO,.F.))
//				nLin := 56
				nLin++
				
				U_SaltaFolha()
				
//				nLin--
				
				@nLin,000 psay Replicate("-",_TAMCOL)
				@++nLin,000 psay PadC("* * *  P R O J E T O S  * * *",_TAMCOL)
				
				nLin++
				
				U_SaltaFolha()
				
				@nLin,000 psay "PROJETO DESCRICAO                                                PRODUT           QUANT UN      P.UNIT               TOTAL      VENC"
				
				nLin++
				nQuant := 0
				nTotal := 0
				nPreco := 0
				nContPrc := 0
				
				U_SaltaFolha()
				
				while !SZN->(Eof()) .and. SZN->ZN_CODIGO == TEMP->ZM_CODIGO
//					PROJETO DESCRICAO                                                PRODUT           QUANT UN      P.UNIT               TOTAL      VENC
//					999999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  AAA999  999,999,999.99 AA  999,999.99  999,999,999,999.99  99/99/99
//					PRC MEDIO   999,999,999.99                               T O T A L       999,999,999.99                 999,999,999,999.99
//					012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//					          1         2         3         4         5         6         7         8         9        10        11        12        13
					
					@nLin,000 psay SZN->ZN_PROJETO
					@nLin,008 psay IIf(CTH->(DbSeek(xFilial("CTH")+SZN->ZN_PROJETO,.F.)),Left(CTH->CTH_DESC01,55)," ")
					@nLin,065 psay SZN->ZN_PRODUTO
					@nLin,073 psay Transf(SZN->ZN_QUANT,"@E 999,999,999.99")
					@nLin,088 psay SZN->ZN_UM
					@nLin,092 psay Transf(SZN->ZN_PRCUNIT,"@E 999,999.99")
					@nLin,104 psay Transf(SZN->ZN_TOTAL,"@E 999,999,999,999.99")
					@nLin,124 psay U_ConvData(DToS(SZN->ZN_VENCPRJ),"yy")
					
					nLin++
					nQuant += SZN->ZN_QUANT
					nTotal += SZN->ZN_TOTAL
					nPreco += SZN->ZN_PRCUNIT
					nContPrc++
					
					U_SaltaFolha()
					SZN->(DbSkip())
				enddo
				
				@nLin,000 psay "PRC MEDIO"
				@nLin,012 psay Transf(nPreco / nContPrc,"@E 999,999.99")
				@nLin,057 psay "T O T A L"
				@nLin,073 psay Transf(nQuant,"@E 999,999,999.99")
				@nLin,104 psay Transf(nTotal,"@E 999,999,999,999.99")
			endif
			
			TEMP->(DbSkip())
		enddo
		
/*		nLin += 2
		
		if nLin >= 55
			U_Saltafolha()
			
			nLin--
		else
			nLin += 2
		endif
		
		@nLin,000 psay PadC("        ELABORADO POR                           APROVADO POR        ",130)
		
		nLin += 2
		
		@nLin,000 psay PadC("____________________________            ____________________________",130)
		
		nLin += 2
		
		@nLin,000 psay PadC("       ____/____/____                          ____/____/____       ",130)*/
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
	
	TEMP->(DbCloseArea())
return