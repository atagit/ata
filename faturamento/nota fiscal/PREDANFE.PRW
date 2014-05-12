/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 06/05/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Impressao PRE-DANFE                                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function PREDANFE()
//	private cAcesso := Repl(" ",10)

// Monta objeto para impressão
oPrint := TMSPrinter():New("Exemplo TMSPrinter")

oPrint:SetPortrait()
oPrint:Setup()
oPrint:StartPage()

oFont1  := TFont():New("Times New Roman",,8,,.F.)
oFont1N := TFont():New("Times New Roman",,8,,.T.)

//oPrint:Say(010,010,"COD. PROD",oFont1N,1400)
//oPrint:Say(040,010,"AAA000",oFont1,1400)



oPrint:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont1N)
oPrint:Box(442,000,678,603)
nAuxH := 0
oPrint:Box(442, nAuxH, 678, nAuxH + 10)
oPrint:Say(450, nAuxH + 2, "COD. PROD",oFont1N)
/*nAuxH += aTamCol[1]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[2])
oPrint:Say(450, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont1N)
nAuxH += aTamCol[2]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[3])
oPrint:Say(450, nAuxH + 2, "NCM/SH", oFont1N)
nAuxH += aTamCol[3]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[4])
oPrint:Say(450, nAuxH + 2, "CST", oFont1N)
nAuxH += aTamCol[4]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[5])
oPrint:Say(450, nAuxH + 2, "CFOP", oFont1N)
nAuxH += aTamCol[5]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[6])
oPrint:Say(450, nAuxH + 2, "UN", oFont1N)
nAuxH += aTamCol[6]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[7])
oPrint:Say(450, nAuxH + 2, "QUANT.", oFont1N)
nAuxH += aTamCol[7]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[8])
oPrint:Say(450, nAuxH + 2, "V.UNITARIO", oFont1N)
nAuxH += aTamCol[8]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[9])
oPrint:Say(450, nAuxH + 2, "V.TOTAL", oFont1N)
nAuxH += aTamCol[9]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[10])
oPrint:Say(450, nAuxH + 2, "BC.ICMS", oFont1N)
nAuxH += aTamCol[10]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[11])
oPrint:Say(450, nAuxH + 2, "V.ICMS", oFont1N)
nAuxH += aTamCol[11]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[12])
oPrint:Say(450, nAuxH + 2, "V.IPI", oFont1N)
nAuxH += aTamCol[12]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[13])
oPrint:Say(450, nAuxH + 2, "A.ICMS", oFont1N)
nAuxH += aTamCol[13]
oPrint:Box(442, nAuxH, 678, nAuxH + aTamCol[14])
oPrint:Say(450, nAuxH + 2, "A.IPI", oFont1N)*/

//oPrint:SayBitmap( 100,200,"C:\Dir\Totvs.bmp",400,400 )
//oPrint:Line( 130,10,130,900 )
//oPrint:Box( 130,10,600,900 )
//oBrush1 := TBrush():New( , CLR_YELLOW )
//oPrint:FillRect( {100, 10, 200, 200}, oBrush1 )
//oBrush1:End()
// Visualiza a impressão
oPrint:EndPage()
oPrint:Preview()
return