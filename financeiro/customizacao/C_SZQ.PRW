/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/08/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cadastro das folhas de cheques do talao               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"

user function C_SZQ()
	private cCadastro := "Credito Bancario"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5}}
	
	DbSelectArea("SZQ")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZQ")
return


/*USER FUNCTION GRAVASZ2()
private x := 0
Dbselectarea("SZ2")
SZ2->(DBSETORDER(1))
SZ2->(DBGOTOP())
for x := 1 to oGetDados1:nAt
     If reclock('SZ2',.T.)
          SZ2->Z2_FILIAL := Xfilial("SB1")
          SZ2->Z2_OP := Alltrim(cOP)
          SZ2->Z2_OPER := NwFieldGet(oGetDados1,"Z2_OPER",x)
          SZ2->Z2_MOTIVO :=NwFieldGet(oGetDados1,"Z2_MOTIVO",x)
          SZ2->Z2_DESCRI := NwFieldGet(oGetDados1,"Z2_DESCRI",x)
          SZ2->Z2_DTOCOR := NwFieldGet(oGetDados1,"Z2_DTOCOR",x)
          SZ2->Z2_LIBERA := "A"
          SZ2->Z2_OBS := NwFieldGet(oGetDados1,"Z2_OBS",x)
          SZ2->Z2_SUP := NFORTODOS
          SZ2->( msunlock() )
     endif
next x
APMSGINFO("Dados Gravados com Sucessos!!!")
RETURN*/