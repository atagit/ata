/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Mapa de Coletas                                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#define _FORNECE {"FORNECEDOR","CONTATO","TELEFONE","FAX","CONDICAO PAGAMENTO","A AVISTA (DESCONTO)","PRAZO ENTREGA"}
#define _RODAPE {"TOTAL C/ ICMS S/ IPI","TOTAL S/ ICMS S/ IPI","TOTAL C/ ICMS C/ IPI","TOTAL DESCONTO","TOTAL AV. C/ ICMS C/ IPI","FRETE","TOTAL C/ ICMS C/ IPI","TOTAL AV. C/ ICMS C/ IPI C/ FRETE","TOTAL S/ ICMS S/ IPI S/ PIS S/ COFINS"}
#define _RODAP1 {"FRETE","ICMS(%)","IPI(%)"}
#define _QTDFOR 5
#define _LIMMEM 35

#define _MSKQTD "@E 999,999.99"
#define _MSKVLR "@E 9,999,999,999.99"
#define _MSKIPI "@E 99.99"

user function MPCOLETA()
	private aOrd    	:= {"Cotacao"}
	private aReturn 	:= {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   	:= "MPCOLE"
	private cCabec1  	:= ""
	private cCabec2  	:= ""
	private cDesc1  	:= "MAPA DE COLETAS"
	private cDesc2  	:= ""
	private cDesc3  	:= ""
	private cString 	:= "SC8"
	private m_pag   	:= 1
	private lDic		:= .F.
	private lComp		:= .T.
	private lFiltro		:= .F.
	private nOrdem  	:= 0
	private nTipo   	:= 15
	private limite		:= 132
	private nTamanho 	:= "M"
	private cTitulo  	:= cDesc1
	private wnrel   	:= "MPCOLE"
	private nComp		:= If(aReturn[4]==1,15,18)
	private lAborta 	:= .T.
	
	private cQry    	:= ""
	private cQry1   	:= ""
	private aEmp		:= {}
	private aDesc		:= {}
	private cCotacao	:= ""
	private nPosStr 	:= 0
	private nPos		:= 0
	private nCount		:= 0
	private nPag		:= 1
	private aProduto 	:= {}
	private aIpiVal		:= {}
	private aIpiDesc	:= {}
	private aTotal		:= Array(_QTDFOR)
	private aIpi		:= Array(_QTDFOR)
	private aFrete		:= Array(_QTDFOR)
	private aTotIcm		:= Array(_QTDFOR)
	private aTotFret 	:= Array(_QTDFOR)
	private aTot 		:= Array(_QTDFOR)
	private aTotFretIcm := Array(_QTDFOR)
	private aTotGeral 	:= Array(_QTDFOR)
	private cEmpresa	:= SubStr(cNumEmp,1,2)
	
	Pergunte(cPerg,.F.)
	
	AFill(aTotFret,0.00)
	AFill(aTot,0.00)
	AFill(aTotFretIcm,0.00)
	AFill(aTotal,0.00)
	AFill(aIpi,0.00)
	AFill(aDesc,0.00)
	AFill(aFrete,0.00)
  	AFill(aTotIcm,0.00)
	AFill(aTotGeral,0.00)
	
	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDic,aOrd,lComp,nTamanho,lFiltro)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString,,,nTamanho,2)
	nOrdem  := aReturn[8]
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select distinct C8_NUM, C8_PROJET, C8_NUMSC, C8_EMISSAO "
	cQry += "from "+RetSqlName("SC8")+" "
	cQry += "where (C8_NUM between '"+mv_par01+"' and '"+mv_par02+"') and C8_PROJET <> '' and D_E_L_E_T_ <> '*' "
	cQry += "order by C8_NUM"
	
	tcquery cQry New Alias "TEMP"
	DbSelectArea("TEMP")
	
	if nLastKey == 27 ; return ; endif
	
	if !Empty(TEMP->C8_NUM)
		cCotacao := TEMP->C8_NUM
		
		if TEMP->(RecCount()) > 1
			TEMP->(DbGoTop())
			
			cProj := TEMP->C8_PROJET
			
			for i := 2 to TEMP->(RecCount)
				cProj += "/"+TEMP->C8_PROJET
			next
		else
			cProj := TEMP->C8_PROJET
		endif
		
		cCabec1 := "PROJETO: "+U_Negrito(.T.)+cProj+U_Negrito(.F.)+"                SOLICITACAO COMPRA: "+U_Negrito(.T.)+TEMP->C8_NUMSC+U_Negrito(.F.)+"                EMISSAO: "+U_Negrito(.T.)+U_ConvData(TEMP->C8_EMISSAO)+U_Negrito(.F.)
		
		Cbc(cCotacao,cCabec1)
		
		Processa({|| GeraInformacoes()},"Gerando as informações","Aguarde processando...",lAborta)
		Processa({|| ImpForn()},"Fornecedores","Aguarde processando...",lAborta)
		Processa({|| ImpProd()},"Produtos","Aguarde processando...",lAborta)
		Processa({|| ImpRodP()},"Rodape","Aguarde processando...",lAborta)
		Processa({|| Assinaturas()},"Assinatura","Aguarde processando...",lAborta)
		
		set device to screen
		
		if aReturn[5] == 1
			set printer to
			DbCommitAll()
			DbCloseArea()
			OurSpool(wnrel)
		else
			DbCloseArea()
		endif
	else
		MsgBox("Cotacao nao encontrada!","Alerta","ALERT")
		
		TEMP->(DbCloseArea())
	endif
	
	Ms_Flush()
