function [uk]= smk(x)
n=length(x);
u=zeros(n-1,1);
m=zeros(n,1);
md=zeros(n,1);

for i=2:n
    s=0;
    for j=1:i
        if x(i)>x(j)
            m(i)=m(i)+1;
        end
    end
    
    md(i)=md(i-1)+m(i);
    
    s=md(i);
    ES=i*(i-1)/4;
    VarS=i*(i-1)*(2*i+5)/72;
    Z=(s-ES)/sqrt(VarS);
    u(i-1)=Z;
    
    if(i==2)
        disp( [ ' ES ' num2str( ES ) ] );
        disp( [ ' VarS ' num2str( VarS ) ] );
    end
end

uk=[0;u];
end