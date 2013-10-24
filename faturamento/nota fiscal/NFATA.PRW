/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Emissao da nota fiscal da empresa ATA                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function NFATA(cFI,cNF,cSE)
	private aOrd    	:= {"Nota Fiscal"}
	private aReturn 	:= {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   	:= ""
	private cCabec1  	:= ""
	private cCabec2  	:= ""
	private cDesc1  	:= "Nota Fiscal ATA"
	private cDesc2  	:= ""
	private cDesc3  	:= ""
	private cString 	:= "SF2"
	private m_pag   	:= 1
	private lDic		:= .F.
	private lComp		:= .T.
	private lFiltro		:= .F.
	private nOrdem  	:= 0
	private nTipo   	:= 15
	private limite		:= 132
	private nTamanho 	:= "M"
	private cTitulo  	:= cDesc1
	private wnrel   	:= "NFATA"
	private nComp		:= If(aReturn[4]==1,15,18)
	private lAborta 	:= .T.
	
	private aCliente 	:= {}
	private aNF 		:= {}
	private aFatura		:= {}
	private aPedVenda	:= {}
	private aTransp		:= {}
	private aItemNF		:= {}
	private aNcm		:= {}
	private aTes		:= {}
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.T.)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	
	cNotaInic := cNF
	cSerieInic := cSE
	
	if nLastKey == 27 ; return ; endif
	
	Processa({|| GravaDados()},"Aguarde........","Gravando Dados")
	RptStatus({|| Imprime()})
	
	SetPgEject(.F.)
	set device to screen
	
	if aReturn[5] == 1
		set printer to
		DbCommitAll()
		OurSpool(wnrel)
	endif
	
	Ms_Flush()
return

static function GravaDados()
	DbSelectArea("SF2")
	DbSeek(xFilial("SF2")+cNotaInic+cSerieInic,.F.)
	
	AAdd(aNF,{SF2->F2_DOC,;
				SF2->F2_SERIE,;
				SF2->F2_EMISSAO,;
				SF2->F2_DTENTR,;
				SF2->F2_HORA,;
				SF2->F2_CLIENTE,;
				SF2->F2_LOJA,;
				SF2->F2_VALBRUT,;
				SF2->F2_COND,;
				SF2->F2_VALICM,;
				SF2->F2_BASEICM,;
				SF2->F2_VALIPI,;
				SF2->F2_FRETE,;
				SF2->F2_VALMERC,;
				SF2->F2_VALBRUT,;
				SF2->F2_TRANSP})
	
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+aNF[1][1]+aNF[1][2],.F.)
	
	nNcmCont := 0
	
	while SD2->D2_DOC == aNF[1][1] .and. SD2->D2_SERIE == aNF[1][2]
		DbSelectArea("SC6")
		DbSetOrder(10)
		DbSeek(xFilial("SC6")+aNF[1][1]+aNF[1][2]+SD2->D2_ITEMPV,.F.)
		
		cDescri := AllTrim(SC6->C6_DESCRI)
		
		DbSelectArea("SD2")
		
		cNcm := If(SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD,.F.)),AllTrim(SB1->B1_POSIPI),"")
		
		if (nInd := AScan(aNcm,{|x| x[1] = cNcm})) == 0
			nNcmCont++
			nIDNcm := nNcmCont
			
			AAdd(aNcm,{cNcm,nNcmCont})
		else
			nIDNcm := aNcm[nInd][2]
		endif
		
		if (nInd := AScan(aTes,{|x| x[1] = SD2->D2_TES})) == 0
			AAdd(aTes,{SD2->D2_TES,;
						If(SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES,.F.)),AllTrim(SF4->F4_TEXTO),""),;
						AllTrim(SD2->D2_CF)})
		endif
		
		AAdd(aItemNF,{SD2->D2_COD,;
						cDescri,;
						nIDNcm,;
						SD2->D2_CLASFIS,;
						SD2->D2_UM,;
						SD2->D2_QUANT,;
						SD2->D2_PRCVEN,;
						SD2->D2_TOTAL,;
						SD2->D2_PICM,;
						SD2->D2_IPI,;
						SD2->D2_VALIPI,;
						SD2->D2_TES})
		
		SD2->(DbSkip())
	enddo
	
	DbSelectArea("SC5")
	DbSetOrder(8)
	DbSeek(xFilial("SC5")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
	
	AAdd(aPedVenda,{SC5->C5_PROJETO,;
					SC5->C5_NUM,;
					SC5->C5_PLACA,;
					SC5->C5_UFPLACA,;
					SC5->C5_AF,;
					SC5->C5_CLIENTE,;
					SC5->C5_LOJACLI,;
					SC5->C5_MENNOTA,;
					SC5->C5_MENNOT2,;
					SC5->C5_MENNOT3,;
					SC5->C5_VOLUME1,;
					SC5->C5_ESPECI1,;
					SC5->C5_PESOL,;
					SC5->C5_TPFRETE})
	
	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+aNF[1][6]+aNF[1][7],.F.)
	
	AAdd(aCliente,{SA1->A1_NOME,;
					SA1->A1_CGC,;
					SA1->A1_END,;
					SA1->A1_BAIRRO,;
					SA1->A1_CEP,;
					SA1->A1_MUN,;
					SA1->(AllTrim(A1_DDD)+AllTrim(A1_TEL)),;
					SA1->A1_EST,;
					SA1->A1_INSCR})
	
	DbSelectArea("SE1")
	DbSeek(xFilial("SE1")+aNF[1][2]+aNF[1][1],.F.)
	
	while SE1->E1_NUM == aNF[1][1]
		AAdd(aFatura,{SE1->E1_NUM,;
						SE1->E1_PREFIXO,;
						SE1->E1_PARCELA,;
						SE1->E1_VALOR,;
						SE1->E1_VENCTO})
		
		SE1->(DbSkip())
	enddo
	
	DbSelectArea("SA4")
	DbSeek(xFilial("SA4")+aNF[1][16],.F.)
	
	AAdd(aTransp,{SA4->A4_INSEST,;
					SA4->A4_NOME,;
					SA4->A4_CGC,;
					SA4->A4_END,;
					SA4->A4_MUN,;
					SA4->A4_EST})