return

static function ImpForn()
	@Prow()+1,000 psay "+=====================================================+====================+====================+====================+====================+====================+"
	
	for a := 1 to Len(_FORNECE)
		@Prow()+1,000 psay "|"
		@Prow()  ,001 psay _FORNECE[a]
		@Prow()  ,054 psay "|"
		
		n := 54
		
		for b := 1 to Len(aEmp)
			if a == 6
				@Prow(),n+1 psay AllTrim(Transf(aEmp[b][a],_MSKIPI))
			else
				@Prow(),n+1 psay aEmp[b][a]
			endif
			
			@Prow(),n+21 psay "|"
			
			n += 21
		next
		
		for j := Len(aEmp)+1 to _QTDFOR
			@Prow(),n+21 psay "|"
			
			n += 21
		next
	next
	
	for b := 2 to Len(_RODAP1)
		@Prow()+1,000 psay "|"
		@Prow()  ,001 psay _RODAP1[b]
		@Prow()  ,054 psay "|"
		
		n := 55
		
		do case
			case b == 2				// ICMS
				for a := 1 to Len(aEmp)
					@Prow(),n psay AllTrim(Transf(If(aTotIcm[a] <> 0,aTotIcm[a],0),_MSKIPI))
					@Prow(),n+20 psay "|"
					
					n += 21
				next
			case b == 3				// IPI
				for a := 1 to Len(aEmp)
//					@Prow(),n psay AllTrim(Transf(If((aIpi[a]) <> 0,aIpi[a],0),_MSKIPI))
					@Prow(),n psay Left(AllTrim(aIpiDesc[AScan(aIpiDesc,{|x| x[1] = aEmp[a][8]})][2]),20)
					@Prow(),n+20 psay "|"
					
					n += 21
				next
		endcase
		
		CompletaQuadro(Len(aEmp),_QTDFOR - 1)
	next
return

