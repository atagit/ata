/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 04/01/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho para retornar peso                            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function B5PESPEC(nEspessura,nLargura,nComprimento,cPesoEspecifico)
	local cAlias := Alias()
	local nRet := 0
	
	if cPesoEspecifico == "N" .or. Empty(cPesoEspecifico)
		nRet := 0
	else
		DbSelectArea("SX5")
		DbSeek(xFilial("SX5")+"PE"+cPesoEspecifico)
		
		if Empty(X5_DESCRI)
			MsgBox("Nao possui Peso Especifido desse material cadastrado na tabela PE (SX5)!","Alerta","ALERT")
			
			nRet := 0
		else
			nRet := nEspessura * nLargura * nComprimento * Val(X5_DESCRI)
		endif
	endif
	
	DbSelectArea(cAlias)
return (nRet)