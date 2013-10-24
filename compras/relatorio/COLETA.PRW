/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/04/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de Coleta de Preços                         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _TAMANHO 132
#define _COLFOR 60

user function COLETA()
	private aOrd    := {"Cotacao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELCOL"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "COLETA DE PRECOS"
	private ContFun := 0
	private cString := "SC8"
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
	
	private cCotIni := ""
	private cCotFin := ""
	private cForIni := ""
	private cForFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Cotacao de                                        ³
	//³ mv_par02 - Cotacao ate                                       ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cCotIni := mv_par01
	cCotFin := mv_par02
	cForIni := mv_par03
	cForFin := mv_par04
	
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
	private aFornecedor := Array(5)
	
	cQry := "select C8_NUM, C8_FORNECE, C8_LOJA, C8_CONTATO, C8_PRECO, C8_QUANT, C8_TOTAL, C8_ALIIPI, C8_PICM, C8_UM, C8_PRODUTO, C1_DESCRI, C1_OBS, C1_USER, C1_SOLICIT, B5_CEME, B5_CEME1, B5_CEME2, B5_CEME3, B5_CEME4, B5_CEME5, B5_CEME6 "
	cQry += "from "+RetSqlName("SC8")+" SC8 inner join "+RetSqlName("SC1")+" SC1 on (C8_NUMSC = C1_NUM and C8_ITEMSC = C1_ITEM) "
	cQry += "	inner join "+RetSqlName("SB1")+" SB1 on (B1_COD = C1_PRODUTO and B1_LOCPAD = C1_LOCAL) "
	cQry += "	inner join "+RetSqlName("SB5")+" SB5 on (B5_COD = C8_PRODUTO) "
	cQry += "where (C8_NUM between '"+cCotIni+"' and '"+cCotFin+"') and (C8_FORNECE between '"+cForIni+"' and '"+cForFin+"') and SC8.D_E_L_E_T_ <> '*' and SC1.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SB5.D_E_L_E_T_ <> '*' "
	cQry += "order by C8_NUM, C8_FORNECE, C8_LOJA, C8_ITEM"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cCotacao := TEMP->C8_NUM
		cFornecedor := TEMP->(C8_FORNECE+C8_LOJA)
		cComprador := AllTrim(TEMP->(C1_SOLICIT))
		
		if SA2->(DbSeek(xFilial("SA2")+cFornecedor,.F.))
			aFornecedor[1] := AllTrim(SA2->A2_NREDUZ)
			aFornecedor[2] := AllTrim(SA2->A2_DDD)
			aFornecedor[3] := AllTrim(SA2->A2_TEL)
			aFornecedor[4] := AllTrim(SA2->A2_FAX)
			aFornecedor[5] := AllTrim(SA2->A2_EMAIL)
			
			aFornecedor[2] := Right(aFornecedor[2],2)
			aFornecedor[3] := StrTran(aFornecedor[3],"-","")
			aFornecedor[4] := StrTran(aFornecedor[4],"-","")
		else
			AFill(aFornecedor,0)
		endif
		
		Cabec1 := "COTACAO: "+cCotacao+"        COMPRADOR: "+cComprador+"        FORNECEDOR: "+Transf(cFornecedor,"@R 999999-99")
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
//		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA           AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA              ||AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA              ||FRETE:   [ ] FOB
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay Replicate("=",_TAMANHO)
		@++nLin,000 psay PadC("FORNECEDOR",_COLFOR)
		@nLin,065 psay "||"
		@nLin,073 psay PadC("SOLICITANTE",_COLFOR)
		@++nLin,000 psay PadC(aFornecedor[1],_COLFOR)
		@nLin,065 psay "||"
		@nLin,073 psay PadC(AllTrim(SM0->M0_NOMECOM),_COLFOR)
		@++nLin,000 psay PadC(IIf(!Empty(aFornecedor[3]),"TEL.: "+aFornecedor[2]+" "+Transf(aFornecedor[3],"@R 9999-9999"),"")+" / "+IIf(!Empty(aFornecedor[4]),"FAX.: "+aFornecedor[2]+" "+Transf(aFornecedor[4],"@R 9999-9999"),""),_COLFOR)
		@nLin,065 psay "||"
		@nLin,073 psay PadC("AV. PINHEIRO, 790, LIMOEIRO, TIMOTEO - MG",_COLFOR)
		@++nLin,000 psay IIf(!Empty(TEMP->C8_CONTATO),PadC("CONTATO: "+AllTrim(TEMP->C8_CONTATO),_COLFOR)," ")
		@nLin,065 psay "||"
		@nLin,073 psay PadC("TEL.: 31 3849-9090",_COLFOR)
		@++nLin,000 psay IIf(!Empty(aFornecedor[5]),PadC("E-MAIL: "+Lower(aFornecedor[5]),_COLFOR),"")
		@nLin,065 psay "||"
		@nLin,073 psay PadC("E-MAIL: compras@ata.ind.br",_COLFOR)
		@++nLin,000 psay Replicate("=",_TAMANHO)
		@++nLin,000 psay "Favor fornecer preço, condições de pagamento e prazo de entrega dos itens abaixo relacionado. Informar o preço com todos os impostos"
		@++nLin,000 psay "inclusos, exceto o IPI."
		@++nLin,000 psay Replicate("=",_TAMANHO)
		@++nLin,000 psay "COND. PAG.:"
		@nLin,054 psay "||PRAZO ENTREG.:"
		@nLin,110 psay "||FRETE:"
		@++nLin,054 psay "||"
//		@nLin,110 psay "||  [ ] FOB  [ ] CIF"
		@nLin,110 psay "||"
		@++nLin,000 psay Replicate("=",_TAMANHO)
//		@++nLin,000 psay "IT|        QUANT | UN | DESCRICAO DO PRODUTO                                      |    PRECO   |     TOTAL      |  % ICMS  | % IPI"
		@++nLin,000 psay "IT|        QUANT | UN | DESCRICAO DO PRODUTO                                      |  PRC UNIT  |     TOTAL      |  % ICMS  | % IPI"
		@++nLin,000 psay Replicate("-",_TAMANHO)
		
		nCont := 1
		nTotQuant := 0
		nTotValor := 0
		
		while TEMP->C8_NUM == cCotacao .and. TEMP->(C8_FORNECE+C8_LOJA) == cFornecedor
//			IT|        QUANT | UN | DESCRICAO DO PRODUTO                                      |    PRECO   |     TOTAL      |  % ICMS  | % IPI
//			99| 999999999.99 | AA | AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA | 999,999.99 | 999,999,999.99 |  999.99  | 999.99
//			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			cDescricao := AllTrim(TEMP->C8_PRODUTO)+" - "+AllTrim(B5_CEME)+" "+AllTrim(B5_CEME1)+" "+AllTrim(B5_CEME2)+" "+AllTrim(B5_CEME3)+" "+	AllTrim(B5_CEME4)+" "+AllTrim(B5_CEME5)+" "+AllTrim(B5_CEME6)+Chr(13)+Chr(10)+"OBS.: "+AllTrim(TEMP->C1_OBS)
			
			nLin++
			lVazio := IIf(Empty(TEMP->C8_PRECO),.T.,.F.)
			
			@nLin,000 psay StrZero(nCont,2)
			@nLin,002 psay "|"
			@nLin,004 psay Transf(TEMP->C8_QUANT,"@E 999999999.99")
			@nLin,017 psay "|"
			@nLin,019 psay TEMP->C8_UM
			@nLin,022 psay "|"
			@nLin,024 psay MemoLine(cDescricao,58,1)
			@nLin,082 psay "|"
			@nLin,084 psay IIf(!lVazio,Transf(TEMP->C8_PRECO,"@E 999,999.99")," ")
			@nLin,095 psay "|"
			@nLin,097 psay IIf(!lVazio,Transf(TEMP->C8_TOTAL,"@E 999,999,999.99")," ")
			@nLin,112 psay "|"
			@nLin,115 psay IIf(!lVazio,Transf(TEMP->C8_PICM,"@E 999.99")," ")
			@nLin,123 psay "|"
			@nLin,125 psay IIf(!lVazio,Transf(TEMP->C8_ALIIPI,"@E 999.99")," ")
			
			if MlCount(cDescricao,58) > 1
				for k := 2 to MlCount(cDescricao,58)
					nLin++
					
					@nLin,002 psay "|"
					@nLin,017 psay "|"
					@nLin,022 psay "|"
					@nLin,024 psay MemoLine(cDescricao,58,k)
					@nLin,082 psay "|"
					@nLin,095 psay "|"
					@nLin,112 psay "|"
					@nLin,123 psay "|"
					
					U_SaltaFolha(56)
				next
			endif
			
			@++nLin,000 psay Replicate("-",_TAMANHO)
			
			U_SaltaFolha(56)
			
			nTotQuant += TEMP->C8_QUANT
			nTotValor += IIf(!lVazio,TEMP->C8_TOTAL,0)
			nCont++
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		@++nLin,087 psay "TOTAL"
		@nLin,095 psay "|"
		@nLin,097 psay IIf(!lVazio,Transf(nTotValor,"@E 999,999,999.99")," ")
		@nLin,112 psay "|"
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
return