/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Tela para lançamento do frete                         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function FRETE(cTitulo,cCotacao,cFornece,cLojaForn,cTabela)
	local nLinini := 10
	
	private cTransp := Space(6)
	private nVlFrete := 0
	private oDlg
	
	DbSelectArea("SZ1")
	
	if SZ1->(DbSeek(xFilial("SZ1")+cCotacao+cFornece+cLojaForn,.F.))
		cTransp := SZ1->Z1_TRANSP
		nVlFrete := SZ1->Z1_VLFRETE
	endif
	
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
		
		@nLinini,031 bmpbutton type 01 action Gravar(cCotacao,cFornece,cLojaForn,cTransp,nVlFrete,cTabela)
		@nLinini,061 bmpbutton type 03 action Excluir(cCotacao,cFornece,cLojaForn,cTransp,nVlFrete,cTabela)
		@nLinini,091 bmpbutton type 02 action Close(oDlg)
	activate dialog oDlg center
return

static function Gravar(cCotacao,cFornece,cLojaForn,cTransp,nVlFrete,cTabela)
	DbSelectArea("SZ1")
	
	if !Empty(cTransp)
		if !Empty(nVlFrete)
			if SZ1->(DbSeek(xFilial("SZ1")+cCotacao+cFornece+cLojaForn,.F.))
				if RecLock("SZ1",.F.)
					replace SZ1->Z1_FILIAL with xFilial("SZ1"),;
							SZ1->Z1_COTACAO with cCotacao,;
							SZ1->Z1_FORNECE with cFornece,;
							SZ1->Z1_LOJA with cLojaForn,;
							SZ1->Z1_TRANSP with cTransp,;
							SZ1->Z1_VLFRETE with nVlFrete,;
							SZ1->Z1_TABELA with cTabela
							
					SZ1->(DbCommit())
					SZ1->(MsUnLock())
				endif
			else
				SZ1->(DbAppend())
				
				replace SZ1->Z1_FILIAL with xFilial("SZ1"),;
						SZ1->Z1_COTACAO with cCotacao,;
						SZ1->Z1_FORNECE with cFornece,;
						SZ1->Z1_LOJA with cLojaForn,;
						SZ1->Z1_TRANSP with cTransp,;
						SZ1->Z1_VLFRETE with nVlFrete,;
						SZ1->Z1_TABELA with cTabela
						
				SZ1->(DbCommit())
			endif
		else
			MsgBox("O valor total do frete nao pode ser zerado!","Atencao","ALERT")
		endif
	else
		MsgBox("A transportadora nao pode ser vazio!","Atencao","ALERT")
	endif
	
	SZ1->(DbCloseArea())
	Close(oDlg)
return

static function Excluir(cCotacao,cFornece,cLojaForn,cTransp,nVlFrete,cTabela)
	DbSelectArea("SZ1")
	
	if SZ1->(DbSeek(xFilial("SZ1")+cCotacao+cFornece+cLojaForn,.F.))
		if RecLock("SZ1",.F.)
			SZ1->(DbDelete())
			SZ1->(MsUnLock())
		endif
	endif
	
	Close(oDlg)
return