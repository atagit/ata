/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 02/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Pedido de compra                                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _MAXTEXTO 60

user function PEDCOM()
	private aOrd    := {"Pedido de Compra"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PEDCOM"
	private Cabec1  := "CODIGO LJ RAZAO SOCIAL                              DDD TELEFONE CONTATO"
	private Cabec2  := ""
	private cDesc1  := "PEDIDO DE COMPRA"
	private ContFun := 0
	private cString := "SC7"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "PEDCOM"
	private lAborta := .T.
	
	private cQry    := ""
	private cUser	:= ""
	private cAprov	:= ""
	private nLin	:= 0
	private nPag	:= 1
	private cAlias 	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cQry := "select * "
	cQry += "from "+RetSqlName("SC7")+" "
	cQry += "where (C7_NUM between '"+mv_par01+"' and '"+mv_par02+"') and D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by C7_NUM"
	endif
	
	TCQuery cQry New Alias "TEMP"
	DbSelectArea("TEMP")
	
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
	local cProd := cCod := cPedCom := cStatus := ""
	local nKg := nTotal := nQuant := nDesct := nFrete := nDespe := 0
	local nTotIcms := nTotIpi := 0
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	while !TEMP->(Eof())
		cPedCom := TEMP->C7_NUM
		
		Cbc(cPedCom,TEMP->C7_USER)
		
		nLin := 011
		
		while cPedCom == TEMP->C7_NUM
			cCod := TEMP->C7_PRODUTO
			
			if SB5->(DbSeek(xFilial("SB5")+cCod,.F.))
				cDescProd := AllTrim(SB5->B5_CEME+" "+SB5->B5_CEME1+" "+SB5->B5_CEME2+" "+SB5->B5_CEME3+" "+SB5->B5_CEME4+" "+SB5->B5_CEME5+" "+SB5->B5_CEME6)
			else
				cDescProd := "SEM DESCRICAO NA TABELA DE COMPLEMENTO (SB5)"
			endif
			
			if SB1->(DbSeek(xFilial("SB1")+cCod,.F.))
				if SB1->B1_TIPO $ "MC/MP"
					if Right(cDescProd,1) == "."
						cDescProd := SubStr(cDescProd,1,Len(cDescProd) - 1)+" E INFORMAR O NUMERO DO CERTIFICADO NO CORPO DA NF."
					else
						cDescProd := cDescProd+" E INFORMAR O NUMERO DO CERTIFICADO NO CORPO DA NF."
					endif
				endif
			endif
			
			cProd := AllTrim(cCod)+" "+cDescProd
			cObs := AllTrim(TEMP->C7_OBS)
			cServ := ConsultaSZY(TEMP->C7_REQUISI)
			
			if !Empty(cServ)
				cProd += Chr(13)+Chr(10)+cServ
			endif
			
//			      QUANT | UN |                       DESCRICAO                              |   PROJ |    P.UNIT. |      P.TOTAL | ICMS% |  IPI%
//			  999999.99   AA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999999   999,999.99   9,999,999.99   999.9   999.9
//			01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,002 psay Transf(TEMP->C7_QUANT,"@E 999999.99")
			@nLin,014 psay TEMP->C7_UM
			@nLin,019 psay MemoLine(cProd,_MAXTEXTO,1)
			@nLin,082 psay Left(TEMP->C7_CLVL,6)
			
			if TEMP->C7_PRECO < 0.01
				@nLin,091 psay Transf(TEMP->C7_PRECO,"@E 999.999999")
			else
				@nLin,091 psay Transf(TEMP->C7_PRECO,"@E 999,999.99")
			endif
			
			@nLin,104 psay Transf(TEMP->C7_TOTAL,"@E 9,999,999.99")
			@nLin,119 psay Transf(TEMP->C7_PICM,"@E 999.9")
			@nLin,127 psay Transf(TEMP->C7_IPI,"@E 999.9")
			
/*			do case
				case TEMP->C7_CONAPRO == "B"
					@nLin,129 psay "B"		//bloqueado
				case TEMP->C7_CONAPRO == "L"
					if TEMP->C7_QUJE == 0
						@nLin,129 psay "L"	//liberado
					elseif TEMP->C7_QUJE == TEMP->C7_QUANT
						@nLin,129 psay "A"	//atendido
					else
						@nLin,129 psay "P"	//parcialmente
					endif
			endcase*/
			
			if MLCount(cProd,_MAXTEXTO) > 1
				for k := 2 to MLCount(cProd,_MAXTEXTO)
					nLin++
					
					if k == 2
						if TEMP->C7_QUJE > 0 .and. TEMP->C7_QUJE < TEMP->C7_QUANT .and. TEMP->C7_RESIDUO <> "S"
							@nLin,002 psay Transf(TEMP->C7_QUANT - TEMP->C7_QUJE,"@E 999999.99")
							@nLin,014 psay TEMP->C7_UM
							@nLin,019 psay MemoLine(cProd,_MAXTEXTO,k)
//							@nLin,129 psay "F"	//falta
						else
							@nLin,019 psay MemoLine(cProd,_MAXTEXTO,k)
						endif
					else
						@nLin,019 psay MemoLine(cProd,_MAXTEXTO,k)
					endif
				next
				
				if !Empty(cObs)
					nLin++
					@nLin,019 psay MemoLine(cObs,_MAXTEXTO,1)
				endif
			else
				nLin++
				
				if TEMP->C7_QUJE > 0 .and. TEMP->C7_QUJE < TEMP->C7_QUANT .and. TEMP->C7_RESIDUO <> "S"
					@nLin,002 psay Transf(TEMP->C7_QUANT - TEMP->C7_QUJE,"@E 999999.99")
					@nLin,014 psay TEMP->C7_UM
					@nLin,019 psay MemoLine(cObs,_MAXTEXTO,1)
//					@nLin,129 psay "F"	//falta
				else
					@nLin,019 psay MemoLine(cObs,_MAXTEXTO,1)
				endif
			endif
			
			if MLCount(cObs,_MAXTEXTO) > 1
				for k := 2 to MLCount(cObs,_MAXTEXTO)
					nLin++
					
					@nLin,019 psay MemoLine(cObs,_MAXTEXTO,k)
				next
			endif
			
			nLin++
			
			@nLin,001 psay replicate("-",132)
			
			nLin++
			
			if TEMP->C7_UM == "KG"
				nKg += TEMP->C7_QUANT
			endif
			
			nTotal += TEMP->C7_TOTAL
			nFrete := Frete(TEMP->C7_NUM,TEMP->C7_FORNECE,TEMP->C7_LOJA)
			nQuant += TEMP->C7_QUANT
			nDesct += TEMP->C7_VLDESC
			nDespe += TEMP->C7_DESPESA
			nTotIcms += TEMP->C7_VALICM
			nTotIpi += TEMP->C7_VALIPI
			cStatus := TEMP->C7_CONAPRO
			cUser := TEMP->C7_USER
			
			if nLin > 43
				nPag++
				
				Cbc(cPedCom,TEMP->C7_USER)
			endif
			
			IncProc()
			TEMP->(DbSkip())
			
			cCod := "" ; cProd := "" ; cObs := ""
		enddo
		
		Rdp(nQuant,nTotal,nFrete,nDesct,nDespe,nKg,cStatus,nTotIcms,nTotIpi)
		
		nTotal := 0 ; nFrete := 0 ; nQuant := 0 ; nDesct := 0 ; nDespe := 0 ; cStatus := "" ; cUser := ""
		nTotIcms := 0 ; nTotIpi := 0
	enddo
	
	TEMP->(DbCloseArea())
return

static function Cbc(cPedido,cUsuario)
	@000,000 psay U_TamPag(66)+U_Reduz(0)
	
	do case
		case cEmpresa == "01"
			@001,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T A"+U_Expande(0)+U_AltCar(12)
		case cEmpresa == "02"
			@001,001 psay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T F"+U_Expande(0)+U_AltCar(12)
	endcase
	
	@001,020 psay U_Expande(5)+"PEDIDO DE COMPRA"+U_Expande(0)
	@001,046 psay U_Expande(5)+"N§ "+cPedido+" "+TEMP->C7_CONAPRO+U_Expande(0)
	
	do case
		case cEmpresa == "01"
			@002,001 psay U_Reduz(5)+"INDUSTRIA   MECANICA"+U_Reduz(0)
		case cEmpresa == "02"
			@002,001 psay U_Reduz(5)+"ESTRUTURAS METALICAS"+U_Reduz(0)
	endcase
	
	cAlias := Alias()
	nIQF := 0
	
	DbSelectArea("SZY")
	SZV->(DbSetOrder(4))
	
	if SZV->(DbSeek(xFilial("SZV")+TEMP->C7_FORNECE+TEMP->C7_LOJA,.F.))
		while !SZV->(Eof()) .and. SZV->ZV_FORNECE == TEMP->C7_FORNECE .and. SZV->ZV_LOJA == TEMP->C7_LOJA
			if SZV->ZV_USADO == "S"
				nIQF := SZV->ZV_VALIQF
			endif
			
			SZV->(DbSkip())
		enddo
	endif
	
	DbSelectArea("SY1")
	DbSetOrder(3)
	DbSeek(xFilial("SY1")+cUsuario,.F.)
	
	cComprador := AllTrim(Left(SY1->Y1_NOME,20))
	
	SY1->(DbCloseArea())
	
	cQry := "select sum(C7_VLDESC) as C7_VLDESC, sum(C7_DESPESA) as C7_DESPESA "
	cQry += "from "+RetSqlName("SC7")+" "
	cQry += "where C7_NUM = '"+cPedido+"' and D_E_L_E_T_ <> '*' "
	
	TCQuery cQry New Alias "CON"
	DbSelectArea("CON")
	
	@002,085 psay U_Reduz(5)+"Pag. "+StrZero(nPag,3)+U_Reduz(0)
	@002,072 psay U_Reduz(4)+" "+U_Reduz(0)
	
	nLin := 003
	
	@nLin  ,000 psay U_15Cpi(.T.)
	@nLin+1,002 psay "Fornecedor : "+TEMP->C7_FORNECE+" "+IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(C7_FORNECE+C7_LOJA),.F.)),SA2->A2_NREDUZ,"")+" ("+AllTrim(Str(nIQF))+"%)"
	@nLin+1,060 psay "Telefone : "+IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(C7_FORNECE+C7_LOJA),.F.)),SA2->A2_DDD+" "+Transf(SA2->A2_TEL,"@R 9999-9999"),"")
	@nLin+1,103 psay U_Negrito(.T.)+"Emissao  : "+U_ConvData(TEMP->C7_EMISSAO)+U_Negrito(.F.)
	@nLin+2,002 psay "Contato    : "+IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(C7_FORNECE+C7_LOJA),.F.)),SA2->A2_CONTATO,"")
	@nLin+2,060 psay "Fax      : "+IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(C7_FORNECE+C7_LOJA),.F.)),SA2->A2_DDD+" "+Transf(SA2->A2_FAX,"@R 9999-9999"),"")
	@nLin+2,103 psay U_Negrito(.T.)+"Comprad. : "+cComprador+U_Negrito(.F.)
	@nLin+3,002 psay "E-mail     : "+IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(C7_FORNECE+C7_LOJA),.F.)),AllTrim(SA2->A2_EMAIL),"")
	@nLin+3,060 psay "Cd Pagto : "+IIf(TEMP->C7_COND == "998"," ",IIf(SE4->(DbSeek(xFilial("SE4")+TEMP->C7_COND,.F.)),SE4->E4_DESCRI,""))
	@nLin+3,103 psay "Desconto : "+Transf(CON->C7_VLDESC,"@E 999,999.99")
	@nLin+4,002 psay "Loc Entrg  : "+IIf(Empty(TEMP->C7_LCLENTR),Space(20),AllTrim(TEMP->C7_LCLENTR)+Space(20 - Len(AllTrim(TEMP->C7_LCLENTR))))
	@nLin+4,060 psay "Pz Entreg: "+IIf(TEMP->C7_COND == "998"," ",U_ConvData(TEMP->C7_DATPRF))
	@nLin+4,103 psay "Despesas : "+Transf(CON->C7_DESPESA,"@E 999,999.99")
	
	nLin := 009
	
