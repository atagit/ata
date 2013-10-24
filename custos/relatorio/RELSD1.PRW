/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Rel. verifica SD1 sem CODESP e sem C.Custo            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

/*          
	E ATUALIZA:
		D1_CODESP = '061015' ( FRETE DE PRODUTO ) ONDE D1_CF='1352,2352'
	    ( atualiza antes de executar o relatórios )
	Obs: Crítica para preenchimento de D1_CC, onde F4_DUPLIC=SIM E F4_ESTOQUE=NÃO:
		 - utilizar PONTO DE ENTRADA, observando que Patrimônio CF='1406','2406','1551','2551'
		   ( checar esses CFs) não precisa do C.C ( ver procedimento com Arizio)

*/

#include "rwmake.ch" 
#include "topconn.ch"

User Function RELSD1()

	private nTotal 	:= 0
	private nValor 	:= 0.00
	private aOrd    := {}
	private cTab   	:= " "
    private cQry	:= ''
    private cAnomes := ""
    private cDatade := ''
    private cCde    := ""
    private cCate   := ""
    private cUnid   := ""
    private cDescUn := ""
	private aReturn := {"Especial", 1,"Administracao", 1, 2, 1, "", 2}
	private cPerg   := "SZB002"
	private Cabec2  := ""
	private Cabec1  := "TES  CODIGO   MATERIAL                              REGISTROS       VALOR"
	private Cabecx  := "TES  CODIGO   MATERIAL                              CHAVE           VALOR"   
	private cDesc1  := "ITENS DE NF SEM CODESP"
	private cString := "SD3"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "RELSD1"
	private lAborta := .F.
	

	nOpc:= Aviso("Cód. Despesas","Lista itens de N.F. sem COD.DESP e C.CUSTO. Escolha a Listagem desejada",{"Cod.Desp.", "C. de Custo","Sair"})

	If (nOpc == 0) .or. (nOpc == 3)
	   Return
	EndIf      

	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
    If empty(mv_par01) .OR. empty(mv_par02)   
        msgbox('Parâmetros não foram informados.')
        return
    endif

	cDatade	 := dTos(mv_par01)
    cabec2	 := 'A partir de: '+dtoc(mv_par01)+'-Critério = [TES->(Duplicata=SIM e Estoque=NÃO]'
	nEmp 	 := mv_par02
	cNomeEmp := iif(nEmp=1,'ATA','ATF')

	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]

	If (nOpc == 1)

		Titulo  := cNomeEmp+"-ITENS DE NF SEM CODESP" 
    
    Else

		Titulo  := cNomeEmp+" -ITENS DE NF SEM C.CUSTO" 
    	Cabec1	:= Cabecx
    EndIf 
    
	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	Processa({|| ImprL()},"","Aguarde. Imprimindo...",lAborta)
   	Roda(0,"",Tamanho)


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


Static Function ImprL()


If nOpc == 1 

	// atualiza COD.DESP para REGISTROS DE FRETE
	codesp()
	
	cQry := "SELECT D1_TES TES,D1_COD COD, D1_DESCPRO PRODUTO,B1_CODESP CODESP,COUNT(*) QTDE, SUM(D1_TOTAL) VALOR "
	if nEmp == 1
	   cQry += "FROM SD1010 SD1 JOIN SB1010 SB1 ON B1_COD=D1_COD "
	else
	   cQry += "FROM SD1020 SD1 JOIN SB1010 SB1 ON B1_COD=D1_COD "
	endif
	cQry += "                JOIN SF4010 SF4 ON F4_CODIGO=D1_TES "
    cQry += " WHERE D1_CODESP='' AND D1_CF NOT IN ('1352','2352') AND D1_EMISSAO >= '"+cDatade+"' AND SD1.D_E_L_E_T_ <> '*' AND "
    cQry += " F4_DUPLIC = 'S' AND F4_ESTOQUE = 'N'  "
    cQry += " GROUP BY D1_TES,D1_COD,D1_DESCPRO,B1_CODESP "
    cQry += " ORDER BY D1_COD "

