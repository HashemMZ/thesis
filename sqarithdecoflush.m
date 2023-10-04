function [dseq bitclk] = sqarithdecoflush(code,counts,N,E3_max,len,midFS)
%ARITHENCO Encode a sequence of symbols using arithmetic coding.
%   CODE = ARITHENCO(SEQ, COUNTS) generates binary arithmetic code
% NOTE !: some changes are made to encounter the error introduced in the
% coded seq in lines which ptr is released
if midFS% check the FS pattern (a FS b) or (a b FS)
    a=1;b=3;
else
    a=1;b=2;
end
bitclk=zeros(1,len);
% Compute the cumulative counts vector from the counts
cum_counts = [0, cumsum(counts)];
% Compute the Word Length required.
total_count = cum_counts(end);

% Initialize the lower and upper bounds.
dec_low = 0;
dec_up = 2^N-1;
E3_count=0;
HALF=2^N/2;
% Read the first N number of bits into a temporary tag bin_tag
bin_tag = code(1:N);
dec_tag = bi2de(bin_tag, 'left-msb');
% Initialize DSEQ
dseq = zeros(1,len);
dseq_index = 1;
k=N;
ptr = 0;

% This loop runs untill all the symbols are decoded into DSEQ
while (dseq_index <= len)
%     % Compute the cumulative counts vector from the counts and intervals
%     counts=bordercmpt([dec_low dec_up 0],P0);
%     % Compute the cumulative counts vector from the counts
%     cum_counts = [0, cumsum(counts)];
%     % Compute the Word Length required.
%     total_count = cum_counts(end);
       
    dec_tag_new =floor( ((dec_tag-dec_low+1)*total_count-1)/(dec_up-dec_low+1) );
    % Decode a symbol based on dec_tag_new
    if dec_tag_new<0% s/t in when seq has error  the last symbol produces negative dec_tag_new
        % so pick(...) makes error. we exclude such situations         
        ptr=3-midFS;%ptr will be FS        
    else
        ptr = pick(cum_counts, dec_tag_new);
    end
    if ptr> length(counts)
        ptr=3-midFS;
    end
    % Update DSEQ by adding the decoded symbol
    dseq(dseq_index) = ptr;
    bitclk(dseq_index)= k;
    dseq_index = dseq_index + 1;
    % Compute the new lower bound
    dec_low_new = dec_low + floor( (dec_up-dec_low+1)*cum_counts(ptr-1+1)/total_count );
    % Compute the new upper bound
    dec_up = dec_low + floor( (dec_up-dec_low+1)*cum_counts(ptr+1)/total_count )-1;
    % Update the lower bound
    dec_low = dec_low_new;

    % Check for E1, E2 or E3 conditions and keep looping as long as they occur.
    while ( isequal(bitget(dec_low, N), bitget(dec_up, N)) | ...
            ( isequal(bitget(dec_low, N-1), 1) & isequal(bitget(dec_up, N-1), 0) ) ),
        % Break out if we have finished working with all the bits in CODE
        if ( k==length(code) ), break, end;
        k = k + 1;
         if (E3_count>=E3_max) && (dec_up >= HALF &&  dec_up <1.5* HALF && dec_low < HALF && dec_low >= HALF/2)
            % Compute the cumulative counts vector from the counts
            if ptr==b
                dec_low=HALF;
            elseif ptr==a
                dec_up=HALF-1;
            end
        end
        % If it is an E1 or E2 condition, do
        if isequal(bitget(dec_low, N), bitget(dec_up, N)),
            % Left shifts and update
            dec_low = bitshift(dec_low, 1) + 0;
            dec_up  = bitshift(dec_up,  1) + 1;
            % Left shift and read in code
            dec_tag = bitshift(dec_tag, 1) + code(k);
            % Reduce to N for next loop
            dec_low = bitset(dec_low, N+1, 0);
            dec_up  = bitset(dec_up,  N+1, 0);
            dec_tag = bitset(dec_tag, N+1, 0);
            if  E3_count>0
                E3_count = 0;
            end
            % Else if it is an E3 condition
        elseif ( isequal(bitget(dec_low, N-1), 1) & ...
                isequal(bitget(dec_up, N-1), 0) ),
            % Left shifts and update
            dec_low = bitshift(dec_low, 1) + 0;
            dec_up  = bitshift(dec_up,  1) + 1;
            % Left shift and read in code
            dec_tag = bitshift(dec_tag, 1) + code(k);
            % Reduce to N for next loop
            dec_low = bitset(dec_low, N+1, 0);
            dec_up  = bitset(dec_up,  N+1, 0);
            dec_tag = bitset(dec_tag, N+1, 0);
            % Complement the new MSB of dec_low, dec_up and dec_tag
            dec_low = bitxor(dec_low, 2^(N-1) );
            dec_up  = bitxor(dec_up,  2^(N-1) );
            dec_tag = bitxor(dec_tag, 2^(N-1) );
            E3_count = E3_count+1;
           
        end
    end % end while
end % end while length(dseq)
%-------------------------------------------------------------
function [ptr] = pick(cum_counts, value);
% This internal function is used to find where value is positioned

% Check for this case and quickly exit
if value == cum_counts(end)
    ptr = length(cum_counts)-1;
    return
end

c = find(cum_counts <= value);
ptr = c(end);

%----------------------------------------------------------
% EOF
