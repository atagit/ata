/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 30/09/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Envia email apos conclusao do pedido de compra        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function MT120GOK()
	local cSubject := IIf(Lower(AllTrim(GetEnvServer())) $ "testepro/testeofi","TESTE - ","")
	local cAlias := Alias()
	local cTo := ""
	
	private cMensagem := ""
	
	SetPrvt("cPedido","cEmissao","cProjeto","cAprov","cCompra","cDescForn","cDescComp")
	SetPrvt("cForn","cLojaForn","nTotal","cDescProj","cCliente","cLojaCli","cDescCli","cDescAprov")
	
	if INCLUI == .T. .or. ALTERA == .T.
		U_FRETE("PEDIDO ",CA120NUM,CA120FORN,CA120LOJ,"SC7")
		
		cPedido := CA120NUM
		cSubject += "Liberação do PEDIDO DE COMPRA "+cPedido
		
		DbSelectArea("SC7")
		SC7->(DbSeek(xFilial("SC7")+cPedido,.F.))
		
		cEmissao := U_ConvData(DToS(SC7->C7_EMISSAO))
		cProjeto := SC7->C7_CLVL
		cAprov := SC7->C7_APROV
		cCompra := SC7->C7_USER
		cForn := SC7->C7_FORNECE
		cLojaForn := SC7->C7_LOJA
		nTotal := SC7->C7_TOTAL + SC7->C7_VALIPI
		
		if CTH->(DbSeek(xFilial("CTH")+cProjeto,.F.))
			cDescProj := CTH->CTH_DESC01
			cCliente := CTH->CTH_CLIENT
			cLojaCli := CTH->CTH_LOJACL
		else
			cDescProj := " "
			cCliente := " "
			cLojaCli := " "
		endif
		
		if SA1->(DbSeek(xFilial("SA1")+cCliente+cLojaCli,.F.))
			cDescCli := SA1->A1_NOME
		else
			cDescCli := " "
		endif
		
		if SA2->(DbSeek(xFilial("SA2")+cForn+cLojaForn,.F.))
			cDescForn := SA2->A2_NOME
		else
			cDescForn := " "
		endif
		
		DbSelectArea("SY1")
		SY1->(DbSetOrder(3))
		
		if SY1->(DbSeek(xFilial("SY1")+cCompra,.F.))
			cDescComp := SY1->Y1_NOME
		else
			cDescComp := " "
		endif
		
		DbSelectArea("SAL")
		SAL->(DbSetOrder(3))
		SAL->(DbSeek(xFilial("SAL")+cAprov,.F.))
		
		if !Empty(SAL->AL_COD)
			while SAL->AL_COD == cAprov
				if SAL->AL_MSBLQL <> "1"
					cDescAprov := AllTrim(SAL->AL_NOME)
					cTo := AllTrim(SAL->AL_EMAIL)
					
					MsgHtml()
					
//					cTo := alltrim(U_FUsuario(left(cDescAprov,15)))
/*					dbselectarea("SX5")
					if SX5->(dbseek(xFilial("SX5")+"WK"+"FIN"))
						cTo := AllTrim(SX5->X5_DESCRI)
					endif*/
					
					if !Empty(cTo)
						Processa({|| U_EnvMail(cTo,"","",cSubject,,cMensagem,.T.)},"Enviando e-mail...")
					else
						Alert("Email não cadastrado para o funcinário "+AllTrim(cDescAprov)+"!")
					endif
				endif
				
				SAL->(DbSkip())
			enddo
		else
			cDescAprov := "NAO IDENTIFICADO"
			
			MsgHtml()
			
			DbSelectArea("SX5")
			
			if SX5->(DbSeek(xFilial("SX5")+"WK"+"FIN"))
				cTo := AllTrim(SX5->X5_DESCRI)
			endif
			
//			U_EnvEmail(.T.,.F.,,,,cTo,,cSubject,cMensagem)
			Processa({|| U_EnvMail(cTo,"","",cSubject,,cMensagem,.T.)},"Enviando e-mail...")
		endif
		
		DbSelectArea(cAlias)
	endif
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