//	@nLin  ,007 psay "QUANT | UN |                       DESCRICAO                              |   PROJ |    P.UNIT. |  IPI% |      P.TOTAL | STS"
	@nLin  ,006 psay "QUANT | UN |                       DESCRICAO                              |   PROJ |    P.UNIT. |      P.TOTAL | ICMS% |  IPI%"
	@nLin+1,001 psay Replicate("-",132)
	
	nLin := 011
	
	CON->(DbCloseArea())
	DbSelectArea(cAlias)
return

static function Rdp(nQuant,nTotal,nFrete,nDesct,nDespe,nKg,cStatus,nTotIcms,nTotIpi)
//	  QUANT   999,999.99    QUANT KG   999,999.99    PRECO MEDIO   999,999.99    DESC   999,999.99      TOTAL C/ ICMS   99,999,999.99
//	  TOTAL ICMS   999,999.99                    TOTAL IPI   999,999.99                          TOTAL C/ ICMS C/ IPI   99,999,999.99
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@044,001 psay Replicate("-",132)
	@045,002 psay "QUANT"
	@045,010 psay Transf(nQuant,"@E 999,999.99")
	
	if nKg > 0
		@045,024 psay "QUANT KG"
		@045,035 psay Transf(nKg,"@E 999,999.99")
		@045,049 psay "PRECO MEDIO"
		@045,063 psay Transf(nTotal / nKg,"@E 999,999.99")
	endif
	
	if !Empty(nDesct)
		@045,077 psay "DESC"
		@045,084 psay Transf(nDesct,"@E 999,999.99")
	endif
	
