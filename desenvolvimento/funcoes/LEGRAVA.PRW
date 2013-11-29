user function Scatter()
   local fvals[fcount()], fnum := 1
   
   aeval(fvals, {|elem| fvals[fnum++] := fieldget(fnum)})
return(fvals)

user function Gather(ar)
   local fnum := 1
   
//   aeval(ar, {|elem| fieldput(fnum,ar[fnum++])})
	aeval(ar, {|elem| fieldput(fnum,elem),fnum++})
return