static function ImpProd()
	@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
	@Prow()+1,000 psay "|              DESCRICAO              |UN|   QUANT    |        PRECO       |        PRECO       |        PRECO       |        PRECO       |        PRECO       |"
	@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
	
	for i := 1 to nCount step Len(aEmp)
		nLinha := 1
		nCod := aProduto[i][2]
		cProd := AllTrim(nCod)+" - "+if(SB1->(DbSeek(xFilial("SB1")+nCod,.F.)),AllTrim(SB1->B1_DESC),"SEM DESCRICAO")
		
		@Prow()+1,000 psay "|"
		@Prow()  ,001 psay MemoLine(cProd,_LIMMEM,1)
		@Prow()  ,038 psay "|"
		@Prow()  ,039 psay aProduto[i][3]
		@Prow()  ,041 psay "|"
		@Prow()  ,044 psay Transf(aProduto[i][4],_MSKQTD)
		@Prow()  ,054 psay "|"
		
		n := 55
		
		for j := 1 to Len(aEmp)
			@Prow(),n+4 psay Transf(aProduto[i+j-1][5],_MSKVLR)
			@Prow(),n+20 psay "|"
			
			n += 21
		next
		
		CompletaQuadro(Len(aEmp),_QTDFOR - 1)
		
		if MLCount(cProd,_LIMMEM) > 1
			for k := 2 to MLCount(cProd,_LIMMEM)
				nLinha++
				
				@Prow()+1,000 psay "|"
				@Prow()  ,001 psay MemoLine(cProd,_LIMMEM,k)
				@Prow()  ,038 psay "|"
				@Prow()  ,041 psay "|"
				@Prow()  ,054 psay "|"
				
				n := 55
				
				if k = 2
					for j := 1 to Len(aEmp)
						@Prow(),n+4 psay Transf(aProduto[i+j-1][6],_MSKVLR)
						@Prow(),n+20 psay "|"
						
						aTotal[j] += aProduto[i+j-1][6]
						
						n += 21
					next
					
					CompletaQuadro(Len(aEmp),_QTDFOR - 1)
				else
					for y := 1 to _QTDFOR
						@Prow(),n+20 psay "|"
						
						n += 21
					next
				endif
				
				SaltaFolha()
			next
		endif
		
		@Prow()+1,000 psay "|"
		@Prow()  ,010 psay Left(aProduto[i][11],15)
		@Prow()  ,038 psay "|"
		@Prow()  ,041 psay "|"
		@Prow()  ,054 psay "|"
		
		if nLinha < 2
			n := 55
			
			for j := 1 to Len(aEmp)
				@Prow(),n+4 psay Transf(aProduto[i+j-1][6],_MSKVLR)
				@Prow(),n+20 psay "|"
				
				aTotal[j] += aProduto[i+j-1][6]
	 				aTotGeral[j] += aProduto[i+j-1][6] + (aProduto[i+j-1][6] * aIpi[j] / 100)
				
				n += 21
			next
			
			CompletaQuadro(Len(aEmp),_QTDFOR - 1)
		else
			n := 55
			
			CompletaQuadro(1,_QTDFOR)
		endif
		
		cObs := AllTrim(aProduto[i][10])+" - ("+AllTrim(aProduto[i][12])+")"
		
		@Prow()+1,000 psay "|"
		@Prow()  ,001 psay MemoLine(cObs,_LIMMEM,1)
		@Prow()  ,038 psay "|"
		@Prow()  ,041 psay "|"
		@Prow()  ,054 psay "|"
		
		n := 55
		
		CompletaQuadro(1,_QTDFOR)
		
		if MLCount(cObs,_LIMMEM) > 1
			for k := 2 to MLCount(cObs,_LIMMEM)
				nLinha++
				
				@Prow()+1,000 psay "|"
				@Prow()  ,001 psay MemoLine(cObs,_LIMMEM,k)
				@Prow()  ,038 psay "|"
				@Prow()  ,041 psay "|"
				@Prow()  ,054 psay "|"
				
				SaltaFolha()
			next
			
			CompletaQuadro(Len(aEmp),_QTDFOR - 1)
		endif
		
		@Prow()+1,000 psay "|                                     |  |            |                    |                    |                    |                    |                    |"
		
		SaltaFolha()
	next
	
	@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
return