//	@045,109 psay U_Negrito(.T.)+"TOTAL   "+U_Negrito(.F.)+Transf(nTotal + nDespe - nDesct,"@E 99,999,999.99")
	@045,100 psay "TOTAL C/ ICMS"
	@045,116 psay Transf(nTotal + nDespe + nFrete - nDesct,"@E 99,999,999.99")
	@046,002 psay "TOTAL ICMS"
	@046,015 psay Transf(nTotIcms,"@E 999,999.99")
	@046,045 psay "TOTAL IPI"
	@046,057 psay Transf(nTotIpi,"@E 999,999.99")
//	@046,059 psay U_Negrito(.T.)+"TOTAL C/ ICMS   "+U_Negrito(.F.)+Transf(nTotal + nTotIcms,"@E 99,999,999.99")
	@046,093 psay "TOTAL C/ ICMS C/ IPI"
	@046,116 psay Transf(nTotal + nTotIpi + nDespe + nFrete - nDesct,"@E 99,999,999.99")
	@047,001 psay Replicate("-",132)
	@048,001 psay "VERIFICAR: PRAZO DE ENTREGA, QUANTIDADE E ESPECIFICACAO TECNICA."
	@049,001 psay "OBS.: QUANDO NECESSARIO A "+IIf(cEmpresa == "02","ATF","ATA")+" E/OU CLIENTE REALIZARA INSPECAO DO PRODUTO AINDA NAS INSTALACOES DO FORNECEDOR."
	@050,001 psay "OBS.: FAVOR ENVIAR NOTA FISCAL ELETRONICA PARA: "+U_Negrito(.T.)+"NF@ATA.IND.BR"+U_Negrito(.F.)+"."
	@051,001 psay Replicate("-",132)
	
