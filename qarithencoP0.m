function [code,state] = qarithencoP0(symb, P0,state,N)
%ARITHENCOP0 need probablity of zero only and finds needed disjoint
%intervals itself
%   CODE = ARITHENCO(SEQ, COUNTS) generates binary arithmetic code
dec_low=state(1);dec_up=state(2);E3_count=state(3);
% Compute the cumulative counts vector from the counts and intervals
counts=bordercmpt(state,P0);
cum_counts = [0, cumsum(counts)];
total_count = cum_counts(end);
code=[];
code_index = 1;
symbol = symb;
% Compute the new lower bound
dec_low_new = dec_low + floor( (dec_up-dec_low+1)*cum_counts(symbol+1-1)/total_count );
% Compute the new upper bound
dec_up = dec_low + floor( (dec_up-dec_low+1)*cum_counts(symbol+1)/total_count )-1;
% Update the lower bound
dec_low = dec_low_new;
% Check for E1, E2 or E3 conditions and keep looping as long as they occur.
while( isequal(bitget(dec_low, N), bitget(dec_up, N)) || ...
        (isequal(bitget(dec_low, N-1), 1) && isequal(bitget(dec_up, N-1), 0) ) ),
    % If it is an E1 or E2 condition,
    if isequal(bitget(dec_low, N), bitget(dec_up, N)),
        b = bitget(dec_low, N);
        code(code_index) = b;
        code_index = code_index + 1;
        dec_low = bitshift(dec_low, 1) + 0;
        dec_up = bitshift(dec_up, 1) + 1;
        if (E3_count > 0),
            code(code_index:code_index+E3_count-1) = bitcmp(b, 1).*ones(1, E3_count);
            code_index = code_index + E3_count;
            E3_count = 0;
        end
        dec_low = bitset(dec_low, N+1, 0);
        dec_up  = bitset(dec_up, N+1, 0);
    elseif ( (isequal(bitget(dec_low, N-1), 1) && ...
            isequal(bitget(dec_up, N-1), 0) ) ),
        dec_low = bitshift(dec_low, 1) + 0;
        dec_up  = bitshift(dec_up, 1) + 1;
        dec_low = bitset(dec_low, N+1, 0);
        dec_up  = bitset(dec_up, N+1, 0);
        dec_low = bitxor(dec_low, 2^(N-1) );
        dec_up  = bitxor(dec_up, 2^(N-1) );
        E3_count = E3_count+1;
    end
end
state=[dec_low,dec_up,E3_count];
% Output only the filled values
code = code(1:code_index-1);