static function ImpRodP()
	if nPag > 1
		while Prow() < 35
			@Prow()+1,000 psay " "
		enddo
		
		@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
	endif
	
	R1(_RODAPE[1],"Transf(aTotal[i],'"+_MSKVLR+"')")
	
	@Prow()+1,000 psay "+-----------------------------------------------------+--------------------+--------------------+--------------------+--------------------+--------------------+"
	R1("VALOR DO ICMS","Transf(aTotal[i] * aTotIcm[i] / 100,'"+_MSKVLR+"')")
	R1(_RODAPE[2],"Transf(aTotal[i] - (aTotal[i] * aTotIcm[i] / 100),'"+_MSKVLR+"')")
	
	@Prow()+1,000 psay "+-----------------------------------------------------+--------------------+--------------------+--------------------+--------------------+--------------------+"
	R1("VALOR DO IPI","Transf(aIpiVal[AScan(aIpiVal,{|x| x[1] = aEmp[i][8]})][2],'"+_MSKVLR+"')")
//	R1("VALOR DO IPI","Transf(aTotal[i] * aIpi[i] / 100,'"+_MSKVLR+"')")
//	R1(_RODAPE[7],"Transf(aTotGeral[i],'"+_MSKVLR+"')")
//	R1(_RODAPE[7],"Transf(aTotal[i] + (aTotal[i] * aIpi[i] / 100),'"+_MSKVLR+"')")
	R1(_RODAPE[7],"Transf(aTotal[i] + aIpiVal[AScan(aIpiVal,{|x| x[1] = aEmp[i][8]})][2],'"+_MSKVLR+"')")
	
	@Prow()+1,000 psay "+-----------------------------------------------------+--------------------+--------------------+--------------------+--------------------+--------------------+"
	R1(_RODAPE[4],"Transf(If(!Empty(aEmp[i][6]),aTotal[i] * aEmp[i][6] / 100,aDesc[i][2]),'"+_MSKVLR+"')")
//	R1(_RODAPE[5],"Transf(aTotal[i] - If(!Empty(aEmp[i][6]),(aTotal[i] * aEmp[i][6] / 100),aDesc[i][2]) + (aTotal[i] * aIpi[i] / 100),'"+_MSKVLR+"')")
	R1(_RODAPE[5],"Transf(aTotal[i] - If(!Empty(aEmp[i][6]),(aTotal[i] * aEmp[i][6] / 100),aDesc[i][2]) + aIpiVal[AScan(aIpiVal,{|x| x[1] = aEmp[i][8]})][2],'"+_MSKVLR+"')")
	
	@Prow()+1,000 psay "+-----------------------------------------------------+--------------------+--------------------+--------------------+--------------------+--------------------+"
	R1("VALOR DO PIS/COFINS","Transf(aTotal[i] * 0.0925,'"+_MSKVLR+"')")
	R1(_RODAPE[9],"Transf(aTotal[i] - (aTotal[i] * aTotIcm[i] / 100) - (aTotal[i] * 0.0925),'"+_MSKVLR+"')")
	
	@Prow()+1,000 psay "+-----------------------------------------------------+--------------------+--------------------+--------------------+--------------------+--------------------+"
	R1(_RODAPE[6],"Transf(if(aFrete[i] <> 0,aFrete[i],0),'"+_MSKVLR+"')")
//	R1(_RODAPE[8],"Transf(aTotGeral[i] + aFrete[i] - (aTotal[i] * aEmp[i][6] / 100),'"+_MSKVLR+"')")
//	R1(_RODAPE[8],"Transf(aTotal[i] + aFrete[i] + (aTotal[i] * aIpi[i] / 100) - (aTotal[i] * aEmp[i][6] / 100),'"+_MSKVLR+"')")
	R1(_RODAPE[8],"Transf(aTotal[i] + aFrete[i] + aIpiVal[AScan(aIpiVal,{|x| x[1] = aEmp[i][8]})][2] - (aTotal[i] * aEmp[i][6] / 100),'"+_MSKVLR+"')")
	
	@Prow()+1,000 psay "+======================================+==============+===================================+=================================+==================================+"
//	@Prow()+1,000 psay '                                                                                                              "O Senhor e meu Pastor e nada me faltara." SL.23:1'
return

