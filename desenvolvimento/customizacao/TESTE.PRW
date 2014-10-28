#include "protheus.ch"
#include "tbiconn.ch"

/*#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

User Function FC021HDPC
	Local aAuxCol := ParamIXB[1]
	
	aAdd(aAuxCol,{"COLUNA TESTE","Saldo","@e 999,999,999.99",15,2,".T.",USADO,"N",,"V"}) //"Valor"
Return aAuxCol*/

/*User Function FC21CTRFLX
	Local aTela := ParamIXB[1]
	Local x     := 0
	
	For x := 1 to Len(aTela)
		aTela[x][3] += 10
	Next
Return aTela*/

/*User Function FC021CPO
	Local aCposAna := aClone(PARAMIXB)
	Local aRet := {}
	
	AADD(aRet,{"TESTE","C",5,0})
	MsgAlert("Ponto de entrada FC021CPO executado")
Return aClone(aRet)*/   

/*User Function FC021HEAD
	Local aRet  := {}
//	Local _aVet := PARAMIXB[1]
	
	Aadd(aRet,{"TESTE","Saldo","@e 999,999,999.99",15,2,".T.",USADO,"N",,"V"}) //"Valor"
	MsgAlert("Ponto de entrada FC021HEAD executado")
Return aRet*/

user function TESTE()
//	Alert(cEmpAnt+" ==> "+IIf(cEmpAnt == "01","ATA","ATF"))
	StartJob("U_FUNCAO",GetEnvServer(),.T.,"01","01")
//	Alert(cEmpAnt+" ==> "+IIf(cEmpAnt == "01","ATA","ATF"))
	StartJob("U_FUNCAO",GetEnvServer(),.T.,"02","01")
//	Alert(cEmpAnt+" ==> "+IIf(cEmpAnt == "01","ATA","ATF"))
/*	private lMsErroAuto := .F.
	
	public nValPed := 16 * 211.88
	
	MsgInfo("Empresa: "+IIf(cEmpAnt == "01","ATA","ATF"))
	
	cDoc := GetSxeNum("SC5","C5_NUM")
	aCabec := {}
	aItens := {}
	aLinha := {}
	aTables := {}
	
	AAdd(aCabec,{"C5_PROJETO","141586",nil})
	AAdd(aCabec,{"C5_NUM",cDoc,nil})
	AAdd(aCabec,{"C5_TIPO","N",nil})
	AAdd(aCabec,{"C5_CLIENTE","000012",nil})
	AAdd(aCabec,{"C5_LOJACLI","01",nil})
	AAdd(aCabec,{"C5_LOJAENT","01",nil})
	AAdd(aCabec,{"C5_CONDPAG","010",nil})
	AAdd(aCabec,{"C5_FOLROST","TESTE",nil})
	AAdd(aCabec,{"C5_NATUREZ","10101",nil})
	AAdd(aCabec,{"C5_TPFRETE","C",nil})
	
	AAdd(aLinha,{"C6_ITEM","01",nil})
	AAdd(aLinha,{"C6_PRODUTO","PFA293",nil})
	AAdd(aLinha,{"C6_QTDVEN",16,nil})
	AAdd(aLinha,{"C6_PRCVEN",211.88,nil})
	AAdd(aLinha,{"C6_PRUNIT",0,nil})
	AAdd(aLinha,{"C6_VALOR",16 * 211.88,nil})
	AAdd(aLinha,{"C6_TES","548",nil})
	AAdd(aLinha,{"C6_DESCRI","GUIA HITACHI 10R156995 1",nil})
	AAdd(aItens,aLinha)
	
	MsExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)
	
	if !lMsErroAuto
		MsgAlert("Incluido com sucesso! "+cDoc)
		ConfirmSx8()
	else
		MsgAlert("Erro na inclusao!")
		MostraErro()
		RollBackSx8()
	endif*/
	
	Alert("deu certinho!")
return

user function FUNCAO(cNewEmp,cNewFil,cCod)
	private lMsErroAuto := .F.
	
	public nValPed := 16 * 211.88
	
	RpcSetType(3)
	RpcSetEnv(cNewEmp,cNewFil,,,"FAT")
	
	ConOut("dentro: "+cEmpAnt+"/"+cFilAnt+" ==> "+IIf(cEmpAnt == "01","ATA","ATF"))
	ConOut("SC5: "+GetSxeNum("SC5","C5_NUM"))
	
	cDoc := GetSxeNum("SC5","C5_NUM")
	aCabec := {}
	aItens := {}
	aLinha := {}
	
	AAdd(aCabec,{"C5_PROJETO","141586",nil})
	AAdd(aCabec,{"C5_NUM",cDoc,nil})
	AAdd(aCabec,{"C5_TIPO","N",nil})
	AAdd(aCabec,{"C5_CLIENTE","000012",nil})
	AAdd(aCabec,{"C5_LOJACLI","01",nil})
	AAdd(aCabec,{"C5_LOJAENT","01",nil})
	AAdd(aCabec,{"C5_CONDPAG","010",nil})
	AAdd(aCabec,{"C5_FOLROST","TESTE",nil})
	AAdd(aCabec,{"C5_NATUREZ","10101",nil})
	AAdd(aCabec,{"C5_TPFRETE","C",nil})
	
	AAdd(aLinha,{"C6_ITEM","01",nil})
	AAdd(aLinha,{"C6_PRODUTO","PFA293",nil})
	AAdd(aLinha,{"C6_QTDVEN",16,nil})
	AAdd(aLinha,{"C6_PRCVEN",211.88,nil})
	AAdd(aLinha,{"C6_PRUNIT",0,nil})
	AAdd(aLinha,{"C6_VALOR",16 * 211.88,nil})
	AAdd(aLinha,{"C6_TES","548",nil})
	AAdd(aLinha,{"C6_DESCRI","GUIA HITACHI 10R156995 1",nil})
	AAdd(aItens,aLinha)
	
	MsExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)
	
	if !lMsErroAuto
		ConOut("Incluido com sucesso! "+cDoc)
		ConfirmSx8()
	else
		ConOut("Erro na inclusao!")
		MostraErro()
		RollBackSx8()
	endif
	
	RpcClearEnv()
return