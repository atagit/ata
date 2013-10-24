/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Tela para lançamento do frete                         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function FRETE(cTitulo,cCotacao,cFornece,cLojaForn,cTabela)
	local nLinini := 10
	
	private cTransp := space(6)
	private nVlFrete := 0
	private oDlg
	
	@010,010 to 160,260 dialog oDlg title "VALOR DO FRETE"
		@005,020 to 020,110
		@nLinini,029 say cTitulo+": "+cCotacao+"/"+cFornece+"-"+cLojaForn
		
		nLinini += 17
		@nLinini,010 say "Transport"
		@nLinini-2,040 get cTransp picture "@E 999999" size 30,07 F3 "SA4"
		
		nLinini += 13
		@nLinini,010 say "Total Frete"
		@nLinini-2,040 get nVlFrete picture "@E 999,999,999.99" size 40,07
		
		nLinini += 17
		@nLinini,061 bmpbutton type 01 action Gravar(cCotacao,cFornece,cLojaForn,cTransp,nVlFrete,cTabela)
		@nLinini,091 bmpbutton type 02 action Close(oDlg)
	activate dialog oDlg center
return

static function Gravar(cCotacao,cFornece,cLojaForn,cTransp,nVlFrete,cTabela)
	dbselectarea("SZ1")
	
	if !empty(cTransp)
		if !empty(nVlFrete)
			if SZ1->(dbseek(xFilial("SZ1")+cCotacao+cFornece+cLojaForn,.F.))
				if reclock("SZ1",.F.)
					replace SZ1->Z1_FILIAL with xFilial("SZ1"),;
							SZ1->Z1_COTACAO with cCotacao,;
							SZ1->Z1_FORNECE with cFornece,;
							SZ1->Z1_LOJA with cLojaForn,;
							SZ1->Z1_TRANSP with cTransp,;
							SZ1->Z1_VLFRETE with nVlFrete,;
							SZ1->Z1_TABELA with cTabela
							
					SZ1->(dbcommit())
					SZ1->(msunlock())
				endif
			else
				SZ1->(dbappend())
				
				replace SZ1->Z1_FILIAL with xFilial("SZ1"),;
						SZ1->Z1_COTACAO with cCotacao,;
						SZ1->Z1_FORNECE with cFornece,;
						SZ1->Z1_LOJA with cLojaForn,;
						SZ1->Z1_TRANSP with cTransp,;
						SZ1->Z1_VLFRETE with nVlFrete,;
						SZ1->Z1_TABELA with cTabela
			endif
		else
			msgbox("Valor total do frete nao pode ser zerado!","Atencao","ALERT")
		endif
	else
		msgbox("Transportadora nao pode ser vazio!","Atencao","ALERT")
	endif
	
	SZ1->(dbclosearea())
	close(oDlg)
return