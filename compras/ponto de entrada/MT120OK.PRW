/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 25/05/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Antes de gravar o ped. compra, valida o orcamento     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MT120OK()
	local nPosTot := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_TOTAL"})
	local nPosIpi := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_IPI"})
	local nPosProj := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_CLVL"})
	local nPosProd := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
	local nPosAprov := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_APROV"})
	local cGrAprov := "000001"
	local aProj := {}
	local lRet := .F.
	
	if SA2->(DbSeek(xFilial("SA2")+CA120FORN+CA120LOJ,.F.))
		if !Empty(SA2->A2_GRAPROV)
			cGrAprov := SA2->A2_GRAPROV
		endif
	endif
	
	for nX := 1 to Len(aCols)
		nTotal := (((aCols[nX][nPosTot] * aCols[nX][nPosIpi]) / 100) + aCols[nX][nPosTot])
		cGrupo := If(SB1->(DbSeek(xFilial("SB1")+aCols[nX][nPosProd],.F.)),SB1->B1_GRUPO,"")
		cProj := aCols[nX][nPosProj]+cGrupo
		aCols[nX][nPosAprov] := cGrAprov
		
		if (nInd := AScan(aProj,{|x| x[1] = cProj})) == 0
			AAdd(aProj,{cProj,nTotal})
		else
			aProj[nInd][2] += nTotal
		endif
		
		nTotal := 0 ; cGrupo := "" ; cProj := ""
	next nX
	
	lRet := U_ValidOrc(aProj,"SC7+")
return (lRet)