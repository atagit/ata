/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 21/10/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relação de NF por projeto                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PROJNF()
	private aOrd    := {"Projeto"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PROJNF"
	private Cabec1  := "TIPO | PROTOCOLO | EMISSAO    | NOTA FISCAL   | FORNECEDOR                               |              TOTAL  | PEDIDO"
	private Cabec2  := ""
	private cDesc1  := "NOTAS FISCAIS POR PROJETO"
	private cString := "SD1"
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
	private cRdpLeg	:= "TIPO: (N) - Normal   |   (C) - Conhecimento Frete   |   (D) - Devolução   |   (B) - Beneficiamento"
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cPrjIni := ""
	private cPrjFin := ""
	private nTpDeta := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Projeto de                                        ³
	//³ mv_par02 - Projeto ate                                       ³
	//³ mv_par03 - Detalhado (1-sim/2-nao)                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrjIni := mv_par01
	cPrjFin := mv_par02
	nTpDeta := mv_par03
	
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
	local nTamCR := If(cEmpAnt == "02",6,7)
	local nItem := 0
	local nTotal := 0
	
	cQry := "select D1_TIPO, D1_CLVL, left(D1_CR,"+AllTrim(Str(nTamCR))+") as D1_CR, D1_EMISSAO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, NREDUZ = case when A2_NREDUZ is not null then A2_NREDUZ else A1_NREDUZ end, D1_PEDIDO, sum(D1_TOTAL) as D1_TOTAL "
	cQry += "from "+RetSqlName("SD1")+" SD1 left join "+RetSqlName("SA2")+" SA2 on (D1_FORNECE = A2_COD and D1_LOJA = A2_LOJA) and D1_TIPO not in ('B','D') "
	cQry += "	left join "+RetSqlName("SA1")+" SA1 on (D1_FORNECE = A1_COD and D1_LOJA = A1_LOJA) and D1_TIPO in ('B','D') "
	cQry += "where (D1_CLVL between '"+cPrjIni+"' and '"+cPrjFin+"') and SD1.D1_TIPO not in ('C','D') and SD1.D_E_L_E_T_ <> '*' "
	cQry += "group by D1_TIPO, D1_CLVL, left(D1_CR,"+AllTrim(Str(nTamCR))+"), D1_EMISSAO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, A2_NREDUZ, A1_NREDUZ, D1_PEDIDO "
	
	do case 
		case nOrdem == 1
			cQry += "order by D1_CLVL, NREDUZ, D1_CR"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	while !TEMP->(Eof())
		cCbcRef := U_Negrito(.T.)+AllTrim(TEMP->D1_CLVL)+" - "+If(CTH->(DbSeek(xFilial("CTH")+TEMP->D1_CLVL,.F.)),CTH->CTH_DESC01,"")+U_Negrito(.F.)
		cProj := TEMP->D1_CLVL
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		if nTpDeta == 2
			while cProj == TEMP->D1_CLVL
	
//			TIPO | PROTOCOLO | EMISSAO    | NOTA FISCAL   | FORNECEDOR                               |              TOTAL  | PEDIDO
// 			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11
//			A      9999999     99/99/9999   999999999-999   999999-99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999,999.99    999999
			
				@nLin,000 psay TEMP->D1_TIPO
				@nLin,007 psay Left(TEMP->D1_CR,nTamCR)
				@nLin,019 psay U_ConvData(TEMP->D1_EMISSAO)
				@nLin,032 psay TEMP->D1_DOC+"-"+AllTrim(TEMP->D1_SERIE)
				@nLin,048 psay TEMP->D1_FORNECE+"-"+TEMP->D1_LOJA+" "+TEMP->NREDUZ
				@nLin,091 psay Transf(TEMP->D1_TOTAL,"@E 999,999,999,999.99")
				@nLin,113 psay TEMP->D1_PEDIDO
				
				nTotal += TEMP->D1_TOTAL
				
				nItem++
				nLin++
				
				U_SaltaFolha()
				
				IncProc()
				TEMP->(DbSkip())
			enddo
		else
			while cProj == TEMP->D1_CLVL
	
//			TIPO | PROTOCOLO | EMISSAO    | NOTA FISCAL   | FORNECEDOR                               |              TOTAL
// 			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11
//			A      9999999     99/99/9999   999999999-999   999999-99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999,999.99
//			             999999   UM   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999.999   999999
			
				@nLin,000 psay TEMP->D1_TIPO
				@nLin,007 psay Left(TEMP->D1_CR,nTamCR)
				@nLin,019 psay U_ConvData(TEMP->D1_EMISSAO)
				@nLin,032 psay TEMP->D1_DOC+"-"+AllTrim(TEMP->D1_SERIE)
				@nLin,048 psay TEMP->D1_FORNECE+"-"+TEMP->D1_LOJA+" "+TEMP->NREDUZ
				@nLin,091 psay Transf(TEMP->D1_TOTAL,"@E 999,999,999,999.99")
				@nLin,113 psay TEMP->D1_PEDIDO
				
				nTotal += TEMP->D1_TOTAL
				
				cCon := "select D1_COD, D1_UM, B1_DESC, D1_QUANT "
				cCon += "from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SB1")+" SB1 on (SD1.D1_COD = SB1.B1_COD) "
				cCon += "where D1_DOC = '"+TEMP->D1_DOC+"' and D1_SERIE = '"+TEMP->D1_SERIE+"' and D1_FORNECE = '"+TEMP->D1_FORNECE+"' and D1_LOJA = '"+TEMP->D1_LOJA+"' and D1_CLVL = '"+cProj+"' and SD1.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
				cCon += "order by D1_COD "
				
				tcquery cCon new alias "CON"
				DbSelectArea("CON")
				CON->(DbGoTop())
				
/*				cNota := TEMP->D1_DOC
				cSerie := TEMP->D1_SERIE
				cForn := TEMP->D1_FORNECE
				cLoja := TEMP->D1_LOJA*/
				
//				while !CON->(Eof()) .and. cNota == TEMP->D1_DOC .and. cSerie == TEMP->D1_SERIE .and. cForn == TEMP->D1_FORNECE .and. cLoja == TEMP->D1_LOJA
				while !CON->(Eof())
					nLin++
					
					@nLin,013 psay CON->D1_COD
					@nLin,022 psay CON->D1_UM
					@nLin,027 psay Left(CON->B1_DESC,30)
					@nLin,060 psay Transf(CON->D1_QUANT,"@E 999,999,999.999")
//					@nLin,078 psay CON->D1_PEDIDO
					
					U_SaltaFolha()
					
					CON->(DbSkip())
				enddo
				
				CON->(DbCloseArea())
				
				nItem++
				nLin += 2
				
				U_SaltaFolha()
				
				IncProc()
				TEMP->(DbSkip())
			enddo
		endif
		
		nLin++
		
		@nLin,000 psay "Item(s): "+AllTrim(Str(nItem))
		@nLin,083 psay "TOTAL   "+Transf(nTotal,"@E 999,999,999,999.99")
		
		nTotal := 0
		nItem := 0
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	DbSelectArea("TEMP")
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return