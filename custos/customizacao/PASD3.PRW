/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                       ¦ Data ¦ 15/03/12 ¦
   +----------+--------------------------------------------------------¦
   ¦Descrição ¦ Atualiza D3_CC E D1_CC em branco                       ¦
   ¦            SD3: chave para atualização: D3_NUMSEQ: 1R-NNNNNN      ¦
   :            SD1: chave para atualização: D1_NUMSEQ: 1N-NNNNNN (ATA)|
   :                                       : D1_NUMSEQ: 2N-NNNNNN (ATF)|
   :            UPDATE: onde CHAVE=acima e _CC=branco                     
   
                --> ATENÇÃO: SD1 é exclusivo
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
  */
#include "rwmake.ch"
#include "topconn.ch"

user function PASD3

	local cQry 	:= ''
	local cTab	:= ''
	local cUpd	:= ''
	local cCod	:= ''
	local cDesp := ''
	local lAborta := .F.          
 	private cPerg	:= 'SZB001'
		
	If !Pergunte(cPerg)
	   msgbox('Parâmetros não foram informados.')
	   Return
	EndIf
    
   	If Empty(mv_par01) .or. Empty(mv_par02)   
	   msgbox('Algum parâmetro não foi informado.')
	   return
   	endif                      
	
	Processa({|| atualiza()},"","Aguarde. Processando ...",lAborta)

	// FALTA ATUALIZAR QRY UPDATE 
	
	msgbox('Rotina para atualização não foi ainda concluida...')
    
    Return

                          
static function atualiza()

		incproc()
                                    
		cEmp	:= Left(mv_par01,1)
		cArq	:= substr(mv_par01,2,1)			// onde, R=SD3; N=SD1
		cChave	:= right(mv_par01,6)
		cCusto	:= mv_par02
		
		// CHECAR cCUSTO CTT .....
		 
        
		// update SD3
		cUPD := "update "+RetSqlName("SD3")
		cUPD += " set D3_CODESP = '"+cDesp+"' " 
 		cUPD += " where D3_COD='"+cCod+"' AND D3_TM IN('501','002') AND D3_ESTORNO<>'S' AND D3_EMISSAO >= '20120301' "
        
		TCSqlExec(cUPD)	 

		incproc()


		// update SD1
   		cUPD := ""
		cUPD := "update "+RetSqlName("SD1")
		cUPD += " set D1_CODESP = '"+cDesp+"' " 
 		cUPD += " where D1_COD='"+cCod+"' AND D1_EMISSAO >= '20120301' "

		TCSqlExec(cUPD)	 

		incproc()

return
            
