/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/08/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ P.E. antes de gravar o SC1                            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#define _CARACT {".","..",":","'","*","-","+","=","_",",",";"}

user function MT110CON()
	local aFlag := {}
	local nPosProduto := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C1_PRODUTO"})
	local nPosDescricao := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C1_DESCRI"})
	local nPosFlag := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C1_FLAG"})
	
	if INCLUI .or. ALTERA
		for i := 1 to Len(aCols)
			cProduto := AllTrim(aCols[i][nPosProduto])
			
			if (nInd := AScan(aFlag,{|x| x[1] = cProduto})) == 0
				AAdd(aFlag,{cProduto,aCols[i][nPosFlag]})
			else
				j := aFlag[nInd][2] + 1
				aCols[i][nPosFlag] := j
				aCols[i][nPosDescricao] := Left(aCols[i][nPosDescricao],30)+_CARACT[j]
				aFlag[nInd][2] := j
			endif
		next
	endif
return