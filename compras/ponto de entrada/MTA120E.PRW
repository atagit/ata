/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 02/07/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. antes de excluir o pedido de compra              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MTA120E()
	local nPosTot := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_TOTAL"})
	local nPosIpi := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_IPI"})
	local nPosProj := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_CLVL"})
	local nPosProd := AScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
	local aProj := {}
	local lRet := .F.
	
	for nX := 1 to Len(aCols)
		nTotal := (((aCols[nX][nPosTot] * aCols[nX][nPosIpi]) / 100) + aCols[nX][nPosTot])
		cGrupo := If(SB1->(DbSeek(xFilial("SB1")+aCols[nX][nPosProd],.F.)),SB1->B1_GRUPO,"")
		cProj := aCols[nX][nPosProj]+cGrupo
		
		if (nInd := AScan(aProj,{|x| x[1] = cProj})) == 0
			AAdd(aProj,{cProj,nTotal})
		else
			aProj[nInd][2] += nTotal
		endif
		
		nTotal := 0 ; cGrupo := "" ; cProj := ""
	next nX
	
	U_ValidOrc(aProj,"SC7-")
return