static function CompletaQuadro(nIni,nFim)
//	for y := Len(aEmp) to _QTDFOR -1
	for y := nIni to nFim
		@Prow(),n+20 psay "|"
		
		n += 21
	next
return

static function Cbc(cCotacao,cCabec1)
	@000,000 psay U_TamPag(66)+U_Reduz(0)
	
	if cEmpresa == "01"
		@001,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T A"+U_Expande(0)+U_AltCar(12)
	elseif cEmpresa == "02"
		@001,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T F"+U_Expande(0)+U_AltCar(12)
	endif
	
	@001,022 psay U_Expande(5)+"MAPA DE COLETA"+U_Expande(0)
	@001,049 psay U_Expande(5)+"N§ "+cCotacao+U_Expande(0)
	
	if cEmpresa == "01"
		@002,001 psay U_Reduz(5)+"INDUSTRIA   MECANICA"+U_Reduz(0)
	elseif cEmpresa == "02"
		@002,001 psay U_Reduz(5)+"ESTRUTURAS METALICAS"+U_Reduz(0)
	endif
	
	@002,072 psay U_Reduz(4)+" "+U_Reduz(0)
	@003,001 psay U_Super()
	@004,001 psay cCabec1
	
	nLin := 010
return

static function GeraInformacoes()
	DbCloseArea()
	
	cQry := "select distinct C8_FORNECE, C8_LOJA, C8_COND, C8_PRAZO, C8_CONTATO, C8_DESCAV, C8_PICM "
	cQry += "from "+RetSqlName("SC8")+" "
	cQry += "where (C8_NUM between '"+mv_par01+"' and '"+mv_par02+"') and D_E_L_E_T_ <> '*' "
	cQry += "order by C8_FORNECE"
	
	tcquery cQry New Alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	nPos := 1
	
	while !TEMP->(Eof())
		cFor := TEMP->(C8_FORNECE+C8_LOJA)
		
		while !TEMP->(Eof()) .and. cFor == TEMP->(C8_FORNECE+C8_LOJA)
			P01 := IIf(SA2->(DbSeek(xFilial("SA2")+cFor,.F.)),Left(SA2->A2_NREDUZ,20)," ")
			P02 := Left(TEMP->C8_CONTATO,20)
			P03 := IIf(SA2->(DbSeek(xFilial("SA2")+cFor,.F.)),Left(SA2->A2_DDD+" "+SA2->A2_TEL,20)," ")
			P04 := IIf(SA2->(DbSeek(xFilial("SA2")+cFor,.F.)),Left(SA2->A2_DDD+" "+SA2->A2_FAX,20)," ")
			P05 := IIf(SE4->(DbSeek(xFilial("SE4")+TEMP->C8_COND,.F.)),Left(SE4->E4_DESCRI,20)," ")
			P06 := TEMP->C8_DESCAV
			P07 := TEMP->C8_PRAZO
			P08 := TEMP->C8_FORNECE
			P09 := IIf(SA2->(DbSeek(xFilial("SA2")+cFor,.F.)),SA2->A2_EST,"MG")
			P10 := TEMP->C8_PICM
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		AAdd(aEmp,{P01,;			// 01 Fornecedor (nome)
					P02,;			// 02 Contato
					P03,;			// 03 Telefone
					P04,;			// 04 Fax
					P05,;			// 05 Condicao pagamento
					P06,;			// 06 A vista
					P07,;			// 07 Prazo entrega
					P08,;			// 08 Fornecedor (codigo)
					P09})			// 09 Estado
		
		aTotIcm[nPos] := P10		// 10 ICMS
