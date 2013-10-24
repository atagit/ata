/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 27/05/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Após gravar o SD1, atualizar campos                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function SD1100I()
	local cAlias := Alias()
//	local cGrupo := If(SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD,.F.)),SB1->B1_GRUPO,"")
//	local cGGrupo := If(SBM->(DbSeek(xFilial("SBM")+cGrupo,.F.)),SBM->BM_ORCGRP,"")
//	local cNumSeq := SD1->D1_NUMSEQ
	
	//Atualizar a tabela de orcamento
	U_AtualSZ4(SD1->D1_CLVL,SD1->D1_COD)
	DbSelectArea(cAlias)
/*	if SD1->D1_CLVL <> '000000000'
		cQry := "select * "
		cQry += "from "+RetSqlName("SZ4")+" "
		cQry += "where Z4_PROJETO = '"+SD1->D1_CLVL+"' and Z4_GGRUPO = '"+cGGrupo+"' and Z4_GRUPO in ('','"+cGrupo+"') and D_E_L_E_T_ <> '*'"
		
		tcquery cQry new alias "TMP"
		DbSelectArea("TMP")
		
		cNum := TMP->Z4_NUM
		nReali := TMP->Z4_VLREALI + SD1->D1_TOTAL
		
		TMP->(DbCloseArea())
		
		cUpd := "update "+RetSqlName("SZ4")+" "
		cUpd += "set Z4_VLREALI = "+AllTrim(Str(nReali))+", Z4_SALDO = Z4_VLORCAM + Z4_VLREVIS - "+AllTrim(Str(nReali))+" "
		cUpd += "where Z4_PROJETO = '"+SD1->D1_CLVL+"' and Z4_GGRUPO = '"+cGGrupo+"' and Z4_GRUPO in ('','"+cGrupo+"') and D_E_L_E_T_ <> '*' "
		
		nRet := TCSqlExec(cUpd)
		
		cUpd := "update "+RetSqlName("SZ3")+" "
		cUpd += "set Z3_SALDO = (select sum(Z4_SALDO) from "+RetSqlName("SZ4")+" where Z4_NUM = '"+cNum+"' and D_E_L_E_T_ <> '*') "
		cUpd += "where Z3_NUM = '"+cNum+"' and D_E_L_E_T_ <> '*'"
		
		nRet := TCSqlExec(cUpd)
		
		DbSelectArea(cAlias)
	endif*/
	
	//Atualizar o produto com sequencial da ultima nota lancada
	if SB1->(DbSeek(xFilial("SB1")+SD1->(D1_COD+D1_LOCAL),.F.))
		if RecLock("SB1",.F.)
			SB1->B1_NUMSEQ := IIf(cEmpAnt == "01","A"+SD1->D1_NUMSEQ,"F"+SD1->D1_NUMSEQ)
			
			//Atualizar o ultimo preco de compra
			if SD1->D1_TIPO == "N"
				SB1->B1_ULTPRC := SD1->D1_VUNIT
			endif
 			
			MsUnLock()
		endif
	endif
return