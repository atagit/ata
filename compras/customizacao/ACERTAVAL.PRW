/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/11/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Acertar avaliação do fornecedor                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function ACERTAVAL()
	private lAborta := .T.
	
	Pergunte("ACERTAV",.T.,"Parâmetros")
	Processa({|| Atualiza()},"","Aguarde processando...",lAborta)
return

static function Atualiza()
	DbSelectArea("SZV")
	SZV->(DbSetOrder(3))
	
	DbSelectArea("SA2")
	SA2->(DbGoTop())
	
	if SA2->(DbSeek(xFilial("SA2")+mv_par01,.F.))
		while SA2->A2_COD >= mv_par01 .and. SA2->A2_COD <= mv_par02
			if SA2->A2_MSBLQL <> "2" ; SA2->(DbSkip()) ; loop ; endif
			
			if SZV->(DbSeek(xFilial("SZV")+SA2->(A2_COD+A2_LOJA),.F.))
				if SZV->ZV_STATUS == "A"
					aCalcIQF := U_CalcIQF(SZV->ZV_RA,SZV->ZV_RC,SZV->ZV_RR)
					
					RecLock("SZV",.F.)
						SZV->ZV_VALIQF := aCalcIQF[1][1]
					MsUnLock()
				else
					aCalcIQF := SZV->ZV_VALIQF
				endif
				
				if aCalcIQF[1][1] < 60
					RecLock("SA2",.F.)
						SA2->A2_MSBLQL := "1"
						SA2->A2_OBSBLOQ := "BLOQUEADO DEVIDO IQF ("+AllTrim(Str(aCalcIQF[1][1]))+") ABAIXO DO PERMITIDO."
					MsUnLock()
				endif
			endif
			
			SA2->(DbSkip())
		enddo
		
		MsgInfo("Avaliacao de fornecedores atualizado com sucesso!")
	else
		MsgAlert("Fornecedor nao encontrado.")
	endif
/*	local nCont, nSoma
	local nS1, nS2, nS3, nS4, nS5
	
	nCont := 0 ; nSoma := 0
	nS1 := 0 ; nS2 := 0 ; nS3 := 0 ; nS4 := 0 ; nS5 := 0
	
	DbSelectArea("SA2")
	SA2->(DbGoTop())
	SA2->(DbSeek(xFilial("SA2")+mv_par01,.F.))
	
	while SA2->A2_COD >= mv_par01 .and. SA2->A2_COD <= mv_par02
		if SA2->A2_MSBLQL <> "2" ; SA2->(DbSkip()) ; loop ; endif
		
		cSql := "select F1_FORNECE, F1_LOJA, F1_AVPRZ, F1_AVIDENT, F1_AVESPEC, F1_AVQUANT, F1_AVCERTI "
		cSql += "from "+RetSqlName("SF1")+" "
		cSql += "where F1_FORNECE = '"+SA2->A2_COD+"' and F1_LOJA = '"+SA2->A2_LOJA+"' and D_E_L_E_T_ <> '*' "
		cSql += "order by F1_FORNECE, F1_LOJA"
		
		tcquery cSql new alias "TMP1"
		DbSelectArea("TMP1")
		TMP1->(DbGoTop())
		
		ProcRegua(TMP1->(RecCount()))
		
		while !TMP1->(Eof())
			if TMP1->F1_AVPRZ == "S"
				nS1++
				nSoma++
			endif
			
			if TMP1->F1_AVIDENT == "S"
				nS2++
				nSoma++
			endif
			
			if TMP1->F1_AVESPEC == "S"
				nS3++
				nSoma++
			endif
			
			if TMP1->F1_AVQUANT == "S"
				nS4++
				nSoma++
			endif
			
			if TMP1->F1_AVCERTI == "S"
				nS5++
				nSoma++
			endif
			
			nCont++
			
			IncProc()
			
			TMP1->(DbSkip())
		enddo
		
		RecLock("SA2",.F.)
			SA2->A2_AVPRZ := If(nS1 > 0,nS1 / nCont,0)
			SA2->A2_AVIDENT := If(nS2 > 0,nS2 / nCont,0)
			SA2->A2_AVESPEC := If(nS3 > 0,nS3 / nCont,0)
			SA2->A2_AVQUANT := If(nS4 > 0,nS4 / nCont,0)
			SA2->A2_AVCERTI := If(nS5 > 0,nS5 / nCont,0)
			SA2->A2_AVALIAC := If(nSoma > 0,nSoma / nCont,0)
		MsUnLock()
		
		nCont := 0 ; nSoma := 0
		nS1 := 0 ; nS2 := 0 ; nS3 := 0 ; nS4 := 0 ; nS5 := 0
		
		TMP1->(DbCloseArea())
		SA2->(DbSkip())
	enddo*/
return