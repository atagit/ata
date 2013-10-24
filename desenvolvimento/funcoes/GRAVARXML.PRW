/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 11/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Grava em arquivo TXT salvando como XML                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "fileio.ch"

user function GRAVARXML(cXml,cNomArq)
	local aLinha := {}
	
/*	cXml := '<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="2.00"><NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe Id="NFe31130907697698000195550000000048861001266112" versao="2.00"><ide><cUF>31</cUF><cNF>00126611</cNF><natOp>VND SUCATA</natOp><indPag>0</indPag><mod>55</mod><serie>0</serie><nNF>4886</nNF><dEmi>2013-09-11</dEmi><dSaiEnt>2013-09-11</dSaiEnt><hSaiEnt>16:57:00</hSaiEnt><tpNF>1</tpNF><cMunFG>3168705</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>2</cDV><tpAmb>1</tpAmb><finNFe>1</finNFe><procEmi>0</procEmi><verProc>2.22</verProc></ide><emit><CNPJ>07697698000195</CNPJ><xNome>ATA INDUSTRIA MECANICA LTDA</xNome><xFant>ATA</xFant><enderEmit><xLgr>AVENIDA PINHEIRO</xLgr><nro>790</nro><xBairro>DISTRITO INDUSTRIAL</xBairro><cMun>3168705</cMun><xMun>TIMOTEO</xMun><UF>MG</UF><CEP>35181670</CEP><cPais>1058</cPais><xPais>BRASIL</xPais><fone>3138499050</fone></enderEmit><IE>0010319160092</IE><CRT>3</CRT></emit><dest><CNPJ>25191396000203</CNPJ>'
	cXml += '<xNome>SUCATACO LTDA</xNome><enderDest><xLgr>AVENIDA PINHEIRO</xLgr><nro>SN</nro><xCpl>GP A</xCpl><xBairro>LIMOEIRO</xBairro><cMun>3168705</cMun><xMun>TIMOTEO</xMun><UF>MG</UF><CEP>35181402</CEP><cPais>1058</cPais><xPais>BRASIL</xPais></enderDest><IE>6875904950160</IE><email>sucataco@sucataco.com.br;</email></dest><det nItem="1"><prod><cProd>PFA027</cProd><cEAN></cEAN><xProd>SUCATA DE ACO CARBONO</xProd><NCM>72042900</NCM><CFOP>5949</CFOP><uCom>KG</uCom><qCom>12578.0000</qCom><vUnCom>0.50000000</vUnCom><vProd>6289.00</vProd><cEANTrib></cEANTrib><uTrib>KG</uTrib><qTrib>12578.0000</qTrib><vUnTrib>0.50000000</vUnTrib><indTot>1</indTot></prod><imposto><vTotTrib>2018.14</vTotTrib><ICMS><ICMS90><orig>0</orig><CST>90</CST><modBC>3</modBC><vBC>0</vBC><pICMS>0</pICMS><vICMS>0</vICMS><modBCST>0</modBCST><vBCST>0</vBCST><pICMSST>0</pICMSST><vICMSST>0</vICMSST></ICMS90></ICMS><IPI><cEnq>999</cEnq><IPITrib><CST>99</CST><vBC>0</vBC><pIPI>0</pIPI><vIPI>0</vIPI></IPITrib></IPI><PIS><PISOutr><CST>49</CST>'
	cXml += '<vBC>0</vBC><pPIS>0</pPIS><vPIS>0</vPIS></PISOutr></PIS><COFINS><COFINSOutr><CST>49</CST><vBC>0</vBC><pCOFINS>0</pCOFINS><vCOFINS>0</vCOFINS></COFINSOutr></COFINS></imposto></det><total><ICMSTot><vBC>0</vBC><vICMS>0</vICMS><vBCST>0</vBCST><vST>0</vST><vProd>6289.00</vProd><vFrete>0</vFrete><vSeg>0</vSeg><vDesc>0</vDesc><vII>0</vII><vIPI>0</vIPI><vPIS>0</vPIS><vCOFINS>0</vCOFINS><vOutro>0</vOutro><vNF>6289.00</vNF><vTotTrib>2018.14</vTotTrib></ICMSTot></total><transp><modFrete>1</modFrete><transporta><xNome>O PROPRIO</xNome><IE>ISENTO</IE></transporta><veicTransp><placa>GZG8034</placa><UF>MG</UF></veicTransp><vol><qVol>12578</qVol><esp>KG</esp><pesoL>12578.000</pesoL><pesoB>12578.000</pesoB></vol></transp><cobr><dup><nDup>U  000004886</nDup><dVenc>2013-09-11</dVenc><vDup>6289.00</vDup></dup></cobr><infAdic><infCpl>ICMS DIFERIDO CONFORME ARTIGO 218, ANEXO 9, PARTE 1 DO DECRETO I 43080/2002. RICMS/MG. SUSPENSO IPI CONF. ARTIGO 42, INC VI DO RIPI DEC. 4544/02. COND. PAGAMENTO: CONTRA  '
	cXml += 'APRESENTACAO...Projeto(s): 100237 Valor Aproximado dos Tributos: R$ 2018.14 (32.09%) Fonte: IBPT.</infCpl></infAdic><compra></compra></infNFe><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#"><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod><Reference URI="#NFe31130907697698000195550000000048861001266112"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></Transform></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod><DigestValue>6tt5NldNlBkXbTqnxKDI+rxaAAU=</DigestValue></Reference></SignedInfo><SignatureValue>v+K+FUY6kcx7MeViIoslI/zrrppN2F0zBKFAGaxbW073Z/a+n13ej+Yxh1VBU0yZ0E/kiHZqVkUob/'
	cXml += 'DvlLJPOBD4naVXNOv5EsLN9iLrzfbkTpWKkAVIUKwQCVIDfMbU/BU9zJXN637yXWfGxNfOWYdvBW3WY18fI+XzMHvzcjF+iHk2fzHOTe2sgBK68XIUUIptG3LasGHI3wox5SC0kTaxzblvTteDylrXCrQ67kSYsKIfyisTM45iTp5uCZ7Gj4BZnbTbFQE3Y1SZL/Z1h4qSL0h6GrYNfW+cnzoWcDUum6yuKk3RPJfGutNmDHZZLRHvrkYaS1kaxCaSYqiqSw==</SignatureValue><KeyInfo><X509Data><X509Certificate>MIIH9jCCBd6gAwIBAgIIR9l3z5Z8/bwwDQYJKoZIhvcNAQELBQAwdTELMAkGA1UEBhMCQlIxEzARBgNVBAoTCklDUC1CcmFzaWwxNjA0BgNVBAsTLVNlY3JldGFyaWEgZGEgUmVjZWl0YSBGZWRlcmFsIGRvIEJyYXNpbCAtIFJGQjEZMBcGA1UEAxMQQUMgU0VSQVNBIFJGQiB2MjAeFw0xMzA0MjYxODAzMDBaFw0xNDA0MjYxODAzMDBaMIHbMQswCQYDVQQGEwJCUjELMAkGA1UECBMCTUcxEDAOBgNVBAcTB1RJTU9URU8xEzARBgNVBAoTCklDUC1CcmFzaWwxNjA0BgNVBAsTLVNlY3JldGFyaWEgZGEgUmVjZWl0YSBGZWRlcmFsIGRvIEJyYXNpbCAtIFJGQjEWMBQGA1UECxMNUkZCIGUtQ05QSiBBMTETMBEGA1UECxMKQVIgS1JZUFRPTjEzMDEGA1UEAxMqQVRBIElORFVTVFJJQSBNRUNBTklDQSBMVERBOjA3Njk3Njk4MDAwMTk1MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwb9O5T4kWPbTSlIDuAUOjGV/Sed5YHKg8amvKGueZYh2DWiLJm7kIFmFC22brr2JMOOVyodJqJ7fBMI3HiVALLNej'
	cXml += 'SSRZMIlD3ETrHrPNBYRrQHvg968ccWEBKawIfbtySJRCL4kxALj0oCa33g4Dl9m/jLyo67N5qWz9wThef3w/B68v0epfLFBsi9tzb6Uc66tgbbgCctHsMimu6gpelhCwjbzhdE6KBP/6UvaIFieDqtuybRJw9a+H5TSS56a1OoNvkd+pBxa8GMzPWIcI0BnQi9/b/2khhh/uUzu0rYfyLDdYpfNZZ1n04394C8AulPekErx/9bi1U+DvqMvpwIDAQABo4IDITCCAx0wgZkGCCsGAQUFBwEBBIGMMIGJMEgGCCsGAQUFBzAChjxodHRwOi8vd3d3LmNlcnRpZmljYWRvZGlnaXRhbC5jb20uYnIvY2FkZWlhcy9zZXJhc2FyZmJ2Mi5wN2IwPQYIKwYBBQUHMAGGMWh0dHA6Ly9vY3NwLmNlcnRpZmljYWRvZGlnaXRhbC5jb20uYnIvc2VyYXNhcmZidjIwCQYDVR0TBAIwADAfBgNVHSMEGDAWgBSyoMQ9Rp58yIVsCB4QMpRlRnBBczBxBgNVHSAEajBoMGYGBmBMAQIBDTBcMFoGCCsGAQUFBwIBFk5odHRwOi8vcHVibGljYWNhby5jZXJ0aWZpY2Fkb2RpZ2l0YWwuY29tLmJyL3JlcG9zaXRvcmlvL2RwYy9kZWNsYXJhY2FvLXJmYi5wZGYwgfMGA1UdHwSB6zCB6DBKoEigRoZEaHR0cDovL3d3dy5jZXJ0aWZpY2Fkb2RpZ2l0YWwuY29tLmJyL3JlcG9zaXRvcmlvL2xjci9zZXJhc2FyZmJ2Mi5jcmwwRKBCoECGPmh0dHA6Ly9sY3IuY2VydGlmaWNhZG9zLmNvbS5ici9yZXBvc2l0b3Jpby9sY3Ivc2VyYXNhcmZidjIuY3JsMFSgUqBQhk5odHRwOi8vcmVwb3NpdG9yaW8uaWNwYnJhc2lsLmdvdi5ici9sY3IvU2VyYXNhL3JlcG9zaXRvcmlvL2xjci9zZX'
	cXml += 'Jhc2FyZmJ2Mi5jcmwwDgYDVR0PAQH/BAQDAgXgMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDCBugYDVR0RBIGyMIGvgRhDT05UQUJJTElEQURFQEFUQS5JTkQuQlKgIAYFYEwBAwKgFxMVTUFSQ0lPIE5FSVZBIERBIFNJTFZBoBkGBWBMAQMDoBATDjA3Njk3Njk4MDAwMTk1oD0GBWBMAQMEoDQTMjIwMDcxOTc2MDI0NjA4MjY2NjQwMDAwMDAwMDAwMDAwMDAwMDBNODI2OTUzM1NTUE1HoBcGBWBMAQMHoA4TDDAwMDAwMDAwMDAwMDANBgkqhkiG9w0BAQsFAAOCAgEAL7nBvO4RIVg+FlSTuPY2/4t24ZBtVXGkM0kjJRSFbHeTSgeCBi5XhX0rT78Y2mex4rSJJ6ivLXHULYyWEuFgjNI8D2FVSfZUojdzuHxCyocVeVc54qskStKdaLvvUrGcLr4hxBtExw4IxxWPxVpCtrU9Jb9eiko8LGT9HCq/NMaoYFr5wJS4xKasU3OQ96ORct7uUYc6L+DbdCxfoxjC8YI1zO3ddHu3CGVDHAiqgznSozIEw9ndJGRsI8eGNpxFqo1pPJiQlnCGIqt/YqmKTEQSWxOCitLCiuKxqfbjwyJ2PaNZFLSYKjgbGKfj3bc42Fvaidkhi+EuiYFUY1+59dAMk+NsF0qFoETFuD7c9FB+EhMANaUcL8ogxrz95p+TXPzvt71aRLFcPaWDx22ShTmw3jxDHUCx3vSh1PlKzyFAAqow6OLLlp4hDGN/JfxwOb04EBuPl1Bde6gMZ/LLy2M1PqT/+qmqkVN6PR6PuDpg/RsXJyK62QcA85Jml93a8wKC1KaNnyNj97PLCBC6TtQZPlfXgwIMGfhysD2ebX39JU1mSYyTv1oKImjRoBYzl0KYcxVOaafoeTsWbzWWKx/pVl+UljRC21+sEWLd4YDeGY/UlAtgdWrMwlhq4BONP4R'
	cXml += 'tw/aq5yYmodgd9rIXMIzo9uiv9DBZ+0fA4VatNC8=</X509Certificate></X509Data></KeyInfo></Signature></NFe><protNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="2.00"><infProt><tpAmb>1</tpAmb><verAplic>13_0_97</verAplic><chNFe>31130907697698000195550000000048861001266112</chNFe><dhRecbto>2013-09-11T17:04:29</dhRecbto><nProt>131131206870838</nProt><digVal>6tt5NldNlBkXbTqnxKDI+rxaAAU=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></nfeProc>'*/
	
/*	AAdd(aLinha,"Primeira linha do arquivo")
	AAdd(aLinha,"Segunda linha do arquivo")
	AAdd(aLinha,"Terceira linha do arquivo")*/
	
	nArquivo := FCreate("\temp\"+cNomArq+".xml",FC_NORMAL)
	
	if FError() # 0
		MsgAlert("ERRO AO CRIAR O ARQUIVO, ERRO: "+Str(FError()))
		
		lFalha := .T.
	else
		FWrite(nArquivo,cXml)
/*		for nLinha := 1 to Len(aLinha)
			FWrite(nArquivo,aLinha[nLinha]+Chr(13)+Chr(10))
			
			if FError() # 0
				MsgAlert("ERRO GRAVANDO ARQUIVO, ERRO: "+Str(FError()))
				
				lFalha := .T.
			endif
		next*/
	endif
	
	FClose(nArquivo)
return