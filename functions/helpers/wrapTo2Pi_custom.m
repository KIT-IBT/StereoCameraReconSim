function phi_equiv = wrapTo2Pi_custom(phi)
%% wrapTo2Pi_custom
%maps input angle "phi" to [0,2*PI], exists only to avoid requiring the 
%mapping toolbox
%N.B. this does not support matrix inputs, only scalars.
twoPi =  2 * pi;
%make sure N*2*pi maps to 2*pi, not 0 (convention used by original
%wrapTo2Pi)
if ~(phi == 0) && ~rem(phi,twoPi)
    phi_equiv = twoPi;
    return;
end

phi_equiv = mod(phi,twoPi);
end