return
	
static function Imprime()
	@Prow(),000 psay U_L8PolOn(.T.)
	@Prow(),000 psay U_Reduz(4)
	@Prow(),000 psay Chr(27)+"88"
	
	@Prow()+3,088 psay "X"
	@Prow()  ,122 psay aNF[1][1]
	
	if Len(aTes) > 1
		@Prow()+6,001 psay aTes[1][2]+"/"+aTes[2][2]
		@Prow()  ,046 psay aTes[1][3]+"/"+aTes[2][3]
	else
		@Prow()+6,001 psay aTes[1][2]
		@Prow()  ,046 psay aTes[1][3]
	endif
	
	/* *** DESTINATARIO / REMETENTE *** */
	@Prow()+3,001 psay aCliente[1][1]
	@Prow()  ,088 psay aCliente[1][2] picture "@R 99.999.999/9999-99"
	@Prow()  ,119 psay U_ConvData(DToS(aNF[1][3]))
	@Prow()+2,001 psay aCliente[1][3]
	@Prow()  ,058 psay aCliente[1][4]
 	@Prow()  ,097 psay aCliente[1][5] picture "@R 99999-999"
	@Prow()  ,119 psay U_ConvData(DToS(aNF[1][4]))
	@Prow()+2,001 psay aCliente[1][6]
	@Prow()  ,053 psay If(!Empty(aCliente[1][7]),Transf(aCliente[1][7],"@R (999)9999-9999")," ")
	@Prow()  ,080 psay aCliente[1][8]
	@Prow()  ,086 psay aCliente[1][9]
	@Prow()  ,119 psay aNF[1][5]
	
	m_ext1 := " " ; m_ext2 := " " ; m_ext := " "
	m_ext := Upper(U_Extenso(aNF[1][8]))
	
	if Len(m_ext) > 74
		m_ext1 := MemoLine(m_ext,74,1)
		m_ext2 := MemoLine(m_ext,74,2)
	else
		m_ext1 := m_ext
		m_ext2 := " "
	endif
	
	/* *** FATURA *** */
	@018,000 psay " "
	
	if Len(aFatura) > 0
		if Len(aFatura) > 5
			for I := 1 to Len(aFatura)                 // desdobramento de duplicatas
				@Prow()+1,001 psay AllTrim(aFatura[1][1])+"/"+aFatura[1][2]
				@Prow()  ,025 psay aFatura[1][4] picture "@E 999,999,999.99"
				@Prow()  ,042 psay aFatura[1][5]
				
				if I = 1
					@Prow(),063 psay aNF[1][9]
				elseif I = 2
					@Prow(),063 psay " "//praca
				elseif I = 3
					@Prow(),063 psay " "//endcobra
				elseif I = 5
					@Prow(),056 psay m_ext1
				elseif I = 6
					@Prow(),056 psay m_ext2
				endif
			next
		elseif Len(aFatura) > 4
			for I := 1 to Len(aFatura)                 // desdobramento de duplicatas
				@Prow()+1,001 psay AllTrim(aFatura[1][1])+"/"+aFatura[1][2]
				@Prow()  ,025 psay aFatura[1][4] picture "@E 999,999,999.99"
				@Prow()  ,042 psay aFatura[1][5]
				
				if I = 1
					@Prow(),063 psay aNF[1][9]
				elseif I = 2   
					@Prow(),063 psay " "//praca
				elseif I = 3
					@Prow(),063 psay " "//endcobra
				elseif I = 5
					@Prow(),056 psay m_ext1 
				endif                 
			next
			
			@Prow()+1,056 psay m_ext2
		elseif Len(aFatura) > 3
			for I := 1 to Len(aFatura)                 // desdobramento de duplicatas
				@Prow()+1,001 psay AllTrim(aFatura[1][1])+"/"+aFatura[1][2]
				@Prow()  ,025 psay aFatura[1][4] picture "@E 999,999,999.99"
				@Prow()  ,042 psay aFatura[1][5]
				
				if I = 1
					@Prow(),063 psay aNF[1][9]
				elseif I = 2
					@Prow(),063 psay " "//praca
				elseif I = 3
					@Prow(),063 psay " "//endcobra
				endif
			next
			
			@Prow()+1,56 psay m_ext1
			@Prow()+1,56 psay m_ext2
		elseif Len(aFatura) > 2
			for I := 1 to Len(aFatura)                 // desdobramento de duplicatas
				@Prow()+1,001 psay AllTrim(aFatura[1][1])+"/"+aFatura[1][2]
				@Prow()  ,025 psay aFatura[1][4] picture "@E 999,999,999.99"
				@Prow()  ,042 psay aFatura[1][5]
				
				if I = 1
					@Prow(),063 psay aNF[1][9]
				elseif I = 2
					@Prow(),063 psay " "//praca
				elseif I = 3
					@Prow()  ,063 psay " "//endcobra
					@Prow()+2,056 psay m_ext1
					@Prow()+1,056 psay m_ext2
				endif
			next
		elseif Len(aFatura) > 1
			for I := 1 to Len(aFatura)                 // desdobramento de duplicatas
				@Prow()+1,001 psay AllTrim(aFatura[1][1])+"/"+aFatura[1][2]
				@Prow()  ,025 psay aFatura[1][4] picture "@E 999,999,999.99"
				@Prow()  ,042 psay aFatura[1][5]
				
				if I = 1
					@Prow(),063 psay aNF[1][9]
				elseif I = 2
					@Prow()  ,063 psay " "//praca
					@Prow()+1,063 psay " "//endcobra
					@Prow()+2,056 psay m_ext1
					@Prow()+1,056 psay m_ext2
				endif
			next
		else
			@Prow()+1,001 psay AllTrim(aFatura[1][1])+"/"+aFatura[1][2]
			@Prow()  ,025 psay aFatura[1][4] picture "@E 999,999,999.99"
			@Prow()  ,042 psay U_ConvData(DToS(aFatura[1][5]))
			@Prow()  ,063 psay aNF[1][9]
			@Prow()+1,063 psay " "//praca
			@Prow()+1,063 psay " "//endcobra
			@Prow()+2,056 psay m_ext1
			@Prow()+1,056 psay m_ext2
		endif
	endif
	
	/* *** DADOS DO PRODUTO *** */
	@027,000 psay " "
	
	for I := 1 to Len(aItemNF)
		@Prow()+1,001 psay aItemNF[I][1]
		@Prow()  ,015 psay MemoLine(aItemNF[I][2],40,1)
		@Prow()  ,058 psay aItemNF[I][3]
		@Prow()  ,063 psay aItemNF[I][4]
		@Prow()  ,069 psay aItemNF[I][5]
		@Prow()  ,073 psay aItemNF[I][6] picture "@E 999,999.99"
		@Prow()  ,087 psay aItemNF[I][7] picture "@E 999,999.99"
		@Prow()  ,102 psay aItemNF[I][8] picture "@E 9,999,999.99"
		@Prow()  ,117 psay aItemNF[I][9] picture "@E 99.9"
		@Prow()  ,123 psay aItemNF[I][10] picture "@E 99"
		@Prow()  ,125 psay aItemNF[I][11] picture "@E 999,999.99"
		
		if MLCount(aItemNF[I][2],40) > 1
			for K := 2 to MLCount(aItemNF[I][2],40)
				@Prow()+1,015 psay MemoLine(aItemNF[I][2],40,K)
			next
		endif
	next
	
	@044,000 psay " "
	
	m_obs := AllTrim(aPedVenda[1][8])+" "+AllTrim(aPedVenda[1][9])
	m_obs1 := AllTrim(aPedVenda[1][10])
	m_ncm := "1- "+aNcm[1][1]
	
	for I := 2 to Len(aNcm)
		m_ncm += " ; "+Str(I,1)+"- "+aNcm[I][1]
	next
	
	if Len(aNcm) > 2
		@Prow(),001 psay m_ncm
	else
		@Prow(),001 psay " "
	endif
	
	for I := 1 to MLCount(m_obs,130,I)
		@Prow()+1,001 psay MemoLine(m_obs,130,I)
	next
	
	for I := 1 to MLCount(m_obs1,120,I)
		@Prow()+1,001 psay MemoLine(m_obs1,130,I)
	next
	
	/* *** CALCULO DO IMPOSTO *** */
	@052,000 psay " "
	
	@Prow()+1,003 psay If(!Empty(aNF[1][11]),Transf(aNF[1][11],"@E 999,999,999.99")," ")
	@Prow()  ,027 psay If(!Empty(aNF[1][10]),Transf(aNF[1][10],"@E 999,999,999.99")," ")
	@Prow()  ,114 psay If(!Empty(aNF[1][14]),Transf(aNF[1][14],"@E 999,999,999.99")," ")
	@Prow()+2,003 psay If(!Empty(aNF[1][13]),Transf(aNF[1][13],"@E 999,999,999.99")," ")
	@Prow()  ,080 psay If(!Empty(aNF[1][12]),Transf(aNF[1][12],"@E 999,999,999.99")," ")
	@Prow()  ,114 psay If(!Empty(aNF[1][15]),Transf(aNF[1][15],"@E 999,999,999.99")," ")
	
	/* *** TRANSPORTADOR / VOLUMES TRANSPORTADOS *** */
	@056,000 psay " "
	
	@Prow()+2,001 psay aTransp[1][2]
	@Prow()  ,081 psay If(aPedVenda[1][14] == "C","1","2")
	@Prow()  ,088 psay aPedVenda[1][3]
	@Prow()  ,104 psay If(!Empty(aPedVenda[1][3]),aPedVenda[1][4]," ")
	@Prow()  ,109 psay If(!Empty(aTransp[1][3]),Transf(aTransp[1][3],"@R 99.999.999/9999-99")," ")
	@Prow()+2,001 psay If(!Empty(aTransp[1][4]),aTransp[1][4]," ")
	@Prow()  ,068 psay If(!Empty(aTransp[1][5]),aTransp[1][5]," ")
	@Prow()  ,104 psay If(!Empty(aTransp[1][6]),aTransp[1][6]," ")
	@Prow()  ,109 psay If(!Empty(aTransp[1][1]),AllTrim(aTransp[1][1])," ")
	@Prow()+2,005 psay aPedVenda[1][11] picture "@E 999,999.99"
	@Prow()  ,030 psay If(!Empty(aPedVenda[1][12]),aPedVenda[1][12]," ")
	@Prow()  ,055 psay "ATA"
	@Prow()  ,120 psay aPedVenda[1][13] picture "@E 999,999,999.99"
	
	/* *** DADOS ADICIONAIS / INFORMACOES COMPLEMENTARES *** */
	@Prow()+3,017 psay aPedVenda[1][1]
	@Prow()+2,017 psay aPedVenda[1][6]+"/"+aPedVenda[1][7]
	@Prow()+2,017 psay aPedVenda[1][5]
	@Prow()+2,017 psay " "//comprador
	
	if Len(aNcm) == 1
		@Prow()+2,007 psay aNcm[1][1] picture "@R 9999.99.99"
	elseif Len(aNcm) == 2
		@Prow()+2,007 psay aNcm[1][1] picture "@R 9999.99.99"
		@Prow()  ,035 psay aNcm[2][1] picture "@R 9999.99.99"
	else
		@Prow()+2,007 psay " "
	endif
	
	@082,000 psay " "
	
	@Prow(),120 psay aNF[1][1]

	eject
return