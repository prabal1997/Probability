syms sym_pulse(x, k) sym_discrete_value(f, x, k)
sym_pulse(x, k) = heaviside(x)-heaviside(x-k);
sym_discrete_value(f, x, k) =  sym_pulse(x-floor(x/k)*k, k)*5*integral(f, 1, 4);
%( (1/k)*integral( f,k*floor(x/k),k*(1+floor(x/k)) ) )