function h=get_data_hash(M)
z=cell2mat(M);
z=z(:); t=linspace(0,2*pi,length(z));
h=sum(log(1+abs((z/sum(z)).*sin(t'))))^2;
