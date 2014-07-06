/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
RELAÇÃO DE CUSTOMIZAÇÕES
SX2  -->  TABELAS
SX3  -->  CAMPOS
SX6  -->  PARAMETROS
SX7  -->  GATILHOS
SIX  -->  INDICES
SXA  -->  PASTAS


SX1  -->  Perguntas
SXB  -->  Consulta Padrao
SX5  -->  Tabelas
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#include "rwmake.ch"

user function CUSTOMI()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	local cDesc1 := "Este programa tem como objetivo imprimir relatorio "
	local cDesc2 := "de acordo com os parametros informados pelo usuario."
	local cDesc3 := "Relacao de Itens Customizados"
	local cPict := ""
	local nLin := 80
	local titulo := "Relacao de Itens Customizados"
	local Cabec1 := ""
	local Cabec2 := ""
	local imprime := .T.
	local aOrd := {}
	
	private lEnd := .F.
	private lAbortPrint := .F.
	private CbTxt := ""
	private limite := 220
	private tamanho := "G"
	private nomeprog := "CUSTOMI" // Coloque aqui o nome do programa para impressao no cabecalho
	private nTipo := 18
	private aReturn := {"Zebrado",1,"Administracao",2,2,1,"",1}
	private nLastKey := 0
	private cbTxt := Space(10)
	private cbCont := 00
	private CONTFL := 01
	private m_pag := 01
	private wnrel := "CUSTOMI" // Coloque aqui o nome do arquivo usado para impressao em disco
	private cString := ""
	private cPerg   := "CUSTM"
	
	private nImprSX2 := 1
	private nImprSX3 := 1
	private nImprSX6 := 1
	private nImprSX7 := 1
	private nImprSIX := 1
	private nImprSXA := 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	if nLastKey == 27
		return
	endif
	
	SetDefault(aReturn,cString)
	
	if nLastKey == 27
		return
	endif
	
	nTipo := IIf(aReturn[4] == 1,15,18)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nImprSX2 := mv_par01
	nImprSX3 := mv_par02
	nImprSX6 := mv_par03
	nImprSX7 := mv_par04
	nImprSIX := mv_par05
	nImprSXA := mv_par06
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin)},Titulo)
return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o ³RUNREPORT º Autor ³ AP6 IDE º Data ³ 15/01/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º ³ monta a janela com a regua de processamento. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso ³ Programa principal º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function RunReport(Cabec1,Cabec2,Titulo,nLin)
	local _nRecCount := 0
	
	DbSelectArea("SX2")					// TABELAS
	DbSelectArea("SX3")					// CAMPOS
	DbSelectArea("SX6")					// PARAMETROS
	DbSelectArea("SX7")					// GATILHOS
	DbSelectArea("SIX")					// INDICES
	DbSelectArea("SXA")					// PASTAS
	
	_nRecCount += IIf(nImprSX2 == 1,SX2->(RecCount()),0)
	_nRecCount += IIf(nImprSX3 == 1,SX3->(RecCount()),0)
	_nRecCount += IIf(nImprSX6 == 1,SX6->(RecCount()),0)
	_nRecCount += IIf(nImprSX7 == 1,SX7->(RecCount()),0)
	_nRecCount += IIf(nImprSIX == 1,SIX->(RecCount()),0)
	_nRecCount += IIf(nImprSXA == 1,SXA->(RecCount()),0)
	
	SetRegua(_nRecCount)
	DbSelectArea("SM0")					// EMPRESA-FILIAL
	DbSeek(cEmpAnt+cFilAnt)
	
	_cNome := AllTrim(SM0->M0_NOMECOM)+" - EMPRESA: "+cEmpAnt
	_lImp := .T.
	_nPag := 1
	
	if nImprSX2 == 1
		DbSelectArea("SX2")
		DbSetOrder(1)
		SX2->(DbGoTop())
		
		while SX2->(!Eof())
			IncRegua()
			
			if SubStr(SX2->X2_CHAVE,1,2) <> "SZ" .and. SubStr(SX2->X2_CHAVE,1,2) <> "UZ"					// TABELAS CUSTOMIZADAS PELO USUARIO
				SX2->(DbSkip())
				
				loop
			endif
			
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif
			
			if nLin > 60					// Salto de Página. Neste caso o formulario tem 55 linhas...
				//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				
				nLin := 1
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin++
				
				@nLin,001 psay "*"+" DATA: "+DToC(dDataBase)
				@nLin,092 psay "ALTERACOES NO DICIONARIO DE DADOS"
				@nLin,207 psay "PAGINA: "+Transf(_nPag,"@E 999")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay "*"+" HORA: "+Time()
				@nLin,190 psay "USO EXCLUSIVO - "+IIf(cEmpAnt == "01","ATA IND MEC","ATF EST MET")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin := nLin + 2
				_nPag++
			endif
			
			if _lImp
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "TABELAS CRIADAS PARA EMPRESA "+AllTrim(Upper(_cNome))
				
				nLin++
				
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "TABELA   PATH           ARQUIVO    NOME                             MODO   UNICO"
				
				// TABELA   PATH           ARQUIVO    NOME                             MODO   UNICO
				// AAA      AAAAAAAAAAAA   AAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   A      
				// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				
				_lImp := .F.
				nLin++
			endif
			
			@nLin,001 psay AllTrim(SX2->X2_CHAVE)
			@nLin,010 psay Left(SX2->X2_PATH,12)
			@nLin,025 psay SX2->X2_ARQUIVO
			@nLin,036 psay SX2->X2_NOME
			@nLin,069 psay SX2->X2_MODO
			@nLin,076 psay AllTrim(SX2->X2_UNICO)
			
			nLin++
			
			SX2->(DbSkip())
		enddo
		
		nLin++
		_lImp := .T.
	endif
	
	if nImprSX3 == 1
		DbSelectArea("SX3")
		DbSetOrder(1)
		SX3->(DbGoTop())
		
		while SX3->(!Eof())
			IncRegua()
			
			if SX3->X3_PROPRI <> "U"					// MARCAÇÃO PARA CAMPOS CRIADOS POR USUARIO
				SX3->(DbSkip())
				
				loop
			endif
			
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif
			
			if nLin > 60					// Salto de Página. Neste caso o formulario tem 55 linhas...
				//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				
				nLin := 1
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin++
				
				@nLin,001 psay "*"+" DATA: "+DToC(dDataBase)
				@nLin,092 psay "ALTERACOES NO DICIONARIO DE DADOS"
				@nLin,207 psay "PAGINA: "+Transf(_nPag,"@E 999")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay "*"+" HORA: "+Time()
				@nLin,190 psay "USO EXCLUSIVO - "+IIf(cEmpAnt == "01","ATA IND MEC","ATF EST MET")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin := nLin + 2
				_nPag++
			endif
			
			if _lImp
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "CAMPOS CRIADOS PARA EMPRESA "+AllTrim(Upper(_cNome))
				
				nLin++
				
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "CAMPO        TP   TAM DEC   TITULO         DESCRICAO                   PICTURE                          VALIDACAO USUARIO"
				
				// CAMPO        TP   TAM DEC   TITULO         DESCRICAO                   PICTURE                          VALIDACAO USUARIO
				// AAAAAAAAAA   A    999  9    AAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
				// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				
				_lImp := .F.
				nLin++
			endif
			
			@nLin,001 psay SX3->X3_CAMPO
			@nLin,014 psay SX3->X3_TIPO
			@nLin,019 psay SX3->X3_TAMANHO picture "@E 999"
			@nLin,024 psay SX3->X3_DECIMAL picture "@E 9"
			@nLin,029 psay SX3->X3_TITULO
			@nLin,044 psay SX3->X3_DESCRIC
			@nLin,072 psay Left(SX3->X3_PICTURE,30)
			@nLin,105 psay Left(SX3->X3_VLDUSER,110)
			
			nLin++
			
			SX3->(DbSkip())
		enddo
		
		nLin++
		_lImp := .T.
	endif
	
	if nImprSXA == 1
		DbSelectArea("SXA")
		DbSetOrder(1)
		SXA->(DbGoTop())
		
		while SXA->(!Eof())
			IncRegua()
			
			if SXA->XA_PROPRI <> "U"					// MARCAÇÃO PARA CAMPOS CRIADOS POR USUARIO
				SXA->(DbSkip())
				
				loop
			endif
			
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif
			
			if nLin > 60					// Salto de Página. Neste caso o formulario tem 55 linhas...
				//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				
				nLin := 1
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin++
				
				@nLin,001 psay "*"+" DATA: "+DToC(dDataBase)
				@nLin,092 psay "ALTERACOES NO DICIONARIO DE DADOS"
				@nLin,207 psay "PAGINA: "+Transf(_nPag,"@E 999")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay "*"+" HORA: "+Time()
				@nLin,190 psay "USO EXCLUSIVO - "+IIf(cEmpAnt == "01","ATA IND MEC","ATF EST MET")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin := nLin + 2
				_nPag++
			endif
			
			if _lImp
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "PASTAS CRIADAS PARA EMPRESA "+AllTrim(Upper(_cNome))
				
				nLin++
				
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "ALIAS   ORDEM   DESCRICAO"
				
				// ALIAS   ORDEM   DESCRICAO
				// AAA       A     AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
				// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				
				_lImp := .F.
				nLin++
			endif
			
			@nLin,001 psay SXA->XA_ALIAS
			@nLin,011 psay SXA->XA_ORDEM picture "@E 9"
			@nLin,017 psay SXA->XA_DESCRIC
			
			nLin++
			
			SXA->(DbSkip())
		enddo
		
		nLin++
		_lImp := .T.
	endif
	
	if nImprSX6 == 1
		DbSelectArea("SX6")
		DbSetOrder(1)
		SX6->(DbGoTop())
		
		while SX6->(!Eof())
			IncRegua()
			
			if SX6->X6_PROPRI <> "U"
				SX6->(DbSkip())
				
				loop
			endif
			
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif
			
			if nLin > 60					// Salto de Página. Neste caso o formulario tem 55 linhas...
				//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				
				nLin := 1
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin++
				
				@nLin,001 psay "*"+" DATA: "+DToC(dDataBase)
				@nLin,092 psay "ALTERACOES NO DICIONARIO DE DADOS"
				@nLin,207 psay "PAGINA: "+Transf(_nPag,"@E 999")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay "*"+" HORA: "+Time()
				@nLin,190 psay "USO EXCLUSIVO - "+IIf(cEmpAnt == "01","ATA IND MEC","ATF EST MET")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin := nLin + 2
				_nPag++
			endif
			
			if _lImp
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "PARAMETROS CRIADOS PARA EMPRESA "+AllTrim(Upper(_cNome))
				
				nLin++
				
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "VARIAVEL    TIPO DESCRICAO                                                                                                   CONTEUDO"
				
				// VARIAVEL    TIPO DESCRICAO                                                                                                   CONTEUDO
				// AAAAAAAAAA  A    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
				// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				
				_lImp := .F.
				nLin++
			endif
			
			aDescConte := {}
			cDescricao := AllTrim(SX6->X6_DESCRIC)+AllTrim(SX6->X6_DESC1)+AllTrim(SX6->X6_DESC2)
			cConteudo := AllTrim(SX6->X6_CONTEUD)
			
			if MlCount(cDescricao,100) >= MlCount(cConteudo,90)
				for k := 1 to MlCount(cDescricao,100)
					AAdd(aDescConte,{"",""})
				next
			else
				for k := 1 to MlCount(cConteudo,90)
					AAdd(aDescConte,{"",""})
				next
			endif
			
			for k := 1 to MlCount(cDescricao,100)
				aDescConte[k][1] := MemoLine(cDescricao,100,k)
			next
			
			for k := 1 to MlCount(cConteudo,90)
				aDescConte[k][2] := MemoLine(cConteudo,90,k)
			next
			
			@nLin,001 psay SX6->X6_VAR
			@nLin,013 psay SX6->X6_TIPO
			
			for k := 1 to Len(aDescConte)
				@nLin,018 psay aDescConte[k][1]
				@nLin,126 psay aDescConte[k][2]
				
				nLin++
				
				if nLin > 60					// Salto de Página. Neste caso o formulario tem 55 linhas...
					//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					
					nLin := 1
					
					@nLin,001 psay Replicate("*",LIMITE - 1)
					
					nLin++
					
					@nLin,001 psay "*"+" DATA: "+DToC(dDataBase)
					@nLin,092 psay "ALTERACOES NO DICIONARIO DE DADOS"
					@nLin,207 psay "PAGINA: "+Transf(_nPag,"@E 999")
					@nLin,219 psay "*"
					
					nLin++
					
					@nLin,001 psay "*"+" HORA: "+Time()
					@nLin,190 psay "USO EXCLUSIVO - "+IIf(cEmpAnt == "01","ATA IND MEC","ATF EST MET")
					@nLin,219 psay "*"
					
					nLin++
					
					@nLin,001 psay Replicate("*",LIMITE - 1)
					
					nLin := nLin + 2
					_nPag++
					
					@nLin,001 psay "VARIAVEL    TIPO DESCRICAO                                                                                                   CONTEUDO"
					
					nLin++
				endif
			next
			
			SX6->(DbSkip())
		enddo
		
		nLin++
		_lImp := .T.
	endif
	
	if nImprSX7 == 1
		DbSelectArea("SX7")
		DbSetOrder(1)
		SX7->(DbGoTop())
		
		while SX7->(!Eof())
			IncRegua()
			
			if SX7->X7_PROPRI <> "U"
				SX7->(DbSkip())
				
				loop
			endif
			
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif
			
			if nLin > 60					// Salto de Página. Neste caso o formulario tem 55 linhas...
				//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				
				nLin := 1
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin++
				
				@nLin,001 psay "*"+" DATA: "+DToC(dDataBase)
				@nLin,092 psay "ALTERACOES NO DICIONARIO DE DADOS"
				@nLin,207 psay "PAGINA: "+Transf(_nPag,"@E 999")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay "*"+" HORA: "+Time()
				@nLin,190 psay "USO EXCLUSIVO - "+IIf(cEmpAnt == "01","ATA IND MEC","ATF EST MET")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin := nLin + 2
				_nPag++
			endif
			
			if _lImp
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "GATILHOS CRIADOS PARA EMPRESA "+AllTrim(Upper(_cNome))
				
				nLin++
				
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "CAMPO      SEQ  REGRA                                                                       ALVO        CHAVE                                                                       CONDICAO"
				
				// CAMPO      SEQ  REGRA                                                                       ALVO        CHAVE                                                                       CONDICAO
				// AAAAAAAAAA AAA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
				// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				
				_lImp := .F.
				nLin++
			endif
			
			@nLin,001 psay SX7->X7_CAMPO
			@nLin,012 psay SX7->X7_SEQUENCIA
			@nLin,017 psay Left(SX7->X7_REGRA,70)
			@nLin,093 psay SX7->X7_CDOMIN
			@nLin,105 psay Left(SX7->X7_CHAVE,70)
			@nLin,181 psay SX7->X7_CONDIC
			
			nLin++
			
			SX7->(DbSkip())
		enddo
		
		nLin++
		_lImp := .T.
	endif
	
	if nImprSIX == 1
		DbSelectArea("SIX")
		DbSetOrder(1)
		SIX->(DbGoTop())
		
		while SIX->(!Eof())
			IncRegua()
			
			if SIX->PROPRI <> "U"
				SIX->(DbSkip())
				
				loop
			endif
			
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif
			
			if nLin > 60					// Salto de Página. Neste caso o formulario tem 55 linhas...
				//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				
				nLin := 1
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin++
				
				@nLin,001 psay "*"+" DATA: "+DToC(dDataBase)
				@nLin,092 psay "ALTERACOES NO DICIONARIO DE DADOS"
				@nLin,207 psay "PAGINA: "+Transf(_nPag,"@E 999")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay "*"+" HORA: "+Time()
				@nLin,190 psay "USO EXCLUSIVO - "+IIf(cEmpAnt == "01","ATA IND MEC","ATF EST MET")
				@nLin,219 psay "*"
				
				nLin++
				
				@nLin,001 psay Replicate("*",LIMITE - 1)
				
				nLin := nLin + 2
				_nPag++
			endif
			
			if _lImp
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "INDICES CRIADOS PARA EMPRESA "+AllTrim(Upper(_cNome))
				
				nLin++
				
				@nLin,001 psay Replicate("=",LIMITE)
				
				nLin++
				
				@nLin,001 psay "INDICE   ORDEM   NICKNAME     CHAVE                                                                    DESCRICAO"
				
				// INDICE   ORDEM   NICKNAME     CHAVE                                                                    DESCRICAO
				// AAA      A       AAAAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
				// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				
				_lImp := .F.
				nLin++
			endif
			
			@nLin,001 psay SIX->INDICE
			@nLin,010 psay SIX->ORDEM
			@nLin,018 psay SIX->NICKNAME
			@nLin,031 psay Left(SIX->CHAVE,70)
			@nLin,104 psay Left(SIX->DESCRICAO,70)
			
			nLin++
			
			SIX->(DbSkip())
		enddo
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	set device to screen
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if aReturn[5] == 1
		DbCommitAll()
		
		set printer to
		
		OurSpool(wnrel)
	endif
	
	MS_Flush()
return