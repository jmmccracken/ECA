function flag = tolcheck(a,b,tol)

if( (a >= (b-tol)) && (a <= (b+tol)) ),
    flag = true;
else
    flag = false;
end;