//		AAdd(aTotIcm,P10)
		
		nPos++
	enddo
	
	DbCloseArea()
	
	cQry := "select SC8.C8_NUM, SC8.C8_PRODUTO, SC8.C8_UM, SC8.C8_QUANT, SC8.C8_PRECO, SC8.C8_TOTAL, SC8.C8_COND, SC8.C8_PRAZO, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_CONTATO, SC8.C8_NUMSC, SC8.C8_PROJET, SC8.C8_ALIIPI, SC8.C8_VALIPI, SC8.C8_VALICM, SC8.C8_PICM, SC8.C8_OBS, SB1.B1_MATERIA, SC8.C8_VLDESC, SC8.C8_IDENT "
	cQry += "from "+RetSqlName("SC8")+" SC8 inner join "+RetSqlName("SB1")+" SB1 on (SC8.C8_PRODUTO = SB1.B1_COD) "
	cQry += "where (SC8.C8_NUM between '"+mv_par01+"' and '"+mv_par02+"') and SC8.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	cQry += "order by SC8.C8_PRODUTO, SC8.C8_IDENT, SC8.C8_FORNECE, SC8.C8_LOJA"
//	cQry += "order by SC8.C8_PRODUTO, SC8.C8_FORNECE"
//	cQry += "order by SC8.C8_PRODUTO, SC8.C8_OBS, SC8.C8_FORNECE"
	
	tcquery cQry New Alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	nCount := 1
	nPos := 1
	
	while !TEMP->(Eof())
		nCod := TEMP->C8_PRODUTO
		cObs := TEMP->C8_OBS
		cNumSC := TEMP->C8_NUMSC
		cIdent := TEMP->C8_IDENT
		
//		while nCod == TEMP->C8_PRODUTO .and. cObs == TEMP->C8_OBS
		while !TEMP->(Eof()) .and. nCod == TEMP->C8_PRODUTO .and. cIdent == TEMP->C8_IDENT
			AAdd(aProduto,{nPos,;							// 01
							TEMP->C8_PRODUTO,;				// 02
							TEMP->C8_UM,;					// 03
							TEMP->C8_QUANT,;				// 04
							TEMP->C8_PRECO,;				// 05
							TEMP->C8_TOTAL,;				// 06
							TEMP->C8_PRAZO,;				// 07
							TEMP->C8_ALIIPI,;				// 08
							TEMP->C8_PICM,;					// 09
							TEMP->C8_OBS,;					// 10
							TEMP->B1_MATERIA,;				// 11
							TEMP->C8_PROJET,;				// 12
							TEMP->C8_VLDESC,;				// 13
							TEMP->C8_FORNECE,;				// 14
							TEMP->C8_LOJA})					// 15
//			Alert(nPos)
			aIpi[nPos] := TEMP->C8_ALIIPI
//			AAdd(aIpi,TEMP->C8_ALIIPI)
			
			if (nInd := AScan(aIpiVal,{|x| x[1] = TEMP->(C8_FORNECE+C8_LOJA)})) == 0
				AAdd(aIpiVal,{TEMP->(C8_FORNECE+C8_LOJA),TEMP->C8_VALIPI})
			else
				aIpiVal[nInd][2] += TEMP->C8_VALIPI
			endif
			
			if (nInd := AScan(aIpiDesc,{|x| x[1] = TEMP->(C8_FORNECE+C8_LOJA)})) == 0
				AAdd(aIpiDesc,{TEMP->(C8_FORNECE+C8_LOJA),AllTrim(Str(TEMP->C8_ALIIPI))})
			else
				aIpiDesc[nInd][2] += "/"+AllTrim(Str(TEMP->C8_ALIIPI))
			endif
			
/*			if (nInd := AScan(aDesc,{|x| x[1] = nPos})) == 0
				AAdd(aDesc,{nPos,TEMP->C8_VLDESC})
			else
				aDesc[nInd][2] += TEMP->C8_VLDESC
			endif*/
			
			nPos++
			nCount++
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nPos := 1
	enddo
	
	nPos--
	nCount--
	
	DbCloseArea()
	
	for w := 1 to Len(aEmp)
		nDesc := 0
		
		for j := 1 to Len(aProduto)
			if aEmp[w][8] == aProduto[j][14]
				nDesc += aProduto[j][13]
			endif
		next
		
		if (nInd := AScan(aDesc,{|x| x[1] = w})) == 0
			AAdd(aDesc,{w,nDesc})
		else
			aDesc[nInd][2] += nDesc
		endif
	next
	
	for w := 1 to Len(aEmp)
		cQry1 := "select * "
		cQry1 += "from "+RetSqlName("SZ1")+" "
		cQry1 += "where Z1_FILIAL = '"+xFilial("SZ1")+"' and Z1_COTACAO = '"+cCotacao+"' and Z1_FORNECE = '"+aEmp[w][8]+"' and D_E_L_E_T_ <> '*' "
		
		tcquery cQry1 new alias "TEMP1"
		DbSelectArea("TEMP1")
		
		if !Empty(TEMP1->Z1_VLFRETE)
			aFrete[w] := TEMP1->Z1_VLFRETE
