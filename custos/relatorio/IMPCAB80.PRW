/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 27/02/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cabeçalho de 80/132 colunas para impressora EPSON      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"


User Function ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
 
   	If cEmp = '01'
   		cNomeEmp := 'A T A'
   		cTipEmp  := "IND. MECANICA"
   	Else 
   		cNomeEmp := 'A T F'   	
   		cTipEmp  := "ESTR.METALICAS"
   	EndIf
 
    @000,000 PSay U_TamPag(66)+U_Reduz(0)				// P/ EPSON 
	//  Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	//	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	//	@prow()+1,000 psay U_Negrito(.T.)+Padc("T i T U L O  DO R E L A T o R I O",80)+U_Negrito(.F.)
  	//	@prow()+1,000 psay U_expande(5)+'x'+U_expande(0)
     
    	@001,000 psay "*"+replicate('-',78)+"*"
//    	@002,000 psay "|"+U_AltCar(24)+U_Expande(5)+cNomeEmp+U_Expande(0)+U_AltCar(12)                 
    	@002,000 psay "|"+cNomeEmp                 
    	@002,062 psay "Pagina.: "+strzero(m_pag,3)
    	@002,079 psay "|"
                      
//	    @003,000 psay "|"+U_Reduz(5)+cTipEmp+U_Reduz(0)+U_AltCar(12)
	    @003,000 psay "|"+cTipEmp
    	@003,pcol()+1 psay '     '       
	    @003,(80-len(titulo))/2 psay Titulo       
    	@003,062 psay "Emissao: "+dtoc(ddatabase)
	    @003,079 psay "|"

    	@004,000 psay "*"+replicate('-',78)+"*"

	If Tamanho == 'P'

	    @prow()+1,000 psay cxCabec1      
    	@prow()+1,000 psay cxCabec2
    	@prow()+1,000 psay repli('-',80)

	Else
	
	    @prow()+1,000 psay U_Reduz(5)+cxCabec1+U_Reduz(0)
	    If !Empty(cxCabec2)      
    		@prow()+1,000 psay U_Reduz(5)+cxCabec2+U_Reduz(0)
    	EndIf
    	@prow()+1,000 psay U_Reduz(5)+repli('-',nComp)+U_Reduz(0)
   
	EndIf  
return