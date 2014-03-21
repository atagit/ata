/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/01/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório histórico financeiro de compra              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function HISTCOM()
	private aOrd    := {}
	private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   := "HISCOM"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "HISTORICO DE COMPRAS"
	private ContFun := 0
	private cString := "SE2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
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
	
	private cDtIni := ""
	private cDtFin := ""
	private cForIni := ""
	private cForFin := ""
	private cNFIni:= ""
	private cNFFin := ""
	private cBcoIni := ""
	private cBcoFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
	//³ mv_par05 - Nota Fiscal de                                    ³
	//³ mv_par06 - Nota Fiscal ate                                   ³
	//³ mv_par07 - Banco de                                          ³
	//³ mv_par08 - Banco ate                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cForIni := mv_par03
	cForFin := mv_par04
	cNFIni:= mv_par05
	cNFFin := mv_par06
	cBcoIni := mv_par07
	cBcoFin := mv_par08
	
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
	cQry := "select E2_FORNECE, E2_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, E2_VENCREA, E2_BAIXA, E2_CR, E2_BCOPAG, E2_NUMBCO, E2_VALOR, E2_MULTA, E2_DESCONT, E2_FATURA, E2_FATPREF "
	cQry += "from "+RetSqlName("SE2")+" "
	cQry += "where (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (E2_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (E2_NUM between '"+cNFIni+"' and '"+cNFFin+"') and (E2_BCOPAG between '"+cBcoIni+"' and '"+cBcoFin+"') and E2_FATURA <> 'NOTFAT' and D_E_L_E_T_ <> '*' "
	cQry += "order by E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_NUM, E2_PARCELA"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	SetRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
//	Cabec2 := "NOTA FISCAL   | PARC | EMISSAO  | VENCTO   | BAIXA    | PROT.   | DOCUMEN  | BCO  |          VALOR |      JUROS |    DESCONT | ATRSO"
	
//	NOTA FISCAL   | PARC | EMISSAO  | VENCTO   | BAIXA    | PROT.   | DOCUMEN  | BCO  |          VALOR |      JUROS |    DESCONT | ATRSO
//	999999999-999   999    99/99/99   99/99/99   99/99/99   9999999   AA999999   AAAA   999,999,999.99   999,999.99   999,999.99   9999
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		Cabec2 := ""
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
//		FORNECEDOR: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA (999999-99)                    TIPO FORNECIMENTO: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  PP: 99
//		CONTATO...: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                                             TEL.: 999 99999-9999    CEL.: 999 99999-9999
//		E-MAIL....: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		OBS.......: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		if SA2->(DbSeek(xFilial("SA2")+TEMP->(E2_FORNECE+E2_LOJA),.F.))
			@nLin,000 psay "FORNECEDOR: "+AllTrim(SA2->A2_NREDUZ)+" ("+TEMP->E2_FORNECE+"-"+TEMP->E2_LOJA+")"
			@nLin,074 psay "TIPO FORNECIMENTO: "+SA2->A2_TIPFORN
			@nLin,125 psay "PP:"+SA2->A2_PRIOPAG
			@++nLin,000 psay "CONTATO...: "+AllTrim(SA2->A2_CONTATO)
			@nLin,087 psay "TEL.: "+AllTrim(SA2->A2_DDD)+" "+AllTrim(SA2->A2_TEL)
			@nLin,111 psay "CEL.: "+IIf(!Empty(SA2->A2_CEL),AllTrim(SA2->A2_DDD)+" "+AllTrim(SA2->A2_CEL),"")
			
//			if !Empty(SA2->A2_EMAIL)
				@++nLin,000 psay "E-MAIL....: "+AllTrim(SA2->A2_EMAIL)
//			endif
			
			cObs := AllTrim(SA2->A2_OBSERVA)
			
//			if !Empty(cObs)
				@++nLin,000 psay "OBS.......: "+MemoLine(cObs,120,1)
				
				for k := 2 to MlCount(cObs,120)
					@++nLin,012 psay MemoLine(cObs,120,k)
				next