//			AAdd(aFrete,TEMP1->Z1_VLFRETE)
		else
			aFrete[w] := 0
//			AAdd(aFrete,0)
		endif
		
		DbCloseArea()
	next
	
	DbSelectArea("SC1")
	SC1->(DbSeek(xFilial("SC1")+cNumSC,.F.))
	
	if !Empty(SC1->C1_SOLICIT)
		cUsuario := Left(SC1->C1_SOLICIT,20)
	else
		cUsuario := " "
	endif
	
	SC1->(DbCloseArea())
return

static function R1(cTitulo,cCondicao)
	@Prow()+1,000 psay "|"
	@Prow()  ,001 psay cTitulo
	@Prow()  ,054 psay "|"
	
	n := 55
	
	for i := 1 to Len(aEmp)
		@Prow(),n+4 psay &cCondicao
		@Prow(),n+20 psay "|"
		
		n += 21
	next
	
	CompletaQuadro(Len(aEmp),_QTDFOR - 1)
return

static function Assinaturas()
	if cEmpresa == "01"
           @Prow()+1,000 psay '|Para emissao de Nota Fiscal :         |"O Senhor e   |              EMITIDO              |           FINANCEIRO            |              APROVADO            |'
           @Prow()+1,000 psay U_Negrito(.T.)+"|ATA INDUSTRIA MECANICA  LTDA. "+U_Negrito(.F.)+"        | meu pastor   |-----------------------------------|---------------------------------|----------------------------------|"
           @Prow()+1,000 psay "|Av. Pinheiro, 790 - Dist. Industrial  |    e nada    |                                   |                                 |                                  |"
           @Prow()+1,000 psay '|CEP 35.181-607 - Tim¢teo - MG         | me faltar ." |                                   |                                 |                                  |'
           @Prow()+1,000 psay "|E-mail: compras@ata.ind.br            |(Salmos 23:1) |                                   |                                 |                                  |"
           @Prow()+1,000 psay "|CNPJ 07.697.698/0001-95               |              |-----------------------------------|---------------------------------|----------------------------------|"
           @Prow()+1,000 psay "|Insc. Est. 00.103.191.600-92          |              |Por: "+AllTrim(cUsuario)
           @Prow()  ,090 psay "|Em: ______/______/______         |Em: ______/______/______          |"
	elseif cEmpresa == "02"
           @Prow()+1,000 psay '|Para emissao de Nota Fiscal :         |"O Senhor e   |              EMITIDO              |           FINANCEIRO            |              APROVADO            |'
           @Prow()+1,000 psay U_Negrito(.T.)+"|ATF ESTRURURAS METALICAS LTDA."+U_Negrito(.F.)+"        | meu pastor   |-----------------------------------|---------------------------------|----------------------------------|"
           @Prow()+1,000 psay "|AV. Pinheiros, 950 - Limoeiro         |    e nada    |                                   |                                 |                                  |"
           @Prow()+1,000 psay '|CEP 35.181-402 - Tim¢teo - MG         | me faltar ." |                                   |                                 |                                  |'
           @Prow()+1,000 psay "|E-mail: compras@ata.ind.br            |(Salmos 23:1) |                                   |                                 |                                  |"
           @Prow()+1,000 psay "|CNPJ 41.935.313/0001-19               |              |-----------------------------------|---------------------------------|----------------------------------|"
           @Prow()+1,000 psay "|Insc. Est. 687.804.314-0030           |              |Por: "+AllTrim(cUsuario)
           @Prow()  ,090 psay "|Em: ______/______/______         |Em: ______/______/______          |"
	else
           @Prow()+1,000 psay '|Para emissao de Nota Fiscal :         |"O Senhor e   |              EMITIDO              |           FINANCEIRO            |              APROVADO            |'
           @Prow()+1,000 psay U_Negrito(.T.)+"|TESTE.                        "+U_Negrito(.F.)+"        | meu pastor   |-----------------------------------|---------------------------------|----------------------------------|"
           @Prow()+1,000 psay "|AV.                                   |    e nada    |                                   |                                 |                                  |"
           @Prow()+1,000 psay '|CEP 99.999-999 - Tim¢teo - MG         | me faltar ." |                                   |                                 |                                  |'
           @Prow()+1,000 psay "|E-mail:                               |(Salmos 23:1) |                                   |                                 |                                  |"
           @Prow()+1,000 psay "|CNPJ 99.999.999/9999-99               |              |-----------------------------------|---------------------------------|----------------------------------|"
           @Prow()+1,000 psay "|Insc. Est. 999.999.999-9999           |              |Por: "+AllTrim(cUsuario)
           @Prow()  ,090 psay "|Em: ______/______/______         |Em: ______/______/______          |"
	endif
	
	@Prow()+1,000 psay "+======================================+==============+===================================+=================================+==================================+"
