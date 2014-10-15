/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 27/05/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Após gravar o SD1, atualizar campos                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

user function SD1100I()
	local cAliasAnt := Alias()
	local cCpfCnpj := ""
	local cDescForn := ""
	local cGrpMaterial := ""
	local cDescGrpMat := Space(50)
	local oButton1
	local oGet1,oGet2
	local oSay1,oSay2
	
	private oDlg
//	local cGrupo := If(SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD,.F.)),SB1->B1_GRUPO,"")
//	local cGGrupo := If(SBM->(DbSeek(xFilial("SBM")+cGrupo,.F.)),SBM->BM_ORCGRP,"")
//	local cNumSeq := SD1->D1_NUMSEQ
	
	//Atualizar a tabela de orcamento
	U_AtualSZ4(SD1->D1_CLVL,SD1->D1_COD)
	DbSelectArea(cAliasAnt)
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
	
	//Atualizar tabela de Fornecedor X Grp Material
	if SD1->D1_TIPO == "N"
		if SA2->(DbSeek(xFilial("SA2")+SD1->(D1_FORNECE+D1_LOJA),.F.))
			cCpfCnpj := SA2->A2_CGC
			cDescForn := SA2->A2_NREDUZ
		else
			cCpfCnpj := ""
			cDescForn := ""
		endif
		
		cGrpMaterial := Left(SD1->D1_COD,3)
		cQry := "select max(ZO_ITEM) as ZO_ITEM from "+RetSqlName("SZO")+" where ZO_CPFCNPJ = '"+cCpfCnpj+"' and D_E_L_E_T_ <> '*'"
		
		tcquery cQry new alias "CON"
		
		DbSelectArea("CON")
		SZO->(DbSetOrder(4))
		
		if !SZO->(DbSeek(xFilial("SZO")+cCpfCnpj+cGrpMaterial,.F.)) .and. !Empty(cCpfCnpj+cDescForn)
			if RecLock("SZO",.T.)
				SZO->ZO_FILIAL	:= xFilial("SZO")
				SZO->ZO_CPFCNPJ	:= cCpfCnpj
				SZO->ZO_DFORNEC	:= cDescForn
				SZO->ZO_ITEM	:= StrZero(Val(CON->ZO_ITEM) + 1,3)
				
				if SX5->(DbSeek(xFilial("SX5")+"GM"+cGrpMaterial,.F.))
					cDescGrpMat := Left(SX5->X5_DESCRI,50)
				else
					if MsgYesNo("O grupo de material "+cGrpMaterial+" nao esta cadastrado. Deseja cadastra-lo agora?","Grupo de Material")
						define msdialog oDlg title "Grupo de Material" from 000,000 to 100,460 colors 0,16777215 pixel
							@005,004 say oSay1 prompt "Grupo" size 025,007 of oDlg colors 0,16777215 pixel
							@004,032 msget oGet1 var cGrpMaterial size 020,010 of oDlg colors 0,16777215 readonly pixel
							@019,004 say oSay2 prompt "Descricao" size 025,007 of oDlg colors 0,16777215 pixel
							@017,032 msget oGet2 var cDescGrpMat size 195,010 of oDlg colors 0,16777215 pixel
							@033,148 button oButton1 prompt "Cancelar" size 037,012 of oDlg action oDlg:End() pixel
							@033,189 button oButton2 prompt "Confirmar" size 037,012 of oDlg action Confirmar(cGrpMaterial,@cDescGrpMat) pixel
						activate msdialog oDlg centered
					endif
				endif
				
				if !Empty(cDescGrpMat)
					SZO->ZO_GRPMAT	:= cGrpMaterial
					SZO->ZO_DGRPMAT	:= cDescGrpMat
				endif
				
				MsUnLock()
			endif
		endif
		
		CON->(DbCloseArea())
		DbSelectArea(cAliasAnt)
	endif
return

static function Confirmar(cCod,cDescGrpMat)
	if Empty(cDescGrpMat)
		MsgAlert("A descricao do grupo nao foi digitada.")
		
		return
	else
		if RecLock("SX5",.T.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "GM"
			SX5->X5_CHAVE := cCod
			SX5->X5_DESCRI := cDescGrpMat
			SX5->X5_DESCSPA := cDescGrpMat
			SX5->X5_DESCENG := cDescGrpMat
			
			MsUnLock()
		endif
		
		oDlg:End()
	endif
return