/*	cAlias := Alias()
	
	DbSelectArea("SM0")
	DbSeek(cEmpresa+xFilial(cString),.F.)
	
	@049,002 psay "Para emissao de Nota Fiscal : "+U_Negrito(.T.)+AllTrim(M0_NOMECOM)+U_Negrito(.F.)+", "+AllTrim(M0_ENDCOB)+" - "+AllTrim(M0_BAIRCOB)+" - "+"CEP "+Transf(M0_CEPCOB,"@R 99.999-999")+" - "+AllTrim(M0_CIDCOB)+"/"+M0_ESTCOB
	@050,002 psay "CNPJ "+Transf(M0_CGC,"@R 99.999.999/9999-99")+" - "+"Insc. Est. "+Transf(M0_INSC,"@R 999.999.999-9999")+" - E-mail: compras@ata.ind.br"
	@051,002 psay Replicate("-",132)
	
	DbSelectArea(cAlias)*/
	
	if cEmpresa == "01"
           @052,001 psay 'Para emissao de Nota Fiscal :     |"O Senhor e   |           EMITIDO          |        FINANCEIRO        |         APROVADO'
           @053,001 psay U_Negrito(.T.)+"ATA INDUSTRIA MECANICA  LTDA. "+U_Negrito(.F.)+"    | meu pastor   |----------------------------|--------------------------|--------------------------"
           @054,001 psay "Av. Pinheiro, 790 - Dist. Ind.    |    e nada    |                            |                          |"
           @055,001 psay 'CEP 35.181-670 - Tim¢teo - MG     | me faltar ." |                            |                          |'
           @056,001 psay "E-mail: compras@ata.ind.br        |(Salmos 23:1) |                            |                          |"
           @057,001 psay "CNPJ 07.697.698/0001-95           |              |----------------------------|--------------------------|--------------------------"
           @058,001 psay "Insc. Est. 00.103.191.600-92      |              |Em: ______/_______/______   |Em: ______/______/______  |Em: ______/______/______  "
	elseif cEmpresa == "02"
           @052,001 psay 'Para emissao de Nota Fiscal :     |"O Senhor e   |           EMITIDO          |        FINANCEIRO        |         APROVADO'
           @053,001 psay U_Negrito(.T.)+"ATF ESTRURURAS METALICAS LTDA."+U_Negrito(.F.)+"    | meu pastor   |----------------------------|--------------------------|--------------------------"
           @054,001 psay "Av. Pinheiros, 950 - Limoeiro     |    e nada    |                            |                          |"
           @055,001 psay 'CEP 35.181-402 - Tim¢teo - MG     | me faltar ." |                            |                          |'
           @056,001 psay "E-mail: compras@ata.ind.br        |(Salmos 23:1) |                            |                          |"
           @057,001 psay "CNPJ 41.935.313/0001-19           |              |----------------------------|--------------------------|--------------------------"
           @058,001 psay "Insc. Est. 687.804.314-0030       |              |Em: ______/_______/______   |Em: ______/______/______  |Em: ______/______/______  "
	else
           @052,001 psay 'Para emissao de Nota Fiscal :     |"O Senhor e   |           EMITIDO          |        FINANCEIRO        |         APROVADO'
           @053,001 psay U_Negrito(.T.)+"TESTE.                        "+U_Negrito(.F.)+"    | meu pastor   |----------------------------|--------------------------|--------------------------"
           @054,001 psay "Av.                               |    e nada    |                            |                          |"
           @055,001 psay 'CEP 99.999-999 - Tim¢teo - MG     | me faltar ." |                            |                          |'
           @056,001 psay "E-mail:                           |(Salmos 23:1) |                            |                          |"
           @057,001 psay "CNPJ 99.999.999/9999-99           |              |----------------------------|--------------------------|--------------------------"
           @058,001 psay "Insc. Est. 999.999.999-9999       |              |Em: ______/_______/______   |Em: ______/______/______  |Em: ______/______/______  "
	endif
	
	@059,001 psay Replicate("-",132)
