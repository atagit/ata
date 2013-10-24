/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/12/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de fornecedores por região                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function FORREG()
	private aOrd    := {"Regiao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "FORREG"
	private Cabec1  := "CNPJ               | RAZAO SOCIAL                                                           | CODIGO"
	private Cabec2  := ""
	private cDesc1  := "FORNECEDOR P/ REGIAO"
	private ContFun := 0
	private cString := "SA2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cRegIni := ""
	private cRegFin := ""
	private nTipo := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Regiao de                                         ³
	//³ mv_par02 - Regiao ate                                        ³
	//³ mv_par03 - Tipo (1-Fornecedor/2-Cliente)                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cRegIni := mv_par01
	cRegFin := mv_par02
	nTipo := mv_par03
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
	
	set device to screen
	
	if aReturn[5] == 1
		set printer to
		
		DbCommitAll()
		DbCloseArea()
		OurSpool(wnrel)
	else
		DbCloseArea()
	endif
	
	Ms_Flush()
return

static function Impr()
	if nTipo == 1		//Fornecedor
		cQry := "select X5_CHAVE, X5_DESCRI, A2_TIPO as TIPO, A2_COD as COD, A2_LOJA as LOJA, A2_CGC as CGC, A2_NOME as NOME, A2_NREDUZ "
		cQry += "from "+RetSqlName("SA2")+" SA2 inner join "+RetSqlName("SX5")+" SX5 on (A2_REGIAO = X5_CHAVE) "
		cQry += "where (X5_CHAVE between '"+cRegIni+"' and '"+cRegFin+"') and X5_TABELA = 'MR' and A2_MSBLQL <> '1' and SA2.D_E_L_E_T_ <> '*' and SX5.D_E_L_E_T_ <> '*' "
		cQry += "order by X5_CHAVE, A2_NOME"
	elseif nTipo == 2	//Clientee
		cQry := "select X5_CHAVE, X5_DESCRI, A1_PESSOA as TIPO, A1_COD as COD, A1_LOJA as LOJA, A1_CGC as CGC, A1_NOME as NOME, A1_NREDUZ "
		cQry += "from "+RetSqlName("SA1")+" SA1 inner join "+RetSqlName("SX5")+" SX5 on (A1_REGIAO = X5_CHAVE) "
		cQry += "where (X5_CHAVE between '"+cRegIni+"' and '"+cRegFin+"') and X5_TABELA = 'MR' and A1_MSBLQL <> '1' and SA1.D_E_L_E_T_ <> '*' and SX5.D_E_L_E_T_ <> '*' "
		cQry += "order by X5_CHAVE, A1_NOME"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	while !TEMP->(Eof())
		cRegiao := TEMP->X5_CHAVE
		
//		REGIAO: 99A AAAAAAAAAAAAAAAAAAAA
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay U_Negrito(.T.)+"REGIAO: "+AllTrim(cRegiao)+" "+AllTrim(TEMP->X5_DESCRI)+U_Negrito(.F.)
		
		nLin++
		
		U_SaltaFolha()
		
		while TEMP->X5_CHAVE == cRegiao
//		    CNPJ               | RAZAO SOCIAL                                                           | CODIGO
//		    99.999.999/9999-99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999999-99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			if TEMP->TIPO == "J"
				@nLin,000 psay Transf(TEMP->CGC,"@R 99.999.999/9999-99")
			elseif TEMP->TIPO == "F"
				@nLin,000 psay Transf(TEMP->CGC,"@R 999.999.999-99")
			else
				@nLin,000 psay Transf(TEMP->CGC,"@R 99999999999999")
			endif
			
			@nLin,021 psay TEMP->NOME
			@nLin,094 psay TEMP->COD+"-"+TEMP->LOJA
			
			nLin++
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return