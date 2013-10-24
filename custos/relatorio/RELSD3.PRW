/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Rel. verifica SD3 sem CODESP e sem C.C                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch" 
#include "topconn.ch"

User Function RELSD3()

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
	private Cabec1  := "T.M  CODIGO   MATERIAL                              REGISTROS       VALOR"
	private Cabecx  := "T.M  CODIGO   MATERIAL                              CHAVE           VALOR"   
	private cDesc1  := "REQUISIÇÕES SEM CODESP"
	private cString := "SD3"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "relSD3"
	private lAborta := .F.
	

	nOpc:= Aviso("Cód. Despesas","Lista de Requisições sem COD.DESP e C.CUSTO. Escolha a Listagem desejada",{"Cod.Desp.", "C. de Custo","Sair"})

	If (nOpc == 0) .or. (nOpc == 3)
	   Return
	EndIf      

	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
    If empty(mv_par01)      
        msgbox('Parâmetro não foi informado.')
        return
    endif

	cDatade	 := dTos(mv_par01)
    cabec2	 := 'A partir de: '+dtoc(mv_par01)

	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]

	If (nOpc == 1)

		Titulo  := "REQUISIÇÕES SEM CODESP" 
    
    Else

		Titulo  := "REQUISIÇÕES SEM C.CUSTO"
		Cabec1	:= Cabecx 
    
    EndIf
    
	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	Processa({|| ImprL()},"","Aguarde. Imprimindo...",lAborta)
   	Roda(0,"",Tamanho)


	set device to screen
	
	If lAborta    
		Ms_Flush()
		return
	EndIf
	
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

	cQry := "SELECT D3_TM TM,D3_COD COD, B1_DESC PRODUTO,B1_CODESP CODESP,COUNT(*) QTDE, SUM(D3_CUSTO1) VALOR "
	cQry += "FROM SD3010 SD3 JOIN SB1010 SB1 ON B1_COD=D3_COD "
    cQry += " WHERE D3_TM IN ('501','002') AND D3_ESTORNO<>'S' AND D3_CODESP='' AND D3_EMISSAO >= '"+cDatade+"' AND SD3.D_E_L_E_T_ <> '*' "
    cQry += " GROUP BY D3_TM,D3_COD,B1_DESC,B1_CODESP "
    cQry += " ORDER BY B1_DESC "

Else 

	cQry := "SELECT D3_TM TM,D3_COD COD, B1_DESC PRODUTO,D3_NUMSEQ NSEQ, D3_CUSTO1 VALOR "
	cQry += "FROM SD3010 SD3 JOIN SB1010 SB1 ON B1_COD=D3_COD "
    cQry += " WHERE D3_TM IN ('501','002') AND D3_ESTORNO<>'S' AND D3_CC='' AND D3_EMISSAO >= '"+cDatade+"' AND SD3.D_E_L_E_T_ <> '*' "
    cQry += " ORDER BY B1_DESC "

EndIf      

	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	DbGoTop()
	ProcRegua(SZI->(RecCount()))
	             
	nConta := 0
	While TEMP->( !Eof() )
	
	        if nOpc == 1 .and. !Empty(TEMP->CODESP)
	           	
	           	nConta 	:= nConta + 1         
	           	cDesp	:= TEMP->CODESP
	           	cCod	:= TEMP->COD
	           
				// update SD3
				cUPD := "update "+RetSqlName("SD3")
				cUPD += " set D3_CODESP = '"+cDesp+"' " 
 				cUPD += " where D3_COD='"+cCod+"' AND D3_TM IN('501','002') AND D3_ESTORNO<>'S' AND D3_EMISSAO >= '"+cDatade+"' "
        
				TCSqlExec(cUPD)	  				
			
	        	DbSelectArea("TEMP")
	        	TEMP->(DbSkip())
	        	Loop
	        EndIf	

			@Prow()+1,000 	   	psay TEMP->TM
 			@Prow()  ,Pcol()+2 	psay LEFT(TEMP->COD,6)
 			@Prow()  ,Pcol()+3 	psay LEFT(TEMP->PRODUTO,35)
			if nOpc == 1
				@Prow()  ,Pcol()+3 	psay TEMP->QTDE picture "@E 999999999"
			Else	
				@Prow()  ,Pcol()+3 	psay iif(nOpc=2,'1R-'+TEMP->NSEQ,'         ')
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