//			endif
		endif
		
		nLin++
		
		@nLin,000 psay Replicate("=",132)
		@++nLin,000 psay "NOTA FISCAL   | PARC | EMISSAO  | VENCTO   | BAIXA    | PROT.   | DOCUMEN  | BCO  |          VALOR |      JUROS |    DESCONT | ATRSO"
		@++nLin,000 psay Replicate("-",132)
		
		nLin++
		nCont := 0 ; nTotValor := 0 ; nTotMulta := 0 ; nTotDesco := 0
		nTotAberto := 0 ; nContAberto := 0 ; nTotPago := 0 ; nContPago := 0
		cFornecedor := TEMP->(E2_FORNECE+E2_LOJA)
		
		while !TEMP->(Eof()) .and. TEMP->(E2_FORNECE+E2_LOJA) == cFornecedor
			nAtraso := IIf(Empty(TEMP->E2_BAIXA),dDataBase - SToD(TEMP->E2_VENCREA),SToD(TEMP->E2_BAIXA) - SToD(TEMP->E2_VENCREA))
			cBcoPag := TEMP->E2_BCOPAG
			
			@nLin,000 psay TEMP->E2_NUM+"-"+TEMP->E2_PREFIXO
			@nLin,016 psay TEMP->E2_PARCELA
			@nLin,023 psay U_ConvData(TEMP->E2_EMISSAO,"yy")
			@nLin,034 psay U_ConvData(TEMP->E2_VENCREA,"yy")
			@nLin,045 psay U_ConvData(TEMP->E2_BAIXA,"yy")
			@nLin,056 psay Left(TEMP->E2_CR,7)
			
			if !Empty(TEMP->E2_BAIXA)
				if !Empty(TEMP->E2_NUMBCO)
//					cBcoPag := TEMP->E2_BCOPAG
					
					@nLin,066 psay "CH"+Left(TEMP->E2_NUMBCO,6)
				else
					cNum := IIf(Empty(TEMP->E2_FATURA),TEMP->E2_NUM,TEMP->E2_FATURA)
					cPref := IIf(Empty(TEMP->E2_FATURA),TEMP->E2_PREFIXO,TEMP->E2_FATPREF)
//					cQry := "select E2_BCOPAG from "+RetSqlName("SE2")+" where E2_NUM = '"+TEMP->E2_FATURA+"' and E2_PREFIXO = '"+TEMP->E2_FATPREF+"' and E2_FATURA = 'NOTFAT' and D_E_L_E_T_ <> '*'"
					cQry := "select E5_BANCO, E5_NUMTED from "+RetSqlName("SE5")+" where E5_NUMERO = '"+cNum+"' and E5_PREFIXO = '"+cPref+"' and E5_CLIFOR = '"+TEMP->E2_FORNECE+"' and E5_LOJA = '"+TEMP->E2_LOJA+"' and E5_MOTBX = 'DEB' and D_E_L_E_T_ <> '*'"
					
					tcquery cQry new alias "CON"
					
					DbSelectArea("CON")
					
//					cBcoPag := CON->E2_BCOPAG
					
					if !Empty(CON->E5_BANCO)
						cBcoPag := CON->E5_BANCO
						
						@nLin,066 psay "TD"+Right(AllTrim(CON->E5_NUMTED),6)
					endif
					
					CON->(DbCloseArea())
				endif
				
				@nLin,077 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBcoPag,.F.)),SA6->A6_SIGLA," ")
			endif
			
			@nLin,084 psay Transf(TEMP->E2_VALOR,"@E 999,999,999.99")
			@nLin,101 psay Transf(TEMP->E2_MULTA,"@E 999,999.99")
			@nLin,114 psay Transf(TEMP->E2_DESCONT,"@E 999,999.99")
			@nLin,127 psay Transf(nAtraso,"@R 9999")
			
			nLin++
			nCont++
			nTotValor += TEMP->E2_VALOR
			nTotMulta += TEMP->E2_MULTA
			nTotDesco += TEMP->E2_DESCONT
			
			if Empty(cBcoPag)
				nTotAberto += TEMP->E2_VALOR
				nContAberto++
			else
				nTotPago += TEMP->E2_VALOR
				nContPago++
			endif
			
			if U_SaltaFolha()
				@nLin,000 psay Replicate("=",132)
				@++nLin,000 psay "NOTA FISCAL   | PARC | EMISSAO  | VENCTO   | BAIXA    | PROT.   | DOCUMEN  | BCO  |          VALOR |      JUROS |    DESCONT | ATRSO"
				@++nLin,000 psay Replicate("-",132)
				
				nLin++
			endif
			
			IncRegua()
			TEMP->(DbSkip())
		enddo
		
		@nLin,000 psay Replicate("-",132)
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,034 psay "COMPRAS..:"
		@nLin,056 psay Transf(nCont,"@R 999999")
		@nLin,084 psay Transf(nTotValor,"@E 999,999,999.99")
		@nLin,101 psay Transf(nTotMulta,"@E 999,999.99")
		@nLin,114 psay Transf(nTotDesco,"@E 999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,034 psay "PAGAS....:"
		@nLin,056 psay Transf(nContPago,"@R 999999")
		@nLin,084 psay Transf(nTotPago,"@E 999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,034 psay "EM ABERTO:"
		@nLin,056 psay Transf(nContAberto,"@R 999999")
		@nLin,084 psay Transf(nTotAberto,"@E 999,999,999.99")
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
	
	DbSelectArea("TEMP")
return