Else 

	cQry := "SELECT D1_TES TES,D1_COD COD, D1_DESCPRO PRODUTO,D1_NUMSEQ NSEQ, D1_TOTAL VALOR "
	if nEmp == 1
	   cQry += "FROM SD1010 SD1 JOIN SB1010 SB1 ON B1_COD=D1_COD "
	else
	   cQry += "FROM SD1020 SD1 JOIN SB1010 SB1 ON B1_COD=D1_COD "
	endif
	cQry += "                JOIN SF4010 SF4 ON F4_CODIGO=D1_TES "
    cQry += " WHERE D1_CC='' AND D1_EMISSAO >= '"+cDatade+"' AND SD1.D_E_L_E_T_ <> '*' AND "
    cQry += " F4_DUPLIC='S' AND F4_ESTOQUE='N'  "
    cQry += " ORDER BY D1_COD "

EndIf      

	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	DbGoTop()
	ProcRegua(TEMP->(RecCount()))
	
	nConta := 0
	While TEMP->( !Eof() )
	
	        if nOpc == 1 .and. !Empty(TEMP->CODESP)
	           	
	           	nConta 	:= nConta + 1         
	           	cDesp	:= TEMP->CODESP
	           	cCod	:= TEMP->COD
	           
				// update SD1

				If nEmp == 1
				   	cUPD := "update SD1010 "
				Else
					cUPD := "update SD1020 "
				EndIf
				cUPD += " set D1_CODESP = '"+cDesp+"' " 
 				cUPD += " where D1_COD='"+cCod+"' AND D1_EMISSAO >= '"+cDatade+"' "

				TCSqlExec(cUPD)	 
			
	        	DbSelectArea("TEMP")
	        	IncProc()
	        	TEMP->(DbSkip())
	        	Loop
	        EndIf

			@Prow()+1,000 	   	psay TEMP->TES
 			@Prow()  ,Pcol()+2 	psay LEFT(TEMP->COD,6)
 			@Prow()  ,Pcol()+3 	psay TEMP->PRODUTO+'     '         //cDesc
			if nOpc == 1
				@Prow()  ,Pcol()+3 	psay TEMP->QTDE picture "@E 999999999"
			Else	
				@Prow()  ,Pcol()+3 	psay iif(nOpc=2,str(nEmp,1)+'N-'+TEMP->NSEQ,'         ')
			EndIf
			@Prow()  ,Pcol()+2 	psay TEMP->VALOR picture "@E 999,999.99" 
			
			nTotal += if(nOpc=1,TEMP->QTDE,1)
			nValor += TEMP->VALOR
			 
			IncProc()
		
			TEMP->(DbSkip())

		    If ( !TEMP->(Eof()) ) .and. ( (Prow() >= 55) )
			  Roda(0,"",Tamanho)
		      Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		    endif

	Enddo
	@Prow()+1,000 	   	psay space(3)
	@Prow()  ,Pcol()+2 	psay space(6)
	@Prow()  ,Pcol()+3 	psay 'Total ....'+space(25)
	if nOpc ==1
	   @Prow()  ,Pcol()+3 	psay nTotal picture "@E 999999999"
	Else
	   @Prow()  ,Pcol()+3 	psay space(9)
	EndIf
	@Prow()  ,Pcol()+2 	psay nVALOR picture "@E 999,999.99" 
    
    if !nConta = 0
       msgbox('Atualizados: '+str(nConta,5))
    EndIf
    
Return


Static Function CODESP()

	cUPD := "update SD1010 "
	cUPD += " set D1_CODESP = '061015' " 
	cUPD += " where LEFT(D1_COD,3)<>'SER' AND D1_EMISSAO >= '"+cDatade+"' AND "
	cUPD += " D1_CF IN ('1352','2352') "

	TCSqlExec(cUPD)	 
     
	cUPD := "update SD1020 "
	cUPD += " set D1_CODESP = '061015' " 
	cUPD += " where LEFT(D1_COD,3)<>'SER' AND D1_EMISSAO >= '"+cDatade+"' AND "
	cUPD += " D1_CF IN ('1352','2352') "

	TCSqlExec(cUPD)	 

Return


