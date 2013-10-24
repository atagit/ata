/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ PE para adicionar um botão no pedido de venda         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"

user function MT410BRW()
//	AAdd(aRotina,{"Consulta NF","U_ChamarNF()",0,3})
	AAdd(aRotina,{"Imprimir NF","U_ChamarNF()",0,3})
return

user function ChamarNF()
	cEmpresa := SubStr(cNumEmp,1,2)
	cFilial := SC5->C5_FILIAL
	cNota := SC5->C5_NOTA
	cSerie := SC5->C5_SERIE
	
	if !Empty(cNota) .and. !Empty(cSerie)
		if cEmpresa == "01"
			U_NFATA(cFilial,cNota,cSerie)
		elseif cEmpresa == "02"
			U_NFATF(cFilial,cNota,cSerie)
		else
			U_NFATA(cFilial,cNota,cSerie)
		endif
	else
		MsgBox("O Pedido de Venda nao foi preparado (nao gerou nota fiscal)!","Alerta","ALERT")
	endif
return