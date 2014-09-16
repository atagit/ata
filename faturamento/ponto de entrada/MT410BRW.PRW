/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ PE para adicionar um botão no pedido de venda         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MT410BRW()
	AAdd(aRotina,{"Pre-Nota","U_CHAMARNF()",0,6})
	AAdd(aRotina,{"Folha Rosto","U_IMPFOLR()",0,6})
return

user function CHAMARNF()
	local aAreaAnt := GetArea()
	local cNota := SC5->C5_NOTA
	local cSerie := SC5->C5_SERIE
	local cCliente := SC5->(C5_CLIENTE+C5_LOJACLI)
	local cPedVen := SC5->C5_NUM
	
/*	if !Empty(cNota) .and. !Empty(cSerie)
		if cEmpresa == "01"
			U_NFATA(cFilial,cNota,cSerie)
		elseif cEmpresa == "02"
			U_NFATF(cFilial,cNota,cSerie)
		else
			U_NFATA(cFilial,cNota,cSerie)
		endif
	else
		MsgBox("O Pedido de Venda nao foi preparado (nao gerou nota fiscal)!","Alerta","ALERT")
	endif*/
	
//	if !Empty(cNota) .and. !Empty(cSerie)
		U_PREDANFE("S",cPedVen,cNota,cSerie,cCliente)
//	else
//		MsgBox("O Pedido de Venda nao foi preparado (nao gerou nota fiscal)!","Alerta","ALERT")
//	endif
	
	RestArea(aAreaAnt)
return