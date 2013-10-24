/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/03/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Saldo em estoque com estoque minimo e maximo          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function NFITM()
	private aOrd    := {"Nom. Fornecedor"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "NFITM"
	private Cabec1  := "FORNECEDOR/CLIENTE                                                                CNPJ"
	private Cabec2  := "NOTA FISCAL   | TP | ESPEC | EMISSAO    | DIGITACAO  | CFOP |          VALOR |           ICMS |            IPI"
	private cDesc1  := "NF POR ITEM"
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
	private cRdpLeg	:= "(C) - Cliente   |   (F) - Fornecedor"
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cDtIni := ""
	private cDtFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Data Digitacao de                                 ³
	//³ mv_par02 - Data Digitacao ate                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	
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
	local nGeralValor := 0
	local nGeralIcm := 0
	local nGeralIpi := 0
	
	cQry := "select TMP.* "
	cQry += "from ("
	cQry += "		select D1_DOC, D1_SERIE, D1_TIPO, F1_ESPECIE, D1_EMISSAO, D1_DTDIGIT, D1_FORNECE, A2_NOME, A2_CGC, D1_LOJA, D1_CF, D1_TOTAL, D1_VALICM, D1_VALIPI, D1_CONTA, F1_VALBRUT, F1_VALICM, F1_VALIPI, D1_TES "
	cQry += "		from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SF1")+" SF1 on (SD1.D1_DOC = SF1.F1_DOC and SD1.D1_SERIE = SF1.F1_SERIE) inner join "+RetSqlName("SA2")+" SA2 on (SD1.D1_FORNECE = SA2.A2_COD and SD1.D1_LOJA = SA2.A2_LOJA) "
	cQry += "		where (SD1.D1_DTDIGIT between '"+cDtIni+"' and '"+cDtFin+"') and SD1.D1_TIPO <> 'B' and SD1.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' "
	cQry += "		union all "
	cQry += "		select D1_DOC, D1_SERIE, D1_TIPO, F1_ESPECIE, D1_EMISSAO, D1_DTDIGIT, D1_FORNECE, A1_NOME, A1_CGC, D1_LOJA, D1_CF, D1_TOTAL, D1_VALICM, D1_VALIPI, D1_CONTA, F1_VALBRUT, F1_VALICM, F1_VALIPI, D1_TES "
	cQry += "		from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SF1")+" SF1 on (SD1.D1_DOC = SF1.F1_DOC and SD1.D1_SERIE = SF1.F1_SERIE) inner join "+RetSqlName("SA1")+" SA1 on (SD1.D1_FORNECE = SA1.A1_COD and SD1.D1_LOJA = SA1.A1_LOJA) "
	cQry += "		where (SD1.D1_DTDIGIT between '"+cDtIni+"' and '"+cDtFin+"') and SD1.D1_TIPO = 'B' and SD1.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' "
	cQry += ") TMP "
	cQry += "where TMP.D1_CF <> '2302' "
	
	do case 
		case nOrdem == 1
			cQry += "order by A2_NOME, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_CF"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	cCbcRef := Padc("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	while !TEMP->(Eof())
		cCodFor := TEMP->D1_FORNECE
		cCodLoj := TEMP->D1_LOJA
		cCnpj := TEMP->A2_CGC
		cNomFor := TEMP->A2_NOME
		nTotValor := 0 ; nTotIcm := 0 ; nTotIpi := 0
		cTipo := If(TEMP->D1_TIPO $ "B/D","(C)","(F)")
		
		@nLin,000 psay U_Negrito(.T.)+cCodFor+"-"+cCodLoj+" "+cNomFor+" "+Trans(cCnpj,If(Len(cCnpj) = 14,"@R 99.999.999/9999-99","@R 999.999.999-99"))+" - "+cTipo+U_Negrito(.F.)
		
		nLin++
		
		while cCodFor == TEMP->D1_FORNECE .and. cCodLoj == TEMP->D1_LOJA
			cNF := TEMP->D1_DOC
			cSer := TEMP->D1_SERIE
			cCF := TEMP->D1_CF
			cTip := TEMP->D1_TIPO
			cEsp := TEMP->F1_ESPECIE
			nValor := 0 ; nIcm := 0 ; nIpi := 0
			nValor := TEMP->F1_VALBRUT
			
			@nLin,000 psay TEMP->D1_DOC+"/"+TEMP->D1_SERIE
			@nLin,016 psay TEMP->D1_TIPO
			@nLin,021 psay TEMP->F1_ESPECIE
			@nLin,029 psay U_ConvData(TEMP->D1_EMISSAO)
			@nLin,042 psay U_ConvData(TEMP->D1_DTDIGIT)
			@nLin,055 psay TEMP->D1_CF
			
			while cNF == TEMP->D1_DOC .and. cSer == TEMP->D1_SERIE .and. cCF == TEMP->D1_CF .and. cTip == TEMP->D1_TIPO .and. cEsp == TEMP->F1_ESPECIE
				if SF4->(DbSeek(xFilial("SF4")+TEMP->D1_TES,.F.))
					if SF4->F4_CREDICM == "S"
						nIcm += TEMP->D1_VALICM
					endif
					
					if SF4->F4_CREDIPI == "S"
						nIpi += TEMP->D1_VALIPI
					endif
				endif
/*				nValor += TEMP->D1_TOTAL
				nIcm += TEMP->D1_VALICM
				nIpi += TEMP->D1_VALIPI
					            		aCols[Len(aCols),ni] := Posicione("SBM",1,xFilial("SBM")+aCols[Len(aCols),nPosGrupo],"BM_DESC")
				nTotValor += TEMP->D1_TOTAL
				nTotIcm += TEMP->D1_VALICM
				nTotIpi += TEMP->D1_VALIPI
				
				nGeralValor += TEMP->D1_TOTAL
				nGeralIcm += TEMP->D1_VALICM
				nGeralIpi += TEMP->D1_VALIPI*/
				
				TEMP->(DbSkip())
			enddo
			
			nTotValor += nValor
			nTotIcm += nIcm
			nTotIpi += nIpi
			
			nGeralValor += nValor
			nGeralIcm += nIcm
			nGeralIpi += nIpi
			
			@nLin,062 psay Transf(nValor,"@E 999,999,999.99")
			@nLin,079 psay Transf(nIcm,"@E 999,999,999.99")
			@nLin,096 psay Transf(nIpi,"@E 999,999,999.99")
			
			nLin++
			
			U_SaltaFolha()
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		@nLin,062 psay Transf(nTotValor,"@E 999,999,999.99")
		@nLin,079 psay Transf(nTotIcm,"@E 999,999,999.99")
		@nLin,096 psay Transf(nTotIpi,"@E 999,999,999.99")

		U_SaltaFolha()
		
		nLin++
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,055 psay "TOTAL"
	@nLin,062 psay Transf(nGeralValor,"@E 999,999,999.99")
	@nLin,079 psay Transf(nGeralIcm,"@E 999,999,999.99")
	@nLin,096 psay Transf(nGeralIpi,"@E 999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return