/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 24/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Envia email apos analise de cotacao para gerar pedido ¦
   ¦          ¦ de compra                                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MT160WF()
	local cServer := getmv("MV_RELSERV")
	local cPassword := getmv("MV_RELPSW")
	local cAccount := getmv("MV_RELACNT")
	local cSubject := IIf(Lower(AllTrim(GetEnvServer())) $ "testepro/testeofi","TESTE - ","")
	local cAlias := Alias()
	local cTo := ""
	
	private cMensagem := ""
	
	setprvt("cPedido","cEmissao","cProjeto","cAprov","cCompra","cDescForn","cDescComp")
	setprvt("cForn","cLojaForn","nTotal","cDescProj","cCliente","cLojaCli","cDescCli","cDescAprov")
	
	cPedido := SC7->C7_NUM
	cSubject += "Liberação do PEDIDO DE COMPRA "+cPedido
	cEmissao := U_ConvData(dtos(SC7->C7_EMISSAO))
	cProjeto := SC7->C7_CLVL
	cAprov := SC7->C7_APROV
	cCompra := SC7->C7_USER
	cForn := SC7->C7_FORNECE
	cLojaForn := SC7->C7_LOJA
	nTotal := SC7->C7_TOTAL + SC7->C7_VALIPI
	
	if CTH->(dbseek(xFilial("CTH")+cProjeto,.F.))
		cDescProj := CTH->CTH_DESC01
		cCliente := CTH->CTH_CLIENT
		cLojaCli := CTH->CTH_LOJACL
	else
		cDescProj := " "
		cCliente := " "
		cLojaCli := " "
	endif
	
	if SA1->(dbseek(xFilial("SA1")+cCliente+cLojaCli,.F.))
		cDescCli := SA1->A1_NOME
	else
		cDescCli := " "
	endif
	
	if SA2->(dbseek(xFilial("SA2")+cForn+cLojaForn,.F.))
		cDescForn := SA2->A2_NOME
		cAprov := IIf(!Empty(SA2->A2_GRAPROV),SA2->A2_GRAPROV,cAprov)
	else
		cDescForn := " "
	endif
	
	if cAprov <> "000001"
		if SC7->(DbSeek(xFilial("SC7")+cPedido,.F.))
			while !SC7->(Eof()) .and. SC7->C7_NUM == cPedido
				RecLock("SC7",.F.)
					SC7->C7_APROV := cAprov
				MsUnLock()
				
				SC7->(DbSkip())
			enddo
		endif
		
		if SCR->(DbSeek(xFilial("SCR")+"PC"+cPedido,.F.))
			while !SCR->(Eof()) .and. AllTrim(SCR->CR_NUM) == AllTrim(cPedido)
				RecLock("SCR",.F.)
					DbDelete()
				MsUnLock()
				
				SCR->(DbSkip())
			enddo
		endif
	endif
	
	dbselectarea("SY1")
	SY1->(dbsetorder(3))
	
	if SY1->(dbseek(xFilial("SY1")+cCompra,.F.))
		cDescComp := SY1->Y1_NOME
	else
		cDescComp := " "
	endif
	
	dbselectarea("SAL")
	SAL->(dbsetorder(3))
	SAL->(dbseek(xFilial("SAL")+cAprov,.F.))
	
	if !empty(SAL->AL_COD)
		while SAL->AL_COD == cAprov
			if cAprov <> "000001"
				if RecLock("SCR",.T.)
					SCR->CR_FILIAL := "01"
					SCR->CR_NUM := cPedido
					SCR->CR_TIPO := "PC"
					SCR->CR_USER := SAL->AL_USER
					SCR->CR_APROV := SAL->AL_APROV
					SCR->CR_NIVEL := SAL->AL_NIVEL
					SCR->CR_STATUS := "02"
					SCR->CR_TOTAL := nTotal
					SCR->CR_EMISSAO := CToD(cEmissao)
					SCR->CR_MOEDA := 1
					
					MsUnLock()
				endif
			endif
			
			if SAL->AL_MSBLQL <> "1"
				cDescAprov := AllTrim(SAL->AL_NOME)
				cTo := AllTrim(SAL->AL_EMAIL)
				
				MsgHtml()
				
//				cTo := alltrim(U_FUsuario(left(cDescAprov,15)))
				
				if !empty(cTo)
					U_EnvEmail(.T.,.T.,cServer,cAccount,cPassword,cTo,,cSubject,cMensagem)
				else
					alert("Email não cadastrado para o funcinário "+alltrim(cDescAprov)+"!")
				endif
			endif
			
			SAL->(dbskip())
		enddo
	else
		cDescAprov := "NAO IDENTIFICADO"
		
		MsgHtml()
		
		dbselectarea("SX5")
		if SX5->(dbseek(xFilial("SX5")+"WK"+"FIN"))
			cTo := SX5->X5_DESCRI
		endif
		
//		U_EnvEmail(.T.,.T.,cServer,cAccount,cPassword,cTo,,cSubject,cMensagem)
		Processa({|| U_EnvMail(cTo,"","",cSubject,,cMensagem,.T.)},"Enviando e-mail...")
	endif
	
	dbselectarea(cAlias)
return

static function MsgHtml()
	cMensagem := "<html> "
	cMensagem += "	<body> "
	cMensagem += "		<font face='verdana' size='2'> "
	cMensagem += "			Existe um novo pedido de compra bloqueado no sistema. Aguardamos liberação para encerrar o processo de compra.<br><br> "
	cMensagem += "			Segue abaixo dados para liberação:<br><br> "
	cMensagem += "			<table border='1'> "
	cMensagem += "				<tr> "
	cMensagem += "					<td height='30' colspan='4' align='center' bgcolor='3C79D5'><font face='verdana' size='3' color='FFFFFF'><b>PEDIDO A LIBERAR</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Número Pedido</font></td> "
	cMensagem += "					<td><font face='verdana' size='2'>&nbsp;<b>"+cPedido+"</b></font></td> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Data Emissão</font></td> "
	cMensagem += "					<td><font face='verdana' size='2'>&nbsp;<b>"+cEmissao+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Projeto</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>"+alltrim(cProjeto)+" - "+alltrim(cDescProj)+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Cliente</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>"+alltrim(cCliente)+"/"+alltrim(cLojaCli)+" - "+alltrim(cDescCli)+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td height='5' colspan='4' bgcolor='3C79D5'></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Aprovador</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>"+alltrim(cAprov)+" - "+alltrim(cDescAprov)+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Comprador</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>"+alltrim(cCompra)+" - "+alltrim(cDescComp)+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Fornecedor</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>"+alltrim(cForn)+"/"+alltrim(cLojaForn)+" - "+alltrim(cDescForn)+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td height='5' colspan='4' bgcolor='3C79D5'></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td width='110'><font face='verdana' size='2'>Valor Total</font></td> "
	cMensagem += "					<td colspan='3'><font face='verdana' size='2'>&nbsp;<b>R$ "+transf(nTotal,"@E 999,999,999.99")+"</b></font></td> "
	cMensagem += "				</tr> "
	cMensagem += "				<tr> "
	cMensagem += "					<td height='5' colspan='4' bgcolor='3C79D5'></td> "
	cMensagem += "				</tr> "
	cMensagem += "			</table> "
	cMensagem += "		</font> "
	cMensagem += "	</body> "
	cMensagem += "</html> "
return