return

static function CriaTraba()
	aTempStru := {}
	
	AAdd(aTempStru,{"CODFORN","C",06,0})
	AAdd(aTempStru,{"NOMFORN","C",20,0})
	AAdd(aTempStru,{"CONTATO","C",20,0})
	AAdd(aTempStru,{"FONE","C",20,0})
	AAdd(aTempStru,{"FAX","C",20,0})
	AAdd(aTempStru,{"CONDPGTO","C",20,0})
	AAdd(aTempStru,{"PRAZO","N",05,2})
	AAdd(aTempStru,{"ESTADO","C",02,0})
	AAdd(aTempStru,{"ICMS","N",05,2})
	
	cArqTrab1 := CriaTrab(aTempStru,.T.)
	
	DbUseArea(.T.,,cArqTrab1,"FORN",.F.,.F.)
	IndRegua("FORN",cArqTrab1,"CODFORN+NOMFORN",,,"Selecionando Registros...")
	
	aTempStru := {}
	
	AAdd(aTempStru,{"CODFORN","C",06,0})
	AAdd(aTempStru,{"NOMFORN","C",20,0})
	AAdd(aTempStru,{"CONTATO","C",20,0})
	AAdd(aTempStru,{"FONE","C",20,0})
	AAdd(aTempStru,{"FAX","C",20,0})
	AAdd(aTempStru,{"CONDPGTO","C",20,0})
	AAdd(aTempStru,{"PRAZO","N",05,2})
	AAdd(aTempStru,{"ESTADO","C",02,0})
	AAdd(aTempStru,{"ICMS","N",05,2})
	
	cArqTrab2 := CriaTrab(aTempStru,.T.)
	
	DbUseArea(.T.,,cArqTrab2,"FORN",.F.,.F.)
	IndRegua("FORN",cArqTrab2,"CODFORN+NOMFORN",,,"Selecionando Registros...")
return

static function SaltaFolha()
	if Prow() >= 36
		nPag++
		
		@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
		@Prow()+1,000 psay "|"+Padc("Continua...",158)+"|"
		@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
		
		Cbc(cCotacao,cCabec1)
		ImpForn()
		
		@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
		@Prow()+1,000 psay "|              DESCRICAO              |UN|   QUANT    |        PRECO       |        PRECO       |        PRECO       |        PRECO       |        PRECO       |"
		@Prow()+1,000 psay "+=====================================+==+============+====================+====================+====================+====================+====================+"
	endif
return