//	@060,001 psay "Avaliacao Fornecedor:   [   ] Prz. Entr.   [   ] Identif.   [   ] Especif.   [   ] Quantid.   [   ] Certif. do Prod."
	@060,001 psay "AVALIACAO FORNECEDOR:   (   ) Aprovado                      (   ) Reprovado                   (   ) Aceito com restricao"
return

static function Frete(cCotacao,cFornecedor,cLoja)
	local nFrete := 0
	
	cAlias := Alias()
	DbSelectArea("SZ1")
	
	if SZ1->(DbSeek(xFilial("SZ1")+cCotacao+cFornecedor+cLoja,.F.))
		nFrete := SZ1->Z1_VLFRETE
	else
		nFrete := 0
	endif
	
	SZ1->(DbCloseArea())
	
	DbSelectArea(cAlias)
return (nFrete)

static function ConsultaSZY(nRequi)
	local cRet := ""
	
	DbSelectArea("SZY")
	SZY->(DbSetOrder(1))
	
	if SZY->(DbSeek(xFilial("SZY")+nRequi,.F.))
		while !SZY->(Eof()) .and. SZY->ZY_CODIGO == nRequi
			cRet += "- "+AllTrim(SZY->ZY_REQUISI)+Chr(13)+Chr(10)
			
			SZY->(DbSkip())
		enddo
	endif
return(cRet)