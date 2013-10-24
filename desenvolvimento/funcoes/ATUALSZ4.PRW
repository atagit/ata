/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 06/02/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Atualizar valores na tabela de orcamento              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function ATUALSZ4(cProjeto,cProduto)
	local cGrupo := IIf(SB1->(DbSeek(xFilial("SB1")+cProduto,.F.)),SB1->B1_GRUPO,"")
	local cGGrupo := IIf(SBM->(DbSeek(xFilial("SBM")+cGrupo,.F.)),SBM->BM_ORCGRP,"")
	
	if cProjeto <> '000000000'
		cQry := "select * "
		cQry += "from "+RetSqlName("SZ4")+" "
		cQry += "where Z4_PROJETO = '"+cProjeto+"' and Z4_GGRUPO = '"+cGGrupo+"' and Z4_GRUPO in ('','"+cGrupo+"') and D_E_L_E_T_ <> '*'"
		
		tcquery cQry new alias "TMP"
		DbSelectArea("TMP")
		
		cNum := TMP->Z4_NUM
		nReali := TMP->Z4_VLREALI + SD1->D1_TOTAL
		
		TMP->(DbCloseArea())
		
		cUpd := "update "+RetSqlName("SZ4")+" "
		cUpd += "set Z4_VLREALI = "+AllTrim(Str(nReali))+", Z4_SALDO = Z4_VLORCAM + Z4_VLREVIS - "+AllTrim(Str(nReali))+" "
		cUpd += "where Z4_PROJETO = '"+cProjeto+"' and Z4_GGRUPO = '"+cGGrupo+"' and Z4_GRUPO in ('','"+cGrupo+"') and D_E_L_E_T_ <> '*' "
		
		nRet := TCSqlExec(cUpd)
		
		cUpd := "update "+RetSqlName("SZ3")+" "
		cUpd += "set Z3_SALDO = (select sum(Z4_SALDO) from "+RetSqlName("SZ4")+" where Z4_NUM = '"+cNum+"' and D_E_L_E_T_ <> '*') "
		cUpd += "where Z3_NUM = '"+cNum+"' and D_E_L_E_T_ <> '*'"
		
		nRet := TCSqlExec(cUpd)
	endif
return